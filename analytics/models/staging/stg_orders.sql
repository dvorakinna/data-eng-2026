-- Staging: 1:1 with raw.orders
select
    id          as order_id,
    customer_id,
    order_date,
    status
from {{ source('raw_ecom', 'orders') }}