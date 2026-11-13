-- 66_mural_presenca_v1.0.sql
-- (1) Link fixo do Google Meet e agenda (.ics) com link pessoal de assinatura.
-- (2) Mural da coordenacao: avisos, questionarios (texto, escolha unica, multipla, escala) e documentos (PDF etc.).
-- (3) Presenca nas aulas ao vivo:
--     - codigo/link de presenca gerado pela coordenacao durante a aula ("resgatar credito" pelo aluno);
--     - relatorio de presenca do Google Meet (entrada/saida) enviado pela coordenacao: presenca se o tempo
--       somado for >= 50% da duracao da aula, mesmo sem o codigo.
-- (4) Certificado com carga horaria, temas concluidos e % de presenca, com codigo de verificacao publico.
-- (5) Preceptor (papel "docente"): residentes vinculados, pendencias e evolucao (sem dados de pesquisa).
-- (6) Analise das questoes (taxa real, discriminacao, distrator mais escolhido e alertas).
-- (7) Resumo semanal por e-mail (segunda-feira, 7h) e e-mail de aniversario (8h) com o aproveitamento no curso.
-- Pre-requisito: 45, 48 (agenda, quando houver), 55, 58, 60, 62, 64, 65. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) Meet e agenda ----------
INSERT INTO app.config_curso VALUES
  ('link_meet', 'https://meet.google.com/igg-iuup-gac'),
  ('duracao_aula_min', '90'),
  ('horas_por_tema', '4'),
  ('presenca_minima_pct', '50')
ON CONFLICT (chave) DO NOTHING;
CREATE TABLE IF NOT EXISTS app.agenda_aula (
  ciclo_id BIGINT NOT NULL, ordem SMALLINT NOT NULL, data_hora TIMESTAMPTZ NOT NULL,
  tema_id BIGINT REFERENCES app.tema(tema_id) ON DELETE SET NULL, link_meet TEXT, PRIMARY KEY (ciclo_id, ordem));
UPDATE app.agenda_aula SET link_meet = (SELECT valor FROM app.config_curso WHERE chave = 'link_meet') WHERE link_meet IS NULL;

CREATE OR REPLACE FUNCTION app.config(p TEXT) RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$ SELECT valor FROM app.config_curso WHERE chave = p $$;
GRANT EXECUTE ON FUNCTION app.config(TEXT) TO api_rw;

-- Data e hora da aula (D0) de um tema para a pessoa (principal: agenda do grupo; opcional: D0 escolhido).
CREATE OR REPLACE FUNCTION app.aula_do_tema(p_pessoa BIGINT, p_tema BIGINT) RETURNS TIMESTAMPTZ
LANGUAGE sql STABLE AS $$
  SELECT coalesce((SELECT a.data_hora FROM app.agenda_aula a WHERE a.tema_id = p_tema LIMIT 1), app.d0_da_pessoa(p_pessoa, p_tema)) $$;

-- Token pessoal para assinar a agenda (.ics) sem login.
CREATE TABLE IF NOT EXISTS app.agenda_token (
  pessoa_id BIGINT PRIMARY KEY REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  token     TEXT NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(18), 'hex'),
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now());

CREATE OR REPLACE FUNCTION app.meu_token_agenda() RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v TEXT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  INSERT INTO app.agenda_token (pessoa_id) VALUES (app.pessoa_atual()) ON CONFLICT DO NOTHING;
  SELECT token INTO v FROM app.agenda_token WHERE pessoa_id = app.pessoa_atual();
  RETURN v;
END $$;

