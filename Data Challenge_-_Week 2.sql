# Pizza metrics
-- Question 1. How many  pizza was ordered?
SELECT  COUNT(order_id) AS num_of_pizza_ordered
FROM customer_orders;

-- Question 2. How many unique customer orders were made?
WITH unique_orders AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY order_id) AS unique_id
FROM customer_orders
)
SELECT COUNT(unique_id) AS unique_orders
FROM unique_orders
WHERE unique_id = 1;

-- Question 3.How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(cancellation) AS delivered_pizza
FROM runner_orders
WHERE cancellation = "delivered"
GROUP BY runner_id;

-- 	Question 4.How many of each type of pizza was delivered?
SELECT pizza_id,COUNT(pizza_id) AS delivered_pizza
FROM customer_orders
JOIN runner_orders
USING (order_id)
WHERE cancellation = "delivered"
GROUP BY pizza_id;
--  Question 5. How many vegetarians and meatlovers were ordered by each customer?
SELECT 
    customer_id,
    SUM(pizza_id = 1) AS meat_lovers,
    SUM(pizza_id = 2) AS vegetarians
FROM customer_orders
WHERE pizza_id IN (1, 2)
GROUP BY customer_id;

-- Question 6.What is the maximum number of pizza delivered in a single orders?
SELECT COUNT(pizza_id) AS max_ordered_pizza
FROM customer_orders
JOIN runner_orders
USING(order_id)
WHERE cancellation = "delivered"
GROUP BY order_id 
ORDER by max_ordered_pizza DESC
LIMIT 1;

-- Question 7.  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH pizza_filter AS (
SELECT customer_id,
CASE
	WHEN exclusions IS NULL AND extras IS NULL THEN "No_Changes"
    ELSE "Changes"
END AS `filter`
FROM customer_orders
JOIN runner_orders
USING(order_id)
WHERE cancellation = "delivered"
ORDER BY customer_id
)
SELECT customer_id,
SUM(CASE WHEN `filter` = 'Changes' THEN 1 ELSE 0 END) AS Changes,
SUM(CASE WHEN `filter` = 'No_Changes' THEN 1 ELSE 0 END) AS No_Changes
FROM
pizza_filter
GROUP BY customer_id
ORDER BY customer_id;

-- Question 8 How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT( ( CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 END)) AS pizza_with_double_addings
FROM customer_orders
JOIN runner_orders
USING(order_id)
WHERE cancellation = "delivered";

-- Question 9 What was the total volume of pizzas ordered for each hour of the day
SELECT HOUR(order_time) AS order_hour,COUNT(order_id) AS order_volume
FROM customer_orders
GROUP BY 1
ORDER BY 1;
 
 -- Question 10 What was the volume of orders for each day of the week?
 SELECT DAYNAME(order_time) AS day_name,COUNT(order_id) order_volume
 FROM customer_orders
 GROUP BY 1
 ORDER BY day_name
