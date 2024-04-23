/* --------------------
Week 1 - Case Study Questions
--------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
SELECT
    s.customer_id,
    sum(m.price)
FROM
    sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY
    s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
    COUNT(DISTINCT (order_date)) AS "# days customer visited"
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH first_pruchase AS (
    SELECT s.customer_id AS customer,
        m.product_name product,
        MIN(s.order_date) AS order_date,
        ROW_NUMBER() OVER(
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS rn
    FROM sales s
        LEFT JOIN menu m ON m.product_id = s.product_id
    GROUP BY customer_id, m.product_name, s.order_date
)
SELECT customer,
    product,
    order_date
FROM first_pruchase
WHERE rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT s.product_id, m.product_name, COUNT(s.product_id)
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY S.product_id, m.product_id
ORDER BY COUNT(S.product_id) DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?
WITH most_popular AS (
    SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS most_purchased,
    ROW_NUMBER() OVER(
        PARTITION BY s.customer_id 
        ORDER BY COUNT(s.product_id) DESC 
    ) AS rn
    FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, most_purchased
FROM most_popular
WHERE rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT customer_id,
    product_name,
    order_date
FROM (
        SELECT s.customer_id,
            MIN(s.order_date) AS order_date,
            m.product_name,
            ROW_NUMBER() OVER(
                PARTITION BY s.customer_id
                ORDER BY MIN(s.order_date) ASC
            ) AS rn
        FROM sales s
            LEFT JOIN members mb ON s.customer_id = mb.customer_id
            LEFT JOIN menu m ON m.product_id = s.product_id
        WHERE s.order_date >= mb.join_date
        GROUP BY s.customer_id,
            m.product_name
    ) AS sq
WHERE rn = 1;


-- 7. Which item was purchased just before the customer became a member?
SELECT customer_id,
    product_name,
    order_date
FROM (
        SELECT s.customer_id,
            MAX(s.order_date) AS order_date,
            m.product_name,
            ROW_NUMBER() OVER(
                PARTITION BY s.customer_id
                ORDER BY MAX(s.order_date) DESC
            ) AS rn
        FROM sales s
            LEFT JOIN members mb ON s.customer_id = mb.customer_id
            LEFT JOIN menu m ON m.product_id = s.product_id
        WHERE s.order_date < mb.join_date
        GROUP BY s.customer_id,
            m.product_name
    ) AS sq
WHERE rn = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
    items_bought.items_bought,
    amt_spent.amt_spent
FROM sales s
    LEFT JOIN (
        SELECT s.customer_id,
            COUNT(s.product_id) AS items_bought
        FROM sales S
        LEFT JOIN members mb ON mb.customer_id = s.customer_id
        WHERE s.order_date < mb.join_date
        GROUP BY s.customer_id
    ) AS items_bought ON items_bought.customer_id = s.customer_id
    LEFT JOIN (
        SELECT s.customer_id,
            sum(m.price) AS amt_spent
        FROM sales S
            LEFT JOIN menu m ON s.product_id = m.product_id
            LEFT JOIN members mb ON mb.customer_id = s.customer_id
        WHERE s.order_date < mb.join_date
        GROUP BY s.customer_id
    ) AS amt_spent ON amt_spent.customer_id = s.customer_id
GROUP BY s.customer_id, items_bought, amt_spent;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH customer_points AS (
    SELECT s.customer_id,
        m.product_name,
        s.product_id,
        m.price,
        CASE
            WHEN LOWER(m.product_name) = 'sushi' THEN 2 * (m.price * 10)
            ELSE 10 * m.price
        END AS points
    FROM sales s
        LEFT JOIN menu m ON s.product_id = m.product_id
    ORDER BY m.product_name
)
SELECT customer_id,
    SUM(points) AS total_points
FROM customer_points
GROUP BY customer_id;
/* --------------------
 -- 10. In the first week after a customer joins the program (including their join date) 
 they earn 2x points on all items, not just sushi 
 how many points do customer A and B have at the end of January?
 --------------------*/
WITH jan_points AS (
    SELECT s.customer_id,
        s.order_date,
        CASE
            WHEN (s.order_date - mb.join_date) >= 0
            AND (s.order_date - mb.join_date) <= 7 THEN 2 * (m.price * 10)
            WHEN LOWER(m.product_name) = 'sushi' THEN 2 * (m.price * 10)
            ELSE 10 * m.price
        END AS points
    FROM sales s
        JOIN members mb ON s.customer_id = mb.customer_id
        JOIN menu m ON s.product_id = m.product_id
    WHERE EXTRACT(
            MONTH
            FROM s.order_date
        ) = 1
)
SELECT customer_id,
    SUM(points) AS "January_points"
FROM jan_points
GROUP BY customer_id;

