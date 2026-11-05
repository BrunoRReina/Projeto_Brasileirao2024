-- Q1: Distribuição dos resultados (vantagem de mandante)
SELECT 
    resultado,
    COUNT(*) AS total_jogos,
    ROUND(COUNT(*)*100.00 / (SELECT COUNT(*)FROM partidas), 1) AS percentual
FROM partidas
GROUP BY resultado
ORDER BY total_jogos DESC;


-- Q2: Gols marcados e sofridos por time (jogos em casa + fora)
SELECT
    time,
    SUM(gols_pro) AS gols_marcados,
    SUM(gols_contra) AS gols_sofridos,
    SUM(gols_pro) - SUM(gols_contra) AS saldo
FROM (
    SELECT time_casa AS time, gols_casa AS gols_pro, gols_visitante AS gols_contra
    FROM partidas
    UNION ALL
    SELECT time_visitante AS time, gols_visitante AS gols_pro, gols_casa AS gols_contra
    FROM partidas
)
GROUP BY time
ORDER BY gols_marcados DESC;

-- Q3: Público médio por time mandante
SELECT
    time_casa AS time,
    ROUND(AVG(publico)) AS publico_medio,
    COUNT(publico) AS jogos_com_publico
FROM partidas
GROUP BY time_casa
ORDER BY publico_medio DESC;

-- Q4: Maiores diferenças de gols em uma partida
SELECT
    data,
    time_casa,
    placar,
    time_visitante,
    ABS(saldo_gols) AS diferenca
FROM partidas
ORDER BY diferenca DESC
LIMIT 10;

-- Q5: Tabela de classificação
SELECT
    time,
    COUNT(*) AS jogos,
    SUM(CASE WHEN pontos = 3 THEN 1 ELSE 0 END) AS vitorias,
    SUM(CASE WHEN pontos = 1 THEN 1 ELSE 0 END) AS empates,
    SUM(CASE WHEN pontos = 0 THEN 1 ELSE 0 END) AS derrotas,
    SUM(gols_pro) AS gols_pro,
    SUM(gols_contra) AS gols_contra,
    SUM(gols_pro) - SUM(gols_contra) AS saldo,
    SUM(pontos) AS pontos,
    ROUND(SUM(pontos) * 100.0 / (COUNT(*) * 3), 1) AS aproveitamento
FROM (
    SELECT
        time_casa AS time,
        gols_casa AS gols_pro,
        gols_visitante AS gols_contra,
        CASE
            WHEN gols_casa > gols_visitante THEN 3
            WHEN gols_casa = gols_visitante THEN 1
            ELSE 0
        END AS pontos
    FROM partidas
    UNION ALL
    SELECT
        time_visitante AS time,
        gols_visitante AS gols_pro,
        gols_casa AS gols_contra,
        CASE
            WHEN gols_visitante > gols_casa THEN 3
            WHEN gols_visitante = gols_casa THEN 1
            ELSE 0
        END AS pontos
    FROM partidas
)
GROUP BY time
ORDER BY pontos DESC, vitorias DESC, saldo DESC;

-- Q6: Aproveitamento de cada time em casa e fora
SELECT
    time,
    ROUND(SUM(CASE WHEN mando = 'casa' THEN pontos ELSE 0 END) * 100.0 /
          (SUM(CASE WHEN mando = 'casa' THEN 1 ELSE 0 END) * 3), 1) AS aproveitamento_casa,
    ROUND(SUM(CASE WHEN mando = 'fora' THEN pontos ELSE 0 END) * 100.0 /
          (SUM(CASE WHEN mando = 'fora' THEN 1 ELSE 0 END) * 3), 1) AS aproveitamento_fora
FROM (
    SELECT time_casa AS time, 'casa' AS mando,
        CASE WHEN gols_casa > gols_visitante THEN 3
             WHEN gols_casa = gols_visitante THEN 1 ELSE 0 END AS pontos
    FROM partidas
    UNION ALL
    SELECT time_visitante AS time, 'fora' AS mando,
        CASE WHEN gols_visitante > gols_casa THEN 3
             WHEN gols_visitante = gols_casa THEN 1 ELSE 0 END AS pontos
    FROM partidas
)
GROUP BY time
ORDER BY aproveitamento_casa DESC;

-- Q7: Média de gols por horário
SELECT
    horário AS horario,
    COUNT(*) AS jogos,
    ROUND(AVG(gols_casa + gols_visitante), 2) AS media_gols
FROM partidas
GROUP BY horário
ORDER BY media_gols DESC;