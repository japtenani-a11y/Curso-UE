-- 73_extras_v1.0.sql
-- (1) Fila de producao de 1 a 150, atualizada sozinha:
--       1o) os 39 temas principais, na ordem das aulas;
--       2o) os opcionais com maior taxa de "Avise-me" (pedidos / alunos ativos);
--       3o) os demais por importancia: relevancia no plantao (incidencia e gravidade, 1 a 5), quantos temas libera
--           na arvore e se e recomendado.
--     A relevancia fica em app.tema.relevancia_plantao e pode ser ajustada pela coordenacao (o script so preenche vazios).
-- (2) "Tenho interesse em pesquisar este tema": a partir das sugestoes da sintese de evidencia; lista para a coordenacao.
-- (3) Repeticao espacada nos flashcards (intervalos crescentes; quem erra volta no mesmo dia).
-- (4) Certificado por modulo concluido.
-- (5) Coleta: tempo de leitura por peca, confianca antes de cada teste (calibracao) e aplicabilidade 30 dias depois.
-- Pre-requisito: 53, 60, 65, 66, 68, 71. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) relevancia e fila ----------
ALTER TABLE app.tema ADD COLUMN IF NOT EXISTS relevancia_plantao SMALLINT CHECK (relevancia_plantao BETWEEN 1 AND 5);
ALTER TABLE app.tema ADD COLUMN IF NOT EXISTS relevancia_manual BOOLEAN NOT NULL DEFAULT false;
UPDATE app.tema t SET relevancia_plantao = v.r
  FROM (VALUES
    ('Reanimação e via aérea no trauma',5),('Trauma abdominal',5),('Abdome agudo inflamatório e obstrutivo',5),('Infecção e sepse cirúrgica',5),
    ('Controle de danos e abdome aberto',4),('Trauma de parede torácica e pleural',4),('Trauma cardíaco e de grandes vasos',4),
    ('Trauma de extremidade, pelve e vascular',4),('Neurotrauma',4),('Hérnias e parede abdominal',4),('Hemorragia digestiva e colorretal',4),
    ('Intensivismo cirúrgico',4),('Procedimentos à beira-leito',4),('Avaliação de risco perioperatório',4),('Suporte perioperatório e farmacologia',4),
    ('Interfaces, urgência vascular e isquemia visceral',3),('Cabeça e pescoço',3),('Queimaduras',3),('Urologia e geniturinário',3),
    ('Casos integradores e fechamento',3),('Imagem pelo cirurgião',3),('Segurança do paciente e qualidade',3),('Ginecologia e obstetrícia na urgência',3),
    ('Cirurgia pediátrica de urgência',3),('Endoscopia digestiva na urgência',3),('MIS e cirurgia especializada na urgência',3),
    ('Fim de vida e decisão compartilhada',2),('Auditoria, governança e sistemas',2),('Medicina baseada em evidências — ler e entender',2),
    ('Medicina baseada em evidências — julgar e aplicar',2),('Governança compartilhada e saúde do profissional',2),('Ensino, preceptoria e avaliação',1)
  ) v(modulo, r)
 WHERE t.modulo = v.modulo AND NOT t.relevancia_manual;
-- Ajustes por tema (frequencia no plantao ou gravidade acima/abaixo do modulo).
UPDATE app.tema t SET relevancia_plantao = v.r
  FROM (VALUES ('T-136',5),('T-137',5),('T-006',4),('T-048',4),('T-065',4),('T-064',3),('T-047',5),('T-094',5),('T-093',5),
               ('T-089',5),('T-140',4),('T-146',4),('T-148',4),('T-111',3),('T-079',4),('T-073',4),('T-074',4)) v(c, r)
 WHERE t.codigo = v.c AND NOT t.relevancia_manual;
UPDATE app.tema SET relevancia_plantao = 3 WHERE relevancia_plantao IS NULL;

-- A coordenacao ajusta a relevancia de um tema (1 a 5); o ajuste manual nao e sobrescrito pelo script.
CREATE OR REPLACE FUNCTION app.definir_relevancia(p_codigo TEXT, p_rel INT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  UPDATE app.tema SET relevancia_plantao = least(5, greatest(1, p_rel)), relevancia_manual = true
   WHERE replace(codigo,'-','') = replace(upper(p_codigo),'-','');
END $$;
REVOKE EXECUTE ON FUNCTION app.definir_relevancia(TEXT, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.definir_relevancia(TEXT, INT) TO api_rw;

DROP FUNCTION IF EXISTS app.fila_producao();
CREATE FUNCTION app.fila_producao()
RETURNS TABLE (posicao INT, codigo TEXT, titulo TEXT, modulo TEXT, papel TEXT, ordem SMALLINT, criterio TEXT, status TEXT,
               pecas_publicadas INT, pecas_em_revisao INT, aula_em TIMESTAMPTZ, interessados INT, taxa_avise_pct NUMERIC,
               agendados INT, libera INT, relevancia SMALLINT, importancia NUMERIC, maes TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH RECURSIVE desc_(raiz, tema_id) AS (
    SELECT r.requisito_id, r.tema_id FROM app.tema_requisito r
    UNION SELECT d.raiz, r.tema_id FROM desc_ d JOIN app.tema_requisito r ON r.requisito_id = d.tema_id),
  ativos AS (SELECT greatest(1, count(*)) AS n FROM app.ficha_aluno WHERE status = 'aprovado'),
  base AS (
    SELECT t.*,
      (SELECT count(*)::int FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status = 'publicado') AS pub,
      (SELECT count(*)::int FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status IN ('rascunho','revisao','aprovado')) AS rev,
      (SELECT min(a.data_hora) FROM app.agenda_aula a WHERE a.tema_id = t.tema_id) AS aula,
      (SELECT count(*)::int FROM app.tema_interesse i WHERE i.tema_id = t.tema_id) AS inter,
      (SELECT count(DISTINCT o.pessoa_id)::int FROM app.onda_instancia o WHERE o.tema_id = t.tema_id AND o.pessoa_id IS NOT NULL) AS agend,
      (SELECT count(DISTINCT d.tema_id)::int FROM desc_ d WHERE d.raiz = t.tema_id) AS lib,
      (SELECT string_agg(m.codigo, ' ' ORDER BY m.codigo) FROM app.tema_requisito r JOIN app.tema m ON m.tema_id = r.requisito_id
        WHERE r.tema_id = t.tema_id) AS maes_txt
      FROM app.tema t),
  calc AS (
    SELECT b.*, round(100.0 * b.inter / (SELECT n FROM ativos), 1) AS taxa,
           round(4 * b.relevancia_plantao + least(b.lib, 10) + CASE b.papel_curricular WHEN 'complementar' THEN 2 ELSE 0 END
                 - 0.3 * b.dificuldade, 1) AS imp
      FROM base b)
  SELECT (row_number() OVER (ORDER BY
            CASE WHEN c.papel_curricular = 'nuclear' THEN 1 WHEN c.inter > 0 THEN 2 ELSE 3 END,
            c.ordem_principal NULLS LAST, c.taxa DESC, c.agend DESC, c.imp DESC, c.lib DESC, c.codigo))::int,
         c.codigo, c.titulo, c.modulo, c.papel_curricular, c.ordem_principal,
         CASE WHEN c.papel_curricular = 'nuclear' THEN 'aula ' || c.ordem_principal
              WHEN c.inter > 0 THEN 'avise-me ' || c.taxa || '%' ELSE 'importância ' || c.imp END,
         CASE WHEN c.pub > 0 THEN 'publicado' WHEN c.rev > 0 THEN 'em_revisao' ELSE 'nao_iniciado' END,
         c.pub, c.rev, c.aula, c.inter, c.taxa, c.agend, c.lib, c.relevancia_plantao, c.imp, c.maes_txt
    FROM calc c
   WHERE app.eh_revisor() OR app.papel_painel() IS NOT NULL
   ORDER BY 1 $$;
REVOKE EXECUTE ON FUNCTION app.fila_producao() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.fila_producao() TO api_rw;

-- ---------- (2) interesse em pesquisa ----------
CREATE TABLE IF NOT EXISTS app.pesquisa_interesse (
  interesse_id BIGSERIAL PRIMARY KEY,
  pessoa_id   BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id     BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  ideia_num   SMALLINT NOT NULL CHECK (ideia_num BETWEEN 1 AND 10),
  ideia_texto TEXT NOT NULL CHECK (length(ideia_texto) <= 1000),
  mensagem    TEXT CHECK (length(mensagem) <= 2000),
  autoriza_contato BOOLEAN NOT NULL DEFAULT false,
  status      TEXT NOT NULL DEFAULT 'novo' CHECK (status IN ('novo','em_contato','encaminhado','em_andamento','encerrado')),
  orientador  TEXT CHECK (length(orientador) <= 200),
  nota_coordenacao TEXT CHECK (length(nota_coordenacao) <= 2000),
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (pessoa_id, tema_id, ideia_num));

CREATE OR REPLACE FUNCTION app.registrar_interesse_pesquisa(p JSONB) RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_t BIGINT; v BIGINT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT tema_id INTO v_t FROM app.tema WHERE replace(codigo,'-','') = replace(upper(p->>'tema'),'-','');
  IF v_t IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  IF coalesce((p->>'cancelar')::boolean, false) THEN
    DELETE FROM app.pesquisa_interesse WHERE pessoa_id = app.pessoa_atual() AND tema_id = v_t AND ideia_num = (p->>'ideia')::smallint AND status = 'novo';
    RETURN NULL;
  END IF;
  INSERT INTO app.pesquisa_interesse (pessoa_id, tema_id, ideia_num, ideia_texto, mensagem, autoriza_contato)
  VALUES (app.pessoa_atual(), v_t, (p->>'ideia')::smallint, left(p->>'texto', 1000), nullif(left(p->>'mensagem', 2000), ''),
          coalesce((p->>'autoriza')::boolean, false))
  ON CONFLICT (pessoa_id, tema_id, ideia_num) DO UPDATE SET mensagem = EXCLUDED.mensagem, autoriza_contato = EXCLUDED.autoriza_contato,
     ideia_texto = EXCLUDED.ideia_texto, atualizado_em = now()
  RETURNING interesse_id INTO v;
  -- avisa a coordenacao (curadores e admin) por e-mail
  INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT d.pessoa_id, 'email', pe.email_primario::text, 'Interesse em pesquisa: ' || (SELECT codigo FROM app.tema WHERE tema_id = v_t),
         (SELECT nome_completo FROM app.pessoa WHERE pessoa_id = app.pessoa_atual()) || ' quer seguir a ideia ' || (p->>'ideia') || ': '
           || left(p->>'texto', 300) || coalesce(E'\n\nMensagem: ' || nullif(p->>'mensagem', ''), ''),
         jsonb_build_object('caminho', '/curador/pesquisa', 'rotulo_link', 'Abrir a lista de interesses')
    FROM app.designacao d JOIN app.pessoa pe ON pe.pessoa_id = d.pessoa_id
   WHERE d.papel IN ('admin','curador') AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date);
  RETURN v;
END $$;

CREATE OR REPLACE FUNCTION app.meus_interesses_pesquisa(p_tema TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('ideia', i.ideia_num, 'status', i.status, 'orientador', i.orientador, 'mensagem', i.mensagem,
           'autoriza', i.autoriza_contato) ORDER BY i.ideia_num), '[]'::jsonb)
    FROM app.pesquisa_interesse i JOIN app.tema t ON t.tema_id = i.tema_id
   WHERE i.pessoa_id = app.pessoa_atual() AND replace(t.codigo,'-','') = replace(upper(p_tema),'-','') $$;

CREATE OR REPLACE FUNCTION app.interesses_pesquisa() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', i.interesse_id, 'tema', t.codigo, 'titulo_tema', t.titulo, 'ideia', i.ideia_num,
           'texto', i.ideia_texto, 'mensagem', i.mensagem, 'autoriza', i.autoriza_contato, 'status', i.status, 'orientador', i.orientador,
           'nota', i.nota_coordenacao, 'criado_em', i.criado_em, 'nome', p.nome_completo,
           'email', CASE WHEN i.autoriza_contato THEN p.email_primario::text END,
           'ano', (SELECT ano FROM app.perfil_aluno(p.pessoa_id)), 'especialidade', (SELECT especialidade FROM app.perfil_aluno(p.pessoa_id)))
           ORDER BY (i.status = 'encerrado'), i.criado_em DESC), '[]'::jsonb)
    FROM app.pesquisa_interesse i JOIN app.tema t ON t.tema_id = i.tema_id JOIN app.pessoa p ON p.pessoa_id = i.pessoa_id
   WHERE app.eh_revisor() $$;

CREATE OR REPLACE FUNCTION app.atualizar_interesse_pesquisa(p_id BIGINT, p JSONB) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  UPDATE app.pesquisa_interesse SET status = coalesce(p->>'status', status), orientador = left(coalesce(p->>'orientador', orientador), 200),
         nota_coordenacao = left(coalesce(p->>'nota', nota_coordenacao), 2000), atualizado_em = now()
   WHERE interesse_id = p_id;
END $$;

-- ---------- (3) repeticao espacada ----------
ALTER TABLE app.flashcard_revisao ADD COLUMN IF NOT EXISTS repeticoes INT NOT NULL DEFAULT 0;
ALTER TABLE app.flashcard_revisao ADD COLUMN IF NOT EXISTS intervalo_dias NUMERIC NOT NULL DEFAULT 0;
ALTER TABLE app.flashcard_revisao ADD COLUMN IF NOT EXISTS facilidade NUMERIC NOT NULL DEFAULT 2.5;
ALTER TABLE app.flashcard_revisao ADD COLUMN IF NOT EXISTS proxima_em TIMESTAMPTZ;

-- Acertou: 1 dia, depois 3, depois intervalo x facilidade (a facilidade sobe um pouco). Errou: volta em 10 minutos e recomeca.
CREATE OR REPLACE FUNCTION app.revisar_card(p_chave TEXT, p_acertou BOOLEAN) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE r app.flashcard_revisao; v_int NUMERIC; v_fac NUMERIC; v_rep INT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RETURN; END IF;
  SELECT * INTO r FROM app.flashcard_revisao WHERE pessoa_id = app.pessoa_atual() AND chave = left(p_chave, 80);
  v_rep := coalesce(r.repeticoes, 0); v_int := coalesce(r.intervalo_dias, 0); v_fac := coalesce(r.facilidade, 2.5);
  IF p_acertou THEN
    v_rep := v_rep + 1;
    v_int := CASE WHEN v_rep = 1 THEN 1 WHEN v_rep = 2 THEN 3 ELSE least(180, round(v_int * v_fac, 1)) END;
    v_fac := least(2.8, v_fac + 0.05);
  ELSE
    v_rep := 0; v_int := 0; v_fac := greatest(1.3, v_fac - 0.2);
  END IF;
  INSERT INTO app.flashcard_revisao (pessoa_id, chave, acertos, erros, repeticoes, intervalo_dias, facilidade, proxima_em, ultima)
  VALUES (app.pessoa_atual(), left(p_chave, 80), CASE WHEN p_acertou THEN 1 ELSE 0 END, CASE WHEN p_acertou THEN 0 ELSE 1 END,
          v_rep, v_int, v_fac, CASE WHEN p_acertou THEN now() + make_interval(secs => (v_int * 86400)::int) ELSE now() + interval '10 minutes' END, now())
  ON CONFLICT (pessoa_id, chave) DO UPDATE SET acertos = app.flashcard_revisao.acertos + EXCLUDED.acertos,
     erros = app.flashcard_revisao.erros + EXCLUDED.erros, repeticoes = EXCLUDED.repeticoes, intervalo_dias = EXCLUDED.intervalo_dias,
     facilidade = EXCLUDED.facilidade, proxima_em = EXCLUDED.proxima_em, ultima = now();
