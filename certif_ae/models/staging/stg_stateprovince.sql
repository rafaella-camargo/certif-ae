with source as (select * from {{ source('adventureworks','stateprovince') }})
select
    cast(StateProvinceID as int) as StateProvinceID,
    Name                         as state_name,
    CountryRegionCode            as CountryRegionCode
from source
