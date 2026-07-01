import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
import { AppError } from '../middleware/errorHandler';
import * as payme from '../services/payme';
import * as click from '../services/click';
import { AdOrder, PaymentProvider } from '../types';

const PAYME_KEY = process.env.PAYME_KEY || '';

function isPaymeAuthorized(req: Request): boolean {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Basic ')) return false;

  const decoded = Buffer.from(header.slice('Basic '.length), 'base64').toString('utf-8');
  const separatorIndex = decoded.indexOf(':');
  if (separatorIndex === -1) return false;

  const key = decoded.slice(separatorIndex + 1);
  return PAYME_KEY.length > 0 && key === PAYME_KEY;
}

export async function initPayment(req: Request, res: Response, next: NextFunction) {
  try {
    const { order_id, provider } = req.body as { order_id?: number; provider?: PaymentProvider };
    if (!order_id || !provider) {
      throw new AppError(400, 'order_id va provider talab qilinadi');
    }
    if (provider !== 'payme' && provider !== 'click') {
      throw new AppError(400, "provider 'payme' yoki 'click' bo'lishi kerak");
    }

    const { data: orderData, error: fetchError } = await supabase
      .from('ad_orders')
      .select('*')
      .eq('id', order_id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!orderData) throw new AppError(404, 'Buyurtma topilmadi');

    const order = orderData as AdOrder;
    if (order.user_id !== req.user!.id) {
      throw new AppError(403, 'Bu buyurtma sizga tegishli emas');
    }

    const { error } = await supabase.from('payment_transactions').insert({
      ad_order_id: order.id,
      provider,
      state: 'created',
      amount: Number(order.amount),
    });
    if (error) throw error;

    res.status(200).json({ checkout_url: `https://checkout.stub/${provider}/${order.id}` });
  } catch (err) {
    next(err);
  }
}

export async function handlePayme(req: Request, res: Response) {
  const { method, params, id } = req.body as { method?: string; params?: unknown; id?: number | string };
  const rpcId = id ?? null;

  if (!isPaymeAuthorized(req)) {
    return res.status(401).json({
      jsonrpc: '2.0',
      error: { code: -32504, message: 'Insufficient privileges to perform this method' },
      id: rpcId,
    });
  }

  try {
    let result: unknown;
    switch (method) {
      case 'CheckPerformTransaction':
        result = await payme.checkPerformTransaction(params as Parameters<typeof payme.checkPerformTransaction>[0]);
        break;
      case 'CreateTransaction':
        result = await payme.createTransaction(params as Parameters<typeof payme.createTransaction>[0]);
        break;
      case 'PerformTransaction':
        result = await payme.performTransaction(params as Parameters<typeof payme.performTransaction>[0]);
        break;
      case 'CancelTransaction':
        result = await payme.cancelTransaction(params as Parameters<typeof payme.cancelTransaction>[0]);
        break;
      default:
        return res.status(200).json({
          jsonrpc: '2.0',
          error: { code: -32601, message: 'Method not found' },
          id: rpcId,
        });
    }
    res.status(200).json({ jsonrpc: '2.0', result, id: rpcId });
  } catch (err) {
    if (err instanceof payme.PaymeError) {
      return res.status(200).json({ jsonrpc: '2.0', error: { code: err.code, message: err.message }, id: rpcId });
    }
    console.error('Payme handler error:', err);
    res.status(200).json({ jsonrpc: '2.0', error: { code: -32603, message: 'Internal error' }, id: rpcId });
  }
}

export async function handleClick(req: Request, res: Response) {
  const body = req.body as click.ClickRequestBody;

  if (!click.verifySign(body)) {
    return res.status(200).json({
      click_trans_id: body.click_trans_id,
      merchant_trans_id: body.merchant_trans_id,
      error: -1,
      error_note: 'SIGN CHECK FAILED',
    });
  }

  const action = Number(body.action);
  const result = action === 1 ? await click.complete(body) : await click.prepare(body);
  res.status(200).json(result);
}

export async function getMyOrders(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;

    const { data, error } = await supabase
      .from('ad_orders')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) throw error;

    res.status(200).json({ data: data as AdOrder[] });
  } catch (err) {
    next(err);
  }
}
