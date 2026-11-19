-- ============================================================
-- 109_simulado_filtros_v1.0.sql
-- OBJETIVO (pedido da coordenacao em 19/11/2026): simulado do estudo dirigido com o banco inteiro e filtros.
--  - O aluno escolhe temas, dificuldade e numero de questoes, ou pede TODAS as questoes que passam nos filtros.
--  - Filtros pelo historico dele em cada questao (ondas e simulados): todas; ineditas; repetidas; ja acertei;
--    ja errei alguma vez; errei da ultima vez; sempre acertei; e numero de vezes que ja respondeu (de/ate).
--  - No gabarito: quantas vezes a questao foi respondida no curso, por quantas pessoas, a taxa de acerto e a
--    porcentagem de escolha de cada alternativa (ondas enviadas e simulados entregues, todos os alunos).
--  Quais questoes entram (decisao da coordenacao de 19/11/2026): todas as questoes e casos das ondas que o aluno ja
--  enviou; depois do D+90 isso cobre o tema inteiro. Ondas futuras continuam fechadas, para proteger a medida de
--  retencao do estudo (app.questoes_estudo, do 68, nao muda).
-- Pre-requisito: 68 e 85. Pode ser rodado mais de uma vez. Desfazer: rodar de novo o 68 e o 85.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

-- Cada resposta dada a cada questao: ondas enviadas e simulados entregues.
CREATE OR REPLACE VIEW app.v_resposta_item AS
  SELECT t.pessoa_id, r.item_id, r.alternativa_id, a.eh_correta AS correta, r.respondida_em AS em
    FROM app.resposta r JOIN app.tentativa t ON t.tentativa_id = r.tentativa_id AND t.submetida_em IS NOT NULL
    JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
  UNION ALL
  SELECT s.pessoa_id, sr.item_id, sr.alternativa_id, coalesce(sr.correta, false), s.concluido_em
    FROM app.simulado_resposta sr JOIN app.simulado_aluno s ON s.simulado_id = sr.simulado_id AND s.concluido_em IS NOT NULL
   WHERE sr.alternativa_id IS NOT NULL;
REVOKE ALL ON app.v_resposta_item FROM PUBLIC;

