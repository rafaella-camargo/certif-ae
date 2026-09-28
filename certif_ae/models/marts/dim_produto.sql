select
    ProductID,
    product_name,
    color,
    size,
    list_price,
    product_line
from {{ ref('stg_product') }}
