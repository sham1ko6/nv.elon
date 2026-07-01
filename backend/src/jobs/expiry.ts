import supabase from '../config/db';

export async function runExpiryJob(): Promise<void> {
  const now = new Date().toISOString();

  // Step 1: mark subscriptions as expired
  const { data: expiredSubs, error: subError } = await supabase
    .from('subscriptions')
    .update({ status: 'expired' })
    .eq('status', 'active')
    .lte('expires_at', now)
    .select('id');
  if (subError) throw subError;

  const expiredSubCount = expiredSubs?.length ?? 0;

  // Step 2: expire listings tied to those subscriptions
  let expiredSubListingsCount = 0;
  if (expiredSubs && expiredSubs.length > 0) {
    const { data: subListings, error: slError } = await supabase
      .from('listings')
      .update({ status: 'expired' })
      .eq('status', 'active')
      .in('subscription_id', expiredSubs.map((s: { id: number }) => s.id))
      .select('id');
    if (slError) throw slError;
    expiredSubListingsCount = subListings?.length ?? 0;
  }

  // Step 3: expire posting-fee listings past their expiry date
  const { data: feeListings, error: flError } = await supabase
    .from('listings')
    .update({ status: 'expired' })
    .eq('status', 'active')
    .eq('source', 'posting_fee')
    .lte('expires_at', now)
    .select('id');
  if (flError) throw flError;

  const expiredListings = expiredSubListingsCount + (feeListings?.length ?? 0);
  console.log(`Expired ${expiredSubCount} subscriptions, ${expiredListings} listings`);
}

export function startExpiryJob(): void {
  import('node-cron').then(({ default: cron }) => {
    cron.schedule('0 * * * *', () => {
      runExpiryJob().catch((err) => console.error('Expiry job failed:', err));
    });
  });
}
