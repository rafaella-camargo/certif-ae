with source as (select * from {{ source('adventureworks','salesorderheader') }})
select
    cast(SalesOrderID    as int)       as SalesOrderID,
    cast(OrderDate       as timestamp) as OrderDate,
    cast(Status          as int)       as Status,
    cast(CustomerID      as int)       as CustomerID,
    cast(CreditCardID    as int)       as CreditCardID,
    cast(ShipToAddressID as int)       as ShipToAddressID
from source
