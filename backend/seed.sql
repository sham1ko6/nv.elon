-- CATEGORIES --------------------------------------------------------
INSERT INTO categories (slug, name_uz, name_en, icon, sort_order) VALUES
  ('uy-joy',             'Uy-joy',            'Real Estate',            '🏠', 1),
  ('transport',          'Transport',         'Transport',              '🚗', 2),
  ('elektronika',        'Elektronika',       'Electronics',            '📱', 3),
  ('qishloq-texnika',    'Qishloq texnika',   'Agricultural Machinery', '🚜', 4),
  ('don-mahsulotlari',   'Don mahsulotlari',  'Grain Products',         '🌾', 5),
  ('chorvachilik',       'Chorvachilik',      'Livestock',              '🐄', 6),
  ('kiyim',              'Kiyim',             'Clothing',               '👕', 7),
  ('uy-jihozlari',       'Uy jihozlari',      'Home Furniture',         '🛋', 8);

-- PLANS ---------------------------------------------------------------
INSERT INTO plans (code, name_uz, price, currency, duration_days, max_active_ads, is_active) VALUES
  ('monthly', 'Oylik',  99000.00, 'UZS', 30,  10, TRUE),
  ('yearly',  'Yillik', 799000.00, 'UZS', 365, 30, TRUE);

-- ADMIN USER (phone: +998901234567, password: admin123) --------------
INSERT INTO users (name, phone, password_hash, role, is_verified, status) VALUES
  ('Admin', '+998901234567', '$2b$12$sfPAZo7mewbwVmc3k9AAs.ftu7j9IJuUVH7MSKAWaqjeGlt3s9J3m', 'admin', TRUE, 'active');

-- APP SETTINGS ----------------------------------------------------------
INSERT INTO app_settings (`key`, `value`) VALUES
  ('posting_fee_amount', '19000'),
  ('posting_fee_currency', 'UZS'),
  ('ad_duration_days', '30');
