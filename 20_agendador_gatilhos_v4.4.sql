linha_sql	
	
-- ============================================================	
-- 20_agendador_gatilhos_v4.4.sql	
-- Sistema de Producao Curricular e Coleta Cientifica	
-- Programa de Cirurgia de Urgencia e Trauma	
-- Versao 4.4 / 10-11-2026	
--	
-- OBJETIVO: registrar os 8 gatilhos do sistema. Cada gatilho	
-- enfileira um conjunto de skills em maestro.job quando	
-- disparado por fn_disparar_gatilho.	
--	
-- PRE-REQUISITO: 18_setup_skills_v4.4.	
--	
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 20_agendador_gatilhos_v4.4.sql	
-- ============================================================	
	
\set ON_ERROR_STOP on	
\echo '=== SETUP AGENDADOR GATILHOS v4.4 ==='	
	
BEGIN	
	
INSERT INTO ops.gatilho (codigo, nome, descricao, entidade, skills_enfileiradas, ativo) VALUES	
('GAT_CICLO_ABERTURA',	
 'Abertura de ciclo',	
 'Dispara a cadeia completa de geracao para todos os temas do ciclo.',	
 'ciclo',	
 ARRAY['SK-01','SK-02','SK-03','SK-04','SK-05','SK-06','SK-07','SK-08','SK-09','SK-10','SK-11','SK-12','SK-13','SK-14','SK-15','SK-16'],	
 true),	
	
('GAT_ONDA_FECHAMENTO',	
 'Fechamento de onda',	
 'Dispara a analise psicometrica apos o fechamento da onda.',	
 'onda',	
 ARRAY['PS-01','PS-02','PS-03','PS-08'],	
 true),	
	
('GAT_CICLO_FECHAMENTO',	
 'Fechamento de ciclo',	
 'Dispara a analise estatistica e o relatorio de gestao ao fim do ciclo.',	
 'ciclo',	
 ARRAY['RS-05','PS-04','PS-05','PS-06','PS-07','PK-37'],	
 true),	
	
('GAT_PRODUCAO_CIENTIFICA',	
 'Producao cientifica',	
 'Dispara a cadeia de redacao e submissao de manuscrito.',	
 'manuscrito',	
 ARRAY['RS-06','RS-09','RS-12','RS-13','RS-14'],	
 true),	
	
('GAT_REVISAO_ANUAL',	
 'Revisao anual',	
 'Dispara a revisao completa do curso 60 dias antes do novo ciclo.',	
 'ciclo',	
 ARRAY['PK-29','PK-31','PK-33','PK-38'],	
 true),	
	
('GAT_RELEASE_SOFTWARE',	
 'Release de software',	
 'Dispara a verificacao de seguranca e o teste de carga antes do release.',	
 'release',	
 ARRAY['EN-01','EN-03','EN-07'],	
 true),	
	
('GAT_AUDITORIA_ANUAL',	
 'Auditoria anual',	
 'Dispara a auditoria de conformidade LGPD e o relatorio CAPES.',	
 'ano',	
 ARRAY['EN-08','GV-01','GV-04'],	
 true),	
	
('GAT_MANUTENCAO_DIARIA',	
 'Manutencao diaria',	
 'Dispara a deteccao de obsolescencia e a varredura de integridade.',	
 'global',	
 ARRAY['PK-29','PK-31'],	
 true)	
ON CONFLICT (codigo) DO UPDATE	
   SET nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao,	
       entidade = EXCLUDED.entidade,	
       skills_enfileiradas = EXCLUDED.skills_enfileiradas,	
       ativo = EXCLUDED.ativo	
	
-- CONFERENCIA	
\echo '--- Conferencia ---'	
	
SELECT 'total de gatilhos: ' || count(*) FROM ops.gatilho	
	
SELECT codigo, array_length(skills_enfileiradas, 1) AS n_skills	
  FROM ops.gatilho	
 ORDER BY codigo	
	
SELECT 'FALHA: total de gatilhos <> 8' WHERE (SELECT count(*) FROM ops.gatilho) <> 8	
	
SELECT 'FALHA: gatilho com skill inexistente: ' || g.codigo	
  FROM ops.gatilho g	
 CROSS JOIN LATERAL unnest(g.skills_enfileiradas) AS s(cod)	
 WHERE NOT EXISTS (SELECT 1 FROM ops.skill_definicao sd WHERE sd.codigo = s.cod)	
	
\echo '=== SETUP AGENDADOR GATILHOS CONCLUIDO ==='	
	
COMMIT	