-- Eventos da agenda de uma pessoa (pelo token): aulas do grupo e D0 dos opcionais agendados.
CREATE OR REPLACE FUNCTION app.agenda_por_token(p_token TEXT)
RETURNS TABLE (uid TEXT, inicio TIMESTAMPTZ, titulo TEXT, descricao TEXT, link TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH p AS (SELECT pessoa_id FROM app.agenda_token WHERE token = p_token AND length(p_token) >= 30)
  SELECT 'aula-' || t.codigo || '@programa-cut', a.data_hora, t.codigo || ' — ' || t.titulo,
         'Aula do Programa de Cirurgia de Urgência e Trauma (tema principal).', coalesce(a.link_meet, app.config('link_meet'))
    FROM app.agenda_aula a JOIN app.tema t ON t.tema_id = a.tema_id, p
  UNION ALL
  SELECT 'd0-' || t.codigo || '-' || p.pessoa_id || '@programa-cut', o.data_abertura, t.codigo || ' — ' || t.titulo || ' (minha data)',
         'Data que você escolheu para estudar este tema opcional (D0).', NULL
    FROM app.onda_instancia o JOIN app.tema t ON t.tema_id = o.tema_id, p
   WHERE o.pessoa_id = p.pessoa_id AND o.teste_num = 3 $$;
REVOKE EXECUTE ON FUNCTION app.meu_token_agenda(), app.agenda_por_token(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.meu_token_agenda(), app.agenda_por_token(TEXT) TO api_rw;

-- ---------- (2) mural ----------
CREATE TABLE IF NOT EXISTS app.mural (
  mural_id     BIGSERIAL PRIMARY KEY,
  tipo         TEXT NOT NULL CHECK (tipo IN ('aviso','questionario','documento')),
  titulo       TEXT NOT NULL CHECK (length(titulo) BETWEEN 3 AND 200),
  corpo        TEXT CHECK (length(corpo) <= 20000),
  publico      TEXT NOT NULL DEFAULT 'alunos' CHECK (publico IN ('alunos','todos','revisores')),
  fixado       BOOLEAN NOT NULL DEFAULT false,
  publicado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  expira_em    TIMESTAMPTZ,
  autor_id     BIGINT REFERENCES app.pessoa(pessoa_id),
  arquivo      BYTEA CHECK (arquivo IS NULL OR length(arquivo) <= 10485760),
  arquivo_nome TEXT,
  arquivo_tipo TEXT,
  arquivado    BOOLEAN NOT NULL DEFAULT false);
CREATE TABLE IF NOT EXISTS app.mural_pergunta (
  mural_id    BIGINT NOT NULL REFERENCES app.mural(mural_id) ON DELETE CASCADE,
  ordem       SMALLINT NOT NULL,
  texto       TEXT NOT NULL CHECK (length(texto) BETWEEN 2 AND 500),
  tipo        TEXT NOT NULL CHECK (tipo IN ('texto','unica','multipla','escala')),
  opcoes      TEXT[],
  obrigatoria BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY (mural_id, ordem));
CREATE TABLE IF NOT EXISTS app.mural_resposta (
  mural_id  BIGINT NOT NULL REFERENCES app.mural(mural_id) ON DELETE CASCADE,
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  respostas JSONB NOT NULL,
  em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (mural_id, pessoa_id));
CREATE TABLE IF NOT EXISTS app.mural_leitura (
  mural_id  BIGINT NOT NULL REFERENCES app.mural(mural_id) ON DELETE CASCADE,
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  lido_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (mural_id, pessoa_id));

CREATE OR REPLACE FUNCTION app.eh_aluno_ativo(p BIGINT) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
  SELECT EXISTS (SELECT 1 FROM app.ficha_aluno f WHERE f.pessoa_id = p AND f.status = 'aprovado') $$;

-- Mural da pessoa logada.
CREATE OR REPLACE FUNCTION app.mural_lista() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
      'id', m.mural_id, 'tipo', m.tipo, 'titulo', m.titulo, 'corpo', m.corpo, 'fixado', m.fixado, 'publico', m.publico,
      'publicado_em', m.publicado_em, 'expira_em', m.expira_em, 'arquivo_nome', m.arquivo_nome,
      'lido', EXISTS (SELECT 1 FROM app.mural_leitura l WHERE l.mural_id = m.mural_id AND l.pessoa_id = app.pessoa_atual()),
      'respondido', EXISTS (SELECT 1 FROM app.mural_resposta r WHERE r.mural_id = m.mural_id AND r.pessoa_id = app.pessoa_atual()),
      'minhas_respostas', (SELECT r.respostas FROM app.mural_resposta r WHERE r.mural_id = m.mural_id AND r.pessoa_id = app.pessoa_atual()),
      'n_respostas', CASE WHEN app.eh_revisor() THEN (SELECT count(*) FROM app.mural_resposta r WHERE r.mural_id = m.mural_id) END,
      'perguntas', (SELECT jsonb_agg(jsonb_build_object('ordem', q.ordem, 'texto', q.texto, 'tipo', q.tipo, 'opcoes', q.opcoes,
                                                        'obrigatoria', q.obrigatoria) ORDER BY q.ordem)
                      FROM app.mural_pergunta q WHERE q.mural_id = m.mural_id))
      ORDER BY m.fixado DESC, m.publicado_em DESC), '[]'::jsonb)
    FROM app.mural m
   WHERE app.pessoa_atual() IS NOT NULL AND NOT m.arquivado
     AND (m.expira_em IS NULL OR m.expira_em > now() OR app.eh_revisor())
     AND (app.eh_revisor() OR m.publico IN ('alunos','todos')) $$;

-- Publicar ou editar (revisores). p: {id?, tipo, titulo, corpo, publico, fixado, expira_em, perguntas:[{texto,tipo,opcoes,obrigatoria}], avisar_email}
CREATE OR REPLACE FUNCTION app.mural_salvar(p JSONB) RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v BIGINT := (p->>'id')::bigint; q JSONB; i INT := 0;
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  IF v IS NULL THEN
    INSERT INTO app.mural (tipo, titulo, corpo, publico, fixado, expira_em, autor_id)
    VALUES (p->>'tipo', p->>'titulo', p->>'corpo', coalesce(p->>'publico','alunos'), coalesce((p->>'fixado')::boolean, false),
            nullif(p->>'expira_em','')::timestamptz, app.pessoa_atual()) RETURNING mural_id INTO v;
  ELSE
    UPDATE app.mural SET tipo = p->>'tipo', titulo = p->>'titulo', corpo = p->>'corpo', publico = coalesce(p->>'publico','alunos'),
           fixado = coalesce((p->>'fixado')::boolean, false), expira_em = nullif(p->>'expira_em','')::timestamptz,
           arquivado = coalesce((p->>'arquivado')::boolean, false)
     WHERE mural_id = v;
  END IF;
  IF p->>'tipo' = 'questionario' AND NOT EXISTS (SELECT 1 FROM app.mural_resposta WHERE mural_id = v) THEN
    DELETE FROM app.mural_pergunta WHERE mural_id = v;
    FOR q IN SELECT * FROM jsonb_array_elements(coalesce(p->'perguntas', '[]'::jsonb)) LOOP
      i := i + 1;
      INSERT INTO app.mural_pergunta (mural_id, ordem, texto, tipo, opcoes, obrigatoria)
      VALUES (v, i, q->>'texto', q->>'tipo',
              CASE WHEN q ? 'opcoes' THEN ARRAY(SELECT jsonb_array_elements_text(q->'opcoes')) END,
              coalesce((q->>'obrigatoria')::boolean, false));
    END LOOP;
  END IF;
  IF coalesce((p->>'avisar_email')::boolean, false) AND (p->>'id') IS NULL THEN
    INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
    SELECT c.pessoa_id, 'email', coalesce(c.email_aviso, pe.email_primario::text),
           'Novo no mural do curso: ' || left(p->>'titulo', 120),
           left(coalesce(p->>'corpo', ''), 1500) || CASE WHEN p->>'tipo' = 'questionario' THEN E'\n\nHá um questionário para responder no aplicativo.' ELSE '' END,
           jsonb_build_object('caminho', '/aluno/mural', 'rotulo_link', 'Abrir o mural',
                              'rodape', 'Você recebe este aviso porque autorizou e-mails do Programa de Cirurgia de Urgência e Trauma.')
      FROM app.contato_aluno c JOIN app.pessoa pe ON pe.pessoa_id = c.pessoa_id
     WHERE c.aceita_email AND app.eh_aluno_ativo(c.pessoa_id);
  END IF;
  RETURN v;
END $$;

