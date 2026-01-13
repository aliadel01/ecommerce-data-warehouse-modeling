USE ECOMMERCE_DW.GOLD;

-- ======================================
-- LOAD DIMENSIONS
-- ======================================

-- 1. dim_product
TRUNCATE TABLE dim_product;

INSERT INTO dim_product (product_id, product_category, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT DISTINCT
    PRODUCT_ID,
    TRIM(PRODUCT_CATEGORY),
    PRODUCT_WEIGHT_G,
    PRODUCT_LENGTH_CM,
    PRODUCT_HEIGHT_CM,
    PRODUCT_WIDTH_CM
FROM ECOMMERCE_DW.SILVER.PRODUCTS;

-- 2. dim_seller
TRUNCATE TABLE dim_seller;

INSERT INTO dim_seller (seller_id, seller_zip_code, seller_city, seller_state)
SELECT DISTINCT
    SELLER_ID,
    SELLER_ZIP_CODE,
    TRIM(SELLER_CITY),
    TRIM(SELLER_STATE)
FROM ECOMMERCE_DW.SILVER.SELLERS;

-- 3. dim_user
TRUNCATE TABLE dim_user;

INSERT INTO dim_user (user_name, customer_zip_code, customer_city, customer_state)
SELECT DISTINCT
    USER_NAME,
    CUSTOMER_ZIP_CODE,
    CUSTOMER_CITY,
    CUSTOMER_STATE
FROM ECOMMERCE_DW.SILVER.USERS;

-- 4. dim_date
TRUNCATE TABLE dim_date;

-- Populate dim_date for a range (2010-01-01 to 2030-12-31)
INSERT INTO dim_date (date_key, full_date, day, month, month_name, quarter, year, day_of_week, is_weekend)
WITH dates AS (
    SELECT DATEADD(day, seq4(), '2010-01-01') AS dt
    FROM TABLE(GENERATOR(ROWCOUNT => 7671))  -- 7671 = number of days between 2010-01-01 and 2030-12-31
)
SELECT
    TO_NUMBER(TO_VARCHAR(dt,'YYYYMMDD')) AS date_key,  -- surrogate key
    dt AS full_date,
    DAY(dt) AS day,
    MONTH(dt) AS month,
    TRIM(TO_VARCHAR(dt,'MMMM')) AS month_name,
    CEIL(MONTH(dt)/3) AS quarter,
    YEAR(dt) AS year,
    TRIM(TO_VARCHAR(dt,'DAY')) AS day_of_week,
    CASE WHEN DAYOFWEEK(dt) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM dates;

INSERT INTO dim_date
VALUES (
  -1,
  '1900-01-01',
  NULL, NULL, 'Unknown',
  NULL, NULL,
  'Unknown',
  FALSE
);


-- 5. dim_time
TRUNCATE TABLE dim_time;

INSERT INTO dim_time (time_key, hour, minute, full_time)
WITH hours AS (
    SELECT SEQ4() AS hr
    FROM TABLE(GENERATOR(ROWCOUNT => 24))  -- generates numbers 0 to 23
),
minutes AS (
    SELECT SEQ4() AS mn
    FROM TABLE(GENERATOR(ROWCOUNT => 60))  -- generates numbers 0 to 59
)
SELECT 
    h.hr * 100 + m.mn as time_key,
    h.hr AS hour,
    m.mn AS minute,
    TO_TIME(LPAD(h.hr,2,'0') || ':' || LPAD(m.mn,2,'0')) AS full_time
FROM hours h
CROSS JOIN minutes m
ORDER BY hour, minute;

INSERT INTO dim_time (time_key, hour, minute, full_time)
VALUES (-1, 0, 0, '00:00:00');


-- 6. dim_payment_method
TRUNCATE TABLE dim_payment_method;

INSERT INTO dim_payment_method (method_name)
SELECT DISTINCT
    TRIM(PAYMENT_TYPE)
FROM ECOMMERCE_DW.SILVER.PAYMENTS;

INSERT INTO dim_payment_method (payment_method_key, method_name)
VALUES (-1, 'Unknown');

-- ======================================
-- LOAD FACTS
-- ======================================

-- 1. fact_orders
TRUNCATE TABLE fact_orders;

INSERT INTO fact_orders (
    order_id,
    user_key,
    order_date_key, order_date_time_key,
    order_approved_date_key, order_approved_time_key,
    pickup_date_key, pickup_time_key,
    delivered_date_key, delivered_time_key,
    estimated_delivery_date_key, estimated_delivery_time_key,
    order_status,
    total_order_value
)
SELECT
    o.ORDER_ID,
    u.user_key,

    COALESCE(d1.date_key, -1),
    COALESCE(t1.time_key, -1),

    COALESCE(d2.date_key, -1),
    COALESCE(t2.time_key, -1),

    COALESCE(d3.date_key, -1),
    COALESCE(t3.time_key, -1),

    COALESCE(d4.date_key, -1),
    COALESCE(t4.time_key, -1),

    COALESCE(d5.date_key, -1),
    COALESCE(t5.time_key, -1),

    TRIM(o.ORDER_STATUS),

    COALESCE(SUM(oi.PRICE + oi.SHIPPING_COST), 0) AS total_order_value

FROM ECOMMERCE_DW.SILVER.ORDERS o

LEFT JOIN ECOMMERCE_DW.SILVER.ORDER_ITEMS oi
    ON o.ORDER_ID = oi.ORDER_ID

LEFT JOIN dim_user u
    ON u.user_name = TRIM(o.USER_NAME)

-- Order datetime
LEFT JOIN dim_date d1
    ON d1.full_date = CAST(o.ORDER_DATE AS DATE)
LEFT JOIN dim_time t1
    ON t1.hour = HOUR(o.ORDER_DATE)
   AND t1.minute = MINUTE(o.ORDER_DATE)

-- Approved datetime
LEFT JOIN dim_date d2
    ON d2.full_date = CAST(o.ORDER_APPROVED_DATE AS DATE)
LEFT JOIN dim_time t2
    ON t2.hour = HOUR(o.ORDER_APPROVED_DATE)
   AND t2.minute = MINUTE(o.ORDER_APPROVED_DATE)

-- Pickup datetime
LEFT JOIN dim_date d3
    ON d3.full_date = CAST(o.PICKUP_DATE AS DATE)
LEFT JOIN dim_time t3
    ON t3.hour = HOUR(o.PICKUP_DATE)
   AND t3.minute = MINUTE(o.PICKUP_DATE)

-- Delivered datetime
LEFT JOIN dim_date d4
    ON d4.full_date = CAST(o.DELIVERED_DATE AS DATE)
LEFT JOIN dim_time t4
    ON t4.hour = HOUR(o.DELIVERED_DATE)
   AND t4.minute = MINUTE(o.DELIVERED_DATE)

-- Estimated delivery datetime
LEFT JOIN dim_date d5
    ON d5.full_date = CAST(o.ESTIMATED_TIME_DELIVERY AS DATE)
LEFT JOIN dim_time t5
    ON t5.hour = HOUR(o.ESTIMATED_TIME_DELIVERY)
   AND t5.minute = MINUTE(o.ESTIMATED_TIME_DELIVERY)

GROUP BY
    o.ORDER_ID,
    u.user_key,
    d1.date_key, t1.time_key,
    d2.date_key, t2.time_key,
    d3.date_key, t3.time_key,
    d4.date_key, t4.time_key,
    d5.date_key, t5.time_key,
    o.ORDER_STATUS;



-- 2. fact_order_items
TRUNCATE TABLE fact_order_items;

INSERT INTO fact_order_items (
    order_id,
    order_item_id,
    product_key,
    seller_key,
    date_key,
    time_key,
    price,
    shipping_cost
)
SELECT
    oi.ORDER_ID,
    oi.ORDER_ITEM_ID,

    p.product_key,
    s.seller_key,

    COALESCE(d.date_key, -1),
    COALESCE(t.time_key, -1),

    oi.PRICE,
    oi.SHIPPING_COST

FROM ECOMMERCE_DW.SILVER.ORDER_ITEMS oi

LEFT JOIN dim_product p
    ON p.product_id = oi.PRODUCT_ID

LEFT JOIN dim_seller s
    ON s.seller_id = oi.SELLER_ID

LEFT JOIN dim_date d
    ON d.full_date = CAST(oi.PICKUP_LIMIT_DATE AS DATE)

LEFT JOIN dim_time t
    ON t.hour = HOUR(oi.PICKUP_LIMIT_DATE)
   AND t.minute = MINUTE(oi.PICKUP_LIMIT_DATE);


-- 3. fact_payment
TRUNCATE TABLE fact_payment;

INSERT INTO fact_payment (
    order_id,
    payment_method_key,
    payment_sequential,
    payment_installments,
    payment_value
)
SELECT
    p.ORDER_ID,
    COALESCE(pm.payment_method_key, -1) AS payment_method_key,
    p.PAYMENT_SEQUENTIAL,
    p.PAYMENT_INSTALLMENTS,
    p.PAYMENT_VALUE
FROM ECOMMERCE_DW.SILVER.PAYMENTS p
LEFT JOIN dim_payment_method pm
    ON pm.method_name = TRIM(p.PAYMENT_TYPE);
