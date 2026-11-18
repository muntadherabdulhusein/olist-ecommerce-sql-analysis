-- =====================================================
-- 01. Clean views
-- Run this file FIRST, then click "Write Changes".
-- The views clean the raw tables once, so every later
-- query can stay short and readable.
-- =====================================================

DROP VIEW IF EXISTS v_orders;
DROP VIEW IF EXISTS v_items;
DROP VIEW IF EXISTS v_reviews;

-- -----------------------------------------------------
-- v_orders: one row per order, with customer location,
-- delivery time in days and a late-delivery flag.
-- Empty strings in date columns are turned into NULL.
-- -----------------------------------------------------
CREATE VIEW v_orders AS
SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    DATE(o.order_purchase_timestamp)              AS purchase_date,
    STRFTIME('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
    NULLIF(o.order_delivered_customer_date, '')   AS delivered_date,
    NULLIF(o.order_estimated_delivery_date, '')   AS estimated_date,
    ROUND(
        JULIANDAY(NULLIF(o.order_delivered_customer_date, ''))
      - JULIANDAY(o.order_purchase_timestamp), 1
    )                                             AS delivery_days,
    CASE
        WHEN NULLIF(o.order_delivered_customer_date, '') IS NULL THEN NULL
        WHEN DATE(o.order_delivered_customer_date)
           > DATE(o.order_estimated_delivery_date)               THEN 1
        ELSE 0
    END                                           AS is_late
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON c.customer_id = o.customer_id;

-- -----------------------------------------------------
-- v_items: one row per item sold, with numeric price,
-- freight and the English category name.
-- -----------------------------------------------------
CREATE VIEW v_items AS
SELECT
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    CAST(i.price AS REAL)         AS price,
    CAST(i.freight_value AS REAL) AS freight,
    COALESCE(
        t.product_category_name_english,
        NULLIF(p.product_category_name, ''),
        'unknown'
    )                             AS category
FROM olist_order_items_dataset AS i
LEFT JOIN olist_products_dataset AS p
    ON p.product_id = i.product_id
LEFT JOIN product_category_name_translation AS t
    ON t.product_category_name = p.product_category_name;

-- -----------------------------------------------------
-- v_reviews: one row per order with its average score.
-- (A few orders have more than one review.)
-- -----------------------------------------------------
CREATE VIEW v_reviews AS
SELECT
    order_id,
    AVG(CAST(review_score AS REAL)) AS review_score
FROM olist_order_reviews_dataset
GROUP BY order_id;

-- Quick check: each line should return a number > 0
SELECT 'v_orders'  AS view_name, COUNT(*) AS row_count FROM v_orders
UNION ALL
SELECT 'v_items',   COUNT(*) FROM v_items
UNION ALL
SELECT 'v_reviews', COUNT(*) FROM v_reviews;
