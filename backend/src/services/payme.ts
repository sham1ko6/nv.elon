import supabase from '../config/db';
import { activateOrder } from './orders';
import { AdOrder, PaymentTransaction } from '../types';

export class PaymeError extends Error {
  code: number;

  constructor(code: number, message: string) {
    super(message);
    this.code = code;
  }
}

interface PaymeAccount {
  order_id?: string | number;
}

interface CheckPerformParams {
  amount: number;
  account: PaymeAccount;
}

interface CreateTransactionParams {
  id: string;
  time: number;
  amount: number;
  account: PaymeAccount;
}

interface TransactionIdParams {
  id: string;
}

interface CancelTransactionParams {
  id: string;
  reason?: number;
}

async function getOrderForAccount(account: PaymeAccount): Promise<AdOrder> {
  const orderId = Number(account?.order_id);
  if (!orderId) {
    throw new PaymeError(-31050, "Buyurtma raqami noto'g'ri");
  }
  const { data, error } = await supabase
    .from('ad_orders')
    .select('*')
    .eq('id', orderId)
    .maybeSingle();
  if (error) throw error;
  if (!data) throw new PaymeError(-31050, 'Buyurtma topilmadi');
  return data as AdOrder;
}

async function findTransaction(providerTxnId: string): Promise<PaymentTransaction | null> {
  const { data, error } = await supabase
    .from('payment_transactions')
    .select('*')
    .eq('provider', 'payme')
    .eq('provider_txn_id', providerTxnId)
    .maybeSingle();
  if (error) throw error;
  return data as PaymentTransaction | null;
}

export async function checkPerformTransaction(params: CheckPerformParams) {
  const order = await getOrderForAccount(params.account);

  if (order.status !== 'created') {
    throw new PaymeError(-31008, "Buyurtma to'lov uchun tayyor emas");
  }

  const expectedTiyin = Math.round(Number(order.amount) * 100);
  if (Number(params.amount) !== expectedTiyin) {
    throw new PaymeError(-31001, "Noto'g'ri summa");
  }

  return { allow: true };
}

export async function createTransaction(params: CreateTransactionParams) {
  const order = await getOrderForAccount(params.account);
  const existing = await findTransaction(params.id);

  if (existing) {
    if (existing.state === '-1' || existing.state === '-2') {
      throw new PaymeError(-31008, 'Tranzaksiya bekor qilingan');
    }
    return {
      create_time: new Date(existing.created_at).getTime(),
      transaction: String(existing.id),
      state: Number(existing.state),
    };
  }

  if (order.status !== 'created') {
    throw new PaymeError(-31008, "Buyurtma to'lov uchun tayyor emas");
  }

  const expectedTiyin = Math.round(Number(order.amount) * 100);
  if (Number(params.amount) !== expectedTiyin) {
    throw new PaymeError(-31001, "Noto'g'ri summa");
  }

  const { data: txnData, error: txnError } = await supabase
    .from('payment_transactions')
    .insert({
      ad_order_id: order.id,
      provider: 'payme',
      provider_txn_id: params.id,
      state: '1',
      amount: Number(order.amount),
      raw_payload: params,
    })
    .select('id')
    .single();
  if (txnError) throw new PaymeError(-32603, 'Internal error');

  await supabase.from('ad_orders').update({ status: 'pending' }).eq('id', order.id);

  return {
    create_time: Number(params.time),
    transaction: String((txnData as { id: number }).id),
    state: 1,
  };
}

export async function performTransaction(params: TransactionIdParams) {
  const txn = await findTransaction(params.id);
  if (!txn) {
    throw new PaymeError(-31003, 'Tranzaksiya topilmadi');
  }

  if (txn.state === '2') {
    return {
      transaction: String(txn.id),
      perform_time: new Date(txn.updated_at).getTime(),
      state: 2,
    };
  }
  if (txn.state !== '1') {
    throw new PaymeError(-31008, "Tranzaksiyani bajarib bo'lmaydi");
  }

  await supabase
    .from('payment_transactions')
    .update({ state: '2' })
    .eq('id', txn.id);

  await activateOrder(txn.ad_order_id);

  const { data: updated } = await supabase
    .from('payment_transactions')
    .select('updated_at')
    .eq('id', txn.id)
    .single();

  return {
    transaction: String(txn.id),
    perform_time: updated ? new Date((updated as { updated_at: string }).updated_at).getTime() : Date.now(),
    state: 2,
  };
}

export async function cancelTransaction(params: CancelTransactionParams) {
  const txn = await findTransaction(params.id);
  if (!txn) {
    throw new PaymeError(-31003, 'Tranzaksiya topilmadi');
  }

  if (txn.state === '-1' || txn.state === '-2') {
    return {
      transaction: String(txn.id),
      cancel_time: new Date(txn.updated_at).getTime(),
      state: Number(txn.state),
    };
  }

  const newState = txn.state === '2' ? '-2' : '-1';

  await supabase
    .from('payment_transactions')
    .update({ state: newState })
    .eq('id', txn.id);

  await supabase.from('ad_orders').update({ status: 'cancelled' }).eq('id', txn.ad_order_id);

  const { data: updated } = await supabase
    .from('payment_transactions')
    .select('updated_at')
    .eq('id', txn.id)
    .single();

  return {
    transaction: String(txn.id),
    cancel_time: updated ? new Date((updated as { updated_at: string }).updated_at).getTime() : Date.now(),
    state: Number(newState),
  };
}
