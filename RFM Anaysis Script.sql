DECLARE @as_of_date DATE = '2024-12-25';

-- Step 1: Combine 2019 + 2020 data and compute R, F, M metrics
WITH base AS (
    SELECT 
        [Client ID],
        DATEDIFF(DAY, MAX([Date of delivery]), @as_of_date) AS Recency,
        COUNT([Order number]) AS Frequency,
        SUM([Delivery amount]) AS Monetary
    FROM (
        SELECT * FROM [2019_Data]
        UNION ALL
        SELECT * FROM [2020_Data]
    ) AS orders
    GROUP BY [Client ID]
),rfm AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R,      -- Lower Recency → better → higher score
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F,     -- More frequent → better
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M       -- Higher spend → better
    FROM base
)

-- Step 2: Apply quantile-based scoring for R, F, M
, scored AS (
    SELECT *,
        CAST((R + F + M) / 3.0 AS DECIMAL(4,2)) AS Avg_RFM_Score
    FROM rfm
)

-- Group customers into 5 RFM tiers
SELECT 
    CASE 
        WHEN Avg_RFM_Score >= 4.5 THEN 'Champions'
        WHEN Avg_RFM_Score >= 3.5 THEN 'Loyal Customers'
        WHEN Avg_RFM_Score >= 2.5 THEN 'Need Attention'
        WHEN Avg_RFM_Score >= 1.5 THEN 'At Risk'
        ELSE 'Lost'
    END AS RFM_Group,
    COUNT([Client ID]) AS Customers,
    CAST(SUM(Monetary) AS DECIMAL(12,2)) AS Total_Revenue
FROM scored
GROUP BY 
    CASE 
        WHEN Avg_RFM_Score >= 4.5 THEN 'Champions'
        WHEN Avg_RFM_Score >= 3.5 THEN 'Loyal Customers'
        WHEN Avg_RFM_Score >= 2.5 THEN 'Need Attention'
        WHEN Avg_RFM_Score >= 1.5 THEN 'At Risk'
        ELSE 'Lost'
    END
ORDER BY Total_Revenue DESC;
