-- 68_estudo_dirigido_v1.0.sql
-- Estudo dirigido pelo aluno (nao entra em nota nem ranking):
--  (1) Simulado sob medida: o aluno escolhe temas, grau de dificuldade e numero de questoes; o sistema sorteia
--      questoes so de testes que ele JA enviou (o gabarito ja foi visto, entao nada de testes futuros vaza).
--      O grau e ajustado ao perfil do aluno (como na nota esperada).
--  (2) Flashcards: deck montado com os cards oficiais dos temas ja liberados no pos-aula, os cards do proprio
--      aluno e os cards que colegas decidiram compartilhar com quem faz o tema. Registro de acerto/erro por card.
--  (3) Criacao de flashcards pelo aluno. Se ele marcar a caixa no fim, o card vai direto para todos os participantes
--      do tema, SEM passar por revisor; aparece marcado como "feito por aluno", com o nome (ou o apelido, se preferir).
--      A coordenacao so consegue ocultar depois, caso algum card tenha erro grave.
-- Pre-requisito: 37, 60, 64 e 65. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) simulado ----------
CREATE TABLE IF NOT EXISTS app.simulado_aluno (
  simulado_id BIGSERIAL PRIMARY KEY,
  pessoa_id   BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  filtros     JSONB NOT NULL,
  itens       BIGINT[] NOT NULL,
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  concluido_em TIMESTAMPTZ,
  acertos     SMALLINT);
CREATE TABLE IF NOT EXISTS app.simulado_resposta (
  simulado_id BIGINT NOT NULL REFERENCES app.simulado_aluno(simulado_id) ON DELETE CASCADE,
  item_id     BIGINT NOT NULL REFERENCES app.item(item_id),
  alternativa_id BIGINT REFERENCES app.alternativa(alternativa_id),
  correta     BOOLEAN,
  segundos    INT,
  PRIMARY KEY (simulado_id, item_id));

-- Questoes que a pessoa pode usar no estudo: de testes ja enviados por ela (qualquer perfil) e a questao fixa
-- dos temas em que ela ja enviou algum teste.
CREATE OR REPLACE FUNCTION app.questoes_estudo(p_pessoa BIGINT)
RETURNS TABLE (item_id BIGINT, tema_id BIGINT, grau INT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH feitos AS (
    SELECT DISTINCT o.tema_id, o.teste_num FROM app.tentativa t JOIN app.onda_instancia o ON o.onda_id = t.onda_id
     WHERE t.pessoa_id = p_pessoa AND t.submetida_em IS NOT NULL AND o.tema_id IS NOT NULL)
  SELECT i.item_id, i.tema_id, app.grau_para_perfil(i, app.perfil_da_pessoa(p_pessoa))
    FROM app.item i
   WHERE EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id = i.item_id AND a.eh_correta)
     AND ((i.fixa AND i.tema_id IN (SELECT tema_id FROM feitos))
          OR (i.tema_id, i.teste_num) IN (SELECT tema_id, teste_num FROM feitos)) $$;

-- Monta o simulado. p: {temas:[codigos], grau_min, grau_max, quantidade}
CREATE OR REPLACE FUNCTION app.montar_simulado(p JSONB) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_p BIGINT := app.pessoa_atual(); v_itens BIGINT[]; v_id BIGINT;
        v_min INT := greatest(1, least(6, coalesce((p->>'grau_min')::int, 1)));
        v_max INT := greatest(1, least(6, coalesce((p->>'grau_max')::int, 6)));
        v_n INT := greatest(1, least(60, coalesce((p->>'quantidade')::int, 10)));
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT array_agg(item_id) INTO v_itens FROM (
    SELECT q.item_id FROM app.questoes_estudo(v_p) q JOIN app.tema t ON t.tema_id = q.tema_id
     WHERE q.grau BETWEEN least(v_min, v_max) AND greatest(v_min, v_max)
       AND (jsonb_array_length(coalesce(p->'temas', '[]')) = 0
            OR replace(t.codigo, '-', '') IN (SELECT replace(upper(x), '-', '') FROM jsonb_array_elements_text(p->'temas') x))
     ORDER BY random() LIMIT v_n) s;
  IF v_itens IS NULL THEN RAISE EXCEPTION 'sem_questoes'; END IF;
  INSERT INTO app.simulado_aluno (pessoa_id, filtros, itens) VALUES (v_p, p, v_itens) RETURNING simulado_id INTO v_id;
  RETURN app.simulado_ver(v_id);
END $$;

