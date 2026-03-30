-- ============================================
-- Advanced Funnel & Behavior Analysis
-- ============================================

USE product_analytics;

-- --------------------------------------------
-- Step 1. True Funnel Conversion (User Level)
-- --------------------------------------------
SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
FROM events
WHERE event_type IN ('view', 'cart', 'purchase');

-- --------------------------------------------
-- Step 2: Product Category Conversion (Fixed)
-- --------------------------------------------
DROP TEMPORARY TABLE IF EXISTS distinct_cat_views;
CREATE TEMPORARY TABLE distinct_cat_views AS
SELECT DISTINCT category_code, user_id 
FROM events 
WHERE event_type = 'view' AND category_code IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS cat_viewers;
CREATE TEMPORARY TABLE cat_viewers AS
SELECT category_code, COUNT(user_id) AS viewers 
FROM distinct_cat_views 
GROUP BY category_code;

DROP TEMPORARY TABLE IF EXISTS distinct_cat_buyers;
CREATE TEMPORARY TABLE distinct_cat_buyers AS
SELECT DISTINCT category_code, user_id 
FROM events 
WHERE event_type = 'purchase' AND category_code IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS cat_buyers;
CREATE TEMPORARY TABLE cat_buyers AS
SELECT category_code, COUNT(user_id) AS buyers 
FROM distinct_cat_buyers 
GROUP BY category_code;

SELECT 
    v.category_code, 
    v.viewers, 
    COALESCE(b.buyers, 0) AS buyers,
    ROUND(COALESCE(b.buyers, 0) / v.viewers, 4) AS conversion_rate
FROM cat_viewers v
LEFT JOIN cat_buyers b ON v.category_code = b.category_code
ORDER BY conversion_rate DESC;

-- --------------------------------------------
-- Step 3: Time-to-Purchase (Fixed)
-- --------------------------------------------
DROP TEMPORARY TABLE IF EXISTS user_purchases;
CREATE TEMPORARY TABLE user_purchases AS
SELECT user_id, MIN(event_time) AS purchase_time
FROM events WHERE event_type = 'purchase'
GROUP BY user_id;

-- Only pull views for users who made a purchase
DROP TEMPORARY TABLE IF EXISTS user_views;
CREATE TEMPORARY TABLE user_views AS
SELECT e.user_id, MIN(e.event_time) AS first_view
FROM events e
INNER JOIN user_purchases p ON e.user_id = p.user_id
WHERE e.event_type = 'view'
GROUP BY e.user_id;

SELECT 
    p.user_id, 
    v.first_view, 
    p.purchase_time,
    TIMESTAMPDIFF(
        MINUTE,
        STR_TO_DATE(v.first_view, '%Y-%m-%d %H:%i:%s UTC'),
        STR_TO_DATE(p.purchase_time, '%Y-%m-%d %H:%i:%s UTC')
    ) AS minutes_to_purchase
FROM user_purchases p
JOIN user_views v ON p.user_id = v.user_id
WHERE v.first_view <= p.purchase_time;

-- --------------------------------------------
-- Step 4. Hourly Conversion Rate
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
-- Step 5. Top Revenue Products
-- --------------------------------------------
SELECT
    product_id,
    SUM(price) AS total_revenue,
    COUNT(*) AS purchases
FROM events
WHERE event_type = 'purchase'
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;




