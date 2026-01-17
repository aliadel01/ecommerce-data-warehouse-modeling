USE ECOMMERCE_DW.GOLD;

-- when is the peak season of our ecommerce?

-- over month
SELECT 
    DATE_TRUNC('month', d.full_date) AS year_month,
    SUM(fo.total_order_value) AS total
FROM fact_orders fo
INNER JOIN dim_date d
    ON fo.order_date_key = d.date_key
WHERE fo.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', d.full_date)
ORDER BY year_month ASC;

-- over quarters
SELECT d.year, d.quarter, SUM(fo.total_order_value) AS total
FROM fact_orders fo
INNER JOIN dim_date d
    ON fo.order_date_key = d.date_key
WHERE fo.order_status IN ('delivered')
GROUP BY d.year, d.quarter
ORDER BY d.year ASC, d.quarter ASC;

-- over days
SELECT d.year, d.month_name, d.day, SUM(fo.total_order_value) AS total
FROM fact_orders fo
INNER JOIN dim_date d
    ON fo.order_date_key = d.date_key
WHERE fo.order_status = 'delivered'
GROUP BY d.year, d.month_name, d.day
ORDER BY d.year, d.month, d.day;