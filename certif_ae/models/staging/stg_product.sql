with source as (select * from {{ source('adventureworks','product') }})
select
    cast(ProductID as int)            as ProductID,
    Name                              as product_name,
    Color                             as color,
    Size                              as size,
    cast(ListPrice as decimal(19,4))  as list_price,
    ProductLine                       as product_line
from source
