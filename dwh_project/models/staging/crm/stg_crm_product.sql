select
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
from {{ source('crm', 'BRZ_CRM_PRODUCT') }}
