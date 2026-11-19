-- ============================================================
-- 105_temas_liberados_v1.0.sql
-- OBJETIVO (pedido da coordenacao em 19/11/2026): a pagina "Aulas" lista os TEMAS liberados (publicados), como o
-- T001, com o acesso direto a cada um. Um tema entra quando tem pelo menos uma peca publicada.
-- Para cada tema: etapa da pessoa (0 = bloqueado pela arvore ... 4 = tudo liberado), pecas publicadas, quantas a
-- pessoa ja abriu e quais pecas da aula ja estao abertas para ela.
-- Pode ser rodado mais de uma vez.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE OR REPLACE FUNCTION app.temas_liberados()
RETURNS TABLE (codigo TEXT, titulo TEXT, modulo TEXT, papel TEXT, etapa INT, pecas INT, vistas INT, aula_aberta BOOLEAN,
               publicado_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH p AS (SELECT app.pessoa_atual() AS id),
  pub AS (
    SELECT DISTINCT ON (a.tema_id, a.tipo) a.tema_id, a.tipo::text AS tipo, a.publicado_em
      FROM conteudo.artefato a
     WHERE a.status = 'publicado' AND app.etapa_do_material(a.tipo::text) IS NOT NULL
     ORDER BY a.tema_id, a.tipo, a.versao DESC)
  SELECT replace(t.codigo, '-', ''), t.titulo, t.modulo, t.papel_curricular::text,
         app.etapa_liberada(p.id, t.tema_id),
         count(*)::int,
         count(*) FILTER (WHERE EXISTS (SELECT 1 FROM app.leitura_tempo l WHERE l.pessoa_id = p.id AND l.tema_id = t.tema_id AND l.tipo = pub.tipo))::int,
         app.etapa_liberada(p.id, t.tema_id) >= 3 AND bool_or(pub.tipo = 'aula'),
         max(pub.publicado_em)
    FROM pub JOIN app.tema t ON t.tema_id = pub.tema_id, p
   WHERE p.id IS NOT NULL
   GROUP BY t.tema_id, t.codigo, t.titulo, t.modulo, t.papel_curricular, p.id
   ORDER BY t.codigo $$;
REVOKE EXECUTE ON FUNCTION app.temas_liberados() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.temas_liberados() TO api_rw;

COMMIT;
\echo 'temas liberados (pagina Aulas): pronto'
