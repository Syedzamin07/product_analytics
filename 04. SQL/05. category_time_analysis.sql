-- ============================================
-- Category & Time Analysis
-- ============================================

USE product_analytics;

-- --------------------------------------------
-- 1. Category Revenue (Top Categories)
-- --------------------------------------------
SELECT 
    category_code,
    SUM(price) AS revenue
FROM events
WHERE event_type = 'purchase'
AND category_code IS NOT NULL
GROUP BY category_code
ORDER BY revenue DESC
LIMIT 10;

-- --------------------------------------------
-- 2. Top Products by Revenue
-- --------------------------------------------
SELECT 
    product_id,
    SUM(price) AS revenue
FROM events
WHERE event_type = 'purchase'
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;


-- ============================================
-- SHARED HOURLY DATA 
-- ============================================
DROP TEMPORARY TABLE IF EXISTS hourly_purchases;
CREATE TEMPORARY TABLE hourly_purchases AS
SELECT 
    SUBSTR(event_time, 12, 2) AS hour,
    COUNT(*) AS purchases
FROM events
WHERE event_type = 'purchase'
GROUP BY hour;


-- --------------------------------------------
-- 3. Hourly Purchases Trend
-- --------------------------------------------
SELECT * FROM hourly_purchases
ORDER BY hour;

-- --------------------------------------------
-- 4. Peak Hours (Top 5)
-- --------------------------------------------
SELECT * FROM hourly_purchases
ORDER BY purchases DESC
LIMIT 5;

-- --------------------------------------------
-- 5. Category Conversion Rate
-- --------------------------------------------

DROP TEMPORARY TABLE IF EXISTS category_views;
CREATE TEMPORARY TABLE category_views AS
SELECT 
    category_code,
    COUNT(*) AS views
FROM events
WHERE event_type = 'view'
AND category_code IS NOT NULL
GROUP BY category_code;

DROP TEMPORARY TABLE IF EXISTS category_purchases;
CREATE TEMPORARY TABLE category_purchases AS
SELECT 
    category_code,
    COUNT(*) AS purchases
FROM events
WHERE event_type = 'purchase'
AND category_code IS NOT NULL
GROUP BY category_code;

SELECT 
    v.category_code,
    v.views,
    COALESCE(p.purchases, 0) AS purchases,
    ROUND(
        COALESCE(p.purchases, 0) * 1.0 / v.views,
        4
    ) AS conversion_rate
FROM category_views v
LEFT JOIN category_purchases p
    ON v.category_code = p.category_code
ORDER BY conversion_rate DESC
LIMIT 10;

-- --------------------------------------------
-- 6. Conversion by Hour (Single-pass)
-- --------------------------------------------

SELECT 
    SUBSTR(event_time, 12, 2) AS hour,
    SUM(event_type = 'view') AS views,
    SUM(event_type = 'purchase') AS purchases,
    ROUND(
        SUM(event_type = 'purchase') / NULLIF(SUM(event_type = 'view'), 0), 
        4
    ) AS conversion_rate
FROM events
WHERE event_type IN ('view', 'purchase')
GROUP BY 1
ORDER BY 1;

