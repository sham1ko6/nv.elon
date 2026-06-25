import { Router } from 'express';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth';
import { upload } from '../middleware/upload';
import {
  listListings,
  getListing,
  createListing,
  updateListing,
  deleteListing,
  getMyListings,
  contactListing,
  uploadImages,
  deleteImage,
} from '../controllers/listingsController';

const router = Router();

router.get('/listings', listListings);
router.get('/me/listings', authMiddleware, getMyListings);
router.get('/listings/:id', getListing);
router.post('/listings', authMiddleware, createListing);
router.put('/listings/:id', authMiddleware, updateListing);
router.delete('/listings/:id', authMiddleware, deleteListing);
router.post('/listings/:id/contact', optionalAuthMiddleware, contactListing);
router.post('/listings/:id/images', authMiddleware, upload.array('images', 10), uploadImages);
router.delete('/listings/:id/images/:imageId', authMiddleware, deleteImage);

export default router;
