WITH all_data AS (
    SELECT * FROM [2019_Data]
    UNION ALL
    SELECT * FROM [2020_Data]
),
monthly_sales AS (
    SELECT 
        [Product code] AS Product,
        COUNT([Order number]) AS Num_of_Orders,
        SUM([Delivery amount]) AS Total_Revenue,
        YEAR([Date of delivery]) AS Year,
        FORMAT([Date of delivery], 'MMM') AS Month
    FROM all_data
    GROUP BY 
        [Product code],
        YEAR([Date of delivery]),
        FORMAT([Date of delivery], 'MMM')
),
ranked_monthly AS (
    SELECT *,
        SUM(Total_Revenue) OVER (PARTITION BY Year, Month) AS monthly_total,
        SUM(Total_Revenue) OVER (
            PARTITION BY Year, Month 
            ORDER BY Total_Revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 1.0 / SUM(Total_Revenue) OVER (PARTITION BY Year, Month) AS cumulative_share
    FROM monthly_sales
)
SELECT 
    Product,
    Year,
    Month,
    Num_of_Orders,
    Total_Revenue,
    CASE 
        WHEN cumulative_share <= 0.7 THEN 'A'
        WHEN cumulative_share <= 0.9 THEN 'B'
        ELSE 'C'
    END AS ABC_Class
FROM ranked_monthly
ORDER BY Year, Month, ABC_Class;
