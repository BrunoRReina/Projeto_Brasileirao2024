import sqlite3
import re
import pandas as pd

conn = sqlite3.connect('database/brasileirao_2024.db')

with open('sql/analises.sql', encoding='utf-8') as f:
    conteudo = f.read()

# Cada query termina com ";" e começa com um comentário tipo "-- Q5: ..."
for bloco in conteudo.split(';'):
    bloco = bloco.strip()
    if not bloco:
        continue

    match = re.search(r'--\s*(Q\d+)', bloco)
    if not match:
        continue

    nome = match.group(1).lower()
    resultado = pd.read_sql_query(bloco, conn)
    resultado.to_csv(f'data/processed/{nome}.csv', index=False, encoding='utf-8-sig')
    print(f"{nome}.csv salvo ({len(resultado)} linhas)")

conn.close()