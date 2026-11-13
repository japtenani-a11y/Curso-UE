-- 45_notificacoes_v1.0.sql
-- Envio dos lembretes tambem por e-mail e WhatsApp, alem do aviso no aplicativo.
--  (1) app.contato_aluno: e-mail de aviso, WhatsApp (formato internacional, +55...) e o consentimento
--      de cada canal (LGPD: o aluno escolhe; sem consentimento, nao se envia nada por aquele canal).
--  (2) app.notificacao_saida: fila de envio. Cada lembrete gera no maximo uma mensagem por canal.
--  (3) Funcoes para o enviador (api/src/notificador.ts), que roda a cada poucos minutos:
--      app.enfileirar_notificacoes()            abre/fecha ondas, gera lembretes e poe na fila
--      app.notificacoes_reservar(canais, n)     pega ate n mensagens pendentes dos canais configurados
--      app.notificacao_resultado(id, ok, erro)  registra o resultado do envio (ate 5 tentativas)
-- Credenciais (SMTP e WhatsApp) ficam so em variaveis de ambiente, nunca no banco nem no repositorio.
-- Pre-requisito: 43. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.contato_aluno (
  pessoa_id          BIGINT PRIMARY KEY REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  email_aviso        TEXT CHECK (email_aviso IS NULL OR email_aviso ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  whatsapp           TEXT CHECK (whatsapp IS NULL OR whatsapp ~ '^\+[1-9][0-9]{9,14}$'),
  aceita_email       BOOLEAN NOT NULL DEFAULT false,
  aceita_whatsapp    BOOLEAN NOT NULL DEFAULT false,
  consentimento_em   TIMESTAMPTZ,
  versao_termo       TEXT,
  atualizado_em      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (NOT aceita_whatsapp OR whatsapp IS NOT NULL));
ALTER TABLE app.contato_aluno ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_contato_proprio ON app.contato_aluno;
CREATE POLICY pol_contato_proprio ON app.contato_aluno FOR ALL TO api_rw
  USING (pessoa_id = app.pessoa_atual()) WITH CHECK (pessoa_id = app.pessoa_atual());
GRANT SELECT, INSERT, UPDATE ON app.contato_aluno TO api_rw;

CREATE TABLE IF NOT EXISTS app.notificacao_saida (
  notificacao_id BIGSERIAL PRIMARY KEY,
  lembrete_id    BIGINT NOT NULL REFERENCES app.lembrete(lembrete_id) ON DELETE CASCADE,
  pessoa_id      BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  canal          TEXT NOT NULL CHECK (canal IN ('email','whatsapp')),
  destino        TEXT NOT NULL,
  assunto        TEXT NOT NULL,
  corpo          TEXT NOT NULL,
  parametros     JSONB NOT NULL DEFAULT '{}'::jsonb,
  status         TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente','enviando','enviada','simulada','erro','cancelada')),
  tentativas     SMALLINT NOT NULL DEFAULT 0,
  ultimo_erro    TEXT,
  criado_em      TIMESTAMPTZ NOT NULL DEFAULT now(),
  reservado_em   TIMESTAMPTZ,
  enviado_em     TIMESTAMPTZ,
  UNIQUE (lembrete_id, canal));
-- Sem acesso direto pela API: so pelas funcoes abaixo.
ALTER TABLE app.notificacao_saida ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON app.notificacao_saida FROM PUBLIC;

-- Texto da mensagem de um lembrete.
CREATE OR REPLACE FUNCTION app.texto_lembrete(p_lembrete BIGINT)
RETURNS TABLE (assunto TEXT, corpo TEXT, parametros JSONB)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT
    CASE WHEN l.dias_apos = -1 THEN 'Prazo do ' || n.nome || ' de ' || t.codigo || ' termina em breve'
         ELSE n.nome || ' de ' || t.codigo || ' pendente' END,
    CASE WHEN l.dias_apos = -1
         THEN 'O ' || n.nome || ' de ' || t.codigo || ' (' || t.titulo || ') fecha em '
              || to_char(o.data_fechamento AT TIME ZONE 'America/Sao_Paulo', 'DD/MM "às" HH24:MI')
              || ', 1 hora antes da aula. Leva de 10 a 15 minutos.'
         ELSE 'O ' || n.nome || ' de ' || t.codigo || ' (' || t.titulo || ') está pendente há '
              || l.dias_apos || ' dias. Leva de 10 a 15 minutos.' END,
    jsonb_build_object('nome', p.nome_completo, 'teste', n.nome, 'tema', t.codigo, 'titulo', t.titulo,
                       'dias_apos', l.dias_apos,
                       'prazo', to_char(o.data_fechamento AT TIME ZONE 'America/Sao_Paulo', 'DD/MM HH24:MI'),
                       'caminho', '/aluno/testes/' || replace(t.codigo, '-', ''))
    FROM app.lembrete l
    JOIN app.pessoa p ON p.pessoa_id = l.pessoa_id
    JOIN app.onda_instancia o ON o.onda_id = l.onda_id
    JOIN app.tema t ON t.tema_id = o.tema_id
    JOIN (VALUES (1,'pré-teste inicial'),(2,'pré-teste 2'),(3,'pós-teste D0'),(4,'pós-teste D+15'),
                 (5,'pós-teste D+45'),(6,'pós-teste D+90')) n(num, nome) ON n.num = o.teste_num
   WHERE l.lembrete_id = p_lembrete $$;

-- Gera lembretes de todos e poe na fila as mensagens dos canais que cada aluno aceitou.
CREATE OR REPLACE FUNCTION app.enfileirar_notificacoes() RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v INT;
BEGIN
  PERFORM app.abrir_ondas_do_dia();
  PERFORM app.gerar_lembretes();
  INSERT INTO app.notificacao_saida (lembrete_id, pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT l.lembrete_id, l.pessoa_id, c.canal, c.destino, x.assunto, x.corpo, x.parametros
    FROM app.lembrete l
    JOIN app.onda_instancia o ON o.onda_id = l.onda_id
    JOIN app.contato_aluno ca ON ca.pessoa_id = l.pessoa_id
    JOIN app.pessoa p ON p.pessoa_id = l.pessoa_id
    CROSS JOIN LATERAL (VALUES
        ('email',    CASE WHEN ca.aceita_email THEN coalesce(ca.email_aviso, p.email_primario::text) END),
        ('whatsapp', CASE WHEN ca.aceita_whatsapp THEN ca.whatsapp END)) c(canal, destino)
    CROSS JOIN LATERAL app.texto_lembrete(l.lembrete_id) x
   WHERE c.destino IS NOT NULL
     AND l.lido_em IS NULL
     AND NOT app.teste_submetido(l.pessoa_id, o.tema_id, o.teste_num)
     AND (l.dias_apos <> -1 OR now() < o.data_fechamento)
  ON CONFLICT (lembrete_id, canal) DO NOTHING;
  GET DIAGNOSTICS v = ROW_COUNT;
  -- quem respondeu o teste, ou retirou o consentimento, nao recebe o que ainda estava na fila
  UPDATE app.notificacao_saida s SET status = 'cancelada', ultimo_erro = 'teste respondido, prazo vencido ou consentimento retirado'
    FROM app.lembrete l JOIN app.onda_instancia o ON o.onda_id = l.onda_id
   WHERE s.lembrete_id = l.lembrete_id AND s.status IN ('pendente','erro')
     AND (app.teste_submetido(l.pessoa_id, o.tema_id, o.teste_num)
          OR (l.dias_apos = -1 AND now() >= o.data_fechamento)
          OR NOT EXISTS (SELECT 1 FROM app.contato_aluno ca WHERE ca.pessoa_id = s.pessoa_id
                          AND ((s.canal = 'email' AND ca.aceita_email) OR (s.canal = 'whatsapp' AND ca.aceita_whatsapp))));
  RETURN v;
END $$;

-- Reserva mensagens para envio (sem duplicar se houver dois enviadores rodando).
CREATE OR REPLACE FUNCTION app.notificacoes_reservar(p_canais TEXT[], p_max INT DEFAULT 50)
RETURNS TABLE (notificacao_id BIGINT, canal TEXT, destino TEXT, assunto TEXT, corpo TEXT, parametros JSONB)
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH r AS (
    SELECT s.notificacao_id FROM app.notificacao_saida s
     WHERE s.canal = ANY (p_canais)
       AND (s.status = 'pendente'
            OR (s.status = 'erro' AND s.tentativas < 5)
            OR (s.status = 'enviando' AND s.reservado_em < now() - interval '15 minutes'))
     ORDER BY s.criado_em LIMIT p_max FOR UPDATE SKIP LOCKED)
  UPDATE app.notificacao_saida s SET status = 'enviando', reservado_em = now(), tentativas = s.tentativas + 1
    FROM r WHERE s.notificacao_id = r.notificacao_id
  RETURNING s.notificacao_id, s.canal, s.destino, s.assunto, s.corpo, s.parametros $$;

-- Resultado do envio: p_situacao = 'enviada', 'simulada' ou 'erro'.
CREATE OR REPLACE FUNCTION app.notificacao_resultado(p_id BIGINT, p_situacao TEXT, p_erro TEXT DEFAULT NULL) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  UPDATE app.notificacao_saida
     SET status = CASE WHEN p_situacao IN ('enviada','simulada','erro') THEN p_situacao ELSE 'erro' END,
         ultimo_erro = left(p_erro, 500),
         enviado_em = CASE WHEN p_situacao IN ('enviada','simulada') THEN now() ELSE enviado_em END
   WHERE notificacao_id = p_id $$;

-- Resumo da fila para o curador / suporte.
CREATE OR REPLACE VIEW app.vw_notificacoes_resumo AS
  SELECT canal, status, count(*) AS mensagens, max(criado_em) AS ultima
    FROM app.notificacao_saida GROUP BY canal, status;

REVOKE EXECUTE ON FUNCTION app.texto_lembrete(BIGINT), app.enfileirar_notificacoes(),
  app.notificacoes_reservar(TEXT[], INT), app.notificacao_resultado(BIGINT, TEXT, TEXT) FROM PUBLIC;
-- O enviador roda no servidor com a mesma conexao da API (api_rw); nenhuma rota HTTP chama estas funcoes.
GRANT EXECUTE ON FUNCTION app.enfileirar_notificacoes(), app.notificacoes_reservar(TEXT[], INT),
  app.notificacao_resultado(BIGINT, TEXT, TEXT) TO api_rw;

COMMIT;
\echo 'notificacoes por e-mail e WhatsApp: tabelas e funcoes prontas'
