from pathlib import Path
import pandas as pd

RAIZ = Path(__file__).resolve().parent.parent
CSV = RAIZ / "data" / "shot_logs.csv"

COLUNAS = [
    "SHOT_DIST",
    "CLOSE_DEF_DIST",
    "DRIBBLES",
    "SHOT_RESULT",
    "PERIOD",
    "MATCHUP"
]

df = pd.read_csv(CSV)

filtro = ((df["PTS_TYPE"] == 3) & (df["player_name"] == "stephen curry"))

df_filtrado = df.loc[filtro].copy()

df_curry = df_filtrado[COLUNAS].copy()

assert not df_filtrado.empty, "Nenhum arremesso encontrado."
assert len(COLUNAS) == 6
assert df_curry["SHOT_RESULT"].isin(["made", "missed"]).all()
assert df_curry.notna().all().all()
assert not df_filtrado.duplicated(subset=["GAME_ID", "player_id", "SHOT_NUMBER"]).any()
assert (df_curry["DRIBBLES"] >= 0).all()
assert (df_curry["DRIBBLES"] % 1 == 0).all()
assert (df_curry["SHOT_DIST"] >= 0).all()
assert (df_curry["CLOSE_DEF_DIST"] >= 0).all()
assert df_curry["PERIOD"].isin([1, 2, 3, 4, 5]).all()

datas = pd.to_datetime(
    df_curry["MATCHUP"].str.strip().str.split(" - ", n=1).str[0],
    format="%b %d, %Y",
    errors="coerce"
)

assert datas.notna().all()

df_curry["DATA"] = datas.apply(
    lambda d: f"data({d.year}, {d.month}, {d.day})"
)

def formatar_fato(registro):
    distancia = float(registro["SHOT_DIST"])
    distancia_defensor = float(registro["CLOSE_DEF_DIST"])
    dribles = int(registro["DRIBBLES"])
    resultado = str(registro["SHOT_RESULT"]).strip()
    periodo = int(registro["PERIOD"])
    data = registro["DATA"]

    fato = (
        f"arremesso({distancia}, {distancia_defensor}, {dribles}, {resultado}, {periodo}, {data})."
    )

    return fato

SAIDA = RAIZ / "prolog" / "fatos.pl"

with SAIDA.open("w", encoding="utf-8") as arquivo:
    for _, registro in df_curry.iterrows():
        arquivo.write(formatar_fato(registro) + "\n")

print("\nArquivo Prolog gerado:", SAIDA)
print("Quantidade de fatos:", len(df_curry))

with SAIDA.open("r", encoding="utf-8") as arquivo:
    total_fatos = sum(
        1 for linha in arquivo
        if linha.startswith("arremesso(")
    )

print("Fatos encontrados no arquivo:", total_fatos)

assert total_fatos == len(df_curry)