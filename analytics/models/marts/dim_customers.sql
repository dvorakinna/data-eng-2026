-- Customer dimension: lifetime metrics per customer
with orders as (
    select
        customer_id,
        count(*)           as total_orders,
        min(order_date)    as first_order_date,
        max(order_date)    as last_order_date
    from {{ ref('stg_orders') }}
    group by customer_id
),

revenue as (
    select
        o.customer_id,
        sum(oi.line_amount) as lifetime_revenue
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_order_items') }} oi on o.order_id = oi.order_id
    group by o.customer_id
)

select
    c.customer_id,
    c.customer_name,
    c.email,
    c.country,
    c.signup_date,
    coalesce(o.total_orders, 0)        as total_orders,
    o.first_order_date,
    o.last_order_date,
    coalesce(r.lifetime_revenue, 0)    as lifetime_revenue,
    case
        when r.lifetime_revenue >= 5000 then 'gold'
        when r.lifetime_revenue >= 1000 then 'silver'
        else 'bronze'
    end                                as customer_tier
from {{ ref('stg_customers') }} c
left join orders o  on c.customer_id = o.customer_id
left join revenue r on c.customer_id = r.customer_id