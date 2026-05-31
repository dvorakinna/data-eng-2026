-- Cohort retention: % of customers from each signup month who reordered later (drill #10)
-- Cohort = group of customers who signed up in the same month
-- Retention = did they come back for a 2nd+ order?

with first_order as (
    -- find each customer's first order date
    select
        customer_id,
        min(order_date) as first_order_date
    from {{ ref('stg_orders') }}
    group by customer_id
),

repeat_customers as (
    -- customers who ordered AFTER their first order = retained
    select distinct o.customer_id
    from {{ ref('stg_orders') }} o
    join first_order f using (customer_id)
    where o.order_date > f.first_order_date
)

select
    date_trunc('month', c.signup_date)::date as cohort_month,
    count(distinct c.customer_id)            as cohort_size,
    count(distinct r.customer_id)            as retained,
    -- retention %: NULLIF guards against empty cohorts
    round(
        100.0 * count(distinct r.customer_id)
        / nullif(count(distinct c.customer_id), 0),
        1
    )                                        as retention_pct
from {{ ref('stg_customers') }} c
left join repeat_customers r on c.customer_id = r.customer_id
group by 1
order by 1