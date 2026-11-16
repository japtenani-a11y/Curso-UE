-- 78_perfis_v1.0.sql
-- Perfis por sessao e funcoes da equipe.
--  (1) Quem tem mais de uma funcao (ex.: admin + curador + preceptor) escolhe, ao entrar, com qual perfil quer usar
--      o aplicativo, e pode trocar depois em "Meu perfil". Toda pessoa da equipe pode tambem ver o aplicativo como
--      aluno; o administrador pode usar qualquer perfil. Fora isso, so aparecem as funcoes que a pessoa tem:
--      trocar de perfil nunca da acesso a mais do que ela ja tem.
--  (2) O administrador atribui e encerra funcoes de outras pessoas (curador, preceptor, pesquisador, responsavel
--      pelos dados, administrador). Encerrar nao apaga: a designacao ganha data de fim e fica no historico.
-- Pre-requisito: 02 (sessao, designacao), 62. Pode ser rodado mais de uma vez.
-- DESFAZER: ALTER TABLE app.sessao DROP COLUMN papel_ativo; e rodar de novo o script que criou fn_identificar_sessao.
\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE app.sessao ADD COLUMN IF NOT EXISTS papel_ativo TEXT;

-- Funcoes vigentes da pessoa, na ordem de prioridade, mais "aluno" para quem e da equipe (visualizar como aluno).
CREATE OR REPLACE FUNCTION app.papeis_da_pessoa(p_pessoa BIGINT) RETURNS TEXT[]
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH d AS (
    SELECT DISTINCT d.papel FROM app.designacao d
     WHERE d.pessoa_id = p_pessoa AND d.vigencia_inicio <= current_date
       AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date))
  SELECT CASE WHEN count(*) = 0 THEN ARRAY['aluno']
              -- o administrador pode ver o aplicativo com qualquer perfil, sem precisar atribuir cada funcao a si mesmo
              WHEN bool_or(papel = 'admin') THEN ARRAY['admin','curador','docente','pesquisador','data_steward','aluno']
              ELSE array_agg(papel ORDER BY array_position(ARRAY['admin','curador','data_steward','docente','pesquisador'], papel)) || ARRAY['aluno'] END
    FROM d $$;

-- Sessao: o papel escolhido vale enquanto a pessoa ainda tiver aquela funcao; sem escolha, vale a regra antiga
-- (a designacao mais recente; sem designacao, aluno).
CREATE OR REPLACE FUNCTION app.fn_identificar_sessao(p_token TEXT)
RETURNS TABLE (pessoa_id BIGINT, nome_completo TEXT, email_primario TEXT, papel TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT p.pessoa_id,
         p.nome_completo,
         p.email_primario::text,
         CASE WHEN s.papel_ativo IS NOT NULL AND s.papel_ativo = ANY (app.papeis_da_pessoa(p.pessoa_id)) THEN s.papel_ativo
              ELSE coalesce((SELECT d.papel
                               FROM app.designacao d
                              WHERE d.pessoa_id = p.pessoa_id
                                AND d.vigencia_inicio <= current_date
                                AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)
                              ORDER BY d.vigencia_inicio DESC LIMIT 1), 'aluno') END
    FROM app.sessao s
    JOIN app.pessoa p ON p.pessoa_id = s.pessoa_id
   WHERE s.token_hash = encode(digest(p_token, 'sha256'), 'hex')
     AND s.revogada_em IS NULL
     AND s.expira_em > now() $$;

-- Perfis da sessao: as funcoes possiveis, a escolhida e se ainda falta escolher (mais de uma e nenhuma escolhida).
CREATE OR REPLACE FUNCTION app.fn_papeis_sessao(p_token TEXT)
RETURNS TABLE (papeis TEXT[], papel_ativo TEXT, escolher BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.papeis_da_pessoa(s.pessoa_id), s.papel_ativo,
         s.papel_ativo IS NULL AND cardinality(app.papeis_da_pessoa(s.pessoa_id)) > 1
    FROM app.sessao s
   WHERE s.token_hash = encode(digest(p_token, 'sha256'), 'hex') AND s.revogada_em IS NULL AND s.expira_em > now() $$;

-- Troca o perfil desta sessao (so para uma funcao que a pessoa tem).
CREATE OR REPLACE FUNCTION app.trocar_papel(p_token TEXT, p_papel TEXT) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_s BIGINT; v_p BIGINT;
BEGIN
  SELECT s.sessao_id, s.pessoa_id INTO v_s, v_p FROM app.sessao s
   WHERE s.token_hash = encode(digest(p_token, 'sha256'), 'hex') AND s.revogada_em IS NULL AND s.expira_em > now();
  IF v_s IS NULL THEN RAISE EXCEPTION 'sessao_invalida' USING ERRCODE = '42501'; END IF;
  IF NOT p_papel = ANY (app.papeis_da_pessoa(v_p)) THEN RAISE EXCEPTION 'papel_nao_atribuido' USING ERRCODE = '42501'; END IF;
  UPDATE app.sessao SET papel_ativo = p_papel WHERE sessao_id = v_s;
  RETURN p_papel;
END $$;

-- ---------- funcoes da equipe (so o administrador, usando o perfil de administrador) ----------
CREATE OR REPLACE FUNCTION app.exigir_admin() RETURNS VOID LANGUAGE plpgsql STABLE AS $$
BEGIN
  IF app.role_atual() <> 'admin' OR NOT 'admin' = ANY (app.papeis_da_pessoa(app.pessoa_atual())) THEN
    RAISE EXCEPTION 'so_administrador' USING ERRCODE = '42501';
  END IF;
END $$;

CREATE OR REPLACE FUNCTION app.funcoes_equipe()
RETURNS TABLE (designacao_id BIGINT, pessoa_id BIGINT, nome TEXT, email TEXT, papel TEXT, desde DATE, atribuido_por TEXT)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  PERFORM app.exigir_admin();
  RETURN QUERY
    SELECT d.designacao_id, p.pessoa_id, p.nome_completo, p.email_primario::text, d.papel, d.vigencia_inicio, a.nome_completo
      FROM app.designacao d JOIN app.pessoa p ON p.pessoa_id = d.pessoa_id
      LEFT JOIN app.pessoa a ON a.pessoa_id = d.aprovador_id
     WHERE d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)
     ORDER BY p.nome_completo, d.papel;
