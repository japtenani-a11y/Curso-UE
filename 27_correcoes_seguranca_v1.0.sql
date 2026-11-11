-- ============================================================
-- 27_correcoes_seguranca_v1.0.sql
-- Programa de Cirurgia de Urgencia e Trauma
-- Correcoes de seguranca do banco (aplicar depois do 23).
--
-- O QUE FAZ
--  1. Troca as senhas padrao dos tres papeis (valores passados por variavel).
--  2. Cria funcoes SECURITY DEFINER para identificar, criar e revogar sessao,
--     para a API nao precisar ler app.sessao como superusuario.
--  3. Fecha fn_sessao_teste (so funciona se app.permitir_teste = on; em
--     producao a funcao e removida com -v producao=1).
--  4. Refaz as politicas de RLS: aluno so ve a propria linha; artefato so
--     publicado; escrita da resposta so na propria tentativa; papel maestro_rw
--     com politicas proprias.
--
-- USO (todos os tres -v sao obrigatorios):
--   psql -d programa_v44 -v ON_ERROR_STOP=1 \
--        -v api_pw='...' -v maestro_pw='...' -v metabase_pw='...' \
--        [-v producao=1] -f 27_correcoes_seguranca_v1.0.sql
--
-- IMPORTANTE: a API TEM que conectar como api_rw (nunca como postgres).
-- Superusuario ignora RLS: com DATABASE_URL=postgres://postgres... as
-- politicas abaixo nao valem nada.
-- ============================================================

\set ON_ERROR_STOP on
\if :{?api_pw}
\else
  \echo 'ERRO: informe -v api_pw=... -v maestro_pw=... -v metabase_pw=...'
  \quit
\endif
\if :{?maestro_pw}
\else
  \echo 'ERRO: falta -v maestro_pw=...'
  \quit
\endif
\if :{?metabase_pw}
\else
  \echo 'ERRO: falta -v metabase_pw=...'
  \quit
\endif

\echo '=== CORRECOES DE SEGURANCA v1.0 ==='

BEGIN;

-- 1. SENHAS
ALTER ROLE api_rw PASSWORD :'api_pw';
ALTER ROLE maestro_rw PASSWORD :'maestro_pw';
ALTER ROLE metabase_ro PASSWORD :'metabase_pw';
ALTER ROLE api_rw NOSUPERUSER NOBYPASSRLS;
ALTER ROLE maestro_rw NOSUPERUSER NOBYPASSRLS;
ALTER ROLE metabase_ro NOSUPERUSER NOBYPASSRLS;

-- 2. FUNCOES DE APOIO

CREATE OR REPLACE FUNCTION app.pessoa_atual()
RETURNS BIGINT
LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('app.pessoa_id', true), '')::bigint;
$$;

CREATE OR REPLACE FUNCTION app.fn_identificar_sessao(p_token TEXT)
RETURNS TABLE (pessoa_id BIGINT, nome_completo TEXT, email_primario TEXT, papel TEXT)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
  SELECT p.pessoa_id,
         p.nome_completo,
         p.email_primario::text,
         coalesce((SELECT d.papel
                     FROM app.designacao d
                    WHERE d.pessoa_id = p.pessoa_id
                      AND d.vigencia_inicio <= current_date
                      AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)
                    ORDER BY d.vigencia_inicio DESC LIMIT 1), 'aluno')
    FROM app.sessao s
    JOIN app.pessoa p ON p.pessoa_id = s.pessoa_id
   WHERE s.token_hash = encode(digest(p_token, 'sha256'), 'hex')
     AND s.revogada_em IS NULL
     AND s.expira_em > now();
$$;

CREATE OR REPLACE FUNCTION app.fn_revogar_sessao(p_token TEXT)
RETURNS VOID
LANGUAGE sql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
  UPDATE app.sessao
     SET revogada_em = now()
   WHERE token_hash = encode(digest(p_token, 'sha256'), 'hex')
     AND revogada_em IS NULL;
$$;

