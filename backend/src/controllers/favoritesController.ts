import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Listing } from '../types';

export async function getMyFavorites(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;

    const { data, error } = await supabase
      .from('favorites')
      .select('listings(*)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) throw error;

    const listings = ((data ?? []) as Array<{ listings: unknown }>)
      .map((row) => row.listings)
      .filter(Boolean) as Listing[];

    res.status(200).json({ data: listings });
  } catch (err) {
    next(err);
  }
}

export async function addFavorite(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const { data: listing, error: fetchError } = await supabase
      .from('listings')
      .select('id')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!listing) throw new AppError(404, "E'lon topilmadi");

    // upsert with ignoreDuplicates mirrors MySQL INSERT IGNORE
    const { error } = await supabase
      .from('favorites')
      .upsert(
        { user_id: userId, listing_id: Number(id) },
        { onConflict: 'user_id,listing_id', ignoreDuplicates: true }
      );
    if (error) throw error;

    res.status(200).json({ favorited: true });
  } catch (err) {
    next(err);
  }
}

export async function removeFavorite(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const { error } = await supabase
      .from('favorites')
      .delete()
      .eq('user_id', userId)
      .eq('listing_id', id);
    if (error) throw error;

    res.status(200).json({ favorited: false });
  } catch (err) {
    next(err);
  }
}
