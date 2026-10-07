# E-Commerce Profitability & Customer Intelligence

An end-to-end business analytics project transforming a messy synthetic e-commerce dataset into actionable business insights using **Python, Pandas, MySQL, and SQL**.

## 📌 Overview

A data analytics case study simulating an Indian e-commerce business, focused on understanding profitability, customer behavior, discounts, returns, and regional performance. The project covers data cleaning, database design, SQL analysis, customer segmentation, and business recommendations to support management decision-making.

## 🎯 Business Problem

Framed as a real-world business scenario: an e-commerce company wants to understand what's driving its revenue and profit, where it is losing money, which customers are most valuable, and where opportunities exist to improve customer retention and profitability.

## 🗂️ Dataset

- **Source:** Synthetic dataset generated specifically for this project
- **Data period:** 2024–2025
- **Order lines:** ~97,673
- **Orders:** 69,840
- **Customers:** 8,641
- **Products:** 350
- **Database tables:** `customers`, `products`, `orders`, `returns`

The raw dataset was deliberately generated with real-world data quality issues such as duplicates, missing values, inconsistent categories and states, negative quantities, and inconsistent Yes/No labels.

## 🛠️ Tools & Tech Stack

- **Python** (Pandas, NumPy) — data generation, cleaning, validation, and feature engineering
- **MySQL** — relational database design and data storage
- **SQL** — business analysis, profitability analysis, RFM segmentation, churn and returns analysis
- **Jupyter Notebook** — data cleaning and exploration
- **Git & GitHub** — version control and project management

## 🔑 Key Insights

- **Discounts above 20% destroy profitability** — margin falls from 16.9% with no discount to -10.1% at 21–30% and -35.3% above 30%. Orders discounted 30% or more account for 17.1% of revenue but lose approximately ₹2.13 crore.

- **Revenue does not equal profit** — Electronics generates 56.9% of revenue but only 22.1% of profit, while Fashion generates 14.6% of revenue and 68.1% of profit.

- **Four sub-categories are consistently loss-making** — Sofas, Laptops, Tables, and Staples together account for approximately 62% of revenue while losing around ₹98.6 lakh.

- **Returns are a significant revenue leak** — approximately 11.1% of revenue is refunded through returns. Fashion has the highest return rate at 26.2%.

- **Repeat customers drive the business** — repeat customers represent around 80% of customers but generate 97.5% of revenue.

- **High-value customers can be targeted for retention** — the At Risk RFM segment contains 1,296 customers representing approximately ₹8.69 crore of past revenue.

- **Slower delivery is associated with higher churn** — churn increases from 22.5% for customers receiving orders within 3 days to 31.1% when delivery takes more than 5 days.

## 📂 Project Files

- [`generate_dataset.py`](python/generate_dataset.py) — Generates the synthetic raw e-commerce dataset
- [`02_data_cleaning.ipynb`](python/02_data_cleaning.ipynb) — Data cleaning, validation, and feature engineering
- [`load_to_mysql.py`](python/load_to_mysql.py) — Loads cleaned data into MySQL tables
- [`schema.sql`](sql/schema.sql) — MySQL database schema and table definitions
- [`kpi_analysis.sql`](sql/kpi_analysis.sql) — Revenue, profit, trends, category, and regional analysis
- [`profitability_analysis.sql`](sql/profitability_analysis.sql) — Discount, product, shipping, and returns analysis
- [`customer_analysis.sql`](sql/customer_analysis.sql) — Customer behavior, RFM segmentation, and churn analysis
- [`findings.md`](business_report/findings.md) — Detailed business findings and recommendations
- [`cleaning_log.csv`](data/cleaning_log.csv) — Documentation of data cleaning decisions

## 📁 Repository Structure

```text
├── README.md
├── python/
│   ├── generate_dataset.py
│   ├── 02_data_cleaning.ipynb
│   ├── load_to_mysql.py
│   └── export_for_powerbi.py
│
├── sql/
│   ├── schema.sql
│   ├── kpi_analysis.sql
│   ├── profitability_analysis.sql
│   └── customer_analysis.sql
│
├── business_report/
│   └── findings.md
│
└── data/
    └── cleaning_log.csv
```

## 📊 Business Recommendations

Based on the SQL analysis:

1. **Cap deep discounts** and introduce stricter limits above 20%.
2. **Review pricing and costs** for Laptops, Sofas, and Tables.
3. **Prioritize win-back campaigns** for high-value At Risk customers.
4. **Increase marketing focus on Fashion and Beauty**, which generate the majority of profit.
5. Introduce a **minimum order value or shipping threshold** for Grocery.
6. Reduce Fashion returns through better product information and sizing guidance.
7. Encourage **prepaid payments** to reduce return rates.
8. Improve delivery performance in high-churn regions.

## ⚠️ Data Note

The dataset is **synthetic** and was generated to simulate a realistic Indian e-commerce business. Churn rates and other business metrics are illustrative and should not be interpreted as real-world benchmarks.

Profit in this analysis is measured before returns, and the relationship between delivery time and churn represents an association rather than proof of causation.

## 🚀 How to Run

### Install dependencies

```bash
pip install pandas numpy sqlalchemy pymysql cryptography
```

### Generate the dataset

```bash
python python/generate_dataset.py
```

### Clean the data

Run:

```text
python/02_data_cleaning.ipynb
```

### Create the MySQL database

```bash
mysql -u root -p -e "source sql/schema.sql"
```

### Load the cleaned data

```bash
python python/load_to_mysql.py
```

### Run the SQL analysis

```bash
mysql -u root -p ecommerce -t -e "source sql/kpi_analysis.sql"

mysql -u root -p ecommerce -t -e "source sql/profitability_analysis.sql"

mysql -u root -p ecommerce -t -e "source sql/customer_analysis.sql"
```

## 👤 Author

**Naman Kothari**
