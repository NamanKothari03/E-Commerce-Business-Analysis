-- profitability_analysis.sql : where are we losing money?
-- Run one query at a time inside mysql>, or the whole file with:
--   mysql -u root -p ecommerce -t -e "source sql/profitability_analysis.sql"
USE ecommerce;

-- ------------------------------------------------------------
-- Q1. Margin by discount band  (the central finding)
-- ------------------------------------------------------------
SELECT
    CASE WHEN discount = 0    THEN '1) 0%'
         WHEN discount <= .10 THEN '2) 1-10%'
         WHEN discount <= .20 THEN '3) 11-20%'
         WHEN discount <= .30 THEN '4) 21-30%'
         ELSE                      '5) >30%' END      AS discount_band,
    COUNT(*)                                          AS order_lines,
    ROUND(SUM(sales))                                 AS revenue,
    ROUND(SUM(profit))                                AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 1)          AS margin_pct
FROM orders
GROUP BY discount_band
ORDER BY discount_band;

-- ------------------------------------------------------------
-- Q2. Does discounting hurt inside every category? (rules out product mix)
-- ------------------------------------------------------------
SELECT p.category,
       ROUND(AVG(o.discount) * 100, 1)                                        AS avg_discount_pct,
       ROUND(SUM(CASE WHEN o.discount <= .10 THEN o.profit END)
             / SUM(CASE WHEN o.discount <= .10 THEN o.sales END) * 100, 1)    AS margin_low_disc_pct,
       ROUND(SUM(CASE WHEN o.discount >= .30 THEN o.profit END)
             / SUM(CASE WHEN o.discount >= .30 THEN o.sales END) * 100, 1)    AS margin_high_disc_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY avg_discount_pct DESC;

-- ------------------------------------------------------------
-- Q3. Profit lost on orders with 30%+ discount
-- ------------------------------------------------------------
SELECT COUNT(*)                                         AS deep_discount_lines,
       ROUND(SUM(sales))                                AS revenue,
       ROUND(SUM(profit))                               AS profit,
       ROUND(SUM(sales) / (SELECT SUM(sales) FROM orders) * 100, 1) AS share_of_revenue_pct
FROM orders
WHERE discount >= .30;

-- ------------------------------------------------------------
-- Q4. Sub-categories that bring revenue but lose money
-- ------------------------------------------------------------
SELECT p.category, p.sub_category,
       ROUND(SUM(o.sales))                              AS revenue,
       ROUND(SUM(o.profit))                             AS profit,
       ROUND(SUM(o.profit) / SUM(o.sales) * 100, 1)     AS margin_pct,
       ROUND(AVG(o.discount) * 100, 1)                  AS avg_discount_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category, p.sub_category
ORDER BY profit ASC;

-- ------------------------------------------------------------
-- Q5. The 10 most loss-making products
-- ------------------------------------------------------------
SELECT p.product_name, p.category,
       ROUND(SUM(o.sales))                              AS revenue,
       ROUND(SUM(o.profit))                             AS profit,
       ROUND(AVG(o.discount) * 100, 1)                  AS avg_discount_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY profit ASC
LIMIT 10;

-- ------------------------------------------------------------
-- Q6. Shipping cost as a share of revenue, by category
-- ------------------------------------------------------------
SELECT p.category,
       ROUND(SUM(o.shipping_cost))                      AS shipping_cost,
       ROUND(SUM(o.shipping_cost) / SUM(o.sales) * 100, 1) AS shipping_pct_of_sales
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY shipping_pct_of_sales DESC;

-- ------------------------------------------------------------
-- Q7. Returns: how much revenue and profit do we lose?
-- ------------------------------------------------------------
SELECT p.category,
       COUNT(*)                                         AS order_lines,
       COUNT(r.order_line_id)                           AS returned_lines,
       ROUND(COUNT(r.order_line_id) / COUNT(*) * 100, 1) AS return_rate_pct,
       ROUND(SUM(r.returned_revenue))                   AS returned_revenue
FROM orders o
JOIN products p ON p.product_id = o.product_id
LEFT JOIN returns r ON r.order_line_id = o.order_line_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;

-- ------------------------------------------------------------
-- Q8. Return rate by payment mode
-- ------------------------------------------------------------
SELECT o.payment_mode,
       COUNT(*)                                         AS order_lines,
       ROUND(COUNT(r.order_line_id) / COUNT(*) * 100, 1) AS return_rate_pct
FROM orders o
LEFT JOIN returns r ON r.order_line_id = o.order_line_id
GROUP BY o.payment_mode
ORDER BY return_rate_pct DESC;

-- ------------------------------------------------------------
-- Q9. Monthly average discount: what happened in Oct 2025?
-- ------------------------------------------------------------
SELECT DATE_FORMAT(order_date, '%Y-%m')                 AS month,
       ROUND(AVG(discount) * 100, 1)                    AS avg_discount_pct,
       ROUND(SUM(profit) / SUM(sales) * 100, 1)         AS margin_pct
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