-- Historico da pessoa em cada questao que ela ja respondeu.
CREATE OR REPLACE FUNCTION app.historico_itens(p_pessoa BIGINT)
RETURNS TABLE (item_id BIGINT, vezes INT, acertos INT, erros INT, ultima_correta BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT v.item_id, count(*)::int, count(*) FILTER (WHERE v.correta)::int, count(*) FILTER (WHERE NOT v.correta)::int,
         (array_agg(v.correta ORDER BY v.em DESC))[1]
    FROM app.v_resposta_item v WHERE v.pessoa_id = p_pessoa GROUP BY v.item_id $$;

-- Estatistica da questao no curso (todas as pessoas): respostas, pessoas, acerto e escolha de cada alternativa.
CREATE OR REPLACE FUNCTION app.estatistica_item(p_item BIGINT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH v AS (SELECT * FROM app.v_resposta_item WHERE item_id = p_item)
  SELECT jsonb_build_object(
    'respostas', (SELECT count(*) FROM v),
    'pessoas', (SELECT count(DISTINCT pessoa_id) FROM v),
    'acerto_pct', (SELECT CASE WHEN count(*) > 0 THEN round(100.0 * count(*) FILTER (WHERE correta) / count(*)) END FROM v),
    'alternativas', (SELECT coalesce(jsonb_object_agg(a.alternativa_id::text,
                       CASE WHEN t.n > 0 THEN round(100.0 * (SELECT count(*) FROM v WHERE v.alternativa_id = a.alternativa_id) / t.n) ELSE 0 END), '{}')
                     FROM app.alternativa a CROSS JOIN (SELECT count(*) AS n FROM v) t WHERE a.item_id = p_item)) $$;

-- Questoes candidatas para os filtros p (mesmos campos do montar_simulado). Usada para contar e para montar.
CREATE OR REPLACE FUNCTION app.candidatas_simulado(p_pessoa BIGINT, p JSONB)
RETURNS TABLE (item_id BIGINT, tema_id BIGINT, rodada BIGINT, sorteio DOUBLE PRECISION)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH par AS (
    SELECT coalesce(p->>'modo', '') AS modo,
           greatest(1, least(6, coalesce((p->>'grau_min')::int, 1))) AS gmin,
           greatest(1, least(6, coalesce((p->>'grau_max')::int, 6))) AS gmax,
           coalesce(nullif(p->>'historico', ''), 'todas') AS hist,
           nullif(p->>'vezes_min', '')::int AS vmin, nullif(p->>'vezes_max', '')::int AS vmax)
  SELECT q.item_id, q.tema_id,
         CASE WHEN par.modo IN ('revisao', 'misturado') THEN row_number() OVER (PARTITION BY q.tema_id ORDER BY coalesce(r.proxima, now()), random()) ELSE 1 END,
         random()
    FROM par, app.questoes_estudo(p_pessoa) q JOIN app.tema t ON t.tema_id = q.tema_id
    LEFT JOIN app.item_revisao r ON r.pessoa_id = p_pessoa AND r.item_id = q.item_id
    LEFT JOIN app.historico_itens(p_pessoa) h ON h.item_id = q.item_id
   WHERE (par.modo IN ('revisao', 'misturado') OR q.grau BETWEEN least(par.gmin, par.gmax) AND greatest(par.gmin, par.gmax))
     AND (par.modo <> 'revisao' OR r.proxima <= now())
     AND (par.modo IN ('revisao', 'misturado') OR jsonb_array_length(coalesce(p->'temas', '[]')) = 0
          OR replace(t.codigo, '-', '') IN (SELECT replace(upper(x), '-', '') FROM jsonb_array_elements_text(p->'temas') x))
     AND CASE par.hist
           WHEN 'ineditas'       THEN coalesce(h.vezes, 0) = 0
           WHEN 'repetidas'      THEN coalesce(h.vezes, 0) >= 1
           WHEN 'ja_acertei'     THEN coalesce(h.acertos, 0) >= 1
           WHEN 'ja_errei'       THEN coalesce(h.erros, 0) >= 1
           WHEN 'errei_ultima'   THEN h.ultima_correta IS FALSE
           WHEN 'sempre_acertei' THEN coalesce(h.vezes, 0) >= 1 AND coalesce(h.erros, 0) = 0
           ELSE true END
     AND (par.vmin IS NULL OR coalesce(h.vezes, 0) >= par.vmin)
     AND (par.vmax IS NULL OR coalesce(h.vezes, 0) <= par.vmax) $$;

CREATE OR REPLACE FUNCTION app.contar_simulado(p JSONB) RETURNS INT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT count(*)::int FROM app.candidatas_simulado(app.pessoa_atual(), p) WHERE app.pessoa_atual() IS NOT NULL $$;

-- Monta o simulado. Novos campos em p: historico, vezes_min, vezes_max e todas (true = todas as candidatas, ate 1000).
CREATE OR REPLACE FUNCTION app.montar_simulado(p JSONB) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_p BIGINT := app.pessoa_atual(); v_itens BIGINT[]; v_id BIGINT;
        v_n INT := CASE WHEN coalesce((p->>'todas')::boolean, false) THEN 1000
                        ELSE greatest(1, least(500, coalesce((p->>'quantidade')::int, 10))) END;
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT array_agg(item_id ORDER BY rodada, sorteio) INTO v_itens
    FROM (SELECT * FROM app.candidatas_simulado(v_p, p) ORDER BY rodada, sorteio LIMIT v_n) s;
  IF v_itens IS NULL THEN RAISE EXCEPTION 'sem_questoes'; END IF;
  INSERT INTO app.simulado_aluno (pessoa_id, filtros, itens) VALUES (v_p, p, v_itens) RETURNING simulado_id INTO v_id;
  RETURN app.simulado_ver(v_id);
END $$;

-- Questoes do simulado. Depois de entregue, cada questao traz tambem a estatistica do curso e o historico do aluno.
CREATE OR REPLACE FUNCTION app.simulado_ver(p_id BIGINT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object('id', s.simulado_id, 'concluido', s.concluido_em IS NOT NULL, 'acertos', s.acertos, 'filtros', s.filtros,
    'questoes', (SELECT jsonb_agg(jsonb_build_object(
        'item_id', i.item_id, 'tema', t.codigo, 'enunciado', i.enunciado,
        'caso', (SELECT c.texto FROM app.caso_teste c WHERE c.tema_id = i.tema_id AND c.teste_num = i.teste_num AND NOT i.fixa LIMIT 1),
        'grau', app.grau_para_perfil(i, app.perfil_da_pessoa(s.pessoa_id)),
        'escolhida', r.alternativa_id,
        'estatistica', CASE WHEN s.concluido_em IS NOT NULL THEN app.estatistica_item(i.item_id) END,
        'minhas_vezes', CASE WHEN s.concluido_em IS NOT NULL THEN (SELECT h.vezes FROM app.historico_itens(s.pessoa_id) h WHERE h.item_id = i.item_id) END,
        'alternativas', (SELECT jsonb_agg(jsonb_build_object('alternativa_id', a.alternativa_id, 'texto', a.texto,
                           'correta', CASE WHEN s.concluido_em IS NOT NULL THEN a.eh_correta END,
                           'justificativa', CASE WHEN s.concluido_em IS NOT NULL THEN a.justificativa END) ORDER BY a.ordem)
                          FROM app.alternativa a WHERE a.item_id = i.item_id)) ORDER BY o.n)
      FROM unnest(s.itens) WITH ORDINALITY o(item_id, n) JOIN app.item i ON i.item_id = o.item_id JOIN app.tema t ON t.tema_id = i.tema_id
      LEFT JOIN app.simulado_resposta r ON r.simulado_id = s.simulado_id AND r.item_id = i.item_id))
    FROM app.simulado_aluno s WHERE s.simulado_id = p_id AND s.pessoa_id = app.pessoa_atual() $$;

REVOKE EXECUTE ON FUNCTION app.historico_itens(BIGINT), app.estatistica_item(BIGINT), app.candidatas_simulado(BIGINT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.contar_simulado(JSONB), app.montar_simulado(JSONB), app.simulado_ver(BIGINT) TO api_rw;

SELECT 'simulado com filtros e estatistica: pronto' AS ok;
COMMIT;
