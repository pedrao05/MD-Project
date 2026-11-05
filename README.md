# Knowledge Engine — Analise de Arremessos de Stephen Curry

## 1. Apresentacao

A investigacao utiliza registros de arremessos de tres pontos de Stephen Curry para estudar associacoes entre o aproveitamento do jogador e diferentes caracteristicas das tentativas, como numero de dribles, distancia da cesta, proximidade do defensor e momento da partida.

Densenvolvi quatro investigacoes, envolvendo agregacao, comparacao, ordenacao de resultados e composicao de predicados auxiliares.

O projeto utiliza python para a filtragem e transformacao dos dados em fatos prolog. As classificacoes, os calculos de aproveitamento e as quatro consultas sao realizados em prolog, utilizando o ambiente SWISH.

## 2. Dataset

Os dados foram obtidos do dataset **NBA Shot Logs** no Kaggle.

**Fonte:** https://www.kaggle.com/datasets/dansbecker/nba-shot-logs/data

## 3. Estrutura do repositorio

O projeto esta organizado da seguinte forma:

```text
MD-PROJECT/
├── consultas/
│   └── consultas.md
├── data/
│   └── shot_logs.csv
├── etl/
│   └── gerar_base.py
├── prolog/
│   ├── fatos.pl
│   └── regras.pl
├── .gitignore
├── README.md
└── requirements.txt
```

### Descricao dos arquivos

| Arquivo | Finalidade |
|---|---|
| `data/shot_logs.csv` | Arquivo CSV original obtido do kaggle, utilizado como entrada do ETL |
| `etl/gerar_base.py` | Script python responsavel por filtrar, transformar e converter os dados em fatos Prolog |
| `prolog/fatos.pl` | Base de conhecimento gerada automaticamente, contendo os 456 fatos `arremesso/6` |
| `prolog/regras.pl` | Predicados prolog responsaveis por classificacoes, agregacoes, comparacoes e rankings |
| `consultas/consultas.md` | Documentacao das quatro perguntas e queries prolog |
| `requirements.txt` | Dependencias python necessarias para executar o ETL |
| `.gitignore` | Define arquivos e diretorios que nao devem ser enviados ao repositorio |

**Observacao:** o arquivo CSV original nao é incluido no repositorio. Para executar o ETL, é necessario obte-lo no kaggle e salva-lo em `data/shot_logs.csv`.

## 4. Passos da construcao do projeto

A construcao do Knowledge Engine foi dividida em etapas, desde a definicao das perguntas e a selecao dos dados ate a implementacao e validacao das consultas em prolog.

### 4.1. Escolhendo o dataset

O primeiro passo foi escolher um dataset de interesse que fosse adequado para formular uma investigacao interessante por meio de consultas em prolog.

O dataset NBA shot logs chamou a minha atencao por duas razoes principais:
1) Gosto muito de basquete e, no meu projeto final de matematica da escola, investiguei o angulo ideal de lancamento para acertar uma cesta de tres pontos. Depois de ver o dataset, tive a ideia de ampliar meu interesse pelo tema, analisando como outras caracteristicas dos arremessos, como distancia da cesta, dribles e proximidade do defensor, estao associadas ao aproveitamento.
2) O dataset apresenta informacoes quantitativas, como distancia da cesta e numero de dribles, e qualitativas, como resultado do arremesso. Essa combinaco permite construir fatos prolog e definir regras para classificar e comparar diferentes situacoes de arremesso.

Para reduzir o volume de dados e tornar a base de conhecimento mais facil de manipular no SWISH, decidi concentrar a analise nos arremessos de um unico jogador. Entao eu escolhi o Stephen Curry por sua relevancia nos arremessos de tres pontos.

### 4.2. Definicao da investigacao e das perguntas

A partir do dataset, defini quatro perguntas para orientar a construcao da base de conhecimento:

1. **Dribles e distancia:** qual combinacao de numero de dribles e distancia da cesta apresenta o maior aproveitamento de Stephen Curry em arremessos de tres pontos, e quanto esse aproveitamento supera sua media geral?
2. **Dribles e proximidade do defensor:** em qual categoria de dribles ocorre a maior diferenca de aproveitamento entre arremessos com defensor proximo e distante?
3. **Perfil completo:** qual combinação de dribles, distâancia da cesta e proximidade do defensor apresenta o maior aproveitamento entre os perfis com pelo menos 20 tentativas e desempenho superior às duas medias de referencia?
4. **Consistencia temporal:** o perfil vencedor da terceira investigacao mantem sua vantagem em relacao ao aproveitamento geral de Stephen Curry em diferentes metades das partidas e intervalos de datas?

