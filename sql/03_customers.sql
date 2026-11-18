-- =====================================================
-- 03. Customers
-- Question: Who are the customers, where do they live,
-- and do they come back?
-- =====================================================

-- 3.1 Top 10 states by revenue
SELECT
    o.customer_state,
    COUNT(DISTINCT o.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id)           AS orders,
    ROUND(SUM(i.price), 0)               AS revenue
FROM v_orders AS o
JOIN v_items AS i
    ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.customer_state
ORDER BY revenue DESC
LIMIT 10;


-- 3.2 Top 10 cities by number of customers
SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM v_orders
WHERE order_status = 'delivered'
GROUP BY customer_city, customer_state
ORDER BY customers DESC
LIMIT 10;


-- 3.3 Repeat customers: how many customers ordered
--     more than once?
WITH orders_per_customer AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM v_orders
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) AS customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
              / COUNT(*), 1
    ) AS repeat_pct
FROM orders_per_customer;


-- 3.4 Customer segments by total spend
WITH spend AS (
    SELECT
        o.customer_unique_id,
        SUM(i.price) AS total_spend
    FROM v_orders AS o
    JOIN v_items AS i
        ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_unique_id
)
SELECT
    CASE
        WHEN total_spend < 50   THEN '1. under 50'
        WHEN total_spend < 100  THEN '2. 50-99'
        WHEN total_spend < 200  THEN '3. 100-199'
        WHEN total_spend < 500  THEN '4. 200-499'
        ELSE                         '5. 500+'
    END                       AS spend_group,
    COUNT(*)                  AS customers,
    ROUND(SUM(total_spend), 0) AS revenue
FROM spend
GROUP BY spend_group
ORDER BY spend_group;
