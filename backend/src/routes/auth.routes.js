// =============================================================
// auth.routes.js — /auth/register, /auth/login, /auth/me
// =============================================================
const express = require('express');
const bcrypt = require('bcryptjs');     // for hashing passwords safely
const jwt = require('jsonwebtoken');    // for making login tokens
const { pool } = require('../config/db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Small helper: build and sign a login token for a user row.
function makeToken(user) {
  // We only put non-secret, useful fields inside the token.
  return jwt.sign(
    { id: user.id, role: user.role, name: user.name, phone: user.phone },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

// ----------------------------------------------------------------
// POST /auth/register
// Body: { name, phone, email, password }
// Creates a new account, then logs them in (returns a token).
// ----------------------------------------------------------------
router.post('/register', async (req, res, next) => {
  try {
    const { name, phone, email, password } = req.body;

    // --- Basic validation (simple, readable checks) ---
    if (!name || !phone || !password) {
      return res.status(400).json({ error: 'name, phone and password are required' });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: 'password must be at least 6 characters' });
    }

    // --- Make sure phone (and email if given) are not already used ---
    const [existing] = await pool.query(
      'SELECT id FROM users WHERE phone = ? OR (email IS NOT NULL AND email = ?) LIMIT 1',
      [phone, email || null]
    );
    if (existing.length > 0) {
      return res.status(409).json({ error: 'A user with this phone or email already exists' });
    }

    // --- Hash the password. We NEVER store the raw password. ---
    // bcrypt adds a random "salt" and is slow on purpose (hard to brute-force).
    const passwordHash = await bcrypt.hash(password, 10);

    // --- Insert the new user. Default role is 'seller' so they can post. ---
    const [result] = await pool.query(
      `INSERT INTO users (name, phone, email, password_hash, role)
       VALUES (?, ?, ?, ?, 'seller')`,
      [name, phone, email || null, passwordHash]
    );

    const user = { id: result.insertId, name, phone, role: 'seller' };
    const token = makeToken(user);

    // 201 = "created"
    res.status(201).json({ token, user });
  } catch (err) {
    next(err); // hand any unexpected error to the error handler
  }
});

// ----------------------------------------------------------------
// POST /auth/login
// Body: { login, password }   (login = phone OR email)
// ----------------------------------------------------------------
router.post('/login', async (req, res, next) => {
  try {
    const { login, password } = req.body;
    if (!login || !password) {
      return res.status(400).json({ error: 'login (phone or email) and password are required' });
    }

    // Find the user by phone or email.
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE phone = ? OR email = ? LIMIT 1',
      [login, login]
    );
    const user = rows[0];

    // Use the SAME error message whether the user is missing or the
    // password is wrong, so attackers can't tell which one was correct.
    if (!user || !user.password_hash) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    if (user.status === 'banned') {
      return res.status(403).json({ error: 'This account is banned' });
    }

    // Compare the typed password against the stored hash.
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = makeToken(user);
    res.json({
      token,
      user: { id: user.id, name: user.name, phone: user.phone, role: user.role },
    });
  } catch (err) {
    next(err);
  }
});

// ----------------------------------------------------------------
// GET /auth/me  (protected)
// Returns the currently logged-in user. Requires a valid token.
// ----------------------------------------------------------------
router.get('/me', requireAuth, async (req, res, next) => {
  try {
    // req.user was set by the requireAuth middleware from the token.
    const [rows] = await pool.query(
      'SELECT id, name, phone, email, role, is_verified, created_at FROM users WHERE id = ? LIMIT 1',
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ user: rows[0] });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