CREATE OR REPLACE FUNCTION app.mural_arquivo(p_id BIGINT, p_nome TEXT, p_tipo TEXT, p_dados BYTEA) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  UPDATE app.mural SET arquivo = p_dados, arquivo_nome = left(p_nome, 200), arquivo_tipo = left(p_tipo, 100) WHERE mural_id = p_id;
END $$;

CREATE OR REPLACE FUNCTION app.mural_baixar(p_id BIGINT, OUT nome TEXT, OUT tipo TEXT, OUT dados BYTEA)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT m.arquivo_nome, m.arquivo_tipo, m.arquivo FROM app.mural m
   WHERE m.mural_id = p_id AND NOT m.arquivado AND app.pessoa_atual() IS NOT NULL
     AND (app.eh_revisor() OR m.publico IN ('alunos','todos')) $$;

CREATE OR REPLACE FUNCTION app.mural_ler(p_id BIGINT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.mural_leitura (mural_id, pessoa_id) SELECT p_id, app.pessoa_atual() WHERE app.pessoa_atual() IS NOT NULL
  ON CONFLICT DO NOTHING $$;

CREATE OR REPLACE FUNCTION app.mural_responder(p_id BIGINT, p_respostas JSONB) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE q RECORD; r JSONB;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  IF NOT EXISTS (SELECT 1 FROM app.mural WHERE mural_id = p_id AND tipo = 'questionario' AND NOT arquivado
                  AND (expira_em IS NULL OR expira_em > now())) THEN RAISE EXCEPTION 'questionario_fechado'; END IF;
  FOR q IN SELECT * FROM app.mural_pergunta WHERE mural_id = p_id LOOP
    r := p_respostas -> q.ordem::text;
    IF q.obrigatoria AND (r IS NULL OR r = 'null'::jsonb OR r = '""'::jsonb OR r = '[]'::jsonb) THEN RAISE EXCEPTION 'pergunta:%', q.ordem; END IF;
  END LOOP;
  IF length(p_respostas::text) > 20000 THEN RAISE EXCEPTION 'respostas_grandes'; END IF;
  INSERT INTO app.mural_resposta (mural_id, pessoa_id, respostas) VALUES (p_id, app.pessoa_atual(), p_respostas)
  ON CONFLICT (mural_id, pessoa_id) DO UPDATE SET respostas = EXCLUDED.respostas, em = now();
  PERFORM app.mural_ler(p_id);
END $$;

-- Respostas de um questionario (revisores), com perfil do aluno.
CREATE OR REPLACE FUNCTION app.mural_respostas(p_id BIGINT)
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, respostas JSONB, em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT pe.nome_completo, pf.ano, pf.especialidade, pf.turma, r.respostas, r.em
    FROM app.mural_resposta r JOIN app.pessoa pe ON pe.pessoa_id = r.pessoa_id, LATERAL app.perfil_aluno(r.pessoa_id) pf
   WHERE r.mural_id = p_id AND app.eh_revisor() ORDER BY r.em $$;

REVOKE EXECUTE ON FUNCTION app.mural_lista(), app.mural_salvar(JSONB), app.mural_arquivo(BIGINT, TEXT, TEXT, BYTEA), app.mural_baixar(BIGINT),
  app.mural_ler(BIGINT), app.mural_responder(BIGINT, JSONB), app.mural_respostas(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.mural_lista(), app.mural_salvar(JSONB), app.mural_arquivo(BIGINT, TEXT, TEXT, BYTEA), app.mural_baixar(BIGINT),
  app.mural_ler(BIGINT), app.mural_responder(BIGINT, JSONB), app.mural_respostas(BIGINT) TO api_rw;

-- ---------- (3) presenca ----------
CREATE TABLE IF NOT EXISTS app.codigo_presenca (
  codigo     TEXT PRIMARY KEY CHECK (codigo ~ '^[A-Z0-9]{6}$'),
  tema_id    BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  aula_em    TIMESTAMPTZ NOT NULL,
  valido_ate TIMESTAMPTZ NOT NULL,
  criado_por BIGINT REFERENCES app.pessoa(pessoa_id),
  criado_em  TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS app.presenca (
  pessoa_id  BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id    BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  aula_em    TIMESTAMPTZ NOT NULL,
  por_codigo BOOLEAN NOT NULL DEFAULT false,
  codigo_em  TIMESTAMPTZ,
  minutos_meet NUMERIC(6,1),
  entrada_meet TIMESTAMPTZ,
  saida_meet   TIMESTAMPTZ,
  manual     BOOLEAN NOT NULL DEFAULT false,
  atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (pessoa_id, tema_id));
-- Linhas do relatorio do Meet que nao bateram com nenhum aluno (para conferencia manual).
CREATE TABLE IF NOT EXISTS app.presenca_nao_identificada (
  tema_id BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  nome TEXT, email TEXT, minutos NUMERIC(6,1), enviado_em TIMESTAMPTZ NOT NULL DEFAULT now());

CREATE OR REPLACE FUNCTION app.presente(p app.presenca) RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT p.por_codigo OR p.manual OR coalesce(p.minutos_meet, 0) >= app.config('duracao_aula_min')::numeric * app.config('presenca_minima_pct')::numeric / 100 $$;

-- Gera o codigo da aula (revisores). Vale da criacao ate 30 min depois do fim previsto da aula.
CREATE OR REPLACE FUNCTION app.gerar_codigo_presenca(p_tema TEXT) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_tema BIGINT; v_aula TIMESTAMPTZ; v_cod TEXT; v_ate TIMESTAMPTZ;
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  SELECT tema_id INTO v_tema FROM app.tema WHERE upper(replace(codigo,'-','')) = upper(replace(p_tema,'-',''));
  IF v_tema IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  v_aula := coalesce((SELECT data_hora FROM app.agenda_aula WHERE tema_id = v_tema LIMIT 1),
                     (SELECT data_abertura FROM app.onda_instancia WHERE tema_id = v_tema AND teste_num = 3 AND pessoa_id IS NULL LIMIT 1), now());
  v_ate := greatest(now(), v_aula + make_interval(mins => app.config('duracao_aula_min')::int)) + interval '30 minutes';
  LOOP
    v_cod := upper(substr(translate(encode(gen_random_bytes(8), 'base64'), '+/=0O1IL', ''), 1, 6));
    EXIT WHEN length(v_cod) = 6 AND NOT EXISTS (SELECT 1 FROM app.codigo_presenca WHERE codigo = v_cod);
  END LOOP;
  INSERT INTO app.codigo_presenca (codigo, tema_id, aula_em, valido_ate, criado_por) VALUES (v_cod, v_tema, v_aula, v_ate, app.pessoa_atual());
  RETURN jsonb_build_object('codigo', v_cod, 'valido_ate', v_ate, 'aula_em', v_aula);
END $$;

-- "Resgatar credito": o aluno cola o codigo ou o link mostrado na aula.
CREATE OR REPLACE FUNCTION app.resgatar_presenca(p_texto TEXT) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_cod TEXT := upper(substring(coalesce(p_texto, '') FROM '([A-Za-z0-9]{6})\s*/?\s*$')); c app.codigo_presenca; v_tit TEXT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT * INTO c FROM app.codigo_presenca WHERE codigo = v_cod;
  IF c.codigo IS NULL THEN RAISE EXCEPTION 'codigo_invalido'; END IF;
  IF now() > c.valido_ate THEN RAISE EXCEPTION 'codigo_expirado'; END IF;
  INSERT INTO app.presenca (pessoa_id, tema_id, aula_em, por_codigo, codigo_em) VALUES (app.pessoa_atual(), c.tema_id, c.aula_em, true, now())
  ON CONFLICT (pessoa_id, tema_id) DO UPDATE SET por_codigo = true, codigo_em = coalesce(app.presenca.codigo_em, now()), atualizado_em = now();
  SELECT codigo || ' — ' || titulo INTO v_tit FROM app.tema WHERE tema_id = c.tema_id;
  RETURN jsonb_build_object('tema', v_tit, 'aula_em', c.aula_em);
END $$;

-- Relatorio do Meet: [{email, nome, minutos, entrada, saida}] -> presenca (soma por pessoa).
CREATE OR REPLACE FUNCTION app.importar_presenca_meet(p_tema TEXT, p_linhas JSONB) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_tema BIGINT; v_aula TIMESTAMPTZ; n_ok INT := 0; n_presentes INT := 0; n_sem INT := 0; r RECORD;
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  SELECT tema_id INTO v_tema FROM app.tema WHERE upper(replace(codigo,'-','')) = upper(replace(p_tema,'-',''));
  IF v_tema IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  v_aula := coalesce((SELECT data_hora FROM app.agenda_aula WHERE tema_id = v_tema LIMIT 1),
                     (SELECT data_abertura FROM app.onda_instancia WHERE tema_id = v_tema AND teste_num = 3 AND pessoa_id IS NULL LIMIT 1), now());
  DELETE FROM app.presenca_nao_identificada WHERE tema_id = v_tema;
  FOR r IN
    WITH l AS (SELECT lower(trim(x->>'email')) AS email, x->>'nome' AS nome, coalesce((x->>'minutos')::numeric, 0) AS minutos,
                      nullif(x->>'entrada','')::timestamptz AS entrada, nullif(x->>'saida','')::timestamptz AS saida
                 FROM jsonb_array_elements(p_linhas) x),
    m AS (SELECT l.*, (SELECT p.pessoa_id FROM app.pessoa p LEFT JOIN app.contato_aluno c ON c.pessoa_id = p.pessoa_id
                        WHERE l.email <> '' AND (lower(p.email_primario::text) = l.email OR lower(c.email_aviso) = l.email) LIMIT 1) AS pessoa_id
            FROM l)
    SELECT pessoa_id, max(nome) AS nome, max(email) AS email, sum(minutos) AS minutos, min(entrada) AS entrada, max(saida) AS saida
      FROM m GROUP BY pessoa_id, CASE WHEN pessoa_id IS NULL THEN coalesce(email, nome) END
  LOOP
    IF r.pessoa_id IS NULL THEN
      INSERT INTO app.presenca_nao_identificada (tema_id, nome, email, minutos) VALUES (v_tema, r.nome, r.email, r.minutos);
      n_sem := n_sem + 1;
    ELSE
      INSERT INTO app.presenca (pessoa_id, tema_id, aula_em, minutos_meet, entrada_meet, saida_meet)
      VALUES (r.pessoa_id, v_tema, v_aula, least(r.minutos, 9999), r.entrada, r.saida)
      ON CONFLICT (pessoa_id, tema_id) DO UPDATE SET minutos_meet = EXCLUDED.minutos_meet, entrada_meet = EXCLUDED.entrada_meet,
        saida_meet = EXCLUDED.saida_meet, atualizado_em = now();
      n_ok := n_ok + 1;
      IF r.minutos >= app.config('duracao_aula_min')::numeric * app.config('presenca_minima_pct')::numeric / 100 THEN n_presentes := n_presentes + 1; END IF;
    END IF;
  END LOOP;
  RETURN jsonb_build_object('identificados', n_ok, 'presentes_pelo_tempo', n_presentes, 'nao_identificados', n_sem,
                            'minimo_minutos', app.config('duracao_aula_min')::numeric * app.config('presenca_minima_pct')::numeric / 100);
END $$;

-- Lista de presenca de uma aula (revisores).
CREATE OR REPLACE FUNCTION app.lista_presenca(p_tema TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH t AS (SELECT tema_id, codigo, titulo FROM app.tema WHERE upper(replace(codigo,'-','')) = upper(replace(p_tema,'-','')))
  SELECT jsonb_build_object(
    'tema', (SELECT codigo || ' — ' || titulo FROM t),
    'presencas', coalesce((SELECT jsonb_agg(jsonb_build_object('nome', pe.nome_completo, 'email', pe.email_primario::text,
                     'por_codigo', pr.por_codigo, 'minutos_meet', pr.minutos_meet, 'entrada', pr.entrada_meet, 'saida', pr.saida_meet,
                     'manual', pr.manual, 'presente', app.presente(pr)) ORDER BY pe.nome_completo)
                   FROM app.presenca pr JOIN app.pessoa pe ON pe.pessoa_id = pr.pessoa_id, t WHERE pr.tema_id = t.tema_id), '[]'),
    'nao_identificados', coalesce((SELECT jsonb_agg(jsonb_build_object('nome', n.nome, 'email', n.email, 'minutos', n.minutos))
                   FROM app.presenca_nao_identificada n, t WHERE n.tema_id = t.tema_id), '[]'),
    'codigos', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', c.codigo, 'valido_ate', c.valido_ate) ORDER BY c.criado_em DESC)
                   FROM app.codigo_presenca c, t WHERE c.tema_id = t.tema_id), '[]'))
  WHERE app.eh_revisor() $$;

-- Presenca da pessoa logada.
CREATE OR REPLACE FUNCTION app.minhas_presencas() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('tema', t.codigo, 'titulo', t.titulo, 'aula_em', pr.aula_em,
           'por_codigo', pr.por_codigo, 'minutos_meet', pr.minutos_meet, 'presente', app.presente(pr)) ORDER BY pr.aula_em), '[]'::jsonb)
    FROM app.presenca pr JOIN app.tema t ON t.tema_id = pr.tema_id WHERE pr.pessoa_id = app.pessoa_atual() $$;

