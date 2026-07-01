import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Plan, PaymentProvider } from '../types';

export async function createSubscription(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const { plan_id, provider } = req.body as { plan_id?: number; provider?: PaymentProvider };

    if (!plan_id || !provider) {
      throw new AppError(400, 'plan_id va provider talab qilinadi');
    }
    if (provider !== 'payme' && provider !== 'click') {
      throw new AppError(400, "provider 'payme' yoki 'click' bo'lishi kerak");
    }

    const { data: planData, error: planError } = await supabase
      .from('plans')
      .select('*')
      .eq('id', plan_id)
      .eq('is_active', true)
      .maybeSingle();
    if (planError) throw planError;
    if (!planData) throw new AppError(404, 'Reja topilmadi');

    const plan = planData as Plan;

    const { data: subData, error: subError } = await supabase
      .from('subscriptions')
      .insert({ user_id: userId, plan_id, status: 'pending' })
      .select('id')
      .single();
    if (subError) throw subError;

    const { data: orderData, error: orderError } = await supabase
      .from('ad_orders')
      .insert({
        user_id: userId,
        type: 'subscription',
        plan_id,
        amount: plan.price,
        currency: plan.currency,
        status: 'created',
      })
      .select('id')
      .single();
    if (orderError) throw orderError;

    const { error: txnError } = await supabase.from('payment_transactions').insert({
      ad_order_id: (orderData as { id: number }).id,
      provider,
      state: 'created',
      amount: plan.price,
    });
    if (txnError) throw txnError;

    res.status(201).json({
      order_id: (orderData as { id: number }).id,
      subscription_id: (subData as { id: number }).id,
      checkout_url: `https://checkout.stub/${provider}/${(orderData as { id: number }).id}`,
    });
  } catch (err) {
    next(err);
  }
}

export async function getMySubscription(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;

    const { data, error } = await supabase
      .from('subscriptions')
      .select('*, plans!plan_id(id, code, name_uz, price, currency, duration_days, max_active_ads)')
      .eq('user_id', userId)
      .eq('status', 'active')
      .order('expires_at', { ascending: false })
      .limit(1)
      .maybeSingle();
    if (error) throw error;

    if (!data) {
      return res.status(200).json({ subscription: null });
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const row = data as any;
    const p = row.plans ?? {};
    const subscription = {
      id: row.id,
      status: row.status,
      started_at: row.started_at,
      expires_at: row.expires_at,
      created_at: row.created_at,
      plan_id: row.plan_id,
      plan_code: p.code,
      plan_name: p.name_uz,
      plan_price: p.price,
      plan_currency: p.currency,
      duration_days: p.duration_days,
      max_active_ads: p.max_active_ads,
    };

    res.status(200).json({ subscription });
  } catch (err) {
    next(err);
  }
}
