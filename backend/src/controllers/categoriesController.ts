import { Request, Response, NextFunction } from 'express';
import { query, execute } from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Category, Subcategory, CategoryWithSubcategories } from '../types';

const CACHE_TTL_MS = 10 * 60 * 1000;
let cache: { data: CategoryWithSubcategories[]; expiresAt: number } | null = null;

export function invalidateCategoriesCache(): void {
  cache = null;
}

async function loadCategoriesWithSubcategories(): Promise<CategoryWithSubcategories[]> {
  const categories = await query<Category>('SELECT * FROM categories ORDER BY sort_order ASC, id ASC');
  const subcategories = await query<Subcategory>('SELECT * FROM subcategories ORDER BY id ASC');

  return categories.map((category) => ({
    ...category,
    subcategories: subcategories.filter((sub) => sub.category_id === category.id),
  }));
}

export async function getCategories(_req: Request, res: Response, next: NextFunction) {
  try {
    if (cache && cache.expiresAt > Date.now()) {
      return res.status(200).json({ data: cache.data });
    }

    const data = await loadCategoriesWithSubcategories();
    cache = { data, expiresAt: Date.now() + CACHE_TTL_MS };

    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function createCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { slug, name_uz, name_en, icon, sort_order } = req.body as Partial<Category>;
    if (!slug || !name_uz || !name_en) {
      throw new AppError(400, 'slug, name_uz, name_en talab qilinadi');
    }

    const result = await execute(
      'INSERT INTO categories (slug, name_uz, name_en, icon, sort_order) VALUES (?, ?, ?, ?, ?)',
      [slug, name_uz, name_en, icon ?? null, sort_order ?? 0]
    );

    invalidateCategoriesCache();
    const [category] = await query<Category>('SELECT * FROM categories WHERE id = ?', [result.insertId]);
    res.status(201).json({ category });
  } catch (err) {
    next(err);
  }
}

export async function updateCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { slug, name_uz, name_en, icon, sort_order } = req.body as Partial<Category>;

    const [existing] = await query<Category>('SELECT * FROM categories WHERE id = ?', [id]);
    if (!existing) {
      throw new AppError(404, 'Kategoriya topilmadi');
    }

    await execute(
      'UPDATE categories SET slug = ?, name_uz = ?, name_en = ?, icon = ?, sort_order = ? WHERE id = ?',
      [
        slug ?? existing.slug,
        name_uz ?? existing.name_uz,
        name_en ?? existing.name_en,
        icon ?? existing.icon,
        sort_order ?? existing.sort_order,
        id,
      ]
    );

    invalidateCategoriesCache();
    const [updated] = await query<Category>('SELECT * FROM categories WHERE id = ?', [id]);
    res.status(200).json({ category: updated });
  } catch (err) {
    next(err);
  }
}

export async function deleteCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const result = await execute('DELETE FROM categories WHERE id = ?', [id]);
    if (result.affectedRows === 0) {
      throw new AppError(404, 'Kategoriya topilmadi');
    }

    invalidateCategoriesCache();
    res.status(200).json({ message: "Kategoriya o'chirildi" });
  } catch (err) {
    next(err);
  }
}
