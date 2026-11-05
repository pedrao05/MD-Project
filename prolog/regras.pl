% ============================================================
% 1. CLASSIFICACAO DOS ARREMESSOS
% ============================================================

% Classifica arremessos realizados sem dribles
faixa_dribles(D, sem_dribles) :-
    integer(D),
    D =:= 0.

% Classifica arremessos realizados com 1 ou 2 dribles
faixa_dribles(D, um_ou_dois) :-
    integer(D),
    D >= 1,
    D =< 2.

% Classifica arremessos realizados com 3 ou mais dribles
faixa_dribles(D, tres_ou_mais) :-
    integer(D),
    D >= 3.

% Classifica arremessos realizados a até 25 pés
faixa_distancia(D, ate_25_pes) :-
    number(D),
    D >= 0,
    D =< 25.

% Classifica arremessos realizados acima de 25 pés
faixa_distancia(D, acima_25_pes) :-
    number(D),
    D > 25.

% Classifica arremessos com defensor a menos de 4 pes
categoria_defensor(D, defensor_proximo) :-
    number(D),
    D >= 0,
    D < 4.

% Classifica arremessos com defensor a 4 pes ou mais
categoria_defensor(D, defensor_distante) :-
    number(D),
    D >= 4.

% ============================================================
% 2. APROVEITAMENTO GERAL
% ============================================================

% Calcula o aproveitamento geral de tres pontos
aproveitamento_geral(Tentativas, Acertos, Percentual) :-
    aggregate_all(
        count,
        arremesso(_, _, _, _, _, _),
        Tentativas
    ),
    Tentativas > 0,
    aggregate_all(
        count,
        arremesso(_, _, _, made, _, _),
        Acertos
    ),
    Percentual is (Acertos / Tentativas) * 100.

% ============================================================
% 3. CONSULTA 1 - DRIBLES E DISTANCIA
% ============================================================

% Conta tentativas por faixa de dribles e distancia
tentativas_por_perfil(FaixaDribles, FaixaDistancia, Total) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, _, Dribles, _, _, _),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia)
        ),
        Total
    ).

% Conta acertos por faixa de dribles e distancia
acertos_por_perfil(FaixaDribles, FaixaDistancia, Acertos) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, _, Dribles, made, _, _),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia)
        ),
        Acertos
    ).

% Calcula o aproveitamento por faixa de dribles e distancia
aproveitamento_por_perfil(FaixaDribles, FaixaDistancia, Tentativas, Acertos, Percentual) :-
    tentativas_por_perfil(FaixaDribles, FaixaDistancia, Tentativas),
    acertos_por_perfil(FaixaDribles, FaixaDistancia, Acertos),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Ordena os perfis de dribles e distancia por aproveitamento
ranking_perfis(Ranking) :-
    findall(
        Percentual-perfil(FaixaDribles, FaixaDistancia, Tentativas, Acertos),
        (
            member(FaixaDribles, [sem_dribles, um_ou_dois, tres_ou_mais]),
            member(FaixaDistancia, [ate_25_pes, acima_25_pes]),
            aproveitamento_por_perfil(
                FaixaDribles,
                FaixaDistancia,
                Tentativas,
                Acertos,
                Percentual
            )
        ),
        Lista
    ),
    keysort(Lista, Ordenada),
    reverse(Ordenada, Ranking).

% Identifica o melhor perfil e compara com a media geral
comparacao_melhor_perfil(
    FaixaDribles,
    FaixaDistancia,
    Tentativas,
    Acertos,
    Percentual,
    MediaGeral,
    Diferenca
) :-
    ranking_perfis([
        Percentual-perfil(FaixaDribles, FaixaDistancia, Tentativas, Acertos)
        | _
    ]),
    aproveitamento_geral(_, _, MediaGeral),
    Diferenca is Percentual - MediaGeral.


% ============================================================
% 4. CONSULTA 2 - DRIBLES E DEFENSOR
% ============================================================

