with source as (select * from {{ source('adventureworks','customer') }})
select
    cast(CustomerID as int) as CustomerID,
    cast(PersonID   as int) as PersonID,
    cast(StoreID    as int) as StoreID
from source