END $$;

-- Deck: acrescenta o modo "devidos" (revisao do dia): cards vencidos primeiro, depois cards nunca vistos.
CREATE OR REPLACE FUNCTION app.montar_deck(p JSONB) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH eu AS (SELECT app.pessoa_atual() AS id),
  temas AS (SELECT t.tema_id, t.codigo FROM app.tema t, eu
             WHERE (jsonb_array_length(coalesce(p->'temas', '[]')) = 0 OR replace(t.codigo,'-','') IN (SELECT replace(upper(x),'-','') FROM jsonb_array_elements_text(p->'temas') x))),
  fontes AS (SELECT CASE WHEN jsonb_typeof(p->'fontes') = 'array' AND jsonb_array_length(p->'fontes') > 0
                         THEN array(SELECT jsonb_array_elements_text(p->'fontes')) ELSE ARRAY['oficiais','meus','colegas'] END AS f),
  cards AS (
    SELECT 'oficial:' || t.codigo || ':' || o.n AS chave, t.codigo AS tema, o.frente, o.verso, 'oficial' AS origem, NULL::text AS autor
      FROM temas t, eu, fontes, LATERAL app.flashcards_oficiais(t.tema_id) o
     WHERE 'oficiais' = ANY (fontes.f) AND app.flashcards_liberados(eu.id, t.tema_id)
    UNION ALL
    SELECT 'aluno:' || f.flashcard_id, t.codigo, f.frente, f.verso, CASE WHEN f.autor_id = eu.id THEN 'meu' ELSE 'colega' END, app.assinatura_de(f.autor_id)
      FROM app.flashcard_aluno f JOIN temas t ON t.tema_id = f.tema_id, eu, fontes
     WHERE NOT f.oculto AND ((f.autor_id = eu.id AND 'meus' = ANY (fontes.f))
            OR (f.autor_id <> eu.id AND f.compartilhado AND 'colegas' = ANY (fontes.f) AND app.flashcards_liberados(eu.id, t.tema_id)))),
  com_hist AS (SELECT c.*, coalesce(r.acertos, 0) AS acertos, coalesce(r.erros, 0) AS erros, r.proxima_em, coalesce(r.intervalo_dias, 0) AS intervalo_dias
                 FROM cards c CROSS JOIN eu LEFT JOIN app.flashcard_revisao r ON r.pessoa_id = eu.id AND r.chave = c.chave)
  SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) FROM (
    SELECT * FROM com_hist
     WHERE (NOT coalesce((p->>'so_dificeis')::boolean, false) OR erros > acertos)
       AND (coalesce(p->>'modo', '') <> 'devidos' OR proxima_em IS NULL OR proxima_em <= now())
     ORDER BY CASE WHEN p->>'modo' = 'devidos' THEN (proxima_em IS NULL) END,
              CASE WHEN p->>'modo' = 'devidos' THEN proxima_em END,
              CASE WHEN coalesce((p->>'so_dificeis')::boolean, false) THEN erros - acertos END DESC NULLS LAST, random()
     LIMIT greatest(1, least(200, coalesce((p->>'quantidade')::int, 20)))) x $$;

CREATE OR REPLACE FUNCTION app.flashcards_devidos() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH d AS (SELECT jsonb_array_elements(app.montar_deck('{"modo":"devidos","quantidade":200}'::jsonb)) AS c)
  SELECT jsonb_build_object('vencidos', count(*) FILTER (WHERE c->>'proxima_em' IS NOT NULL),
                            'novos', count(*) FILTER (WHERE c->>'proxima_em' IS NULL))
    FROM d WHERE app.pessoa_atual() IS NOT NULL $$;

-- ---------- (4) certificado por modulo ----------
CREATE OR REPLACE FUNCTION app.meus_modulos() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('modulo', m.modulo, 'total', m.total, 'concluidos', m.conc,
           'completo', m.conc = m.total,
           'certificado', (SELECT c.codigo FROM app.certificado c WHERE c.pessoa_id = app.pessoa_atual() AND c.dados->>'modulo' = m.modulo
                            ORDER BY c.emitido_em DESC LIMIT 1)) ORDER BY (m.conc = m.total) DESC, m.conc DESC, m.modulo), '[]'::jsonb)
    FROM (SELECT t.modulo, count(*) AS total, count(*) FILTER (WHERE app.tema_concluido(app.pessoa_atual(), t.tema_id)) AS conc
            FROM app.tema t WHERE t.modulo IS NOT NULL GROUP BY t.modulo) m
   WHERE app.pessoa_atual() IS NOT NULL $$;

CREATE OR REPLACE FUNCTION app.emitir_certificado_modulo(p_modulo TEXT) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_p BIGINT := app.pessoa_atual(); v_cod TEXT; v JSONB; n_total INT; n_conc INT;
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT count(*), count(*) FILTER (WHERE app.tema_concluido(v_p, tema_id)) INTO n_total, n_conc FROM app.tema WHERE modulo = p_modulo;
  IF n_total = 0 THEN RAISE EXCEPTION 'modulo_nao_encontrado'; END IF;
  IF n_conc < n_total THEN RAISE EXCEPTION 'modulo_incompleto'; END IF;
  SELECT c.codigo INTO v_cod FROM app.certificado c WHERE c.pessoa_id = v_p AND c.dados->>'modulo' = p_modulo LIMIT 1;
  IF v_cod IS NOT NULL THEN RETURN jsonb_build_object('codigo', v_cod); END IF;
  v := jsonb_build_object(
    'modulo', p_modulo,
    'nome', (SELECT nome_completo FROM app.pessoa WHERE pessoa_id = v_p),
    'perfil', (SELECT jsonb_build_object('ano', ano, 'especialidade', especialidade) FROM app.perfil_aluno(v_p)),
    'temas_concluidos', n_conc,
    'lista_temas', (SELECT jsonb_agg(codigo || ' — ' || titulo ORDER BY codigo) FROM app.tema WHERE modulo = p_modulo),
    'horas', n_conc * app.config('horas_por_tema')::int,
    'aulas_realizadas', NULL, 'aulas_presentes', NULL,
    'presenca_pct', (SELECT round(100.0 * count(*) FILTER (WHERE app.presente(pr)) / nullif(count(*), 0), 0)
                       FROM app.presenca pr JOIN app.tema t ON t.tema_id = pr.tema_id WHERE pr.pessoa_id = v_p AND t.modulo = p_modulo));
  v_cod := upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 4) || '-' || substr(encode(gen_random_bytes(8), 'hex'), 1, 4) || '-' || substr(encode(gen_random_bytes(8), 'hex'), 1, 4));
  INSERT INTO app.certificado (codigo, pessoa_id, dados) VALUES (v_cod, v_p, v);
  RETURN v || jsonb_build_object('codigo', v_cod, 'emitido_em', now());
END $$;

