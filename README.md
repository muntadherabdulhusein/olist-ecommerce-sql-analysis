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

| Metric (delivered orders) | Value |
|---|---|
| Orders | 96,478 |
| Customers | 93,358 |
| Revenue | 13.2 M BRL |
| Average order value | 137 BRL |

**Growth.** 2016 holds only a handful of orders (test period), so the analysis starts in January 2017.
Revenue grew fast during 2017: January to August 2018 brought 7.22 M BRL, against 2.99 M BRL in the same months of 2017 (**+141%**).

**Peak.** November 2017 (Black Friday) is the best month in the data: 7,289 orders, +52% on October.

**Plateau.** In 2018 monthly revenue stayed flat between 0.83 M and 0.98 M BRL. Growth has stopped.

| Month | Orders | Revenue (BRL) |
|---|---|---|
| 2017-01 | 750 | 111,798 |
| 2017-06 | 3,135 | 421,923 |
| 2017-11 | 7,289 | 987,765 |
| 2018-01 | 7,069 | 924,645 |
| 2018-05 | 6,749 | 977,545 |
| 2018-08 | 6,351 | 838,577 |

**Weekdays.** Monday is the busiest day (15,701 orders). Saturday is the quietest (10,555), about a third lower.

**Payments.** Credit card is used for 74% of payments, boleto (Brazilian bank slip) for 19%, vouchers for 6%.

### 3. Customers

**Location.** São Paulo state (SP) alone brings 38% of revenue and 42% of orders.
The top 3 states (SP, RJ, MG) bring 63% of revenue.

| State | Customers | Orders | Revenue (BRL) |
|---|---|---|---|
| SP | 39,156 | 40,501 | 5,067,633 |
| RJ | 11,917 | 12,350 | 1,759,651 |
| MG | 11,001 | 11,354 | 1,552,482 |
| RS | 5,168 | 5,345 | 728,897 |
| PR | 4,769 | 4,923 | 666,064 |

Top cities: São Paulo (14,528 customers), Rio de Janeiro (6,361), Belo Horizonte (2,606), Brasília (2,013).

**Loyalty.** Only **3%** of customers (2,801 of 93,358) ordered more than once.
Almost all revenue comes from first-time buyers.

**Spend.** A small group of high spenders carries the business:

| Total spend (BRL) | Customers | Revenue (BRL) |
|---|---|---|
| under 50 | 27,054 | 862,728 |
| 50–99 | 26,412 | 1,993,030 |
| 100–199 | 24,804 | 3,567,009 |
| 200–499 | 11,454 | 3,423,611 |
| 500+ | 3,634 | 3,375,121 |

Customers who spent 200 BRL or more are 16% of all customers but bring 51% of revenue.
The 500+ group alone (4% of customers) brings 26%.

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
