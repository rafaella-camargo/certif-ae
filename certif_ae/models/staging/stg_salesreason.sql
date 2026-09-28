with source as (select * from {{ source('adventureworks','salesreason') }})
select
    cast(SalesReasonID as int) as SalesReasonID,
    Name                       as reason_name,
    ReasonType                 as reason_type
from source
