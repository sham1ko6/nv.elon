import { Request, Response, NextFunction } from 'express';
import { query, execute } from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Listing } from '../types';

export async function getMyFavorites(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const data = await query<Listing>(
      `SELECT l.* FROM favorites f
       JOIN listings l ON l.id = f.listing_id
       WHERE f.user_id = ?
       ORDER BY f.created_at DESC`,
      [userId]
    );
    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function addFavorite(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const [listing] = await query<Listing>('SELECT id FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }

    await execute('INSERT IGNORE INTO favorites (user_id, listing_id) VALUES (?, ?)', [userId, id]);
    res.status(200).json({ favorited: true });
  } catch (err) {
    next(err);
  }
}

export async function removeFavorite(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    await execute('DELETE FROM favorites WHERE user_id = ? AND listing_id = ?', [userId, id]);
    res.status(200).json({ favorited: false });
  } catch (err) {
    next(err);
  }
}
