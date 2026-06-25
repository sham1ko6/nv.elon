import { Request, Response, NextFunction } from 'express';
import multer from 'multer';

export class AppError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export function notFoundHandler(req: Request, res: Response) {
  res.status(404).json({ error: `Topilmadi: ${req.method} ${req.path}` });
}

export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof AppError) {
    return res.status(err.status).json({ error: err.message });
  }
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ error: err.message });
  }

  const message = err instanceof Error ? err.message : 'Server xatosi';
  console.error('Unhandled error:', err);
  res.status(500).json({ error: message || 'Server xatosi' });
}
