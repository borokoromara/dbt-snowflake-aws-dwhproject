select
    product_key,
    product_id,
    product_name,
    product_cost,
    product_line,
    category_id,
    category,
    subcategory,
    maintenance,
    start_date,
    end_date
from {{ ref('int_product') }}
