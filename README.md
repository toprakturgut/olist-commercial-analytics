# Olist Commercial Analytics (SQL + Looker Studio)

This project analyzes Olist’s Brazilian e-commerce dataset and delivers a single-source-of-truth reporting layer (SQL) and an interactive BI dashboard. It focuses on commercial performance (revenue/orders/AOV), logistics (delivery time & late delivery), and customer experience (review score), with filters by date, category, state, and payment type.

## Links
- **Dashboard:** https://lookerstudio.google.com/u/0/reporting/6392cf2a-82f2-4b01-838c-7f44f55fc574/page/uADhF
- **SQL (master query):** [`master_query.sql`](./master_query.sql)
- **Dataset:** Olist Brazilian E-Commerce Public Dataset (Kaggle)

## Business Questions
- How are **revenue and orders** trending over time?
- Which **product categories** drive the most revenue?
- How is revenue distributed across **Brazilian states**?
- What is the **late delivery rate**, and how does it relate to **review scores**?
- What is the **payment mix** (credit card / boleto / etc.)?

## KPI Definitions (high-level)
- **Revenue:** sum of item prices (or price + freight, depending on definition)
- **Orders:** distinct order_id
- **AOV:** revenue / orders
- **Delivery time (days):** delivered_date - purchase_date
- **Late delivery:** delivered_date > estimated_delivery_date
- **Review score:** average review score per order (deduplicated)

## Key Snapshot (from dashboard)
- Revenue: R$ 13.2M  
- Orders: 96,449  
- AOV: R$ 119.99  
- Avg delivery time: 11.41 days  
- Late delivery rate: 7% (7,263 orders)  
- Avg review score: 4.08  
- Payment mix: 78% credit card, 17.6% boleto

## How to Reproduce
1. Download the dataset from Kaggle.
2. Load CSVs into your database (PostgreSQL / BigQuery / etc.).
3. Run `master_query.sql` to create the reporting layer/view.
4. Connect your BI tool (Tableau / Looker Studio) to the output and explore the dashboard.

## Project Structure
- `master_query.sql` — single source of truth reporting layer
- `dashboard/` — screenshots and dashboard assets
- `docs/` — - **Project brief (EN):** [`docs/project-brief_EN.docx`](./docs/project-brief_EN.docx)

## Notes
This was built as a team project based on the public Olist dataset and is intended for portfolio / learning purposes.