END $$;

-- Busca pessoas ja cadastradas (que entraram ao menos uma vez) por nome ou e-mail.
CREATE OR REPLACE FUNCTION app.buscar_pessoas(p_q TEXT)
RETURNS TABLE (pessoa_id BIGINT, nome TEXT, email TEXT, papeis TEXT[])
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  PERFORM app.exigir_admin();
  IF length(trim(coalesce(p_q, ''))) < 2 THEN RETURN; END IF;
  RETURN QUERY
    SELECT p.pessoa_id, p.nome_completo, p.email_primario::text, app.papeis_da_pessoa(p.pessoa_id)
      FROM app.pessoa p
     WHERE p.nome_completo ILIKE '%' || trim(p_q) || '%' OR p.email_primario::text ILIKE '%' || trim(p_q) || '%'
     ORDER BY p.nome_completo LIMIT 10;
END $$;

CREATE OR REPLACE FUNCTION app.atribuir_funcao(p_pessoa BIGINT, p_papel TEXT) RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v BIGINT;
BEGIN
  PERFORM app.exigir_admin();
  IF p_papel NOT IN ('admin', 'curador', 'docente', 'pesquisador', 'data_steward') THEN RAISE EXCEPTION 'funcao_invalida'; END IF;
  IF NOT EXISTS (SELECT 1 FROM app.pessoa WHERE pessoa_id = p_pessoa) THEN RAISE EXCEPTION 'pessoa_nao_encontrada'; END IF;
  SELECT d.designacao_id INTO v FROM app.designacao d
   WHERE d.pessoa_id = p_pessoa AND d.papel = p_papel AND d.vigencia_inicio <= current_date
     AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date);
  IF v IS NOT NULL THEN RETURN v; END IF;
  INSERT INTO app.designacao (pessoa_id, papel, aprovador_id, vigencia_inicio)
  VALUES (p_pessoa, p_papel, app.pessoa_atual(), current_date) RETURNING designacao_id INTO v;
  RETURN v;
END $$;

-- Encerra (com data de fim) uma funcao; nao deixa o curso sem nenhum administrador.
CREATE OR REPLACE FUNCTION app.encerrar_funcao(p_designacao BIGINT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_papel TEXT;
BEGIN
  PERFORM app.exigir_admin();
  SELECT papel INTO v_papel FROM app.designacao WHERE designacao_id = p_designacao
     AND vigencia_inicio <= current_date AND (vigencia_fim IS NULL OR vigencia_fim >= current_date);
  IF v_papel IS NULL THEN RAISE EXCEPTION 'funcao_nao_encontrada'; END IF;
  IF v_papel = 'admin' AND (SELECT count(DISTINCT pessoa_id) FROM app.designacao WHERE papel = 'admin'
        AND vigencia_inicio <= current_date AND (vigencia_fim IS NULL OR vigencia_fim >= current_date)) <= 1 THEN
    RAISE EXCEPTION 'ultimo_administrador';
  END IF;
  UPDATE app.designacao SET vigencia_fim = current_date - 1 WHERE designacao_id = p_designacao;
END $$;

REVOKE EXECUTE ON FUNCTION app.papeis_da_pessoa(BIGINT), app.fn_papeis_sessao(TEXT), app.trocar_papel(TEXT, TEXT),
  app.funcoes_equipe(), app.buscar_pessoas(TEXT), app.atribuir_funcao(BIGINT, TEXT), app.encerrar_funcao(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.papeis_da_pessoa(BIGINT), app.fn_papeis_sessao(TEXT), app.trocar_papel(TEXT, TEXT),
  app.funcoes_equipe(), app.buscar_pessoas(TEXT), app.atribuir_funcao(BIGINT, TEXT), app.encerrar_funcao(BIGINT), app.exigir_admin() TO api_rw;

COMMIT;
\echo 'perfis por sessao e funcoes da equipe: pronto'
