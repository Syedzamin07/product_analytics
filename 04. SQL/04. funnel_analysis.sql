-- ============================================
-- Funnel Analysis (Lightweight & Reliable)
-- ============================================

USE product_analytics;

-- --------------------------------------------
-- 1. Create Stage Tables (FAST)
-- --------------------------------------------
DROP TEMPORARY TABLE IF EXISTS views;
CREATE TEMPORARY TABLE views AS
SELECT DISTINCT user_id
FROM events
WHERE event_type = 'view';

DROP TEMPORARY TABLE IF EXISTS carts;
CREATE TEMPORARY TABLE carts AS
SELECT DISTINCT user_id
FROM events
WHERE event_type = 'cart';

DROP TEMPORARY TABLE IF EXISTS purchases;
CREATE TEMPORARY TABLE purchases AS
SELECT DISTINCT user_id
FROM events
WHERE event_type = 'purchase';

-- --------------------------------------------
-- 2. Funnel Metrics
-- --------------------------------------------
SELECT
    v.views,
    c.carts,
    p.purchases,
    ROUND(p.purchases * 1.0 / NULLIF(v.views, 0), 4) AS purchase_rate,
    ROUND(1 - (p.purchases * 1.0 / NULLIF(v.views, 0)), 4) AS drop_off_rate
FROM 
    (SELECT COUNT(*) AS views FROM views) v,
    (SELECT COUNT(*) AS carts FROM carts) c,
    (SELECT COUNT(*) AS purchases FROM purchases) p;

-- --------------------------------------------
-- 3. Funnel Breakdown (for dashboard)
-- --------------------------------------------
SELECT 'View' AS stage, COUNT(*) AS users FROM views
UNION ALL
SELECT 'Cart', COUNT(*) FROM carts
UNION ALL
SELECT 'Purchase', COUNT(*) FROM purchases;

-- --------------------------------------------
-- 4. Step Conversion Rates
-- --------------------------------------------
SELECT
    v.views,
    c.carts,
    p.purchases,
    ROUND(c.carts * 1.0 / NULLIF(v.views, 0), 4) AS view_to_cart_rate,
    ROUND(p.purchases * 1.0 / NULLIF(c.carts, 0), 4) AS cart_to_purchase_rate
FROM 
    (SELECT COUNT(*) AS views FROM views) v,
    (SELECT COUNT(*) AS carts FROM carts) c,
    (SELECT COUNT(*) AS purchases FROM purchases) p;

-- --------------------------------------------
-- 5. Clean Up
-- --------------------------------------------
DROP TEMPORARY TABLE IF EXISTS views;
DROP TEMPORARY TABLE IF EXISTS carts;
DROP TEMPORARY TABLE IF EXISTS purchases;