-- 64_nota_esperada_v1.0.sql
-- Nota esperada de cada teste e comparativos para o aluno.
--  - Taxa esperada por grau (ponto medio da faixa do banco): muito facil 95%, facil 82,5%, media 62,5%,
--    dificil 40%, muito dificil 22,5%, extrema 7,5%.
--  - O grau de cada questao e ajustado ao perfil do aluno: questao escrita como "media" para R1 fica um grau mais
--    facil para o R2, dois para o R3 etc. (e mais dificil para quem esta abaixo). A questao fixa segue a tabela
--    do banco: graduacao media, R1 facil, R2 em diante muito facil.
--  - Nota esperada do teste = media das taxas esperadas das questoes que o aluno respondeu.
--  - Comparativos por teste: nota real, esperada, media de todos e media do subgrupo (mesmo ano de residencia e
--    mesma especialidade). Medias de grupo so aparecem com 3 ou mais alunos, para ninguem deduzir a nota de outro.
-- Pre-requisito: 37, 55, 60 e 62. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

CREATE OR REPLACE FUNCTION app.taxa_do_grau(g INT) RETURNS NUMERIC LANGUAGE sql IMMUTABLE AS $$
  SELECT (ARRAY[95, 82.5, 62.5, 40, 22.5, 7.5])[least(6, greatest(1, g))]::numeric $$;
CREATE OR REPLACE FUNCTION app.nivel_perfil(p TEXT) RETURNS INT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p WHEN 'graduacao' THEN 0 WHEN 'R1' THEN 1 WHEN 'R2' THEN 2 WHEN 'R3' THEN 3 WHEN 'R+' THEN 4 END $$;

-- Grau da questao para um aluno de determinado perfil.
CREATE OR REPLACE FUNCTION app.grau_para_perfil(p_item app.item, p_perfil TEXT) RETURNS INT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE
    WHEN p_item.fixa THEN CASE WHEN p_perfil IS NULL THEN coalesce(p_item.dificuldade, 3) WHEN p_perfil = 'graduacao' THEN 3
                             WHEN p_perfil = 'R1' THEN 2 ELSE 1 END
    WHEN p_item.perfil IS NULL OR p_perfil IS NULL THEN coalesce(p_item.dificuldade, 3)
    ELSE least(6, greatest(1, coalesce(p_item.dificuldade, 3) - (app.nivel_perfil(p_perfil) - app.nivel_perfil(p_item.perfil)))) END $$;

CREATE OR REPLACE FUNCTION app.nota_esperada(p_tentativa BIGINT, p_perfil TEXT) RETURNS NUMERIC
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT round(avg(app.taxa_do_grau(app.grau_para_perfil(i, p_perfil))), 1)
    FROM app.resposta r JOIN app.item i ON i.item_id = r.item_id
   WHERE r.tentativa_id = p_tentativa $$;

ALTER TABLE app.nota_teste ADD COLUMN IF NOT EXISTS esperado NUMERIC(5,1);
CREATE OR REPLACE FUNCTION app.fn_nota_esperada() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
BEGIN
  NEW.esperado := app.nota_esperada(NEW.tentativa_id, NEW.perfil);
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_nota_esperada ON app.nota_teste;
CREATE TRIGGER tg_nota_esperada BEFORE INSERT ON app.nota_teste FOR EACH ROW EXECUTE FUNCTION app.fn_nota_esperada();
UPDATE app.nota_teste SET esperado = app.nota_esperada(tentativa_id, perfil) WHERE esperado IS NULL;

