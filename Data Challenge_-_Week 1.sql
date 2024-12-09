-- DROP DATABASE IF EXISTS `data_challenge`;
CREATE DATABASE data_challenge;
USE data_challenge;


-- Creation of the sales table with Customer_id and Product_id as the primary key 
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE products (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

INSERT INTO products
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE customers (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO customers
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- Case study Questions
-- 1.What is the total amount each customer spent at the restaurant?
WITH amount 
AS
	(SELECT customer_id,products.product_id,products.product_name,(price)
	FROM sales
	JOIN products
		ON sales.product_id = products.product_id
)
SELECT customer_id,SUM(price) AS Total_amount
FROM amount
GROUP BY customer_id
;

-- 2.How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(order_date) AS Entry_count
FROM sales
GROUP BY customer_id;

-- 3.What was the first item from the menu purchased by each customer?
SELECT customer_id, product_name
FROM
(
  SELECT customer_id, 
  product_name,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rank
  FROM sales 
  LEFT JOIN products 
  USING (product_id)
 ) AS order_table
 WHERE order_rank = 1;
 
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name,COUNT(*) AS times_purchased
FROM sales
JOIN products USING (product_id)
GROUP BY product_name
ORDER by times_purchased DESC
LIMIT 1;


-- 5.Most popular product for each customers
WITH popular_product AS 
( SELECT customer_id,product_name,COUNT(product_id) AS times_purchased
	 FROM sales
	 JOIN products
	 USING (product_id)
	 GROUP BY customer_id,product_name
	 ORDER BY customer_id,times_purchased DESC
)
SELECT customer_id,product_name 
FROM  (SELECT *, 
	   ROW_NUMBER() 
	   OVER(PARTITION BY customer_id ORDER BY times_purchased DESC) AS ranks
	   FROM popular_product 
	   ) AS ranking
WHERE ranks = 1
;

-- 6. Which product was purchased first by the customer after they become a member
WITH member_purchase AS
(   SELECT customer_id,order_date,product_id,product_name
	FROM sales
	JOIN customers
	USING(customer_id)
	JOIN products
	USING (product_id)
	WHERE order_date >join_date
	ORDER BY order_date,customer_id
)
SELECT customer_id,product_name
FROM (SELECT *,
	  ROW_NUMBER () OVER(PARTITION BY customer_id ORDER BY order_date) AS row_num
	  FROM member_purchase) AS first_memberpurchase
WHERE row_num = 1;

--  7.Which product was purchased first by the customer before they become a member
WITH premembership_purchase AS
(   SELECT customer_id,order_date,product_id,product_name
	FROM sales
	JOIN customers
	USING(customer_id)
	JOIN products
	USING (product_id)
	WHERE order_date <join_date
	ORDER BY order_date,customer_id
)
SELECT customer_id,product_name
FROM (SELECT *,
	  RANK () OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS row_num
	  FROM premembership_purchase) AS pre_memberpurchase
WHERE row_num =1 ;

-- 8. Total items bought and total amount before membership

SELECT customer_id,COUNT(*) AS Total_item,SUM(price) AS Total_amount
FROM(
	SELECT customer_id,product_name,price
	FROM sales
	JOIN products
	USING (product_id)
	JOIN customers
	USING(customer_id)
	WHERE order_date < join_date
) AS premembership
GROUP BY customer_id
ORDER BY customer_id;

-- 9. If each $1 spent equates 10 points and sushi has a 2x multiplier, how many points would each customer have?

SELECT customer_id,SUM(Points) AS Points
FROM (SELECT customer_id,(product_id),
	CASE
	WHEN product_id = 1 THEN  price * 20
	ELSE price * 10
	END AS Points
	FROM sales
	JOIN products
	USING (product_id)) AS Points
GROUP BY customer_id;

-- 10. In the first week after a customers joins the programme(including the join date) they earn 2x on all items, how many points does customer A and B have at the end of january
WITH included_date AS
(SELECT customer_id,product_id,order_date,join_date
FROM sales
JOIN customers
USING(customer_id)
WHERE order_date >= join_date AND order_date != "2021-02-01" 
)
SELECT customer_id,
SUM(CASE WHEN order_date < DATE_ADD(join_date,INTERVAL + 7 DAY) THEN price * 20
WHEN product_id = 1 THEN price * 20
ELSE price * 10
END) AS Points
FROM included_date
JOIN products
USING(product_id)
GROUP BY customer_id;


