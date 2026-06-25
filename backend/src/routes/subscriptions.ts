import { Router } from 'express';
import { authMiddleware } from '../middleware/auth';
import { createSubscription, getMySubscription } from '../controllers/subscriptionsController';

const router = Router();

router.post('/subscriptions', authMiddleware, createSubscription);
router.get('/me/subscription', authMiddleware, getMySubscription);

export default router;
