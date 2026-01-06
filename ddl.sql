CREATE OR REPLACE DATABASE ecommerce_dw;

CREATE OR REPLACE SCHEMA ecommerce_dw.bronze;
CREATE OR REPLACE SCHEMA ecommerce_dw.silver;
CREATE OR REPLACE SCHEMA ecommerce_dw.gold;

USE ECOMMERCE_DW.GOLD

-- 1. Date Dimension
CREATE OR REPLACE TABLE dim_date (
    date_key INT PRIMARY KEY, -- Usually populated from a script, not auto-inc
    full_date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    day_of_week VARCHAR(20),
    is_weekend BOOLEAN
);

CREATE OR REPLACE TABLE dim_time (
    time_key INT PRIMARY KEY,         -- Format: HHMMSS (e.g., 143005 for 14:30:05)
    full_time TIME NOT NULL,          -- The actual time object
    hour_24 INT,                      -- 0-23
    hour_12 INT,                      -- 1-12
    minute INT,                       -- 0-59
    second INT,                       -- 0-59
    am_pm CHAR(2),                    -- AM/PM
    day_part VARCHAR(20),             -- Morning, Afternoon, Evening, Night
    is_business_hours BOOLEAN         -- True if between 9 AM and 5 PM
);

-- 2. Seller Dimension
CREATE OR REPLACE TABLE dim_seller (
    seller_key INT IDENTITY(1,1) PRIMARY KEY, -- Auto PK
    seller_id VARCHAR(50), -- Business ID from source
    seller_zip_code VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- 3. Product Dimension
CREATE OR REPLACE TABLE dim_product (
    product_key INT IDENTITY(1,1) PRIMARY KEY, -- Auto PK
    product_id VARCHAR(50), -- Business ID from source
    product_category VARCHAR(100),
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

-- 4. User Dimension
CREATE OR REPLACE TABLE dim_user (
    user_key INT IDENTITY(1,1) PRIMARY KEY, -- Auto PK
    user_id VARCHAR(50), -- Business ID from source
    user_name VARCHAR(100),
    customer_zip_code VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- 5. Payment Method Dimension
CREATE OR REPLACE TABLE dim_payment_method (
    payment_method_key INT IDENTITY(1,1) PRIMARY KEY, -- Auto PK
    method_name VARCHAR(50) 
);

-- 6. Fact Orders (Updated with Time Key)
CREATE OR REPLACE TABLE fact_orders (
    fact_orders_key INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT,
    product_key INT REFERENCES dim_product(product_key),
    seller_key INT REFERENCES dim_seller(seller_key),
    user_key INT REFERENCES dim_user(user_key),
    date_key INT REFERENCES dim_date(date_key),
    time_key INT REFERENCES dim_time(time_key), 
    price NUMBER(15,2),
    shipping_cost NUMBER(15,2)
);

-- 7. Fact Payments (Updated with Time Key)
CREATE OR REPLACE TABLE fact_payment (
    fact_payment_key INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    payment_method_key INT REFERENCES dim_payment_method(payment_method_key),
    date_key INT REFERENCES dim_date(date_key),
    time_key INT REFERENCES dim_time(time_key), 
    payment_sequential INT,
    payment_installments INT,
    payment_value NUMBER(15,2)
);
