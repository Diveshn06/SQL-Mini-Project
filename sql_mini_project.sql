-- SQL Mini Project - Queries
-- Organized from PDF into SQL file format

-- ===============================
-- Level 1: Basics
-- ===============================

-- 1. Retrieve customer names and emails for email marketing
SELECT name, email FROM customers;

-- 2. View complete product catalog with all available details
SELECT * FROM products;

-- 3. List all unique product categories
SELECT DISTINCT category FROM products;

-- 4. Show all products priced above ₹1,000
SELECT name, price FROM products WHERE price > 1000 ORDER BY price;

-- 5. Display products within a mid-range price bracket (₹2,000 to ₹5,000)
SELECT name, price FROM products WHERE price BETWEEN 2000 AND 5000 ORDER BY price;

-- 6. Fetch data for specific customer IDs (e.g., from loyalty program list)
SELECT * FROM customers WHERE customer_id IN (1,2,3);

-- 7. Identify customers whose names start with the letter 'A'
SELECT * FROM customers WHERE name LIKE 'A%';

-- 8. List electronics products priced under ₹3,000
SELECT category, price FROM products WHERE category='Electronics' AND price < 3000 ORDER BY price DESC;

-- 9. Display product names and prices in descending order of price
SELECT name, price FROM products ORDER BY price DESC;

-- 10. Display product names and prices, sorted by price and then by name
SELECT name, price FROM products ORDER BY price, name;


-- ===============================
-- Level 2: Filtering and Formatting
-- ===============================

-- 1. Retrieve orders where customer information is missing
SELECT  
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_values_customer_id,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS null_values_name,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_values_email,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS null_values_phone,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_values_created_at,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_values_order_date,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS null_values_status,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS null_values_total_amount
FROM (
    SELECT c.customer_id, c.name, c.email, c.phone, c.created_at, 
           od.order_id, od.order_date, od.status, od.total_amount
    FROM orders AS od 
    LEFT JOIN customers AS c ON od.customer_id = c.customer_id
) AS X;

-- 2. Display customer names and emails using column aliases
SELECT name AS customer_name, email AS customer_email FROM customers;

-- 3. Calculate total value per item ordered
SELECT p.name, (o.quantity * o.item_price) AS total_value
FROM order_items AS o
JOIN products AS p ON p.product_id = o.product_id
ORDER BY total_value;

-- 4. Combine customer name and phone number in a single column
SELECT CONCAT(name,' - ',phone) AS customer_contact FROM customers;

-- 5. Extract only the date part from order timestamps
SELECT order_id, DATE(order_date) AS order_date_only FROM orders;

-- 6. List products that do not have any stock left
SELECT name, category, stock_quantity
FROM products
WHERE stock_quantity IS NULL;


-- ===============================
-- Level 3: Aggregations
-- ===============================

-- 1. Count the total number of orders placed
SELECT COUNT(*) AS total_orders FROM orders;

-- 2. Calculate the total revenue collected from all orders
SELECT SUM(quantity * item_price) AS total_revenue FROM order_items;
-- OR
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- 3. Calculate the average order value
SELECT ROUND(AVG(total_amount),2) AS average_total FROM orders;

-- 4. Count the number of customers who have placed at least one order
SELECT COUNT(DISTINCT(customer_id)) AS customers_with_orders FROM customers;

-- 5. Find the number of orders placed by each customer
SELECT c.name, COUNT(od.order_id) AS total_orders
FROM customers AS c 
JOIN orders AS od ON od.customer_id = c.customer_id
GROUP BY c.name
ORDER BY total_orders DESC;

-- 6. Find total sales amount made by each customer
SELECT c.name, SUM(od.total_amount) AS total_sales
FROM customers AS c 
JOIN orders AS od ON od.customer_id = c.customer_id
GROUP BY c.name
ORDER BY total_sales DESC;

-- 7. List the number of products sold per category
SELECT category, COUNT(product_id) AS total_no_of_products
FROM products 
GROUP BY category
ORDER BY total_no_of_products DESC;

-- 8. Find the average item price per category
SELECT category, ROUND(AVG(price),2) AS avg_price
FROM products
GROUP BY category
ORDER BY avg_price DESC;

