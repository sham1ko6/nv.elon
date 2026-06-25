import crypto from 'crypto';
import { query, execute } from '../config/db';
import { activateOrder } from './orders';
import { AdOrder, PaymentTransaction } from '../types';

const SECRET_KEY = process.env.CLICK_SECRET_KEY || '';

export interface ClickRequestBody {
  click_trans_id: string | number;
  service_id: string | number;
  merchant_trans_id: string | number;
  amount: string | number;
  action: string | number;
  sign_time: string;
  sign_string: string;
  merchant_prepare_id?: string | number;
  error?: string | number;
}

export function verifySign(body: ClickRequestBody): boolean {
  const action = Number(body.action);
  const parts =
    action === 1
      ? [
          body.click_trans_id,
          body.service_id,
          SECRET_KEY,
          body.merchant_trans_id,
          body.merchant_prepare_id,
          body.amount,
          body.action,
          body.sign_time,
        ]
      : [body.click_trans_id, body.service_id, SECRET_KEY, body.merchant_trans_id, body.amount, body.action, body.sign_time];

  const expected = crypto.createHash('md5').update(parts.join('')).digest('hex');
  return Boolean(body.sign_string) && expected === body.sign_string;
}

export async function prepare(body: ClickRequestBody) {
  const orderId = Number(body.merchant_trans_id);
  const [order] = await query<AdOrder>('SELECT * FROM ad_orders WHERE id = ?', [orderId]);
  if (!order) {
    return { error: -5, error_note: 'Buyurtma topilmadi' };
  }
  if (order.status !== 'created') {
    return { error: -4, error_note: "Buyurtma allaqachon to'langan yoki bekor qilingan" };
  }

  const expectedAmount = Math.round(Number(order.amount));
  if (Math.round(Number(body.amount)) !== expectedAmount) {
    return { error: -2, error_note: "Summa noto'g'ri" };
  }

  const result = await execute(
    `INSERT INTO payment_transactions (ad_order_id, provider, provider_txn_id, state, amount, raw_payload)
     VALUES (?, 'click', ?, 'prepared', ?, ?)`,
    [order.id, String(body.click_trans_id), Number(order.amount), JSON.stringify(body)]
  );
  await execute("UPDATE ad_orders SET status = 'pending' WHERE id = ?", [order.id]);

  return {
    click_trans_id: body.click_trans_id,
    merchant_trans_id: body.merchant_trans_id,
    merchant_prepare_id: result.insertId,
    error: 0,
    error_note: 'Success',
  };
}

export async function complete(body: ClickRequestBody) {
  const orderId = Number(body.merchant_trans_id);
  const [order] = await query<AdOrder>('SELECT * FROM ad_orders WHERE id = ?', [orderId]);
  if (!order) {
    return { error: -5, error_note: 'Buyurtma topilmadi' };
  }

  const [txn] = await query<PaymentTransaction>(
    "SELECT * FROM payment_transactions WHERE id = ? AND provider = 'click'",
    [Number(body.merchant_prepare_id)]
  );
  if (!txn) {
    return { error: -6, error_note: 'Tranzaksiya topilmadi' };
  }
  if (txn.state === 'cancelled') {
    return { error: -9, error_note: 'Tranzaksiya bekor qilingan' };
  }

  if (Number(body.error) < 0) {
    await execute("UPDATE payment_transactions SET state = 'cancelled' WHERE id = ?", [txn.id]);
    await execute("UPDATE ad_orders SET status = 'cancelled' WHERE id = ?", [order.id]);
    return {
      click_trans_id: body.click_trans_id,
      merchant_trans_id: body.merchant_trans_id,
      merchant_confirm_id: txn.id,
      error: 0,
      error_note: 'Success',
    };
  }

  if (txn.state === 'confirmed') {
    return {
      click_trans_id: body.click_trans_id,
      merchant_trans_id: body.merchant_trans_id,
      merchant_confirm_id: txn.id,
      error: 0,
      error_note: 'Already confirmed',
    };
  }

  await execute("UPDATE payment_transactions SET state = 'confirmed' WHERE id = ?", [txn.id]);
  await activateOrder(order.id);

  return {
    click_trans_id: body.click_trans_id,
    merchant_trans_id: body.merchant_trans_id,
    merchant_confirm_id: txn.id,
    error: 0,
    error_note: 'Success',
  };
}
