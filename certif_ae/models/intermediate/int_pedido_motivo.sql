-- ponte pedido <-> motivo (N:N). Grão: par pedido-motivo.
select
    SalesOrderID,
    SalesReasonID
from {{ ref('stg_salesorderheadersalesreason') }}
