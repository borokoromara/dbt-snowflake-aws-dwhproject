select
    ID as category_id,
    CAT as category,
    SUBCAT as subcategory,
    MAINTENANCE as maintenance
from {{ ref('stg_erp_product_category') }}
