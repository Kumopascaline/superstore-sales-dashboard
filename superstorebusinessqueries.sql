DROP TABLE IF EXISTS superstore;

CREATE TABLE superstore (
    "Row ID" INT,
    "Order ID" VARCHAR(50),
    "Order Date" VARCHAR(50), -- Changed to VARCHAR
    "Ship Date" VARCHAR(50),  -- Changed to VARCHAR
    "Ship Mode" VARCHAR(50),
    "Customer ID" VARCHAR(50),
    "Customer Name" VARCHAR(100),
    "Segment" VARCHAR(50),
    "Country" VARCHAR(50),
    "City" VARCHAR(50),
    "State" VARCHAR(50),
    "Postal Code" VARCHAR(10),
    "Region" VARCHAR(50),
    "Product ID" VARCHAR(50),
    "Category" VARCHAR(50),
    "Sub-Category" VARCHAR(50),
    "Product Name" VARCHAR(255),
    "Sales" NUMERIC,
    "Quantity" INT,
    "Discount" NUMERIC,
    "Profit" NUMERIC
);
-- Alter table to change date fields from VARCHAR to Date
ALTER TABLE superstore 
    ALTER COLUMN "Order Date" TYPE DATE USING to_date("Order Date", 'MM/DD/YYYY'),
    ALTER COLUMN "Ship Date" TYPE DATE USING to_date("Ship Date", 'MM/DD/YYYY');

SELECT * FROM superstore

-- Checking the number of rows in the table
SELECT COUNT(*) FROM superstore;

--Previewing the firts 5 rows
SELECT * FROM superstore LIMIT 5;

--Check dates Loaded correctly
Select  "Order Date", "Ship Date" FROM superstore LIMIT 5;

-- Query 1 — What is the total revenue and profit?
-- This is always the first question any business asks — how much did we make and how much did we keep?

SELECT ROUND(SUM("Sales")::NUMERIC, 2) AS Total_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Total_Profit,
		ROUND((SUM("Profit")/ SUM("Sales") * 100) :: NUMERIC, 2) AS Proit_Margin
FROM superstore

-- Query 2 — Which region makes the most revenue and profit?
SELECT "Region", 
		ROUND(SUM("Sales")::NUMERIC, 2) AS Total_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Total_Profit,
		ROUND((SUM("Profit")/ SUM("Sales") * 100) :: NUMERIC, 2) AS Proit_Margin
FROM superstore
GROUP BY "Region"
ORDER BY Total_Revenue DESC;

-- Query 3 — Which category makes the most profit?
SELECT "Category", 
		ROUND(SUM("Sales")::NUMERIC, 2) AS Total_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Total_Profit,
		ROUND((SUM("Profit")/ SUM("Sales") * 100) :: NUMERIC, 2) AS Proit_Margin
FROM superstore
GROUP BY "Category"
ORDER BY Total_Profit DESC;



-- Query 4 — Which sub-categories are actually losing money?

SELECT "Category", "Sub-Category", 
		ROUND(SUM("Sales")::NUMERIC, 2) AS Total_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Total_Profit,
		ROUND((SUM("Profit")/ SUM("Sales") * 100) :: NUMERIC, 2) AS Proit_Margin
FROM superstore
GROUP BY "Category", "Sub-Category"
ORDER BY Total_Profit ASC;

-- Query 5 — Is discounting causing the losses?
SELECT  "Sub-Category", 
		ROUND(SUM("Sales")::NUMERIC, 2) AS Total_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Total_Profit,
		ROUND((AVG("Discount") * 100) :: NUMERIC, 2) AS Avg_discount
FROM superstore
GROUP BY  "Sub-Category"
ORDER BY Avg_Discount DESC;

--Query 6 — Who are the top 10 customers by revenue?
SELECT   "Region", "Customer Name", "Segment",
		ROUND(SUM("Sales")::NUMERIC, 2) AS Total_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Total_Profit,
		COUNT("Order ID") AS Total_Order
