// =============================================================
// auth.js — protect routes that require a logged-in user
// =============================================================
// When a user logs in we give them a JWT (a signed token string).
// The app then sends that token on protected requests using the header:
//     Authorization: Bearer <token>
// This middleware checks the token is valid and, if so, attaches the
// user info to req.user so the route can know who is calling.
// =============================================================
const jwt = require('jsonwebtoken');

function requireAuth(req, res, next) {
  // 1) Read the Authorization header.
  const header = req.headers.authorization || '';

  // 2) It must look like "Bearer xxxxx". Split off the token part.
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  // 3) Verify the token's signature using our secret. If it was tampered
  //    with or expired, jwt.verify throws and we return 401.
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    // payload is what we signed at login: { id, role, name, phone }
    req.user = payload;
    next(); // token is good — continue to the actual route
  } catch (e) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

// Optional helper for later (admin-only routes). Not used in Phase 1.
function requireRole(role) {
  return (req, res, next) => {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

module.exports = { requireAuth, requireRole };
