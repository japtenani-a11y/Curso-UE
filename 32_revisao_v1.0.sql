-- 32_revisao_v1.0.sql
-- Revisao de rascunhos pelos curadores: afirmacoes com trecho literal e pareceres.
-- Decisoes: correto | erro_leve | erro_critico (tolerancia: ate 5% leve, zero critico).
-- Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS conteudo.afirmacao (
  afirmacao_id   BIGSERIAL PRIMARY KEY,
  artefato_id    BIGINT NOT NULL REFERENCES conteudo.artefato(artefato_id) ON DELETE CASCADE,
  codigo         TEXT NOT NULL,
  texto          TEXT NOT NULL,
  fonte_arquivo  TEXT,
  trecho_literal TEXT NOT NULL,
  UNIQUE (artefato_id, codigo)
);

CREATE TABLE IF NOT EXISTS conteudo.parecer_revisao (
  parecer_id       BIGSERIAL PRIMARY KEY,
  artefato_id      BIGINT NOT NULL REFERENCES conteudo.artefato(artefato_id) ON DELETE CASCADE,
  afirmacao_codigo TEXT NOT NULL DEFAULT '',   -- '' = parecer sobre o artefato inteiro
  pessoa_id        BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id),
  decisao          TEXT NOT NULL CHECK (decisao IN ('correto','erro_leve','erro_critico')),
  comentario       TEXT,
  criado_em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (artefato_id, afirmacao_codigo, pessoa_id)
);

ALTER TABLE conteudo.afirmacao ENABLE ROW LEVEL SECURITY;
ALTER TABLE conteudo.parecer_revisao ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_afirmacao_revisores ON conteudo.afirmacao;
CREATE POLICY pol_afirmacao_revisores ON conteudo.afirmacao FOR SELECT TO api_rw
  USING (app.role_atual() = ANY (ARRAY['admin','data_steward','curador','preceptor']));

DROP POLICY IF EXISTS pol_parecer_leitura ON conteudo.parecer_revisao;
CREATE POLICY pol_parecer_leitura ON conteudo.parecer_revisao FOR SELECT TO api_rw
  USING (app.role_atual() = ANY (ARRAY['admin','data_steward','curador','preceptor']));

DROP POLICY IF EXISTS pol_parecer_inserir ON conteudo.parecer_revisao;
CREATE POLICY pol_parecer_inserir ON conteudo.parecer_revisao FOR INSERT TO api_rw
  WITH CHECK (app.role_atual() = ANY (ARRAY['admin','data_steward','curador','preceptor'])
              AND pessoa_id = app.pessoa_atual());

DROP POLICY IF EXISTS pol_parecer_alterar ON conteudo.parecer_revisao;
CREATE POLICY pol_parecer_alterar ON conteudo.parecer_revisao FOR UPDATE TO api_rw
  USING (pessoa_id = app.pessoa_atual()) WITH CHECK (pessoa_id = app.pessoa_atual());

DROP POLICY IF EXISTS pol_maestro_afirmacao ON conteudo.afirmacao;
CREATE POLICY pol_maestro_afirmacao ON conteudo.afirmacao FOR ALL TO maestro_rw USING (true) WITH CHECK (true);

GRANT SELECT ON conteudo.afirmacao TO api_rw;
GRANT SELECT, INSERT, UPDATE ON conteudo.parecer_revisao TO api_rw;
GRANT USAGE ON SEQUENCE conteudo.parecer_revisao_parecer_id_seq TO api_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON conteudo.afirmacao TO maestro_rw;
GRANT USAGE ON SEQUENCE conteudo.afirmacao_afirmacao_id_seq TO maestro_rw;

COMMIT;
\echo 'revisao: tabelas conteudo.afirmacao e conteudo.parecer_revisao prontas'
