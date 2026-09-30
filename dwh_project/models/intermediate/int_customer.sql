with crm_customer as (

    select
        customer_id,
        customer_key,
        first_name,
        last_name,
        marital_status,
        gender,
        create_date
    from (
        select
            try_to_number(cst_id) as customer_id,
            cst_key as customer_key,
            cst_firstname as first_name,
            cst_lastname as last_name,
            cst_marital_status as marital_status,
            cst_gndr as gender,
            try_to_date(cst_create_date) as create_date,
            row_number() over (
                partition by cst_key
                order by try_to_date(cst_create_date) desc nulls last
            ) as rn
        from {{ ref('stg_crm_customer') }}
        where regexp_like(cst_key, '^AW[0-9]{8}$')
    )
    where rn = 1

),

erp_customer as (

    select
        case
            when CID like 'NASAW%' then 'AW' || right(CID, 8)
            else CID
        end as customer_key,
        case
            when BDATE::date = '9999-11-20'::date then null
            else BDATE::date
        end as birth_date,
        case
            when trim(GEN) = 'M' then 'Male'
            when trim(GEN) = 'F' then 'Female'
            when trim(GEN) in ('Male', 'Female') then trim(GEN)
            else null
        end as gender_erp
    from {{ ref('stg_erp_customer') }}

)

select
    c.customer_id,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.marital_status,
    coalesce(c.gender, e.gender_erp) as gender,
    e.birth_date,
    c.create_date
from crm_customer c
left join erp_customer e
    on c.customer_key = e.customer_key
