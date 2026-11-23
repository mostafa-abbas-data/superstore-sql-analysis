-- =====================================================================
-- Superstore Sales - Data Cleaning (MySQL 8 / MySQL Workbench)
-- ---------------------------------------------------------------------
-- Raw table  : superstore_orders_q1  (never modified)
-- Clean table: store                 (all cleaning happens here)
-- Safe to re-run: the script rebuilds `store` from the raw table.
-- =====================================================================

-- Allow UPDATE / ALTER without a key in the WHERE clause
-- (MySQL Workbench "safe mode", error 1175)
SET SQL_SAFE_UPDATES = 0;


-- ---------------------------------------------------------------------
-- Step 0: Look at the raw data
-- ---------------------------------------------------------------------
SELECT * FROM superstore_orders_q1 LIMIT 10;

-- How many Discount values are empty text?
SELECT COUNT(*) AS empty_discount
FROM superstore_orders_q1
WHERE TRIM(Discount) = '';


-- ---------------------------------------------------------------------
-- Step 1: Work on a copy, keep the raw table untouched
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS store;
CREATE TABLE store LIKE superstore_orders_q1;

INSERT INTO store
SELECT * FROM superstore_orders_q1;


-- ---------------------------------------------------------------------
-- Step 2: Turn placeholder text ('', 'ERROR', '--', 'UNKNOWN') into NULL
-- ---------------------------------------------------------------------
UPDATE store SET Discount = NULL WHERE TRIM(Discount) IN ('', 'ERROR', 'UNKNOWN');
UPDATE store SET Region   = NULL WHERE TRIM(Region)   IN ('', 'ERROR', '--', 'UNKNOWN');
UPDATE store SET Profit   = NULL WHERE TRIM(Profit)   IN ('', 'ERROR', 'UNKNOWN');


-- ---------------------------------------------------------------------
-- Step 3: Clean Product Name (remove the broken character and extra spaces)
-- ---------------------------------------------------------------------
SELECT DISTINCT `Product Name` FROM store LIMIT 20;   -- look before cleaning

UPDATE store
SET `Product Name` = TRIM(REPLACE(`Product Name`, 'آ', ''));


-- ---------------------------------------------------------------------
-- Step 4: Standardize Category names
-- ---------------------------------------------------------------------
SELECT DISTINCT Category FROM store;                  -- look before cleaning

UPDATE store SET Category = 'Technology'    WHERE Category IN ('Tech', 'technologies');
UPDATE store SET Category = 'Furniture'     WHERE Category = 'Furni';
UPDATE store SET Category = 'Office Supply' WHERE Category = 'OfficeSupply';

SELECT DISTINCT Category FROM store;                  -- should be 3 values


-- ---------------------------------------------------------------------
-- Step 5: Fill missing Region from State
-- (each state belongs to only one region, so this is safe)
-- ---------------------------------------------------------------------
UPDATE store s
JOIN (SELECT State, MAX(Region) AS Region
      FROM store
      WHERE Region IS NOT NULL
      GROUP BY State) m ON m.State = s.State
SET s.Region = m.Region
WHERE s.Region IS NULL;

-- Rows that could not be filled (state had no known region)
SELECT * FROM store WHERE Region IS NULL;


-- ---------------------------------------------------------------------
-- Step 6: Fix numeric data types (they were imported as text)
-- ---------------------------------------------------------------------
ALTER TABLE store MODIFY Sales    DECIMAL(10,2);
ALTER TABLE store MODIFY Profit   DECIMAL(10,2);
ALTER TABLE store MODIFY Discount DECIMAL(3,2);       -- so it sorts as a number, not text


-- ---------------------------------------------------------------------
-- Step 7: Postal Code as text with 5 digits (restore lost leading zeros)
-- e.g. 7090 -> 07090
-- ---------------------------------------------------------------------
ALTER TABLE store MODIFY `Postal Code` VARCHAR(5);

UPDATE store
SET `Postal Code` = LPAD(`Postal Code`, 5, '0');


-- ---------------------------------------------------------------------
-- Step 8: Convert dates from text (mm/dd/yyyy) to real DATE columns
-- The WHERE ... LIKE '%/%' guard makes it safe if run twice.
-- ---------------------------------------------------------------------
UPDATE store
SET `Order Date` = STR_TO_DATE(`Order Date`, '%m/%d/%Y')
WHERE `Order Date` LIKE '%/%';

UPDATE store
SET `Ship Date` = STR_TO_DATE(`Ship Date`, '%m/%d/%Y')
WHERE `Ship Date` LIKE '%/%';

-- Check before changing the type: this must return 0
SELECT COUNT(*) AS bad_dates
FROM store
WHERE `Order Date` IS NULL OR `Ship Date` IS NULL;

ALTER TABLE store
MODIFY `Order Date` DATE,
MODIFY `Ship Date`  DATE;


-- ---------------------------------------------------------------------
-- Step 9: Final checks
-- ---------------------------------------------------------------------
SHOW COLUMNS FROM store;                              -- data types

-- Remaining NULLs per column
SELECT SUM(Region   IS NULL) AS null_region,
       SUM(Discount IS NULL) AS null_discount,
       SUM(Profit   IS NULL) AS null_profit
FROM store;

-- Shipping date before order date? (should be 0)
SELECT COUNT(*) AS ship_before_order
FROM store
WHERE `Ship Date` < `Order Date`;

-- Duplicate Row IDs? (should return no rows)
SELECT `Row ID`, COUNT(*) AS cnt
FROM store
GROUP BY `Row ID`
HAVING COUNT(*) > 1;

-- Suspicious sales values (zero or very large) - review them manually
SELECT `Row ID`, `Product Name`, Sales, Quantity, Profit
FROM store
WHERE Sales = 0 OR Sales > 20000;

SELECT * FROM store LIMIT 10;


-- Turn safe mode back on
SET SQL_SAFE_UPDATES = 1;
