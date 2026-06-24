-- =============================================================
-- Phase 3 migration — adds Payme bookkeeping columns
-- =============================================================
-- Run this ONCE on a database you already created in Phase 1/2, so you
-- don't have to wipe and reload everything:
--
--   sudo mysql nv_elon < backend/db/migration_phase3.sql
--
-- (Fresh installs from schema.sql already include these columns, so you
--  only need this file if your database is from before Phase 3.)
-- "IF NOT EXISTS" makes it safe to run more than once.
-- =============================================================
USE nv_elon;

ALTER TABLE payment_transactions
  ADD COLUMN IF NOT EXISTS create_time  BIGINT NOT NULL DEFAULT 0 AFTER amount,
  ADD COLUMN IF NOT EXISTS perform_time BIGINT NOT NULL DEFAULT 0 AFTER create_time,
  ADD COLUMN IF NOT EXISTS cancel_time  BIGINT NOT NULL DEFAULT 0 AFTER perform_time,
  ADD COLUMN IF NOT EXISTS reason       INT NULL AFTER cancel_time;
