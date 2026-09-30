select
    CID as customer_id,
    case
        when trim(CNTRY) = 'DE' then 'Germany'
        when trim(CNTRY) in ('US', 'USA') then 'United States'
        else nullif(trim(CNTRY), '')
    end as country
from {{ ref('stg_erp_location') }}
