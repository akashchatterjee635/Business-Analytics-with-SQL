-- Step 1: Aggregate revenue per product for each year separately
WITH revenue_2019 AS (
    SELECT 
        [Product code] AS product,
        SUM([Delivery amount]) AS total_2019
    FROM [2019_Data]
    GROUP BY [Product code]
),
revenue_2020 AS (
    SELECT 
        [Product code] AS product,
        SUM([Delivery amount]) AS total_2020
    FROM [2020_Data]
    GROUP BY [Product code]
)

-- Step 2: Join only products present in both years
SELECT 
    r20.product,
    total_2019,
    total_2020,
    (total_2020 - total_2019) AS difference
FROM revenue_2020 r20
JOIN revenue_2019 r19 ON r20.product = r19.product
ORDER BY difference DESC;
