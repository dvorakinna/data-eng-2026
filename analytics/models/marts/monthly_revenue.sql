with monthly as (
    select
        -- truncate any date in the month to the 1st: 2026-05-15 → 2026-05-01
        -- ::date casts timestamp to date (removes 00:00:00)
        date_trunc('month', o.order_date)::date as month,
        sum(oi.line_amount)                     as revenue,
        count(distinct o.order_id)              as order_count
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_order_items') }} oi on o.order_id = oi.order_id
    where o.status in ('paid', 'shipped')   -- exclude pending/cancelled
    group by 1                               -- group by first column (month)
)

select
    month,
    revenue,
    order_count,
    -- running total: sum all previous months + current (cumulative revenue)
    sum(revenue) over (order by month rows unbounded preceding) as running_total
from monthly
order by month