REVOKE EXECUTE ON FUNCTION app.gerar_codigo_presenca(TEXT), app.resgatar_presenca(TEXT), app.importar_presenca_meet(TEXT, JSONB),
  app.lista_presenca(TEXT), app.minhas_presencas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.gerar_codigo_presenca(TEXT), app.resgatar_presenca(TEXT), app.importar_presenca_meet(TEXT, JSONB),
  app.lista_presenca(TEXT), app.minhas_presencas() TO api_rw;

-- ---------- (4) certificado ----------
CREATE TABLE IF NOT EXISTS app.certificado (
  codigo    TEXT PRIMARY KEY,
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  emitido_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  dados     JSONB NOT NULL);

-- Resumo do aproveitamento: temas concluidos, horas, aulas realizadas para a pessoa e % de presenca.
CREATE OR REPLACE FUNCTION app.aproveitamento(p_pessoa BIGINT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH conc AS (SELECT t.codigo, t.titulo FROM app.tema t WHERE app.tema_concluido(p_pessoa, t.tema_id)),
  aulas AS (  -- aulas que ja aconteceram e valem para a pessoa: do grupo desde a aprovacao + D0 proprios
    SELECT a.tema_id FROM app.agenda_aula a, app.ficha_aluno f
     WHERE f.pessoa_id = p_pessoa AND a.tema_id IS NOT NULL AND a.data_hora < now() AND a.data_hora >= coalesce(f.decidido_em, f.criado_em) - interval '1 day'
    UNION
    SELECT o.tema_id FROM app.onda_instancia o, app.ficha_aluno f  -- tema principal ainda sem agenda (ambiente de teste)
     WHERE f.pessoa_id = p_pessoa AND o.pessoa_id IS NULL AND o.teste_num = 3 AND o.data_abertura < now()
       AND o.data_abertura >= coalesce(f.decidido_em, f.criado_em) - interval '1 day'
       AND NOT EXISTS (SELECT 1 FROM app.agenda_aula a WHERE a.tema_id = o.tema_id)
    UNION
    SELECT o.tema_id FROM app.onda_instancia o WHERE o.pessoa_id = p_pessoa AND o.teste_num = 3 AND o.data_abertura < now()),
  pres AS (SELECT count(*) FILTER (WHERE app.presente(pr)) AS n FROM app.presenca pr WHERE pr.pessoa_id = p_pessoa AND pr.tema_id IN (SELECT tema_id FROM aulas))
  SELECT jsonb_build_object(
    'temas_concluidos', (SELECT count(*) FROM conc),
    'lista_temas', coalesce((SELECT jsonb_agg(codigo || ' — ' || titulo ORDER BY codigo) FROM conc), '[]'),
    'horas', (SELECT count(*) FROM conc) * app.config('horas_por_tema')::int,
    'aulas_realizadas', (SELECT count(*) FROM aulas),
    'aulas_presentes', (SELECT n FROM pres),
    'presenca_pct', CASE WHEN (SELECT count(*) FROM aulas) = 0 THEN NULL
                         ELSE round(100.0 * (SELECT n FROM pres) / (SELECT count(*) FROM aulas), 0) END) $$;

CREATE OR REPLACE FUNCTION app.emitir_certificado() RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_cod TEXT; v JSONB;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  v := app.aproveitamento(app.pessoa_atual()) || jsonb_build_object(
         'nome', (SELECT nome_completo FROM app.pessoa WHERE pessoa_id = app.pessoa_atual()),
         'perfil', (SELECT jsonb_build_object('ano', ano, 'especialidade', especialidade) FROM app.perfil_aluno(app.pessoa_atual())));
  IF (v->>'temas_concluidos')::int = 0 THEN RAISE EXCEPTION 'sem_temas_concluidos'; END IF;
  v_cod := upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 4) || '-' || substr(encode(gen_random_bytes(8), 'hex'), 1, 4) || '-' || substr(encode(gen_random_bytes(8), 'hex'), 1, 4));
  INSERT INTO app.certificado (codigo, pessoa_id, dados) VALUES (v_cod, app.pessoa_atual(), v);
  RETURN v || jsonb_build_object('codigo', v_cod, 'emitido_em', now());