-- Questoes do simulado (sem gabarito enquanto nao concluido; com gabarito e justificativas depois).
CREATE OR REPLACE FUNCTION app.simulado_ver(p_id BIGINT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object('id', s.simulado_id, 'concluido', s.concluido_em IS NOT NULL, 'acertos', s.acertos, 'filtros', s.filtros,
    'questoes', (SELECT jsonb_agg(jsonb_build_object(
        'item_id', i.item_id, 'tema', t.codigo, 'enunciado', i.enunciado,
        'caso', (SELECT c.texto FROM app.caso_teste c WHERE c.tema_id = i.tema_id AND c.teste_num = i.teste_num AND NOT i.fixa LIMIT 1),
        'grau', app.grau_para_perfil(i, app.perfil_da_pessoa(s.pessoa_id)),
        'escolhida', r.alternativa_id,
        'alternativas', (SELECT jsonb_agg(jsonb_build_object('alternativa_id', a.alternativa_id, 'texto', a.texto,
                           'correta', CASE WHEN s.concluido_em IS NOT NULL THEN a.eh_correta END,
                           'justificativa', CASE WHEN s.concluido_em IS NOT NULL THEN a.justificativa END) ORDER BY a.ordem)
                          FROM app.alternativa a WHERE a.item_id = i.item_id)) ORDER BY o.n)
      FROM unnest(s.itens) WITH ORDINALITY o(item_id, n) JOIN app.item i ON i.item_id = o.item_id JOIN app.tema t ON t.tema_id = i.tema_id
      LEFT JOIN app.simulado_resposta r ON r.simulado_id = s.simulado_id AND r.item_id = i.item_id))
    FROM app.simulado_aluno s WHERE s.simulado_id = p_id AND s.pessoa_id = app.pessoa_atual() $$;

-- Entrega: respostas {item_id: alternativa_id}; corrige e devolve com gabarito.
CREATE OR REPLACE FUNCTION app.entregar_simulado(p_id BIGINT, p_respostas JSONB, p_segundos INT) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE s app.simulado_aluno;
BEGIN
  SELECT * INTO s FROM app.simulado_aluno WHERE simulado_id = p_id AND pessoa_id = app.pessoa_atual();
  IF s.simulado_id IS NULL THEN RAISE EXCEPTION 'simulado_nao_encontrado'; END IF;
  IF s.concluido_em IS NULL THEN
    INSERT INTO app.simulado_resposta (simulado_id, item_id, alternativa_id, correta, segundos)
    SELECT p_id, i, a.alternativa_id, coalesce(a.eh_correta, false), NULL
      FROM unnest(s.itens) i LEFT JOIN app.alternativa a ON a.item_id = i AND a.alternativa_id = (p_respostas->>(i::text))::bigint
    ON CONFLICT (simulado_id, item_id) DO UPDATE SET alternativa_id = EXCLUDED.alternativa_id, correta = EXCLUDED.correta;
    UPDATE app.simulado_aluno SET concluido_em = now(),
           acertos = (SELECT count(*) FILTER (WHERE correta) FROM app.simulado_resposta WHERE simulado_id = p_id),
           filtros = filtros || jsonb_build_object('segundos', greatest(0, least(coalesce(p_segundos, 0), 86400)))
     WHERE simulado_id = p_id;
  END IF;
  RETURN app.simulado_ver(p_id);
END $$;

-- ---------- (2) e (3) flashcards ----------
CREATE TABLE IF NOT EXISTS app.flashcard_aluno (
  flashcard_id BIGSERIAL PRIMARY KEY,
  autor_id     BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id      BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  frente       TEXT NOT NULL CHECK (length(frente) BETWEEN 3 AND 500),
  verso        TEXT NOT NULL CHECK (length(verso) BETWEEN 1 AND 1500),
  compartilhado BOOLEAN NOT NULL DEFAULT false,
  oculto       BOOLEAN NOT NULL DEFAULT false,
  criado_em    TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS app.flashcard_revisao (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  chave     TEXT NOT NULL,             -- 'oficial:<tema>:<n>' ou 'aluno:<id>'
  acertos   INT NOT NULL DEFAULT 0,
  erros     INT NOT NULL DEFAULT 0,
  ultima    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (pessoa_id, chave));

-- Cards oficiais de um tema: tabela "| n | frente | verso |" da peca publicada, sem os codigos das fontes.
CREATE OR REPLACE FUNCTION app.flashcards_oficiais(p_tema BIGINT)
RETURNS TABLE (n INT, frente TEXT, verso TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH a AS (SELECT corpo FROM conteudo.artefato WHERE tema_id = p_tema AND tipo = 'flashcard' AND status = 'publicado' ORDER BY versao DESC LIMIT 1),
  l AS (SELECT regexp_matches(a.corpo, '^\|\s*(\d+)\s*\|([^|\n]+)\|([^|\n]+)\|\s*$', 'gn') m FROM a)
  SELECT (m[1])::int, trim(regexp_replace(m[2], '\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]', '', 'g')),
         trim(regexp_replace(m[3], '\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]', '', 'g'))
    FROM l $$;

-- Flashcards de um tema ficam liberados para a pessoa quando ela chega ao pos-aula (etapa 4).
CREATE OR REPLACE FUNCTION app.flashcards_liberados(p_pessoa BIGINT, p_tema BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$ SELECT app.etapa_liberada(p_pessoa, p_tema) >= 4 $$;

-- Assinatura dos cards feitos por aluno: o nome completo ou, se o aluno preferir, um apelido.
CREATE TABLE IF NOT EXISTS app.estudo_assinatura (
  pessoa_id BIGINT PRIMARY KEY REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  apelido   TEXT NOT NULL CHECK (length(apelido) BETWEEN 2 AND 40));
CREATE OR REPLACE FUNCTION app.assinatura_de(p_pessoa BIGINT) RETURNS TEXT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce((SELECT apelido FROM app.estudo_assinatura WHERE pessoa_id = p_pessoa),
                  (SELECT nome_completo FROM app.pessoa WHERE pessoa_id = p_pessoa)) $$;
CREATE OR REPLACE FUNCTION app.minha_assinatura() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object('nome', p.nome_completo, 'apelido', a.apelido)
    FROM app.pessoa p LEFT JOIN app.estudo_assinatura a USING (pessoa_id) WHERE p.pessoa_id = app.pessoa_atual() $$;
-- Apelido vazio = volta a assinar com o nome.
CREATE OR REPLACE FUNCTION app.salvar_apelido(p_apelido TEXT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  IF coalesce(trim(p_apelido), '') = '' THEN DELETE FROM app.estudo_assinatura WHERE pessoa_id = app.pessoa_atual();
  ELSE INSERT INTO app.estudo_assinatura VALUES (app.pessoa_atual(), trim(p_apelido))
       ON CONFLICT (pessoa_id) DO UPDATE SET apelido = EXCLUDED.apelido; END IF;
END $$;

-- Deck: p {temas:[...], fontes:['oficiais','meus','colegas'], quantidade, so_dificeis}
CREATE OR REPLACE FUNCTION app.montar_deck(p JSONB) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH eu AS (SELECT app.pessoa_atual() AS id),
  temas AS (SELECT t.tema_id, t.codigo FROM app.tema t, eu
             WHERE (jsonb_array_length(coalesce(p->'temas', '[]')) = 0 OR replace(t.codigo,'-','') IN (SELECT replace(upper(x),'-','') FROM jsonb_array_elements_text(p->'temas') x))),
  fontes AS (SELECT coalesce(array(SELECT jsonb_array_elements_text(p->'fontes')), ARRAY['oficiais','meus','colegas']) AS f),
  cards AS (
    SELECT 'oficial:' || t.codigo || ':' || o.n AS chave, t.codigo AS tema, o.frente, o.verso, 'oficial' AS origem, NULL::text AS autor
      FROM temas t, eu, fontes, LATERAL app.flashcards_oficiais(t.tema_id) o
     WHERE 'oficiais' = ANY (fontes.f) AND app.flashcards_liberados(eu.id, t.tema_id)
    UNION ALL
    SELECT 'aluno:' || f.flashcard_id, t.codigo, f.frente, f.verso, CASE WHEN f.autor_id = eu.id THEN 'meu' ELSE 'colega' END, app.assinatura_de(f.autor_id)
      FROM app.flashcard_aluno f JOIN temas t ON t.tema_id = f.tema_id, eu, fontes
     WHERE NOT f.oculto AND ((f.autor_id = eu.id AND 'meus' = ANY (fontes.f))
            OR (f.autor_id <> eu.id AND f.compartilhado AND 'colegas' = ANY (fontes.f) AND app.flashcards_liberados(eu.id, t.tema_id)))),
  com_hist AS (SELECT c.*, coalesce(r.acertos, 0) AS acertos, coalesce(r.erros, 0) AS erros
                 FROM cards c CROSS JOIN eu LEFT JOIN app.flashcard_revisao r ON r.pessoa_id = eu.id AND r.chave = c.chave)
  SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) FROM (
    SELECT * FROM com_hist
     WHERE NOT coalesce((p->>'so_dificeis')::boolean, false) OR erros > acertos
     ORDER BY CASE WHEN coalesce((p->>'so_dificeis')::boolean, false) THEN erros - acertos END DESC NULLS LAST, random()
     LIMIT greatest(1, least(200, coalesce((p->>'quantidade')::int, 20)))) x $$;

CREATE OR REPLACE FUNCTION app.revisar_card(p_chave TEXT, p_acertou BOOLEAN) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.flashcard_revisao (pessoa_id, chave, acertos, erros)
  SELECT app.pessoa_atual(), left(p_chave, 80), CASE WHEN p_acertou THEN 1 ELSE 0 END, CASE WHEN p_acertou THEN 0 ELSE 1 END
   WHERE app.pessoa_atual() IS NOT NULL
  ON CONFLICT (pessoa_id, chave) DO UPDATE SET acertos = app.flashcard_revisao.acertos + EXCLUDED.acertos,
    erros = app.flashcard_revisao.erros + EXCLUDED.erros, ultima = now() $$;

-- Criar/editar card proprio (so de temas ja liberados no pos-aula).
CREATE OR REPLACE FUNCTION app.salvar_flashcard(p JSONB) RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_tema BIGINT; v BIGINT := (p->>'id')::bigint;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT tema_id INTO v_tema FROM app.tema WHERE replace(codigo,'-','') = replace(upper(p->>'tema'),'-','');
  IF v_tema IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  IF NOT app.flashcards_liberados(app.pessoa_atual(), v_tema) AND NOT app.eh_revisor() THEN RAISE EXCEPTION 'tema_nao_liberado'; END IF;
  IF v IS NULL THEN
    INSERT INTO app.flashcard_aluno (autor_id, tema_id, frente, verso, compartilhado)
    VALUES (app.pessoa_atual(), v_tema, trim(p->>'frente'), trim(p->>'verso'), coalesce((p->>'compartilhar')::boolean, false)) RETURNING flashcard_id INTO v;
  ELSE
    UPDATE app.flashcard_aluno SET frente = trim(p->>'frente'), verso = trim(p->>'verso'), compartilhado = coalesce((p->>'compartilhar')::boolean, false), tema_id = v_tema
     WHERE flashcard_id = v AND autor_id = app.pessoa_atual();
  END IF;
  RETURN v;
END $$;

CREATE OR REPLACE FUNCTION app.meus_flashcards() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', f.flashcard_id, 'tema', t.codigo, 'frente', f.frente, 'verso', f.verso,
           'compartilhado', f.compartilhado, 'oculto', f.oculto, 'criado_em', f.criado_em) ORDER BY f.criado_em DESC), '[]'::jsonb)
    FROM app.flashcard_aluno f JOIN app.tema t ON t.tema_id = f.tema_id WHERE f.autor_id = app.pessoa_atual() $$;

CREATE OR REPLACE FUNCTION app.apagar_flashcard(p_id BIGINT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  DELETE FROM app.flashcard_aluno WHERE flashcard_id = p_id AND autor_id = app.pessoa_atual() $$;

-- Coordenacao: cards compartilhados (para conferir) e ocultar/mostrar.
CREATE OR REPLACE FUNCTION app.flashcards_compartilhados() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', f.flashcard_id, 'tema', t.codigo, 'frente', f.frente, 'verso', f.verso,
           'autor', app.assinatura_de(f.autor_id), 'nome', p.nome_completo, 'oculto', f.oculto, 'criado_em', f.criado_em) ORDER BY f.criado_em DESC), '[]'::jsonb)
    FROM app.flashcard_aluno f JOIN app.tema t ON t.tema_id = f.tema_id JOIN app.pessoa p ON p.pessoa_id = f.autor_id
   WHERE f.compartilhado AND app.eh_revisor() $$;
