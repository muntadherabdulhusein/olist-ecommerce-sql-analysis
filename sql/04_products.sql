-- =====================================================
-- 04. Products
-- Question: Which product categories drive revenue?
-- =====================================================

-- 4.1 Top 10 categories by revenue, with share of total
--     and rank (window functions)
WITH category_sales AS (
    SELECT
        i.category,
        COUNT(*)              AS items_sold,
        ROUND(SUM(i.price), 0) AS revenue,
        ROUND(AVG(i.price), 2) AS avg_price
    FROM v_items AS i
    JOIN v_orders AS o
        ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.category
)
SELECT
    RANK() OVER (ORDER BY revenue DESC)              AS rank,
    category,
    items_sold,
    revenue,
    avg_price,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 1) AS share_pct
FROM category_sales
ORDER BY revenue DESC
LIMIT 10;


-- 4.2 How many categories make up 80% of revenue?
--     (running total with a window function)
WITH category_sales AS (
    SELECT
        i.category,
        SUM(i.price) AS revenue
    FROM v_items AS i
    JOIN v_orders AS o
        ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.category
),
running AS (
    SELECT
        category,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC)
            * 100.0 / SUM(revenue) OVER () AS cumulative_pct
    FROM category_sales
)
SELECT
    COUNT(*)                         AS categories_for_80_pct,
    (SELECT COUNT(*) FROM category_sales) AS all_categories
FROM running
WHERE cumulative_pct <= 80;


-- 4.3 Categories with the highest freight cost
--     compared to price (min. 500 items sold)
SELECT
    i.category,
    COUNT(*)                                 AS items_sold,
    ROUND(AVG(i.price), 2)                   AS avg_price,
    ROUND(AVG(i.freight), 2)                 AS avg_freight,
    ROUND(100.0 * SUM(i.freight) / SUM(i.price), 1) AS freight_pct_of_price
FROM v_items AS i
GROUP BY i.category
HAVING COUNT(*) >= 500
ORDER BY freight_pct_of_price DESC
LIMIT 10;
