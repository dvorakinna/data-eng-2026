-- 1. Top 5 customers by lifetime revenue (paid+shipped only)
SELECT c.id, c.name, SUM(oi.quantity * oi.unit_price) AS lifetime_revenue
FROM raw.customers c
JOIN raw.orders o ON o.customer_id = c.id
JOIN raw.order_items oi ON oi.order_id = o.id
WHERE o.status IN ('paid','shipped')
GROUP BY c.id, c.name
ORDER BY lifetime_revenue DESC
LIMIT 5;

-- 2. Monthly revenue trend
SELECT DATE_TRUNC('month', o.order_date)::date AS month,
       SUM(oi.quantity * oi.unit_price) AS revenue,
       COUNT(DISTINCT o.id) AS orders
FROM raw.orders o
JOIN raw.order_items oi ON oi.order_id = o.id
WHERE o.status IN ('paid','shipped')
GROUP BY 1
ORDER BY 1;

-- 3. Status breakdown per country with ROLLUP
SELECT c.country, o.status, COUNT(*) AS n
FROM raw.customers c
JOIN raw.orders o ON o.customer_id = c.id
GROUP BY ROLLUP (c.country, o.status)
ORDER BY c.country NULLS LAST, o.status NULLS LAST;

-- 4. Each customer's first order (window fn)
WITH ranked AS (
    SELECT o.*,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM raw.orders o
)
SELECT customer_id, id AS first_order_id, order_date, status
FROM ranked WHERE rn = 1;

-- 5. Days between consecutive orders per customer (LAG)
SELECT customer_id,
       id AS order_id,
       order_date,
       order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS gap
FROM raw.orders
ORDER BY customer_id, order_date;

-- 6. Product revenue rank within category (RANK)
SELECT p.category, p.name,
       SUM(oi.quantity * oi.unit_price) AS revenue,
       RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS cat_rank
FROM raw.products p
JOIN raw.order_items oi ON oi.product_id = p.id
JOIN raw.orders o ON o.id = oi.order_id
WHERE o.status IN ('paid','shipped')
GROUP BY p.category, p.name
ORDER BY p.category, cat_rank;

-- 7. Conversion funnel — paid vs cancelled per country (FILTER)
SELECT c.country,
       COUNT(*) FILTER (WHERE o.status = 'paid')      AS paid,
       COUNT(*) FILTER (WHERE o.status = 'cancelled') AS cancelled,
       ROUND(100.0 * COUNT(*) FILTER (WHERE o.status='paid') / NULLIF(COUNT(*),0), 1) AS paid_pct
FROM raw.customers c
JOIN raw.orders o ON o.customer_id = c.id
GROUP BY c.country
ORDER BY paid_pct DESC;

-- 8. Customers with no orders (anti-join)
SELECT c.*
FROM raw.customers c
LEFT JOIN raw.orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- 9. Running revenue total per month
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,
           SUM(oi.quantity * oi.unit_price) AS rev
    FROM raw.orders o JOIN raw.order_items oi ON oi.order_id = o.id
    WHERE o.status IN ('paid','shipped')
    GROUP BY 1
)
SELECT month, rev,
       SUM(rev) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING) AS running_total
FROM monthly;

-- 10. Cohort retention — % of signup-month customers who reordered later
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_dt FROM raw.orders GROUP BY customer_id
),
later_order AS (
    SELECT DISTINCT o.customer_id
    FROM raw.orders o JOIN first_order f USING (customer_id)
    WHERE o.order_date > f.first_dt
)
SELECT
    DATE_TRUNC('month', c.signup_date)::date AS cohort_month,
    COUNT(DISTINCT c.id) AS cohort_size,
    COUNT(DISTINCT l.customer_id) AS retained,
    ROUND(100.0 * COUNT(DISTINCT l.customer_id) / NULLIF(COUNT(DISTINCT c.id),0), 1) AS retention_pct
FROM raw.customers c
LEFT JOIN later_order l ON l.customer_id = c.id
GROUP BY 1
ORDER BY 1;