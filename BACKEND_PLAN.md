# nv.elon — Backend Plan (v1)

> Status: **design only — no app code changed.** Greenfield: the repo currently has
> zero backend/database/API code. This document defines the data model, schema, API,
> auth, subscription/expiry, and payment (Payme/Click) structure to build next.

Decisions locked with the owner:
- **Platform:** Flutter = consumer app, React (`/src`) = admin web. One shared API.
- **Payments:** generic structure now; concrete providers = **Payme + Click**.
- **DB:** owner knows **MySQL**, does not use Supabase. See recommendation below.

---

## 1. MySQL vs Supabase — recommendation

**Recommendation: MySQL + a small custom API server (Node.js/Express, or PHP/Laravel).**

Why MySQL wins *for your case specifically*:

| Factor | MySQL + custom API | Supabase (cloud Postgres) |
|---|---|---|
| Your familiarity | ✅ You already know it | ❌ Postgres dialect + new concepts (RLS) |
| Payme/Click webhooks | ✅ Full control in your own server endpoint | ⚠️ Must write Deno/TS Edge Functions; awkward for JSON-RPC/signature flows |
| Auth + API boilerplate | ❌ You write it (JWT, hashing) | ✅ Built-in auth + auto REST |
| Hosting | Any VPS (common/cheap in UZ) | Vendor cloud, free tier then paid |
| Lock-in | Low (portable SQL) | Medium (RLS, auth, storage tied to platform) |

The deciding factor: **a real marketplace with Payme + Click needs a custom server no matter what**, because both providers call *your* endpoint with their own protocol (Payme = JSON-RPC + Basic auth; Click = Prepare/Complete callbacks + MD5 signature). Once you're writing that server anyway, Supabase's main advantage (no server) mostly disappears — and you'd be fighting an unfamiliar Postgres + RLS model on top of it.

**Supabase would only be the better pick if** you wanted to avoid writing any server code and were fine learning Postgres — which is the opposite of your situation.

**Suggested concrete stack:**
- **DB:** MySQL 8.x
- **API:** Node.js + Express (or NestJS for more structure). If you prefer PHP, **Laravel** is an excellent MySQL-first alternative and very popular in Uzbekistan.
- **Auth:** JWT access tokens + refresh tokens; phone OTP (SMS) is ideal for UZ, email/password as fallback.
- **File storage:** local disk or S3-compatible (e.g. for listing images).
- **Scheduler:** a cron job (node-cron / system cron / Laravel scheduler) for subscription + ad expiry.

---

## 2. Architecture

```
 Flutter app (sellers + buyers) ─┐
                                 ├──HTTPS REST──>  API server (Node/Express)  ──>  MySQL 8
 React admin web (/src)        ──┘                       │
                                                         ├── /storage (listing images)
 Payme / Click  ──webhook──────────────────────────────>┘ (payment callbacks)
                                                         └── cron: expire subs + ads
```

Key principle: **all business rules live in the API, never the client.** Payment
success is decided only by the provider webhook, never by the app.

---

## 3. Data model (ER overview)

```
users ──< listings >── categories ──< subcategories
  │           │
  │           ├──< listing_images
  │           └──> subscriptions (if posted via subscription)
  │
  ├──< subscriptions >── plans
  ├──< ad_orders >── payment_transactions
  ├──< favorites >── listings
  └──< contact_events >── listings
app_settings (posting fee, etc.)
```

Revenue comes from exactly two places, matching the vision:
1. `ad_orders.type = 'posting_fee'`  → pay-per-ad.
2. `ad_orders.type = 'subscription'` → monthly/yearly plan.
Nothing else is ever charged.

---

## 4. MySQL schema (DDL draft)

