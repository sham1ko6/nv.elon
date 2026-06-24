// =============================================================
// dev.routes.js  —  ⚠️ DEVELOPMENT / TESTING ONLY ⚠️
// =============================================================
// These endpoints FAKE the things that real services will do later, so
// you can test the full ad lifecycle today without Payme/Click or a real
// subscription purchase.
//
//   POST /dev/pay/:orderId        -> pretend an order was paid
//   POST /dev/grant-subscription  -> pretend you bought a plan
//
// app.js only mounts this file when NODE_ENV is NOT 'production', so it
// can never run on the real server. In Phase 3 these are replaced by real
// Payme/Click payment webhooks and a real subscribe flow.
// =============================================================
const express = require('express');
const { pool } = require('../config/db');
const { requireAuth } = require('../middleware/auth');
// Reuse the SAME "what happens when paid" logic the real Payme/Click use,
// so the dev shortcut and real payments always behave identically.
const { fulfillOrder } = require('../payments/fulfill');

const router = express.Router();

// ----------------------------------------------------------------
// POST /dev/pay/:orderId
// Marks a posting-fee order as paid and PUBLISHES its ad (status active,
// expires after the configured number of days). This mimics what the real
// payment webhook will do once a user actually pays via Payme/Click.
// ----------------------------------------------------------------
router.post('/pay/:orderId', requireAuth, async (req, res, next) => {
  const conn = await pool.getConnection();
  try {
    const orderId = parseInt(req.params.orderId, 10);
    if (!orderId) return res.status(400).json({ error: 'Invalid order id' });

    await conn.beginTransaction();

    // Find the order — and make sure it belongs to the logged-in user.
    const [orders] = await conn.query(
      'SELECT * FROM ad_orders WHERE id = ? AND user_id = ? LIMIT 1',
      [orderId, req.user.id]
    );
    if (orders.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: 'Order not found' });
    }
    const order = orders[0];
    if (order.status === 'paid') {
      await conn.rollback();
      return res.status(409).json({ error: 'Order already paid' });
    }

    // Mark the order paid AND deliver it (publish ad / start subscription),
    // exactly like a real Payme/Click payment would.
    await fulfillOrder(conn, order);

    await conn.commit();
    res.json({ message: 'Order paid (simulated). Ad is now active.', orderId, listingId: order.listing_id });
  } catch (err) {
    try { await conn.rollback(); } catch (_) {}
    next(err);
  } finally {
    conn.release();
  }
});

// ----------------------------------------------------------------
// POST /dev/grant-subscription
// Body: { planCode: 'monthly' | 'yearly' }
// Gives the logged-in user an active subscription so you can test the
// "publish via subscription" path. Real purchase comes in Phase 4.
// ----------------------------------------------------------------
router.post('/grant-subscription', requireAuth, async (req, res, next) => {
  try {
    const { planCode } = req.body;
    if (!planCode) return res.status(400).json({ error: 'planCode is required' });

    const [plans] = await pool.query('SELECT * FROM plans WHERE code = ? LIMIT 1', [planCode]);
    if (plans.length === 0) return res.status(404).json({ error: 'Unknown plan code' });
    const plan = plans[0];

    const [ins] = await pool.query(
      `INSERT INTO subscriptions (user_id, plan_id, status, started_at, expires_at)
       VALUES (?, ?, 'active', NOW(), NOW() + INTERVAL ? DAY)`,
      [req.user.id, plan.id, plan.duration_days]
    );

    res.status(201).json({
      message: 'Subscription granted (simulated).',
      subscription: { id: ins.insertId, plan: plan.code, durationDays: plan.duration_days },
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
