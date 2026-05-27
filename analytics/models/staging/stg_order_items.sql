-- Staging: 1:1 with raw.order_items + one derived column (line_amount)
-- Derived column is safe here because it has no joins and no business rules
select
    id                       as order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price    as line_amount
from {{ source('raw_ecom', 'order_items') }}