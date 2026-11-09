ALTER DATABASE mercearias_douro SET datestyle = 'ISO, DMY';
SHOW datestyle;

CREATE TABLE controlo.rejeicoes (
	id 					SERIAL PRIMARY KEY,
	id_venda 			TEXT,
	data_venda			TEXT,
	cod_loja			TEXT,
	cod_produto 		TEXT,
	quantidade			TEXT,
	preco_unitario 		TEXT,
	ficheiro_origem		TEXT,
	motivo 				TEXT NOT NULL,
	rejeitado_em 		TIMESTAMP DEFAULT now()
);

CREATE VIEW staging.vendas_validadas AS
SELECT v.*,
	CASE
         WHEN coalesce(v.id_venda, '') = ''      THEN 'id da venda em falta'
         WHEN v.ocorrencia > 1                    THEN 'venda duplicada'
         WHEN NOT pg_input_is_valid(coalesce(v.data_venda, ''), 'date')
              THEN 'data inválida'
         WHEN coalesce(v.cod_loja, '') = ''      THEN 'loja em falta'
         WHEN coalesce(v.cod_produto, '') = ''   THEN 'produto em falta'
         WHEN NOT pg_input_is_valid(coalesce(v.quantidade, ''), 'integer')
              THEN 'quantidade não numérica'
         WHEN v.quantidade::int <= 0              THEN 'quantidade zero ou negativa'
         WHEN NOT pg_input_is_valid(
                replace(coalesce(v.preco_unitario, ''), ',', '.'), 'numeric')
              THEN 'preço em falta ou não numérico'
         WHEN replace(v.preco_unitario, ',', '.')::numeric < 0
              THEN 'preço negativo'
       END AS motivo
FROM (
    SELECT r.*,
           row_number() OVER (PARTITION BY r.id_venda ORDER BY r.carregado_em) AS ocorrencia
    FROM staging.vendas_raw r
) v;

SELECT * FROM staging.vendas_raw;