% Conta tentativas por faixa de dribles e proximidade do defensor
tentativas_por_defesa(FaixaDribles, CategoriaDefensor, Total) :-
    aggregate_all(
        count,
        (
            arremesso(_, DistanciaDefensor, Dribles, _, _, _),
            faixa_dribles(Dribles, FaixaDribles),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor)
        ),
        Total
    ).

% Conta acertos por faixa de dribles e proximidade do defensor
acertos_por_defesa(FaixaDribles, CategoriaDefensor, Acertos) :-
    aggregate_all(
        count,
        (
            arremesso(_, DistanciaDefensor, Dribles, made, _, _),
            faixa_dribles(Dribles, FaixaDribles),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor)
        ),
        Acertos
    ).

% Calcula o aproveitamento por faixa de dribles e proximidade do defensor
aproveitamento_por_defesa(FaixaDribles, CategoriaDefensor, Tentativas, Acertos, Percentual) :-
    tentativas_por_defesa(FaixaDribles, CategoriaDefensor, Tentativas),
    acertos_por_defesa(FaixaDribles, CategoriaDefensor, Acertos),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Compara o aproveitamento entre defensor distante e proximo
diferenca_defesa_por_dribles(
    FaixaDribles,
    PercentualProximo,
    PercentualDistante,
    Diferenca
) :-
    aproveitamento_por_defesa(
        FaixaDribles, defensor_proximo,
        _, _, PercentualProximo
    ),
    aproveitamento_por_defesa(
        FaixaDribles, defensor_distante,
        _, _, PercentualDistante
    ),
    Diferenca is PercentualDistante - PercentualProximo.

% Ordena as diferencas de aproveitamento por categoria de dribles
ranking_diferencas_defesa(Ranking) :-
    findall(
        Diferenca-perfil(FaixaDribles, PercentualProximo, PercentualDistante),
        (
            member(FaixaDribles, [sem_dribles, um_ou_dois, tres_ou_mais]),
            diferenca_defesa_por_dribles(
                FaixaDribles,
                PercentualProximo,
                PercentualDistante,
                Diferenca
            )
        ),
        Lista
    ),
    keysort(Lista, Ordenada),
    reverse(Ordenada, Ranking).


% ============================================================
% 5. CONSULTA 3 - PERFIL COMPLETO
% ============================================================

% Conta tentativas combinando dribles, distancia e defensor
tentativas_por_perfil_completo(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Total
) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, DistanciaDefensor, Dribles, _, _, _),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor)
        ),
        Total
    ).

% Conta acertos combinando dribles, distancia e defensor
acertos_por_perfil_completo(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Acertos
) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, DistanciaDefensor, Dribles, made, _, _),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor)
        ),
        Acertos
    ).

% Calcula o aproveitamento combinando dribles, distancia e defensor
aproveitamento_por_perfil_completo(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Tentativas,
    Acertos,
    Percentual
) :-
    tentativas_por_perfil_completo(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Tentativas
    ),
    acertos_por_perfil_completo(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Acertos
    ),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Calcula o aproveitamento por faixa de distancia
aproveitamento_por_distancia(FaixaDistancia, Tentativas, Acertos, Percentual) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia1, _, _, _, _, _),
            faixa_distancia(Distancia1, FaixaDistancia)
        ),
        Tentativas
    ),
    aggregate_all(
        count,
        (
            arremesso(Distancia2, _, _, made, _, _),
            faixa_distancia(Distancia2, FaixaDistancia)
        ),
        Acertos
    ),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Ordena os perfis com pelo menos 20 tentativas e aproveitamento superior as duas medias
