select
    CID,
    CNTRY
from {{ source('erp', 'BRZ_ERP_LOCATION') }}