-- Cria sessao para um e-mail ja cadastrado. Chamar SO depois de a API ter
-- verificado o id_token do Google (e-mail confirmado). Devolve NULL se o
-- e-mail nao estiver cadastrado.
CREATE OR REPLACE FUNCTION app.fn_sessao_google(p_email TEXT, p_ip INET, p_ua TEXT)
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
DECLARE
  v_pessoa_id BIGINT;
  v_token TEXT;
BEGIN
  SELECT pessoa_id INTO v_pessoa_id
    FROM app.pessoa
   WHERE lower(email_primario::text) = lower(p_email);
  IF v_pessoa_id IS NULL THEN
    RETURN NULL;
  END IF;
  v_token := encode(gen_random_bytes(32), 'hex');
  INSERT INTO app.sessao (pessoa_id, token_hash, expira_em, ip_origem, user_agent)
  VALUES (v_pessoa_id, encode(digest(v_token, 'sha256'), 'hex'),
          now() + interval '12 hours', p_ip, left(p_ua, 300));
  RETURN v_token;
END $$;

-- 3. LOGIN DE TESTE: so com app.permitir_teste = on (e removido em producao)
CREATE OR REPLACE FUNCTION app.fn_sessao_teste(p_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
DECLARE
  v_pessoa_id BIGINT;
  v_token TEXT;
BEGIN
  IF coalesce(current_setting('app.permitir_teste', true), 'off') <> 'on' THEN
    RAISE EXCEPTION 'fn_sessao_teste desabilitada' USING ERRCODE = '42501';
  END IF;
  SELECT pessoa_id INTO v_pessoa_id FROM app.pessoa WHERE email_primario = p_email;
  IF v_pessoa_id IS NULL THEN
    RAISE EXCEPTION 'pessoa nao encontrada: %', p_email USING ERRCODE = '23503';
  END IF;
  v_token := encode(gen_random_bytes(32), 'hex');
  INSERT INTO app.sessao (pessoa_id, token_hash, expira_em, ip_origem, user_agent)
  VALUES (v_pessoa_id, encode(digest(v_token, 'sha256'), 'hex'),
          now() + interval '24 hours', '127.0.0.1'::inet, 'fn_sessao_teste');
  RETURN v_token;
END $$;

REVOKE EXECUTE ON FUNCTION app.fn_sessao_teste(TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION app.fn_identificar_sessao(TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION app.fn_revogar_sessao(TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION app.fn_sessao_google(TEXT, INET, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.fn_identificar_sessao(TEXT) TO api_rw;
GRANT EXECUTE ON FUNCTION app.fn_revogar_sessao(TEXT) TO api_rw;
GRANT EXECUTE ON FUNCTION app.fn_sessao_google(TEXT, INET, TEXT) TO api_rw;
GRANT EXECUTE ON FUNCTION app.fn_sessao_teste(TEXT) TO api_rw;
GRANT EXECUTE ON FUNCTION app.pessoa_atual() TO api_rw, maestro_rw, metabase_ro;

\if :{?producao}
  DROP FUNCTION IF EXISTS app.fn_sessao_teste(TEXT);
  \echo 'producao: fn_sessao_teste removida'
\endif

-- 4. RLS
-- Papeis que enxergam dados de varias pessoas
-- (mantido em lista unica para nao divergir entre politicas)
-- privilegiados de leitura: admin, data_steward, preceptor, pesquisador, curador

ALTER TABLE app.tentativa ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_pessoa_leitura ON app.pessoa;
CREATE POLICY pol_pessoa_leitura ON app.pessoa FOR SELECT
  USING (pessoa_id = app.pessoa_atual()
         OR app.role_atual() IN ('admin','data_steward','preceptor','pesquisador','curador'));

DROP POLICY IF EXISTS pol_sessao_leitura ON app.sessao;
CREATE POLICY pol_sessao_leitura ON app.sessao FOR SELECT
  USING (app.role_atual() IN ('admin','data_steward') OR pessoa_id = app.pessoa_atual());

DROP POLICY IF EXISTS pol_tentativa_leitura ON app.tentativa;
DROP POLICY IF EXISTS pol_tentativa_insercao ON app.tentativa;
DROP POLICY IF EXISTS pol_tentativa_atualizacao ON app.tentativa;
CREATE POLICY pol_tentativa_leitura ON app.tentativa FOR SELECT
  USING (pessoa_id = app.pessoa_atual()
         OR app.role_atual() IN ('admin','data_steward','preceptor','pesquisador'));
CREATE POLICY pol_tentativa_insercao ON app.tentativa FOR INSERT
  WITH CHECK (pessoa_id = app.pessoa_atual());
CREATE POLICY pol_tentativa_atualizacao ON app.tentativa FOR UPDATE
  USING (pessoa_id = app.pessoa_atual())
  WITH CHECK (pessoa_id = app.pessoa_atual());

DROP POLICY IF EXISTS pol_resposta_leitura ON app.resposta;
DROP POLICY IF EXISTS pol_resposta_insercao ON app.resposta;
CREATE POLICY pol_resposta_leitura ON app.resposta FOR SELECT
  USING (app.role_atual() IN ('admin','data_steward','pesquisador')
         OR tentativa_id IN (SELECT t.tentativa_id FROM app.tentativa t
                              WHERE t.pessoa_id = app.pessoa_atual()));
CREATE POLICY pol_resposta_insercao ON app.resposta FOR INSERT
  WITH CHECK (tentativa_id IN (SELECT t.tentativa_id FROM app.tentativa t
                                WHERE t.pessoa_id = app.pessoa_atual()));

DROP POLICY IF EXISTS pol_participante_leitura ON pesquisa.participante;
CREATE POLICY pol_participante_leitura ON pesquisa.participante FOR SELECT
  USING (pessoa_id = app.pessoa_atual()
         OR app.role_atual() IN ('admin','data_steward','pesquisador'));

DROP POLICY IF EXISTS pol_resposta_participante_insercao ON pesquisa.resposta_participante;
CREATE POLICY pol_resposta_participante_insercao ON pesquisa.resposta_participante FOR INSERT
  WITH CHECK (participante_id IN (SELECT p.participante_id FROM pesquisa.participante p
                                   WHERE p.pessoa_id = app.pessoa_atual()));

DROP POLICY IF EXISTS pol_artefato_leitura ON conteudo.artefato;
CREATE POLICY pol_artefato_leitura ON conteudo.artefato FOR SELECT
  USING (status = 'publicado'
         OR app.role_atual() IN ('admin','data_steward','curador','preceptor'));

DROP POLICY IF EXISTS pol_fonte_leitura ON conteudo.fonte;
CREATE POLICY pol_fonte_leitura ON conteudo.fonte FOR SELECT
  USING (app.role_atual() <> 'anonimo');

-- Auditoria: so insercao (sem UPDATE/DELETE para nenhum papel)
DROP POLICY IF EXISTS pol_auditoria_insercao ON ops.auditoria;
CREATE POLICY pol_auditoria_insercao ON ops.auditoria FOR INSERT
  TO api_rw, maestro_rw WITH CHECK (true);
REVOKE UPDATE, DELETE, TRUNCATE ON ops.auditoria FROM api_rw, maestro_rw;

-- Papel do executor (maestro_rw): politicas proprias, pois ele nao tem
-- app.role. So atua em job, artefato e fonte.
DROP POLICY IF EXISTS pol_maestro_job ON maestro.job;
CREATE POLICY pol_maestro_job ON maestro.job FOR ALL TO maestro_rw
  USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS pol_maestro_artefato ON conteudo.artefato;
CREATE POLICY pol_maestro_artefato ON conteudo.artefato FOR ALL TO maestro_rw
  USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS pol_maestro_fonte ON conteudo.fonte;
CREATE POLICY pol_maestro_fonte ON conteudo.fonte FOR ALL TO maestro_rw
  USING (true) WITH CHECK (true);

COMMIT;

\echo '=== CORRECOES DE SEGURANCA CONCLUIDAS ==='
