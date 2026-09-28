with source as (select * from {{ source('adventureworks','person') }})
select
    cast(BusinessEntityID as int) as BusinessEntityID,
    FirstName                     as first_name,
    LastName                      as last_name
from source
