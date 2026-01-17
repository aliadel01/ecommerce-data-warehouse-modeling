USE ECOMMERCE_DW.GOLD;

-- Which logistic route that have heavy traffic in our ecommerce?
SELECT 
    ds.seller_state,
    du.customer_state,
    COUNT(*) AS num_orders
FROM fact_orders fo
JOIN dim_user du
    ON fo.user_key = du.user_key
JOIN fact_order_items foi
    ON fo.order_id = foi.order_id
JOIN dim_seller ds
    ON foi.seller_key = ds.seller_key
WHERE fo.order_status = 'delivered'
GROUP BY ds.seller_state, du.customer_state
ORDER BY num_orders DESC;