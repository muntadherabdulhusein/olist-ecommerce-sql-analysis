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

**Top categories.** Health & beauty and watches & gifts lead revenue.
Watches & gifts sells fewer items but at a much higher price (199 BRL on average).

| Rank | Category | Items sold | Revenue (BRL) | Avg price | Share |
|---|---|---|---|---|---|
| 1 | health_beauty | 9,465 | 1,233,132 | 130 | 9.3% |
| 2 | watches_gifts | 5,859 | 1,166,177 | 199 | 8.8% |
| 3 | bed_bath_table | 10,953 | 1,023,435 | 93 | 7.7% |
| 4 | sports_leisure | 8,431 | 954,853 | 113 | 7.2% |
| 5 | computers_accessories | 7,644 | 888,725 | 116 | 6.7% |

The top 10 categories bring 62% of revenue.

**80/20 rule.** 17 of 74 categories (23%) make 80% of revenue.

**Freight cost.** For some categories shipping is a large part of the price:

| Category | Avg price | Avg freight | Freight as % of price |
|---|---|---|---|
| electronics | 58 | 17 | 29% |
| furniture_living_room | 137 | 36 | 26% |
| office_furniture | 162 | 41 | 25% |
| food | 58 | 14 | 25% |
| furniture_decor | 88 | 21 | 24% |

Cheap items (electronics, food) and bulky items (furniture) pay the most freight relative to their price.

### 5. Delivery performance

**Overall.** An order takes **12.6 days** on average to reach the customer.
6.8% of delivered orders (6,534) arrived after the estimated date.

| Delivery time | Orders | Share |
|---|---|---|
| up to 1 week | 26,575 | 27.5% |
| 1–2 weeks | 39,964 | 41.4% |
| 2–3 weeks | 17,542 | 18.2% |
| 3–4 weeks | 7,865 | 8.2% |
| over 4 weeks | 4,524 | 4.7% |

69% of orders arrive within two weeks, but 13% take more than three weeks.

**By state.** Distance from São Paulo, where most sellers are, drives delays.
The north-east is slowest and most often late. Rio de Janeiro stands out: it is the second-largest market, yet 12% of its orders are late.

| State | Orders | Avg days | Late |
|---|---|---|---|
| MA | 717 | 21.6 | 17.4% |
| CE | 1,279 | 21.3 | 13.8% |
| BA | 3,256 | 19.3 | 12.2% |
| RJ | 12,350 | 15.3 | 12.1% |
| … | | | |
| MG | 11,354 | 12.0 | 4.6% |
| SP | 40,494 | 8.8 | 4.5% |
| PR | 4,923 | 12.0 | 4.0% |

**Over time.** Peaks in demand break the delivery network:

| Month | Orders | Avg days | Late |
|---|---|---|---|
| 2017-10 | 4,478 | 11.9 | 4.2% |
| 2017-11 (Black Friday) | 7,288 | 15.2 | 12.4% |
| 2018-02 | 6,555 | 16.9 | 14.1% |
| 2018-03 | 7,003 | 16.3 | **19.0%** |
| 2018-06 | 6,096 | 9.2 | 1.2% |
| 2018-08 | 6,351 | 7.7 | 6.2% |

Late deliveries tripled during Black Friday 2017 and reached 19% in March 2018.
From April 2018 delivery recovered strongly: by August 2018 the average was 7.7 days, the fastest in the data.

### 6. Reviews

**Late delivery is the main driver of bad reviews.**

| Delivery | Orders | Avg score | Bad reviews (1–2 ★) |
|---|---|---|---|
| on time | 89,443 | 4.29 | 9.2% |
| late | 6,381 | **2.27** | **62.4%** |

A late order is almost **7 times** more likely to get a bad review.
The score drops with every extra day of delay:

| Lateness | Orders | Avg score |
|---|---|---|
| on time | 89,443 | 4.29 |
| 1–3 days late | 1,852 | 3.29 |
| 4–7 days late | 1,748 | 2.11 |
| over 1 week late | 2,781 | 1.70 |

**Overall satisfaction** is good: 77% of reviews are 4 or 5 stars, 15% are 1 or 2 stars.

| Stars | Reviews | Share |
|---|---|---|
| 5 | 57,328 | 57.8% |
| 4 | 19,142 | 19.3% |
| 3 | 8,179 | 8.2% |
| 2 | 3,151 | 3.2% |
| 1 | 11,424 | 11.5% |

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
