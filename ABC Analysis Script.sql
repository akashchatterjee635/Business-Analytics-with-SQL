WITH all_years AS (
    SELECT * FROM [2019_Data]
    UNION ALL
    SELECT * FROM [2020_Data]
),
product_sales AS (
    SELECT 
        [Product code] AS Product,
        COUNT([Order number]) AS Num_of_Orders,
        SUM([Delivery amount]) AS Total_Revenue
    FROM all_years
    GROUP BY [Product code]
),
ranked_sales AS (
    SELECT *,
        SUM(Total_Revenue) OVER () AS grand_total,
        SUM(Total_Revenue) OVER (ORDER BY Total_Revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 1.0 
            / SUM(Total_Revenue) OVER () AS cumulative_share
    FROM product_sales
)
SELECT 
    Product,
    Num_of_Orders,
    Total_Revenue,
    CASE 
        WHEN cumulative_share <= 0.7 THEN 'A'
        WHEN cumulative_share <= 0.9 THEN 'B'
        ELSE 'C'
    END AS ABC_Class
FROM ranked_sales
ORDER BY Total_Revenue DESC;
