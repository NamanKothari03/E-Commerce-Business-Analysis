-- kpi_analysis.sql : Executive-level KPIs
-- Run:  mysql -u root -p ecommerce < sql/kpi_analysis.sql      (Command Prompt)
--  or:  mysql -u root -p ecommerce -e "source sql/kpi_analysis.sql"   (PowerShell)
USE ecommerce;

-- ------------------------------------------------------------
-- Q1. Overall business KPIs (one row)
-- Business question: How is the business performing overall?
-- ------------------------------------------------------------
SELECT
    ROUND(SUM(o.sales))                                         AS revenue,
    ROUND(SUM(o.profit))                                        AS profit,
    ROUND(SUM(o.profit) / SUM(o.sales) * 100, 1)                AS profit_margin_pct,
    COUNT(DISTINCT o.order_id)                                  AS total_orders,
    COUNT(DISTINCT o.customer_id)                               AS total_customers,
    ROUND(SUM(o.sales) / COUNT(DISTINCT o.order_id))            AS avg_order_value,
    ROUND(COUNT(r.order_line_id) / COUNT(*) * 100, 1)           AS return_rate_pct,
    ROUND(SUM(r.returned_revenue))                              AS returned_revenue
FROM orders o
LEFT JOIN returns r ON r.order_line_id = o.order_line_id;

-- ------------------------------------------------------------
-- Q2. Monthly revenue, profit, margin and month-over-month growth
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(sales)  AS revenue,
           SUM(profit) AS profit
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month,
       ROUND(revenue)                                   AS revenue,
       ROUND(profit)                                    AS profit,
       ROUND(profit / revenue * 100, 1)                 AS margin_pct,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 1) AS revenue_growth_pct
FROM monthly
ORDER BY month;

-- ------------------------------------------------------------
-- Q3. Category performance: which categories earn, which only look big?
-- ------------------------------------------------------------
SELECT p.category,
       ROUND(SUM(o.sales))                              AS revenue,
       ROUND(SUM(o.profit))                             AS profit,
       ROUND(SUM(o.profit) / SUM(o.sales) * 100, 1)     AS margin_pct,
       ROUND(SUM(o.sales) / SUM(SUM(o.sales)) OVER () * 100, 1)  AS revenue_share_pct,
       ROUND(SUM(o.profit) / SUM(SUM(o.profit)) OVER () * 100, 1) AS profit_share_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY profit DESC;

-- ------------------------------------------------------------
-- Q4. Region performance
-- ------------------------------------------------------------
SELECT c.region,
       ROUND(SUM(o.sales))                              AS revenue,
       ROUND(SUM(o.profit))                             AS profit,
       ROUND(SUM(o.profit) / SUM(o.sales) * 100, 1)     AS margin_pct,
       COUNT(DISTINCT o.customer_id)                    AS customers
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region
ORDER BY profit DESC;

-- ------------------------------------------------------------
-- Q5. State performance: where are we underperforming?
-- Underperforming = low margin and/or low profit per customer
-- ------------------------------------------------------------
SELECT c.state,
       ROUND(SUM(o.sales))                              AS revenue,
       ROUND(SUM(o.profit))                             AS profit,
       ROUND(SUM(o.profit) / SUM(o.sales) * 100, 1)     AS margin_pct,
       COUNT(DISTINCT o.customer_id)                    AS customers,
       ROUND(SUM(o.profit) / COUNT(DISTINCT o.customer_id)) AS profit_per_customer,
       ROUND(AVG(o.delivery_days), 1)                   AS avg_delivery_days
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.state
ORDER BY margin_pct ASC;
