with products as (

    select
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    from {{ ref('stg_crm_product') }}

),

product_category as (

    select
        category_id,
        category,
        subcategory,
        maintenance
    from {{ ref('int_product_category') }}

)

select
    try_to_number(p.prd_id) as product_id,
    p.prd_key as product_key,
    p.prd_nm as product_name,
    try_to_number(p.prd_cost) as product_cost,
    p.prd_line as product_line,
    try_to_date(p.prd_start_dt) as start_date,
    try_to_date(p.prd_end_dt) as end_date,
    c.category_id,
    c.category,
    c.subcategory,
    c.maintenance
from products p
left join product_category c
    on split_part(p.prd_key, '-', 1) || '_' || split_part(p.prd_key, '-', 2) = c.category_id