ranking_perfis_superiores(Ranking) :-
    findall(
        Percentual-perfil(
            FaixaDribles,
            FaixaDistancia,
            CategoriaDefensor,
            Tentativas,
            Acertos
        ),
        (
            member(FaixaDribles, [sem_dribles, um_ou_dois, tres_ou_mais]),
            member(FaixaDistancia, [ate_25_pes, acima_25_pes]),
            member(CategoriaDefensor, [defensor_proximo, defensor_distante]),

            aproveitamento_por_perfil_completo(
                FaixaDribles,
                FaixaDistancia,
                CategoriaDefensor,
                Tentativas,
                Acertos,
                Percentual
            ),

            Tentativas >= 20,

            aproveitamento_geral(_, _, MediaGeral),

            aproveitamento_por_distancia(
                FaixaDistancia,
                _, _,
                MediaDistancia
            ),

            Percentual > MediaGeral,
            Percentual > MediaDistancia
        ),
        Lista
    ),
    keysort(Lista, Ordenada),
    reverse(Ordenada, Ranking).

% Identifica o perfil com maior aproveitamento entre aqueles que atendem aos criterios da terceira investigacao
melhor_perfil_superior(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor
) :-
    ranking_perfis_superiores([
        _-perfil(
            FaixaDribles,
            FaixaDistancia,
            CategoriaDefensor,
            _,
            _
        )
        | _
    ]).

% ============================================================
% 6. CONSULTA 4 - ANALISE POR METADES
% ============================================================

% Classifica os periodos da partida em duas metades
metade_partida(P, primeira_metade) :-
    integer(P),
    member(P, [1, 2]).

metade_partida(P, segunda_metade) :-
    integer(P),
    member(P, [3, 4]).

% Conta tentativas de um perfil em determinada metade da partida
tentativas_perfil_por_metade(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Metade,
    Total
) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, DistanciaDefensor, Dribles, _, Periodo, _),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor),
            metade_partida(Periodo, Metade)
        ),
        Total
    ).

% Conta acertos de um perfil em determinada metade da partida
acertos_perfil_por_metade(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Metade,
    Acertos
) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, DistanciaDefensor, Dribles, made, Periodo, _),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor),
            metade_partida(Periodo, Metade)
        ),
        Acertos
    ).

% Calcula o aproveitamento de um perfil em cada metade da partida
aproveitamento_perfil_por_metade(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Metade,
    Tentativas,
    Acertos,
    Percentual
) :-
    tentativas_perfil_por_metade(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Metade,
        Tentativas
    ),
    acertos_perfil_por_metade(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Metade,
        Acertos
    ),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Calcula o aproveitamento geral por metade da partida
aproveitamento_geral_por_metade(Metade, Tentativas, Acertos, Percentual) :-
    aggregate_all(
        count,
        (
            arremesso(_, _, _, _, Periodo1, _),
            metade_partida(Periodo1, Metade)
        ),
        Tentativas
    ),
    aggregate_all(
        count,
        (
            arremesso(_, _, _, made, Periodo2, _),
            metade_partida(Periodo2, Metade)
        ),
        Acertos
    ),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Compara o melhor perfil com a media geral em cada metade
vantagem_melhor_perfil_por_metade(
    Metade,
    TentativasPerfil,
    AcertosPerfil,
    PercentualPerfil,
    PercentualGeral,
    Diferenca
) :-
    melhor_perfil_superior(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor
    ),
    aproveitamento_perfil_por_metade(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Metade,
        TentativasPerfil,
        AcertosPerfil,
        PercentualPerfil
    ),
    aproveitamento_geral_por_metade(
        Metade,
        _, _,
        PercentualGeral
    ),
    Diferenca is PercentualPerfil - PercentualGeral.

% ============================================================
% 7. CONSULTA 4 - ANALISE POR DATAS
% ============================================================

% Classifica datas de outubro a dezembro de 2014
intervalo_temporal(data(2014, Mes, _), out_dez_2014) :-
    member(Mes, [10, 11, 12]).

% Classifica datas de janeiro a marco de 2015
intervalo_temporal(data(2015, Mes, _), jan_mar_2015) :-
    member(Mes, [1, 2, 3]).

% Conta tentativas de um perfil em determinado intervalo de datas
tentativas_perfil_por_intervalo(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Intervalo,
    Total
) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, DistanciaDefensor, Dribles, _, _, Data),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor),
            intervalo_temporal(Data, Intervalo)
        ),
        Total
    ).

