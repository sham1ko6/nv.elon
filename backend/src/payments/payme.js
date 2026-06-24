// =============================================================
// payme.js — handles the Payme "Merchant API" webhook
// =============================================================
// HOW PAYME WORKS (plain language):
// Payme's servers send POST requests to our /payments/payme URL. Each
// request is "JSON-RPC": a JSON body like { method: "...", params: {...} }.
// Payme proves it's really them using HTTP Basic auth (username "Paycom"
// + your secret key). We answer each method, and the important one is
// PerformTransaction — that's when money is actually taken, so that's
// where we mark the order paid and switch the ad to active.
//
// Money note: Payme works in TIYIN (1 so'm = 100 tiyin). Our database
// stores amounts in so'm, so we multiply by 100 when comparing.
// =============================================================
const { pool } = require('../config/db');
const cfg = require('../config/payments').payme;
const { fulfillOrder } = require('./fulfill');

// Payme transaction states (their numbers, not ours).
const STATE = {
  CREATED: 1,             // waiting to be paid
  COMPLETED: 2,           // paid
  CANCELLED: -1,          // cancelled while still waiting
  CANCELLED_AFTER_PAY: -2 // cancelled after it was paid (refund)
};

// Payme error codes we use.
const ERR = {
  AUTH: -32504,
  METHOD: -32601,
  AMOUNT: -31001,
  TXN_NOT_FOUND: -31003,
  CANT_PERFORM: -31008,
  ORDER_NOT_FOUND: -31050,   // an "account" error (the order id was bad)
  ORDER_UNAVAILABLE: -31099, // order can't be paid (already paid / in progress)
};

// Build a localized message (Payme wants ru/uz/en).
const msg = (ru, uz, en) => ({ ru, uz, en });

// Send a JSON-RPC error back (still HTTP 200 — that's what Payme expects).
function rpcError(res, id, code, message, data) {
  return res.json({ jsonrpc: '2.0', id: id ?? null, error: { code, message, data } });
}
// Send a JSON-RPC success result.
function rpcResult(res, id, result) {
  return res.json({ jsonrpc: '2.0', id: id ?? null, result });
}

// Check the HTTP Basic auth header is "Paycom:<your key>".
function authOk(req) {
  const header = req.headers.authorization || '';
  if (!header.startsWith('Basic ')) return false;
  const decoded = Buffer.from(header.slice(6), 'base64').toString('utf8'); // "Paycom:KEY"
  const sep = decoded.indexOf(':');
  const pass = sep >= 0 ? decoded.slice(sep + 1) : '';
  return pass === cfg.key;
}

// Pull the order id out of Payme's "account" object and load the order.
async function loadOrderFromAccount(conn, params) {
  const account = params.account || {};
  const orderId = account[cfg.accountField];
  if (!orderId) return null;
  const [rows] = await conn.query('SELECT * FROM ad_orders WHERE id = ? LIMIT 1', [Number(orderId)]);
  return rows[0] || null;
}

// The expected amount for an order, in tiyin.
const tiyin = (order) => Math.round(Number(order.amount) * 100);

// ============================================================
// Main entry: Express calls this for POST /payments/payme
// ============================================================
async function handlePayme(req, res) {
  // 1) Security: reject anyone who isn't Payme.
  if (!authOk(req)) {
    return rpcError(res, req.body && req.body.id, ERR.AUTH,
      msg('Недостаточно привилегий', 'Ruxsat yetarli emas', 'Insufficient privileges'));
  }

  const { method, params, id } = req.body || {};
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    let out;
    switch (method) {
      case 'CheckPerformTransaction': out = await checkPerform(conn, params, id, res); break;
      case 'CreateTransaction':       out = await createTxn(conn, params, id, res); break;
      case 'PerformTransaction':      out = await performTxn(conn, params, id, res); break;
      case 'CancelTransaction':       out = await cancelTxn(conn, params, id, res); break;
      case 'CheckTransaction':        out = await checkTxn(conn, params, id, res); break;
      case 'GetStatement':            out = await getStatement(conn, params, id, res); break;
      default:
        await conn.rollback();
        return rpcError(res, id, ERR.METHOD, msg('Метод не найден', 'Metod topilmadi', 'Method not found'));
    }
    await conn.commit();
    return out;
  } catch (e) {
    try { await conn.rollback(); } catch (_) {}
    console.error('[payme] error:', e.message);
    return rpcError(res, req.body && req.body.id, ERR.CANT_PERFORM,
      msg('Внутренняя ошибка', 'Ichki xatolik', 'Internal error'));
  } finally {
    conn.release();
  }
}

