SELECT 
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	AVG(total_sale) as avg_sales
FROM retail_sales
GROUP BY year,month
ORDER BY year,3 DESC

 --write a sql query to calculate the average sale for each month . Find out the best selling month in each year
 
SELECT * FROM
(
  SELECT
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	AVG(total_sale) as avg_sales,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date)ORDER BY AVG(total_sale)DESC) as rank
 FROM retail_sales
 GROUP BY year,month
) as t1
WHERE rank =1

SELECT  	
		year,
		month,
		avg_sales
	
FROM
(
  SELECT
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	AVG(total_sale) as avg_sales,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date)ORDER BY AVG(total_sale)DESC) as rank
 FROM retail_sales
 GROUP BY year,month
) as t1
WHERE rank =1

-- write sql query to find out thw top 5 customers based on the highest total score
SELECT * FROM retail_sales

SELECT 
	customer_id,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC

SELECT 
	customer_id,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--WRite sql query to find out the no. of unique customers who purchased itemsfrom each category
SELECT
	category,
	customer_id
FROM retail_sales

SELECT
	category,
	COUNT(customer_id)
FROM retail_sales
GROUP BY 1

SELECT
	category,
	COUNT(DISTINCT customer_id) as count_of_unique_customer
FROM retail_sales
GROUP BY 1

--Write sql query to create each shift and no.of orders
SELECT * FROM retail_sales

SELECT *,
	CASE
		WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17  THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales

WITH hourly_sale
AS
(
SELECT *,
	CASE
		WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17  THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales
)	
SELECT 
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift