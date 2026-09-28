select CustomerID, tipo, tem_contato, nome
from {{ ref('int_cliente') }}
