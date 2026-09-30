select
    CID,
    BDATE,
    GEN
from {{ source('erp', 'BRZ_ERP_CUSTOMER') }}
