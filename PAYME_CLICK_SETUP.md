# Connecting real Payme & Click (do this when you have merchant accounts)

Right now the app uses **test placeholder keys**, so payments work with fake data
only. When you get real Payme and Click merchant accounts, you switch to real
payments by editing **ONE file**:

    backend/.env

You do **not** touch any code. Just replace the values on the lines below, then
restart the backend (`Ctrl+C`, then `npm start`).

---

## Part 1 — Give the payment companies your webhook addresses

Your server must be online at a real address first (a domain + HTTPS — see
`FOR_SHAMSHOD.md`). Suppose your address is `https://api.nvelon.uz`. In each
provider's merchant cabinet, enter these URLs:

| Provider | What they ask for | What you enter |
|----------|-------------------|----------------|
| **Payme** | Endpoint / Cassa URL | `https://api.nvelon.uz/payments/payme` |
| **Payme** | Account parameter name | `order_id`  (must match `PAYME_ACCOUNT_FIELD` below) |
| **Click** | Prepare URL | `https://api.nvelon.uz/payments/click/prepare` |
| **Click** | Complete URL | `https://api.nvelon.uz/payments/click/complete` |

---

## Part 2 — Payme keys → paste into `backend/.env`

Payme gives you these in your **Payme Business / Merchant cabinet**.
Tip: Payme has a **test (sandbox) key** and a **live key** — use the test one first.

| `.env` line | Replace with | Where to find it |
|-------------|--------------|------------------|
| `PAYME_MERCHANT_ID=` | your Merchant ID | Payme cabinet → your cashbox (kassa) details |
| `PAYME_KEY=` | your secret key | Payme cabinet → cashbox → "Key" (has TEST and LIVE versions) |
| `PAYME_ACCOUNT_FIELD=` | leave as `order_id` | must match the "account parameter name" you set in Part 1 |
| `PAYME_CHECKOUT_URL=` | `https://checkout.paycom.uz` for live, or `https://test.paycom.uz` for sandbox | Payme docs |

Current lines in `backend/.env` (replace the values after the `=`):
```
PAYME_MERCHANT_ID=test_merchant
PAYME_KEY=test_payme_key_123
PAYME_ACCOUNT_FIELD=order_id
PAYME_CHECKOUT_URL=https://checkout.paycom.uz
```

---

## Part 3 — Click keys → paste into `backend/.env`

Click gives you these in your **Click Merchant cabinet** (the SHOP/Merchant API section).

| `.env` line | Replace with | Where to find it |
|-------------|--------------|------------------|
| `CLICK_SERVICE_ID=` | your Service ID | Click cabinet → your service settings |
| `CLICK_MERCHANT_ID=` | your Merchant ID | Click cabinet → merchant profile |
| `CLICK_SECRET_KEY=` | your Secret Key | Click cabinet → service → "Secret key" (used to verify signatures) |
| `CLICK_CHECKOUT_URL=` | `https://my.click.uz/services/pay` | Click docs (usually this default) |

Current lines in `backend/.env` (replace the values after the `=`):
```
CLICK_SERVICE_ID=12345
CLICK_MERCHANT_ID=67890
CLICK_SECRET_KEY=test_click_secret_456
CLICK_CHECKOUT_URL=https://my.click.uz/services/pay
```

---

## Part 4 — That's it

1. Save `backend/.env`.
2. Restart the backend (`Ctrl+C`, then `npm start`).
3. Do a small real test payment (e.g. set the posting fee low) and confirm the ad
   goes live after you pay.

### Important safety notes
- The `.env` file holds secrets — it is **git-ignored**, so it never gets uploaded.
  Never paste these keys into any other file or share them.
- Keep the dev fake-pay route OFF in production: run the server with
  `NODE_ENV=production` and the `/dev/*` routes disable themselves automatically.
- You can keep testing with fake data anytime using:
  `bash backend/scripts/simulate-payment.sh payme`  (or `click`).
