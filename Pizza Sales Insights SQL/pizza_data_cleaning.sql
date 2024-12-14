# 1. DATA CLEANING of pizzas table 
-- Checking for NULL AND empty values
SELECT 
    CONCAT(
        'SELECT ',
        GROUP_CONCAT(CONCAT(
            'COUNT(CASE WHEN ', COLUMN_NAME, ' IS NULL OR ', COLUMN_NAME, " = '' THEN 1 END) AS ", COLUMN_NAME, '_nullCount'
        ) SEPARATOR ', '),
        ' FROM pizzas;'
    ) AS query
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizzas';


SELECT COUNT(CASE WHEN pizza_id IS NULL OR pizza_id = '' THEN 1 END) AS pizza_id_nullCount, 
COUNT(CASE WHEN pizza_type_id IS NULL OR pizza_type_id = '' THEN 1 END) AS pizza_type_id_nullCount, 
COUNT(CASE WHEN size IS NULL OR size = '' THEN 1 END) AS size_nullCount, 
COUNT(CASE WHEN price IS NULL OR price = '' THEN 1 END) AS price_nullCount 
FROM pizzas;

-- Observation: There is no null and empty values in pizzas table

-- Standardize the data
SHOW COLUMNS FROM pizzas;
SELECT * FROM pizzas LIMIT 1;

-- Observation: Data is in a standardized format

-- Checking any duplicate rows
SELECT * FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY pizza_id, pizza_type_id, size, price) row_num
FROM pizzas) duplicates_checking
WHERE row_num > 1;

-- Observation: There is no duplicates available in this table

# 2. DATA CLEANING of pizza_types table 
 -- Checking NULL and empty values
SELECT 
CONCAT(
 'SELECT ',
  GROUP_CONCAT(
  CONCAT('COUNT(CASE WHEN ', COLUMN_NAME, ' IS NULL OR ', COLUMN_NAME, " = '' THEN 1 END) AS ", COLUMN_NAME, '_null_count')
  SEPARATOR ', ' 
  ),
  ' FROM pizza_types;'
) AS query
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_types';

SELECT COUNT(CASE WHEN pizza_type_id IS NULL OR pizza_type_id = '' THEN 1 END) AS pizza_type_id_null_count, 
COUNT(CASE WHEN name IS NULL OR name = '' THEN 1 END) AS name_null_count, 
COUNT(CASE WHEN category IS NULL OR category = '' THEN 1 END) AS category_null_count, 
COUNT(CASE WHEN ingredients IS NULL OR ingredients = '' THEN 1 END) AS ingredients_null_count 
FROM pizza_types;

-- Observation: There is no null and empty values in this table

-- Standardize the data
SHOW COLUMNS FROM pizza_types;
SELECT * FROM pizza_types LIMIT 1;

-- Observation: Data is in a standardized format

-- Checking any duplicate rows
SELECT * FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY pizza_type_id, `name`, category, ingredients) row_num
FROM pizza_types) duplicates_checking
WHERE row_num > 1;

-- Observation: There is no duplicates available in this table

# 3. DATA CLEANING of Orders table 
 -- Checking NULL and empty values
SELECT 
CONCAT(
 'SELECT ',
  GROUP_CONCAT(
  CONCAT('COUNT(CASE WHEN ', COLUMN_NAME, ' IS NULL OR ', COLUMN_NAME, " = '' THEN 1 END) AS ", COLUMN_NAME, '_null_count')
  SEPARATOR ', ' 
  ),
  ' FROM orders;'
) AS query
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders';

SELECT COUNT(CASE WHEN `date` IS NULL OR `date` = '' THEN 1 END) AS date_null_count, 
COUNT(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 END) AS order_id_null_count, 
COUNT(CASE WHEN time IS NULL OR time = '' THEN 1 END) AS time_null_count 
FROM orders;

-- Observation: There is no null and empty values in this table

-- Standardize the data
SHOW COLUMNS FROM orders;
SELECT * FROM orders LIMIT 1; 

-- date column rename to order_date
ALTER TABLE orders
RENAME COLUMN `date` TO order_date;

-- time column rename to order_time
ALTER TABLE orders
RENAME COLUMN `time` TO order_time;

-- order_date datatype changes from text to date
ALTER TABLE orders
MODIFY COLUMN order_date DATE;

-- order_time datatype changes from text to date
ALTER TABLE orders
MODIFY COLUMN order_time TIME;

SELECT * FROM orders;

-- Observation: Data converts into a standardized format

-- Checking any duplicate rows
SELECT * FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY order_id, order_date, order_time) row_num
FROM orders) duplicates_checking
WHERE row_num > 1;

-- Observation: There is no duplicates available in this table

# 4. DATA CLEANING of order_details table 
 -- Checking NULL and empty values
SELECT 
CONCAT(
 'SELECT ',
  GROUP_CONCAT(
  CONCAT('COUNT(CASE WHEN ', COLUMN_NAME, ' IS NULL OR ', COLUMN_NAME, " = '' THEN 1 END) AS ", COLUMN_NAME, '_null_count')
  SEPARATOR ', ' 
  ),
  ' FROM order_details;'
) AS query
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_details';

SELECT COUNT(CASE WHEN order_details_id IS NULL OR order_details_id = '' THEN 1 END) AS order_details_id_null_count, 
COUNT(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 END) AS order_id_null_count, 
COUNT(CASE WHEN pizza_id IS NULL OR pizza_id = '' THEN 1 END) AS pizza_id_null_count, 
COUNT(CASE WHEN quantity IS NULL OR quantity = '' THEN 1 END) AS quantity_null_count 
FROM order_details;

-- Observation: There is no null and empty values in this table

-- Standardize the data
SHOW COLUMNS FROM order_details;
SELECT * FROM order_details LIMIT 1;

-- Observation: Data is in a standardized format

-- Checking any duplicate rows
SELECT * FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY order_details_id, order_id, pizza_id, quantity) row_num
FROM order_details) duplicates_checking
WHERE row_num > 1;

-- Observation: There is no duplicates available in this table