END $$;

-- Verificacao publica (sem login): so nome, data, horas, temas e presenca.
CREATE OR REPLACE FUNCTION app.verificar_certificado(p_codigo TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT c.dados || jsonb_build_object('codigo', c.codigo, 'emitido_em', c.emitido_em)
    FROM app.certificado c WHERE c.codigo = upper(trim(p_codigo)) $$;

CREATE OR REPLACE FUNCTION app.meu_aproveitamento() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aproveitamento(app.pessoa_atual())
         || jsonb_build_object('certificados', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', codigo, 'emitido_em', emitido_em) ORDER BY emitido_em DESC)
                                                          FROM app.certificado WHERE pessoa_id = app.pessoa_atual()), '[]'))
   WHERE app.pessoa_atual() IS NOT NULL $$;
REVOKE EXECUTE ON FUNCTION app.aproveitamento(BIGINT), app.emitir_certificado(), app.verificar_certificado(TEXT), app.meu_aproveitamento() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.emitir_certificado(), app.verificar_certificado(TEXT), app.meu_aproveitamento() TO api_rw;

-- ---------- (5) preceptor ----------
CREATE TABLE IF NOT EXISTS app.preceptor_aluno (
  preceptor_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  aluno_id     BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  criado_em    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (preceptor_id, aluno_id));

