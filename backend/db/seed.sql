-- =============================================================
-- nv.elon — sample/seed data
-- =============================================================
-- Run AFTER schema.sql:
--   mysql -u root -p < backend/db/seed.sql
--
-- Gives you categories, subscription plans, settings, one demo
-- seller account, and a few ACTIVE listings so the feed isn't empty.
--
-- Demo login -> phone: +998901112233   password: password123
-- =============================================================
USE nv_elon;

-- Start clean so this file can be re-run safely.
DELETE FROM contact_events;
DELETE FROM favorites;
DELETE FROM payment_transactions;
DELETE FROM ad_orders;
DELETE FROM listing_images;
DELETE FROM listings;
DELETE FROM subscriptions;
DELETE FROM subcategories;
DELETE FROM categories;
DELETE FROM plans;
DELETE FROM app_settings;
DELETE FROM users;

-- --- Categories -------------------------------------------------
INSERT INTO categories (slug, name_uz, name_en, icon, sort_order) VALUES
  ('real-estate',        'Uy-joy sotuvi',         'Real Estate',                'home',    1),
  ('electronics',        'Elektronika va Texnika','Electronics & Tech',         'laptop',  2),
  ('commercial-farming', 'Firma Xo''jaligi',      'Commercial Farming',         'tractor', 3),
  ('local-farming',      'Dehqon Xo''jaligi',     'Local Farming & Livestock',  'sprout',  4);

-- --- Subcategories (linked to their category by slug) -----------
INSERT INTO subcategories (category_id, slug, name_uz, name_en) VALUES
  ((SELECT id FROM categories WHERE slug='real-estate'),        'apartments',      'Kvartiralar',              'Apartments'),
  ((SELECT id FROM categories WHERE slug='real-estate'),        'houses',          'Hovli va Dacha',           'Houses & Villas'),
  ((SELECT id FROM categories WHERE slug='real-estate'),        'land',            'Er uchastkalari',          'Land Plots'),
  ((SELECT id FROM categories WHERE slug='electronics'),        'smartphones',     'Telefonlar',               'Smartphones'),
  ((SELECT id FROM categories WHERE slug='electronics'),        'laptops',         'Noutbuklar',               'Laptops & Computers'),
  ((SELECT id FROM categories WHERE slug='electronics'),        'accessories',     'Aksessuarlar',             'Accessories'),
  ((SELECT id FROM categories WHERE slug='commercial-farming'), 'machinery',       'Og''ir Texnika',           'Heavy Machinery'),
  ((SELECT id FROM categories WHERE slug='commercial-farming'), 'irrigation',      'Sug''orish Tizimlari',     'Irrigation Systems'),
  ((SELECT id FROM categories WHERE slug='commercial-farming'), 'wholesale-goods', 'Ulgurji Mahsulotlar',      'Wholesale Goods'),
  ((SELECT id FROM categories WHERE slug='local-farming'),      'grains',          'Don mahsulotlari',         'Grains & Crops'),
  ((SELECT id FROM categories WHERE slug='local-farming'),      'livestock',       'Mol, qo''y, quyon',        'Livestock'),
  ((SELECT id FROM categories WHERE slug='local-farming'),      'poultry',         'Tovuq, tuxum, parrandalar','Poultry & Produce');

-- --- Subscription plans (monthly / yearly) ----------------------
INSERT INTO plans (code, name_uz, price, currency, duration_days, max_active_ads) VALUES
  ('monthly', 'Oylik obuna', 50000.00,  'UZS', 30,  20),
  ('yearly',  'Yillik obuna', 500000.00, 'UZS', 365, 100);

-- --- App settings (the single posting fee, etc.) ----------------
INSERT INTO app_settings (`key`, `value`) VALUES
  ('posting_fee_amount',   '15000'),  -- price to post one ad
  ('posting_fee_currency', 'UZS'),
  ('ad_term_days',         '30');     -- how long a paid single ad stays active

-- --- Demo seller account ----------------------------------------
-- password_hash below is bcrypt of "password123".
INSERT INTO users (name, phone, email, password_hash, role, is_verified) VALUES
  ('Bobur Dehqon', '+998901112233', 'demo@nv.elon',
   '$2a$10$wvaxzUaE309qm0NCbzYV3utOmJAgGt65alSYc5jEwLbRPGJyQIHSm',
   'seller', TRUE);

-- --- A few ACTIVE listings so /listings returns data ------------
-- Each is published now and expires in 30 days (so it shows in the feed).
INSERT INTO listings
  (user_id, category_id, subcategory_id, title, description, price, currency,
   location, contact_phone, status, source, views, published_at, expires_at)
VALUES
  ((SELECT id FROM users WHERE phone='+998901112233'),
   (SELECT id FROM categories WHERE slug='real-estate'),
   (SELECT id FROM subcategories WHERE slug='apartments'),
   'Modern 3-room Apartment in Tashkent City',
   'Fully furnished apartment in Tashkent City. 88 sqm, 4th floor, secure parking.',
   125000, 'USD', 'Tashkent City, Tashkent', '+998901112233',
   'active', 'posting_fee', 142, NOW(), NOW() + INTERVAL 30 DAY),

  ((SELECT id FROM users WHERE phone='+998901112233'),
   (SELECT id FROM categories WHERE slug='commercial-farming'),
   (SELECT id FROM subcategories WHERE slug='machinery'),
   'John Deere 6140M Tractor (2022)',
   'Excellent condition, 1,200 hours, 140 HP. Serviced by official dealer.',
   78000, 'USD', 'Jizzakh Region', '+998901112233',
   'active', 'posting_fee', 520, NOW(), NOW() + INTERVAL 30 DAY),

  ((SELECT id FROM users WHERE phone='+998901112233'),
   (SELECT id FROM categories WHERE slug='electronics'),
   (SELECT id FROM subcategories WHERE slug='laptops'),
   'MacBook Pro 16" M3 Max (36GB / 1TB)',
   'Perfect condition, 28 battery cycles, full box with 140W charger.',
   2650, 'USD', 'Mirzo Ulugbek, Tashkent', '+998901112233',
   'active', 'posting_fee', 405, NOW(), NOW() + INTERVAL 30 DAY),

  ((SELECT id FROM users WHERE phone='+998901112233'),
   (SELECT id FROM categories WHERE slug='local-farming'),
   (SELECT id FROM subcategories WHERE slug='livestock'),
   'Pedigree Holstein Dairy Cow',
   'Healthy Holstein cow, 2nd lactation, 28-32 L/day, vet certified.',
   1800, 'USD', 'Samarkand District, Samarkand', '+998901112233',
   'active', 'posting_fee', 245, NOW(), NOW() + INTERVAL 30 DAY);
