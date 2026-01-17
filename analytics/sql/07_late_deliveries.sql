USE ECOMMERCE_DW.GOLD;

-- How many late delivered order in our ecommerce? Are late order affecting the customer satisfaction?
-- Percentage of late deliveries
SELECT
    COUNT(*) AS num_late_orders,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) 
                              FROM fact_orders 
                              WHERE order_status = 'delivered'), 2) AS pct_late
FROM fact_orders
WHERE order_status = 'delivered'
    AND delivered_date_key > estimated_delivery_date_key;

-- How long are the delay for delivery / shipping process in each state?
SELECT 
    du.customer_state,
    COUNT(*) AS num_late_orders,
    FLOOR(AVG(dd.full_date - de.full_date)) AS delay_avg_day,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_late_orders
FROM FACT_ORDERS fo
JOIN dim_date dd
    ON fo.delivered_date_key = dd.date_key
JOIN dim_date de
    ON fo.estimated_delivery_date_key = de.date_key
JOIN dim_user du
    ON fo.user_key = du.user_key
where fo.order_status = 'delivered' 
    AND delivered_date_key > estimated_delivery_date_key
GROUP BY du.customer_state
ORDER BY delay_avg_day desc;

-- How long are the difference between estimated delivery time and actual delivery time in each state?
SELECT 
    du.customer_state,
    FLOOR(AVG(dd.full_date - de.full_date)) AS delay_avg_day
FROM FACT_ORDERS fo
JOIN dim_date dd
    ON fo.delivered_date_key = dd.date_key
JOIN dim_date de
    ON fo.estimated_delivery_date_key = de.date_key
JOIN dim_user du
    ON fo.user_key = du.user_key
where fo.order_status = 'delivered' 
GROUP BY du.customer_state
ORDER BY delay_avg_day desc;