CREATE OR REPLACE FUNCTION app.preceptores() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(DISTINCT jsonb_build_object('pessoa_id', p.pessoa_id, 'nome', p.nome_completo)), '[]'::jsonb)
    FROM app.designacao d JOIN app.pessoa p ON p.pessoa_id = d.pessoa_id
   WHERE app.eh_revisor() AND d.papel = 'docente' AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date) $$;

CREATE OR REPLACE FUNCTION app.definir_preceptor(p_aluno BIGINT, p_preceptor BIGINT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  DELETE FROM app.preceptor_aluno WHERE aluno_id = p_aluno;
  IF p_preceptor IS NOT NULL THEN INSERT INTO app.preceptor_aluno VALUES (p_preceptor, p_aluno) ON CONFLICT DO NOTHING; END IF;
END $$;

CREATE OR REPLACE FUNCTION app.meus_residentes() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
      'nome', pe.nome_completo, 'email', pe.email_primario::text, 'ano', pf.ano, 'especialidade', pf.especialidade,
      'testes', (SELECT count(*) FROM app.nota_teste n WHERE n.pessoa_id = pa.aluno_id),
      'media', (SELECT round(avg(n.pct), 0) FROM app.nota_teste n WHERE n.pessoa_id = pa.aluno_id),
      'esperada', (SELECT round(avg(n.esperado), 0) FROM app.nota_teste n WHERE n.pessoa_id = pa.aluno_id),
      'ultimo_acesso', (SELECT max(s.emitida_em) FROM app.sessao s WHERE s.pessoa_id = pa.aluno_id),
      'aproveitamento', app.aproveitamento(pa.aluno_id),
      'evolucao', (SELECT jsonb_agg(jsonb_build_object('teste', x.teste_num, 'nota', x.m, 'esperada', x.e) ORDER BY x.teste_num)
                     FROM (SELECT n.teste_num, round(avg(n.pct), 0) AS m, round(avg(n.esperado), 0) AS e FROM app.nota_teste n
                            WHERE n.pessoa_id = pa.aluno_id GROUP BY 1) x),
      'pendentes', (SELECT count(*) FROM app.onda_instancia o
                     WHERE o.tema_id IS NOT NULL AND o.onda_id = app.onda_da_pessoa(pa.aluno_id, o.tema_id, o.teste_num)
                       AND app.teste_liberado(pa.aluno_id, o.tema_id, o.teste_num) AND app.onda_respondivel(o.onda_id)
                       AND NOT app.teste_submetido(pa.aluno_id, o.tema_id, o.teste_num))) ORDER BY pe.nome_completo), '[]'::jsonb)
    FROM app.preceptor_aluno pa JOIN app.pessoa pe ON pe.pessoa_id = pa.aluno_id, LATERAL app.perfil_aluno(pa.aluno_id) pf
   WHERE pa.preceptor_id = app.pessoa_atual() $$;
REVOKE EXECUTE ON FUNCTION app.preceptores(), app.definir_preceptor(BIGINT, BIGINT), app.meus_residentes() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.preceptores(), app.definir_preceptor(BIGINT, BIGINT), app.meus_residentes() TO api_rw;

-- Regras de aprovacao automatica (revisores).
CREATE OR REPLACE FUNCTION app.regras_aprovacao() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('tipo', tipo, 'valor', valor) ORDER BY tipo, valor), '[]'::jsonb)
    FROM app.regra_aprovacao WHERE app.eh_revisor() $$;
