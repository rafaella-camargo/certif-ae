# certif_ae — projeto dbt (Certificação Analytics Engineering)

Transformação em dbt do modelo dimensional de vendas AdventureWorks.
Constrói o esquema estrela desenhado na Fase 3: `fct_vendas` + 7 dimensões + a bridge de motivo.

## Estrutura (3 camadas)
- **staging/** (`stg_`): 1:1 com a Silver, renomeia/tipa. Materializado como *view*.
- **intermediate/** (`int_`): lógica composta (geografia, cliente, bridge). *Ephemeral*.
- **marts/** (`dim_`/`fct_`): tabelas finais do diagrama. Materializado como *table*.

## Antes do primeiro run
1. **Ingerir a tabela `store`** na Silver (`workspace.adventureworks_silver.store`) —
   usada em `int_cliente` pro nome das lojas. Sem ela, `stg_store` falha.
2. Conectar o dbt Cloud neste repo, apontando o catálogo `workspace`.
3. `dbt deps` (instala o dbt_utils) → `dbt run` → `dbt test`.

## Fonte
Todos os models leem de `source('adventureworks', ...)`, que aponta para o schema
`workspace.adventureworks_silver` (ver `models/staging/_sources.yml`).

## Observações de modelagem (do EDA)
- `fct_vendas`: grão = 1 item de pedido; `SalesOrderID` é dimensão degenerada.
- `dim_cartao`: membro "Não informado" (CreditCardID = -1) para pedidos sem cartão.
- `dim_motivo`: membro "Sem motivo" (SalesReasonID = -1).
- `dim_cliente`: tipo por precedência de `StoreID` (Loja senão Pessoa Física) + flag `tem_contato`.
- `dim_geografia`: hierarquia cidade → estado → país (GeoKey = AddressID).
- `dim_data`: calendário gerado (date spine), com flag `ano_completo`.
- `dim_status`: constante (só 5 = Shipped), mantida por completude.
- Categoria de produto: adiada (tabelas não ingeridas) — nice-to-have.
