import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Category, Subcategory, CategoryWithSubcategories } from '../types';

const CACHE_TTL_MS = 10 * 60 * 1000;
let cache: { data: CategoryWithSubcategories[]; expiresAt: number } | null = null;

export function invalidateCategoriesCache(): void {
  cache = null;
}

async function loadCategoriesWithSubcategories(): Promise<CategoryWithSubcategories[]> {
  const [catRes, subRes] = await Promise.all([
    supabase.from('categories').select('*').order('sort_order').order('id'),
    supabase.from('subcategories').select('*').order('id'),
  ]);

  if (catRes.error) throw catRes.error;
  if (subRes.error) throw subRes.error;

  const categories = (catRes.data ?? []) as Category[];
  const subcategories = (subRes.data ?? []) as Subcategory[];

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

    const { data, error } = await supabase
      .from('categories')
      .insert({ slug, name_uz, name_en, icon: icon ?? null, sort_order: sort_order ?? 0 })
      .select()
      .single();
    if (error) throw error;

    invalidateCategoriesCache();
    res.status(201).json({ category: data as Category });
  } catch (err) {
    next(err);
  }
}

export async function updateCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { slug, name_uz, name_en, icon, sort_order } = req.body as Partial<Category>;

    const { data: existing, error: fetchError } = await supabase
      .from('categories')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!existing) throw new AppError(404, 'Kategoriya topilmadi');

    const cat = existing as Category;

    const { data, error } = await supabase
      .from('categories')
      .update({
        slug: slug ?? cat.slug,
        name_uz: name_uz ?? cat.name_uz,
        name_en: name_en ?? cat.name_en,
        icon: icon ?? cat.icon,
        sort_order: sort_order ?? cat.sort_order,
      })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;

    invalidateCategoriesCache();
    res.status(200).json({ category: data as Category });
  } catch (err) {
    next(err);
  }
}

export async function deleteCategory(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('categories')
      .delete()
      .eq('id', id)
      .select('id');
    if (error) throw error;
    if (!data || data.length === 0) throw new AppError(404, 'Kategoriya topilmadi');

    invalidateCategoriesCache();
    res.status(200).json({ message: "Kategoriya o'chirildi" });
  } catch (err) {
    next(err);
  }
}
