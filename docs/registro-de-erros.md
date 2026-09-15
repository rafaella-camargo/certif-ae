# Registro de erros — Ingestão e EDA (AdventureWorks / Databricks)

Log dos erros enfrentados na construção do pipeline (CSV para Delta em camadas
Bronze/Silver/Gold) e no EDA, do primeiro ao último. Para cada um: a mensagem,
quando ocorreu, a causa, o que significa, como foi resolvido e como evitar.

São **5 causas-raiz distintas**; algumas apareceram mais de uma vez (8 aparições no total).

---

## Erro 1 — Tabela não encontrada e reconciliação "no rows"

**Mensagem:** `[TABLE_OR_VIEW_NOT_FOUND] ... adventureworks_bronze.salesorderheader cannot be found. SQLSTATE: 42P01` (e a célula de reconciliação retornando nenhuma linha).

**Quando:** primeira execução do pipeline.

**Causa:** a variável `CSV_DIR` apontava para um caminho onde não havia arquivos.
Com a lista de arquivos vazia, o loop de carga Bronze não gravou nenhuma tabela.
A Silver, em seguida, tentou ler uma tabela que nunca foi criada.

**O que significa:** o código `42P01` indica que a tabela ou view referenciada não
existe no catálogo. Aqui foi um efeito em cascata, não a causa raiz: a tabela não
existia porque a ingestão não rodou sobre arquivo nenhum.

**Resolução:** corrigir `CSV_DIR` para o caminho real do Volume e rodar de novo as
células de config, carga e reconciliação.

**Como evitar:** depois de definir ou alterar o caminho, listar os arquivos
(`dbutils.fs.ls(CSV_DIR)`) antes de ingerir. Se vier zero arquivo, parar ali.
Tratar "no rows" na reconciliação como alarme, não como aprovação.

---

## Erro 2 — DBFS desabilitado (caminho placeholder)

**Mensagem:** `[DBFS_DISABLED] Public DBFS root is disabled. Access is denied on path: /SEU_CAMINHO_AQUI. SQLSTATE: 56038`.

**Quando:** ao recolar a célula de configuração.

**Causa:** a célula colada trazia um texto de exemplo (`SEU_CAMINHO_AQUI`) no lugar
do caminho real. Ao rodar, o Spark tentou ler literalmente esse texto como caminho.

**O que significa:** como o valor não começava com um `/Volumes/...` válido, o
Databricks o interpretou como raiz do DBFS público, que fica desabilitada por
segurança nesse tipo de workspace.

**Resolução:** substituir o placeholder pelo caminho real do Volume e rodar de novo.

**Como evitar:** revisar placeholders (textos em maiúsculas como `SEU_CAMINHO_AQUI`)
antes de executar qualquer célula colada. Manter o caminho em uma única célula de
configuração, para haver só um lugar a conferir.

---

## Erro 3 — Caracteres inválidos em nomes de coluna

**Mensagem:** `[DELTA_INVALID_CHARACTERS_IN_COLUMN_NAMES] Found invalid character(s) among ' ,;{}()\n\t=' in the column names ...` seguido de uma linha inteira de dados.

**Quando:** na carga Bronze, em praticamente todas as tabelas.

**Causa:** os arquivos do AdventureWorks são separados por TAB e não têm linha de
cabeçalho. O código lia com `sep=","` e `header="true"`. Com o separador errado, a
linha inteira virou uma única coluna; com `header=true` sem haver cabeçalho, a
primeira linha de dados foi usada como nome de coluna, trazendo tab, espaço e chaves `{}`.

**O que significa:** o Delta não aceita esses caracteres em nomes de coluna. A
mensagem apontava para o Delta, mas o problema real era de leitura (separador e
cabeçalho errados) uma etapa antes.

**Resolução:** trocar `sep` para `"\t"` e `HAS_HEADER` para `False`. Sem cabeçalho,
as colunas entram com nomes genéricos válidos (`_c0`, `_c1`, ...).

**Como evitar:** antes de ingerir, inspecionar uma amostra crua do arquivo
(`spark.read.text(caminho).show(1, truncate=False)`) para descobrir o separador e se
existe cabeçalho. Nunca assumir vírgula nem presença de cabeçalho.

---

## Erro 4 — Coluna não resolvida (`_c0` em vez do nome real)

**Mensagem:** `[UNRESOLVED_COLUMN.WITH_SUGGESTION] A column ... with name 'SalesOrderID' cannot be resolved. Did you mean [_c0, _c1, _c10, ...]. SQLSTATE: 42703`.

**Quando:** na montagem da Silver, depois de corrigir a leitura do Bronze.

**Causa:** como os arquivos não têm cabeçalho, o Bronze ficou com colunas
`_c0.._cN`, mas a célula de tipagem se referia aos nomes reais (`SalesOrderID`, etc.),
que ainda não existiam.

**O que significa:** o código `42703` indica referência a uma coluna inexistente. Os
nomes reais só passam a existir depois da etapa de nomeação.

**Resolução:** mapear `_c0.._cN` para os nomes reais, na ordem correta do esquema do
AdventureWorks, dentro da Silver, com uma trava que compara a quantidade de colunas
do arquivo com a do esquema esperado e aborta se divergir (evitando nomear errado).

**Como evitar:** quando a origem não tem cabeçalho, planejar a nomeação (esquema
posicional) como parte da Silver desde o início, e conferir visualmente que cada nome
bate com o conteúdo da coluna.

---

## Erro 5 — NameError: nome não definido (recorrente)

**Mensagem:** `NameError: name 'X' is not defined`, com `X` sendo `arquivos`, depois
`CATALOG`, depois `construir_silver`, em momentos diferentes.

**Quando:** várias vezes, ao rodar uma célula depois de o cluster reiniciar, ao abrir
o notebook em nova sessão, ou ao executar uma célula de baixo sem ter rodado as de cima.

**Causa:** variáveis e funções só existem na memória depois que a célula que as define
é executada na sessão atual. Quando o cluster dorme ou reinicia, essa memória é zerada.

**O que significa:** o Python não conhece aquele nome na sessão atual. Importante: as
tabelas Delta continuam salvas no catálogo. O que se perde é apenas o estado em
memória (variáveis e funções), não os dados.

**Resolução:** rodar as células de configuração e de definição do topo antes das
demais, ou usar `Run all`.

**Como evitar:** manter no topo do notebook as células de configuração e de definição
de funções; ao reabrir o notebook depois de um tempo, começar com `Run all`; e escrever
cada célula o mais independente possível.

---

## Padrões que se repetiram (as lições)

**Ler o dado antes de assumir o formato.** Os erros 1, 3 e 4 vieram de suposições
sobre caminho, separador e cabeçalho. Uma inspeção rápida da origem elimina os três
antes de acontecerem.

**Validar em vez de confiar no "rodou".** "No rows" e "rodou sem erro" não significam
sucesso. As checagens de contagem, unicidade de chave e integridade referencial são o
que de fato prova que está certo.

**Ordem de execução e estado da sessão.** A maior parte dos `NameError` não é erro de
código, e sim de ordem. Em notebook, `Run all` ao reabrir resolve.

**Revisar o que se cola.** Placeholders deixados no código (erro 2) são fáceis de
evitar com uma conferência antes de executar.

Depuração de ingestão é parte normal do trabalho de engenharia de dados. O valor está
em entender a causa de cada erro, que é o que este registro documenta.
