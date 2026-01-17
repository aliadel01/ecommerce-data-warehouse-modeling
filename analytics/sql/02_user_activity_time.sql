-- What time users are most likely make an order or using the ecommerce app?
USE ECOMMERCE_DW.GOLD;


SELECT 
    dt.hour,
    COUNT(*) AS num_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS pct_of_total
FROM fact_orders fo
INNER JOIN dim_time dt
    ON fo.order_date_time_key = dt.time_key
WHERE fo.order_status = 'delivered'
GROUP BY dt.hour
ORDER BY dt.hour ASC;