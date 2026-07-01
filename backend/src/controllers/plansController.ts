import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Plan } from '../types';

export async function getPlans(_req: Request, res: Response, next: NextFunction) {
  try {
    const { data, error } = await supabase
      .from('plans')
      .select('*')
      .eq('is_active', true)
      .order('duration_days');
    if (error) throw error;
    res.status(200).json({ data: data as Plan[] });
  } catch (err) {
    next(err);
  }
}

export async function getAllPlans(_req: Request, res: Response, next: NextFunction) {
  try {
    const { data, error } = await supabase.from('plans').select('*').order('duration_days');
    if (error) throw error;
    res.status(200).json({ data: data as Plan[] });
  } catch (err) {
    next(err);
  }
}

export async function createPlan(req: Request, res: Response, next: NextFunction) {
  try {
    const { code, name_uz, price, currency, duration_days, max_active_ads, is_active } =
      req.body as Partial<Plan>;
    if (!code || !name_uz || price == null || !duration_days) {
      throw new AppError(400, 'code, name_uz, price, duration_days talab qilinadi');
    }

    const { data, error } = await supabase
      .from('plans')
      .insert({
        code,
        name_uz,
        price,
        currency: currency ?? 'UZS',
        duration_days,
        max_active_ads: max_active_ads ?? 10,
        is_active: is_active ?? true,
      })
      .select()
      .single();
    if (error) throw error;

    res.status(201).json({ plan: data as Plan });
  } catch (err) {
    next(err);
  }
}

export async function updatePlan(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { code, name_uz, price, currency, duration_days, max_active_ads, is_active } =
      req.body as Partial<Plan>;

    const { data: existing, error: fetchError } = await supabase
      .from('plans')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!existing) throw new AppError(404, 'Reja topilmadi');

    const plan = existing as Plan;

    const { data, error } = await supabase
      .from('plans')
      .update({
        code: code ?? plan.code,
        name_uz: name_uz ?? plan.name_uz,
        price: price ?? plan.price,
        currency: currency ?? plan.currency,
        duration_days: duration_days ?? plan.duration_days,
        max_active_ads: max_active_ads ?? plan.max_active_ads,
        is_active: is_active ?? plan.is_active,
      })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;

    res.status(200).json({ plan: data as Plan });
  } catch (err) {
    next(err);
  }
}

export async function deletePlan(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('plans')
      .delete()
      .eq('id', id)
      .select('id');
    if (error) throw error;
    if (!data || data.length === 0) throw new AppError(404, 'Reja topilmadi');

    res.status(200).json({ message: "Reja o'chirildi" });
  } catch (err) {
    next(err);
  }
}
