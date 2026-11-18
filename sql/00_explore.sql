-- 00. First look at the data
-- How many rows does each main table have?

SELECT COUNT(*) FROM olist_customers_dataset;

SELECT COUNT(*) FROM olist_orders_dataset;

SELECT COUNT(*) FROM olist_order_items_dataset;

-- How many orders per order status?

SELECT order_status, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY COUNT(*) DESC;
