-- =====================================================
-- 02. Sales overview
-- Question: How big is the business, and how did
-- sales grow over time?
-- Revenue = item price (freight excluded),
-- delivered orders only.
-- =====================================================

-- 2.1 Headline numbers
SELECT
    COUNT(DISTINCT o.order_id)                          AS orders,
    COUNT(DISTINCT o.customer_unique_id)                AS customers,
    ROUND(SUM(i.price), 0)                              AS revenue,
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM v_orders AS o
JOIN v_items AS i
    ON i.order_id = o.order_id
WHERE o.order_status = 'delivered';


-- 2.2 Revenue and orders per month,
--     with month-over-month growth (window function LAG)
WITH monthly AS (
    SELECT
        o.purchase_month,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(i.price), 0)     AS revenue
    FROM v_orders AS o
    JOIN v_items AS i
        ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.purchase_month
)
SELECT
    purchase_month,
    orders,
    revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY purchase_month))
              / LAG(revenue) OVER (ORDER BY purchase_month), 1
    ) AS growth_pct
FROM monthly
ORDER BY purchase_month;


-- 2.3 Revenue by weekday (0 = Sunday ... 6 = Saturday)
SELECT
    STRFTIME('%w', o.purchase_date) AS weekday,
    COUNT(DISTINCT o.order_id)      AS orders,
    ROUND(SUM(i.price), 0)          AS revenue
FROM v_orders AS o
JOIN v_items AS i
    ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY weekday
ORDER BY weekday;


-- 2.4 Payment methods
SELECT
    payment_type,
    COUNT(*)                                           AS payments,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct,
    ROUND(AVG(CAST(payment_value AS REAL)), 2)         AS avg_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY payments DESC;
