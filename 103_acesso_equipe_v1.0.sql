-- ============================================================
-- 103_acesso_equipe_v1.0.sql
-- OBJETIVO (pedido da coordenacao em 19/11/2026): coordenador (admin), curadores e data_steward veem TODO o curso
-- como o aluno veria no fim, sem nada bloqueado: material de todas as etapas, todos os testes e gabaritos, de todos os
-- temas, sem fazer os testes nem assistir as aulas. Vale tambem quando a pessoa entra no perfil de aluno.
-- Os testes, para a equipe, abrem em modo "Visualizar" (API /teste/ondas/:id/visualizar, script 103_acesso_equipe_app):
-- nada e gravado como resposta, entao os indicadores dos alunos nao mudam.
-- Roda depois do 38, 54, 60, 65 e 81 (que definem as funcoes abaixo). Pode ser rodado mais de uma vez.
-- Para desfazer: rodar de novo o 65 e o 81.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

-- A pessoa e da equipe (coordenacao ou curadoria) com designacao vigente?
CREATE OR REPLACE FUNCTION app.e_equipe(p_pessoa BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT p_pessoa IS NOT NULL AND EXISTS (
    SELECT 1 FROM app.designacao d
     WHERE d.pessoa_id = p_pessoa AND d.papel::text IN ('admin', 'curador', 'data_steward')
       AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)) $$;
REVOKE EXECUTE ON FUNCTION app.e_equipe(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.e_equipe(BIGINT) TO api_rw;

-- Etapa 4 (tudo liberado) para a equipe; para o aluno, as regras de sempre (38, 60, 65, 81).
CREATE OR REPLACE FUNCTION app.etapa_liberada(p_pessoa BIGINT, p_tema BIGINT) RETURNS INT
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN app.e_equipe(p_pessoa) THEN 4
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint)
         AND EXISTS (SELECT 1 FROM app.tema_requisito r WHERE r.tema_id = p_tema AND NOT app.tema_concluido(p_pessoa, r.requisito_id)) THEN 0
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint) THEN 1
    WHEN coalesce(now() < app.d0_da_pessoa(p_pessoa, p_tema), true) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 3::smallint) THEN 3
    ELSE 4 END $$;

-- Arvore de temas: nenhum tema bloqueado para a equipe.
CREATE OR REPLACE FUNCTION app.maes_pendentes(p_pessoa BIGINT, p_tema BIGINT) RETURNS TEXT[]
LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN app.e_equipe(p_pessoa) THEN '{}'::text[] ELSE
    (SELECT coalesce(array_agg(t.codigo ORDER BY t.codigo), '{}') FROM app.tema_requisito r JOIN app.tema t ON t.tema_id = r.requisito_id
      WHERE r.tema_id = p_tema AND NOT app.tema_concluido(p_pessoa, r.requisito_id)) END $$;

-- Ondas: a equipe ve o teste de qualquer tema, mesmo opcional sem D0 agendado (usa a onda de outra pessoa como modelo;
-- as questoes sao as mesmas). Para o aluno, nada muda.
CREATE OR REPLACE FUNCTION app.onda_da_pessoa(p_pessoa BIGINT, p_tema BIGINT, p_teste SMALLINT) RETURNS BIGINT
LANGUAGE sql STABLE AS $$
  SELECT o.onda_id FROM app.onda_instancia o
   WHERE o.tema_id = p_tema AND o.teste_num = p_teste
     AND (o.pessoa_id IS NULL OR o.pessoa_id = p_pessoa OR app.e_equipe(p_pessoa))
   ORDER BY (o.pessoa_id = p_pessoa) DESC NULLS LAST, (o.pessoa_id IS NULL) DESC, o.onda_id LIMIT 1 $$;

SELECT count(*) AS pessoas_da_equipe FROM app.pessoa p WHERE app.e_equipe(p.pessoa_id);
COMMIT;
\echo 'acesso completo da equipe: pronto'
