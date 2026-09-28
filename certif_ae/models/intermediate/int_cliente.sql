-- tipo por precedência de StoreID; nome de store (loja) ou person (PF); flag tem_contato
with cus as (select * from {{ ref('stg_customer') }}),
     per as (select * from {{ ref('stg_person') }}),
     sto as (select * from {{ ref('stg_store') }})
select
    cus.CustomerID,
    case when cus.StoreID is not null then 'Loja' else 'Pessoa Física' end as tipo,
    case when cus.StoreID is not null and cus.PersonID is not null then true else false end as tem_contato,
    case when cus.StoreID is not null then sto.store_name
         else trim(concat(coalesce(per.first_name,''),' ',coalesce(per.last_name,'')))
    end as nome
from cus
left join per on cus.PersonID = per.BusinessEntityID
left join sto on cus.StoreID  = sto.BusinessEntityID
