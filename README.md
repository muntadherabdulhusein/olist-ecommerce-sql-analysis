# Olist E-commerce Analysis (SQL + Power BI)

Analysis of about 100,000 real orders from Olist, a Brazilian online marketplace (2016–2018).

## Business questions

1. Who are the best customers, and where do they live?
2. Which product categories bring the most revenue?
3. How long does delivery take, and which orders arrive late?
4. Do late deliveries lead to lower review scores?
5. Which sellers perform best and worst?

## Data

- Source: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 9 tables: customers, orders, order items, payments, reviews, products, sellers, geolocation, category names
- The data files are not stored in this repository. Download them from Kaggle and unzip them into a `data/` folder.

## Tools

- SQL (SQLite, DB Browser for SQLite)
- Power BI

## Method

_In progress._

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

Query: [`sql/00_explore.sql`](sql/00_explore.sql)

## Recommendations

_In progress._

## Repository structure

```
data/   raw CSV files (not uploaded)
sql/    SQL queries, one file per question
```

## Author

Muntadher Abdulhusein · [LinkedIn](https://www.linkedin.com/in/muntadher-abdulhusein)
