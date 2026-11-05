import sqlite3
import pandas as pd
import numpy as np

colunas = ['data', 'horário', 'time_casa', 'placar',
           'time_visitante', 'publico', 'estadio']

df = pd.read_csv(
    'data/raw/DataSet_Brasileirao_Raw.csv',
    header=None,
    names=colunas
)

print("Dimensões do dataset:", df.shape)
print(df.head())
print(df.info())


placar_split = df['placar'].str.split('–', expand=True)
df['gols_casa'] = placar_split[0].astype(int)
df['gols_visitante'] = placar_split[1].astype(int)


df['publico'] = df['publico'].astype(str).str.replace(',', '')
df['publico'] = pd.to_numeric(df['publico'], errors='coerce')

df['horário'] = df['horário'].str.extract(r'(\d{2}:\d{2})')[0]

df['data'] = pd.to_datetime(df['data'])

print(df[['placar', 'gols_casa', 'gols_visitante',
      'publico', 'horário', 'data']].head(10))
print(df.dtypes)


print("\nDuplicatas:", df.duplicated().sum())

print("\nValores nulos por coluna:")
print(df.isnull().sum())

print("\nTotal de partidas:", len(df))

print("\nTimes mandantes únicos:")
print(sorted(df['time_casa'].unique()))

print("\nTimes visitantes únicos:")
print(sorted(df['time_visitante'].unique()))

condicoes = [
    df['gols_casa'] > df['gols_visitante'],
    df['gols_casa'] == df['gols_visitante'],
    df['gols_casa'] < df['gols_visitante']
]
valores = ['vitoria_casa', 'empate', 'vitoria_fora']
df['resultado'] = np.select(condicoes, valores, default='indefinido')

# Saldo de gols da partida (do ponto de vista do mandante)
df['saldo_gols'] = df['gols_casa'] - df['gols_visitante']

# Rodada (aproximação pela ordem cronológica, 10 jogos por rodada)
df = df.sort_values('data').reset_index(drop=True)
df['rodada'] = (df.index // 10) + 1

print(df[['data', 'time_casa', 'time_visitante',
      'resultado', 'saldo_gols', 'rodada']].head(15))
print("\nContagem de resultados:")
print(df['resultado'].value_counts())


df.to_csv('data/processed/brasileirao_2024_tratado.csv', index=False)
print("\nDataset tratado salvo em data/processed/brasileirao_2024_tratado.csv")


conn = sqlite3.connect('database/brasileirao_2024.db')
df.to_sql('partidas', conn, if_exists='replace', index=False)
conn.close()

print("\nDados carregados com sucesso no banco SQLite!")
