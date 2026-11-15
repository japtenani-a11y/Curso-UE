-- 39_ondas_teste_T001_v1.0.sql
-- SO PARA TESTE LOCAL: cria as 6 ondas do T001 abertas agora e coloca nelas as questoes
-- (questao fixa + questoes de caso de todos os perfis; a API filtra pelo perfil do aluno).
-- Em producao, as datas seguem o calendario: D-15, D-x, D0, D+15, D+45, D+90.
-- Pre-requisito: 37 e 38. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

INSERT INTO app.onda_instancia (ciclo_id, onda_codigo, ordem_onda, data_abertura, data_fechamento, status, tema_id, teste_num)
SELECT t.ciclo_id, 'T001-' || v.cod, 100 + v.n, now() - interval '1 day', now() + interval '120 days', 'aberta', t.tema_id, v.n
  FROM app.tema t,
       (VALUES (1,'PRE1'),(2,'PRE2'),(3,'POS-D0'),(4,'POS-D15'),(5,'POS-D45'),(6,'POS-D90')) v(n, cod)
 WHERE replace(t.codigo,'-','') = 'T001'
ON CONFLICT (ciclo_id, onda_codigo) DO UPDATE
   SET tema_id = EXCLUDED.tema_id, teste_num = EXCLUDED.teste_num, status = 'aberta',
       data_abertura = EXCLUDED.data_abertura, data_fechamento = EXCLUDED.data_fechamento;

-- questao fixa primeiro, depois as do caso, na ordem do codigo
INSERT INTO app.item_selecionado (onda_id, item_id, ordem_apresentada)
SELECT o.onda_id, i.item_id,
       row_number() OVER (PARTITION BY o.onda_id ORDER BY i.fixa DESC, i.perfil, i.codigo)::smallint
  FROM app.onda_instancia o
  JOIN app.item i ON i.tema_id = o.tema_id AND (i.fixa OR i.teste_num = o.teste_num)
 WHERE o.onda_codigo LIKE 'T001-%'
ON CONFLICT (onda_id, item_id) DO NOTHING;

SELECT o.onda_codigo, o.teste_num, count(s.*) AS questoes_na_onda
  FROM app.onda_instancia o LEFT JOIN app.item_selecionado s USING (onda_id)
 WHERE o.onda_codigo LIKE 'T001-%' GROUP BY 1, 2 ORDER BY 2;
COMMIT;