FROM superstore
GROUP BY  "Customer Name","Region", "Segment"
ORDER BY Total_Revenue DESC
LIMIT 5;

-- Query 7 — What are the monthly sales trends?
SELECT  EXTRACT(YEAR FROM "Order Date"::DATE) AS year, -- To extract year and month from date
    	EXTRACT(MONTH FROM "Order Date"::DATE) AS month,
		ROUND(SUM("Sales")::NUMERIC, 2) AS Monthly_Revenue,
		ROUND(SUM("Profit"):: NUMERIC, 2) AS Monthly_Profit,
		COUNT("Order ID") AS Total_Order
FROM superstore
GROUP BY  year, month
ORDER BY Monthly_Revenue DESC
LIMIT 5;

-- Yearly Growth
SELECT 
    EXTRACT(YEAR FROM "Order Date"::DATE) AS year,
    ROUND(SUM("Sales")::NUMERIC, 2) AS yearly_revenue,
    ROUND(SUM("Profit")::NUMERIC, 2) AS yearly_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::NUMERIC, 2) AS profit_margin_pct,
    COUNT("Order ID") AS total_orders
FROM superstore
GROUP BY year
ORDER BY year ASC;


-- Query 8 — Which states are the most and least profitable?
-- Least Profitable Sate 
SELECT 
    "State",
    "Region",
    ROUND(SUM("Sales")::NUMERIC, 2) AS total_revenue,
    ROUND(SUM("Profit")::NUMERIC, 2) AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::NUMERIC, 2) AS profit_margin_pct
FROM superstore
GROUP BY "State", "Region"
ORDER BY total_profit ASC
LIMIT 10;

-- Most Profitable Sate 
SELECT 
    "State",
    "Region",
    ROUND(SUM("Sales")::NUMERIC, 2) AS total_revenue,
    ROUND(SUM("Profit")::NUMERIC, 2) AS total_profit,
    ROUND((SUM("Profit") / SUM("Sales") * 100)::NUMERIC, 2) AS profit_margin_pct
FROM superstore
GROUP BY "State", "Region"
ORDER BY total_profit DESC
LIMIT 10;

-- Query 9 — Does discounting hurt profit?

SELECT 
    CASE 
        WHEN "Discount" = 0 THEN '0% No discount'
        WHEN "Discount" <= 0.10 THEN '1-10% Low discount'
        WHEN "Discount" <= 0.20 THEN '11-20% Medium discount'
        WHEN "Discount" <= 0.30 THEN '21-30% High discount'
        ELSE 'Over 30% Very high discount'
    END AS discount_band,
    COUNT(*) AS total_orders,
    ROUND(SUM("Sales")::NUMERIC, 2) AS total_revenue,
    ROUND(SUM("Profit")::NUMERIC, 2) AS total_profit,
    ROUND(AVG("Profit")::NUMERIC, 2) AS avg_profit_per_order
FROM superstore
GROUP BY discount_band
ORDER BY avg_profit_per_order DESC;

-- Query 10 — Who are the most profitable customers?
SELECT 
    "Customer Name",
    "Segment",
    "Region",
    COUNT(DISTINCT "Order ID") AS total_orders,
    ROUND(SUM("Sales")::NUMERIC, 2) AS total_revenue,
    ROUND(SUM("Profit")::NUMERIC, 2) AS total_profit,
    ROUND(AVG("Discount") * 100::NUMERIC, 2) AS avg_discount_pct
FROM superstore
GROUP BY "Customer Name", "Segment", "Region"
ORDER BY total_profit DESC
LIMIT 10;

/* Summary Findings:
QueryFinding
Q1    Overall profit margin is low at 12.47%
Q2    Central region underperforming at 7.9% margin
Q3    Furniture barely profitable at 2.49% margin
Q4   Tables and Bookcases losing money
Q5   Tables over-discounted at 26% average
Q6   Top revenue customer Sean Miller is unprofitableQ7November is peak sales month every year
Q8   Texas losing $25,729 — biggest problem stateQ9Discounts over 20% always lose money
Q10   Most profitable customers get little or no discount
*/