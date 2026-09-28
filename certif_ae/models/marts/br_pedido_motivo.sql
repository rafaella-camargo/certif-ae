select SalesOrderID, SalesReasonID
from {{ ref('int_pedido_motivo') }}