As perguntas foram organizadas de forma progressiva: comecei comparando dribles e distancia da cesta, acrescentei a proximidade do defensor, combinei as tres características para identificar perfis mais especificos e, por fim, investiguei o desempenho temporal do perfil vencedor.

### 4.3. Construcao da base de conhecimento

Com base nas perguntas que defini, comecei a construir a base de conhecimento para as coonsultas em Prolog com o processo de ETL no arquivo `etl/gerar_base.py`.

#### 4.3.1 Filtragem dos registros

O script le o arquivo original `data/shot_logs.csv`, obtido do conjunto de dados NBA Shot Logs no Kaggle.

Para a construcao da base de conhecimento, selecionei apenas as tentativas de tres pontos realizadas por Stephen Curry usando filtragem e manipulacao de dados que aprendi em CDados. 

Apos a filtragem, a base utilizada no projeto ficou com:

- **456 tentativas** de tres pontos.
- **190 arremessos convertidos**.
- **266 arremessos nao convertidos**.
- **41,67% de aproveitamento geral**.

#### 4.3.2 Campos utilizados

Selecionei seis campos para representar cada arremesso em Prolog:

| Campo original | Significado |
|---|---|
| `SHOT_DIST` | Distancia entre o jogador e a cesta, em pes |
| `CLOSE_DEF_DIST` | Distancia do defensor mais proximo, em pes |
| `DRIBBLES` | Quantidade de dribles antes do arremesso |
| `SHOT_RESULT` | Resultado do arremesso (`made` ou `missed`) |
| `PERIOD` | Periodo da partida em que ocorreu o arremesso |
| `MATCHUP` | Informacao da partida utilizada para extrair a data |

#### 4.3.3 Transformacao dos dados

Para representar os arremessos em prolog, o ETL realiza as seguintes transformacoes:

1. Seleciona as informacoes dos 6 campos.
2. Extrai a data da informação original contida na coluna `MATCHUP`.
3. Converte a data para uma estrutura prolog no formato `data(Ano, Mes, Dia)`.
4. Organiza os seis atributos na ordem definida pelo predicado `arremesso/6`.

Os campos de identificação do CSV (`GAME_ID`, `player_id`, `SHOT_NUMBER`) tambem sao utilizados durante o processamento para verificar a existencia de registros duplicados, mas nao sao incluidos nos fatos finais. Fiz verificacoes com `assert` para valores ausentes, resultados invalidos, duplicatas, distancias negativas e conversao das datas.

#### 4.3.4 Geracao dos fatos prolog

A funcao `formatar_fato` converte cada registro para um fato Prolog, seguindo o esquema de seis argumentos:
`arremesso(DistanciaCesta, DistanciaDefensor, Dribles, Resultado, Periodo, Data).`

Exemplo de fato gerado:

```prolog
arremesso(25.9, 3.0, 0, missed, 1, data(2015, 3, 4)).
```

Nesse exemplo, o arremesso foi realizado a 25,9 pes da cesta, com o defensor mais proximo a 3 pes, sem dribles, no primeiro periodo da partida de 4 de março de 2015, e nao foi convertido.

Ao final do processamento, o script gera automaticamente o arquivo `prolog/fatos.pl`, contendo **456 fatos `arremesso/6`**.

### 4.4. Construcao das regras prolog e relacao com a Logica de Predicados

Apos gerar os fatos, utilizei conceitos de Logica de Predicados para formalizar as quatro perguntas e orientar a construcao das regras em prolog/regras.pl. As expressoes logicas caracterizam os resultados procurados, enquanto os predicados prolog realizam as classificacoes, agregacoes e comparacoes necessarias. Eu ultilizei Logica de Predicados com funcoes numericas e relacoes de ordem, pois os percentuais e as diferencas sao calculados numericamente.

#### 4.4.1. Criterios de classificação utilizados nas consultas

Para realizar as analises em prolog, agrupei os valores quantitativos dos arremessos em categorias por meio de regras definidas no arquivo `prolog/regras.pl`.

Foram adotados os seguintes criterios:

| Atributo | Categoria Prolog | Criterio |
|---|---|---|
| Numero de dribles | `sem_dribles` | 0 dribles |
| Numero de dribles | `um_ou_dois` | 1 ou 2 dribles |
| Numero de dribles | `tres_ou_mais` | 3 ou mais dribles |
| Distancia da cesta | `ate_25_pes` | Até 25 pes, inclusive |
| Distancia da cesta | `acima_25_pes` | Acima de 25 pes |
| Distancia do defensor | `defensor_proximo` | Menos de 4 pes |
| Distancia do defensor | `defensor_distante` | 4 pes ou mais |

