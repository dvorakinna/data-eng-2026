-- Product revenue rank within category (drill #6)
-- RANK() = window function: ranks rows within partition by ORDER BY value
-- Ties get same rank; next rank skips (1, 2, 2, 4)
select
    p.category,
    p.product_name,
    sum(oi.line_amount) as revenue,
    sum(oi.quantity)    as units_sold,
    -- rank within each category, highest revenue = 1
    rank() over (
        partition by p.category
        order by sum(oi.line_amount) desc
    ) as category_rank
from {{ ref('stg_products') }} p
join {{ ref('stg_order_items') }} oi on p.product_id = oi.product_id
join {{ ref('stg_orders') }} o       on oi.order_id  = o.order_id
where o.status in ('paid', 'shipped')
group by p.category, p.product_name
order by p.category, category_rank