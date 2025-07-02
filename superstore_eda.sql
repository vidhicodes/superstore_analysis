SELECT *
FROM sales_staging;

-- Analysis Based on Sales 
SELECT ROUND(SUM(sales),2) as total_sales,
	   ROUND(SUM(quantity),2) as total_quantity,
       ROUND(SUM(profit),2) as total_profit
FROM sales_staging; -- total sales, quantity and profit

SELECT city,state,SUM(sales) AS total_sales,SUM(profit) AS total_profit
FROM sales_staging
GROUP BY city,state
ORDER BY total_sales DESC,total_profit DESC LIMIT 10; -- top 10 cities,states contributing most to sales and profit

SELECT customer_name, ROUND(SUM(sales),2) as total_sales
FROM sales_staging
GROUP BY customer_name
ORDER BY total_sales DESC LIMIT 10; -- Top 10 Customers acc to total sales

SELECT product_id,product_name,ROUND(SUM(sales),2)AS total_sales,ROUND(SUM(profit),2) AS total_profit
FROM sales_staging
GROUP BY product_id,product_name
ORDER BY total_sales DESC,total_profit DESC LIMIT 5;

-- Categorical Analysis

SELECT category, ROUND(SUM(profit),2) AS total_profit
FROM sales_staging
GROUP BY category
ORDER BY total_profit DESC LIMIT 1; -- Category generating most profit

SELECT category,sub_category,ROUND(SUM(sales),2)AS total_sales,ROUND(SUM(profit),2) AS total_profit
FROM sales_staging
GROUP BY category,sub_category
ORDER BY total_sales DESC,total_profit ASC;

SELECT category,sub_category,ROUND(SUM(CASE WHEN profit < 0 THEN -profit ELSE 0 END ),2) AS total_loss
FROM sales_staging
GROUP BY category,sub_category
HAVING total_loss>0
ORDER BY total_loss DESC;

-- Region based analysis

SELECT region , ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit
FROM sales_staging
GROUP BY region
ORDER BY total_sales DESC, total_profit DESC ; -- West region performs best in sales and profit

SELECT segment , ROUND(SUM(sales),2) AS total_sales
FROM sales_staging
GROUP BY segment
ORDER BY total_sales DESC; -- the Consumer segment generates most revenue

WITH reg_cat AS
(
SELECT region,category,ROUND(SUM(sales),2) AS total_sales, ROW_NUMBER() OVER(PARTITION BY region ORDER BY ROUND(SUM(sales),2)) AS cat_rank
FROM sales_staging
GROUP BY region,category
)
SELECT region, category, total_sales
FROM reg_cat
WHERE cat_rank = 1; -- shows how different region prefer different categories
    

-- Monthly sales trend
WITH mon_sales AS
(
SELECT SUBSTRING(order_date,1,7) AS 'MONTH', ROUND(SUM(sales),2) AS monthly_sales
FROM sales_staging
GROUP BY SUBSTRING(order_date,1,7)
ORDER BY SUBSTRING(order_date,1,7)
)
SELECT `MONTH`, monthly_sales
FROM mon_sales; -- helpful in finding sales trends

WITH year_sales AS
(
SELECT YEAR(order_date) AS 'YEAR', ROUND(SUM(sales),2) AS yearly_sales
FROM sales_staging
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)
)
SELECT `YEAR`, yearly_sales
FROM year_sales; 

WITH seasonal_sales AS
(
SELECT SUBSTRING(order_date,6,2) AS 'MONTH', ROUND(SUM(sales),2) AS monthly_sales
FROM sales_staging
GROUP BY SUBSTRING(order_date,6,2)
ORDER BY monthly_sales DESC
)
SELECT `MONTH`, monthly_sales
FROM seasonal_sales; -- helpful in identifying seasonal spikes

-- done