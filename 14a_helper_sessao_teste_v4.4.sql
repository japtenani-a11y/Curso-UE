linha_sql	
	
-- ============================================================	
-- 14a_helper_sessao_teste_v4.4.sql	
-- Sistema de Producao Curricular e Coleta Cientifica	
-- Programa de Cirurgia de Urgencia e Trauma	
-- Versao 4.4 / 10-11-2026	
--	
-- OBJETIVO: criar a funcao fn_sessao_teste, que emite um token	
-- de sessao para qualquer e-mail cadastrado. Serve para o	
-- roteiro de aceitacao autenticar sem OAuth.	
--	
-- PRE-REQUISITO: 03_setup_minimo_v4.3.	
--	
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 14a_helper_sessao_teste_v4.4.sql	
--	
-- ATENCAO: funcao de teste. Nao usar em producao. Em producao,	
-- a sessao e emitida pelo fluxo OAuth com state e PKCE.	
-- ============================================================	
	
\set ON_ERROR_STOP on	
\echo '=== HELPER SESSAO TESTE v4.4 ==='	
	
BEGIN	
	
CREATE OR REPLACE FUNCTION app.fn_sessao_teste(p_email TEXT)	
RETURNS TEXT	
LANGUAGE plpgsql	
SECURITY DEFINER	
AS $$	
DECLARE	
  v_pessoa_id BIGINT	
  v_token TEXT	
BEGIN	
  SELECT pessoa_id INTO v_pessoa_id	
    FROM app.pessoa	
   WHERE email_primario = p_email	
	
  IF v_pessoa_id IS NULL THEN	
    RAISE EXCEPTION 'pessoa nao encontrada: %', p_email USING ERRCODE = '23503';	
  END IF	
	
  v_token := encode(gen_random_bytes(32), 'hex');	
	
  INSERT INTO app.sessao (pessoa_id, token_hash, expira_em, ip_origem, user_agent)	
  VALUES (v_pessoa_id,	
          encode(digest(v_token, 'sha256'), 'hex'),	
          now() + interval '24 hours',	
          '127.0.0.1'::inet,	
          'fn_sessao_teste')	
	
  RETURN v_token	
END $$	
	
COMMENT ON FUNCTION app.fn_sessao_teste(TEXT) IS	
  'Emite token de sessao para um e-mail cadastrado. Uso exclusivo em teste.'	
	
GRANT EXECUTE ON FUNCTION app.fn_sessao_teste(TEXT) TO api_rw	
	
-- VALIDACAO	
\echo '--- Validacao ---'	
	
DO $$	
DECLARE	
  v_token TEXT	
BEGIN	
  v_token := app.fn_sessao_teste('r1.teste@setup.local')	
  IF v_token IS NULL OR length(v_token) < 32 THEN	
    RAISE EXCEPTION 'fn_sessao_teste retornou token invalido'	
  END IF	
  RAISE NOTICE 'fn_sessao_teste OK: token de % caracteres', length(v_token);	
END $$	
	
SELECT 'sessoes ativas: ' || count(*) FROM app.sessao WHERE revogada_em IS NULL	
	
\echo '=== HELPER SESSAO TESTE CONCLUIDO ==='	
	
COMMIT	
