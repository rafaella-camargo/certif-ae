with source as (select * from {{ source('adventureworks','creditcard') }})
select
    cast(CreditCardID as int) as CreditCardID,
    CardType                  as card_type
from source
