// =============================================================
// listings.routes.js
//   GET  /listings        — public feed (active ads only)
//   GET  /listings/mine   — my own ads, any status (login required)
//   GET  /listings/:id    — one active ad's detail
//   POST /listings        — create an ad (login required)  << Phase 2
// =============================================================
// IMPORTANT RULE (the whole business depends on it):
// A new ad does NOT go live for free. To become "active" it must either
//   (a) be paid for with a one-time POSTING FEE, or
//   (b) use a slot from the seller's active SUBSCRIPTION.
// Those are the only two ways the platform makes money.
// =============================================================
const express = require('express');
const { pool } = require('../config/db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

const PAGE_SIZE = 20;

// --- small helper: read a value from the app_settings table -------
// e.g. the posting fee amount, or how many days a paid ad stays active.
async function getSetting(conn, key, fallback) {
  const [rows] = await conn.query('SELECT `value` FROM app_settings WHERE `key` = ?', [key]);
  return rows.length ? rows[0].value : fallback;
}

// --- small helper: turn a category slug (+ optional subcategory slug)
// into their database ids, and validate that they actually exist and
// that the subcategory really belongs to the category. -------------
async function resolveCategory(conn, categorySlug, subSlug) {
  const [cats] = await conn.query('SELECT id FROM categories WHERE slug = ? LIMIT 1', [categorySlug]);
  if (cats.length === 0) {
    const err = new Error('Unknown category');
    err.status = 400;
    throw err;
  }
  const categoryId = cats[0].id;

  let subcategoryId = null;
  if (subSlug) {
    const [subs] = await conn.query(
      'SELECT id FROM subcategories WHERE slug = ? AND category_id = ? LIMIT 1',
      [subSlug, categoryId]
    );
    if (subs.length === 0) {
      const err = new Error('Subcategory does not belong to that category');
      err.status = 400;
      throw err;
    }
    subcategoryId = subs[0].id;
  }
  return { categoryId, subcategoryId };
}

// ================================================================
// GET /listings  — public feed (only active, non-expired ads)
// ================================================================
router.get('/', async (req, res, next) => {
  try {
    const { q, category, subcategory, location, min, max, sort } = req.query;

    const where = [
      "l.status = 'active'",
      '(l.expires_at IS NULL OR l.expires_at > NOW())',
    ];
    const params = [];

    if (q) { where.push('(l.title LIKE ? OR l.description LIKE ?)'); params.push(`%${q}%`, `%${q}%`); }
    if (category) { where.push('c.slug = ?'); params.push(category); }
    if (subcategory) { where.push('sc.slug = ?'); params.push(subcategory); }
    if (location) { where.push('l.location LIKE ?'); params.push(`%${location}%`); }
    if (min) { where.push('l.price >= ?'); params.push(Number(min)); }
    if (max) { where.push('l.price <= ?'); params.push(Number(max)); }

    let orderBy = 'l.published_at DESC, l.id DESC';
    if (sort === 'price_asc') orderBy = 'l.price ASC';
    if (sort === 'price_desc') orderBy = 'l.price DESC';

    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const offset = (page - 1) * PAGE_SIZE;
    const whereSql = where.join(' AND ');

    const [countRows] = await pool.query(
      `SELECT COUNT(*) AS total
         FROM listings l
         JOIN categories c ON c.id = l.category_id
         LEFT JOIN subcategories sc ON sc.id = l.subcategory_id
        WHERE ${whereSql}`,
      params
    );
    const total = countRows[0].total;

    const [rows] = await pool.query(
      `SELECT l.id, l.title, l.description, l.price, l.currency, l.location, l.contact_phone,
              l.views, l.published_at, l.created_at,
              c.slug AS category, sc.slug AS subcategory,
              u.name AS seller_name, u.role AS seller_role
         FROM listings l
         JOIN categories c ON c.id = l.category_id
         LEFT JOIN subcategories sc ON sc.id = l.subcategory_id
         JOIN users u ON u.id = l.user_id
        WHERE ${whereSql}
        ORDER BY ${orderBy}
        LIMIT ${PAGE_SIZE} OFFSET ${offset}`,
      params
    );

    res.json({
      listings: rows,
      pagination: { page, pageSize: PAGE_SIZE, total, totalPages: Math.ceil(total / PAGE_SIZE) },
    });
  } catch (err) {
    next(err);
  }
});

// ================================================================
// GET /listings/mine  — the logged-in seller's OWN ads (any status)
// ----------------------------------------------------------------
// NOTE: this MUST be declared BEFORE "/:id". Express checks routes
// top to bottom, and "/:id" would otherwise treat the word "mine"
// as an id and try to look up a listing with id = "mine".
// ================================================================
router.get('/mine', requireAuth, async (req, res, next) => {
  try {
    const [rows] = await pool.query(
      `SELECT l.id, l.title, l.price, l.currency, l.status, l.source,
              l.views, l.published_at, l.expires_at, l.created_at,
              c.slug AS category, sc.slug AS subcategory
         FROM listings l
         JOIN categories c ON c.id = l.category_id
         LEFT JOIN subcategories sc ON sc.id = l.subcategory_id
        WHERE l.user_id = ?
        ORDER BY l.created_at DESC`,
      [req.user.id]
    );
    res.json({ listings: rows });
  } catch (err) {
    next(err);
  }
});

// ================================================================
// GET /listings/:id  — one active ad's full detail (+ bump views)
// ================================================================
router.get('/:id', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (!id) return res.status(400).json({ error: 'Invalid listing id' });

    await pool.query('UPDATE listings SET views = views + 1 WHERE id = ?', [id]);

    const [rows] = await pool.query(
      `SELECT l.*, c.slug AS category, sc.slug AS subcategory,
              u.name AS seller_name, u.role AS seller_role
         FROM listings l
         JOIN categories c ON c.id = l.category_id
         LEFT JOIN subcategories sc ON sc.id = l.subcategory_id
         JOIN users u ON u.id = l.user_id
        WHERE l.id = ? AND l.status = 'active'
        LIMIT 1`,
      [id]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Listing not found' });

    const [images] = await pool.query(
      'SELECT id, url, sort_order FROM listing_images WHERE listing_id = ? ORDER BY sort_order',
      [id]
    );
    res.json({ listing: { ...rows[0], images } });
  } catch (err) {
    next(err);
  }
});

