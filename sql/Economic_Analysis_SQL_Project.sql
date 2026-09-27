CREATE DATABASE pakistan_economy;
USE pakistan_economy;
SELECT * 
FROM master_dataset; 

SELECT COUNT(*) AS Total_Records
FROM master_dataset;

DESCRIBE master_dataset;

SELECT
MIN(Date) AS Start_Date,
MAX(Date) AS End_Date
FROM master_dataset;

-- Yearly average of all key metrics
SELECT Year, ROUND(AVG(Inflation_YoY),2) AS avg_inflation,
       ROUND(AVG(USD_PKR),2) AS avg_usd_pkr,
       ROUND(AVG(Remittances_Million_USD),2) AS avg_remittance,
       ROUND(AVG(Petrol_Price),2) AS avg_petrol
FROM master_dataset
GROUP BY Year
ORDER BY Year;

-- Total yearly remittances
SELECT Year, 
ROUND(SUM(Remittances_Million_USD),2) AS Total_Remittances
FROM master_dataset
GROUP BY Year
ORDER BY Year;

-- Highest inflation month
SELECT *
FROM master_dataset
ORDER BY Inflation_YoY DESC
LIMIT 1;

-- Months where inflation exceeded 20%
SELECT Date, Inflation_YoY
FROM master_dataset
WHERE Inflation_YoY > 20
ORDER BY Date;

-- Quarterly average remittances
SELECT Year, Quarter, ROUND(AVG(Remittances_Million_USD),2) AS avg_remittance
FROM master_dataset
GROUP BY Year, Quarter
ORDER BY Year, Quarter;

-- Highest USD month
SELECT *
FROM master_dataset
ORDER BY USD_PKR DESC
LIMIT 1;

-- Highest petrol price month
SELECT *
FROM master_dataset
ORDER BY Petrol_Price DESC
LIMIT 1;

-- Top 10 inflation months
SELECT Date,
Inflation_YoY
FROM master_dataset
ORDER BY Inflation_YoY DESC
LIMIT 10;

-- Lowest inflation months
SELECT Date,
Inflation_YoY
FROM master_dataset
ORDER BY Inflation_YoY ASC
LIMIT 10;

-- Years where average inflation exceeded 10%
SELECT Year,
ROUND(AVG(Inflation_YoY),2) AS Avg_Inflation
FROM master_dataset
GROUP BY Year
HAVING Avg_Inflation>10;

-- Average inflation by quarter
SELECT Quarter,
ROUND(AVG(Inflation_YoY),2)
AS Avg_Inflation
FROM master_dataset
GROUP BY Quarter;

-- Average petrol by fiscal year
SELECT
Fiscal_Year,
ROUND(AVG(Petrol_Price),2)
AS Avg_Petrol
FROM master_dataset
GROUP BY Fiscal_Year;

-- Rank months by remittance amount (highest first)
SELECT Date, Remittances_Million_USD,
       RANK() OVER (ORDER BY Remittances_Million_USD DESC) AS remittance_rank
FROM master_dataset;

-- Top 5 highest remittance months
SELECT Date, Remittances_Million_USD
FROM (
    SELECT Date, Remittances_Million_USD,
           DENSE_RANK() OVER (ORDER BY Remittances_Million_USD DESC) AS rnk
    FROM master_dataset
) ranked
WHERE rnk <= 5;

-- Rank each year's months by inflation (reset ranking every year)
SELECT Year, Date, Inflation_YoY,
       RANK() OVER (PARTITION BY Year ORDER BY Inflation_YoY DESC) AS yearly_inflation_rank
FROM master_dataset;

-- Highest petrol price month per year (top 1 only)
SELECT Year, Date, Petrol_Price
FROM (
    SELECT Year, Date, Petrol_Price,
           ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Petrol_Price DESC) AS rn
    FROM master_dataset
) t
WHERE rn = 1;

-- Percentile ranking of inflation across entire dataset
SELECT Date, Inflation_YoY,
       NTILE(4) OVER (ORDER BY Inflation_YoY) AS inflation_quartile
FROM master_dataset;

--  Petrol price 2 and 3 months ago vs current inflation (multi-lag comparison)
SELECT Date, Inflation_YoY,
       LAG(Petrol_Price, 1) OVER (ORDER BY Date) AS petrol_lag1,
       LAG(Petrol_Price, 2) OVER (ORDER BY Date) AS petrol_lag2,
       LAG(Petrol_Price, 3) OVER (ORDER BY Date) AS petrol_lag3
