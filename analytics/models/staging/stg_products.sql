select
    id         as product_id,
    sku,
    name       as product_name,
    category,
    price
from {{ source('raw_ecom', 'products') }}