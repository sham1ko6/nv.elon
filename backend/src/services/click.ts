import crypto from 'crypto';
import supabase from '../config/db';
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
      : [
          body.click_trans_id,
          body.service_id,
          SECRET_KEY,
          body.merchant_trans_id,
          body.amount,
          body.action,
          body.sign_time,
        ];

  const expected = crypto.createHash('md5').update(parts.join('')).digest('hex');
  return Boolean(body.sign_string) && expected === body.sign_string;
}

export async function prepare(body: ClickRequestBody) {
  const orderId = Number(body.merchant_trans_id);

  const { data: orderData } = await supabase
    .from('ad_orders')
    .select('*')
    .eq('id', orderId)
    .maybeSingle();

  const order = orderData as AdOrder | null;
  if (!order) return { error: -5, error_note: 'Buyurtma topilmadi' };
  if (order.status !== 'created') {
    return { error: -4, error_note: "Buyurtma allaqachon to'langan yoki bekor qilingan" };
  }

  const expectedAmount = Math.round(Number(order.amount));
  if (Math.round(Number(body.amount)) !== expectedAmount) {
    return { error: -2, error_note: "Summa noto'g'ri" };
  }

  const { data: txnData, error: txnError } = await supabase
    .from('payment_transactions')
    .insert({
      ad_order_id: order.id,
      provider: 'click',
      provider_txn_id: String(body.click_trans_id),
      state: 'prepared',
      amount: Number(order.amount),
      raw_payload: body,
    })
    .select('id')
    .single();
  if (txnError) return { error: -9, error_note: 'Internal error' };

  await supabase.from('ad_orders').update({ status: 'pending' }).eq('id', order.id);

  return {
    click_trans_id: body.click_trans_id,
    merchant_trans_id: body.merchant_trans_id,
    merchant_prepare_id: (txnData as { id: number }).id,
    error: 0,
    error_note: 'Success',
  };
}

export async function complete(body: ClickRequestBody) {
  const orderId = Number(body.merchant_trans_id);

  const { data: orderData } = await supabase
    .from('ad_orders')
    .select('*')
    .eq('id', orderId)
    .maybeSingle();

  const order = orderData as AdOrder | null;
  if (!order) return { error: -5, error_note: 'Buyurtma topilmadi' };

  const { data: txnData } = await supabase
    .from('payment_transactions')
    .select('*')
    .eq('id', Number(body.merchant_prepare_id))
    .eq('provider', 'click')
    .maybeSingle();

  const txn = txnData as PaymentTransaction | null;
  if (!txn) return { error: -6, error_note: 'Tranzaksiya topilmadi' };
  if (txn.state === 'cancelled') return { error: -9, error_note: 'Tranzaksiya bekor qilingan' };

  if (Number(body.error) < 0) {
    await supabase
      .from('payment_transactions')
      .update({ state: 'cancelled' })
      .eq('id', txn.id);
    await supabase.from('ad_orders').update({ status: 'cancelled' }).eq('id', order.id);
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

  await supabase
    .from('payment_transactions')
    .update({ state: 'confirmed' })
    .eq('id', txn.id);

  await activateOrder(order.id);

  return {
    click_trans_id: body.click_trans_id,
    merchant_trans_id: body.merchant_trans_id,
    merchant_confirm_id: txn.id,
    error: 0,
    error_note: 'Success',
  };
}
