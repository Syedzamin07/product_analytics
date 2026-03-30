-- ============================================
-- Data Exploration & Understanding
-- ============================================

USE product_analytics;

-- --------------------------------------------
-- 1. Event Distribution
-- --------------------------------------------
SELECT 
    event_type, 
    COUNT(*) AS total_events
FROM events
GROUP BY event_type
ORDER BY total_events DESC;

-- --------------------------------------------
-- 2. Unique Users
-- --------------------------------------------
SELECT 
    COUNT(DISTINCT user_id) AS total_users
FROM events;

-- --------------------------------------------
-- 3. Missing Values Check
-- --------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN category_code IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS missing_brand
FROM events;

-- --------------------------------------------
-- 4. Price Distribution
-- --------------------------------------------
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM events
WHERE event_type = 'purchase';

-- --------------------------------------------
-- 5. Top Categories by Activity (Views)
-- --------------------------------------------

SELECT *
FROM events
WHERE event_type = 'view'
LIMIT 1000;

CREATE INDEX idx_event_category 
ON events(event_type, category_code);

SET SESSION max_execution_time = 60000;

SELECT 
    category_code, 
    COUNT(*) AS views
FROM events
WHERE event_type = 'view' 
  AND category_code IS NOT NULL
GROUP BY category_code
ORDER BY views DESC
LIMIT 10;


-- --------------------------------------------
-- 6. Top Brands by Purchases
-- --------------------------------------------
SELECT
    brand,
    COUNT(*) AS purchases
FROM events
WHERE event_type = 'purchase'
GROUP BY brand
ORDER BY purchases DESC
LIMIT 10;

-- --------------------------------------------
-- 7. Event Timeline Range
-- --------------------------------------------
SELECT
    MIN(event_time) AS start_date,
    MAX(event_time) AS end_date
FROM events;

-- --------------------------------------------
-- 8. Daily Activity Trend
-- --------------------------------------------
SELECT
    DATE(event_time) AS date,
    COUNT(*) AS total_events
FROM events
GROUP BY date
ORDER BY date;

