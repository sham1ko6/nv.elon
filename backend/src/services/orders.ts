import { query, execute } from '../config/db';
import { AdOrder, Plan, Subscription } from '../types';

// Activates whatever the paid ad_order is for: a posting-fee listing goes
// 'active' with a fixed expiry; a subscription order activates the most
// recent pending subscription for that user+plan (ad_orders has no FK back
// to subscriptions, so this pairing is done by lookup instead of a join).
export async function activateOrder(orderId: number): Promise<void> {
  const [order] = await query<AdOrder>('SELECT * FROM ad_orders WHERE id = ?', [orderId]);
  if (!order || order.status === 'paid') {
    return;
  }

  await execute("UPDATE ad_orders SET status = 'paid', paid_at = NOW() WHERE id = ?", [orderId]);

  if (order.type === 'posting_fee' && order.listing_id) {
    const settingRows = await query<{ value: string }>(
      "SELECT value FROM app_settings WHERE `key` = 'ad_duration_days'"
    );
    const days = Number(settingRows[0]?.value ?? 30);

    await execute(
      `UPDATE listings SET status = 'active', published_at = NOW(), expires_at = DATE_ADD(NOW(), INTERVAL ? DAY)
       WHERE id = ?`,
      [days, order.listing_id]
    );
  }

  if (order.type === 'subscription' && order.plan_id) {
    const [plan] = await query<Plan>('SELECT * FROM plans WHERE id = ?', [order.plan_id]);
    if (plan) {
      const [subscription] = await query<Subscription>(
        `SELECT * FROM subscriptions WHERE user_id = ? AND plan_id = ? AND status = 'pending'
         ORDER BY created_at DESC LIMIT 1`,
        [order.user_id, order.plan_id]
      );
      if (subscription) {
        await execute(
          `UPDATE subscriptions SET status = 'active', started_at = NOW(),
            expires_at = DATE_ADD(NOW(), INTERVAL ? DAY) WHERE id = ?`,
          [plan.duration_days, subscription.id]
        );
      }
    }
  }
}
