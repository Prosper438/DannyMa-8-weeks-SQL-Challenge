# DannyMa-8-weeks-SQL-Challenge. 
#### This project aims to provide answers to the popular Danny Ma 8 weeks SQL challenge. <br>
The link to the site for getting started and table creation SQL code. [Click here..](https://8weeksqlchallenge.com/getting-started/) <br>
Tool used: MySQL
# Challenge Overview
#### The aim of this challenge is to help individual hone and improve their SQL skills, improve effectiveness of critical thinking,
#### and help provide different methods of tackling SQL problems.

# Database and Table Creation Code
```SQL
- DROP DATABASE IF EXISTS `data_challenge`;
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
  
```


#### So feel free to check out the codes and drop your recommendations,opinions and corrections 🙂 💜
