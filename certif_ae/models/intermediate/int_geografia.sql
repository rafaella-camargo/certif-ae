-- cidade -> estado -> país numa linha só (GeoKey = AddressID)
with a as (select * from {{ ref('stg_address') }}),
     s as (select * from {{ ref('stg_stateprovince') }}),
     c as (select * from {{ ref('stg_countryregion') }})
select
    a.AddressID          as GeoKey,
    a.city               as cidade,
    s.state_name         as estado,
    c.country_name       as pais
from a
left join s on a.StateProvinceID = s.StateProvinceID
left join c on s.CountryRegionCode = c.CountryRegionCode