// ---- CheckPerformTransaction: "can this order be paid?" ----
async function checkPerform(conn, params, id, res) {
  const order = await loadOrderFromAccount(conn, params);
  if (!order) {
    return rpcError(res, id, ERR.ORDER_NOT_FOUND,
      msg('Заказ не найден', 'Buyurtma topilmadi', 'Order not found'), cfg.accountField);
  }
  if (order.status === 'paid') {
    return rpcError(res, id, ERR.ORDER_UNAVAILABLE,
      msg('Заказ уже оплачен', "Buyurtma allaqachon to'langan", 'Order already paid'));
  }
  if (Number(params.amount) !== tiyin(order)) {
    return rpcError(res, id, ERR.AMOUNT, msg('Неверная сумма', "Noto'g'ri summa", 'Invalid amount'));
  }
  return rpcResult(res, id, { allow: true });
}

// ---- CreateTransaction: Payme registers a pending payment ----
async function createTxn(conn, params, id, res) {
  // If we've already seen this Payme transaction id, reply consistently.
  const [existing] = await conn.query(
    "SELECT * FROM payment_transactions WHERE provider = 'payme' AND provider_txn_id = ? LIMIT 1",
    [params.id]
  );
  if (existing.length) {
    const t = existing[0];
    if (Number(t.state) === STATE.CREATED) {
      return rpcResult(res, id, {
        create_time: Number(t.create_time),
        transaction: String(t.id),
        state: STATE.CREATED,
      });
    }
    return rpcError(res, id, ERR.CANT_PERFORM,
      msg('Невозможно выполнить', 'Bajarib bolmaydi', 'Unable to perform operation'));
  }

  // New transaction — validate the order first.
  const order = await loadOrderFromAccount(conn, params);
  if (!order) {
    return rpcError(res, id, ERR.ORDER_NOT_FOUND,
      msg('Заказ не найден', 'Buyurtma topilmadi', 'Order not found'), cfg.accountField);
  }
  if (Number(params.amount) !== tiyin(order)) {
    return rpcError(res, id, ERR.AMOUNT, msg('Неверная сумма', "Noto'g'ri summa", 'Invalid amount'));
  }
  if (order.status === 'paid') {
    return rpcError(res, id, ERR.ORDER_UNAVAILABLE,
      msg('Заказ уже оплачен', "Buyurtma to'langan", 'Order already paid'));
  }
  // Only one active Payme transaction per order.
  const [active] = await conn.query(
    "SELECT id FROM payment_transactions WHERE ad_order_id = ? AND provider = 'payme' AND state = '1' LIMIT 1",
    [order.id]
  );
  if (active.length) {
    return rpcError(res, id, ERR.ORDER_UNAVAILABLE,
      msg('Заказ в обработке', 'Buyurtma jarayonda', 'Order is being processed'));
  }

  const createTime = Number(params.time) || Date.now();
  const [ins] = await conn.query(
    `INSERT INTO payment_transactions
       (ad_order_id, provider, provider_txn_id, state, amount, create_time, raw_payload)
     VALUES (?, 'payme', ?, '1', ?, ?, ?)`,
    [order.id, params.id, order.amount, createTime, JSON.stringify(params)]
  );
  // Move the order into "pending" so the UI can reflect it.
  await conn.query("UPDATE ad_orders SET status = 'pending' WHERE id = ? AND status = 'created'", [order.id]);

  return rpcResult(res, id, {
    create_time: createTime,
    transaction: String(ins.insertId),
    state: STATE.CREATED,
  });
}

// ---- PerformTransaction: money taken -> activate the ad ----
async function performTxn(conn, params, id, res) {
  const [rows] = await conn.query(
    "SELECT * FROM payment_transactions WHERE provider = 'payme' AND provider_txn_id = ? LIMIT 1",
    [params.id]
  );
  if (!rows.length) {
    return rpcError(res, id, ERR.TXN_NOT_FOUND,
      msg('Транзакция не найдена', 'Tranzaksiya topilmadi', 'Transaction not found'));
  }
  const t = rows[0];

  if (Number(t.state) === STATE.CREATED) {
    const performTime = Date.now();
    // This is the real moment of payment: deliver the goods.
    const [orders] = await conn.query('SELECT * FROM ad_orders WHERE id = ? LIMIT 1', [t.ad_order_id]);
    await fulfillOrder(conn, orders[0]);
    await conn.query(
      "UPDATE payment_transactions SET state = '2', perform_time = ? WHERE id = ?",
      [performTime, t.id]
    );
    return rpcResult(res, id, { transaction: String(t.id), perform_time: performTime, state: STATE.COMPLETED });
  }

  if (Number(t.state) === STATE.COMPLETED) {
    // Already done — reply with the stored values (idempotent).
    return rpcResult(res, id, {
      transaction: String(t.id),
      perform_time: Number(t.perform_time),
      state: STATE.COMPLETED,
    });
  }

  return rpcError(res, id, ERR.CANT_PERFORM,
    msg('Невозможно выполнить', 'Bajarib bolmaydi', 'Unable to perform operation'));
}

