select distinct
    Status,
    case when Status = 5 then 'Shipped'
         else cast(Status as string) end as status_desc
from {{ ref('stg_salesorderheader') }}
