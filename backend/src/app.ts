import path from 'path';
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import authRoutes from './routes/auth';
import categoriesRoutes from './routes/categories';
import listingsRoutes from './routes/listings';
import favoritesRoutes from './routes/favorites';
import plansRoutes from './routes/plans';
import subscriptionsRoutes from './routes/subscriptions';
import paymentsRoutes from './routes/payments';
import adminRoutes from './routes/admin';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { startExpiryJob } from './jobs/expiry';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const UPLOAD_DIR = process.env.UPLOAD_DIR || './uploads';
app.use('/uploads', express.static(path.resolve(UPLOAD_DIR)));

app.get('/health', (_req, res) => res.status(200).json({ status: 'ok' }));

app.use('/api/auth', authRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/plans', plansRoutes);
app.use('/api', listingsRoutes);
app.use('/api', favoritesRoutes);
app.use('/api', subscriptionsRoutes);
app.use('/api', paymentsRoutes);
app.use('/api/admin', adminRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

const PORT = Number(process.env.PORT) || 3001;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`nv.elon API running at http://localhost:${PORT}`);
  });
  startExpiryJob();
}

export default app;
