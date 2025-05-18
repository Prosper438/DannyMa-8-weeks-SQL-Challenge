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

# Runners and Customer Experience
-- Q1. How many runners signed up for each 1 week period? (week starts from 2021-01-01)
SELECT CONCAT("Week starting from ", DATE_ADD("2021-01-01",INTERVAL FLOOR(DATEDIFF(registration_date,"2021-01-01")/7) WEEK)) AS week_inteval,
COUNT(runner_id) AS registered_runners
FROM runners
GROUP BY 1;

-- Q2. What is the average time in minutes it took for each runner to arrive at the pizza runner HQ to pick up the order?
SELECT runner_id, ROUND(AVG(TIMESTAMPDIFF(MINUTE,order_time,pickup_time)),2) AS avg_time_in_mins
FROM runner_orders
JOIN customer_orders
USING(order_id)
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

-- Q3. Is there relationship between the number of pizzas and how long the order takes to prepare?
WITH preparation_time AS 
(
SELECT runner_orders.order_id,MAX(TIMESTAMPDIFF(SECOND,order_time,pickup_time)) AS max_prep_time,
COUNT(pizza_id) AS count_per_order
FROM runner_orders 
JOIN customer_orders
USING(order_id)
WHERE pickup_time IS NOT NULL
GROUP BY runner_orders.order_id
)
SELECT count_per_order, ROUND(AVG(max_prep_time),2) Avg_order_time_in_sec
FROM preparation_time
GROUP BY count_per_order;
-- We can say the average time used in preparation is directly proportional to the number of pizza ordered.

-- 	Q4. What is the average distance travelled for each customer?
SELECT customer_id,ROUND(AVG(distance_in_km),2) AS average_distance_covered
FROM customer_orders
JOIN runner_orders
USING(order_id)
GROUP BY customer_id;

-- Q5.What is the difference between the longest and shortest delivery times for all orders?
SELECT CONCAT(MAX(duration_in_mins) - MIN(duration_in_mins) ," mins") AS time_range_in_mins
FROM runner_orders
WHERE duration_in_mins IS NOT NULL;

-- Q6. What was the average speed for each runner for each delivery and do you notice any trends for these values?
SELECT runner_id,ROUND(((distance_in_km * 1000) / (duration_in_mins * 60)),2)AS speed_in_mpersec
FROM runner_orders
WHERE distance_in_km IS NOT NULL
ORDER BY runner_id;

-- Q7. What is the successful delivery percentage for each runner?
WITH delivery_measure AS
(
SELECT runner_id, COUNT( CASE WHEN pickup_time IS NOT NULL THEN 1
END) AS success,
COUNT(CASE WHEN pickup_time IS NULL THEN 1 END) AS failure
FROM runner_orders
GROUP BY runner_id
)
SELECT runner_id, success,failure,
ROUND(100.0 * success / (success + failure), 2) AS success_percentage
FROM delivery_measure;

