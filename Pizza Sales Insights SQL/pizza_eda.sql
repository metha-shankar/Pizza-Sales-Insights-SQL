# Exploratory Data Analysis
-- Retrieve the total number of orders placed
SELECT COUNT(order_id) total_no_of_orders FROM orders;

-- Calculate the total revenue generated from pizza sales
SELECT ROUND(SUM(price * quantity),2) total_revenue 
FROM pizzas t1
JOIN order_details t2
 ON t1.pizza_id = t2.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.pizza_type_id, size, `name`, price
FROM (
	SELECT * FROM pizzas
	WHERE price = (SELECT MAX(price) FROM pizzas)
) highest_price
JOIN pizza_types
	ON highest_price.pizza_type_id = pizza_types.pizza_type_id;
    
-- Identify the most common pizza size ordered.
SELECT size, COUNT(order_id) total_no_of_order_sizes  
FROM pizzas t1
JOIN order_details t2
	ON t1.pizza_id = t2.pizza_id
GROUP BY size
ORDER BY 2 DESC;

-- List the top 5 most ordered pizza types along with their quantities.
WITH order_details_of_pizzas_and_types AS
(
 SELECT t1.pizza_id, t1.pizza_type_id, t2.`name`, t3.quantity  
 FROM pizzas t1
 JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
 JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
), pizza_types_ordered AS
(
  SELECT pizza_type_id, COUNT(*) total_no_of_pizza_types_ordered 
  FROM order_details_of_pizzas_and_types
  GROUP BY 1
)
SELECT t2.pizza_type_id, `name`,
total_no_of_pizza_types_ordered, 
SUM(quantity) Total_quantity 
FROM order_details_of_pizzas_and_types t1
JOIN pizza_types_ordered t2
 ON t1.pizza_type_id = t2.pizza_type_id
GROUP BY 1,2,3
ORDER BY 3 DESC
LIMIT 5;

-- Improvised version of the previous one
SELECT t1.pizza_type_id, t2.`name`, 
COUNT(t3.order_id) total_orders,
SUM(t3.quantity) total_quantity  
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity 
-- of each pizza category ordered.
SELECT category, SUM(quantity) total_quantity 
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) hours, 
COUNT(order_id) total_orders
FROM orders
GROUP BY 1;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(order_id) total_orders 
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Group the orders by date and calculate the average number of pizzas 
-- ordered per day.
SELECT order_date, ROUND(AVG(total_orders)) avg_orders_per_day
FROM (SELECT order_date, SUM(quantity) total_orders 
FROM orders t1
JOIN order_details t2
	ON t1.order_id = t2.order_id
GROUP BY 1) total_orders_per_day
GROUP BY 1;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT t2.pizza_type_id, `name`, ROUND(SUM(price * quantity),2) Total_revenue
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
-- hardcoded approach
SELECT ROUND(SUM(price * quantity),2) total_revenue
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id;
-- Total Revenue = 817860.05
SELECT `name`, 
CONCAT(
ROUND(SUM(price * quantity) / 817860.05* 100, 2), 
'%') percentage_contribution
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
GROUP BY 1;

-- dynamic approach
WITH total AS
(
	SELECT ROUND(SUM(price * quantity),2) total_revenue
	FROM pizzas t1
	JOIN pizza_types t2 
		ON t1.pizza_type_id = t2.pizza_type_id
	JOIN order_details t3
		ON t1.pizza_id = t3.pizza_id
)
SELECT `name`,
CONCAT(
ROUND(SUM(price * quantity) / total_revenue * 100, 2), 
'%') percentage_contribution
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id,
    total
GROUP BY 1, total_revenue;

-- Analyze the cumulative revenue generated per day.
WITH total_per_day AS
(
	SELECT order_date, ROUND(SUM(price * quantity), 2) total_revenue 
    FROM order_details t1
	JOIN orders t2
		ON t1.order_id = t2.order_id
	JOIN pizzas t3
		ON t1.pizza_id = t3.pizza_id
	GROUP BY 1
)

SELECT order_date, total_revenue,
ROUND(cumulative_revenue, 2) cumulative_revenue_per_day FROM ( 
	SELECT *, 
	SUM(total_revenue) OVER(ORDER BY order_date) cumulative_revenue
	FROM total_per_day) total;
    
-- Determine the top 3 most ordered pizza types based on revenue 
-- for each pizza category.


WITH ranking_pizza_category AS
(
SELECT `name`, 
category,
ROUND(SUM(price * quantity), 2) total_revenue,
RANK() OVER(PARTITION BY category 
ORDER BY ROUND(SUM(price * quantity), 2) DESC) ranking 
FROM pizzas t1
JOIN pizza_types t2 
	ON t1.pizza_type_id = t2.pizza_type_id
JOIN order_details t3
	ON t1.pizza_id = t3.pizza_id
GROUP BY 1,2)

SELECT `name`, category, total_revenue 
FROM ranking_pizza_category
WHERE ranking <= 3;

