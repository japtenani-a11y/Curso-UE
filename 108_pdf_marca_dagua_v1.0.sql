-- ============================================================
-- 108_pdf_marca_dagua_v1.0.sql
-- OBJETIVO (pedido da coordenacao em 19/11/2026):
--  1. CRM e UF no cadastro (campos opcionais; graduando nao tem CRM).
--  2. Download do material em PDF com marca d'agua em todas as paginas: nome, codigo do aluno no curso, CRM/UF
--     (quando houver), data e hora do download e um codigo de verificacao. Cada download fica registrado aqui,
--     para rastrear uma copia que circule fora do curso ate quem baixou.
--  So baixa o que ja esta liberado para a pessoa (mesma regra da leitura: app.etapa_liberada; a equipe ve tudo).
-- Pode ser rodado mais de uma vez. Desfazer: DROP TABLE app.download_pdf; ALTER TABLE app.ficha_aluno DROP COLUMN crm, DROP COLUMN crm_uf;
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE app.ficha_aluno ADD COLUMN IF NOT EXISTS crm TEXT CHECK (crm IS NULL OR crm ~ '^[0-9]{1,8}$');
ALTER TABLE app.ficha_aluno ADD COLUMN IF NOT EXISTS crm_uf CHAR(2) CHECK (crm_uf IS NULL OR crm_uf IN
  ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'));
COMMENT ON COLUMN app.ficha_aluno.crm IS 'numero do CRM (so digitos), informado pelo aluno; vai na marca d''agua do PDF';

-- Codigo do aluno no curso: CUT-00012 (a partir do pessoa_id; nao identifica fora do sistema).
CREATE OR REPLACE FUNCTION app.codigo_aluno(p BIGINT) RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$ SELECT 'CUT-' || lpad(p::text, 5, '0') $$;

-- Registro profissional da pessoa logada.
CREATE OR REPLACE FUNCTION app.meu_registro_profissional() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object('codigo_aluno', app.codigo_aluno(p.pessoa_id), 'crm', f.crm, 'crm_uf', f.crm_uf,
                            'situacao', f.situacao)
    FROM app.pessoa p LEFT JOIN app.ficha_aluno f ON f.pessoa_id = p.pessoa_id
   WHERE p.pessoa_id = app.pessoa_atual() $$;

CREATE OR REPLACE FUNCTION app.salvar_registro_profissional(p_crm TEXT, p_uf TEXT) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_id BIGINT := app.pessoa_atual(); v_crm TEXT := nullif(regexp_replace(coalesce(p_crm, ''), '[^0-9]', '', 'g'), '');
        v_uf TEXT := nullif(upper(trim(coalesce(p_uf, ''))), '');
BEGIN
  IF v_id IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  IF (v_crm IS NULL) <> (v_uf IS NULL) THEN RAISE EXCEPTION 'campo:crm_uf'; END IF;
  IF v_crm IS NOT NULL AND length(v_crm) > 8 THEN RAISE EXCEPTION 'campo:crm'; END IF;
  IF NOT EXISTS (SELECT 1 FROM app.ficha_aluno WHERE pessoa_id = v_id) THEN RAISE EXCEPTION 'campo:ficha'; END IF;
  UPDATE app.ficha_aluno SET crm = v_crm, crm_uf = v_uf, atualizado_em = now() WHERE pessoa_id = v_id;
  RETURN app.meu_registro_profissional();
EXCEPTION WHEN check_violation THEN RAISE EXCEPTION 'campo:crm_uf';
END $$;

-- ---------- registro de cada download ----------
CREATE TABLE IF NOT EXISTS app.download_pdf (
  codigo      TEXT PRIMARY KEY CHECK (codigo ~ '^[A-Z0-9]{4}-[A-Z0-9]{4}$'),
  pessoa_id   BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id     BIGINT NOT NULL REFERENCES app.tema(tema_id),
  pecas       TEXT[] NOT NULL,
  versoes     INT[] NOT NULL,
  baixado_em  TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip          INET,
  user_agent  TEXT);
CREATE INDEX IF NOT EXISTS download_pdf_pessoa_idx ON app.download_pdf (pessoa_id, baixado_em DESC);
ALTER TABLE app.download_pdf ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON app.download_pdf FROM PUBLIC;

-- Registra o download e devolve o que vai na marca d'agua e o texto das pecas (versao publicada, ja liberada).
-- p_tipo NULL = tema inteiro (todas as pecas liberadas).
CREATE OR REPLACE FUNCTION app.registrar_download_pdf(p_tema TEXT, p_tipo TEXT, p_ip INET, p_ua TEXT) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_id BIGINT := app.pessoa_atual(); t RECORD; v_etapa INT; v_cod TEXT; v_pecas JSONB; v_tipos TEXT[]; v_vers INT[];
        v_nome TEXT; v_crm TEXT; v_uf TEXT;
        ordem TEXT[] := ARRAY['objetivos','resumo_basico','podcast_roteiro','caso_base','sintese_evidencia','mapa',
                              'aula','slides','caso','resumo','protocolo','checklist','flashcard','simulado'];
BEGIN
  IF v_id IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  IF p_tipo IS NOT NULL AND NOT (p_tipo = ANY (ordem)) THEN RAISE EXCEPTION 'peca_invalida'; END IF;
  SELECT tema_id, codigo, titulo INTO t FROM app.tema WHERE upper(replace(codigo, '-', '')) = upper(replace(p_tema, '-', ''));
  IF NOT FOUND THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  -- limite contra coleta em massa: 30 downloads por pessoa em 24 h
  IF (SELECT count(*) FROM app.download_pdf WHERE pessoa_id = v_id AND baixado_em > now() - interval '24 hours') >= 30 THEN
    RAISE EXCEPTION 'limite_downloads'; END IF;
  v_etapa := app.etapa_liberada(v_id, t.tema_id);
  SELECT coalesce(jsonb_agg(jsonb_build_object('tipo', x.tipo, 'versao', x.versao, 'titulo', x.titulo, 'corpo', x.corpo)
                            ORDER BY array_position(ordem, x.tipo)), '[]'::jsonb),
         array_agg(x.tipo ORDER BY array_position(ordem, x.tipo)), array_agg(x.versao ORDER BY array_position(ordem, x.tipo))
    INTO v_pecas, v_tipos, v_vers
    FROM (SELECT DISTINCT ON (a.tipo) a.tipo::text AS tipo, a.versao, a.titulo, a.corpo
            FROM conteudo.artefato a
           WHERE a.tema_id = t.tema_id AND a.status::text = 'publicado' AND a.tipo::text = ANY (ordem)
             AND (p_tipo IS NULL OR a.tipo::text = p_tipo)
             AND app.etapa_do_material(a.tipo::text) IS NOT NULL AND app.etapa_do_material(a.tipo::text) <= v_etapa
           ORDER BY a.tipo, a.versao DESC) x;
  IF v_tipos IS NULL THEN RAISE EXCEPTION 'nada_liberado'; END IF;
  LOOP
    v_cod := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 4) || '-' || substr(md5(random()::text), 1, 4));
    EXIT WHEN NOT EXISTS (SELECT 1 FROM app.download_pdf WHERE codigo = v_cod);
  END LOOP;
  INSERT INTO app.download_pdf (codigo, pessoa_id, tema_id, pecas, versoes, ip, user_agent)
  VALUES (v_cod, v_id, t.tema_id, v_tipos, v_vers, p_ip, left(p_ua, 300));
  SELECT p.nome_completo, f.crm, f.crm_uf INTO v_nome, v_crm, v_uf
    FROM app.pessoa p LEFT JOIN app.ficha_aluno f ON f.pessoa_id = p.pessoa_id WHERE p.pessoa_id = v_id;
  RETURN jsonb_build_object(
    'codigo_verificacao', v_cod, 'baixado_em', now(),
    'nome', coalesce(v_nome, ''), 'codigo_aluno', app.codigo_aluno(v_id),
    'crm', CASE WHEN v_crm IS NOT NULL THEN 'CRM ' || v_crm || '/' || v_uf END,
    'tema', jsonb_build_object('codigo', t.codigo, 'titulo', t.titulo),
    'inteiro', p_tipo IS NULL, 'pecas', v_pecas);
