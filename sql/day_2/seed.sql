-- 50 customers across CH/DE/AT/FR/IT, signups over last 2 years
INSERT INTO raw.customers (name, email, country, signup_date)
SELECT
    'Customer ' || gs,
    'cust' || gs || '@example.com',
    (ARRAY['CH','DE','AT','FR','IT'])[1 + (random()*4)::int],
    CURRENT_DATE - (random() * 730)::int
FROM generate_series(1, 50) gs;

-- 20 products across 4 categories
INSERT INTO raw.products (sku, name, price, category)
SELECT
    'SKU-' || LPAD(gs::text, 4, '0'),
    'Product ' || gs,
    ROUND((10 + random() * 490)::numeric, 2),
    (ARRAY['Electronics','Books','Clothing','Home'])[1 + (random()*3)::int]
FROM generate_series(1, 20) gs;

-- 200 orders over last 365 days
INSERT INTO raw.orders (customer_id, order_date, status)
SELECT
    1 + (random() * 49)::int,
    NOW() - (random() * 365)::int * INTERVAL '1 day' - (random() * 86400)::int * INTERVAL '1 second',
    (ARRAY['pending','paid','paid','paid','shipped','shipped','cancelled'])[1 + (random()*6)::int]
FROM generate_series(1, 200);

-- 1–5 items per order, unit_price snapshotted from products
INSERT INTO raw.order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.id,
    p.id,
    1 + (random() * 4)::int,
    p.price
FROM raw.orders o
CROSS JOIN LATERAL (
    SELECT id, price FROM raw.products ORDER BY random() LIMIT 1 + (random() * 4)::int
) p;

-- Sanity check
SELECT 'customers' tbl, COUNT(*) n FROM raw.customers
UNION ALL SELECT 'products',    COUNT(*) FROM raw.products
UNION ALL SELECT 'orders',      COUNT(*) FROM raw.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM raw.order_items;