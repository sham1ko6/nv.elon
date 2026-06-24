// =============================================================
// app.js — builds the Express application (routes + middleware)
// =============================================================
// We keep "building the app" separate from "starting the server"
// (that part is in server.js). This separation makes testing easier.
// =============================================================
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const categoriesRoutes = require('./routes/categories.routes');
const listingsRoutes = require('./routes/listings.routes');
const { notFound, errorHandler } = require('./middleware/errorHandler');

const app = express();

// --- Global middleware (runs on every request) ---
app.use(cors());            // allow the Flutter app / React admin to call us
app.use(express.json());    // parse JSON bodies (most of our API + Payme)
app.use(express.urlencoded({ extended: false })); // parse form bodies (Click sends these)

// --- Health check: a simple way to confirm the server is up ---
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'nv.elon API', time: new Date().toISOString() });
});

// --- Feature routes ---
app.use('/auth', authRoutes);             // /auth/register, /auth/login, /auth/me
app.use('/categories', categoriesRoutes); // /categories
app.use('/listings', listingsRoutes);     // /listings, /listings/mine, /listings/:id
app.use('/payments', require('./routes/payments.routes')); // Payme + Click webhooks, /init

// --- Development-only helper routes ---
// These FAKE payments/subscriptions so you can test the flow now. They are
// only loaded when NOT in production, so they can never run on the real server.
if (process.env.NODE_ENV !== 'production') {
  const devRoutes = require('./routes/dev.routes');
  app.use('/dev', devRoutes);             // /dev/pay/:orderId, /dev/grant-subscription
  console.log('⚠️  Dev routes enabled (/dev/*). Do NOT use in production.');
}

// --- Fallbacks (must be LAST) ---
app.use(notFound);      // no route matched -> 404
app.use(errorHandler);  // any thrown error -> JSON error response

module.exports = app;
