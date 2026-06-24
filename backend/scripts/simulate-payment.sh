#!/usr/bin/env bash
# =============================================================
# simulate-payment.sh — pretend to be Payme or Click, with fake data
# =============================================================
# Lets you watch a REAL payment webhook flow without real merchant accounts.
# It signs the requests exactly like Payme/Click would, using the TEST keys
# in your .env file.
#
# Requirements: the backend must be running (npm start) and the database up.
#
# Usage:
#   bash scripts/simulate-payment.sh payme
#   bash scripts/simulate-payment.sh click
# =============================================================
set -u
PROVIDER="${1:-payme}"
B="http://localhost:4000"

# Load the TEST keys from .env (same ones the server uses).
cd "$(dirname "$0")/.." || exit 1
set -a; . ./.env; set +a

echo "1) Logging in as the demo seller..."
TOKEN=$(curl -s -X POST $B/auth/login -H 'Content-Type: application/json' \
  -d '{"login":"+998901112233","password":"password123"}' | sed -E 's/.*"token":"([^"]+)".*/\1/')
if [ -z "$TOKEN" ]; then echo "   Could not log in. Is the server running? Did you load seed.sql?"; exit 1; fi

echo "2) Creating an ad (which makes a posting-fee order)..."
TITLE="Test ad $RANDOM"
RESP=$(curl -s -X POST $B/listings -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "{\"title\":\"$TITLE\",\"description\":\"simulated payment test\",\"price\":500,\"location\":\"Tashkent\",\"category\":\"electronics\",\"subcategory\":\"smartphones\",\"publishMethod\":\"posting_fee\"}")
OID=$(echo "$RESP" | sed -E 's/.*"order":\{"id":([0-9]+).*/\1/')
AMT=$(echo "$RESP" | sed -E 's/.*"amount":([0-9.]+).*/\1/')
echo "   order id = $OID, fee = $AMT (ad is now hidden, status pending_payment)"

if [ "$PROVIDER" = "payme" ]; then
  echo "3) Simulating PAYME..."
  # Payme works in tiyin (so'm x 100). awk does the math (no 'bc' needed).
  TIYIN=$(awk "BEGIN{printf \"%.0f\", $AMT*100}")
  # The same transaction id is used for Create, then Perform.
  PTID="sim_${RANDOM}${RANDOM}"
  PAUTH="Authorization: Basic $(printf 'Paycom:%s' "$PAYME_KEY" | base64)"

  echo "   CheckPerformTransaction:"
  curl -s -X POST $B/payments/payme -H "$PAUTH" -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"CheckPerformTransaction\",\"params\":{\"amount\":$TIYIN,\"account\":{\"order_id\":\"$OID\"}}}"; echo
  echo "   CreateTransaction:"
  curl -s -X POST $B/payments/payme -H "$PAUTH" -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"CreateTransaction\",\"params\":{\"id\":\"$PTID\",\"time\":1750000000000,\"amount\":$TIYIN,\"account\":{\"order_id\":\"$OID\"}}}"; echo
  echo "   PerformTransaction (this is the moment money is taken):"
  curl -s -X POST $B/payments/payme -H "$PAUTH" -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"PerformTransaction\",\"params\":{\"id\":\"$PTID\"}}"; echo
fi

if [ "$PROVIDER" = "click" ]; then
  echo "3) Simulating CLICK..."
  CTID="sim_$RANDOM"; STIME="2026-06-23 10:00:00"
  PSIGN=$(printf '%s' "${CTID}${CLICK_SERVICE_ID}${CLICK_SECRET_KEY}${OID}${AMT}0${STIME}" | md5sum | cut -d' ' -f1)
  echo "   Prepare:"
  PREP=$(curl -s -X POST $B/payments/click/prepare \
    -d "click_trans_id=$CTID" -d "service_id=$CLICK_SERVICE_ID" -d "merchant_trans_id=$OID" \
    -d "amount=$AMT" -d "action=0" -d "sign_time=$STIME" -d "sign_string=$PSIGN")
  echo "   $PREP"
  MPID=$(echo "$PREP" | sed -E 's/.*"merchant_prepare_id":([0-9]+).*/\1/')
  CSIGN=$(printf '%s' "${CTID}${CLICK_SERVICE_ID}${CLICK_SECRET_KEY}${OID}${MPID}${AMT}1${STIME}" | md5sum | cut -d' ' -f1)
  echo "   Complete:"
  curl -s -X POST $B/payments/click/complete \
    -d "click_trans_id=$CTID" -d "service_id=$CLICK_SERVICE_ID" -d "merchant_trans_id=$OID" \
    -d "merchant_prepare_id=$MPID" -d "amount=$AMT" -d "action=1" -d "error=0" \
    -d "sign_time=$STIME" -d "sign_string=$CSIGN"; echo
fi

echo "4) Is the ad now LIVE in the public feed?"
if curl -s "$B/listings?q=$(echo "$TITLE" | sed 's/ /%20/g')" | grep -q "$TITLE"; then
  echo "   ✅ YES — the simulated payment published the ad."
else
  echo "   ❌ No — check the server logs."
fi
