USE ECOMMERCE_DW.GOLD;

-- What is the preferred way to pay in the ecommerce?
SELECT 
    dpm.method_name,
    COUNT(fp.payment_method_key) AS total_transaction 
FROM fact_orders fo
LEFT JOIN fact_payment fp
    ON fo.order_id = fp.order_id
LEFT JOIN dim_payment_method dpm
    ON fp.payment_method_key = dpm.payment_method_key
GROUP BY dpm.method_name
ORDER BY total_transaction DESC;