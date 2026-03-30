-- ============================================
-- Table Setup (Run this tab first)
-- ============================================

CREATE DATABASE IF NOT EXISTS product_analytics;
USE product_analytics;

DROP TABLE IF EXISTS events;

CREATE TABLE events (
    event_time VARCHAR(50),
    event_type VARCHAR(20),
    product_id BIGINT,
    category_id BIGINT,
    category_code VARCHAR(100),
    brand VARCHAR(50),
    price DECIMAL(10,2),
    user_id BIGINT,
    user_session VARCHAR(100)
);

-- 4. Verify it was created successfully
SHOW TABLES;
DESCRIBE events;
