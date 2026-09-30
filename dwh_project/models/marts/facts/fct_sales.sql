select
    md5(order_number || '|' || product_key) as sales_key,
    order_number,
    product_key,
    product_id,
    customer_id,
    order_date,
    ship_date,
    due_date,
    quantity,
    price,
    sales_amount
from {{ ref('int_sales') }}
