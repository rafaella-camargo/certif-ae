-- ATENÇÃO: depende da tabela `store` ingerida na Silver (pendência mapeada).
with source as (select * from {{ source('adventureworks','store') }})
select
    cast(BusinessEntityID as int) as BusinessEntityID,
    Name                          as store_name
from source
