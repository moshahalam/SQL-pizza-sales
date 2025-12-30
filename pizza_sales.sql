-- Q1. Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- Q2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS total_sales
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;

-- Q3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_detail_id) AS total_orders
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY total_orders DESC
LIMIT 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- Q7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- Q8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_orders), 0)
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_orders
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS total_quantity;
    
    -- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS sale
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY sale DESC
LIMIT 3;

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.name AS pizza_name,
    ROUND(SUM(pizzas.price * order_details.quantity) / (SELECT 
            ROUND(SUM(pizzas.price * order_details.quantity),
                        2) AS total_sales
        FROM
            pizzas
                JOIN
            order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,2) AS percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY percentage DESC;

-- Q12. Analyze the cumulative revenue generated over time.

SELECT order_date, ROUND(SUM(revenue) OVER (ORDER BY order_date),2) AS cum_revenue
FROM
(SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date) AS sales;

-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue, rnk
FROM
(SELECT category, name, revenue, RANK() OVER(PARTITION BY category ORDER BY revenue) AS rnk
FROM
(SELECT pizza_types.category, pizza_types.name, ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS table_a) AS table_b
WHERE rnk<4;

