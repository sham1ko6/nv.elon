-- =============================================================
-- nv.elon — MySQL / MariaDB schema
-- =============================================================
-- HOW TO RUN (from a terminal):
--   mysql -u root -p < backend/db/schema.sql
--   mysql -u root -p < backend/db/seed.sql        (sample data, optional)
--
-- This file creates the whole database. The Phase 1 API only USES the
-- users, categories, subcategories and listings tables, but we create
-- every table now so the schema is stable and future phases (payments,
-- subscriptions) just plug in.
-- =============================================================

-- Create the database if it does not exist, then switch into it.
CREATE DATABASE IF NOT EXISTS nv_elon
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nv_elon;

-- Drop tables first so re-running this file gives a clean slate.
-- Order matters: drop children before parents (foreign keys).
DROP TABLE IF EXISTS contact_events;
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS payment_transactions;
DROP TABLE IF EXISTS ad_orders;
DROP TABLE IF EXISTS listing_images;
DROP TABLE IF EXISTS listings;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS plans;
DROP TABLE IF EXISTS subcategories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS app_settings;
DROP TABLE IF EXISTS users;

-- USERS -------------------------------------------------------------
-- One row per account. Buyers can browse without an account; people
-- register mainly to post ads (sellers) or to save/contact listings.
CREATE TABLE users (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(120) NOT NULL,
  phone         VARCHAR(20)  NOT NULL UNIQUE,        -- e.g. +998901234567
  email         VARCHAR(160) UNIQUE,
  password_hash VARCHAR(255),                        -- bcrypt hash (never the raw password)
  role          ENUM('buyer','seller','admin') NOT NULL DEFAULT 'seller',
  is_verified   BOOLEAN NOT NULL DEFAULT FALSE,
  status        ENUM('active','banned') NOT NULL DEFAULT 'active',
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- CATEGORIES --------------------------------------------------------
CREATE TABLE categories (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  slug       VARCHAR(60) NOT NULL UNIQUE,            -- 'real-estate'
  name_uz    VARCHAR(120) NOT NULL,
  name_en    VARCHAR(120) NOT NULL,
  icon       VARCHAR(40),
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE subcategories (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  category_id BIGINT UNSIGNED NOT NULL,
  slug        VARCHAR(60) NOT NULL,
  name_uz     VARCHAR(120) NOT NULL,
  name_en     VARCHAR(120) NOT NULL,
  UNIQUE KEY uq_subcat (category_id, slug),
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- PLANS (subscription products) -------------------------------------
CREATE TABLE plans (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code            VARCHAR(40) NOT NULL UNIQUE,        -- 'monthly','yearly'
  name_uz         VARCHAR(120) NOT NULL,
  price           DECIMAL(12,2) NOT NULL,
  currency        CHAR(3) NOT NULL DEFAULT 'UZS',
  duration_days   INT NOT NULL,                       -- 30, 365
  max_active_ads  INT NOT NULL DEFAULT 10,            -- ad slots while active
  is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

-- SUBSCRIPTIONS -----------------------------------------------------
CREATE TABLE subscriptions (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id    BIGINT UNSIGNED NOT NULL,
  plan_id    BIGINT UNSIGNED NOT NULL,
  status     ENUM('pending','active','expired','cancelled') NOT NULL DEFAULT 'pending',
  started_at TIMESTAMP NULL,
  expires_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_sub_user (user_id),
  INDEX idx_sub_expiry (status, expires_at),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (plan_id) REFERENCES plans(id)
);

-- LISTINGS ----------------------------------------------------------
-- The ads themselves. The public feed only shows status='active'.
CREATE TABLE listings (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id         BIGINT UNSIGNED NOT NULL,
  category_id     BIGINT UNSIGNED NOT NULL,
  subcategory_id  BIGINT UNSIGNED NULL,
  title           VARCHAR(160) NOT NULL,
  description     TEXT NOT NULL,
  price           DECIMAL(14,2) NOT NULL,
  currency        CHAR(3) NOT NULL DEFAULT 'USD',
  location        VARCHAR(160) NOT NULL,
  contact_phone   VARCHAR(20) NOT NULL,
  status          ENUM('draft','pending_payment','active','expired','rejected','sold')
                    NOT NULL DEFAULT 'draft',
  source          ENUM('posting_fee','subscription') NULL,  -- how it got published
  subscription_id BIGINT UNSIGNED NULL,                     -- if source=subscription
  views           INT NOT NULL DEFAULT 0,
  published_at    TIMESTAMP NULL,
  expires_at      TIMESTAMP NULL,                           -- tied to sub or fixed term
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_listing_feed (status, expires_at, category_id),
  INDEX idx_listing_user (user_id),
  FULLTEXT KEY ft_listing (title, description),             -- fast text search
  FOREIGN KEY (user_id)         REFERENCES users(id),
  FOREIGN KEY (category_id)     REFERENCES categories(id),
  FOREIGN KEY (subcategory_id)  REFERENCES subcategories(id),
  FOREIGN KEY (subscription_id) REFERENCES subscriptions(id)
);

CREATE TABLE listing_images (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  listing_id BIGINT UNSIGNED NOT NULL,
  url        VARCHAR(400) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

-- ORDERS + PAYMENTS -------------------------------------------------
-- The ONLY two revenue types: 'posting_fee' and 'subscription'.
CREATE TABLE ad_orders (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NOT NULL,
  type        ENUM('posting_fee','subscription') NOT NULL,
  listing_id  BIGINT UNSIGNED NULL,           -- for posting_fee
  plan_id     BIGINT UNSIGNED NULL,           -- for subscription
  amount      DECIMAL(12,2) NOT NULL,
  currency    CHAR(3) NOT NULL DEFAULT 'UZS',
  status      ENUM('created','pending','paid','failed','cancelled') NOT NULL DEFAULT 'created',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  paid_at     TIMESTAMP NULL,
  FOREIGN KEY (user_id)    REFERENCES users(id),
  FOREIGN KEY (listing_id) REFERENCES listings(id),
  FOREIGN KEY (plan_id)    REFERENCES plans(id)
);

CREATE TABLE payment_transactions (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  ad_order_id     BIGINT UNSIGNED NOT NULL,
  provider        ENUM('payme','click') NOT NULL,
  provider_txn_id VARCHAR(120) NULL,          -- Payme/Click transaction id
  state           VARCHAR(40) NOT NULL,       -- provider-specific lifecycle state
  amount          DECIMAL(12,2) NOT NULL,
  -- Payme requires us to remember these timestamps (in milliseconds) and the
  -- cancel reason, so we can answer its CheckTransaction/CancelTransaction calls.
  create_time     BIGINT NOT NULL DEFAULT 0,
  perform_time    BIGINT NOT NULL DEFAULT 0,
  cancel_time     BIGINT NOT NULL DEFAULT 0,
  reason          INT NULL,
  raw_payload     JSON NULL,                  -- last callback body for audit
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_provider_txn (provider, provider_txn_id),
  FOREIGN KEY (ad_order_id) REFERENCES ad_orders(id)
);

-- ENGAGEMENT (free, analytics only — NEVER billed) ------------------
CREATE TABLE favorites (
  user_id    BIGINT UNSIGNED NOT NULL,
  listing_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, listing_id),
  FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

CREATE TABLE contact_events (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  listing_id BIGINT UNSIGNED NOT NULL,
  viewer_id  BIGINT UNSIGNED NULL,
  type       ENUM('view_phone','call','share') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

-- SETTINGS (posting fee amount, etc.) -------------------------------
CREATE TABLE app_settings (
  `key`   VARCHAR(60) PRIMARY KEY,            -- 'posting_fee_amount'
  `value` VARCHAR(255) NOT NULL
);
