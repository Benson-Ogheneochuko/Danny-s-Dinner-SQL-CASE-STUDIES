/*markdown
How many pizzas were ordered?
*/

SELECT COUNT(pizza_id) AS pizzas_ordered FROM customer_orders

/*markdown
How many unique customer orders were made?
*/

SELECT COUNT(DISTINCT order_id) AS unique_orders FROM customer_orders;

/*markdown
How many successful orders were delivered by each runner?
*/

SELECT COUNT(DISTINCT order_id)
FROM runner_orders
WHERE cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation' );

SELECT COUNT(DISTINCT order_id) completed_deliveries
FROM runner_orders
WHERE cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
OR cancellation IS NULL;

/*markdown
How many of each type of pizza was delivered?
*/

SELECT * FROM runner_orders LIMIT 2;

SELECT pizza_id, COUNT(pizza_id) AS number_delivered
FROM
    customer_orders AS c
    JOIN runner_orders r ON c.order_id = r.order_id
WHERE
    r.cancellation NOT IN(
        'Restaurant Cancellation', 'Customer Cancellation'
    )
    OR r.cancellation IS NULL
GROUP BY
    pizza_id;

/*markdown
How many Vegetarian and Meatlovers were ordered by each customer?
*/

SELECT 
    customer_id,
    SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
    SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM 
    customer_orders
GROUP BY 
    customer_id
ORDER BY 
    customer_id;


/*markdown
What was the maximum number of pizzas delivered in a single order?
*/

SELECT c.order_id, COUNT(c.pizza_id) AS max_pizzas_ordered
FROM
    customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
WHERE
    r.cancellation NOT IN(
        'Restaurant Cancellation', 'Customer Cancellation'
    )
    OR r.cancellation IS NULL
GROUP BY
    order_id
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;

/*markdown
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
*/

SELECT
    customer_id,
    SUM(
        CASE
            WHEN (
                exclusions LIKE '%null%'
                OR exclusions IS NULL
                OR exclusions = ''
            )
            AND (
                extras LIKE '%null%'
                OR extras IS NULL
                OR extras = ''
            ) THEN 1
            ELSE 0
        END
    ) AS no_change,
    SUM(
        CASE
            WHEN (
                exclusions IS NOT NULL
                AND exclusions != ''
                AND exclusions NOT LIKE '%null%'
            )
            OR (
                extras IS NOT NULL
                AND extras != ''
                AND extras NOT LIKE '%null%'
            ) THEN 1
            ELSE 0
        END
    ) AS had_change
FROM customer_orders AS c
    JOIN runner_orders r ON c.order_id = r.order_id
WHERE
    r.cancellation NOT IN(
        'Restaurant Cancellation', 'Customer Cancellation'
    )

GROUP BY
    customer_id;

/*markdown
How many pizzas were delivered that had both exclusions and extras?
*/

SELECT COUNT(pizza_id) AS had_exclusions_and_extras
FROM customer_orders
WHERE (
        exclusions IS NOT NULL
        AND exclusions != ''
        AND exclusions NOT LIKE '%null%'
    )
    AND (
        extras IS NOT NULL
        AND extras != ''
        AND extras NOT LIKE '%null%'
    );

SELECT customer_id, order_id, exclusions, extras, COUNT(pizza_id)
FROM customer_orders
WHERE (
        exclusions IS NOT NULL
        AND exclusions != ''
        AND exclusions NOT LIKE '%null%'
    )
    AND (
        extras IS NOT NULL
        AND extras != ''
        AND extras NOT LIKE '%null%'
    )
GROUP BY customer_id, order_id, exclusions, extras;

/*markdown
What was the total volume of pizzas ordered for each hour of the day?
*/

SELECT EXTRACT(HOUR FROM order_time) AS hour, COUNT(pizza_id) AS sales_volume
FROM customer_orders
GROUP BY hour
ORDER BY hour;

/*markdown
What was the volume of orders for each day of the week?
*/

SELECT DAYNAME(order_time) AS week_day, COUNT(pizza_id) AS sales_volume
FROM customer_orders
GROUP BY week_day
ORDER BY sales_volume DESC;