```sql
-- USERS -------------------------------------------------------------
CREATE TABLE users (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(120) NOT NULL,
  phone         VARCHAR(20)  NOT NULL UNIQUE,        -- +998...
  email         VARCHAR(160) UNIQUE,
  password_hash VARCHAR(255),                        -- bcrypt/argon2 (null if OTP-only)
  role          ENUM('buyer','seller','admin') NOT NULL DEFAULT 'buyer',
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
  FULLTEXT KEY ft_listing (title, description),
  FOREIGN KEY (user_id)        REFERENCES users(id),
  FOREIGN KEY (category_id)    REFERENCES categories(id),
  FOREIGN KEY (subcategory_id) REFERENCES subcategories(id),
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
  raw_payload     JSON NULL,                  -- last callback body for audit
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_provider_txn (provider, provider_txn_id),
  FOREIGN KEY (ad_order_id) REFERENCES ad_orders(id)
);

-- ENGAGEMENT (free, analytics only) --------------------------------
CREATE TABLE favorites (
  user_id    BIGINT UNSIGNED NOT NULL,
  listing_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, listing_id),
  FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

CREATE TABLE contact_events (   -- "showed phone"/"called" tracking; NEVER billed
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  listing_id BIGINT UNSIGNED NOT NULL,
  viewer_id  BIGINT UNSIGNED NULL,
  type       ENUM('view_phone','call','share') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

-- SETTINGS (posting fee etc.) --------------------------------------
CREATE TABLE app_settings (
  `key`   VARCHAR(60) PRIMARY KEY,            -- 'posting_fee_amount'
  `value` VARCHAR(255) NOT NULL
);
```

---

## 5. Ad lifecycle (state machine)

```
draft ──submit──> pending_payment ──pay (fee OR subscription slot)──> active
                                                                        │
                                  sub expires / term ends / cron ──────┤──> expired
                                  admin rejects ───────────────────────┘──> rejected
                                  seller marks sold ───────────────────────> sold
```

Rules:
- A listing only becomes `active` after `ad_orders.status='paid'` (posting fee) **or**
  it consumes a free slot under an `active` subscription (`source='subscription'`,
  `subscription_id` set, `expires_at` = subscription `expires_at`).
- The public feed returns **only** `status='active' AND expires_at > NOW()`.
- **When a subscription expires, all its ads expire too** (see §7).

---

## 6. REST API (endpoints)

### Auth
- `POST /auth/register` — name, phone, email, password → user + tokens
- `POST /auth/login` — phone/email + password → tokens
- `POST /auth/otp/request` / `POST /auth/otp/verify` — phone OTP (recommended for UZ)
- `POST /auth/refresh` — refresh access token
- `GET  /auth/me` — current user

### Categories
- `GET /categories` — list with subcategories (cacheable)

### Listings
- `GET    /listings` — feed: filters `?q=&category=&subcategory=&location=&min=&max=&sort=&page=` (active only)
- `GET    /listings/:id` — detail (+ increments views)
- `POST   /listings` — create as `draft`/`pending_payment` (auth, seller)
- `PUT    /listings/:id` — edit own listing
- `DELETE /listings/:id` — remove own listing
- `GET    /me/listings` — seller's own (any status)
- `POST   /listings/:id/contact` — log `view_phone`/`call`, returns phone (free)

### Favorites
- `GET /me/favorites` · `POST /listings/:id/favorite` · `DELETE /listings/:id/favorite`

### Plans & Subscriptions
- `GET  /plans` — available monthly/yearly plans
- `GET  /me/subscription` — current status + expiry
- `POST /subscriptions` — start subscribe (creates `ad_order type=subscription`, returns payment init)

### Payments
- `POST /payments/init` — body: `{ order_id, provider }` → returns checkout URL / params
- `POST /payments/payme`  — **Payme webhook** (JSON-RPC; Basic auth)
- `POST /payments/click`  — **Click webhook** (Prepare + Complete; signature check)
- `GET  /me/orders` — order/payment history

### Admin (React admin app — role=admin)
- `GET/PUT  /admin/listings` — approve / reject / expire / extend
- `GET/PUT  /admin/users` — ban / change role / verify
- `CRUD     /admin/plans`, `/admin/categories`
- `GET      /admin/orders`, `/admin/metrics` — revenue, active ads, etc.

