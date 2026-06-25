import { Request, Response, NextFunction } from 'express';
import { query, execute } from '../config/db';
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

    const [plan] = await query<Plan>('SELECT * FROM plans WHERE id = ? AND is_active = TRUE', [plan_id]);
    if (!plan) {
      throw new AppError(404, 'Reja topilmadi');
    }

    const subResult = await execute(
      "INSERT INTO subscriptions (user_id, plan_id, status) VALUES (?, ?, 'pending')",
      [userId, plan_id]
    );

    const orderResult = await execute(
      `INSERT INTO ad_orders (user_id, type, plan_id, amount, currency, status)
       VALUES (?, 'subscription', ?, ?, ?, 'created')`,
      [userId, plan_id, plan.price, plan.currency]
    );

    await execute(
      `INSERT INTO payment_transactions (ad_order_id, provider, state, amount) VALUES (?, ?, 'created', ?)`,
      [orderResult.insertId, provider, plan.price]
    );

    res.status(201).json({
      order_id: orderResult.insertId,
      subscription_id: subResult.insertId,
      checkout_url: `https://checkout.stub/${provider}/${orderResult.insertId}`,
    });
  } catch (err) {
    next(err);
  }
}

export async function getMySubscription(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;

    const [subscription] = await query<{
      id: number;
      status: string;
      started_at: Date | null;
      expires_at: Date | null;
      created_at: Date;
      plan_id: number;
      plan_code: string;
      plan_name: string;
      plan_price: number;
      plan_currency: string;
      duration_days: number;
      max_active_ads: number;
    }>(
      `SELECT s.id, s.status, s.started_at, s.expires_at, s.created_at,
              p.id AS plan_id, p.code AS plan_code, p.name_uz AS plan_name, p.price AS plan_price,
              p.currency AS plan_currency, p.duration_days, p.max_active_ads
       FROM subscriptions s
       JOIN plans p ON p.id = s.plan_id
       WHERE s.user_id = ? AND s.status = 'active'
       ORDER BY s.expires_at DESC
       LIMIT 1`,
      [userId]
    );

    res.status(200).json({ subscription: subscription ?? null });
  } catch (err) {
    next(err);
  }
}
