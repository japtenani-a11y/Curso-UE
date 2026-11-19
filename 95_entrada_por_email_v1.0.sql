-- ============================================================
-- 95_entrada_por_email_v1.0.sql
-- OBJETIVO: entrar e se inscrever no CUT sem conta Google, por um link enviado ao e-mail (sem senha).
--   1. A pessoa digita o e-mail na tela de entrada. O banco gera um link de uso único, válido por 20 minutos.
--      Só gera se o e-mail já estiver cadastrado ou se as inscrições estiverem abertas (a mesma regra do Google).
--   2. A API envia o link por e-mail. A resposta para a tela é sempre a mesma, para não revelar quem está cadastrado.
--   3. Ao abrir o link e tocar em "Entrar", o banco confere o link, marca como usado, cria a pessoa e a ficha de
--      inscrição se for o primeiro acesso, e abre a sessão. Daí em diante, o caminho é o mesmo do Google: ficha,
--      termos e aprovação da coordenação.
-- Guarda só o resumo (sha256) do link, nunca o link. Limites: 3 pedidos por e-mail a cada 15 minutos e 20 por
-- endereço de rede por hora.
-- Pode ser rodado mais de uma vez.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.link_entrada (
  link_id     BIGSERIAL PRIMARY KEY,
  email       TEXT NOT NULL,
  token_hash  TEXT NOT NULL UNIQUE,
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  expira_em   TIMESTAMPTZ NOT NULL,
  usado_em    TIMESTAMPTZ,
  ip_pedido   INET,
  ip_uso      INET
);
CREATE INDEX IF NOT EXISTS ix_link_entrada_email ON app.link_entrada (lower(email), criado_em DESC);
CREATE INDEX IF NOT EXISTS ix_link_entrada_ip ON app.link_entrada (ip_pedido, criado_em DESC);
ALTER TABLE app.link_entrada ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON app.link_entrada FROM PUBLIC;

-- Pede um link. Devolve o link (texto) para a API enviar, ou NULL quando não deve enviar
-- (e-mail inválido, limite atingido, ou e-mail não cadastrado com inscrições fechadas).
CREATE OR REPLACE FUNCTION app.fn_pedir_link_entrada(p_email TEXT, p_ip INET)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_email TEXT := lower(trim(coalesce(p_email, ''))); v_token TEXT;
BEGIN
  IF length(v_email) > 254 OR v_email !~ '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$' THEN RETURN NULL; END IF;
  -- limpeza dos links vencidos há mais de 7 dias
  DELETE FROM app.link_entrada WHERE expira_em < now() - interval '7 days';
  IF (SELECT count(*) FROM app.link_entrada WHERE lower(email) = v_email AND criado_em > now() - interval '15 minutes') >= 3 THEN RETURN NULL; END IF;
  IF p_ip IS NOT NULL AND (SELECT count(*) FROM app.link_entrada WHERE ip_pedido = p_ip AND criado_em > now() - interval '1 hour') >= 20 THEN RETURN NULL; END IF;
  IF NOT EXISTS (SELECT 1 FROM app.pessoa WHERE lower(email_primario::text) = v_email)
     AND coalesce((SELECT valor FROM app.config_curso WHERE chave = 'inscricao_aberta'), 'nao') <> 'sim' THEN
    RETURN NULL;
  END IF;
  v_token := encode(gen_random_bytes(32), 'hex');
  INSERT INTO app.link_entrada (email, token_hash, expira_em, ip_pedido)
  VALUES (v_email, encode(digest(v_token, 'sha256'), 'hex'), now() + interval '20 minutes', p_ip);
  RETURN v_token;
END $$;

-- Usa o link: confere, marca como usado e abre a sessão (criando a pessoa no primeiro acesso, se as inscrições
-- estiverem abertas). Devolve o token da sessão, ou NULL se o link não vale mais.
CREATE OR REPLACE FUNCTION app.fn_sessao_link_entrada(p_token TEXT, p_ip INET, p_ua TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_link app.link_entrada;
BEGIN
  IF coalesce(p_token, '') !~ '^[0-9a-f]{64}$' THEN RETURN NULL; END IF;
  UPDATE app.link_entrada SET usado_em = now(), ip_uso = p_ip
   WHERE token_hash = encode(digest(p_token, 'sha256'), 'hex') AND usado_em IS NULL AND expira_em > now()
  RETURNING * INTO v_link;
  IF NOT FOUND THEN RETURN NULL; END IF;
  -- mesmo caminho da entrada pelo Google: cria a pessoa e a ficha no primeiro acesso (inscrições abertas)
  -- sem nome conhecido (o Google traz o nome; o e-mail, nao): a ficha de inscricao pede o nome completo
  RETURN app.fn_sessao_google_inscricao(v_link.email, '', p_ip, p_ua);
END $$;

REVOKE EXECUTE ON FUNCTION app.fn_pedir_link_entrada(TEXT, INET) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION app.fn_sessao_link_entrada(TEXT, INET, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.fn_pedir_link_entrada(TEXT, INET) TO api_rw;
GRANT EXECUTE ON FUNCTION app.fn_sessao_link_entrada(TEXT, INET, TEXT) TO api_rw;

COMMIT;
SELECT 'entrada por e-mail (95): pronto' AS situacao;
