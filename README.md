# Certificação Analytics Engineering — Desafio (Etapa 1)

Pipeline de ingestão e análise da base **AdventureWorks** no **Databricks**, em
arquitetura medallion (Bronze → Silver → Gold), com validação de integridade e
Análise Exploratória de Dados (EDA) para responder às perguntas de negócio do desafio.

## Estrutura do repositório

```
certif-ae/
├── README.md
├── .gitignore
├── desafio/
│   └── enunciado.md                 # perguntas de negócio do desafio (a–f)
├── notebook/
│   └── Desafio AE - Etapa 1.ipynb   # pipeline + validações + EDA
└── docs/
    └── registro-de-erros.md         # log dos erros enfrentados e como foram resolvidos
```

## Base de dados

Os dados são a base pública **AdventureWorks** (arquivos CSV separados por TAB e
sem linha de cabeçalho). **Os dados brutos não são versionados neste repositório**
por serem arquivos grandes; a pasta de dados está no `.gitignore`. Para reproduzir,
carregue os CSVs em um Volume do Databricks e ajuste o caminho `CSV_DIR` na primeira
célula de configuração do notebook.

## Pipeline (resumo)

- **Bronze**: ingestão fiel, todas as colunas lidas como texto (sem inferência de schema),
  preservando o dado exatamente como na origem.
- **Silver**: tipagem explícita com verificação de perda por conversão e nomeação das colunas
  (esquema posicional do AdventureWorks).
- **Gold / análise**: cruzamentos entre fato e dimensões e EDA para as perguntas de negócio.
- **Validações**: reconciliação de contagem CSV × Delta, unicidade de chave primária,
  integridade referencial e conferência de faturamento.

## Como abrir

Importe `notebook/Desafio AE - Etapa 1.ipynb` no Databricks
(Workspace → Import → File), conecte a um cluster e execute as células na ordem.