FROM master_dataset;

-- Month-over-month change using LAG (validate your Python-calculated column)
SELECT Date, Inflation_YoY,
       Inflation_YoY - LAG(Inflation_YoY, 1) OVER (ORDER BY Date) AS mom_inflation_change
FROM master_dataset;

-- Next month's inflation compared to today's petrol price (LEAD)
SELECT Date, Petrol_Price,
       LEAD(Inflation_YoY, 2) OVER (ORDER BY Date) AS inflation_2mo_later
FROM master_dataset;

-- Flag months where petrol price jumped >10% from previous month
WITH petrol_changes AS (
    SELECT
        Date,
        Petrol_Price,
        LAG(Petrol_Price,1) OVER (ORDER BY Date) AS prev_petrol,
        ROUND(
            ((Petrol_Price - LAG(Petrol_Price,1) OVER (ORDER BY Date))
            / LAG(Petrol_Price,1) OVER (ORDER BY Date)) * 100,
            2
        ) AS pct_jump
    FROM master_dataset
)

SELECT *
FROM petrol_changes
WHERE pct_jump > 10;

-- USD/PKR rate 6 months ago vs today (depreciation over half-year)
SELECT Date, USD_PKR,
       LAG(USD_PKR, 6) OVER (ORDER BY Date) AS usd_pkr_6mo_ago,
       ROUND(USD_PKR - LAG(USD_PKR, 6) OVER (ORDER BY Date), 2) AS change_6mo
FROM master_dataset;

