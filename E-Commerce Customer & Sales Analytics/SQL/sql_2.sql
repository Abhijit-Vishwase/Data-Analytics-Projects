USE ecommerce_project;

SELECT * FROM customers;

SELECT * FROM order_items;

SELECT * FROM products;

SELECT * FROM orders;

# Monthly Trend Analysis:-

SELECT 
YEAR(order_date) AS year,
MONTH(order_date) AS month,
ROUND(SUM(total_spend),2) AS revenue
FROM orders AS o
JOIN  order_items AS ot
ON o.order_id = ot.order_id
GROUP BY year,month
ORDER BY revenue DESC;

# INSIGHTS:-
# October has highest revenue generated where as September is lowest.

#Top Customers:-

SELECT 
c.customer_id AS customer,
SUM(total_spend) AS revenue
FROM orders AS o
JOIN order_items AS ot
ON o.order_id = ot.order_id
JOIN customers AS c
ON c.customer_id = o.order_id
GROUP BY customer
ORDER BY revenue DESC
LIMIT 10;

# Product Performance:-

SELECT 
p.category,
COUNT(*) AS total_orders,
SUM(total_spend) AS revenue
FROM products AS p
JOIN order_items AS ot
ON p.product_id = ot.product_id
GROUP BY category
ORDER BY revenue DESC;

#Insights:-
# Top Revenue generating  products are of "HAIR" category.
# "MAKEUP" category is second strongest performer.
# "SKIN" category is underperforming.
# Revenue closely follow order volume. 

#  Average Order Value:-

SELECT 
ROUND(AVG(total_spend),2) AS avg_spend_per_order
FROM(
		SELECT
        order_id,
        SUM(total_spend) AS total_spend
        from order_items
        GROUP BY order_id
	)t;

# Insights :-
# Customers are comfortable on spending 447 per order.

# Total Revenue:-

SELECT 
SUM(total_spend) AS Revenue
FROM order_items;

# Insights:-
# 384853 is the total revenue generated till date 

# Repeat Customers:-

SELECT  
customer_id AS customer,
COUNT(DISTINCT order_id) as no_of_orders
FROM orders
GROUP BY customer
ORDER BY no_of_orders DESC;

# Insights:-
# Strong repeat purchase behaviour exists.alter

# Delivery Analysis:-

SELECT 
status,
COUNT(status) AS Delivery_Status
FROM orders
GROUP BY status;

# Insights:-
# Aproximatly 80% of orders are completed sucessfully
# Aproximatly 10% of orders are cancelled " Likely pre fulfillment losses"
# Aproximatly 10% of orders are returened " Likely post fulfilment losses"

# Country wise Analysis:-

WITH state AS(
				SELECT 
                country AS state,
                SUM(total_spend) AS revenue,
                COUNT(DISTINCT o.order_id) AS total_orders
                FROM customers AS c
                JOIN orders AS o
                ON c.customer_id = o.customer_id
                JOIN order_items AS ot
                ON o.order_id = ot.order_id
                GROUP BY c.country
			)
	SELECT *,
       RANK() OVER(
           ORDER BY revenue DESC
       ) AS rank_num
FROM state;

# Insights:-
# Italy has highest revenue generated followed by spain.
# Similary Italy has highest no of orders followed by spain.
# Germany has the lowest Revenue generated and so lowest no of orders.alter

# Product Analysis by cost:-

SELECT 
p.product_id,
p.product_name,
p.category,
COUNT(DISTINCT order_id) As orders,
Sum(price) aS REVENUE
FROM order_items AS ot
JOIN products AS p
ON ot.product_id = p.product_id
GROUP BY product_id
ORDER BY orders DESC;

# Insights:-
# Product 45,23,47,16 performs better than others.
# product 10,33,36,5 perfoms very low compare to others.
# It indicates that products from same categories dosent perform equally 
# i.e few products perform well few preform low.

# Ranking Customers on thier spend :-

SELECT
DENSE_RANK() OVER( ORDER BY SUM(total_spend) DESC) AS rank_cust,
c.customer_id AS customer,   
COUNT(DISTINCT ot.order_id) AS orders,
SUM(ot.total_spend) AS revenue
FROM customers AS c
JOIN orders AS o
ON c.customer_id = o.customer_id
JOIN order_items AS ot
ON o.order_id = ot.order_id
GROUP BY customer
ORDER BY revenue DESC;

# Insights:-
# Customer 152 spended highest i.e 5388 and also has 7 orders it indicates that this customer is more active 
# Customer 18 spended only 18 i.e the lowest in the list it indicates that this customer is less active 

# less Active Customers:-

WITH CUST AS(
				SELECT
				DENSE_RANK() OVER( ORDER BY SUM(total_spend) DESC) AS rank_cust,
				c.customer_id AS customer,   
				COUNT(DISTINCT ot.order_id) AS orders,
				SUM(ot.total_spend) AS revenue
				FROM customers AS c
				JOIN orders AS o
				ON c.customer_id = o.customer_id
				JOIN order_items AS ot
				ON o.order_id = ot.order_id
				GROUP BY customer
				ORDER BY revenue DESC
			)
	SELECT *
    FROM cust
    WHERE revenue < (
						SELECT 
                        AVG(revenue)
                        FROM cust
					);
			
# Insights:-
# This shows that there are 145 those customers who has spended below average.
# It indicates there is need to attract those customers by attractive offers.
