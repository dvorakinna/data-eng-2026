-- Conversion funnel per country: paid vs cancelled ratio (drill #7)
-- FILTER clause = Postgres-specific aggregate filter (cleaner than CASE WHEN)
select
    c.country,
    count(*)                                          as total_orders,
    count(*) filter (where o.status = 'paid')         as paid,
    count(*) filter (where o.status = 'cancelled')    as cancelled,
    -- paid percentage: NULLIF prevents division by zero
    round(
        100.0 * count(*) filter (where o.status = 'paid')
        / nullif(count(*), 0),
        1
    )                                                 as paid_pct
from {{ ref('stg_customers') }} c
join {{ ref('stg_orders') }} o on c.customer_id = o.customer_id
group by c.country
order by paid_pct desc