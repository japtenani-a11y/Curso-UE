-- ============================================================
-- 107_autorizacao_revisor_v1.0.sql
-- Decisão da coordenação de 19/11/2026: os revisores (papel curador) entram nomeados no grupo de elaboração dos guias
-- de atendimento. Na primeira entrada no sistema, cada revisor clica autorizando e declara conflitos de interesse
-- (termo em docs/termo_revisor_diretriz.md). Idempotente.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.autorizacao_revisor (
  pessoa_id      BIGINT PRIMARY KEY REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  versao_termo   TEXT NOT NULL,
  autorizado_em  TIMESTAMPTZ NOT NULL DEFAULT now(),
  sem_conflitos  BOOLEAN NOT NULL,
  conflitos      TEXT,
  revogado_em    TIMESTAMPTZ
);

-- O revisor (curador com designação vigente) ainda precisa autorizar?
CREATE OR REPLACE FUNCTION app.autorizacao_revisor_situacao(p_pessoa BIGINT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object(
    'revisor', EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p_pessoa AND d.papel::text = 'curador'
                         AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)),
    'autorizado', EXISTS (SELECT 1 FROM app.autorizacao_revisor a WHERE a.pessoa_id = p_pessoa AND a.revogado_em IS NULL),
    'versao_termo', '1.0 · 19/11/2026') $$;

CREATE OR REPLACE FUNCTION app.registrar_autorizacao_revisor(p_pessoa BIGINT, p_sem_conflitos BOOLEAN, p_conflitos TEXT)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT (app.autorizacao_revisor_situacao(p_pessoa) ->> 'revisor')::boolean THEN RAISE EXCEPTION 'nao_e_revisor'; END IF;
  IF NOT p_sem_conflitos AND length(trim(coalesce(p_conflitos, ''))) < 5 THEN RAISE EXCEPTION 'descreva_os_conflitos'; END IF;
  INSERT INTO app.autorizacao_revisor (pessoa_id, versao_termo, sem_conflitos, conflitos)
  VALUES (p_pessoa, '1.0 · 19/11/2026', p_sem_conflitos, CASE WHEN p_sem_conflitos THEN NULL ELSE left(p_conflitos, 4000) END)
  ON CONFLICT (pessoa_id) DO UPDATE SET versao_termo = EXCLUDED.versao_termo, autorizado_em = now(),
    sem_conflitos = EXCLUDED.sem_conflitos, conflitos = EXCLUDED.conflitos, revogado_em = NULL;
  RETURN app.autorizacao_revisor_situacao(p_pessoa);
END $$;

-- Para a coordenação montar o "Grupo de elaboração e conflitos de interesse" de cada guia
CREATE OR REPLACE FUNCTION app.revisores_autorizados() RETURNS TABLE(nome TEXT, autorizado_em TIMESTAMPTZ, sem_conflitos BOOLEAN, conflitos TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT p.nome_completo::text, a.autorizado_em, a.sem_conflitos, a.conflitos
    FROM app.autorizacao_revisor a JOIN app.pessoa p USING (pessoa_id)
   WHERE a.revogado_em IS NULL ORDER BY p.nome_completo $$;

REVOKE EXECUTE ON FUNCTION app.autorizacao_revisor_situacao(BIGINT), app.registrar_autorizacao_revisor(BIGINT, BOOLEAN, TEXT), app.revisores_autorizados() FROM PUBLIC;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'api_rw') THEN
    GRANT EXECUTE ON FUNCTION app.autorizacao_revisor_situacao(BIGINT), app.registrar_autorizacao_revisor(BIGINT, BOOLEAN, TEXT), app.revisores_autorizados() TO api_rw;
  END IF;
END $$;
COMMIT;
