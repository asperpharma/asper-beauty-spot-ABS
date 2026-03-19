-- Migration: Add high-impact performance indexes
-- Based on common query patterns for brand/category filtering,
-- time-series review and telemetry queries, and regimen step lookups.

-- ============================================================
-- PRODUCTS — composite indexes for catalog filtering
-- ============================================================

-- Speeds up queries filtering by brand AND category
CREATE INDEX IF NOT EXISTS idx_products_brand_category
  ON public.products(brand, category);

-- Speeds up queries filtering by concern and step in the routine
CREATE INDEX IF NOT EXISTS idx_products_primary_concern_regimen
  ON public.products(primary_concern, regimen_step);

-- Partial index: only indexes products that are currently in stock.
-- Smaller, faster to scan, and cheaper to maintain than a full index.
CREATE INDEX IF NOT EXISTS idx_products_available_active
  ON public.products(brand, category)
  WHERE in_stock = true;

-- ============================================================
-- PRODUCT REVIEWS — composite index for product + time ordering
-- ============================================================

-- Speeds up loading a specific product's reviews in chronological order
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id_created_at
  ON public.product_reviews(product_id, created_at DESC);

-- ============================================================
-- TELEMETRY EVENTS — composite index for user + time ordering
-- ============================================================

-- Speeds up fetching a specific user's app events in reverse chronological order
CREATE INDEX IF NOT EXISTS idx_telemetry_events_user_occurred
  ON public.telemetry_events(user_id, occurred_at DESC);

-- ============================================================
-- REGIMEN STEPS — composite index for plan lookup + ordering
-- ============================================================

-- Speeds up fetching routine steps for a specific plan in step order
CREATE INDEX IF NOT EXISTS idx_regimen_steps_plan_step
  ON public.regimen_steps(plan_id, step_number);
