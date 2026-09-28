with days as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2011-01-01' as date)",
        end_date="cast('2015-01-01' as date)"
    ) }}
)
select
    cast(date_day as date)                                   as DateKey,
    year(date_day)                                           as ano,
    month(date_day)                                          as mes,
    quarter(date_day)                                        as trimestre,
    day(date_day)                                            as dia,
    case when year(date_day) in (2012, 2013) then true
         else false end                                     as ano_completo
from days
