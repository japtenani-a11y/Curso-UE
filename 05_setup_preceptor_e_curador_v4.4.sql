-- ============================================================
-- 05_setup_preceptor_e_curador_v4.4.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.4 / 10-11-2026
--
-- OBJETIVO: criar preceptor, curador, modulo, vinculo de
-- preceptor ao modulo e uma tarefa de teste.
--
-- PRE-REQUISITO: 03_setup_minimo_v4.3.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 05_setup_preceptor_e_curador_v4.4.sql
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== SETUP PRECEPTOR E CURADOR v4.4 ==='

BEGIN;

-- PRECEPTOR
INSERT INTO app.pessoa (nome_completo, email_primario)
VALUES ('Preceptor Teste', 'preceptor.teste@setup.local')
ON CONFLICT (email_primario) DO NOTHING;

INSERT INTO app.posicao_anual (pessoa_id, perfil_id, ano_letivo, grau, ativo)
SELECT p.pessoa_id, 25, 2026, 'preceptor', true
  FROM app.pessoa p WHERE p.email_primario = 'preceptor.teste@setup.local'
ON CONFLICT (pessoa_id, ano_letivo, perfil_id) DO NOTHING;

-- CURADOR
INSERT INTO app.pessoa (nome_completo, email_primario)
VALUES ('Curador Teste', 'curador.teste@setup.local')
ON CONFLICT (email_primario) DO NOTHING;

INSERT INTO app.designacao (pessoa_id, papel, vigencia_inicio)
SELECT p.pessoa_id, 'curador', '2026-01-01'
  FROM app.pessoa p WHERE p.email_primario = 'curador.teste@setup.local'
  AND NOT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p.pessoa_id AND d.papel = 'curador');

-- MODULO
INSERT INTO app.modulo (ciclo_id, codigo, nome, ordem)
SELECT ciclo_id, 'M-001', 'Modulo de trauma', 1
  FROM app.ciclo WHERE ano_ingresso = 2026
ON CONFLICT (ciclo_id, codigo) DO NOTHING;

-- VINCULO PRECEPTOR-MODULO
INSERT INTO app.preceptor_modulo (preceptor_id, modulo_id, carga_maxima, vigencia_inicio)
SELECT p.pessoa_id, m.modulo_id, 10, '2026-01-01'
  FROM app.pessoa p, app.modulo m
 WHERE p.email_primario = 'preceptor.teste@setup.local'
   AND m.codigo = 'M-001'
   AND NOT EXISTS (SELECT 1 FROM app.preceptor_modulo pm
                    WHERE pm.preceptor_id = p.pessoa_id AND pm.modulo_id = m.modulo_id AND pm.revogado_em IS NULL);

-- TAREFA DE TESTE
INSERT INTO app.tarefa (modulo_id, pessoa_id, tipo, descricao, prazo, status)
SELECT m.modulo_id, p.pessoa_id, 'procedimento', 'Realizar sutura simples supervisionada', '2026-03-15', 'pendente'
  FROM app.modulo m, app.pessoa p
 WHERE m.codigo = 'M-001' AND p.email_primario = 'r1.teste@setup.local'
   AND NOT EXISTS (SELECT 1 FROM app.tarefa t WHERE t.modulo_id = m.modulo_id AND t.pessoa_id = p.pessoa_id);

-- CONFERENCIA
\echo '--- Conferencia ---'

SELECT 'preceptores ativos: ' || count(*) FROM app.preceptor_modulo WHERE revogado_em IS NULL;
SELECT 'curadores: ' || count(*) FROM app.designacao WHERE papel = 'curador';
SELECT 'modulos: ' || count(*) FROM app.modulo;
SELECT 'tarefas: ' || count(*) FROM app.tarefa;

\echo '=== SETUP PRECEPTOR E CURADOR CONCLUIDO ==='

COMMIT;
