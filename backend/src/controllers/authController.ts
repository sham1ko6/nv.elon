import { randomInt } from 'crypto';
import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { query, execute } from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { sendOTP } from '../services/sms';
import { User, SafeUser, AuthTokenPayload, RefreshTokenPayload } from '../types';

const PHONE_REGEX = /^\+998\d{9}$/;
const BCRYPT_ROUNDS = 12;
const OTP_TTL_MS = 5 * 60 * 1000;

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || '';
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || '';
const ACCESS_EXPIRES = process.env.JWT_ACCESS_EXPIRES || '15m';
const REFRESH_EXPIRES = process.env.JWT_REFRESH_EXPIRES || '30d';

interface OtpEntry {
  code: string;
  expiresAt: number;
}

const otpStore = new Map<string, OtpEntry>();

function toSafeUser(user: User): SafeUser {
  const { password_hash, ...safe } = user;
  return safe;
}

function signAccessToken(user: Pick<User, 'id' | 'phone' | 'role'>): string {
  const payload: AuthTokenPayload = { id: user.id, phone: user.phone, role: user.role };
  return jwt.sign(payload, ACCESS_SECRET, { expiresIn: ACCESS_EXPIRES } as jwt.SignOptions);
}

function signRefreshToken(user: Pick<User, 'id'>): string {
  const payload: RefreshTokenPayload = { id: user.id };
  return jwt.sign(payload, REFRESH_SECRET, { expiresIn: REFRESH_EXPIRES } as jwt.SignOptions);
}

function issueTokens(user: Pick<User, 'id' | 'phone' | 'role'>) {
  return {
    accessToken: signAccessToken(user),
    refreshToken: signRefreshToken(user),
  };
}

async function findUserByPhone(phone: string): Promise<User | null> {
  const rows = await query<User>('SELECT * FROM users WHERE phone = ? LIMIT 1', [phone]);
  return rows[0] ?? null;
}

async function findUserById(id: number): Promise<User | null> {
  const rows = await query<User>('SELECT * FROM users WHERE id = ? LIMIT 1', [id]);
  return rows[0] ?? null;
}

export async function register(req: Request, res: Response, next: NextFunction) {
  try {
    const { name, phone, password } = req.body as { name?: string; phone?: string; password?: string };

    if (!name || !phone) {
      throw new AppError(400, "Ism va telefon raqami talab qilinadi");
    }
    if (!PHONE_REGEX.test(phone)) {
      throw new AppError(400, "Telefon raqami formati noto'g'ri (+998XXXXXXXXX)");
    }

    const existing = await findUserByPhone(phone);
    if (existing) {
      throw new AppError(409, 'Bu telefon raqami allaqachon ro\'yxatdan o\'tgan');
    }

    const passwordHash = password ? await bcrypt.hash(password, BCRYPT_ROUNDS) : null;

    const result = await execute(
      'INSERT INTO users (name, phone, password_hash, role) VALUES (?, ?, ?, ?)',
      [name, phone, passwordHash, 'buyer']
    );

    const user = await findUserById(result.insertId);
    if (!user) {
      throw new AppError(500, 'Foydalanuvchi yaratilmadi');
    }

    res.status(201).json({ user: toSafeUser(user), ...issueTokens(user) });
  } catch (err) {
    next(err);
  }
}

export async function login(req: Request, res: Response, next: NextFunction) {
  try {
    const { phone, password } = req.body as { phone?: string; password?: string };

    if (!phone || !password) {
      throw new AppError(400, 'Telefon raqami va parol talab qilinadi');
    }

    const user = await findUserByPhone(phone);
    if (!user || !user.password_hash) {
      throw new AppError(401, "Telefon raqami yoki parol xato");
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      throw new AppError(401, "Telefon raqami yoki parol xato");
    }

    if (user.status === 'banned') {
      throw new AppError(403, 'Foydalanuvchi bloklangan');
    }

    res.status(200).json({ user: toSafeUser(user), ...issueTokens(user) });
  } catch (err) {
    next(err);
  }
}

export async function requestOtp(req: Request, res: Response, next: NextFunction) {
  try {
    const { phone } = req.body as { phone?: string };
    if (!phone || !PHONE_REGEX.test(phone)) {
      throw new AppError(400, "Telefon raqami formati noto'g'ri (+998XXXXXXXXX)");
    }

    const code = String(randomInt(100000, 1000000));
    otpStore.set(phone, { code, expiresAt: Date.now() + OTP_TTL_MS });

    await sendOTP(phone, code);

    res.status(200).json({ message: 'SMS yuborildi' });
  } catch (err) {
    next(err);
  }
}

export async function verifyOtp(req: Request, res: Response, next: NextFunction) {
  try {
    const { phone, code } = req.body as { phone?: string; code?: string };
    if (!phone || !code) {
      throw new AppError(400, 'Telefon raqami va kod talab qilinadi');
    }

    const entry = otpStore.get(phone);
    if (!entry || entry.expiresAt < Date.now()) {
      otpStore.delete(phone);
      throw new AppError(400, "Kod yaroqsiz yoki muddati o'tgan");
    }
    if (entry.code !== code) {
      throw new AppError(400, "Noto'g'ri kod");
    }

    otpStore.delete(phone);

    let user = await findUserByPhone(phone);
    if (!user) {
      const result = await execute(
        'INSERT INTO users (name, phone, password_hash, role, is_verified) VALUES (?, ?, ?, ?, ?)',
        ['Foydalanuvchi', phone, null, 'buyer', true]
      );
      user = await findUserById(result.insertId);
    }
    if (!user) {
      throw new AppError(500, 'Foydalanuvchi yaratilmadi');
    }

    res.status(200).json({ user: toSafeUser(user), ...issueTokens(user) });
  } catch (err) {
    next(err);
  }
}

export async function refresh(req: Request, res: Response, next: NextFunction) {
  try {
    const { refreshToken } = req.body as { refreshToken?: string };
    if (!refreshToken) {
      throw new AppError(400, 'refreshToken talab qilinadi');
    }

    let payload: RefreshTokenPayload;
    try {
      payload = jwt.verify(refreshToken, REFRESH_SECRET) as RefreshTokenPayload;
    } catch {
      throw new AppError(401, "Refresh token yaroqsiz yoki muddati o'tgan");
    }

    const user = await findUserById(payload.id);
    if (!user || user.status === 'banned') {
      throw new AppError(401, 'Foydalanuvchi topilmadi yoki bloklangan');
    }

    res.status(200).json({ accessToken: signAccessToken(user) });
  } catch (err) {
    next(err);
  }
}

export async function me(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await findUserById(req.user!.id);
    if (!user) {
      throw new AppError(404, 'Foydalanuvchi topilmadi');
    }
    res.status(200).json({ user: toSafeUser(user) });
  } catch (err) {
    next(err);
  }
}
