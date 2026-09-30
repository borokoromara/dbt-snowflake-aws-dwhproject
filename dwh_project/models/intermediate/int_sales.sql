with sales as (

    select
        sls_ord_num as order_number,
        sls_prd_key as product_key,
        try_to_number(sls_cust_id) as customer_id,
        case
            when sls_order_dt::varchar = '0' then null
            else try_to_date(sls_order_dt::varchar, 'YYYYMMDD')
        end as order_date,
        try_to_date(sls_ship_dt::varchar, 'YYYYMMDD') as ship_date,
        try_to_date(sls_due_dt::varchar, 'YYYYMMDD') as due_date,
        try_to_number(sls_sales) as sales_amount,
        try_to_number(sls_quantity) as quantity,
        try_to_number(sls_price) as price

    from {{ ref('stg_crm_sales') }}

),

product_matches as (

    select
        s.order_number,
        s.product_key,
        s.order_date,
        p.product_id,
        row_number() over (
            partition by s.order_number, s.product_key
            order by p.start_date desc
        ) as rn

    from sales s
    left join {{ ref('int_product') }} p
        on p.product_key like '%-' || s.product_key
        and s.order_date is not null
        and p.start_date <= s.order_date

)

select
    s.order_number,
    s.product_key,
    pm.product_id,
    s.customer_id,
    s.order_date,
    s.ship_date,
    s.due_date,
    s.sales_amount,
    s.quantity,
    s.price

from sales s
left join product_matches pm
    on s.order_number = pm.order_number
    and s.product_key = pm.product_key
    and pm.rn = 1
