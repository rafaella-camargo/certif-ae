select
    CreditCardID,
    card_type as tipo_cartao
from {{ ref('stg_creditcard') }}

union all

-- membro de ausência (pedidos sem cartão apontam para cá na fato)
select
    -1                as CreditCardID,
    'Não informado'   as tipo_cartao
