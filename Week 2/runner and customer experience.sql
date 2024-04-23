-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT * FROM runners;

SELECT EXTRACT(
        WEEK
        FROM registration_date
    ) AS week, COUNT(runner_id) registered_runners
FROM runners
GROUP BY
    week;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- pickup_time, distance, duration.
SELECT r.runner_id, AVG(
        TIMESTAMPDIFF(
            MINUTE, c.order_time, r.pickup_time
        )
    ) AS avg_time_to_arrive
FROM
    customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
WHERE
    r.pickup_time IS NOT NULL
GROUP BY
    r.runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT c.order_id, COUNT(c.pizza_id) AS num_pizzas, TIMESTAMPDIFF(
        MINUTE, c.order_time, r.pickup_time
    ) AS t_preparation
FROM
    customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
GROUP BY
    c.order_id,
    t_preparation
ORDER BY t_preparation DESC;

-- What was the average distance travelled for each customer?
SELECT c.customer_id, COUNT(c.order_id) AS orders, ROUND(AVG(r.distance), 2) AS avg_distance
FROM
    customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
GROUP BY
    c.customer_id
ORDER BY avg_distance DESC;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(
        CASE
            WHEN duration LIKE '% minutes' THEN CAST(
                SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED
            )
            ELSE CAST(duration AS UNSIGNED)
        END
    ) - MIN(
        CASE
            WHEN duration LIKE '% minutes' THEN CAST(
                SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED
            )
            ELSE CAST(duration AS UNSIGNED)
        END
    ) AS duration_range_in_minutes
FROM runner_orders;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id, ROUND(
        AVG(
            CAST(
                REGEXP_REPLACE(distance, '[^0-9.]+', '') AS DECIMAL(10, 2)
            ) / CAST(
                REGEXP_REPLACE(duration, '[^0-9.]+', '') AS DECIMAL(10, 2)
            )
        ), 2
    ) AS avg_speed
FROM runner_orders
WHERE
    distance NOT LIKE '%null%'
    AND duration NOT LIKE '%null%'
GROUP BY
    runner_id,
    order_id
ORDER BY runner_id, avg_speed DESC;

-- What is the successful delivery percentage for each runner?
SELECT 
    runner_id,
    COUNT(order_id) AS total_orders,
    SUM(
        CASE
            WHEN cancellation LIKE '%cancellation%' THEN 1
            ELSE 0
        END
    ) AS orders_cancelled,
    ROUND((COUNT(order_id) - SUM(
            CASE
                WHEN cancellation LIKE '%cancellation%' THEN 1
                ELSE 0
            END
        )) / COUNT(order_id) * 100, 2) AS `%_delivery_success`
FROM 
    runner_orders
GROUP BY
    runner_id
ORDER BY 
    `%_delivery_success` DESC;
