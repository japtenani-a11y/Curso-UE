-- ============================================================
-- 104_meu_material_v1.0.sql
-- OBJETIVO (pedido da coordenacao em 19/11/2026): no Inicio do aluno, um quadro clicavel com todo o material ja
-- liberado para ele, separado em "Novo" (ainda nao aberto) e "Ja visto", de todos os temas.
-- Liberado = peca publicada (a versao mais recente de cada tipo) cuja etapa ja abriu para a pessoa
-- (app.etapa_liberada >= app.etapa_do_material). Visto = a pessoa ja passou tempo na peca (app.leitura_tempo).
-- Para a equipe (103) aparece tudo o que esta publicado.
-- Pode ser rodado mais de uma vez.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE OR REPLACE FUNCTION app.meu_material()
RETURNS TABLE (codigo TEXT, titulo TEXT, tipo TEXT, publicado_em TIMESTAMPTZ, visto BOOLEAN, ultimo_acesso TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH p AS (SELECT app.pessoa_atual() AS id),
  pecas AS (
    SELECT DISTINCT ON (a.tema_id, a.tipo) a.tema_id, a.tipo::text AS tipo, a.publicado_em
      FROM conteudo.artefato a
     WHERE a.status = 'publicado' AND app.etapa_do_material(a.tipo::text) IS NOT NULL
     ORDER BY a.tema_id, a.tipo, a.versao DESC)
  SELECT replace(t.codigo, '-', ''), t.titulo, pc.tipo, pc.publicado_em,
         lt.ultimo IS NOT NULL, lt.ultimo
    FROM pecas pc JOIN app.tema t ON t.tema_id = pc.tema_id, p
    LEFT JOIN LATERAL (SELECT max(l.em) AS ultimo FROM app.leitura_tempo l
                        WHERE l.pessoa_id = p.id AND l.tema_id = pc.tema_id AND l.tipo = pc.tipo) lt ON true
   WHERE p.id IS NOT NULL AND app.etapa_liberada(p.id, pc.tema_id) >= app.etapa_do_material(pc.tipo)
   ORDER BY (lt.ultimo IS NOT NULL), coalesce(lt.ultimo, pc.publicado_em) DESC NULLS LAST, t.codigo, app.etapa_do_material(pc.tipo) $$;
REVOKE EXECUTE ON FUNCTION app.meu_material() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.meu_material() TO api_rw;

COMMIT;
\echo 'meu material (Inicio do aluno): pronto'
