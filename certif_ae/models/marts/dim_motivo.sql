select
    SalesReasonID,
    reason_name  as nome,
    reason_type  as tipo
from {{ ref('stg_salesreason') }}

union all

-- membro de ausência (pedidos sem motivo)
select
    -1            as SalesReasonID,
    'Sem motivo'  as nome,
    'N/A'         as tipo
