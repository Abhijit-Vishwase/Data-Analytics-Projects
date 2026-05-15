CREATE DATABASE ecommerce_project; # created database

USE ecommerce_project;   

SELECT * FROM  customers;  # displayed table

ALTER TABLE customers                    #changed datatype of column
MODIFY COLUMN customer_id INT;

ALTER TABLE customers					# added primary key 
ADD PRIMARY KEY (customer_id);

ALTER TABLE customers						 #changed datatype of column
MODIFY COLUMN country VARCHAR(50);

SET SQL_SAFE_UPDATES = 0;                  	#turns off MySQL’s safe update mode 

UPDATE customers							
SET signup_date = STR_TO_DATE(signup_date, '%d-%m-%Y');

ALTER TABLE customers						 #changed datatype of column
MODIFY COLUMN signup_date DATE;

SELECT * FROM order_items;        # displayed table

ALTER TABLE order_items						 #changed datatype of column
MODIFY COLUMN order_id INT;

ALTER TABLE order_items					# added foreign key
ADD CONSTRAINT fk_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items					# added foreign key
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE order_items						 #changed datatype of column
MODIFY COLUMN price DECIMAL(10,2);

ALTER TABLE order_items						 #changed datatype of column
MODIFY COLUMN product_id INT;

ALTER TABLE order_items						 #changed datatype of column
MODIFY COLUMN quantity INT;

ALTER TABLE order_items						 #added new column
ADD COLUMN total_spend DECIMAL(10,2);

UPDATE order_items                        # added data in column
SET total_spend = quantity * price;

SELECT * FROM orders;           # displayed table

ALTER TABLE orders				 #changed datatype of column
MODIFY COLUMN order_id INT;

ALTER TABLE orders					# added primary key 
ADD PRIMARY KEY (order_id);

ALTER TABLE orders						# added foreign key
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE orders					 #changed datatype of column
MODIFY COLUMN customer_id INT;

ALTER TABLE orders						 #changed datatype of column
MODIFY COLUMN order_date DATE;

ALTER TABLE orders                     #changed datatype of column
MODIFY COLUMN status VARCHAR(20);

SELECT * FROM products;             # displayed table

ALTER TABLE products					 #changed datatype of column
MODIFY COLUMN product_id INT;

ALTER TABLE products					# added primary key 
ADD PRIMARY KEY (product_id);

ALTER TABLE products					 #changed datatype of column
MODIFY COLUMN product_name VARCHAR(20);

ALTER TABLE products					 #changed datatype of column
MODIFY COLUMN category VARCHAR(20);
