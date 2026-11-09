SELECT  count(*) AS linhas
FROM staging.vendas_raw;

SELECT *
FROM staging.vendas_raw
WHERE quantidade LIKE '-%'
   OR quantidade = ''
   OR quantidade IS NULL
   OR quantidade !~ '^[0-9]+$';
   
SELECT *
FROM staging.vendas_raw
WHERE preco_unitario LIKE '-%'
   OR preco_unitario = ''
   OR preco_unitario IS NULL;

SELECT *
FROM staging.vendas_raw
WHERE id_venda IS NULL 
OR cod_produto IS NULL;

SELECT data_venda, count(*) AS linhas
FROM staging.vendas_raw
WHERE data_venda ~ '^31/(04|06|09|11)/'               -- dia 31 em meses de 30 dias
   OR data_venda ~ '^(29|30|31)/02/'                   -- fevereiro de 2026 só tem 28 dias
   OR data_venda LIKE '00/%'                           -- dia zero
   OR data_venda !~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'     -- formato diferente de dd/mm/aaaa
   OR data_venda IS NULL
GROUP BY data_venda
ORDER BY linhas DESC;   