# Consultas sofisticadas

## Consulta 1 — Dribles e distancia da cesta

**Pergunta:** Qual combinacao de numero de dribles e distancia da cesta apresenta o maior aproveitamento de Stephen Curry em arremessos de tres pontos, e quanto esse aproveitamento supera sua media geral?

### Query Prolog

```prolog
comparacao_melhor_perfil(
    FaixaDribles,
    FaixaDistancia,
    Tentativas,
    Acertos,
    Percentual,
    MediaGeral,
    Diferenca
).
```

### Tecnicas utilizadas:

Agregacao de tentativas e acertos, calculo de aproveitamento, ordenacao dos perfis e comparacao com a media geral do Curry.

## Consulta 2 — Dribles e proximidade do defensor

**Pergunta:** Em qual categoria de dribles ocorre a maior diferenca de aproveitamento entre arremessos com defensor proximo e distante?

### Query Prolog

```prolog
ranking_diferencas_defesa(Ranking).
```

### Tecnicas utilizadas:
Agrupamento por duas caracteristicas, agregacao, calculo de diferencas entre aproveitamentos e ordenacao dos resultados.

## Consulta 3 — Perfil completo

**Pergunta:** Qual combinação de dribles, distancia da cesta e proximidade do defensor apresenta o maior aproveitamento entre os perfis com pelo menos 20 tentativas e desempenho superior às duas medias de referencia?

### Query Prolog

```prolog
ranking_perfis_superiores(Ranking).
```

### Criterios utilizados

Um perfil é incluido no ranking somente quando satisfaz simultaneamente tres condicoes:

1. Possui pelo menos 20 tentativas.
2. Seu aproveitamento supera a media geral de Curry.
3. Seu aproveitamento supera a media dos arremessos da mesma faixa de distancia.

### Tecnicas utilizadas:

Combinacao de tres categorias, agregacao, calculo de percentuais, filtragem por quantidade minima de tentativas, comparacao com duas medias e ordenacao dos perfis elegiveis.

## Consulta 4 — Consistencia temporal do perfil vencedor

**Pergunta:** O perfil vencedor da terceira investigacao mantem sua vantagem em relacao ao aproveitamento geral de Stephen Curry em diferentes metades das partidas e intervalos de datas?

### Query Prolog

```prolog
analise_temporal_melhor_perfil(RankingMetades, RankingIntervalos).
```

### Metodologia

A consulta identifica automaticamente o melhor perfil da terceira investigacao e compara seu aproveitamento com a media geral de Curry nos mesmos recortes temporais.

As comparacoes consideram:

- Primeira e segunda metades das partidas.
- Outubro a dezembro de 2014.
- Janeiro a março de 2015.

As tentativas na prorrogacao nao entram na comparacao entre metades.

### Tecnicas utilizadas:

Cmposicao de predicados auxiliares, identificacao automatica do perfil vencedor da terceira investigacao, agregacao por recortes temporais, comparacao de aproveitamentos e ordenacao das vantagens.