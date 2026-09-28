with source as (select * from {{ source('adventureworks','address') }})
select
    cast(AddressID        as int) as AddressID,
    City                          as city,
    cast(StateProvinceID  as int) as StateProvinceID
from source