**Exemplo:**
```prolog
faixa_dribles(D, sem_dribles) :-
    integer(D),
    D =:= 0.
```

Essa regra classifica um valor como sem_dribles quando ele é inteiro e igual a zero.

#### 4.4.2 Primeira pergunta — Dribles e distancia da cesta

**Formalizacao em Logica de Predicados**

A primeira pergunta busca identificar a combinacao de numero de dribles e distancia da cesta com maior aproveitamento de tres pontos, comparando esse resultado com a media geral do jogador.

Para representar essa investigacao utilizando Logica de Predicados, defini:

$P(x)$: $x$ é um perfil valido de dribles e distancia, com pelo menos uma tentativa.

$A(x)$: aproveitamento percentual do perfil $x$.

$G$: aproveitamento geral de Stephen Curry na amostra.

A condicao que caracteriza a existencia de um perfil com aproveitamento maximo é:

$$
\exists x\left(
P(x)\land
\forall y(P(y)\rightarrow A(x)\geq A(y))
\right)
$$

Essa expressao afirma que existe um perfil valido cujo aproveitamento é maior ou igual ao de qualquer outro perfil valido.

A segunda parte da investigacao consiste em calcular a diferença entre o aproveitamento do perfil vencedor e a media geral:

$$
\Delta(x)=A(x)-G
$$

**Construcao das regras prolog da primeira pergunta**

**1. Classificacao dos arremessos**

Primeiro, criei os predicados `faixa_dribles/2` e `faixa_distancia/2` para classificar os valores numericos em categorias.

Essas classificacoes permitem representar os perfis $P(x)$ como combinacoes das tres faixas de dribles e das duas faixas de distancia, totalizando seis combinacoes possiveis.

**2. Calculo do aproveitamento**

Em seguida, desenvolvi `tentativas_por_perfil/3` e `acertos_por_perfil/3`, utilizando `aggregate_all/3` para contar os registros que satisfazem simultaneamente as condicoes de dribles e distancia.

Essas contagens sao utilizadas por `aproveitamento_por_perfil/5` para calcular $A(x)$:

$$
A(x)=\frac{\operatorname{Acertos}(x)}{\operatorname{Tentativas}(x)}\times100
$$

**3. Identificacao do melhor perfil**

Na formalizacao logica, o quantificador universal $\forall y$ representa a comparacao do aproveitamento de um perfil com todos os outros perfis validos.

Para implementar essa ideia, criei `ranking_perfis/1`. Esse predicado utiliza `member/2` para percorrer as combinacoes possiveis, `findall/3` para reunir seus aproveitamentos e `keysort/2` e `reverse/2` para organiza-los em ordem decrescente.

Dessa forma, o primeiro elemento do ranking corresponde a um perfil com aproveitamento maximo.

**4. Comparacao com a media geral**

Por fim, criei `comparacao_melhor_perfil/7`, que recupera o primeiro perfil do ranking e utiliza `aproveitamento_geral/3` para calcular sua diferenca em relacao à media geral (medida em pontos percentuais).

Assim, a primeira pergunta é respondida pela composicao de varios predicados auxiliares, aplicando classificacoes, conjuncoes de condicoes, agregacoes, comparacoes e ordenacao.

O prolog não executa literalmente a expressao com $\forall y$. Em vez disso, enumera os perfis, calcula seus aproveitamentos e os ordena, permitindo identificar o maximo entre as combinacoes consideradas.

#### 4.4.3 Segunda pergunta — Dribles e proximidade do defensor

**Formalizacao em Logica de Predicados**

A segunda pergunta busca identificar em qual categoria de dribles ocorre a maior diferenca de aproveitamento entre arremessos com defensor proximo e distante.

Para formalizar essa investigacao em Logica de Predicados, defini:

- $C(x)$: $x$ é uma categoria valida de dribles, com tentativas nos dois grupos.
- $A_d(x)$: aproveitamento com defensor distante.
- $A_p(x)$: aproveitamento com defensor próximo.
- $\Delta(x)=A_d(x)-A_p(x)$: diferenca de aproveitamento.

A condicao que caracteriza a categoria com maior diferenca é:

$$
\exists x\left(C(x)\land\forall y\left(C(y)\rightarrow\Delta(x)\geq\Delta(y)\right)\right)
$$

