// =============================================================
// server.js — the entry point: load config, then start listening
// =============================================================
// Run with:  npm run dev   (auto-restarts on file changes)
//        or: npm start
// =============================================================

// 1) Load variables from the .env file into process.env. Must be first.
require('dotenv').config();

const app = require('./app');
const { pingDatabase } = require('./config/db');

const PORT = process.env.PORT || 4000;

// 2) Start the HTTP server, then check the database connection.
async function start() {
  app.listen(PORT, () => {
    console.log(`✅ nv.elon API running at http://localhost:${PORT}`);
    console.log(`   Try:  http://localhost:${PORT}/health`);
  });

  // A failed DB check should NOT crash the server — it just warns you,
  // so you can still hit /health and see a clear message about the DB.
  try {
    await pingDatabase();
    console.log('✅ Database connection OK');
  } catch (err) {
    console.warn('⚠️  Could NOT connect to the database.');
    console.warn('   Check your .env DB_* settings and that MySQL is running.');
    console.warn('   Details:', err.message);
  }
}

start();
