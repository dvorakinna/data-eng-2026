-- Product dimension: sales metrics per product
with sales as (
    select
        product_id,
        sum(quantity)      as total_units_sold,
        sum(line_amount)   as total_revenue,
        count(distinct order_id) as order_count
    from {{ ref('stg_order_items') }}
    group by product_id
)

select
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.price                              as current_price,
    coalesce(s.total_units_sold, 0)      as total_units_sold,
    coalesce(s.total_revenue, 0)         as total_revenue,
    coalesce(s.order_count, 0)           as order_count,
    case
        when s.total_revenue >= 10000 then 'star'   -- 10000+ → star, STOP
        when s.total_revenue >= 3000  then 'core'   -- 3000–9999 → core, STOP
        else 'niche'                                 -- <3000 → niche
    end                                 as product_tier
from {{ ref('stg_products') }} p
left join sales s on p.product_id = s.product_id