// ================================================================
// POST /listings  — create an ad (login required)        << Phase 2
// ----------------------------------------------------------------
// Body:
//   title, description, price, location           (required)
//   category            category slug             (required)
//   subcategory         subcategory slug          (optional)
//   currency            default 'USD'             (optional)
//   contactPhone        default = your phone      (optional)
//   publishMethod       'posting_fee' | 'subscription'  (required)
//
// Two outcomes:
//   • 'subscription' + you have an active plan with a free slot
//        -> ad is published immediately (status 'active').
//   • 'posting_fee'
//        -> ad is saved as 'pending_payment' and an order is created;
//           it goes live only after that order is paid (Phase 3).
// ================================================================
router.post('/', requireAuth, async (req, res, next) => {
  // We use a transaction: several writes that must ALL succeed together
  // (e.g. create the ad AND its order). If anything fails we roll back so
  // we never leave half-finished data behind.
  const conn = await pool.getConnection();
  try {
    const {
      title, description, price, location,
      category, subcategory, currency, contactPhone, publishMethod,
    } = req.body;

    // ---------- 1) Validate the input ----------
    if (!title || !description || price == null || !location || !category) {
      return res.status(400).json({ error: 'title, description, price, location and category are required' });
    }
    const priceNum = Number(price);
    if (Number.isNaN(priceNum) || priceNum <= 0) {
      return res.status(400).json({ error: 'price must be a number greater than 0' });
    }
    if (publishMethod !== 'posting_fee' && publishMethod !== 'subscription') {
      return res.status(400).json({ error: "publishMethod must be 'posting_fee' or 'subscription'" });
    }

    await conn.beginTransaction();

    // ---------- 2) Resolve & validate category/subcategory ----------
    const { categoryId, subcategoryId } = await resolveCategory(conn, category, subcategory);

    // The phone buyers will call: use the one provided, else the user's own.
    const phone = (contactPhone && contactPhone.trim()) || req.user.phone;
    const cur = (currency || 'USD').toUpperCase().slice(0, 3);

    // ====================================================
    // PATH A: publish using an active SUBSCRIPTION
    // ====================================================
    if (publishMethod === 'subscription') {
      // Find the user's currently active subscription (not expired).
      const [subs] = await conn.query(
        `SELECT s.id, s.expires_at, p.max_active_ads
           FROM subscriptions s
           JOIN plans p ON p.id = s.plan_id
          WHERE s.user_id = ? AND s.status = 'active' AND s.expires_at > NOW()
          ORDER BY s.expires_at DESC
          LIMIT 1`,
        [req.user.id]
      );
      if (subs.length === 0) {
        await conn.rollback();
        return res.status(402).json({ error: 'No active subscription. Subscribe first or use posting_fee.' });
      }
      const sub = subs[0];

      // Count how many active ads this subscription is already using.
      const [used] = await conn.query(
        "SELECT COUNT(*) AS n FROM listings WHERE subscription_id = ? AND status = 'active'",
        [sub.id]
      );
      if (used[0].n >= sub.max_active_ads) {
        await conn.rollback();
        return res.status(409).json({ error: `Subscription ad limit reached (${sub.max_active_ads}). Remove an ad or upgrade.` });
      }

      // Publish immediately. The ad expires when the subscription expires
      // — this is the "subscription ends -> its ads end" rule.
      const [ins] = await conn.query(
        `INSERT INTO listings
           (user_id, category_id, subcategory_id, title, description, price, currency,
            location, contact_phone, status, source, subscription_id, published_at, expires_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 'subscription', ?, NOW(), ?)`,
        [req.user.id, categoryId, subcategoryId, title.trim(), description.trim(),
         priceNum, cur, location.trim(), phone, sub.id, sub.expires_at]
      );

      await conn.commit();
      return res.status(201).json({
        message: 'Ad published using your subscription.',
        listing: { id: ins.insertId, status: 'active', expires_at: sub.expires_at },
      });
    }

    // ====================================================
    // PATH B: publish by paying a one-time POSTING FEE
    // ====================================================
    // The ad is saved but NOT visible yet. We also create an "order" for
    // the fee. Real payment (Payme/Click) confirms the order in Phase 3;
    // only then does the ad become active.
    const feeAmount = Number(await getSetting(conn, 'posting_fee_amount', '15000'));
    const feeCurrency = await getSetting(conn, 'posting_fee_currency', 'UZS');

    const [ins] = await conn.query(
      `INSERT INTO listings
         (user_id, category_id, subcategory_id, title, description, price, currency,
          location, contact_phone, status, source)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_payment', 'posting_fee')`,
      [req.user.id, categoryId, subcategoryId, title.trim(), description.trim(),
       priceNum, cur, location.trim(), phone]
    );
    const listingId = ins.insertId;

    const [order] = await conn.query(
      `INSERT INTO ad_orders (user_id, type, listing_id, amount, currency, status)
       VALUES (?, 'posting_fee', ?, ?, ?, 'created')`,
      [req.user.id, listingId, feeAmount, feeCurrency]
    );

    await conn.commit();
    return res.status(201).json({
      message: 'Ad created. Complete the payment to publish it.',
      listing: { id: listingId, status: 'pending_payment' },
      order: { id: order.insertId, type: 'posting_fee', amount: feeAmount, currency: feeCurrency, status: 'created' },
      next: 'Pay this order to publish. (Phase 3 adds Payme/Click. For now, dev route: POST /dev/pay/:orderId)',
    });
  } catch (err) {
    // Undo any partial writes, then let the error handler respond.
    try { await conn.rollback(); } catch (_) {}
    next(err);
  } finally {
    conn.release(); // always return the connection to the pool
  }
});

module.exports = router;
