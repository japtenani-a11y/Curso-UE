-- ============================================================
-- 27c_teste_rls_v1.0.sql
-- Teste das regras de acesso (RLS) depois do 27. Roda como superusuario
-- e assume os papeis api_rw, maestro_rw e metabase_ro. Cada linha
-- imprime PASSOU ou FALHOU.
-- USO: psql -d programa_v44 -f 27c_teste_rls_v1.0.sql
-- ============================================================
\set ON_ERROR_STOP off
\pset tuples_only on

INSERT INTO app.pessoa(nome_completo,email_primario) VALUES ('Aluno C','c.teste@setup.local') ON CONFLICT DO NOTHING;
SELECT pessoa_id AS c FROM app.pessoa WHERE email_primario='c.teste@setup.local' \gset
SELECT pessoa_id AS a FROM app.pessoa WHERE email_primario='r1.teste@setup.local' \gset
SELECT tentativa_id AS tb FROM app.tentativa WHERE pessoa_id<>:c ORDER BY 1 LIMIT 1 \gset
SELECT onda_id AS o FROM app.onda_instancia ORDER BY 1 LIMIT 1 \gset
SELECT item_id AS it FROM app.item_selecionado WHERE onda_id=:o LIMIT 1 \gset
SELECT alternativa_id AS al FROM app.alternativa WHERE item_id=:it LIMIT 1 \gset

BEGIN; SET LOCAL ROLE api_rw;
SELECT CASE WHEN count(*)=0 THEN 'PASSOU' ELSE 'FALHOU' END||' 1 sem contexto nao ve pessoas' FROM app.pessoa;
SELECT CASE WHEN count(*)=0 THEN 'PASSOU' ELSE 'FALHOU' END||' 1b sem contexto nao ve artefato nao publicado' FROM conteudo.artefato WHERE status<>'publicado';
ROLLBACK;

BEGIN; SET LOCAL ROLE api_rw;
SELECT set_config('app.pessoa_id',:'c',true), set_config('app.role','aluno',true) \gset
SELECT CASE WHEN count(*)=1 THEN 'PASSOU' ELSE 'FALHOU' END||' 2 aluno ve so a propria pessoa' FROM app.pessoa;
SELECT CASE WHEN count(*)=0 THEN 'PASSOU' ELSE 'FALHOU' END||' 3 aluno nao ve tentativa de outro' FROM app.tentativa WHERE pessoa_id=:a;
INSERT INTO app.tentativa(onda_id,pessoa_id) VALUES (:o,:c) RETURNING tentativa_id \gset tc_
INSERT INTO app.resposta(tentativa_id,item_id,alternativa_id) VALUES (:tc_tentativa_id,:it,:al);
UPDATE app.tentativa SET submetida_em=now() WHERE tentativa_id=:tc_tentativa_id;
SELECT CASE WHEN count(*)=1 THEN 'PASSOU' ELSE 'FALHOU' END||' 4 aluno cria tentativa, responde e submete a propria' FROM app.resposta;
COMMIT;

BEGIN; SET LOCAL ROLE api_rw;
SELECT set_config('app.pessoa_id',:'c',true), set_config('app.role','aluno',true) \gset
INSERT INTO app.resposta(tentativa_id,item_id,alternativa_id) VALUES (:tb,:it,:al);
ROLLBACK;
SELECT 'ESPERADO ERRO RLS acima: aluno nao responde na tentativa de outro (5)';

BEGIN; SET LOCAL ROLE api_rw;
SELECT set_config('app.role','preceptor',true);
SELECT CASE WHEN count(*)>1 THEN 'PASSOU' ELSE 'FALHOU' END||' 6 preceptor ve varias pessoas' FROM app.pessoa;
ROLLBACK;

BEGIN; SET LOCAL ROLE api_rw;
SELECT app.fn_sessao_teste('r1.teste@setup.local');
ROLLBACK;
SELECT 'ESPERADO ERRO acima: login de teste desabilitado por padrao (7)';

BEGIN; SET LOCAL ROLE api_rw;
SELECT set_config('app.permitir_teste','on',true);
SELECT app.fn_sessao_teste('r1.teste@setup.local') AS tok \gset
SELECT CASE WHEN count(*)=1 THEN 'PASSOU' ELSE 'FALHOU' END||' 8 sessao identificada pela funcao' FROM app.fn_identificar_sessao(:'tok');
SELECT app.fn_revogar_sessao(:'tok');
SELECT CASE WHEN count(*)=0 THEN 'PASSOU' ELSE 'FALHOU' END||' 9 sessao revogada nao identifica' FROM app.fn_identificar_sessao(:'tok');
SELECT CASE WHEN app.fn_sessao_google('x@nao.existe',NULL,'ua') IS NULL THEN 'PASSOU' ELSE 'FALHOU' END||' 10 e-mail nao cadastrado nao abre sessao';
ROLLBACK;

BEGIN; SET LOCAL ROLE maestro_rw;
SELECT 'PASSOU 11 maestro_rw consulta job: '||count(*) FROM maestro.job;
ROLLBACK;

BEGIN; SET LOCAL ROLE metabase_ro;
SELECT CASE WHEN count(*)=0 THEN 'PASSOU' ELSE 'FALHOU' END||' 12 metabase_ro nao ve pessoas identificadas' FROM app.pessoa;
ROLLBACK;

BEGIN; SET LOCAL ROLE api_rw;
INSERT INTO ops.auditoria(acao,resultado) VALUES ('teste','ok');
SELECT 'PASSOU 13 auditoria aceita insercao';
ROLLBACK;
BEGIN; SET LOCAL ROLE api_rw;
DELETE FROM ops.auditoria;
ROLLBACK;
SELECT 'ESPERADO ERRO permission denied acima: auditoria nao aceita DELETE (14)';
