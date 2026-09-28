with sod as (select * from {{ ref('stg_salesorderdetail') }}),
     soh as (select * from {{ ref('stg_salesorderheader') }})
select
    -- chaves
    sod.SalesOrderDetailID,
    sod.SalesOrderID,                                   -- dimensão degenerada
    sod.ProductID,
    cast(soh.OrderDate as date)          as DateKey,
    soh.CustomerID,
    coalesce(soh.CreditCardID, -1)       as CreditCardID,   -- -1 = Não informado
    soh.Status,
    soh.ShipToAddressID                  as GeoKey,
    -- medidas
    sod.OrderQty                         as quantidade,
    round(sod.UnitPrice * sod.OrderQty, 4)                              as valor_bruto,
    round(sod.UnitPrice * sod.OrderQty * sod.UnitPriceDiscount, 4)      as valor_desconto,
    round(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount),4) as valor_liquido
from sod
join soh on sod.SalesOrderID = soh.SalesOrderID