-- 3-month rolling average of inflation (frame clause)
SELECT Date, Inflation_YoY,
       ROUND(AVG(Inflation_YoY) OVER (ORDER BY Date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS inflation_3mo_avg
FROM master_dataset;

-- 6-month rolling average of remittances
SELECT Date, Remittances_Million_USD,
       ROUND(AVG(Remittances_Million_USD) OVER (ORDER BY Date ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS remittance_6mo_avg
FROM master_dataset;

-- 12-month rolling average of petrol price (smoothing out volatility)
SELECT Date, Petrol_Price,
       ROUND(AVG(Petrol_Price) OVER (ORDER BY Date ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 2) AS petrol_12mo_avg
FROM master_dataset;

-- Running (cumulative) total of remittances since 2010
SELECT Date, Remittances_Million_USD,
       SUM(Remittances_Million_USD) OVER (ORDER BY Date) AS cumulative_remittances
FROM master_dataset;

-- Rolling 3-month average of petrol
SELECT
Date,
Petrol_Price,
AVG(Petrol_Price)
OVER(
ORDER BY Date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
AS Rolling_3M
FROM master_dataset;

-- Month with the largest USD increase
WITH USD_Change AS
(
SELECT
Date,
USD_PKR-
LAG(USD_PKR)
OVER(ORDER BY Date)
AS Increase_USD
FROM master_dataset
)

SELECT *
FROM USD_Change
ORDER BY Increase_USD DESC
LIMIT 1;

-- Month with the largest petrol increase
WITH Petrol_Change AS
(
SELECT
Date,
Petrol_Price-
LAG(Petrol_Price)
OVER(ORDER BY Date)
AS Increase_Petrol
FROM master_dataset
)

SELECT *
FROM Petrol_Change
ORDER BY Increase_Petrol DESC
LIMIT 1;

-- Top 5 remittance months
SELECT
Date,
Remittances_Million_USD
FROM master_dataset
ORDER BY Remittances_Million_USD DESC
LIMIT 5;

-- Years ranked by total remittances
SELECT
Year,
SUM(Remittances_Million_USD)
AS Total_Remittance,
DENSE_RANK()
OVER(
ORDER BY SUM(Remittances_Million_USD)
DESC
)
AS Ranking
FROM master_dataset
GROUP BY Year;

-- Compare every month with yearly average inflation
SELECT
Date,
Year,
Inflation_YoY,
AVG(Inflation_YoY)
OVER(PARTITION BY Year)
AS Yearly_Average
FROM master_dataset;

-- True Year-over-Year remittance growth % (same month last year)
SELECT Date, Remittances_Million_USD,
       LAG(Remittances_Million_USD, 12) OVER (ORDER BY Date) AS remittance_last_year,
       ROUND(((Remittances_Million_USD - LAG(Remittances_Million_USD,12) OVER (ORDER BY Date))
             / LAG(Remittances_Million_USD,12) OVER (ORDER BY Date)) * 100, 2) AS yoy_growth_pct
FROM master_dataset;

-- Fiscal year total remittances
SELECT Fiscal_Year, ROUND(SUM(Remittances_Million_USD),2) AS total_remittance
FROM master_dataset
GROUP BY Fiscal_Year
ORDER BY Fiscal_Year;

-- Which fiscal year had highest average inflation
SELECT Fiscal_Year, ROUND(AVG(Inflation_YoY),2) AS avg_inflation
FROM master_dataset
GROUP BY Fiscal_Year
ORDER BY avg_inflation DESC
LIMIT 1;

-- CTE: find months where petrol rose AND inflation rose next 2 months (lag correlation candidates)
WITH petrol_lagged AS (
    SELECT Date, Inflation_YoY, Petrol_Price,
           LAG(Petrol_Price, 2) OVER (ORDER BY Date) AS petrol_2mo_ago
    FROM master_dataset
)
SELECT Date, Inflation_YoY, petrol_2mo_ago
FROM petrol_lagged
WHERE petrol_2mo_ago IS NOT NULL
ORDER BY Date;

-- CTE: yearly summary, then filter years above overall average inflation
WITH yearly_avg AS (
    SELECT Year,
           AVG(Inflation_YoY) AS avg_inf
    FROM master_dataset
    GROUP BY Year
)

SELECT Year,
       ROUND(avg_inf, 2) AS avg_inflation
FROM yearly_avg
WHERE avg_inf > (
    SELECT AVG(Inflation_YoY)
    FROM master_dataset
)
ORDER BY avg_inf DESC;

-- CTE: rank years by remittance growth, then pick top 3
WITH yearly_remit AS (
    SELECT Year, SUM(Remittances_Million_USD) AS total_remit
    FROM master_dataset
    GROUP BY Year
),
ranked_years AS (
    SELECT Year, total_remit,
           RANK() OVER (ORDER BY total_remit DESC) AS rnk
    FROM yearly_remit
)
SELECT * FROM ranked_years WHERE rnk <= 3;

-- Categorize each month's inflation severity
SELECT Date, Inflation_YoY,
       CASE 
           WHEN Inflation_YoY < 5 THEN 'Low'
           WHEN Inflation_YoY BETWEEN 5 AND 15 THEN 'Moderate'
           WHEN Inflation_YoY BETWEEN 15 AND 25 THEN 'High'
           ELSE 'Severe'
       END AS inflation_category
FROM master_dataset;

-- Categorize PKR trend direction month-to-month
SELECT Date, USD_PKR,
       CASE 
           WHEN USD_PKR > LAG(USD_PKR,1) OVER (ORDER BY Date) THEN 'Depreciating'
           WHEN USD_PKR < LAG(USD_PKR,1) OVER (ORDER BY Date) THEN 'Appreciating'
           ELSE 'Stable'
       END AS pkr_trend
FROM master_dataset;

-- Economic Stress Index (custom metric)
WITH normalized AS (
    SELECT Date,
        (USD_PKR - MIN(USD_PKR) OVER()) / (MAX(USD_PKR) OVER() - MIN(USD_PKR) OVER()) AS usd_norm,
        (Inflation_YoY - MIN(Inflation_YoY) OVER()) / (MAX(Inflation_YoY) OVER() - MIN(Inflation_YoY) OVER()) AS inf_norm,
        (Petrol_Price - MIN(Petrol_Price) OVER()) / (MAX(Petrol_Price) OVER() - MIN(Petrol_Price) OVER()) AS petrol_norm
    FROM master_dataset
)
SELECT Date, ROUND((usd_norm*0.4 + inf_norm*0.3 + petrol_norm*0.3)*100, 2) AS Economic_Stress_Index
FROM normalized
ORDER BY Economic_Stress_Index DESC;

-- Create a reusable VIEW that Power BI will connect to directly
CREATE VIEW vw_economic_summary AS
SELECT Date, Year, Quarter, Inflation_YoY, USD_PKR, Remittances_Million_USD, Petrol_Price,
       ROUND(AVG(Inflation_YoY) OVER (ORDER BY Date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS inflation_3mo_avg,
       LAG(Petrol_Price, 2) OVER (ORDER BY Date) AS petrol_2mo_lag,
       CASE 
           WHEN Inflation_YoY < 5 THEN 'Low'
           WHEN Inflation_YoY BETWEEN 5 AND 15 THEN 'Moderate'
           WHEN Inflation_YoY BETWEEN 15 AND 25 THEN 'High'
           ELSE 'Severe'
       END AS inflation_category
FROM master_dataset;