END $$;

-- Coordenacao: a partir do codigo impresso no rodape, quem baixou, quando e o que.
CREATE OR REPLACE FUNCTION app.verificar_download_pdf(p_codigo TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT CASE WHEN NOT app.e_equipe(app.pessoa_atual()) THEN jsonb_build_object('erro', 'proibido') ELSE
    (SELECT jsonb_build_object('codigo', d.codigo, 'codigo_aluno', app.codigo_aluno(d.pessoa_id), 'nome', p.nome_completo,
                               'tema', t.codigo, 'pecas', d.pecas, 'versoes', d.versoes, 'baixado_em', d.baixado_em)
       FROM app.download_pdf d JOIN app.pessoa p ON p.pessoa_id = d.pessoa_id JOIN app.tema t ON t.tema_id = d.tema_id
      WHERE d.codigo = upper(trim(p_codigo))) END $$;

REVOKE EXECUTE ON FUNCTION app.registrar_download_pdf(TEXT, TEXT, INET, TEXT), app.verificar_download_pdf(TEXT),
  app.meu_registro_profissional(), app.salvar_registro_profissional(TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.registrar_download_pdf(TEXT, TEXT, INET, TEXT), app.verificar_download_pdf(TEXT),
  app.meu_registro_profissional(), app.salvar_registro_profissional(TEXT, TEXT), app.codigo_aluno(BIGINT) TO api_rw;

SELECT 'PDF com marca d''agua: pronto' AS ok;
COMMIT;
