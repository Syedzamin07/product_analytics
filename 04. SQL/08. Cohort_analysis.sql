

USE product_analytics;

-- Step 1: Map Purchase Days (Ignores millions of 'views' to prevent timeouts)
DROP TEMPORARY TABLE IF EXISTS daily_purchases;
CREATE TEMPORARY TABLE daily_purchases AS
SELECT DISTINCT 
    user_id, 
    SUBSTR(event_time, 1, 10) AS activity_day
FROM events
WHERE event_type = 'purchase';

-- Step 2: Define Cohort (First Purchase Day per User)
DROP TEMPORARY TABLE IF EXISTS daily_cohorts;
CREATE TEMPORARY TABLE daily_cohorts AS
SELECT 
    user_id, 
    MIN(activity_day) AS cohort_day
FROM daily_purchases
GROUP BY user_id;

-- Step 3: Calculate Daily Retention
SELECT 
    c.cohort_day,
    p.activity_day,
    COUNT(p.user_id) AS active_users
FROM daily_cohorts c
JOIN daily_purchases p ON c.user_id = p.user_id
GROUP BY c.cohort_day, p.activity_day
ORDER BY c.cohort_day, p.activity_day;

-- Clean Up
DROP TEMPORARY TABLE IF EXISTS daily_purchases;
DROP TEMPORARY TABLE IF EXISTS daily_cohorts;