-- 9. Show number of orders placed per day
SELECT DATE(order_date) AS order_day, COUNT(order_id) AS total_orders
FROM orders 
GROUP BY DATE(order_date)
ORDER BY order_day;

-- 10. List total payments received per payment method
SELECT method, SUM(amount_paid) AS total_payment
FROM payments
GROUP BY method
ORDER BY total_payment DESC;


-- ===============================
-- Level 4: Multi-Table Queries
-- ===============================

-- 1. Retrieve order details along with the customer name
SELECT c.name AS customer_name, od.*
FROM customers AS c 
INNER JOIN orders AS od ON od.customer_id = c.customer_id;

-- 2. Get list of products that have been sold
SELECT DISTINCT(p.product_id), p.name AS product_name, p.category, p.price
FROM products AS p
JOIN order_items AS o ON o.product_id = p.product_id;

-- 3. List all orders with their payment method
SELECT od.order_id, p.method
FROM orders AS od 
JOIN payments AS p ON p.order_id = od.order_id
ORDER BY od.order_id;

-- 4. Get list of customers and their orders
SELECT c.customer_id, c.name AS customer_name, od.order_id, od.order_date, od.status, od.total_amount
FROM customers as c 
LEFT JOIN orders AS od ON od.customer_id = c.customer_id
ORDER BY c.customer_id, od.order_date;

-- 5. List all products along with order item quantity
SELECT p.product_id, p.name AS product_name, o.quantity
FROM products AS p 
LEFT JOIN order_items AS o ON o.product_id = p.product_id;

-- 6. List all payments including those with no matching orders
SELECT od.order_id, od.order_date, od.status, od.total_amount, 
       p.payment_id, p.method, p.amount_paid
FROM orders AS od 
RIGHT JOIN payments AS p ON od.order_id = p.order_id
ORDER BY p.payment_id;

-- 7. Combine data from three tables: customer, order, and payment
SELECT *
FROM customers AS c 
JOIN orders AS od ON od.customer_id = c.customer_id
JOIN payments AS p ON p.order_id = od.order_id;


-- ===============================
-- Level 5: Subqueries
-- ===============================

-- 1. List all products priced above the average product price
SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 2. Find customers who have placed at least one order
-- Using window function
SELECT DISTINCT customer_id, name, email
FROM (
    SELECT c.customer_id, c.name, c.email, od.order_id, 
           ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY od.order_id) AS rk
    FROM customers AS c 
    LEFT JOIN orders AS od ON od.customer_id = c.customer_id
) AS x
WHERE rk = 1;

-- Using subquery
SELECT customer_id, name, email 
FROM customers 
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders);

-- 3. Show orders whose total amount is above the average for that customer
SELECT order_id, customer_id, total_amount
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY total_amount;

-- 4. Display customers who haven't placed any orders
SELECT c.customer_id, c.name  
FROM customers AS c 
JOIN orders AS od ON od.customer_id = c.customer_id
WHERE c.customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- 5. Show products that were never ordered
SELECT product_id, name, category
FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- 6. Show highest value order per customer
SELECT customer_id, order_id, name, total_amount, rk
FROM (
    SELECT c.customer_id, c.name, od.order_id, od.total_amount,
           ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY od.total_amount DESC) AS rk
    FROM customers AS c
    JOIN orders AS od ON od.customer_id = c.customer_id
) AS x
WHERE rk = 1
ORDER BY customer_id;

-- 7. Highest Order Per Customer (Including Names)
SELECT customer_id, order_id, name, total_amount
FROM (
    SELECT c.customer_id, c.name, od.order_id, od.total_amount,
           ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY od.total_amount DESC) AS rk
    FROM customers AS c
    JOIN orders AS od ON od.customer_id = c.customer_id
) AS x
WHERE rk = 1
ORDER BY customer_id;


-- ===============================
-- Level 6: Set Operations
-- ===============================

-- 1. List all customers who have either placed an order or written a product review
SELECT name, email
FROM customers 
WHERE customer_id IN (SELECT customer_id FROM orders)
UNION
SELECT name, email
FROM customers
WHERE customer_id IN (SELECT customer_id FROM product_reviews);

-- 2. List all customers who have placed an order as well as reviewed a product
SELECT name, email
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders)
  AND customer_id IN (SELECT customer_id FROM product_reviews);
