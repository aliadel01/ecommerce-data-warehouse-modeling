USE ECOMMERCE_DW.GOLD;
    
-- How many installment is usually done when paying in the ecommerce?
SELECT 
    FLOOR(AVG(payment_installments)) AS avg_installments
FROM fact_payment; 

SELECT 
    payment_installments,
    COUNT(*) AS num_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM fact_payment
GROUP BY payment_installments
ORDER BY num_orders DESC;