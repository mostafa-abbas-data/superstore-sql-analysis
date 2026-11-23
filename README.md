# Superstore Sales: Data Cleaning & Analysis with MySQL

An end-to-end SQL project: cleaning a messy Superstore sales table and answering nine business questions about sales, profit, discounts, and shipping.

**Tools:** MySQL 8, MySQL Workbench

---

## Project Goals

1. Clean a raw sales table that contains missing values, inconsistent labels, and wrong data types.
2. Analyze sales and profit to find what drives (and hurts) profitability.

## Repository Structure

```
.
├── 01_data_cleaning.sql    # Builds the clean table `store` from the raw table
├── 02_data_analysis.sql    # Nine analysis questions
└── README.md
```

## Dataset

Superstore sales orders (one row per product line in an order).

| Column | Description |
|---|---|
| Row ID | Row number |
| Order ID | Order number |
| Order Date / Ship Date | Order and shipping dates |
| Ship Mode | Standard Class, Second Class, First Class, Same Day |
| Customer ID | Customer code |
| Country, City, State, Postal Code, Region | Customer location |
| Product ID, Product Name | Product code and name |
| Category, Sub-Category | Product classification |
| Sales | Sales amount |
| Quantity | Units sold |
| Discount | Discount rate (0 to 1) |
| Profit | Profit (negative = loss) |

The raw data is loaded into the table `superstore_orders_q1` and is never modified. All cleaning is done on a copy named `store`.

## Data Cleaning

| Problem found | Fix |
|---|---|
| Missing values written as `''`, `ERROR`, `--`, `UNKNOWN` in Discount, Region, and Profit | Converted to `NULL` |
| Missing Region | Filled from State (each state belongs to a single region) |
| Inconsistent Category names (`Tech`, `technologies`, `Furni`, `OfficeSupply`) | Standardized to Technology, Furniture, Office Supply |
| Broken character (`آ`) and extra spaces in Product Name | Removed with `REPLACE` and `TRIM` |
| Sales, Profit, and Discount stored as text | Converted to `DECIMAL` |
| Postal codes lost their leading zeros | Stored as 5-character text with `LPAD` |
| Dates stored as text (`mm/dd/yyyy`) | Converted to `DATE` with `STR_TO_DATE` |

The script ends with validation queries (remaining NULLs, ship date before order date, duplicate Row IDs, suspicious sales values).

## Analysis Questions

1. Total sales, profit, and profit margin per year and per month. Is the business growing?
2. Which Category and Sub-Category are the most profitable, and which lose money?
3. Which Region and State are the most and least profitable?
4. At what discount level does profit turn into a loss?
5. Top 10 loss-making products and top 10 customers by sales.
6. Does the ship mode affect profit or delivery time?
7. Which months have the peak sales?
8. If the discount were capped at 30%, how much loss would be avoided?
9. Which frequent customers receive large discounts and cause losses?

## Key Findings

**Profit by category (Question 2)**
- Technology is the most profitable category (about 129,600), followed by Office Supply (about 65,500). Furniture earns only about 6,000.
- The most profitable sub-categories are Copiers (55,570), Paper (46,009), and Phones (40,652).
- Six sub-categories lose money: Machines, Supplies, Furnishings, Bookcases, Fasteners, and Tables. Tables is the biggest loss at -17,678.
- Furniture's profit is small because Chairs (+36,463) is largely cancelled out by losses in Tables, Bookcases, and Furnishings.

**Discount cap (Question 8)**
- 1,712 orders with a discount above 30% lost money, for a total loss of about 247,197.
- Capping discounts at 30% could avoid up to that amount. This is a rough upper bound, since customers might buy less if discounts were lower.

<!-- Add findings for the remaining questions here -->

## How to Run

1. Import your CSV into MySQL as the table `superstore_orders_q1` (MySQL Workbench: *Table Data Import Wizard*).
2. Run `01_data_cleaning.sql` to create the clean table `store`.
3. Run `02_data_analysis.sql` query by query and review the results.

> MySQL Workbench may block `UPDATE` statements without a key (error 1175). The cleaning script turns safe mode off at the top and back on at the end.

## Notes

- Analysis queries use plain `SELECT`, `GROUP BY`, `SUM`, `AVG`, and `HAVING`, so they are easy to follow.
- Products are grouped by name rather than Product ID, because some Product IDs map to more than one name.
- Negative profit rows are real losses and were intentionally kept.

## Source
 The data comes from a publicly available Superstore sales dataset on [Kaggle](PUT-THE-DATASET-LINK-HERE). It is used here for educational and portfolio purposes only.
