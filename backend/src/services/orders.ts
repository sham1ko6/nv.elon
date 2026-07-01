import supabase from '../config/db';
import { AdOrder, Plan, Subscription } from '../types';

// Activates whatever the paid ad_order is for: a posting-fee listing goes
// 'active' with a fixed expiry; a subscription order activates the most
// recent pending subscription for that user+plan.
export async function activateOrder(orderId: number): Promise<void> {
  const { data: orderData, error: orderError } = await supabase
    .from('ad_orders')
    .select('*')
    .eq('id', orderId)
    .maybeSingle();
  if (orderError) throw orderError;

  const order = orderData as AdOrder | null;
  if (!order || order.status === 'paid') return;

  await supabase
    .from('ad_orders')
    .update({ status: 'paid', paid_at: new Date().toISOString() })
    .eq('id', orderId);

  if (order.type === 'posting_fee' && order.listing_id) {
    const { data: settingData } = await supabase
      .from('app_settings')
      .select('value')
      .eq('key', 'ad_duration_days')
      .maybeSingle();
    const days = Number((settingData as { value?: string } | null)?.value ?? 30);

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + days);

    await supabase
      .from('listings')
      .update({
        status: 'active',
        published_at: new Date().toISOString(),
        expires_at: expiresAt.toISOString(),
      })
      .eq('id', order.listing_id);
  }

  if (order.type === 'subscription' && order.plan_id) {
    const { data: planData } = await supabase
      .from('plans')
      .select('*')
      .eq('id', order.plan_id)
      .maybeSingle();

    const plan = planData as Plan | null;
    if (plan) {
      const { data: subData } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('user_id', order.user_id)
        .eq('plan_id', order.plan_id)
        .eq('status', 'pending')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      const subscription = subData as Subscription | null;
      if (subscription) {
        const now = new Date();
        const expiresAt = new Date(now);
        expiresAt.setDate(expiresAt.getDate() + plan.duration_days);

        await supabase
          .from('subscriptions')
          .update({
            status: 'active',
            started_at: now.toISOString(),
            expires_at: expiresAt.toISOString(),
          })
          .eq('id', subscription.id);
      }
    }
  }
}
