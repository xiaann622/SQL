CREATE DATABASE project1;
--sales analysis
-- CREATE TABLE
CREATE TABLE retail_sales
(
	transaction_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender TEXT,
	age  INT,
	category TEXT,
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT ,
	total_sale FLOAT
)

SELECT * FROM retail_sales
LIMIT 100

SELECT 
	COUNT(*)
FROM retail_sales

-- check for nulls in your dataset
SELECT * FROM retail_sales
WHERE 
	transaction_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	
	OR
	total_sale IS NULL;

-- Delete the nulls from the dataset
DELETE FROM retail_sales
WHERE 
	transaction_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	
	OR
	total_sale IS NULL

__ sales that we have
SELECT COUNT(*) as total_sale FROM retail_sales

--how many unique customers we have
SELECT COUNT(distinct customer_id) as unique_customer FROM retail_sales

--Distinct categories
SELECT COUNT(distinct category) as unique_categories FROM retail_sales
-- retrieve all col for sales on 2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date ='2022-11-05'

-- retrieve all transaction where category is clothingsand quantity is more than 10 and the month is november
SELECT * FROM retail_sales
WHERE category ='Clothing'
	   AND
	  TO_CHAR(sale_date, 'YYYY-MM') ='2022-11'
	  AND
	  quantity >=4

SELECT  
	category ,
	COUNT(*) AS total_sales
FROM retail_sales
WHERE 
	category ='Clothing'
		AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND 
  quantity >= 4
GROUP BY category;

-- total sales for each category
SELECT * FROM retail_sales

SELECT
	category,
	SUM(total_sale) as net_sale
	
FROM retail_sales
GROUP BY category

SELECT
	category,
	SUM(total_sale) as net_sale,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category

--Avg age of customers who puchased from beauty category
SELECT 
	age
	
FROM retail_sales
WHERE category ='Beauty'

SELECT 
	AVG(age) as avg_age
	
FROM retail_sales
WHERE category ='Beauty'

SELECT 
	ROUND(AVG(age),2) as avg_age
	
FROM retail_sales
WHERE category ='Beauty'

--Transaction is greater than 1000
SELECT *FROM retail_sales

SELECT *
FROM retail_sales
WHERE total_sale > 1000

-- total no. of transactions made by gender in each category
SELECT 
	category,
	gender,
	count(*) as total_sales
FROM retail_sales
GROUP BY category, gender
ORDER BY 1

--Avg sales for each month and the best selling month in each year
SELECT * FROM retail_sales
 SELECT
	EXTRACT (YEAR FROM  sale_date) as year,
	EXTRACT (MONTH FROM  sale_date) as month,
	AVG(total_sale) as avg_sales
FROM retail_sales
GROUP BY 1,2
ORDER BY 1, 3 DESC

SELECT
	year,
	month,
	avg_sales
FROM
(
  SELECT
	EXTRACT (YEAR FROM  sale_date) as year,
	EXTRACT (MONTH FROM  sale_date) as month,
	AVG(total_sale) as avg_sales,
	RANK() OVER(PARTITION BY EXTRACT (YEAR FROM  sale_date) ORDER BY AVG(total_sale) DESC) as Rank
 FROM retail_sales
 GROUP BY 1,2
) as t1
WHERE rank = 1

--top 5 customer based on the highest total sales
SELECT *FROM retail_sales

SELECT
	customer_id,
	sum(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Unique customers  who purchased items from each category

SELECT
	category,
	COUNT(DISTINCT customer_id) as count_of_unique_customer
FROM retail_sales
GROUP BY 1
 -- create each shift  and no. of orders
SELECT * FROM retail_sales


SELECT *,
 	CASE 
	 	WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
		 WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN ' Afternoon'
		 ELSE 'Evening'
	END as shift
FROM retail_sales

WITH hourly_sale
AS 
(
SELECT *,
 	CASE 
	 	WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
		 WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN ' Afternoon'
		 ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT 
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift