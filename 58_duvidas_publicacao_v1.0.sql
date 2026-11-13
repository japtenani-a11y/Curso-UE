-- 58_duvidas_publicacao_v1.0.sql
-- (1) Duvidas dos alunos respondidas pela coordenacao (sem IA):
--     - cada duvida nova vai por e-mail para os curadores e o coordenador (papel admin/curador vigente);
--     - quem tem papel de revisor responde na tela "Duvidas dos alunos"; o aluno ve a resposta no aplicativo
--       e recebe e-mail se autorizou lembretes por e-mail.
-- (2) Publicacao com aprovacao de 1 revisor: a peca e publicada quando todas as afirmacoes tem parecer de
--     pelo menos um revisor, nenhuma tem erro critico e os erros leves nao passam de 5%
--     (peca sem afirmacoes: basta um parecer geral "correto"). Quem publica e um revisor.
--     A versao publicada anterior do mesmo tipo vai para "arquivado".
-- Pre-requisito: 32, 45 e 55. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) duvidas ----------
ALTER TABLE app.mensagem_aluno ADD COLUMN IF NOT EXISTS resposta TEXT CHECK (length(resposta) <= 8000);
ALTER TABLE app.mensagem_aluno ADD COLUMN IF NOT EXISTS respondida_por BIGINT REFERENCES app.pessoa(pessoa_id);

ALTER TABLE app.notificacao_saida ALTER COLUMN lembrete_id DROP NOT NULL;
ALTER TABLE app.notificacao_saida ADD COLUMN IF NOT EXISTS mensagem_id BIGINT REFERENCES app.mensagem_aluno(mensagem_id) ON DELETE CASCADE;
CREATE UNIQUE INDEX IF NOT EXISTS uq_notif_mensagem ON app.notificacao_saida (mensagem_id, canal, destino) WHERE mensagem_id IS NOT NULL;

CREATE OR REPLACE FUNCTION app.eh_revisor() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT EXISTS (SELECT 1 FROM app.designacao d
                  WHERE d.pessoa_id = app.pessoa_atual() AND d.papel IN ('admin','curador','data_steward')
                    AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)) $$;

