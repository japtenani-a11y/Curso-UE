-- 79_aluno_para_todos_v1.0.sql
-- Parte do aluno liberada para todos que fazem o curso (decisao de 15/11/2026).
-- Antes: sem ano de residencia cadastrado (caso da equipe usando o perfil de aluno), os testes ficavam
-- indisponiveis ("perfil nao cadastrado"). Agora o perfil das questoes segue esta ordem:
--   1) o ano da posicao anual (residente aprovado, como antes);
--   2) o ano calculado da ficha de inscricao, se houver;
--   3) sem nenhum dos dois: R+ (questoes do nivel mais avancado).
-- Quem chega aos testes ja passou pela conferencia do cadastro (app.cadastro_ok), entao isso nao abre o curso
-- para quem nao esta inscrito. Pre-requisito: 38, 62. Pode ser rodado mais de uma vez.
-- DESFAZER: rodar de novo o 38_liberacao_v1.0.sql (volta a funcao antiga).
\set ON_ERROR_STOP on
BEGIN;
CREATE OR REPLACE FUNCTION app.perfil_da_pessoa(p_pessoa BIGINT) RETURNS TEXT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT CASE WHEN p_pessoa IS NULL THEN NULL ELSE app.perfil_questoes(coalesce(
    (SELECT pa.grau FROM app.posicao_anual pa WHERE pa.pessoa_id = p_pessoa AND pa.ativo AND pa.grau IS NOT NULL
      ORDER BY pa.ano_letivo DESC LIMIT 1),
    (SELECT app.grau_da_ficha(f) FROM app.ficha_aluno f WHERE f.pessoa_id = p_pessoa AND f.situacao IS NOT NULL),
    'R6'::app.grau_enum)) END $$;
COMMIT;
\echo 'parte do aluno liberada para todos os inscritos: pronto'
