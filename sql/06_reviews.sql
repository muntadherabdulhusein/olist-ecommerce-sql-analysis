-- =====================================================
-- 06. Reviews
-- Question: Do late deliveries lead to worse reviews?
-- Bad review = score 1 or 2.
-- =====================================================

-- 6.1 Review score: late vs on-time orders
SELECT
    CASE o.is_late WHEN 1 THEN 'late' ELSE 'on time' END AS delivery,
    COUNT(*)                                             AS orders,
    ROUND(AVG(r.review_score), 2)                        AS avg_score,
    ROUND(
        100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                    AS bad_review_pct
FROM v_orders AS o
JOIN v_reviews AS r
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.is_late IS NOT NULL
GROUP BY delivery;


-- 6.2 Review score by how many days late
WITH late_days AS (
    SELECT
        o.order_id,
        JULIANDAY(DATE(o.delivered_date))
      - JULIANDAY(DATE(o.estimated_date)) AS days_late
    FROM v_orders AS o
    WHERE o.order_status = 'delivered'
      AND o.delivered_date IS NOT NULL
)
SELECT
    CASE
        WHEN days_late <= 0  THEN '1. on time'
        WHEN days_late <= 3  THEN '2. 1-3 days late'
        WHEN days_late <= 7  THEN '3. 4-7 days late'
        ELSE                      '4. over 1 week late'
    END                           AS lateness,
    COUNT(*)                      AS orders,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM late_days AS l
JOIN v_reviews AS r
    ON r.order_id = l.order_id
GROUP BY lateness
ORDER BY lateness;


-- 6.3 Score distribution (1 to 5 stars)
SELECT
    CAST(review_score AS INTEGER)                      AS stars,
    COUNT(*)                                           AS reviews,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct
FROM olist_order_reviews_dataset
GROUP BY stars
ORDER BY stars;