-- Comparativo da pessoa logada, por teste (1 a 6). Com tema: daquele tema; sem tema: media dos temas que ela fez.
CREATE OR REPLACE FUNCTION app.meu_comparativo(p_codigo TEXT DEFAULT NULL)
RETURNS TABLE (teste_num SMALLINT, nota NUMERIC, esperada NUMERIC, media_todos NUMERIC, n_todos INT, media_subgrupo NUMERIC, n_subgrupo INT,
               ano TEXT, especialidade TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH eu AS (SELECT app.pessoa_atual() AS id),
  tema AS (SELECT t.tema_id FROM app.tema t WHERE p_codigo IS NOT NULL AND upper(replace(t.codigo,'-','')) = upper(replace(p_codigo,'-',''))),
  minhas AS (  -- ultima nota de cada tema/teste da pessoa
    SELECT DISTINCT ON (n.tema_id, n.teste_num) n.* FROM app.nota_teste n, eu
     WHERE n.pessoa_id = eu.id AND (p_codigo IS NULL OR n.tema_id IN (SELECT tema_id FROM tema))
     ORDER BY n.tema_id, n.teste_num, n.submetida_em DESC),
  perfil AS (SELECT (SELECT grau::text FROM app.posicao_anual x, eu WHERE x.pessoa_id = eu.id AND x.ativo ORDER BY ano_letivo DESC LIMIT 1) AS ano,
                    (SELECT x.especialidade FROM app.posicao_anual x, eu WHERE x.pessoa_id = eu.id AND x.ativo ORDER BY ano_letivo DESC LIMIT 1) AS esp),
  todas AS (  -- primeira nota de cada pessoa em cada tema/teste que a pessoa logada fez
    SELECT DISTINCT ON (n.pessoa_id, n.tema_id, n.teste_num) n.* FROM app.nota_teste n
     WHERE (n.tema_id, n.teste_num) IN (SELECT tema_id, teste_num FROM minhas)
     ORDER BY n.pessoa_id, n.tema_id, n.teste_num, n.submetida_em),
  g AS (SELECT t.teste_num, avg(t.pct) AS m, count(DISTINCT t.pessoa_id)::int AS n FROM todas t GROUP BY 1),
  s AS (SELECT t.teste_num, avg(t.pct) AS m, count(DISTINCT t.pessoa_id)::int AS n FROM todas t, perfil
         WHERE t.ano IS NOT DISTINCT FROM perfil.ano AND t.especialidade IS NOT DISTINCT FROM perfil.esp GROUP BY 1)
  SELECT m.teste_num, round(avg(m.pct), 1), round(avg(m.esperado), 1),
         CASE WHEN g.n >= 3 THEN round(g.m, 1) END, g.n, CASE WHEN s.n >= 3 THEN round(s.m, 1) END, coalesce(s.n, 0),
         (SELECT ano FROM perfil), (SELECT esp FROM perfil)
    FROM minhas m LEFT JOIN g ON g.teste_num = m.teste_num LEFT JOIN s ON s.teste_num = m.teste_num
   WHERE app.pessoa_atual() IS NOT NULL
   GROUP BY m.teste_num, g.m, g.n, s.m, s.n
   ORDER BY 1 $$;
REVOKE EXECUTE ON FUNCTION app.meu_comparativo(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.meu_comparativo(TEXT) TO api_rw;

-- Painel: nota esperada junto das notas.
DROP FUNCTION IF EXISTS app.painel_notas();
CREATE FUNCTION app.painel_notas()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, teste_num SMALLINT, teste TEXT,
               acertos SMALLINT, total SMALLINT, pct NUMERIC, esperado NUMERIC, nota_ponderada NUMERIC, tempo_s INT, submetida_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(n.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, n.teste_num, app.nome_teste(n.teste_num),
         n.acertos, n.total, n.pct, n.esperado, n.nota_ponderada, n.tempo_total_s, n.submetida_em
    FROM app.nota_teste n JOIN app.tema t ON t.tema_id = n.tema_id, LATERAL app.perfil_aluno(n.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY n.submetida_em $$;
REVOKE EXECUTE ON FUNCTION app.painel_notas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.painel_notas() TO api_rw;

COMMIT;
\echo 'nota esperada e comparativos: prontos'
