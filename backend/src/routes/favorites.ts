import { Router } from 'express';
import { authMiddleware } from '../middleware/auth';
import { getMyFavorites, addFavorite, removeFavorite } from '../controllers/favoritesController';

const router = Router();

router.get('/me/favorites', authMiddleware, getMyFavorites);
router.post('/listings/:id/favorite', authMiddleware, addFavorite);
router.delete('/listings/:id/favorite', authMiddleware, removeFavorite);

export default router;
