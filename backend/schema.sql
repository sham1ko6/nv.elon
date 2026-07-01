-- PostgreSQL schema for nv.elon (Supabase)
-- Run this in Supabase SQL Editor before seeding

-- ---------------------------------------------------------------------------
-- EXTENSIONS
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------------------------------------
-- ENUM TYPES
-- ---------------------------------------------------------------------------
CREATE TYPE user_role           AS ENUM ('buyer','seller','admin');
CREATE TYPE user_status         AS ENUM ('active','banned');
CREATE TYPE subscription_status AS ENUM ('pending','active','expired','cancelled');
CREATE TYPE listing_status      AS ENUM ('draft','pending_payment','active','expired','rejected','sold');
CREATE TYPE listing_source      AS ENUM ('posting_fee','subscription');
CREATE TYPE ad_order_type       AS ENUM ('posting_fee','subscription');
CREATE TYPE ad_order_status     AS ENUM ('created','pending','paid','failed','cancelled');
CREATE TYPE payment_provider    AS ENUM ('payme','click');
CREATE TYPE contact_event_type  AS ENUM ('view_phone','call','share');

-- ---------------------------------------------------------------------------
-- TRIGGER: auto-update updated_at
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- USERS
-- ---------------------------------------------------------------------------
CREATE TABLE users (
  id            BIGSERIAL PRIMARY KEY,
  name          VARCHAR(120) NOT NULL,
  phone         VARCHAR(20)  NOT NULL UNIQUE,
  email         VARCHAR(160) UNIQUE,
  password_hash VARCHAR(255),
  role          user_role    NOT NULL DEFAULT 'buyer',
  is_verified   BOOLEAN      NOT NULL DEFAULT FALSE,
  status        user_status  NOT NULL DEFAULT 'active',
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------------------------------------------------------------------------
-- CATEGORIES
-- ---------------------------------------------------------------------------
CREATE TABLE categories (
  id         BIGSERIAL PRIMARY KEY,
  slug       VARCHAR(60)  NOT NULL UNIQUE,
  name_uz    VARCHAR(120) NOT NULL,
  name_en    VARCHAR(120) NOT NULL,
  icon       VARCHAR(40),
  sort_order INT          NOT NULL DEFAULT 0
);

CREATE TABLE subcategories (
  id          BIGSERIAL PRIMARY KEY,
  category_id BIGINT       NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  slug        VARCHAR(60)  NOT NULL,
  name_uz     VARCHAR(120) NOT NULL,
  name_en     VARCHAR(120) NOT NULL,
  UNIQUE (category_id, slug)
);

-- ---------------------------------------------------------------------------
-- PLANS
-- ---------------------------------------------------------------------------
CREATE TABLE plans (
  id             BIGSERIAL PRIMARY KEY,
  code           VARCHAR(40)   NOT NULL UNIQUE,
  name_uz        VARCHAR(120)  NOT NULL,
  price          DECIMAL(12,2) NOT NULL,
  currency       CHAR(3)       NOT NULL DEFAULT 'UZS',
  duration_days  INT           NOT NULL,
  max_active_ads INT           NOT NULL DEFAULT 10,
  is_active      BOOLEAN       NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------------
-- SUBSCRIPTIONS
-- ---------------------------------------------------------------------------
CREATE TABLE subscriptions (
  id         BIGSERIAL           PRIMARY KEY,
  user_id    BIGINT              NOT NULL REFERENCES users(id),
  plan_id    BIGINT              NOT NULL REFERENCES plans(id),
  status     subscription_status NOT NULL DEFAULT 'pending',
  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sub_user   ON subscriptions(user_id);
CREATE INDEX idx_sub_expiry ON subscriptions(status, expires_at);

-- ---------------------------------------------------------------------------
-- LISTINGS
-- ---------------------------------------------------------------------------
CREATE TABLE listings (
  id              BIGSERIAL      PRIMARY KEY,
  user_id         BIGINT         NOT NULL REFERENCES users(id),
  category_id     BIGINT         NOT NULL REFERENCES categories(id),
  subcategory_id  BIGINT         REFERENCES subcategories(id),
  title           VARCHAR(160)   NOT NULL,
  description     TEXT           NOT NULL,
  price           DECIMAL(14,2)  NOT NULL,
  currency        CHAR(3)        NOT NULL DEFAULT 'USD',
  location        VARCHAR(160)   NOT NULL,
  contact_phone   VARCHAR(20)    NOT NULL,
  status          listing_status NOT NULL DEFAULT 'draft',
  source          listing_source,
  subscription_id BIGINT         REFERENCES subscriptions(id),
  views           INT            NOT NULL DEFAULT 0,
  published_at    TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_listings_updated_at
  BEFORE UPDATE ON listings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE INDEX idx_listing_feed ON listings(status, expires_at, category_id);
CREATE INDEX idx_listing_user ON listings(user_id);

CREATE TABLE listing_images (
  id         BIGSERIAL    PRIMARY KEY,
  listing_id BIGINT       NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  url        VARCHAR(400) NOT NULL,
  sort_order INT          NOT NULL DEFAULT 0
);

-- ---------------------------------------------------------------------------
-- AD ORDERS + PAYMENT TRANSACTIONS
-- ---------------------------------------------------------------------------
CREATE TABLE ad_orders (
  id         BIGSERIAL       PRIMARY KEY,
  user_id    BIGINT          NOT NULL REFERENCES users(id),
  type       ad_order_type   NOT NULL,
  listing_id BIGINT          REFERENCES listings(id),
  plan_id    BIGINT          REFERENCES plans(id),
  amount     DECIMAL(12,2)   NOT NULL,
  currency   CHAR(3)         NOT NULL DEFAULT 'UZS',
  status     ad_order_status NOT NULL DEFAULT 'created',
  created_at TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  paid_at    TIMESTAMPTZ
);

CREATE TABLE payment_transactions (
  id              BIGSERIAL        PRIMARY KEY,
  ad_order_id     BIGINT           NOT NULL REFERENCES ad_orders(id),
  provider        payment_provider NOT NULL,
  provider_txn_id VARCHAR(120),
  state           VARCHAR(40)      NOT NULL,
  amount          DECIMAL(12,2)    NOT NULL,
  raw_payload     JSONB,
  created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
  UNIQUE NULLS NOT DISTINCT (provider, provider_txn_id)
);

CREATE TRIGGER trg_payment_transactions_updated_at
  BEFORE UPDATE ON payment_transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------------------------------------------------------------------------
-- ENGAGEMENT
-- ---------------------------------------------------------------------------
CREATE TABLE favorites (
  user_id    BIGINT      NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
  listing_id BIGINT      NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, listing_id)
);

CREATE TABLE contact_events (
  id         BIGSERIAL          PRIMARY KEY,
  listing_id BIGINT             NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  viewer_id  BIGINT             REFERENCES users(id),
  type       contact_event_type NOT NULL,
  created_at TIMESTAMPTZ        NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- APP SETTINGS
-- ---------------------------------------------------------------------------
CREATE TABLE app_settings (
  key   VARCHAR(60)  PRIMARY KEY,
  value VARCHAR(255) NOT NULL
);

-- ---------------------------------------------------------------------------
-- HELPER: atomic view increment (avoids race conditions)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION increment_listing_views(p_id BIGINT)
RETURNS void LANGUAGE sql AS $$
  UPDATE listings SET views = views + 1 WHERE id = p_id;
$$;

-- ---------------------------------------------------------------------------
-- DISABLE RLS (auth is handled in the Express backend)
-- ---------------------------------------------------------------------------
ALTER TABLE users                DISABLE ROW LEVEL SECURITY;
ALTER TABLE categories           DISABLE ROW LEVEL SECURITY;
ALTER TABLE subcategories        DISABLE ROW LEVEL SECURITY;
ALTER TABLE plans                DISABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions        DISABLE ROW LEVEL SECURITY;
ALTER TABLE listings             DISABLE ROW LEVEL SECURITY;
ALTER TABLE listing_images       DISABLE ROW LEVEL SECURITY;
ALTER TABLE ad_orders            DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE favorites            DISABLE ROW LEVEL SECURITY;
ALTER TABLE contact_events       DISABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings         DISABLE ROW LEVEL SECURITY;
