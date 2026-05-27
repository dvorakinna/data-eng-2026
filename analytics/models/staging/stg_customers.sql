select
    id          as customer_id,
    name        as customer_name,
    email,
    country,
    signup_date
from {{ source('raw_ecom', 'customers') }}