import { Router } from 'express';
import { authMiddleware } from '../middleware/auth';
import { initPayment, handlePayme, handleClick, getMyOrders } from '../controllers/paymentsController';

const router = Router();

router.post('/payments/init', authMiddleware, initPayment);
router.post('/payments/payme', handlePayme);
router.post('/payments/click', handleClick);
router.get('/me/orders', authMiddleware, getMyOrders);

export default router;
