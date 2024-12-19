SELECT
    m.data_movimento AS data_venda,
    g.cod_grupo,  
    g.nome AS grupo,
    -- Valores de vendas
    SUM(m.valor) AS valor_venda,
    SUM(m.quantidade) AS quantidade_venda,
    SUM(m.tributos_sobre_vendas) AS tributos_sobre_vendas,
    -- CMV (Custo das Mercadorias Vendidas)
    SUM(m.quantidade * m.preco_medio) AS CMV_venda,
    -- Cálculo do lucro
    SUM(m.valor) - SUM(m.tributos_sobre_vendas) - SUM(m.quantidade * m.preco_medio) AS lucro_venda
FROM
    relatorios.movimentacao_produtos_com_lucro_bruto_medio(
        2, 
        0, 
        0, 
        0, 
        '01/10/2024', 
        '31/10/2024'
    ) m
-- Joins
INNER JOIN public.produtos p ON m.cod_produto = p.cod_produto
INNER JOIN public.grupos g ON p.cod_grupo = g.cod_grupo
-- Filtros
WHERE
    m.tipo_lancamento IN ('V')
    AND p.tipo IN ('U', 'C', 'M', 'D', 'P')
    AND m.data_movimento BETWEEN '01/10/2024' AND '31/10/2024'
-- Agrupamento
GROUP BY
    m.data_movimento, 
    g.cod_grupo,  
    g.nome
ORDER BY
    g.nome;
