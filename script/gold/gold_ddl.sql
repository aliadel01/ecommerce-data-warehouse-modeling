USE ECOMMERCE_DW.GOLD;

-- ======================================
-- DIMENSIONS
-- ======================================

-- Product Dimension
CREATE OR REPLACE TABLE dim_product (
    product_key INT AUTOINCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    product_category VARCHAR(100),
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

-- Seller Dimension
CREATE OR REPLACE TABLE dim_seller (
    seller_key INT AUTOINCREMENT PRIMARY KEY,
    seller_id VARCHAR(50),
    seller_zip_code VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(50)
);

-- User Dimension
CREATE OR REPLACE TABLE dim_user (
    user_key INT AUTOINCREMENT PRIMARY KEY,
    user_name VARCHAR(100),
    customer_zip_code VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(50)
);

-- Date Dimension
CREATE OR REPLACE TABLE dim_date (
    date_key INT PRIMARY KEY,        -- YYYYMMDD format
    full_date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    day_of_week VARCHAR(20),
    is_weekend BOOLEAN
);

-- Time Dimesion
CREATE OR REPLACE TABLE dim_time (
    time_key INT PRIMARY KEY,
    hour INT NOT NULL,
    minute INT NOT NULL,
    full_time TIME NOT NULL
);

-- Payment Method Dimension
CREATE OR REPLACE TABLE dim_payment_method (
    payment_method_key INT AUTOINCREMENT PRIMARY KEY,
    method_name VARCHAR(50)
);


-- ======================================
-- FACTS
-- ======================================

-- Fact Order Items
CREATE OR REPLACE TABLE fact_order_items (
    fact_order_item_key INT AUTOINCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,  -- degenerate dimension
    order_item_id INT,
    product_key INT REFERENCES dim_product(product_key),
    seller_key INT REFERENCES dim_seller(seller_key),
    date_key INT REFERENCES dim_date(date_key),
    time_key INT REFERENCES dim_time(time_key),  
    price NUMBER,
    shipping_cost NUMBER
);

-- Fact Orders
CREATE OR REPLACE TABLE fact_orders (
    fact_order_key INT AUTOINCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL, -- degenerate dimension
    user_key INT REFERENCES dim_user(user_key),
    order_date_key INT REFERENCES dim_date(date_key),
    order_date_time_key INT REFERENCES dim_time(time_key),          
    order_approved_date_key INT REFERENCES dim_date(date_key),
    order_approved_time_key INT REFERENCES dim_time(time_key),
    pickup_date_key INT REFERENCES dim_date(date_key),
    pickup_time_key INT REFERENCES dim_time(time_key),
    delivered_date_key INT REFERENCES dim_date(date_key),
    delivered_time_key INT REFERENCES dim_time(time_key),
    estimated_delivery_date_key INT REFERENCES dim_date(date_key),
    estimated_delivery_time_key INT REFERENCES dim_time(time_key),  
    order_status VARCHAR(30),
    total_order_value NUMBER
);

-- Fact Payment
CREATE OR REPLACE TABLE fact_payment (
    fact_payment_key INT AUTOINCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL, -- degenerate dimension
    payment_method_key INT REFERENCES dim_payment_method(payment_method_key),
    payment_sequential INT,
    payment_installments INT,
    payment_value NUMBER
);
