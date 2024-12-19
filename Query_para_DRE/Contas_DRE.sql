WITH contas AS (
    SELECT
        id AS id_conta,
        cod_plano,
        nome AS nome_conta,
        array_length(string_to_array(id, '.'), 1) AS nivel
    FROM
        plano_contas
    WHERE
        id LIKE '3%' -- Apenas contas de resultado
),
movimentos AS (
    SELECT
        CASE 
            WHEN cod_plano_credito IS NOT NULL THEN cod_plano_credito
            ELSE cod_plano_debito
        END AS cod_plano,
        SUM(CASE WHEN cod_plano_credito IS NOT NULL THEN valor ELSE 0 END) AS vlr_credito,
        SUM(CASE WHEN cod_plano_debito IS NOT NULL THEN valor ELSE 0 END) AS vlr_debito,
        SUM(CASE WHEN cod_plano_credito IS NOT NULL THEN valor ELSE -valor END) AS saldo_vlr,
        data_movimento,
        cod_empresa
    FROM
        lancamentos_financeiros
    WHERE
        situacao = 2 AND
        cod_empresa = 2 AND
        data_movimento BETWEEN '2024-10-01' AND '2024-10-31'
    GROUP BY
        CASE 
            WHEN cod_plano_credito IS NOT NULL THEN cod_plano_credito
            ELSE cod_plano_debito
        END, data_movimento, cod_empresa
)
SELECT
    pe.nome AS nome_empresa,
    mov.data_movimento,
    c.cod_plano,
    converte_id_para_comparar(c.id_conta) AS id_para_comparar,
    c.id_conta AS id_para_mostrar,
    c.nome_conta,
    c.nivel,
    COALESCE(SUM(mov.vlr_credito), 0) AS vlr_credito,
    COALESCE(SUM(mov.vlr_debito), 0) AS vlr_debito,
    COALESCE(SUM(mov.saldo_vlr), 0) AS saldo_vlr
FROM
    contas c
LEFT JOIN
    movimentos mov ON mov.cod_plano = c.cod_plano
LEFT JOIN
    pessoas pe ON mov.cod_empresa = pe.cod_pessoa
GROUP BY
    pe.nome, mov.data_movimento, c.cod_plano, c.id_conta, c.nome_conta, c.nivel
ORDER BY
    id_para_comparar;