-- Nova duvida: e-mail para cada curador e coordenador.
CREATE OR REPLACE FUNCTION app.fn_duvida_avisar_curadores() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NEW.tipo <> 'duvida' THEN RETURN NEW; END IF;
  INSERT INTO app.notificacao_saida (mensagem_id, pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT NEW.mensagem_id, d.pessoa_id, 'email', p.email_primario::text,
         'Nova dúvida de aluno' || coalesce(' — ' || t.codigo, ''),
         'Um aluno enviou uma dúvida' || coalesce(' sobre ' || t.codigo || ' (' || t.titulo || ')', '')
           || coalesce(', na peça "' || NEW.ferramenta || '"', '') || E':\n\n' || NEW.texto
           || E'\n\nResponda pelo aplicativo, na tela Dúvidas dos alunos.',
         jsonb_build_object('caminho', '/curador/duvidas', 'rotulo_link', 'Responder no aplicativo',
                            'rodape', 'Você recebe este aviso por ser curador ou coordenador do Programa de Cirurgia de Urgência e Trauma.')
    FROM app.designacao d JOIN app.pessoa p ON p.pessoa_id = d.pessoa_id
    LEFT JOIN app.tema t ON t.tema_id = NEW.tema_id
   WHERE d.papel IN ('admin','curador') AND d.vigencia_inicio <= current_date
     AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_duvida_avisar ON app.mensagem_aluno;
CREATE TRIGGER tg_duvida_avisar AFTER INSERT ON app.mensagem_aluno FOR EACH ROW EXECUTE FUNCTION app.fn_duvida_avisar_curadores();

-- Lista para os revisores (todas as duvidas, mais recentes primeiro).
CREATE OR REPLACE FUNCTION app.duvidas_para_curadoria(p_so_pendentes BOOLEAN DEFAULT true)
RETURNS TABLE (mensagem_id BIGINT, aluno TEXT, ano TEXT, tema TEXT, ferramenta TEXT, texto TEXT, criado_em TIMESTAMPTZ,
               resposta TEXT, respondida_em TIMESTAMPTZ, respondida_por TEXT, util BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT m.mensagem_id, p.nome_completo, (SELECT x.grau::text FROM app.posicao_anual x WHERE x.pessoa_id = m.pessoa_id AND x.ativo ORDER BY x.ano_letivo DESC LIMIT 1),
         t.codigo, m.ferramenta, m.texto, m.criado_em, m.resposta, m.respondida_em, r.nome_completo, m.util
    FROM app.mensagem_aluno m JOIN app.pessoa p ON p.pessoa_id = m.pessoa_id
    LEFT JOIN app.tema t ON t.tema_id = m.tema_id LEFT JOIN app.pessoa r ON r.pessoa_id = m.respondida_por
   WHERE app.eh_revisor() AND m.tipo = 'duvida' AND (NOT p_so_pendentes OR m.resposta IS NULL)
   ORDER BY m.criado_em DESC LIMIT 500 $$;

-- Resposta da coordenacao: grava, avisa o aluno no aplicativo e, se ele autorizou, por e-mail.
CREATE OR REPLACE FUNCTION app.responder_duvida(p_id BIGINT, p_resposta TEXT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  IF length(trim(coalesce(p_resposta, ''))) < 3 THEN RAISE EXCEPTION 'resposta_curta'; END IF;
  UPDATE app.mensagem_aluno SET resposta = left(p_resposta, 8000), respondida_por = app.pessoa_atual(),
         respondida_em = now(), status = 'respondida'
   WHERE mensagem_id = p_id AND tipo = 'duvida';
  IF NOT FOUND THEN RAISE EXCEPTION 'duvida_nao_encontrada'; END IF;
  INSERT INTO app.notificacao_saida (mensagem_id, pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT m.mensagem_id, m.pessoa_id, 'email', coalesce(c.email_aviso, p.email_primario::text),
         'Sua dúvida foi respondida' || coalesce(' — ' || t.codigo, ''),
         E'Sua pergunta:\n' || m.texto || E'\n\nResposta da coordenação:\n' || m.resposta,
         jsonb_build_object('caminho', '/aluno/duvidas', 'rotulo_link', 'Ver no aplicativo')
    FROM app.mensagem_aluno m JOIN app.pessoa p ON p.pessoa_id = m.pessoa_id
    JOIN app.contato_aluno c ON c.pessoa_id = m.pessoa_id AND c.aceita_email
    LEFT JOIN app.tema t ON t.tema_id = m.tema_id
   WHERE m.mensagem_id = p_id
  ON CONFLICT DO NOTHING;
END $$;
REVOKE EXECUTE ON FUNCTION app.duvidas_para_curadoria(BOOLEAN), app.responder_duvida(BIGINT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.eh_revisor(), app.duvidas_para_curadoria(BOOLEAN), app.responder_duvida(BIGINT, TEXT) TO api_rw;

-- A resposta da IA nao e mais usada: as funcoes do respondedor deixam de existir.
DROP FUNCTION IF EXISTS app.duvidas_reservar(INT);
DROP FUNCTION IF EXISTS app.duvida_responder(BIGINT, TEXT, TEXT, BOOLEAN);
UPDATE app.mensagem_aluno SET status = 'nova' WHERE tipo = 'duvida' AND status IN ('respondendo','erro') AND resposta IS NULL;

DROP VIEW IF EXISTS pesquisa.vw_estudo_mensagens;
CREATE VIEW pesquisa.vw_estudo_mensagens AS
  SELECT pesquisa.codigo_participante(m.pessoa_id) AS participante, t.codigo AS tema, m.ferramenta, m.tipo,
         m.texto, m.resposta, m.util, m.criado_em, m.respondida_em
    FROM app.mensagem_aluno m LEFT JOIN app.tema t ON t.tema_id = m.tema_id
    JOIN app.consentimento_pesquisa c ON c.pessoa_id = m.pessoa_id AND c.aceito;

-- ---------- (2) publicacao com 1 revisor ----------
CREATE OR REPLACE FUNCTION app.situacao_revisao(p_artefato BIGINT)
RETURNS TABLE (total INT, revisadas INT, leves INT, criticos INT, geral_ok BOOLEAN, pode_publicar BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH af AS (SELECT f.codigo FROM conteudo.afirmacao f WHERE f.artefato_id = p_artefato),
  pior AS (
    SELECT af.codigo,
           max(CASE pr.decisao WHEN 'erro_critico' THEN 3 WHEN 'erro_leve' THEN 2 WHEN 'correto' THEN 1 END) AS g
      FROM af LEFT JOIN conteudo.parecer_revisao pr ON pr.artefato_id = p_artefato AND pr.afirmacao_codigo = af.codigo
     GROUP BY af.codigo),
  geral AS (
    SELECT bool_and(pr.decisao = 'correto') AS ok, count(*) AS n
      FROM conteudo.parecer_revisao pr WHERE pr.artefato_id = p_artefato AND coalesce(pr.afirmacao_codigo, '') = '')
  SELECT (SELECT count(*) FROM pior)::int,
         (SELECT count(*) FROM pior WHERE g IS NOT NULL)::int,
         (SELECT count(*) FROM pior WHERE g = 2)::int,
         (SELECT count(*) FROM pior WHERE g = 3)::int,
         coalesce((SELECT ok FROM geral WHERE n > 0), false),
         CASE WHEN (SELECT count(*) FROM pior) = 0
              THEN coalesce((SELECT ok FROM geral WHERE n > 0), false)
              ELSE (SELECT count(*) FROM pior WHERE g IS NULL) = 0
                   AND (SELECT count(*) FROM pior WHERE g = 3) = 0
                   AND (SELECT count(*) FROM pior WHERE g = 2) <= 0.05 * (SELECT count(*) FROM pior)
                   AND coalesce((SELECT bool_and(pr.decisao <> 'erro_critico') FROM conteudo.parecer_revisao pr
                                  WHERE pr.artefato_id = p_artefato AND coalesce(pr.afirmacao_codigo, '') = ''), true)
         END $$;

CREATE OR REPLACE FUNCTION app.publicar_artefato(p_artefato BIGINT) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE v_tema BIGINT; v_tipo TEXT; v_status TEXT; v_ok BOOLEAN;
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  SELECT a.tema_id, a.tipo, a.status::text INTO v_tema, v_tipo, v_status FROM conteudo.artefato a WHERE a.artefato_id = p_artefato;
  IF v_tema IS NULL THEN RAISE EXCEPTION 'artefato_nao_encontrado'; END IF;
  IF v_status <> 'rascunho' THEN RAISE EXCEPTION 'artefato_nao_e_rascunho'; END IF;
  SELECT s.pode_publicar INTO v_ok FROM app.situacao_revisao(p_artefato) s;
  IF NOT v_ok THEN RAISE EXCEPTION 'revisao_incompleta_ou_fora_da_tolerancia'; END IF;
  UPDATE conteudo.artefato SET status = 'arquivado'
   WHERE tema_id = v_tema AND tipo = v_tipo AND status = 'publicado';
  UPDATE conteudo.artefato SET checklist_conforme = true, revisado_em = now(), status = 'publicado'
   WHERE artefato_id = p_artefato;
  RETURN 'publicado';
END $$;
REVOKE EXECUTE ON FUNCTION app.publicar_artefato(BIGINT), app.situacao_revisao(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.publicar_artefato(BIGINT), app.situacao_revisao(BIGINT) TO api_rw;

COMMIT;
\echo 'duvidas pela coordenacao e publicacao com 1 revisor: prontas'
