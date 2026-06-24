# nv.elon — Backend API (Phase 1)

Node.js + Express + MySQL/MariaDB. Phase 1 covers **auth**, **categories**, and
**read-only listings**. Posting ads, payments and subscriptions come in later phases.

## What's inside

```
backend/
├── db/
│   ├── schema.sql      # creates the database + all tables
│   └── seed.sql        # sample categories, plans, a demo user, sample ads
├── src/
│   ├── config/db.js            # MySQL connection pool
│   ├── middleware/
│   │   ├── auth.js             # checks the login token on protected routes
│   │   └── errorHandler.js     # turns errors / 404s into clean JSON
│   ├── routes/
│   │   ├── auth.routes.js       # POST /auth/register, /auth/login, GET /auth/me
│   │   ├── categories.routes.js # GET /categories
│   │   └── listings.routes.js   # GET /listings, GET /listings/:id
│   ├── app.js          # wires routes + middleware together
│   └── server.js       # starts the server (run this)
├── .env.example        # copy to .env and fill in your values
└── package.json
```

## Setup (step by step)

### 1. Install dependencies
```bash
cd backend
npm install
```

### 2. Create the database
Run the schema, then the sample data, with your MySQL user:
```bash
mysql -u root -p < db/schema.sql
mysql -u root -p < db/seed.sql
```
This creates a database called `nv_elon` with all tables and some demo content.

### 3. Configure your environment
```bash
cp .env.example .env
```
Open `.env` and set `DB_PASSWORD` to your MySQL password, and change `JWT_SECRET`
to any long random string.

### 4. Run the server
```bash
npm run dev      # development mode, auto-restarts when you edit files
# or
npm start
```
You should see:
```
✅ nv.elon API running at http://localhost:4000
✅ Database connection OK
```

## Try it

```bash
# Health check
curl http://localhost:4000/health

# Categories (with nested subcategories)
curl http://localhost:4000/categories

# Listings feed (filters: ?q= &category= &subcategory= &location= &min= &max= &sort= &page=)
curl "http://localhost:4000/listings?category=electronics"

# One listing
curl http://localhost:4000/listings/1

# Log in as the demo seller (from seed.sql)
curl -X POST http://localhost:4000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"+998901112233","password":"password123"}'

# Use the token from login to see your own profile
curl http://localhost:4000/auth/me -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Endpoints (Phase 1)

| Method | Path              | Auth | Description                                  |
|--------|-------------------|------|----------------------------------------------|
| GET    | `/health`         | no   | Server status                                |
| POST   | `/auth/register`  | no   | Create account → returns token               |
| POST   | `/auth/login`     | no   | Log in (phone or email) → returns token      |
| GET    | `/auth/me`        | yes  | Current logged-in user                       |
| GET    | `/categories`     | no   | All categories + subcategories               |
| GET    | `/listings`       | no   | Active ads, with filters + pagination        |
| GET    | `/listings/mine`  | yes  | My own ads (any status)                      |
| GET    | `/listings/:id`   | no   | One active ad's full detail                  |
| POST   | `/listings`       | yes  | Create an ad (posting-fee or subscription)   |
| POST   | `/payments/init`  | yes  | Get a Payme/Click "pay now" link for an order |
| POST   | `/payments/payme` | webhook | Payme calls this (JSON-RPC + Basic auth)  |
| POST   | `/payments/click/prepare`  | webhook | Click step 1 (signature checked)  |
| POST   | `/payments/click/complete` | webhook | Click step 2 → publishes the ad   |

### Dev-only routes (auto-disabled when `NODE_ENV=production`)

These FAKE payments/subscriptions so you can test the flow before Payme/Click exist.

| Method | Path                     | Auth | Description                              |
|--------|--------------------------|------|------------------------------------------|
| POST   | `/dev/pay/:orderId`      | yes  | Pretend an order was paid → publishes ad  |
| POST   | `/dev/grant-subscription`| yes  | Pretend you bought a plan (`{planCode}`)  |

### Posting an ad (Phase 2)

`POST /listings` body:
```json
{
  "title": "iPhone 15 Pro",
  "description": "Like new, 256GB",
  "price": 900,
  "currency": "USD",
  "location": "Tashkent",
  "category": "electronics",
  "subcategory": "smartphones",
  "publishMethod": "posting_fee"
}
```
- `publishMethod: "posting_fee"` → ad is saved as **pending_payment** and an order is
  returned. It only goes live after the order is paid. (Test now with `POST /dev/pay/:orderId`.)
- `publishMethod: "subscription"` → if you have an active subscription with a free slot,
  the ad goes **active immediately** and expires when the subscription does.

## Troubleshooting

**`Could NOT connect to the database` / `ECONNREFUSED 127.0.0.1:3306`**
Your MySQL/MariaDB isn't reachable over TCP. Either:
- Start it and make sure it listens on TCP port 3306 (in MariaDB, ensure
  `skip-networking` is **off** and `bind-address = 127.0.0.1`), **or**
- If it only uses a Unix socket, add a `socketPath` to `src/config/db.js`
  (e.g. `socketPath: '/run/mysqld/mysqld.sock'`) instead of host/port.

**`Access denied for user`** — wrong `DB_USER`/`DB_PASSWORD` in `.env`.

## Notes
- This whole phase was tested end-to-end against a real MariaDB: schema + seed
  load cleanly, and every endpoint above returns correct data (including the
  security cases: wrong password, duplicate phone, missing/invalid token).
- New accounts default to the `seller` role so they can post ads in Phase 2.
- The listings feed only ever returns `status='active'` ads that haven't
  expired — this is where the "expired ads disappear" rule will live.
