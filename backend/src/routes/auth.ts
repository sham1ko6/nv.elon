import { Router } from 'express';
import { authMiddleware } from '../middleware/auth';
import { register, login, requestOtp, verifyOtp, refresh, me } from '../controllers/authController';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/otp/request', requestOtp);
router.post('/otp/verify', verifyOtp);
router.post('/refresh', refresh);
router.get('/me', authMiddleware, me);

export default router;