-- ---------- (5) coleta de dados ----------
CREATE TABLE IF NOT EXISTS app.leitura_tempo (
  leitura_id BIGSERIAL PRIMARY KEY,
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id   BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  tipo      TEXT NOT NULL,
  segundos  INT NOT NULL CHECK (segundos BETWEEN 1 AND 3600),
  em        TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS ix_leitura_tempo ON app.leitura_tempo (pessoa_id, tema_id, tipo);

CREATE OR REPLACE FUNCTION app.registrar_tempo_leitura(p_tema TEXT, p_tipo TEXT, p_segundos INT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.leitura_tempo (pessoa_id, tema_id, tipo, segundos)
  SELECT app.pessoa_atual(), t.tema_id, left(p_tipo, 40), least(3600, greatest(1, p_segundos))
    FROM app.tema t WHERE replace(t.codigo,'-','') = replace(upper(p_tema),'-','') AND app.pessoa_atual() IS NOT NULL AND p_segundos >= 3 $$;

CREATE TABLE IF NOT EXISTS app.confianca_teste (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  onda_id   BIGINT NOT NULL REFERENCES app.onda_instancia(onda_id) ON DELETE CASCADE,
  confianca_pct SMALLINT NOT NULL CHECK (confianca_pct BETWEEN 0 AND 100),
  em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (pessoa_id, onda_id));

CREATE OR REPLACE FUNCTION app.confianca_da_onda(p_onda BIGINT) RETURNS SMALLINT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT confianca_pct FROM app.confianca_teste WHERE pessoa_id = app.pessoa_atual() AND onda_id = p_onda $$;
-- Uma vez por teste, antes de abrir as questoes (nao muda depois).
CREATE OR REPLACE FUNCTION app.registrar_confianca(p_onda BIGINT, p_pct INT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.confianca_teste (pessoa_id, onda_id, confianca_pct)
  SELECT app.pessoa_atual(), p_onda, least(100, greatest(0, p_pct))
   WHERE app.pessoa_atual() IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM app.tentativa t WHERE t.onda_id = p_onda AND t.pessoa_id = app.pessoa_atual() AND t.submetida_em IS NOT NULL)
  ON CONFLICT DO NOTHING $$;

CREATE TABLE IF NOT EXISTS app.aplicabilidade (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id   BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  usou      SMALLINT CHECK (usou BETWEEN 0 AND 4),        -- 0 nunca, 1 1 vez, 2 2-3 vezes, 3 4-10 vezes, 4 mais de 10
  mudou_conduta BOOLEAN,
  confianca SMALLINT CHECK (confianca BETWEEN 1 AND 5),   -- seguranca para conduzir o tema no plantao hoje
  exemplo   TEXT CHECK (length(exemplo) <= 1500),
  barreira  TEXT CHECK (length(barreira) <= 1500),
  dispensado BOOLEAN NOT NULL DEFAULT false,
  em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (pessoa_id, tema_id));

-- Temas concluidos ha 30 dias ou mais sem a avaliacao de aplicabilidade (some depois de 90 dias).
CREATE OR REPLACE FUNCTION app.aplicabilidade_pendente() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('codigo', x.codigo, 'titulo', x.titulo, 'concluido_em', x.em) ORDER BY x.em), '[]'::jsonb)
    FROM (SELECT t.codigo, t.titulo, min(tt.submetida_em) AS em
            FROM app.tentativa tt JOIN app.onda_instancia o ON o.onda_id = tt.onda_id JOIN app.tema t ON t.tema_id = o.tema_id
           WHERE tt.pessoa_id = app.pessoa_atual() AND o.teste_num = 3 AND tt.submetida_em IS NOT NULL
             AND NOT EXISTS (SELECT 1 FROM app.aplicabilidade a WHERE a.pessoa_id = tt.pessoa_id AND a.tema_id = t.tema_id)
           GROUP BY t.codigo, t.titulo
          HAVING min(tt.submetida_em) <= now() - interval '30 days' AND min(tt.submetida_em) > now() - interval '120 days') x $$;

CREATE OR REPLACE FUNCTION app.salvar_aplicabilidade(p JSONB) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_t BIGINT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT tema_id INTO v_t FROM app.tema WHERE replace(codigo,'-','') = replace(upper(p->>'tema'),'-','');
  IF v_t IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  INSERT INTO app.aplicabilidade (pessoa_id, tema_id, usou, mudou_conduta, confianca, exemplo, barreira, dispensado)
  VALUES (app.pessoa_atual(), v_t, (p->>'usou')::smallint, (p->>'mudou_conduta')::boolean, (p->>'confianca')::smallint,
          nullif(left(p->>'exemplo', 1500), ''), nullif(left(p->>'barreira', 1500), ''), coalesce((p->>'dispensado')::boolean, false))
  ON CONFLICT (pessoa_id, tema_id) DO UPDATE SET usou = EXCLUDED.usou, mudou_conduta = EXCLUDED.mudou_conduta, confianca = EXCLUDED.confianca,
     exemplo = EXCLUDED.exemplo, barreira = EXCLUDED.barreira, dispensado = EXCLUDED.dispensado, em = now();
