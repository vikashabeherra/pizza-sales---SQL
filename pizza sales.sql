CREATE DATABASE Pizza_Hut ;
USE Pizza_Hut ;
CREATE TABLE order_details (
order_details_id INT NOT NULL ,
order_id INT NOT NULL ,
pizza_id TEXT NOT NULL ,
quantity INT NOT NULL ,
PRIMARY KEY (order_details_id));

CREATE TABLE orders (
order_id INT NOT NULL ,
order_date DATE NOT NULL ,
order_time TIME NOT NULL,
PRIMARY KEY (order_id) ); 

-- Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS Total_orders
FROM orders ;

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(A.quantity*B.price),2) AS Total_Sales
FROM order_details AS A
JOIN pizzas AS B
ON A.pizza_id = B.pizza_id ;

-- Identify the highest-priced pizza.

SELECT pz.name , ps.price
FROM pizza_types AS PZ
JOIN pizzas AS PS
ON pz.pizza_type_id = ps.pizza_type_id
ORDER BY price DESC 
LIMIT 1 ;

-- Identify the most common pizza size ordered.

SELECT s.size , COUNT(h.order_details_id) AS Total_Purchase
FROM pizzas AS S
JOIN order_details AS H
ON s.pizza_id = h.pizza_id
GROUP BY s.size 
ORDER BY Total_Purchase DESC ;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name , SUM(order_details.quantity) AS Total_Sales_Quantity
FROM order_details 
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_Sales_Quantity DESC
LIMIT 5 ;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category , SUM(order_details.quantity) AS Quantity
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
GROUP BY pizza_types.category 
ORDER BY Quantity DESC ;

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS Hour ,
COUNT(order_id) AS Order_Count
 FROM orders
 GROUP BY HOUR(order_time) ;
 
 
 -- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category , COUNT(name) AS Distribution
 FROM pizza_types
 GROUP BY category ;


-- Group the orders by date and calculate the average number of pizzas ordered per day.


SELECT ROUND(AVG(quantity),0) 
FROM
(SELECT  orders.order_date , COUNT(order_details.quantity) AS Quantity
FROM order_details
JOIN orders
ON order_details.order_id = orders.order_id 
GROUP BY orders.order_date ) AS order_quantity ;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name , SUM(order_details.quantity * pizzas.price) AS Revenue
FROM order_details 
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name 
ORDER BY Revenue DESC
LIMIT 3 ;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category , 
ROUND(SUM(order_details.quantity * pizzas.price)/
(SELECT ROUND(SUM(A.quantity*B.price),2) AS Total_Sales
FROM order_details AS A
JOIN pizzas AS B
ON A.pizza_id = B.pizza_id ) *100,2) AS Revenue
FROM order_details 
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY  pizza_types.category
ORDER BY Revenue DESC ;

-- Analyse the cumulative revenue generated over time

SELECT order_date ,
SUM(Revenue) OVER(ORDER BY order_date ) AS Cum_Revenue
FROM 
(SELECT orders.order_date , SUM(order_details.quantity * pizzas.price) AS Revenue
FROM orders
JOIN order_details
ON orders.order_id = order_details.order_id
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date ) AS Sales ;

--  Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT category ,name , revenue ,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS Rank_no
FROM
(SELECT pizza_types.category , pizza_types.name ,
 SUM(order_details.quantity * pizzas.price) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ,pizza_types.name) AS A ;


