-- ============================================================
-- 94_aproveitar_pareceres_v1.0.sql
-- OBJETIVO: depois de importar uma versão nova de um tema, aproveitar os pareceres já dados.
--   1. Copia cada parecer de afirmação das versões anteriores do tema para a afirmação idêntica (mesmo texto e mesma
--      fonte) das peças em rascunho, em nome do mesmo revisor, com a origem anotada no comentário. Só copia onde esse
--      revisor ainda não deu parecer.
--   2. Remove as questões de exemplo da instalação (sem código, sem perfil, sem teste e nunca respondidas), que podiam
--      entrar nas ondas de teste.
-- USO (no WSL, dentro de ~/Curso-UE), trocando T001 pelo tema e SENHA pela senha do banco:
--   PGPASSWORD=SENHA psql -h localhost -U postgres -d programa -v tema=T001 -f 94_aproveitar_pareceres_v1.0.sql
-- Pode ser rodado mais de uma vez: não duplica nada e não apaga parecer.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE TEMP TABLE _tema ON COMMIT DROP AS
  SELECT tema_id, codigo FROM app.tema WHERE replace(codigo, '-', '') = replace(upper(:'tema'), '-', '');
DO $$ BEGIN IF (SELECT count(*) FROM _tema) <> 1 THEN RAISE EXCEPTION 'tema nao encontrado'; END IF; END $$;

\echo 'antes: afirmacoes das pecas em rascunho, com e sem parecer'
SELECT count(*) AS afirmacoes_em_rascunho,
       count(*) FILTER (WHERE EXISTS (SELECT 1 FROM conteudo.parecer_revisao p WHERE p.artefato_id = f.artefato_id AND p.afirmacao_codigo = f.codigo)) AS ja_com_parecer
  FROM conteudo.afirmacao f JOIN conteudo.artefato a USING (artefato_id) JOIN _tema t USING (tema_id)
 WHERE a.status::text = 'rascunho';

-- 1. pareceres das versoes anteriores -> afirmacoes identicas em rascunho
-- (o gatilho de replicacao repete o parecer nas outras copias do mesmo texto; ON CONFLICT evita duplicar)
WITH origem AS (
  SELECT DISTINCT ON (f.texto, coalesce(f.fonte_arquivo, ''), p.pessoa_id)
         f.texto, coalesce(f.fonte_arquivo, '') AS fonte, p.pessoa_id, p.decisao, p.comentario,
         app.nome_material(a.tipo::text) AS peca, a.versao, f.codigo
    FROM conteudo.parecer_revisao p
    JOIN conteudo.afirmacao f ON f.artefato_id = p.artefato_id AND f.codigo = p.afirmacao_codigo
    JOIN conteudo.artefato a ON a.artefato_id = p.artefato_id
    JOIN _tema t ON t.tema_id = a.tema_id
   WHERE a.status::text <> 'rascunho'
   ORDER BY f.texto, coalesce(f.fonte_arquivo, ''), p.pessoa_id, p.criado_em DESC),
destino AS (
  SELECT f.artefato_id, f.codigo, f.texto, coalesce(f.fonte_arquivo, '') AS fonte
    FROM conteudo.afirmacao f JOIN conteudo.artefato a USING (artefato_id) JOIN _tema t USING (tema_id)
   WHERE a.status::text = 'rascunho')
INSERT INTO conteudo.parecer_revisao (artefato_id, afirmacao_codigo, pessoa_id, decisao, comentario)
SELECT d.artefato_id, d.codigo, o.pessoa_id, o.decisao,
       left(concat_ws(' ', o.comentario, '[parecer da versão ' || o.versao || ' de ' || o.peca || ', ' || o.codigo || ', aproveitado na versão nova]'), 4000)
  FROM destino d JOIN origem o ON o.texto = d.texto AND o.fonte = d.fonte
ON CONFLICT (artefato_id, afirmacao_codigo, pessoa_id) DO NOTHING;

\echo 'depois: afirmacoes das pecas em rascunho, com e sem parecer'
SELECT count(*) AS afirmacoes_em_rascunho,
       count(*) FILTER (WHERE EXISTS (SELECT 1 FROM conteudo.parecer_revisao p WHERE p.artefato_id = f.artefato_id AND p.afirmacao_codigo = f.codigo)) AS ja_com_parecer,
       count(DISTINCT f.texto) FILTER (WHERE NOT EXISTS (SELECT 1 FROM conteudo.parecer_revisao p WHERE p.artefato_id = f.artefato_id AND p.afirmacao_codigo = f.codigo)) AS textos_ainda_sem_parecer
  FROM conteudo.afirmacao f JOIN conteudo.artefato a USING (artefato_id) JOIN _tema t USING (tema_id)
 WHERE a.status::text = 'rascunho';

-- 2. questoes de exemplo da instalacao
\echo 'questoes de exemplo removidas (sem codigo, sem perfil, sem teste e sem resposta):'
WITH apagar AS (
  SELECT i.item_id FROM app.item i JOIN _tema t USING (tema_id)
   WHERE i.codigo IS NULL AND i.perfil IS NULL AND i.teste_num IS NULL AND NOT i.fixa
     AND NOT EXISTS (SELECT 1 FROM app.resposta r WHERE r.item_id = i.item_id)),
z AS (UPDATE app.item i SET gabarito_alternativa_id = NULL FROM apagar a WHERE i.item_id = a.item_id RETURNING i.item_id)
SELECT count(*) AS marcadas FROM z;
DELETE FROM app.item i USING _tema t
 WHERE i.tema_id = t.tema_id AND i.codigo IS NULL AND i.perfil IS NULL AND i.teste_num IS NULL AND NOT i.fixa
   AND NOT EXISTS (SELECT 1 FROM app.resposta r WHERE r.item_id = i.item_id);

COMMIT;
\echo 'pronto.'
