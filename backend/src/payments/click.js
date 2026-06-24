// =============================================================
// click.js — handles the Click "Merchant API" webhook
// =============================================================
// HOW CLICK WORKS (plain language):
// Click calls our server TWICE for one payment:
//   1) PREPARE  — "a customer wants to pay order X, is that OK?"
//   2) COMPLETE — "the money went through, finish it."
// Each call is form data (not JSON) and includes a "sign_string": an MD5
// fingerprint built from the fields + your SECRET KEY. We rebuild that
// fingerprint ourselves and only trust the request if it matches — that's
// how we know it's really Click and nobody faked it.
//
// Money note: Click works in so'm (e.g. "15000.00"), same as our database.
// =============================================================
const crypto = require('crypto');
const { pool } = require('../config/db');
const cfg = require('../config/payments').click;
const { fulfillOrder } = require('./fulfill');

// Click result codes (it expects these exact numbers back).
const E = {
  OK: 0,
  SIGN_FAIL: -1,
  BAD_AMOUNT: -2,
  ACTION_NOT_FOUND: -3,
  ALREADY_PAID: -4,
  ORDER_NOT_FOUND: -5,
  TXN_NOT_FOUND: -6,
  CANCELLED: -9,
};

const md5 = (s) => crypto.createHash('md5').update(s).digest('hex');

// Rebuild the PREPARE fingerprint and compare with what Click sent.
function prepareSignOk(b) {
  const mine = md5(
    b.click_trans_id + b.service_id + cfg.secretKey +
    b.merchant_trans_id + b.amount + b.action + b.sign_time
  );
  return mine === b.sign_string;
}

// Rebuild the COMPLETE fingerprint (note: it also includes merchant_prepare_id).
function completeSignOk(b) {
  const mine = md5(
    b.click_trans_id + b.service_id + cfg.secretKey +
    b.merchant_trans_id + b.merchant_prepare_id + b.amount + b.action + b.sign_time
  );
  return mine === b.sign_string;
}

// Compare two money amounts allowing for tiny rounding differences.
const sameAmount = (a, b) => Math.abs(Number(a) - Number(b)) < 0.01;

// ============================================================
// PREPARE  — POST /payments/click/prepare   (Click sends action=0)
// ============================================================
async function handleClickPrepare(req, res) {
  const b = req.body || {};

  if (!prepareSignOk(b)) {
    return res.json({ error: E.SIGN_FAIL, error_note: 'SIGN CHECK FAILED' });
  }
  if (String(b.action) !== '0') {
    return res.json({ error: E.ACTION_NOT_FOUND, error_note: 'Action not found' });
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [orders] = await conn.query('SELECT * FROM ad_orders WHERE id = ? LIMIT 1', [Number(b.merchant_trans_id)]);
    const order = orders[0];
    if (!order) {
      await conn.rollback();
      return res.json({ error: E.ORDER_NOT_FOUND, error_note: 'Order not found' });
    }
    if (order.status === 'paid') {
      await conn.rollback();
      return res.json({ error: E.ALREADY_PAID, error_note: 'Already paid' });
    }
    if (!sameAmount(b.amount, order.amount)) {
      await conn.rollback();
      return res.json({ error: E.BAD_AMOUNT, error_note: 'Incorrect amount' });
    }

    // Reuse an existing prepared row if Click retries; otherwise create one.
    let prepareId;
    const [existing] = await conn.query(
      "SELECT id FROM payment_transactions WHERE provider = 'click' AND provider_txn_id = ? LIMIT 1",
      [b.click_trans_id]
    );
    if (existing.length) {
      prepareId = existing[0].id;
    } else {
      const [ins] = await conn.query(
        `INSERT INTO payment_transactions
           (ad_order_id, provider, provider_txn_id, state, amount, raw_payload)
         VALUES (?, 'click', ?, 'prepared', ?, ?)`,
        [order.id, b.click_trans_id, order.amount, JSON.stringify(b)]
      );
      prepareId = ins.insertId;
    }
    await conn.query("UPDATE ad_orders SET status = 'pending' WHERE id = ? AND status = 'created'", [order.id]);

    await conn.commit();
    // merchant_prepare_id is OUR id; Click sends it back in the Complete call.
    return res.json({
      click_trans_id: b.click_trans_id,
      merchant_trans_id: b.merchant_trans_id,
      merchant_prepare_id: prepareId,
      error: E.OK,
      error_note: 'Success',
    });
  } catch (e) {
    try { await conn.rollback(); } catch (_) {}
    console.error('[click prepare] error:', e.message);
    return res.json({ error: E.TXN_NOT_FOUND, error_note: 'Internal error' });
  } finally {
    conn.release();
  }
}

// ============================================================
// COMPLETE — POST /payments/click/complete  (Click sends action=1)
// ============================================================
async function handleClickComplete(req, res) {
  const b = req.body || {};

  if (!completeSignOk(b)) {
    return res.json({ error: E.SIGN_FAIL, error_note: 'SIGN CHECK FAILED' });
  }
  if (String(b.action) !== '1') {
    return res.json({ error: E.ACTION_NOT_FOUND, error_note: 'Action not found' });
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // Find the prepared transaction (must match both ids).
    const [rows] = await conn.query(
      "SELECT * FROM payment_transactions WHERE provider = 'click' AND provider_txn_id = ? AND id = ? LIMIT 1",
      [b.click_trans_id, Number(b.merchant_prepare_id)]
    );
    const t = rows[0];
    if (!t) {
      await conn.rollback();
      return res.json({ error: E.TXN_NOT_FOUND, error_note: 'Transaction not found' });
    }

    // Already finished? Reply success without doing it twice.
    if (t.state === 'completed') {
      await conn.rollback();
      return res.json({
        click_trans_id: b.click_trans_id,
        merchant_trans_id: b.merchant_trans_id,
        merchant_confirm_id: t.id,
        error: E.OK,
        error_note: 'Already completed',
      });
    }

    // Click tells us (via its own "error" field) if the payment failed.
    if (Number(b.error) < 0) {
      await conn.query("UPDATE payment_transactions SET state = 'cancelled' WHERE id = ?", [t.id]);
      await conn.commit();
      return res.json({ error: E.CANCELLED, error_note: 'Transaction cancelled' });
    }

    if (!sameAmount(b.amount, t.amount)) {
      await conn.rollback();
      return res.json({ error: E.BAD_AMOUNT, error_note: 'Incorrect amount' });
    }

    // All good — take the money's effect: publish the ad / start subscription.
    const [orders] = await conn.query('SELECT * FROM ad_orders WHERE id = ? LIMIT 1', [t.ad_order_id]);
    if (orders[0].status === 'paid') {
      await conn.rollback();
      return res.json({ error: E.ALREADY_PAID, error_note: 'Already paid' });
    }
    await fulfillOrder(conn, orders[0]);
    await conn.query("UPDATE payment_transactions SET state = 'completed' WHERE id = ?", [t.id]);

    await conn.commit();
    return res.json({
      click_trans_id: b.click_trans_id,
      merchant_trans_id: b.merchant_trans_id,
      merchant_confirm_id: t.id,
      error: E.OK,
      error_note: 'Success',
    });
  } catch (e) {
    try { await conn.rollback(); } catch (_) {}
    console.error('[click complete] error:', e.message);
    return res.json({ error: E.TXN_NOT_FOUND, error_note: 'Internal error' });
  } finally {
    conn.release();
  }
}

module.exports = { handleClickPrepare, handleClickComplete };
