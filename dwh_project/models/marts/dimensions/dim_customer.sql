select
    customer_key,
    customer_id,
    first_name,
    last_name,
    marital_status,
    gender,
    birth_date,
    create_date
from {{ ref('int_customer') }}
