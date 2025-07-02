SELECT *
FROM sales;

CREATE TABLE sales_staging
LIKE sales;

SELECT *
FROM sales_staging;

INSERT INTO sales_staging
SELECT *
FROM sales;

WITH duplicate_cte AS
(
SELECT * ,ROW_NUMBER() OVER(PARTITION BY order_id,ship_date,ship_mode,customer_id,customer_name,segment,country,city,state,postal_code,region,product_id,category,sub_category,product_name,sales,quantity,discount,profit) as row_num
FROM sales_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num>1; -- only one duplicate found since row_id was unique for each row it eased the duplicate deletion ,duplicate row_id noted

SELECT *
FROM sales_staging
WHERE row_id = 3407; -- the row to be deleted is reviewed

DELETE
FROM sales_staging
WHERE row_id = 3407; -- the row is deleted

SELECT DISTINCT country
FROM sales_staging; -- only one country US Found so we can easily drop the country column in the final stages of data cleaning

SELECT DISTINCT  customer_name
FROM sales_staging
ORDER BY customer_name ; -- overviewed all seems ok

SELECT DISTINCT  city
FROM sales_staging
ORDER BY city ; -- overviewed all seems ok

SELECT DISTINCT  state
FROM sales_staging
ORDER BY state; -- overviewed all seems ok

SELECT DISTINCT  region
FROM sales_staging; -- all ok

SELECT DISTINCT  sub_category
FROM sales_staging; -- all ok

SELECT DISTINCT discount
FROM sales_staging; -- no invalid values

-- Columns :casing is good,no spell errors etc.

-- Standardizing data
-- repairing date columns i.e. formatting
-- !!!! Being Performed on Staging Table !!!!

SELECT order_date , STR_TO_DATE(order_date,'%m/%d/%Y')
FROM sales_staging;-- order date reviewd before converting to standard format

UPDATE sales_staging
SET order_date = STR_TO_DATE(order_date,'%m/%d/%Y'); -- order date converted to standard format

ALTER TABLE sales_staging
MODIFY COLUMN order_date DATE; -- table column modified accordingly

SELECT ship_date , STR_TO_DATE(ship_date,'%m/%d/%Y')
FROM sales_staging;-- ship date reviewed before converting to standard format

UPDATE sales_staging
SET ship_date = STR_TO_DATE(ship_date,'%m/%d/%Y'); -- ship date converted to standard format

ALTER TABLE sales_staging
MODIFY COLUMN ship_date DATE; -- table column modified accordingly

-- DROP Unnecessary columns
-- here row_id is just a running number and we have removed duplicates so we can drop this
-- country has only one value US so due to no variation we can drop it alter
-- postal_code wont be used in analysis much we will mostly use city names so we can drop this too
-- order_id is for tracking purposes , has no use in analysis we can drop this too

ALTER TABLE sales_staging
DROP COLUMN row_id;

ALTER TABLE sales_staging
DROP COLUMN country;

ALTER TABLE sales_staging
DROP COLUMN postal_code;

ALTER TABLE sales_staging
DROP COLUMN order_id;

-- Done