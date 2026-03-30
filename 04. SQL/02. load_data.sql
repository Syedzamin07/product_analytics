SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

-- ============================================
-- Load Data into events table (Max Speed)
-- ============================================

USE product_analytics;

-- 1. Turn off heavy background checks for lightning-fast import
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- 2. Run the raw data load (No row-by-row conversions)
LOAD DATA LOCAL INFILE 'D:/MMU/Projects/02. Product Analytics Project/01. Data/01/events_sample.csv'
INTO TABLE events
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. Save the data and restore safety checks
COMMIT;
SET unique_checks = 1;
SET foreign_key_checks = 1;
SET autocommit = 1;

-- ============================================
-- Verify data
-- ============================================
SELECT * FROM events
LIMIT 10;