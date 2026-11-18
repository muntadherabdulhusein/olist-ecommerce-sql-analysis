-- =====================================================
-- 07. Sellers
-- Question: Which sellers perform best and worst?
-- Only sellers with at least 100 delivered orders.
-- =====================================================

-- 7.1 Seller scorecard (CTE)
WITH seller_stats AS (
    SELECT
        i.seller_id,
        s.seller_state,
        COUNT(DISTINCT i.order_id)                       AS orders,
        ROUND(SUM(i.price), 0)                           AS revenue,
        ROUND(AVG(r.review_score), 2)                    AS avg_score,
        ROUND(100.0 * AVG(o.is_late), 1)                 AS late_pct
    FROM v_items AS i
    JOIN v_orders AS o
        ON o.order_id = i.order_id
    JOIN olist_sellers_dataset AS s
        ON s.seller_id = i.seller_id
    LEFT JOIN v_reviews AS r
        ON r.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.seller_id, s.seller_state
    HAVING COUNT(DISTINCT i.order_id) >= 100
)
SELECT
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    seller_id,
    seller_state,
    orders,
    revenue,
    avg_score,
    late_pct
FROM seller_stats
ORDER BY revenue DESC
LIMIT 10;


-- 7.2 The 10 lowest-rated sellers (min. 100 orders)
WITH seller_stats AS (
    SELECT
        i.seller_id,
        COUNT(DISTINCT i.order_id)        AS orders,
        ROUND(AVG(r.review_score), 2)     AS avg_score,
        ROUND(100.0 * AVG(o.is_late), 1)  AS late_pct
    FROM v_items AS i
    JOIN v_orders AS o
        ON o.order_id = i.order_id
    LEFT JOIN v_reviews AS r
        ON r.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.seller_id
    HAVING COUNT(DISTINCT i.order_id) >= 100
)
SELECT *
FROM seller_stats
ORDER BY avg_score ASC
LIMIT 10;


-- 7.3 Revenue concentration: share of revenue
--     from the top 10% of sellers (NTILE window function)
WITH seller_revenue AS (
    SELECT
        i.seller_id,
        SUM(i.price) AS revenue
    FROM v_items AS i
    JOIN v_orders AS o
        ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.seller_id
),
ranked AS (
    SELECT
        seller_id,
        revenue,
        NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM seller_revenue
)
SELECT
    decile,
    COUNT(*)                                          AS sellers,
    ROUND(SUM(revenue), 0)                            AS revenue,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS share_pct
FROM ranked
GROUP BY decile
ORDER BY decile;