Essa expressao indica que existe uma categoria cuja diferenca de aproveitamento é maior ou igual à de todas as outras categorias validas.

**Construcao das regras prolog da segunda pergunta**

**1. Classificacao da proximidade do defensor**

Primeiro, criei o predicado `categoria_defensor/2` para classificar os arremessos em duas categorias: `defensor_proximo` e `defensor_distante`.

Entao combinei faixa_dribles/2 e categoria_defensor/2 para formar seis grupos de arremessos.

**2. Calculo dos aproveitamentos**

Em seguida, desenvolvi `tentativas_por_defesa/3` e `acertos_por_defesa/3`, utilizando `aggregate_all/3` para contar os arremessos que satisfazem simultaneamente as condicoes de dribles e proximidade do defensor.

Esses resultados sao utilizados por `aproveitamento_por_defesa/5` para calcular os percentuais $A_d(x)$ e $A_p(x)$.

**3. Calculo da diferença entre aproveitamentos**

Para representar a funcao $\Delta(x)$ da formalizacao, criei o predicado `diferenca_defesa_por_dribles/4`.

Assim, uma diferenca positiva indica maior aproveitamento com defensor distante, enquanto uma diferenca negativa indica maior aproveitamento com defensor proximo.

**4. Identificacao da categoria com maior diferenca**

Na formalização logica, o quantificador universal $\forall y$ representa a comparacao da diferenca de uma categoria com todas as demais categorias validas.

Para implementar essa ideia, desenvolvi `ranking_diferencas_defesa/1`, que organiza as categorias pela diferenca de aproveitamento em ordem decrescente, identificando aquela com maior diferenca.

A segunda pergunta é respondida pela composicao desses predicados, combinando classificacao, conjuncao de condicoes, agregacao, comparacao e ordenacao.

#### 4.4.4 Terceira pergunta — Perfil completo de arremesso

**Formalizacao em Logica de Predicados**

A terceira pergunta busca identificar o perfil com maior aproveitamento, combinando numero de dribles, distancia da cesta e proximidade do defensor, considerando apenas os perfis que atendem aos criterios estabelecidos. Para evitar a selecao de perfis com poucas observacoes, eu coloquei um limite minimo de 20 tentativas para os perfis.

Para formalizar essa investigacao em Logica de Predicados, defini:

- $T(x)$: o perfil $x$ possui pelo menos 20 tentativas.
- $G(x)$: o aproveitamento de $x$ supera a media geral de Curry.
- $D(x)$: o aproveitamento de $x$ supera a media da sua faixa de distancia.
- $E(x)$: o perfil $x$ é elegivel.
- $A(x)$: aproveitamento percentual do perfil $x$.

A condicao de elegibilidade é:

$$
\forall x\left(
E(x)\leftrightarrow
(T(x)\land G(x)\land D(x))
\right)
$$

Nesta formalizacao, o dominio considerado é formado pelos 12 perfis possiveis, obtidos pelas combinacoes das tres categorias de dribles, duas faixas de distancia e duas categorias de proximidade do defensor.

A condicao que caracteriza o melhor perfil elegivel é:

$$
\exists x\left(E(x)\land\forall y\left(E(y)\rightarrow A(x)\geq A(y)\right)\right)
$$

Essa expressao indica que existe um perfil que satisfaz simultaneamente os tres criterios e cujo aproveitamento é maior ou igual ao de qualquer outro perfil elegivel.

**Construcao das regras prolog da terceira pergunta**

**1. Combinacao das tres caracteristicas**

Primeiro, reutilizei os predicados `faixa_dribles/2`, `faixa_distancia/2` e `categoria_defensor/2` para classificar os arremessos.

**2. Calculo do aproveitamento por perfil completo**

Em seguida, desenvolvi `tentativas_por_perfil_completo/4` e `acertos_por_perfil_completo/4`, utilizando `aggregate_all/3` para contar os registros que satisfazem simultaneamente as tres condicoes.

Essas contagens sao utilizadas por `aproveitamento_por_perfil_completo/6` para calcular $A(x)$.

**3. Definicao dos criterios de elegibilidade**

Para implementar a condicao de elegibilidade $E(x)$, combinei tres verificacoes: o minimo de 20 tentativas, a comparacao com a media geral e a comparacao com a media da faixa de distancia. Para isso, utilizei `aproveitamento_geral/3` e `aproveitamento_por_distancia/4`, que fornecem as medias de referencia utilizadas nas comparacoes.

