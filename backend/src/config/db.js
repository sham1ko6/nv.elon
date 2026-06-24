// =============================================================
// db.js — the database connection
// =============================================================
// We use "mysql2" with a connection POOL. A pool keeps a small set of
// reusable connections open, so each request doesn't pay the cost of
// opening a brand-new connection. We use the "/promise" version so we
// can write modern async/await code (await pool.query(...)).
// =============================================================
const mysql = require('mysql2/promise');

// Read settings from environment variables (loaded from .env in server.js).
const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'nv_elon',
  waitForConnections: true, // queue requests instead of failing when busy
  connectionLimit: 10,      // max simultaneous connections
  namedPlaceholders: false, // we use plain "?" placeholders
});

// A tiny helper so other files can check the DB is reachable on startup.
async function pingDatabase() {
  const conn = await pool.getConnection();
  try {
    await conn.query('SELECT 1');
  } finally {
    conn.release(); // always give the connection back to the pool
  }
}

module.exports = { pool, pingDatabase };