CREATE OR REPLACE FUNCTION app.ocultar_flashcard(p_id BIGINT, p_oculto BOOLEAN) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  UPDATE app.flashcard_aluno SET oculto = p_oculto WHERE flashcard_id = p_id;
END $$;

-- Opcoes para montar o simulado: temas com questoes disponiveis e quantas por grau.
CREATE OR REPLACE FUNCTION app.opcoes_estudo() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object(
    'temas', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', t.codigo, 'titulo', t.titulo, 'questoes', x.n,
                                         'por_grau', x.g) ORDER BY t.codigo)
      FROM (SELECT q.tema_id, sum(q.k)::int AS n, jsonb_object_agg(q.grau, q.k) AS g
              FROM (SELECT tema_id, grau, count(*) AS k FROM app.questoes_estudo(app.pessoa_atual()) GROUP BY 1, 2) q
             GROUP BY q.tema_id) x JOIN app.tema t ON t.tema_id = x.tema_id), '[]'),
    'assinatura', app.minha_assinatura(),
    'flashcards', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', t.codigo, 'titulo', t.titulo,
        'oficiais', (SELECT count(*) FROM app.flashcards_oficiais(t.tema_id)),
        'meus', (SELECT count(*) FROM app.flashcard_aluno f WHERE f.tema_id = t.tema_id AND f.autor_id = app.pessoa_atual()),
        'colegas', (SELECT count(*) FROM app.flashcard_aluno f WHERE f.tema_id = t.tema_id AND f.compartilhado AND NOT f.oculto AND f.autor_id <> app.pessoa_atual())) ORDER BY t.codigo)
      FROM app.tema t WHERE app.flashcards_liberados(app.pessoa_atual(), t.tema_id)), '[]'),
    'historico', coalesce((SELECT jsonb_agg(jsonb_build_object('id', s.simulado_id, 'criado_em', s.criado_em, 'questoes', cardinality(s.itens),
        'acertos', s.acertos, 'filtros', s.filtros) ORDER BY s.criado_em DESC)
      FROM (SELECT * FROM app.simulado_aluno WHERE pessoa_id = app.pessoa_atual() ORDER BY criado_em DESC LIMIT 20) s), '[]'))
  WHERE app.pessoa_atual() IS NOT NULL $$;

