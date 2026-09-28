with source as (select * from {{ source('adventureworks','salesorderdetail') }})
select
    cast(SalesOrderID       as int)           as SalesOrderID,
    cast(SalesOrderDetailID as int)           as SalesOrderDetailID,
    cast(OrderQty           as int)           as OrderQty,
    cast(ProductID          as int)           as ProductID,
    cast(UnitPrice          as decimal(19,4)) as UnitPrice,
    cast(UnitPriceDiscount  as decimal(19,4)) as UnitPriceDiscount
from source
