import { Request, Response, NextFunction } from 'express';
import { query, execute } from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Plan } from '../types';

export async function getPlans(_req: Request, res: Response, next: NextFunction) {
  try {
    const data = await query<Plan>('SELECT * FROM plans WHERE is_active = TRUE ORDER BY duration_days ASC');
    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function getAllPlans(_req: Request, res: Response, next: NextFunction) {
  try {
    const data = await query<Plan>('SELECT * FROM plans ORDER BY duration_days ASC');
    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function createPlan(req: Request, res: Response, next: NextFunction) {
  try {
    const { code, name_uz, price, currency, duration_days, max_active_ads, is_active } = req.body as Partial<Plan>;
    if (!code || !name_uz || price == null || !duration_days) {
      throw new AppError(400, 'code, name_uz, price, duration_days talab qilinadi');
    }

    const result = await execute(
      `INSERT INTO plans (code, name_uz, price, currency, duration_days, max_active_ads, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [code, name_uz, price, currency ?? 'UZS', duration_days, max_active_ads ?? 10, is_active ?? true]
    );

    const [plan] = await query<Plan>('SELECT * FROM plans WHERE id = ?', [result.insertId]);
    res.status(201).json({ plan });
  } catch (err) {
    next(err);
  }
}

export async function updatePlan(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { code, name_uz, price, currency, duration_days, max_active_ads, is_active } = req.body as Partial<Plan>;

    const [existing] = await query<Plan>('SELECT * FROM plans WHERE id = ?', [id]);
    if (!existing) {
      throw new AppError(404, 'Reja topilmadi');
    }

    await execute(
      `UPDATE plans SET code = ?, name_uz = ?, price = ?, currency = ?, duration_days = ?,
        max_active_ads = ?, is_active = ? WHERE id = ?`,
      [
        code ?? existing.code,
        name_uz ?? existing.name_uz,
        price ?? existing.price,
        currency ?? existing.currency,
        duration_days ?? existing.duration_days,
        max_active_ads ?? existing.max_active_ads,
        is_active ?? existing.is_active,
        id,
      ]
    );

    const [updated] = await query<Plan>('SELECT * FROM plans WHERE id = ?', [id]);
    res.status(200).json({ plan: updated });
  } catch (err) {
    next(err);
  }
}

export async function deletePlan(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const result = await execute('DELETE FROM plans WHERE id = ?', [id]);
    if (result.affectedRows === 0) {
      throw new AppError(404, 'Reja topilmadi');
    }
    res.status(200).json({ message: "Reja o'chirildi" });
  } catch (err) {
    next(err);
  }
}
