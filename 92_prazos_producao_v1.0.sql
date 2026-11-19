-- ============================================================
-- 92_prazos_producao_v1.0.sql
-- OBJETIVO: prazos de producao de cada tema, contados de tras para frente a partir da aula (decisao de 16/11/2026):
--   producao pronta 6 semanas antes da aula (todas as pecas e testes em rascunho);
--   revisao concluida 3 semanas antes da aula (tudo publicado, antes do pre-teste 1, que abre 15 dias antes).
--  - app.aula_planejada: a data da aula de cada um dos 39 temas principais (docs/calendario_aulas_2027_2028.md).
--    Nao mexe nas ondas: e so o calendario de producao. Temas opcionais nao tem data (cada aluno escolhe a sua).
--  - app.prazos_temas_base() e app.painel_prazos(): situacao de cada tema (aba "Prazos de producao" do painel).
--  - O supervisor dos agentes recebe os prazos no pacote dele e avisa o tema atrasado.
-- PRE-REQUISITO: 53, 88, 89. Pode ser rodado mais de uma vez.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.aula_planejada (
  tema_id BIGINT PRIMARY KEY REFERENCES app.tema (tema_id) ON DELETE CASCADE,
  ordem   SMALLINT NOT NULL,
  data    DATE NOT NULL);
GRANT SELECT ON app.aula_planejada TO api_rw;

INSERT INTO app.aula_planejada (tema_id, ordem, data)
SELECT t.tema_id, v.ordem, v.data
  FROM (VALUES
  (1, 'T-001', DATE '2027-03-04'),
  (2, 'T-002', DATE '2027-03-11'),
  (3, 'T-003', DATE '2027-03-18'),
  (4, 'T-015', DATE '2027-04-01'),
  (5, 'T-046', DATE '2027-04-08'),
  (6, 'T-047', DATE '2027-04-15'),
  (7, 'T-004', DATE '2027-04-29'),
  (8, 'T-005', DATE '2027-05-06'),
  (9, 'T-009', DATE '2027-05-13'),
  (10, 'T-010', DATE '2027-05-20'),
  (11, 'T-013', DATE '2027-06-03'),
  (12, 'T-014', DATE '2027-06-10'),
  (13, 'T-017', DATE '2027-06-17'),
  (14, 'T-026', DATE '2027-06-24'),
  (15, 'T-038', DATE '2027-07-01'),
  (16, 'T-049', DATE '2027-07-15'),
  (17, 'T-051', DATE '2027-07-22'),
  (18, 'T-052', DATE '2027-07-29'),
  (19, 'T-053', DATE '2027-08-05'),
  (20, 'T-057', DATE '2027-08-12'),
  (21, 'T-059', DATE '2027-08-19'),
  (22, 'T-066', DATE '2027-08-26'),
  (23, 'T-020', DATE '2027-09-02'),
  (24, 'T-023', DATE '2027-09-09'),
  (25, 'T-024', DATE '2027-09-16'),
  (26, 'T-025', DATE '2027-09-23'),
  (27, 'T-030', DATE '2027-09-30'),
  (28, 'T-037', DATE '2027-10-07'),
  (29, 'T-040', DATE '2027-10-14'),
  (30, 'T-041', DATE '2027-10-21'),
  (31, 'T-044', DATE '2027-11-04'),
  (32, 'T-048', DATE '2027-11-11'),
  (33, 'T-067', DATE '2028-01-13'),
  (34, 'T-019', DATE '2028-01-20'),
  (35, 'T-028', DATE '2028-01-27'),
  (36, 'T-035', DATE '2028-02-03'),
  (37, 'T-088', DATE '2028-02-10'),
  (38, 'T-089', DATE '2028-02-17'),
  (39, 'T-094', DATE '2028-02-24')) v(ordem, codigo, data)
  JOIN app.tema t ON t.codigo = v.codigo
ON CONFLICT (tema_id) DO UPDATE SET ordem = EXCLUDED.ordem, data = EXCLUDED.data;

