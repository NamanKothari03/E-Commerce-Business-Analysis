-- customer_analysis.sql : who are our valuable customers, and who is leaving?
-- Run one query at a time inside mysql>, or everything with:
--   mysql -u root -p ecommerce -t -e "source sql/customer_analysis.sql"
USE ecommerce;

-- ------------------------------------------------------------
-- STEP 0: one row per customer (a VIEW = a saved query we can reuse)
-- "Today" = the last order date in the data, so results never go stale.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW customer_base AS
SELECT o.customer_id,
       c.state,
       c.region,
       COUNT(DISTINCT o.order_id)                                  AS orders,
       SUM(o.sales)                                                AS revenue,
       SUM(o.profit)                                               AS profit,
       MIN(o.order_date)                                           AS first_order,
       MAX(o.order_date)                                           AS last_order,
       DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(o.order_date)) AS recency_days,
       AVG(o.delivery_days)                                        AS avg_delivery_days,
       COUNT(r.order_line_id)                                      AS returned_lines,
       COUNT(*)                                                    AS order_lines
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN returns r ON r.order_line_id = o.order_line_id
GROUP BY o.customer_id, c.state, c.region;

-- ------------------------------------------------------------
-- Q1. Repeat vs one-time customers
-- ------------------------------------------------------------
SELECT CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*)                                                AS customers,
       ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 1)        AS pct_of_customers,
       ROUND(SUM(revenue) / SUM(SUM(revenue)) OVER () * 100, 1) AS pct_of_revenue,
       ROUND(AVG(profit))                                      AS avg_profit_per_customer
FROM customer_base
GROUP BY customer_type;

-- ------------------------------------------------------------
-- Q2. How concentrated is revenue? (top 20% of customers)
-- ------------------------------------------------------------
WITH ranked AS (
    SELECT customer_id, revenue, profit,
           NTILE(5) OVER (ORDER BY revenue DESC) AS quintile      -- 1 = top 20%
    FROM customer_base
)
SELECT quintile,
       COUNT(*)                                                    AS customers,
       ROUND(SUM(revenue) / SUM(SUM(revenue)) OVER () * 100, 1)    AS pct_of_revenue,
       ROUND(SUM(profit)  / SUM(SUM(profit))  OVER () * 100, 1)    AS pct_of_profit
FROM ranked
GROUP BY quintile
ORDER BY quintile;

-- ------------------------------------------------------------
-- Q3. Top 10 customers by profit
-- ------------------------------------------------------------
SELECT customer_id, state, orders, ROUND(revenue) AS revenue, ROUND(profit) AS profit
FROM customer_base
ORDER BY profit DESC
LIMIT 10;

-- ------------------------------------------------------------
-- STEP 1 for RFM: score every customer 1-5 on each dimension (5 = best)
--   R = Recency   (days since last order: fewer is better)
--   F = Frequency (number of orders)
--   M = Monetary  (total revenue)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW rfm_scores AS
SELECT *,
       NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
       NTILE(5) OVER (ORDER BY orders ASC, revenue ASC) AS f_score,
       NTILE(5) OVER (ORDER BY revenue ASC)       AS m_score
FROM customer_base;

CREATE OR REPLACE VIEW rfm_segments AS
SELECT *,
       CASE WHEN r_score >= 4 AND f_score >= 4 THEN '1 Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN '2 Loyal'
            WHEN r_score <= 2 AND f_score >= 3 THEN '3 At risk'
            WHEN r_score >= 4 AND f_score <= 2 THEN '4 New / promising'
            ELSE                                    '5 Low value / lost' END AS segment
FROM rfm_scores;

-- ------------------------------------------------------------
-- Q4. RFM segment summary: size, value and lifetime profit per customer
-- ------------------------------------------------------------
SELECT segment,
       COUNT(*)                                                   AS customers,
       ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 1)           AS pct_customers,
       ROUND(SUM(revenue))                                        AS revenue,
       ROUND(SUM(revenue) / SUM(SUM(revenue)) OVER () * 100, 1)   AS pct_revenue,
       ROUND(AVG(revenue))                                        AS avg_revenue_per_customer,
       ROUND(AVG(profit))                                         AS avg_profit_per_customer,
       ROUND(AVG(orders), 1)                                      AS avg_orders,
       ROUND(AVG(recency_days))                                   AS avg_days_since_order
FROM rfm_segments
GROUP BY segment
ORDER BY segment;

-- ------------------------------------------------------------
-- CHURN: a customer is "churned" if they have not ordered for 90+ days
-- ------------------------------------------------------------
-- Q5. Overall churn rate
SELECT COUNT(*)                                                  AS customers,
       SUM(recency_days > 90)                                    AS churned,
       ROUND(SUM(recency_days > 90) / COUNT(*) * 100, 1)         AS churn_rate_pct
FROM customer_base;

-- Q6. Churn by state: which states lose customers fastest?
SELECT state,
       COUNT(*)                                                  AS customers,
       ROUND(SUM(recency_days > 90) / COUNT(*) * 100, 1)         AS churn_rate_pct,
       ROUND(AVG(avg_delivery_days), 1)                          AS avg_delivery_days
FROM customer_base
GROUP BY state
ORDER BY churn_rate_pct DESC;

-- Q7. Churn by delivery experience
-- Only customers with 5+ orders, so the groups are comparable
-- (one-time buyers churn a lot anyway and would distort the result).
SELECT CASE WHEN avg_delivery_days <= 3 THEN '1) 3 days or less'
            WHEN avg_delivery_days <= 5 THEN '2) 3-5 days'
            ELSE                             '3) over 5 days' END AS delivery_experience,
       COUNT(*)                                                  AS customers,
       ROUND(SUM(recency_days > 90) / COUNT(*) * 100, 1)         AS churn_rate_pct
FROM customer_base
WHERE orders >= 5
GROUP BY delivery_experience
ORDER BY delivery_experience;

-- Q8. Churn by return behaviour (again only customers with 5+ orders)
SELECT CASE WHEN returned_lines = 0                        THEN '1) no returns'
            WHEN returned_lines / order_lines <= .30       THEN '2) returns <= 30% of lines'
            ELSE                                                '3) returns > 30% of lines' END AS return_behaviour,
       COUNT(*)                                                  AS customers,
       ROUND(SUM(recency_days > 90) / COUNT(*) * 100, 1)         AS churn_rate_pct
FROM customer_base
WHERE orders >= 5
GROUP BY return_behaviour
ORDER BY return_behaviour;

-- Q9. Churn by number of orders: does early repeat buying keep customers?
SELECT CASE WHEN orders = 1  THEN '1) 1 order'
            WHEN orders <= 4 THEN '2) 2-4 orders'
            WHEN orders <= 9 THEN '3) 5-9 orders'
            ELSE                  '4) 10+ orders' END AS order_count_group,
       COUNT(*)                                          AS customers,
       ROUND(SUM(recency_days > 90) / COUNT(*) * 100, 1) AS churn_rate_pct
FROM customer_base
GROUP BY order_count_group
ORDER BY order_count_group;