**4. Selecao e ordenacao dos perfis elegiveis**

Na formalizacao logica, o quantificador universal $\forall y$ representa a comparacao do aproveitamento de um perfil elegivel com todos os demais perfis elegiveis.

Para implementar essa ideia, desenvolvi `ranking_perfis_superiores/1`, que aplica os criterios de elegibilidade e ordena os perfis selecionados por aproveitamento decrescente.

A terceira pergunta é respondida pela composicao desses predicados, aplicando conjuncao de condicoes, agregacoes, comparacoes com duas medias, filtragem e ordenacao de resultados.

#### 4.4.5 Quarta pergunta — Consistencia temporal do perfil vencedor

**Formalizacao em Logica de Predicados**

A quarta pergunta busca verificar se o perfil vencedor da terceira investigacao mantem sua vantagem sobre a media geral de Curry em diferentes metades das partidas e intervalos de datas.

Para formalizar essa investigação em Logica de Predicados, defini:

- $V(x)$: $x$ é o perfil vencedor da terceira investigacao.
- $T(t)$: $t$ é um dos quatro recortes temporais analisados.
- $A(x,t)$: aproveitamento do perfil $x$ no recorte $t$.
- $G(t)$: aproveitamento geral de Curry no mesmo recorte $t$.

A condicao que caracteriza a manutencao da vantagem é:

$$
\exists x\left(V(x)\land\forall t\left(T(t)\rightarrow A(x,t)>G(t)\right)\right)
$$

Essa expressao indica que existe um perfil vencedor cujo aproveitamento supera a media geral em todos os recortes temporais considerados.

**Construcao das regras prolog da quarta pergunta**

**1. Reutilizacao do perfil vencedor**

Primeiro, desenvolvi o predicado melhor_perfil_superior/3, que reutiliza ranking_perfis_superiores/1 para recuperar automaticamente o perfil vencedor da terceira investigacao.

**2. Classificacao dos recortes temporais**

Em seguida, utilizei os campos de periodo e data dos arremessos para estabelecer dois tipos de comparacao:

- **Metades das partidas:** primeira metade (periodos 1 e 2) e segunda metade (periodos 3 e 4), sem incluir as prorrogacoes.
- **Intervalos de datas:** outubro a dezembro de 2014 e janeiro a março de 2015.

As prorrogacoes nao sao consideradas na divisao por metades, mas permanecem incluidas na analise por intervalos de datas.

O predicado `metade_partida/2` permite identificar a metade correspondente ao periodo de cada arremesso. Tambem foram definidas condicoes para classificar os registros nos intervalos de datas.

**3. Calculo dos aproveitamentos por recorte**

Para cada recorte temporal, desenvolvi regras que contam as tentativas e os acertos do perfil vencedor e do conjunto geral de arremessos de Curry.

Com esses valores, calculei os aproveitamentos $A(x,t)$ e $G(t)$, alem da diferenca:

$$
\Delta(x,t)=A(x,t)-G(t)
$$

Uma diferenca positiva indica que o perfil vencedor superou a media geral naquele recorte.

**4. Comparacao e organizacao dos resultados**

Na formalizacao logica, o quantificador universal $\forall t$ expressa a condicao de que o perfil vencedor apresente aproveitamento superior à media geral em todos os recortes considerados.

Para investigar essa propriedade, desenvolvi `analise_temporal_melhor_perfil/2`, que combina as regras anteriores e retorna dois rankings: um para as metades das partidas e outro para os intervalos de datas.

Os rankings sao organizados pela diferenca de aproveitamento em ordem decrescente, permitindo verificar se a vantagem do perfil permanece positiva em cada recorte.

Assim, a quarta pergunta é respondida pela composicao de predicados ja existentes com novas regras de classificacao temporal, agregacao, comparacao e ordenacao.

### 4.5. Testes e validacao das consultas prolog

Realizei os testes no SWISH, inserindo os conteudos de `prolog/fatos.pl` e `prolog/regras.pl` em **Program** e executando as consultas em **Query**.

Verifiquei a coerencia das contagens, dos percentuais, da ordenacao dos rankings e da reutilizacao do perfil vencedor. Apos reorganizar as regras, executei novamente as quatro consultas e confirmei que os resultados permaneceram consistentes.

As consultas estao documentadas em `consultas/consultas.md`.

## 5. Como executar o projeto

O projeto utiliza python para gerar a base de fatos e prolog para executar as consultas. As consultas foram desenvolvidas e testadas no ambiente online SWISH.

