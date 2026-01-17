USE ECOMMERCE_DW.GOLD;

-- What is the frequency of purchase on each state?
SELECT 
    du.customer_state,
    COUNT(*) AS num_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM fact_orders fo
JOIN dim_user du
    ON fo.user_key = du.user_key
WHERE fo.order_status = 'delivered'
GROUP BY du.customer_state
ORDER BY num_orders DESC;