-- Pecas exigidas para o tema ficar completo
CREATE OR REPLACE FUNCTION app.pecas_exigidas() RETURNS TEXT[]
LANGUAGE sql IMMUTABLE AS $$
  SELECT ARRAY['objetivos', 'resumo_basico', 'podcast_roteiro', 'caso_base', 'sintese_evidencia', 'mapa', 'aula', 'slides', 'caso',
               'resumo', 'protocolo', 'checklist', 'flashcard',
               'teste_1', 'teste_2', 'teste_3', 'teste_4', 'teste_5', 'teste_6',
               'gabarito_1', 'gabarito_2', 'gabarito_3', 'gabarito_4', 'gabarito_5', 'gabarito_6'] $$;

DROP FUNCTION IF EXISTS app.prazos_temas_base();
CREATE FUNCTION app.prazos_temas_base()
RETURNS TABLE (tema TEXT, titulo TEXT, aula DATE, prazo_producao DATE, prazo_revisao DATE, pecas_exigidas INT, pecas_produzidas INT,
               pecas_publicadas INT, questoes_ancora INT, textos_sem_parecer INT, situacao TEXT, faltam TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app, conteudo AS $$
  WITH b AS (
    SELECT t.tema_id, t.codigo, t.titulo, ap.data AS aula,
           (SELECT count(DISTINCT a.tipo) FROM conteudo.artefato a WHERE a.tema_id = t.tema_id
               AND a.status::text IN ('rascunho', 'publicado') AND a.tipo::text = ANY (app.pecas_exigidas()))::int AS produzidas,
           (SELECT count(DISTINCT a.tipo) FROM conteudo.artefato a WHERE a.tema_id = t.tema_id
               AND a.status::text = 'publicado' AND a.tipo::text = ANY (app.pecas_exigidas()))::int AS publicadas,
           (SELECT count(*) FROM app.item i WHERE i.tema_id = t.tema_id AND i.fixa)::int AS ancoras,
           (SELECT count(DISTINCT (f.texto, f.fonte_arquivo)) FROM conteudo.afirmacao f JOIN conteudo.artefato a ON a.artefato_id = f.artefato_id
             WHERE a.tema_id = t.tema_id AND a.status::text IN ('rascunho', 'publicado')
               AND NOT EXISTS (SELECT 1 FROM conteudo.parecer_revisao p WHERE p.artefato_id = f.artefato_id AND p.afirmacao_codigo = f.codigo))::int AS sem_parecer,
           (SELECT string_agg(app.nome_material(x), ', ' ORDER BY array_position(app.pecas_exigidas(), x))
              FROM unnest(app.pecas_exigidas()) x
             WHERE NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.tipo::text = x
                                  AND a.status::text IN ('rascunho', 'publicado'))) AS faltam
      FROM app.aula_planejada ap JOIN app.tema t ON t.tema_id = ap.tema_id)
  SELECT codigo, titulo, aula, aula - 42, aula - 21, cardinality(app.pecas_exigidas()), produzidas, publicadas, ancoras, sem_parecer,
         CASE WHEN publicadas = cardinality(app.pecas_exigidas()) THEN 'publicado'
              WHEN current_date > aula - 21 THEN 'revisão atrasada'
              WHEN produzidas < cardinality(app.pecas_exigidas()) AND current_date > aula - 42 THEN 'produção atrasada'
              WHEN produzidas < cardinality(app.pecas_exigidas()) AND current_date > aula - 56 THEN 'produção vence em ' || (aula - 42 - current_date) || ' dias'
              WHEN produzidas = cardinality(app.pecas_exigidas()) AND current_date > aula - 35 THEN 'revisão vence em ' || (aula - 21 - current_date) || ' dias'
              ELSE 'em dia' END,
         faltam
    FROM b ORDER BY aula $$;

DROP FUNCTION IF EXISTS app.painel_prazos();
CREATE FUNCTION app.painel_prazos()
RETURNS TABLE (tema TEXT, titulo TEXT, aula DATE, prazo_producao DATE, prazo_revisao DATE, pecas_exigidas INT, pecas_produzidas INT,
               pecas_publicadas INT, questoes_ancora INT, textos_sem_parecer INT, situacao TEXT, faltam TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app AS $$
  SELECT * FROM app.prazos_temas_base() WHERE app.papel_painel() IS NOT NULL $$;

GRANT EXECUTE ON FUNCTION app.pecas_exigidas(), app.prazos_temas_base(), app.painel_prazos() TO api_rw;
COMMIT;
SELECT 'prazos de producao (92): ' || count(*) || ' temas com data' AS situacao FROM app.aula_planejada;
