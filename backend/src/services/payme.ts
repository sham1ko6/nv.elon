import { query, execute } from '../config/db';
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
  const [order] = await query<AdOrder>('SELECT * FROM ad_orders WHERE id = ?', [orderId]);
  if (!order) {
    throw new PaymeError(-31050, 'Buyurtma topilmadi');
  }
  return order;
}

async function findTransaction(providerTxnId: string): Promise<PaymentTransaction | null> {
  const [txn] = await query<PaymentTransaction>(
    "SELECT * FROM payment_transactions WHERE provider = 'payme' AND provider_txn_id = ?",
    [providerTxnId]
  );
  return txn ?? null;
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

  const result = await execute(
    `INSERT INTO payment_transactions (ad_order_id, provider, provider_txn_id, state, amount, raw_payload)
     VALUES (?, 'payme', ?, '1', ?, ?)`,
    [order.id, params.id, Number(order.amount), JSON.stringify(params)]
  );
  await execute("UPDATE ad_orders SET status = 'pending' WHERE id = ?", [order.id]);

  return {
    create_time: Number(params.time),
    transaction: String(result.insertId),
    state: 1,
  };
}

export async function performTransaction(params: TransactionIdParams) {
  const txn = await findTransaction(params.id);
  if (!txn) {
    throw new PaymeError(-31003, 'Tranzaksiya topilmadi');
  }

  if (txn.state === '2') {
    return { transaction: String(txn.id), perform_time: new Date(txn.updated_at).getTime(), state: 2 };
  }
  if (txn.state !== '1') {
    throw new PaymeError(-31008, "Tranzaksiyani bajarib bo'lmaydi");
  }

  await execute("UPDATE payment_transactions SET state = '2' WHERE id = ?", [txn.id]);
  await activateOrder(txn.ad_order_id);

  const [updated] = await query<PaymentTransaction>('SELECT * FROM payment_transactions WHERE id = ?', [txn.id]);

  return {
    transaction: String(txn.id),
    perform_time: updated ? new Date(updated.updated_at).getTime() : Date.now(),
    state: 2,
  };
}

export async function cancelTransaction(params: CancelTransactionParams) {
  const txn = await findTransaction(params.id);
  if (!txn) {
    throw new PaymeError(-31003, 'Tranzaksiya topilmadi');
  }

  if (txn.state === '-1' || txn.state === '-2') {
    return { transaction: String(txn.id), cancel_time: new Date(txn.updated_at).getTime(), state: Number(txn.state) };
  }

  const newState = txn.state === '2' ? '-2' : '-1';
  await execute('UPDATE payment_transactions SET state = ? WHERE id = ?', [newState, txn.id]);
  await execute("UPDATE ad_orders SET status = 'cancelled' WHERE id = ?", [txn.ad_order_id]);

  const [updated] = await query<PaymentTransaction>('SELECT * FROM payment_transactions WHERE id = ?', [txn.id]);

  return {
    transaction: String(txn.id),
    cancel_time: updated ? new Date(updated.updated_at).getTime() : Date.now(),
    state: Number(newState),
  };
}
