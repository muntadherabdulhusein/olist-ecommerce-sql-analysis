# Olist E-commerce Analysis (SQL + Power BI)

Analysis of about 100,000 real orders from Olist, a Brazilian online marketplace (2016–2018).
The goal: find what drives revenue, how well deliveries perform, and how delivery affects customer satisfaction.

## Business questions

1. How big is the business, and how did sales grow over time?
2. Who are the customers, where do they live, and do they come back?
3. Which product categories drive revenue?
4. How fast are deliveries, and where are orders late most often?
5. Do late deliveries lead to worse reviews?
6. Which sellers perform best and worst?

## Data

- Source: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 9 tables: customers, orders, order items, payments, reviews, products, sellers, geolocation, category names
- The data files are not stored in this repository (see *How to reproduce*).

## Tools

- SQL (SQLite, DB Browser for SQLite)
- Power BI (dashboard, in progress)

## Method

1. **Data check** (`00_explore.sql`): row counts and order status.
2. **Cleaning with views** (`01_create_views.sql`):
   - empty date strings turned into `NULL`
   - prices cast to numbers
   - Portuguese category names translated to English
   - delivery time in days and a late-delivery flag calculated once
3. **Analysis** (`02`–`07`): one SQL file per business question.

Definitions:
- **Revenue** = item price, delivered orders only (freight excluded).
- **Late** = delivered after the estimated delivery date.
- **Customer** = `customer_unique_id` (one person can have several `customer_id`s).
- **Bad review** = score 1 or 2.

SQL techniques used: `JOIN`, `LEFT JOIN`, `GROUP BY` / `HAVING`, `CASE WHEN`, `COALESCE`, `NULLIF`, date functions, views, CTEs (`WITH`), window functions (`LAG`, `RANK`, `NTILE`, `SUM() OVER`).

## Findings

### 1. Order status

97% of all orders (96,478 of 99,441) were delivered.
Only 625 orders (0.6%) were canceled.
The other 3% are still shipped, unavailable, invoiced or processing.

| Status | Orders |
|---|---|
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

### 2. Sales overview

_In progress._

### 3. Customers

_In progress._

### 4. Products

_In progress._

### 5. Delivery performance

_In progress._

### 6. Reviews

_In progress._

### 7. Sellers

_In progress._

## Recommendations

_In progress._

## Repository structure

```
sql/
  00_explore.sql          first look at the data
  01_create_views.sql     cleaning views (run first)
  02_sales_overview.sql   revenue, growth, payments
  03_customers.sql        states, cities, repeat customers
  04_products.sql         categories, 80/20, freight
  05_delivery.sql         delivery time, late rate
  06_reviews.sql          late delivery vs review score
  07_sellers.sql          seller scorecard
data/                     raw CSV files (not uploaded)
```

## How to reproduce

1. Download the dataset from Kaggle and unzip it into `data/`.
2. In DB Browser for SQLite: create `olist.db`, then *File → Import → Table from CSV file*, select all 9 files, tick *Separate tables*.
3. Run `sql/01_create_views.sql` and click *Write Changes*.
4. Run the other files in order.

## Author

Muntadher Abdulhusein · [LinkedIn](https://www.linkedin.com/in/muntadher-abdulhusein)
