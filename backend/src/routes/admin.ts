import { Router } from 'express';
import { authMiddleware } from '../middleware/auth';
import { requireRole } from '../middleware/requireRole';
import {
  getAllListings,
  updateListingStatus,
  getAllUsers,
  updateUser,
  getAllOrders,
  getMetrics,
} from '../controllers/adminController';
import { getCategories, createCategory, updateCategory, deleteCategory } from '../controllers/categoriesController';
import { getAllPlans, createPlan, updatePlan, deletePlan } from '../controllers/plansController';

const router = Router();

router.use(authMiddleware, requireRole('admin'));

router.get('/listings', getAllListings);
router.put('/listings/:id', updateListingStatus);

router.get('/users', getAllUsers);
router.put('/users/:id', updateUser);

router.get('/orders', getAllOrders);
router.get('/metrics', getMetrics);

router.get('/categories', getCategories);
router.post('/categories', createCategory);
router.put('/categories/:id', updateCategory);
router.delete('/categories/:id', deleteCategory);

router.get('/plans', getAllPlans);
router.post('/plans', createPlan);
router.put('/plans/:id', updatePlan);
router.delete('/plans/:id', deletePlan);

export default router;
