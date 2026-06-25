import cron from 'node-cron';
import { execute } from '../config/db';

export async function runExpiryJob(): Promise<void> {
  const expiredSubscriptions = await execute(
    "UPDATE subscriptions SET status='expired' WHERE status='active' AND expires_at <= NOW()"
  );

  const expiredSubListings = await execute(
    `UPDATE listings l
     JOIN subscriptions s ON s.id = l.subscription_id
     SET l.status='expired'
     WHERE l.status='active' AND s.status='expired'`
  );

  const expiredFeeListings = await execute(
    "UPDATE listings SET status='expired' WHERE status='active' AND source='posting_fee' AND expires_at <= NOW()"
  );

  const expiredListings = expiredSubListings.affectedRows + expiredFeeListings.affectedRows;
  console.log(`Expired ${expiredSubscriptions.affectedRows} subscriptions, ${expiredListings} listings`);
}

export function startExpiryJob(): void {
  cron.schedule('0 * * * *', () => {
    runExpiryJob().catch((err) => console.error('Expiry job failed:', err));
  });
}
