with source as (select * from {{ source('adventureworks','countryregion') }})
select
    CountryRegionCode as CountryRegionCode,
    Name              as country_name
from source
