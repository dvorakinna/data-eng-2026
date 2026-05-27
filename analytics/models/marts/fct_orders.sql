-- Fact table: one row per order with line-item totals
with line_totals as (
    select
        order_id,
        sum(line_amount) as order_total,
        sum(quantity)    as total_items,
        count(*)         as line_count
    from {{ ref('stg_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    c.customer_name,
    c.country,
    c.customer_tier,
    coalesce(lt.order_total, 0)   as order_total,
    coalesce(lt.total_items, 0)   as total_items,
    coalesce(lt.line_count, 0)    as line_count,
    row_number() over (
        partition by o.customer_id
        order by o.order_date
    )                              as customer_order_seq
from {{ ref('stg_orders') }} o
left join {{ ref('dim_customers') }} c  on o.customer_id = c.customer_id
left join line_totals lt               on o.order_id = lt.order_id