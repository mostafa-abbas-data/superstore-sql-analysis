-- =====================================================================
-- Superstore Sales - Data Analysis (MySQL 8 / MySQL Workbench)
-- ---------------------------------------------------------------------
-- Run 01_data_cleaning.sql first. All queries use the clean table: store
-- =====================================================================


-- =====================================================================
-- Question 1: Total sales, total profit and profit margin. Is it growing?
-- =====================================================================

-- 1a) Per year
SELECT YEAR(`Order Date`) AS order_year,
       ROUND(SUM(Sales), 2)  AS total_sales,
       ROUND(SUM(Profit), 2) AS total_profit,
       ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS margin_pct   -- profit margin %
FROM store
GROUP BY order_year
ORDER BY order_year;

-- 1b) Per month number (1-12, all years combined)
SELECT MONTH(`Order Date`) AS month_no,
       ROUND(SUM(Sales), 2)  AS total_sales,
       ROUND(SUM(Profit), 2) AS total_profit,
       ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS margin_pct
FROM store
GROUP BY month_no
ORDER BY month_no;


-- =====================================================================
-- Question 2: Which Category / Sub-Category is the most profitable?
--             Which ones lose money?
-- =====================================================================

-- 2a) By Category
SELECT Category,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY Category
ORDER BY total_profit DESC;

-- 2b) By Category and Sub-Category (negative profit = loss)
SELECT Category,
       `Sub-Category`,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY Category, `Sub-Category`
ORDER BY total_profit DESC;


-- =====================================================================
-- Question 3: Which Region / State is the most profitable? Which loses most?
-- =====================================================================

-- 3a) By Region
SELECT Region,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY Region
ORDER BY total_profit DESC;

-- 3b) By State (best first)
SELECT State,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY State
ORDER BY total_profit DESC;

-- 3c) The 5 worst states
SELECT State,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY State
ORDER BY total_profit ASC
LIMIT 5;


-- =====================================================================
-- Question 4: At what discount level does profit turn into a loss?
-- =====================================================================
SELECT Discount,
       COUNT(*) AS orders,
       ROUND(AVG(Profit), 2) AS avg_profit,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
WHERE Discount IS NOT NULL
GROUP BY Discount
ORDER BY Discount;


-- =====================================================================
-- Question 5: Top 10 loss-making products and top 10 customers by sales
-- =====================================================================

-- 5a) 10 products with the biggest losses
--     (grouped by name, because Product ID is not unique per product here)
SELECT `Product Name`,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY `Product Name`
ORDER BY total_profit ASC
LIMIT 10;

-- 5b) 10 customers with the highest sales
SELECT `Customer ID`,
       ROUND(SUM(Sales), 2) AS total_sales
FROM store
GROUP BY `Customer ID`
ORDER BY total_sales DESC
LIMIT 10;


-- =====================================================================
-- Question 6: Does the ship mode affect profit or delivery time?
-- =====================================================================
SELECT `Ship Mode`,
       COUNT(*) AS orders,
       ROUND(AVG(DATEDIFF(`Ship Date`, `Order Date`)), 1) AS avg_delivery_days,
       ROUND(SUM(Profit), 2) AS total_profit,
       ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS margin_pct
FROM store
GROUP BY `Ship Mode`
ORDER BY avg_delivery_days;


-- =====================================================================
-- Question 7: Which months have the peak sales (seasonality)?
-- =====================================================================
SELECT MONTH(`Order Date`) AS month_no,
       ROUND(SUM(Sales), 2)  AS total_sales,
       ROUND(SUM(Profit), 2) AS total_profit
FROM store
GROUP BY month_no
ORDER BY total_sales DESC;


-- =====================================================================
-- Question 8: If we cap the discount at 30%, how much loss would we avoid?
-- (Rough estimate: sales may also drop if discounts are lower.)
-- =====================================================================
SELECT COUNT(*) AS losing_orders,
       ROUND(SUM(Profit), 2) AS total_loss
FROM store
WHERE Discount > 0.30 AND Profit < 0;


-- =====================================================================
-- Question 9: Customers who order often, with big discounts, and cause losses
-- (thresholds: 5+ orders, average discount above 30%, negative total profit)
-- =====================================================================
SELECT `Customer ID`,
       COUNT(DISTINCT `Order ID`) AS orders,
       ROUND(AVG(Discount), 2)    AS avg_discount,
       ROUND(SUM(Profit), 2)      AS total_profit
FROM store
GROUP BY `Customer ID`
HAVING COUNT(DISTINCT `Order ID`) >= 5
   AND AVG(Discount) > 0.30
   AND SUM(Profit) < 0
ORDER BY total_profit ASC
LIMIT 10;
