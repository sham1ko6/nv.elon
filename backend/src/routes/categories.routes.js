// =============================================================
// categories.routes.js — GET /categories
// =============================================================
// Returns every category with its subcategories nested inside, e.g.
//   [{ id, slug, name_uz, ..., subcategories: [ {...}, {...} ] }]
// This is public (no login needed) because buyers browse for free.
// =============================================================
const express = require('express');
const { pool } = require('../config/db');

const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    // 1) Get all categories, ordered for a stable menu.
    const [categories] = await pool.query(
      'SELECT id, slug, name_uz, name_en, icon, sort_order FROM categories ORDER BY sort_order, id'
    );

    // 2) Get all subcategories in one query (cheaper than one query per category).
    const [subcategories] = await pool.query(
      'SELECT id, category_id, slug, name_uz, name_en FROM subcategories ORDER BY id'
    );

    // 3) Attach each subcategory to its parent category.
    const byCategory = {}; // category_id -> array of subcategories
    for (const sub of subcategories) {
      (byCategory[sub.category_id] ||= []).push(sub);
    }
    const result = categories.map((cat) => ({
      ...cat,
      subcategories: byCategory[cat.id] || [],
    }));

    res.json({ categories: result });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
