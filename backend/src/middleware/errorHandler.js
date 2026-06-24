// =============================================================
// errorHandler.js — one place to turn errors into JSON responses
// =============================================================
// Two pieces of "middleware" (functions Express runs for each request):
//   1) notFound      — runs when no route matched the URL  -> 404
//   2) errorHandler  — runs when any route throws an error -> 500 (or custom)
// =============================================================

// Called when no route matched the requested URL.
function notFound(req, res, next) {
  res.status(404).json({ error: 'Not found', path: req.originalUrl });
}

// Express recognizes this as an error handler because it has 4 arguments.
// Any "throw" or "next(err)" inside a route ends up here.
function errorHandler(err, req, res, next) {
  // If a route set a specific status code (e.g. 400), use it; else 500.
  const status = err.status || 500;

  // Log the full error to the server console for debugging.
  console.error(`[error] ${req.method} ${req.originalUrl} ->`, err.message);

  res.status(status).json({
    error: err.publicMessage || err.message || 'Something went wrong',
  });
}

module.exports = { notFound, errorHandler };
