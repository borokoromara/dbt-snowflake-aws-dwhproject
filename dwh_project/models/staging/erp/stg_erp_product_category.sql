select
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
from {{ source('erp', 'BRZ_ERP_PRODUCT_CATEGORY') }}