// ---- CancelTransaction: undo a payment ----
async function cancelTxn(conn, params, id, res) {
  const [rows] = await conn.query(
    "SELECT * FROM payment_transactions WHERE provider = 'payme' AND provider_txn_id = ? LIMIT 1",
    [params.id]
  );
  if (!rows.length) {
    return rpcError(res, id, ERR.TXN_NOT_FOUND,
      msg('Транзакция не найдена', 'Tranzaksiya topilmadi', 'Transaction not found'));
  }
  const t = rows[0];
  const cancelTime = Date.now();

  if (Number(t.state) === STATE.CREATED) {
    await conn.query(
      "UPDATE payment_transactions SET state = '-1', cancel_time = ?, reason = ? WHERE id = ?",
      [cancelTime, params.reason ?? null, t.id]
    );
    return rpcResult(res, id, { transaction: String(t.id), cancel_time: cancelTime, state: STATE.CANCELLED });
  }

  if (Number(t.state) === STATE.COMPLETED) {
    // Reverse the delivery: order back to cancelled, ad back to unpublished.
    const [orders] = await conn.query('SELECT * FROM ad_orders WHERE id = ? LIMIT 1', [t.ad_order_id]);
    const order = orders[0];
    await conn.query("UPDATE ad_orders SET status = 'cancelled' WHERE id = ?", [order.id]);
    if (order.type === 'posting_fee' && order.listing_id) {
      await conn.query("UPDATE listings SET status = 'pending_payment' WHERE id = ?", [order.listing_id]);
    }
    await conn.query(
      "UPDATE payment_transactions SET state = '-2', cancel_time = ?, reason = ? WHERE id = ?",
      [cancelTime, params.reason ?? null, t.id]
    );
    return rpcResult(res, id, { transaction: String(t.id), cancel_time: cancelTime, state: STATE.CANCELLED_AFTER_PAY });
  }

  // Already cancelled — echo stored values.
  return rpcResult(res, id, {
    transaction: String(t.id),
    cancel_time: Number(t.cancel_time),
    state: Number(t.state),
  });
}

// ---- CheckTransaction: report a transaction's status ----
async function checkTxn(conn, params, id, res) {
  const [rows] = await conn.query(
    "SELECT * FROM payment_transactions WHERE provider = 'payme' AND provider_txn_id = ? LIMIT 1",
    [params.id]
  );
  if (!rows.length) {
    return rpcError(res, id, ERR.TXN_NOT_FOUND,
      msg('Транзакция не найдена', 'Tranzaksiya topilmadi', 'Transaction not found'));
  }
  const t = rows[0];
  return rpcResult(res, id, {
    create_time: Number(t.create_time),
    perform_time: Number(t.perform_time),
    cancel_time: Number(t.cancel_time),
    transaction: String(t.id),
    state: Number(t.state),
    reason: t.reason ?? null,
  });
}

// ---- GetStatement: list transactions in a time range ----
async function getStatement(conn, params, id, res) {
  const [rows] = await conn.query(
    `SELECT * FROM payment_transactions
      WHERE provider = 'payme' AND create_time >= ? AND create_time <= ?`,
    [Number(params.from), Number(params.to)]
  );
  const transactions = rows.map((t) => ({
    id: t.provider_txn_id,
    time: Number(t.create_time),
    amount: Math.round(Number(t.amount) * 100), // back to tiyin
    account: { [cfg.accountField]: String(t.ad_order_id) },
    create_time: Number(t.create_time),
    perform_time: Number(t.perform_time),
    cancel_time: Number(t.cancel_time),
    transaction: String(t.id),
    state: Number(t.state),
    reason: t.reason ?? null,
  }));
  return rpcResult(res, id, { transactions });
}

module.exports = { handlePayme };
