-- =====================================================
-- 05. Delivery performance
-- Question: How fast are deliveries, and where are
-- orders late most often?
-- Late = delivered after the estimated delivery date.
-- =====================================================

-- 5.1 Overall delivery time and late rate
SELECT
    COUNT(*)                         AS delivered_orders,
    ROUND(AVG(delivery_days), 1)     AS avg_delivery_days,
    SUM(is_late)                     AS late_orders,
    ROUND(100.0 * SUM(is_late) / COUNT(*), 1) AS late_pct
FROM v_orders
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL;


-- 5.2 Late rate and delivery time by state
--     (states with at least 500 delivered orders)
SELECT
    customer_state,
    COUNT(*)                         AS delivered_orders,
    ROUND(AVG(delivery_days), 1)     AS avg_delivery_days,
    ROUND(100.0 * SUM(is_late) / COUNT(*), 1) AS late_pct
FROM v_orders
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL
GROUP BY customer_state
HAVING COUNT(*) >= 500
ORDER BY late_pct DESC;


-- 5.3 Late rate per month: is it getting better?
SELECT
    purchase_month,
    COUNT(*)                         AS delivered_orders,
    ROUND(AVG(delivery_days), 1)     AS avg_delivery_days,
    ROUND(100.0 * SUM(is_late) / COUNT(*), 1) AS late_pct
FROM v_orders
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL
GROUP BY purchase_month
HAVING COUNT(*) >= 100
ORDER BY purchase_month;


-- 5.4 Delivery time buckets
SELECT
    CASE
        WHEN delivery_days <= 7  THEN '1. up to 1 week'
        WHEN delivery_days <= 14 THEN '2. 1-2 weeks'
        WHEN delivery_days <= 21 THEN '3. 2-3 weeks'
        WHEN delivery_days <= 30 THEN '4. 3-4 weeks'
        ELSE                          '5. over 4 weeks'
    END                               AS delivery_time,
    COUNT(*)                          AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct
FROM v_orders
WHERE order_status = 'delivered'
  AND delivery_days IS NOT NULL
GROUP BY delivery_time
ORDER BY delivery_time;
