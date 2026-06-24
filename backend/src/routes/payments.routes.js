// =============================================================
// payments.routes.js — the payment URLs
// =============================================================
//   POST /payments/payme            <- Payme servers call this
//   POST /payments/click/prepare    <- Click servers call this (step 1)
//   POST /payments/click/complete   <- Click servers call this (step 2)
//   POST /payments/init             <- our app calls this to get a pay link
//
// The three webhook routes are PUBLIC (the payment companies call them and
// prove themselves with auth/signature inside the handlers). /init requires
// the user to be logged in.
// =============================================================
const express = require('express');
const { pool } = require('../config/db');
const { requireAuth } = require('../middleware/auth');
const paymentsCfg = require('../config/payments');
const { handlePayme } = require('../payments/payme');
const { handleClickPrepare, handleClickComplete } = require('../payments/click');

const router = express.Router();

// ---- Webhooks (called by Payme / Click, not by our app) ----
router.post('/payme', handlePayme);
router.post('/click/prepare', handleClickPrepare);
router.post('/click/complete', handleClickComplete);

// ---- /payments/init — give the app a link to send the buyer to ----
// Body: { orderId, provider }  provider = 'payme' | 'click'
// Returns { paymentUrl } that opens the provider's payment page.
router.post('/init', requireAuth, async (req, res, next) => {
  try {
    const { orderId, provider } = req.body;
    if (!orderId || !provider) {
      return res.status(400).json({ error: 'orderId and provider are required' });
    }

    // Load the order and make sure it belongs to this user and is unpaid.
    const [rows] = await pool.query(
      'SELECT * FROM ad_orders WHERE id = ? AND user_id = ? LIMIT 1',
      [Number(orderId), req.user.id]
    );
    const order = rows[0];
    if (!order) return res.status(404).json({ error: 'Order not found' });
    if (order.status === 'paid') return res.status(409).json({ error: 'Order already paid' });

    let paymentUrl;
    if (provider === 'payme') {
      // Payme wants its parameters base64-encoded in the URL.
      const c = paymentsCfg.payme;
      const tiyin = Math.round(Number(order.amount) * 100);
      const raw = `m=${c.merchantId};ac.${c.accountField}=${order.id};a=${tiyin}`;
      const encoded = Buffer.from(raw, 'utf8').toString('base64');
      paymentUrl = `${c.checkoutBaseUrl}/${encoded}`;
    } else if (provider === 'click') {
      const c = paymentsCfg.click;
      const params = new URLSearchParams({
        service_id: c.serviceId,
        merchant_id: c.merchantId,
        amount: String(order.amount),
        transaction_param: String(order.id), // becomes merchant_trans_id in callbacks
      });
      paymentUrl = `${c.checkoutBaseUrl}?${params.toString()}`;
    } else {
      return res.status(400).json({ error: "provider must be 'payme' or 'click'" });
    }

    res.json({ paymentUrl, orderId: order.id, provider });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