CREATE OR REPLACE FUNCTION app.salvar_regras_aprovacao(p_dominios TEXT[], p_emails TEXT[]) RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE n INT;
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  DELETE FROM app.regra_aprovacao;
  INSERT INTO app.regra_aprovacao (tipo, valor)
  SELECT DISTINCT 'dominio', lower(trim(both '@ ' FROM d)) FROM unnest(p_dominios) d WHERE trim(both '@ ' FROM d) ~ '^[a-z0-9.-]+\.[a-z]{2,}$'
  UNION
  SELECT DISTINCT 'email', lower(trim(e)) FROM unnest(p_emails) e WHERE lower(trim(e)) ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$';
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$;
REVOKE EXECUTE ON FUNCTION app.regras_aprovacao(), app.salvar_regras_aprovacao(TEXT[], TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.regras_aprovacao(), app.salvar_regras_aprovacao(TEXT[], TEXT[]) TO api_rw;

-- ---------- (6) analise das questoes ----------
CREATE OR REPLACE FUNCTION app.painel_questoes()
RETURNS TABLE (tema TEXT, codigo TEXT, perfil TEXT, teste_num SMALLINT, dificuldade SMALLINT, taxa_esperada TEXT,
               respostas INT, acerto_pct NUMERIC, discriminacao NUMERIC, distrator TEXT, distrator_pct NUMERIC, alerta TEXT, enunciado TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH r AS (  -- primeira resposta de cada pessoa a cada questao
    SELECT DISTINCT ON (t.pessoa_id, r.item_id) r.item_id, r.alternativa_id, a.eh_correta, n.pct AS nota_teste
      FROM app.resposta r JOIN app.tentativa t ON t.tentativa_id = r.tentativa_id
      JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
      LEFT JOIN app.nota_teste n ON n.tentativa_id = t.tentativa_id
     WHERE t.submetida_em IS NOT NULL ORDER BY t.pessoa_id, r.item_id, t.submetida_em),
  g AS (SELECT r.*, ntile(4) OVER (PARTITION BY r.item_id ORDER BY r.nota_teste) AS quartil FROM r),
  est AS (
    SELECT item_id, count(*)::int AS n, avg(eh_correta::int) AS p,
           avg(eh_correta::int) FILTER (WHERE quartil = 4) - avg(eh_correta::int) FILTER (WHERE quartil = 1) AS d
      FROM g GROUP BY item_id),
  dis AS (
    SELECT DISTINCT ON (r.item_id) r.item_id, al.texto, count(*) OVER (PARTITION BY r.item_id, r.alternativa_id) AS k
      FROM r JOIN app.alternativa al ON al.alternativa_id = r.alternativa_id WHERE NOT r.eh_correta
     ORDER BY r.item_id, count(*) OVER (PARTITION BY r.item_id, r.alternativa_id) DESC)
  SELECT t.codigo, i.codigo, i.perfil, i.teste_num, i.dificuldade, i.taxa_esperada, coalesce(e.n, 0),
         round(100 * e.p, 0), round(e.d, 2), left(dis.texto, 120), round(100.0 * dis.k / nullif(e.n, 0), 0),
         CASE WHEN coalesce(e.n, 0) < 10 THEN 'poucas respostas'
              WHEN e.p > 0.95 THEN 'fácil demais'
              WHEN e.p < 0.10 THEN 'difícil demais (conferir gabarito)'
              WHEN e.d IS NOT NULL AND e.d < 0.1 THEN 'discrimina mal'
              WHEN abs(100 * e.p - app.taxa_do_grau(i.dificuldade)) > 25 THEN 'fora da faixa esperada'
              ELSE 'ok' END,
         left(i.enunciado, 160)
    FROM app.item i JOIN app.tema t ON t.tema_id = i.tema_id
    LEFT JOIN est e ON e.item_id = i.item_id LEFT JOIN dis ON dis.item_id = i.item_id
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY t.codigo, i.teste_num NULLS FIRST, i.perfil, i.codigo $$;
REVOKE EXECUTE ON FUNCTION app.painel_questoes() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.painel_questoes() TO api_rw;

-- Painel: presenca por aula.
CREATE OR REPLACE FUNCTION app.painel_presenca()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, aula_em TIMESTAMPTZ, por_codigo BOOLEAN,
               minutos_meet NUMERIC, presente BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(pr.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, pr.aula_em, pr.por_codigo, pr.minutos_meet, app.presente(pr)
    FROM app.presenca pr JOIN app.tema t ON t.tema_id = pr.tema_id, LATERAL app.perfil_aluno(pr.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL ORDER BY pr.aula_em, 1 $$;
REVOKE EXECUTE ON FUNCTION app.painel_presenca() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.painel_presenca() TO api_rw;

-- Contadores para as telas iniciais da coordenacao.
CREATE OR REPLACE FUNCTION app.resumo_coordenacao() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object(
    'inscricoes_pendentes', (SELECT count(*) FROM app.ficha_aluno WHERE status = 'pendente'),
    'alunos_ativos', (SELECT count(*) FROM app.ficha_aluno WHERE status = 'aprovado'),
    'duvidas_pendentes', (SELECT count(*) FROM app.mensagem_aluno WHERE tipo = 'duvida' AND resposta IS NULL),
    'rascunhos', (SELECT count(*) FROM conteudo.artefato WHERE status = 'rascunho'),
    'publicados', (SELECT count(*) FROM conteudo.artefato WHERE status = 'publicado'),
    'proximas_aulas', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', t.codigo, 'titulo', t.titulo, 'data_hora', a.data_hora) ORDER BY a.data_hora)
                                FROM (SELECT * FROM app.agenda_aula WHERE data_hora > now() - interval '3 hours' ORDER BY data_hora LIMIT 4) a
                                JOIN app.tema t ON t.tema_id = a.tema_id), '[]'))
  WHERE app.eh_revisor() $$;
REVOKE EXECUTE ON FUNCTION app.resumo_coordenacao() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.resumo_coordenacao() TO api_rw;

-- ---------- (7) resumo semanal ----------
CREATE TABLE IF NOT EXISTS app.resumo_enviado (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  semana    DATE NOT NULL,
  PRIMARY KEY (pessoa_id, semana));

CREATE OR REPLACE FUNCTION app.gerar_resumo_semanal() RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE r RECORD; v_sem DATE := date_trunc('week', now() AT TIME ZONE 'America/Sao_Paulo')::date; v_txt TEXT; n INT := 0;
        v_antigo TEXT := current_setting('app.pessoa_id', true);
BEGIN
  -- so na segunda-feira, a partir das 7h (horario de Brasilia)
  IF extract(isodow FROM now() AT TIME ZONE 'America/Sao_Paulo') <> 1 OR extract(hour FROM now() AT TIME ZONE 'America/Sao_Paulo') < 7 THEN RETURN 0; END IF;
  FOR r IN SELECT c.pessoa_id, coalesce(c.email_aviso, p.email_primario::text) AS destino, p.nome_completo
             FROM app.contato_aluno c JOIN app.pessoa p ON p.pessoa_id = c.pessoa_id
            WHERE c.aceita_email AND app.eh_aluno_ativo(c.pessoa_id)
              AND NOT EXISTS (SELECT 1 FROM app.resumo_enviado e WHERE e.pessoa_id = c.pessoa_id AND e.semana = v_sem) LOOP
    PERFORM set_config('app.pessoa_id', r.pessoa_id::text, true);
    SELECT 'Olá, ' || split_part(r.nome_completo, ' ', 1) || E'! Sua semana no Programa de Cirurgia de Urgência e Trauma:\n\n'
      || coalesce('AULAS DA SEMANA\n' || (SELECT string_agg('• ' || to_char(a.data_hora AT TIME ZONE 'America/Sao_Paulo', 'DD/MM (Dy) HH24:MI') || ' — ' || a.codigo || ' ' || a.titulo, E'\n' ORDER BY a.data_hora)
                    FROM app.calendario_aulas() a WHERE a.data_hora >= now() AND a.data_hora < now() + interval '7 days') || E'\n\n', '')
      || coalesce('TESTES PENDENTES\n' || (SELECT string_agg('• ' || pd.codigo || ' — ' || pd.nome || coalesce(' (até ' || to_char(pd.prazo AT TIME ZONE 'America/Sao_Paulo', 'DD/MM HH24:MI') || ')', ''), E'\n')
                    FROM app.pendencias() pd WHERE pd.tipo = 'teste') || E'\n\n', '')
      || coalesce('AVALIAÇÕES PENDENTES: ' || (SELECT count(*)::text FROM app.pendencias() pd WHERE pd.tipo = 'avaliacao' HAVING count(*) > 0) || E'\n\n', '')
      || coalesce('NOVO NO MURAL\n' || (SELECT string_agg('• ' || m.titulo, E'\n') FROM app.mural m
                    WHERE NOT m.arquivado AND m.publico IN ('alunos','todos') AND m.publicado_em > now() - interval '7 days') || E'\n\n', '')
      || 'Link fixo das aulas (Google Meet): ' || coalesce(app.config('link_meet'), '—')
      INTO v_txt;
    INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
    VALUES (r.pessoa_id, 'email', r.destino, 'Sua semana no curso — ' || to_char(v_sem, 'DD/MM'), v_txt,
            jsonb_build_object('caminho', '/aluno/pendencias', 'rotulo_link', 'Abrir as pendências'));
    INSERT INTO app.resumo_enviado VALUES (r.pessoa_id, v_sem);
    n := n + 1;
  END LOOP;
  PERFORM set_config('app.pessoa_id', coalesce(v_antigo, ''), true);
  RETURN n;
END $$;

-- Aniversario: e-mail de parabens (a partir das 8h), com o aproveitamento no curso e agradecimento.
CREATE TABLE IF NOT EXISTS app.aniversario_enviado (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  ano       SMALLINT NOT NULL,
  PRIMARY KEY (pessoa_id, ano));

CREATE OR REPLACE FUNCTION app.gerar_aniversarios() RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE r RECORD; a JSONB; v_hoje DATE := (now() AT TIME ZONE 'America/Sao_Paulo')::date; n INT := 0; v_txt TEXT;
BEGIN
  IF extract(hour FROM now() AT TIME ZONE 'America/Sao_Paulo') < 8 THEN RETURN 0; END IF;
  FOR r IN SELECT p.pessoa_id, p.nome_completo, p.data_nascimento, p.email_primario::text AS email
             FROM app.pessoa p JOIN app.ficha_aluno f ON f.pessoa_id = p.pessoa_id AND f.status = 'aprovado'
            WHERE p.data_nascimento IS NOT NULL
              AND (to_char(p.data_nascimento, 'MM-DD') = to_char(v_hoje, 'MM-DD')
                   -- quem nasceu em 29/02 recebe em 28/02 nos anos nao bissextos
                   OR (to_char(p.data_nascimento, 'MM-DD') = '02-29' AND to_char(v_hoje, 'MM-DD') = '02-28'
                       AND extract(day FROM make_date(extract(year FROM v_hoje)::int, 3, 1) - 1) = 28))
              AND NOT EXISTS (SELECT 1 FROM app.aniversario_enviado e WHERE e.pessoa_id = p.pessoa_id AND e.ano = extract(year FROM v_hoje)) LOOP
    a := app.aproveitamento(r.pessoa_id);
    v_txt := 'Prezado(a) ' || split_part(r.nome_completo, ' ', 1) || E',\n\n'
      || E'Em nome da coordenação do Programa de Cirurgia de Urgência e Trauma, desejamos a você um feliz aniversário! '
      || E'Que este novo ano traga saúde, realizações e muitas conquistas na sua formação e na sua vida.\n\n'
      || E'Aproveitamos a data para compartilhar o seu caminho no curso até aqui:\n'
      || '• Temas concluídos: ' || (a->>'temas_concluidos') || ' (' || (a->>'horas') || E' horas)\n'
      || CASE WHEN a->>'presenca_pct' IS NOT NULL
              THEN '• Presença nas aulas ao vivo: ' || (a->>'presenca_pct') || '% (' || (a->>'aulas_presentes') || ' de ' || (a->>'aulas_realizadas') || E' aulas)\n'
              ELSE '' END
      || coalesce('• Média nos testes: ' || (SELECT round(avg(n.pct))::text FROM app.nota_teste n WHERE n.pessoa_id = r.pessoa_id) || '% '
                  || '(esperada para o seu perfil: ' || (SELECT round(avg(n.esperado))::text FROM app.nota_teste n WHERE n.pessoa_id = r.pessoa_id) || E'%)\n', '')
      || E'\nMuito obrigado pela confiança depositada no programa e pela sua participação: ela é o que dá sentido a este trabalho. '
      || E'Seguimos juntos!\n\nCom carinho e estima,\nCoordenação do Programa de Cirurgia de Urgência e Trauma';
    INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
    VALUES (r.pessoa_id, 'email', r.email, 'Feliz aniversário, ' || split_part(r.nome_completo, ' ', 1) || '!', v_txt,
            jsonb_build_object('caminho', '/aluno/desempenho', 'rotulo_link', 'Ver o seu desempenho',
                               'rodape', 'Mensagem da coordenação do Programa de Cirurgia de Urgência e Trauma.'));
    INSERT INTO app.aniversario_enviado VALUES (r.pessoa_id, extract(year FROM v_hoje));
    n := n + 1;
  END LOOP;
  RETURN n;
END $$;

-- O enfileirador (45) passa a chamar o resumo semanal e os aniversarios.
DO $$
DECLARE d TEXT;
BEGIN
  SELECT pg_get_functiondef('app.enfileirar_notificacoes()'::regprocedure) INTO d;
  IF position('gerar_resumo_semanal' IN d) = 0 THEN
    d := replace(d, '  PERFORM app.gerar_lembretes();', '  PERFORM app.gerar_lembretes();' || E'\n' || '  PERFORM app.gerar_resumo_semanal();' || E'\n' || '  PERFORM app.gerar_aniversarios();');
    IF position('gerar_aniversarios' IN d) = 0 THEN RAISE EXCEPTION 'nao consegui ligar o resumo semanal ao enfileirador'; END IF;
    EXECUTE d;
  END IF;
END $$;

COMMIT;
\echo 'meet, agenda, mural, presenca, certificado, preceptor, analise de questoes e resumo semanal: prontos'
