-- ============================================
-- Final Analytics Dashboard Queries
-- ============================================

USE product_analytics;

-- --------------------------------------------
-- Step 1 — Conversion by Product Category (Optimized for Speed)
-- --------------------------------------------
DROP TEMPORARY TABLE IF EXISTS distinct_cat_views;
CREATE TEMPORARY TABLE distinct_cat_views AS
SELECT DISTINCT category_code, user_id FROM events WHERE event_type = 'view' AND category_code IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS cat_viewers;
CREATE TEMPORARY TABLE cat_viewers AS
SELECT category_code, COUNT(user_id) AS viewers FROM distinct_cat_views GROUP BY category_code;

DROP TEMPORARY TABLE IF EXISTS distinct_cat_buyers;
CREATE TEMPORARY TABLE distinct_cat_buyers AS
SELECT DISTINCT category_code, user_id FROM events WHERE event_type = 'purchase' AND category_code IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS cat_buyers;
CREATE TEMPORARY TABLE cat_buyers AS
SELECT category_code, COUNT(user_id) AS buyers FROM distinct_cat_buyers GROUP BY category_code;

SELECT 
    v.category_code, 
    v.viewers, 
    COALESCE(b.buyers, 0) AS buyers,
    ROUND(COALESCE(b.buyers, 0) / v.viewers, 4) AS conversion_rate
FROM cat_viewers v
LEFT JOIN cat_buyers b ON v.category_code = b.category_code
ORDER BY conversion_rate DESC;

-- Clean up memory
DROP TEMPORARY TABLE IF EXISTS distinct_cat_views;
DROP TEMPORARY TABLE IF EXISTS cat_viewers;
DROP TEMPORARY TABLE IF EXISTS distinct_cat_buyers;
DROP TEMPORARY TABLE IF EXISTS cat_buyers;

-- --------------------------------------------
-- Step 2 — Revenue by Category
-- --------------------------------------------
SELECT
    category_code,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(*) AS total_purchases
FROM events
WHERE event_type = 'purchase'
AND category_code IS NOT NULL
GROUP BY category_code
ORDER BY total_revenue DESC;

-- --------------------------------------------
-- Step 3 — Conversion by Hour
-- --------------------------------------------
SELECT
    SUBSTR(event_time, 12, 2) AS hour,
    ROUND(
        SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END), 0), 
        4
    ) AS conversion_rate
FROM events
GROUP BY hour
ORDER BY hour;

-- --------------------------------------------
-- Step 4 — Top Selling Products
-- --------------------------------------------
SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_revenue,
    COUNT(*) AS purchases
FROM events
WHERE event_type = 'purchase'
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- --------------------------------------------
-- Step 5 — User Purchase Frequency
-- --------------------------------------------
SELECT
    user_id,
    COUNT(*) AS purchases
FROM events
WHERE event_type = 'purchase'
GROUP BY user_id 
ORDER BY purchases DESC
LIMIT 10;

-- --------------------------------------------
-- Step 6 — Average Purchase Price
-- --------------------------------------------
SELECT
    ROUND(AVG(price), 2) AS avg_purchase_price
FROM events
WHERE event_type = 'purchase';