---

## 7. Subscription system + auto-expiry

**Posting fee path:** ad gets a fixed term (e.g. 30 days) on payment → `expires_at = paid_at + term`.

**Subscription path:** while `subscriptions.status='active'`, the seller can keep up to
`plans.max_active_ads` listings active; each such ad's `expires_at` mirrors the
subscription's `expires_at`.

**Cron job (runs hourly/daily):**
```sql
-- 1) expire ended subscriptions
UPDATE subscriptions SET status='expired'
 WHERE status='active' AND expires_at <= NOW();

-- 2) expire ads whose subscription just expired
UPDATE listings l
  JOIN subscriptions s ON s.id = l.subscription_id
   SET l.status='expired'
 WHERE l.status='active' AND s.status='expired';

-- 3) expire fixed-term (posting-fee) ads past their date
UPDATE listings SET status='expired'
 WHERE status='active' AND source='posting_fee' AND expires_at <= NOW();
```
This is the concrete implementation of the vision rule *"subscription expires → its ads expire and stop showing."*

---

## 8. Payment flow (provider-agnostic + Payme/Click)

**Generic flow (never trust the client):**
```
1. App calls POST /payments/init {order_id, provider}
2. Server creates payment_transactions row (state=created) and returns
   provider checkout URL / params
3. User pays inside Payme/Click
4. Provider calls our webhook  →  server verifies, marks ad_order 'paid',
   activates listing or subscription, sets expires_at
5. App polls GET /me/orders (or order status) to confirm
```

**Payme (Merchant API) specifics — `POST /payments/payme`:**
- Protocol: **JSON-RPC 2.0** over HTTPS, **Basic auth** with the Payme merchant key.
- Implement these methods: `CheckPerformTransaction`, `CreateTransaction`,
  `PerformTransaction`, `CancelTransaction`, `CheckTransaction`, `GetStatement`.
- Map Payme transaction states to `payment_transactions.state`; on `PerformTransaction`
  success → mark order paid + activate.

**Click (Merchant/SHOP API) specifics — `POST /payments/click`:**
- Two sequential callbacks: **Prepare** then **Complete**.
- Each request includes a **MD5 `sign_string`** = hash of ordered params + your secret key;
  **verify it** before acting. Return Click's expected `error`/`error_note` codes.
- On a valid Complete → mark order paid + activate.

**Important for both:** validate amount + signature/auth, make webhooks **idempotent**
(same `provider_txn_id` processed once), and store `raw_payload` for audit/disputes.

Concrete merchant credentials/URLs come later — for now the endpoints, tables, and
state machine above are the structure to build against.

---

## 9. Security checklist
- Hash passwords with bcrypt/argon2; never store plaintext.
- JWT access (short-lived) + refresh tokens; role checks on every admin route.
- Validate & sanitize all input server-side (price>0, phone format, lengths).
- Rate-limit auth + contact endpoints; spam/abuse guards on posting.
- Webhooks: verify signature/auth, enforce idempotency, check amounts.
- Don't expose seller phone until `POST /listings/:id/contact` (logged); consider masking.
- Parameterized queries only (no string-built SQL) → no SQL injection.
- HTTPS everywhere; secrets in env vars, not in the repo.

---

## 10. Build phases
1. **DB + API skeleton:** MySQL schema, Express app, `/auth`, `/categories`, `/listings` (read).
2. **Auth + seller posting:** register/login/OTP, create listing as `pending_payment`.
3. **Payments:** `ad_orders`, `/payments/init`, Payme + Click webhooks, activation.
4. **Subscriptions + expiry cron:** plans, subscribe flow, auto-expire job.
5. **Wire Flutter app** to the API (replace mock data / fake auth).
6. **React admin** (repurpose `/src`): listings/users/plans/orders/metrics.
7. **Polish:** image upload, search tuning, notifications, tests, CI.