% Conta acertos de um perfil em determinado intervalo de datas
acertos_perfil_por_intervalo(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Intervalo,
    Acertos
) :-
    aggregate_all(
        count,
        (
            arremesso(Distancia, DistanciaDefensor, Dribles, made, _, Data),
            faixa_dribles(Dribles, FaixaDribles),
            faixa_distancia(Distancia, FaixaDistancia),
            categoria_defensor(DistanciaDefensor, CategoriaDefensor),
            intervalo_temporal(Data, Intervalo)
        ),
        Acertos
    ).

% Calcula o aproveitamento de um perfil em determinado intervalo de datas
aproveitamento_perfil_por_intervalo(
    FaixaDribles,
    FaixaDistancia,
    CategoriaDefensor,
    Intervalo,
    Tentativas,
    Acertos,
    Percentual
) :-
    tentativas_perfil_por_intervalo(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Intervalo,
        Tentativas
    ),
    acertos_perfil_por_intervalo(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Intervalo,
        Acertos
    ),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Calcula o aproveitamento geral em determinado intervalo de datas
aproveitamento_geral_por_intervalo(Intervalo, Tentativas, Acertos, Percentual) :-
    aggregate_all(
        count,
        (
            arremesso(_, _, _, _, _, Data1),
            intervalo_temporal(Data1, Intervalo)
        ),
        Tentativas
    ),
    aggregate_all(
        count,
        (
            arremesso(_, _, _, made, _, Data2),
            intervalo_temporal(Data2, Intervalo)
        ),
        Acertos
    ),
    Tentativas > 0,
    Percentual is (Acertos / Tentativas) * 100.

% Compara o melhor perfil com a media geral em cada intervalo de datas
vantagem_melhor_perfil_por_intervalo(
    Intervalo,
    TentativasPerfil,
    AcertosPerfil,
    PercentualPerfil,
    PercentualGeral,
    Diferenca
) :-
    melhor_perfil_superior(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor
    ),
    aproveitamento_perfil_por_intervalo(
        FaixaDribles,
        FaixaDistancia,
        CategoriaDefensor,
        Intervalo,
        TentativasPerfil,
        AcertosPerfil,
        PercentualPerfil
    ),
    aproveitamento_geral_por_intervalo(
        Intervalo,
        _, _,
        PercentualGeral
    ),
    Diferenca is PercentualPerfil - PercentualGeral.

% ============================================================
% 8. CONSULTA 4 - RANKINGS E INTEGRACAO
% ============================================================

% Ordena os intervalos de datas pela vantagem do melhor perfil
ranking_vantagens_intervalos(Ranking) :-
    findall(
        Diferenca-intervalo(
            Intervalo,
            Tentativas,
            Acertos,
            PercentualPerfil,
            PercentualGeral
        ),
        (
            member(Intervalo, [out_dez_2014, jan_mar_2015]),
            vantagem_melhor_perfil_por_intervalo(
                Intervalo,
                Tentativas,
                Acertos,
                PercentualPerfil,
                PercentualGeral,
                Diferenca
            )
        ),
        Lista
    ),
    keysort(Lista, Ordenada),
    reverse(Ordenada, Ranking).    

% Ordena as metades da partida pela vantagem do melhor perfil
ranking_vantagens_metades(Ranking) :-
    findall(
        Diferenca-metade(
            Metade,
            Tentativas,
            Acertos,
            PercentualPerfil,
            PercentualGeral
        ),
        (
            member(Metade, [primeira_metade, segunda_metade]),
            vantagem_melhor_perfil_por_metade(
                Metade,
                Tentativas,
                Acertos,
                PercentualPerfil,
                PercentualGeral,
                Diferenca
            )
        ),
        Lista
    ),
    keysort(Lista, Ordenada),
    reverse(Ordenada, Ranking).

% Reune as analises temporais do perfil vencedor
analise_temporal_melhor_perfil(RankingMetades, RankingIntervalos) :-
    ranking_vantagens_metades(RankingMetades),
    ranking_vantagens_intervalos(RankingIntervalos).