-- Painel: uso do estudo dirigido.
CREATE OR REPLACE FUNCTION app.painel_estudo()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, simulados INT, questoes INT, acerto_pct NUMERIC,
               cards_revisados INT, cards_criados INT, cards_compartilhados INT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(p.pessoa_id), pf.ano, pf.especialidade, pf.turma,
         (SELECT count(*)::int FROM app.simulado_aluno s WHERE s.pessoa_id = p.pessoa_id AND s.concluido_em IS NOT NULL),
         (SELECT coalesce(sum(cardinality(s.itens)), 0)::int FROM app.simulado_aluno s WHERE s.pessoa_id = p.pessoa_id AND s.concluido_em IS NOT NULL),
         (SELECT round(100.0 * sum(s.acertos) / nullif(sum(cardinality(s.itens)), 0), 0) FROM app.simulado_aluno s WHERE s.pessoa_id = p.pessoa_id AND s.concluido_em IS NOT NULL),
         (SELECT coalesce(sum(r.acertos + r.erros), 0)::int FROM app.flashcard_revisao r WHERE r.pessoa_id = p.pessoa_id),
         (SELECT count(*)::int FROM app.flashcard_aluno f WHERE f.autor_id = p.pessoa_id),
         (SELECT count(*)::int FROM app.flashcard_aluno f WHERE f.autor_id = p.pessoa_id AND f.compartilhado)
    FROM app.pessoa p JOIN app.ficha_aluno fa ON fa.pessoa_id = p.pessoa_id AND fa.status = 'aprovado', LATERAL app.perfil_aluno(p.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL ORDER BY 1 $$;

REVOKE EXECUTE ON FUNCTION app.questoes_estudo(BIGINT), app.opcoes_estudo(), app.montar_simulado(JSONB), app.simulado_ver(BIGINT),
  app.entregar_simulado(BIGINT, JSONB, INT), app.flashcards_oficiais(BIGINT), app.montar_deck(JSONB), app.revisar_card(TEXT, BOOLEAN),
  app.salvar_flashcard(JSONB), app.meus_flashcards(), app.apagar_flashcard(BIGINT), app.flashcards_compartilhados(),
  app.ocultar_flashcard(BIGINT, BOOLEAN), app.painel_estudo(), app.assinatura_de(BIGINT), app.minha_assinatura(), app.salvar_apelido(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.opcoes_estudo(), app.montar_simulado(JSONB), app.simulado_ver(BIGINT), app.entregar_simulado(BIGINT, JSONB, INT),
  app.montar_deck(JSONB), app.revisar_card(TEXT, BOOLEAN), app.salvar_flashcard(JSONB), app.meus_flashcards(), app.apagar_flashcard(BIGINT),
  app.flashcards_compartilhados(), app.ocultar_flashcard(BIGINT, BOOLEAN), app.painel_estudo(), app.flashcards_liberados(BIGINT, BIGINT), app.minha_assinatura(), app.salvar_apelido(TEXT) TO api_rw;

COMMIT;
\echo 'estudo dirigido (simulados sob medida e flashcards): pronto'
