DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA raw;

CREATE TABLE raw.customers (
    id           SERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    email        TEXT UNIQUE NOT NULL,
    country      CHAR(2) NOT NULL,
    signup_date  DATE NOT NULL
);

CREATE TABLE raw.products (
    id        SERIAL PRIMARY KEY,
    sku       TEXT UNIQUE NOT NULL,
    name      TEXT NOT NULL,
    price     NUMERIC(10,2) NOT NULL CHECK (price > 0),
    category  TEXT NOT NULL
);

CREATE TABLE raw.orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INT NOT NULL REFERENCES raw.customers(id),
    order_date   TIMESTAMP NOT NULL DEFAULT NOW(),
    status       TEXT NOT NULL CHECK (status IN ('pending','paid','shipped','cancelled'))
);

CREATE TABLE raw.order_items (
    id          SERIAL PRIMARY KEY,
    order_id    INT NOT NULL REFERENCES raw.orders(id) ON DELETE CASCADE,
    product_id  INT NOT NULL REFERENCES raw.products(id),
    quantity    INT NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL CHECK (unit_price > 0)
);

CREATE INDEX idx_orders_customer  ON raw.orders(customer_id);
CREATE INDEX idx_orders_date      ON raw.orders(order_date);
CREATE INDEX idx_items_order      ON raw.order_items(order_id);
CREATE INDEX idx_items_product    ON raw.order_items(product_id);