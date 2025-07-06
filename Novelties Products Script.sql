WITH new_products_2020 AS (
    SELECT * FROM [2020_Data]
    WHERE [Product code] NOT IN (
        SELECT DISTINCT [Product code]
        FROM [2019_Data]
    )
)
SELECT 
    SUM([Delivery amount]) AS Total_Novelties_Revenue
FROM new_products_2020;
