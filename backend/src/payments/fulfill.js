// =============================================================
// fulfill.js — what happens when an order is actually PAID
// =============================================================
// No matter HOW an order gets paid (Payme, Click, or the dev fake-pay),
// the result must be the same. So that logic lives here in ONE function,
// and all three payment paths call it. This avoids the three of them
// drifting apart over time.
// =============================================================

// Read a value from the app_settings table (e.g. how long a paid ad lasts).
async function getSetting(conn, key, fallback) {
  const [rows] = await conn.query('SELECT `value` FROM app_settings WHERE `key` = ?', [key]);
  return rows.length ? rows[0].value : fallback;
}

// Mark the order paid and deliver what was bought.
//   - posting_fee  -> publish the ad (active, with an expiry date)
//   - subscription -> start an active subscription for the user
// `conn` is a transaction connection so the caller controls commit/rollback.
async function fulfillOrder(conn, order) {
  // 1) Mark the order as paid (only if it isn't already).
  await conn.query(
    "UPDATE ad_orders SET status = 'paid', paid_at = NOW() WHERE id = ? AND status <> 'paid'",
    [order.id]
  );

  // 2a) Posting fee -> the ad goes live for a fixed number of days.
  if (order.type === 'posting_fee' && order.listing_id) {
    const termDays = Number(await getSetting(conn, 'ad_term_days', '30'));
    await conn.query(
      `UPDATE listings
          SET status = 'active', published_at = NOW(),
              expires_at = NOW() + INTERVAL ? DAY
        WHERE id = ?`,
      [termDays, order.listing_id]
    );
  }

  // 2b) Subscription -> create an active subscription for this user.
  if (order.type === 'subscription' && order.plan_id) {
    const [plans] = await conn.query('SELECT * FROM plans WHERE id = ? LIMIT 1', [order.plan_id]);
    if (plans.length) {
      const plan = plans[0];
      await conn.query(
        `INSERT INTO subscriptions (user_id, plan_id, status, started_at, expires_at)
         VALUES (?, ?, 'active', NOW(), NOW() + INTERVAL ? DAY)`,
        [order.user_id, order.plan_id, plan.duration_days]
      );
    }
  }
}

module.exports = { fulfillOrder, getSetting };
