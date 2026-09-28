with source as (select * from {{ source('adventureworks','salesorderheadersalesreason') }})
select
    cast(SalesOrderID  as int) as SalesOrderID,
    cast(SalesReasonID as int) as SalesReasonID
from source