END $$;

-- Painel: calibracao (confianca declarada x nota), tempo de leitura e aplicabilidade.
CREATE OR REPLACE FUNCTION app.painel_coleta()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, tema TEXT, teste SMALLINT, confianca_pct SMALLINT, nota_pct NUMERIC,
               calibracao NUMERIC, leitura_min NUMERIC, usou SMALLINT, mudou_conduta BOOLEAN, confianca_plantao SMALLINT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(c.pessoa_id), pf.ano, pf.especialidade, t.codigo, o.teste_num, c.confianca_pct,
         (SELECT nt.pct FROM app.nota_teste nt WHERE nt.pessoa_id = c.pessoa_id AND nt.tema_id = o.tema_id AND nt.teste_num = o.teste_num
           ORDER BY nt.submetida_em DESC LIMIT 1),
         c.confianca_pct - (SELECT nt.pct FROM app.nota_teste nt WHERE nt.pessoa_id = c.pessoa_id AND nt.tema_id = o.tema_id AND nt.teste_num = o.teste_num
           ORDER BY nt.submetida_em DESC LIMIT 1),
         (SELECT round(sum(l.segundos) / 60.0, 1) FROM app.leitura_tempo l WHERE l.pessoa_id = c.pessoa_id AND l.tema_id = o.tema_id),
         a.usou, a.mudou_conduta, a.confianca
    FROM app.confianca_teste c JOIN app.onda_instancia o ON o.onda_id = c.onda_id JOIN app.tema t ON t.tema_id = o.tema_id
    LEFT JOIN app.aplicabilidade a ON a.pessoa_id = c.pessoa_id AND a.tema_id = o.tema_id,
    LATERAL app.perfil_aluno(c.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY 1, 4, 5 $$;
CREATE OR REPLACE FUNCTION app.painel_leitura()
RETURNS TABLE (aluno TEXT, tema TEXT, peca TEXT, minutos NUMERIC, sessoes INT, ultima TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(l.pessoa_id), t.codigo, l.tipo, round(sum(l.segundos) / 60.0, 1), count(*)::int, max(l.em)
    FROM app.leitura_tempo l JOIN app.tema t ON t.tema_id = l.tema_id
   WHERE app.papel_painel() IS NOT NULL GROUP BY l.pessoa_id, t.codigo, l.tipo ORDER BY 1, 2, 3 $$;

REVOKE EXECUTE ON FUNCTION app.registrar_interesse_pesquisa(JSONB), app.meus_interesses_pesquisa(TEXT), app.interesses_pesquisa(),
  app.atualizar_interesse_pesquisa(BIGINT, JSONB), app.flashcards_devidos(), app.meus_modulos(), app.emitir_certificado_modulo(TEXT),
  app.registrar_tempo_leitura(TEXT, TEXT, INT), app.confianca_da_onda(BIGINT), app.registrar_confianca(BIGINT, INT),
  app.aplicabilidade_pendente(), app.salvar_aplicabilidade(JSONB), app.painel_coleta(), app.painel_leitura() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.registrar_interesse_pesquisa(JSONB), app.meus_interesses_pesquisa(TEXT), app.interesses_pesquisa(),
  app.atualizar_interesse_pesquisa(BIGINT, JSONB), app.flashcards_devidos(), app.meus_modulos(), app.emitir_certificado_modulo(TEXT),
  app.registrar_tempo_leitura(TEXT, TEXT, INT), app.confianca_da_onda(BIGINT), app.registrar_confianca(BIGINT, INT),
  app.aplicabilidade_pendente(), app.salvar_aplicabilidade(JSONB), app.painel_coleta(), app.painel_leitura(),
  app.revisar_card(TEXT, BOOLEAN), app.montar_deck(JSONB) TO api_rw;

COMMIT;
\echo 'fila 1-150, interesse em pesquisa, repeticao espacada, certificado por modulo, tempo de leitura, confianca e aplicabilidade: pronto'