### 5.1. Pre-requisitos

Para reproduzir o projeto, sao necessarios:

- O arquivo original `shot_logs.csv`, disponivel no kaggle.
- Os arquivos deste repositorio.

### 5.2. Preparar os dados

1. Obtenha o arquivo `shot_logs.csv` a partir do dataset indicado na seção 2.
2. Na pasta principal do projeto, crie o diretorio `data/`, caso ele ainda nao exista.
3. Coloque o arquivo CSV no seguinte caminho:

`data/shot_logs.csv`

### 5.3. Configurar o ambiente python

Abra um terminal na pasta principal do projeto.

Crie um ambiente virtual:

```bash
python3 -m venv venv
```

Instale as dependencias:

```bash
./venv/bin/python -m pip install -r requirements.txt
```

### 5.4. Executar o ETL

Com o arquivo CSV na localizacao indicada, execute:

```bash
./venv/bin/python etl/gerar_base.py
```

O script realizara a leitura dos dados, a filtragem dos arremessos de tres pontos de Stephen Curry, a selecao e transformacao dos atributos e a geracao dos fatos prolog.

Apos a execucao, o arquivo `prolog/fatos.pl` devera conter **456 fatos** no formato `arremesso/6`.

O arquivo gerado podera ser utilizado diretamente como base das consultas prolog.

### 5.5. Preparar o ambiente prolog

As consultas podem ser executadas no ambiente online [SWISH — SWI-Prolog](https://swish.swi-prolog.org/).

No SWISH, existem duas areas principais:

- **Program:** contem os fatos e as definicoes dos predicados.
- **Query:** recebe as perguntas que serao executadas sobre a base de conhecimento.

Para preparar o ambiente:

1. Acesse o SWISH.
2. Abra `prolog/fatos.pl` e copie todo o seu conteudo para a area **Program**.
3. Abra `prolog/regras.pl` e acrescente seu conteudo abaixo dos fatos, na mesma area **Program**.
4. Utilize a area **Query** para executar as consultas documentadas no arquivo `consultas/consultas.md`.

Os arquivos `fatos.pl` e `regras.pl` devem estar carregados antes da execucao das consultas principais.

## 6. Resultados obtidos

### 6.1. Consulta 1 — Dribles e distancia

A combinação com maior aproveitamento foi a de **tres ou mais dribles e distancia superior a 25 pes da cesta**.

| Indicador | Resultado |
|---|---|
| Faixa de dribles | 3 ou mais |
| Distancia da cesta | Acima de 25 pes |
| Tentativas | 99 |
| Acertos | 47 |
| Aproveitamento do perfil | 47,47% |
| Aproveitamento geral | 41,67% |
| Vantagem | +5,81 pontos percentuais |

### 6.2. Consulta 2 — Dribles e proximidade do defensor

A maior diferenca positiva entre os aproveitamentos com defensor distante e proximo ocorreu nos arremessos **sem dribles**.

| Defensor proximo | Defensor distante | Diferenca |
|---:|---:|---:|
| 26,98% | 47,65% | +20,67 |

Nas categorias de 1 ou 2 dribles e de 3 ou mais dribles, as diferencas foram negativas, indicando maior aproveitamento com defensor proximo nesses grupos.

### 6.3. Consulta 3 — Perfil completo

Dos 12 perfis possiveis, seis atenderam aos criterios estabelecidos.

O perfil com maior aproveitamento foi:

- **Dribles:** sem dribles.
- **Distancia da cesta:** até 25 pes.
- **Defensor:** distante (4 pes ou mais).
- **Tentativas:** 98.
- **Acertos:** 48.
- **Aproveitamento:** 48,98%.

Esse perfil superou a media geral de Curry (41,67%) em  **7,31 pontos percentuais** e a media dos arremessos a ate 25 pes (42,32%) em **6,66 pontos percentuais**.

### 6.4. Consulta 4 — Consistencia temporal

O perfil vencedor da terceira investigacao apresentou vantagem positiva sobre a media geral em todos os quatro recortes temporais analisados.

| Recorte temporal | Vantagem |
|---|---:|
| Primeira metade das partidas | +6,90 p.p. |
| Segunda metade das partidas | +9,40 p.p. |
| Outubro a dezembro de 2014 | +7,57 p.p. |
| Janeiro a março de 2015 | +6,34 p.p. |

Os resultados mostram que a vantagem do perfil vencedor nao ficou restrita a apenas uma das metades das partidas ou a um dos intervalos de datas considerados.