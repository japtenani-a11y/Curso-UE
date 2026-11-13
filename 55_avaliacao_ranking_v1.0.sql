-- 55_avaliacao_ranking_v1.0.sql
-- Dados para o estudo cientifico e para o aluno acompanhar o proprio desempenho.
--  (1) app.avaliacao: NPS (0 a 10) de cada ferramenta de cada tema e questionario de satisfacao (1 a 5):
--      apresentacao, complexidade, conteudo, objetividade, clareza, tempo gasto, frequencia dos testes
--      e importancia para o aprendizado; mais o tempo que a pessoa diz ter gasto e um comentario.
--      Ferramentas: cada peca do material, cada teste, a reuniao (aula/caso), o aplicativo e o curso.
--  (2) app.mensagem_aluno: duvidas (respondidas pela IA, com base no material do tema, e revisaveis pelo
--      preceptor) e feedback livre. O aluno pode marcar se a resposta foi util.
--  (3) app.uso_material: tempo de leitura de cada peca (o aplicativo registra ao trocar de aba).
--  (4) app.nota_teste: nota de cada teste enviado (acertos, % e nota ponderada pela dificuldade), gravada
--      no envio, imutavel; base do ranking e da pesquisa.
--  (5) Ranking: geral, mesma especialidade, mesmo ano (todas as especialidades) e mesmo subgrupo
--      (ano + especialidade). app.posicao_anual.especialidade guarda a especialidade.
--  (6) pesquisa.vw_estudo_*: visoes pseudonimizadas para analise (codigo do participante no lugar do nome).
--      Uso em pesquisa depende de TCLE e aprovacao do CEP; app.consentimento_pesquisa guarda o aceite.
-- Pre-requisito: 37, 38, 49 e 54. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE app.posicao_anual ADD COLUMN IF NOT EXISTS especialidade TEXT;

-- ---------- (1) avaliacao ----------
CREATE TABLE IF NOT EXISTS app.avaliacao (
  avaliacao_id   BIGSERIAL PRIMARY KEY,
  pessoa_id      BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id        BIGINT REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  ferramenta     TEXT NOT NULL CHECK (ferramenta ~ '^[a-z_0-9]{2,40}$'),
  nps            SMALLINT CHECK (nps BETWEEN 0 AND 10),
  apresentacao   SMALLINT CHECK (apresentacao BETWEEN 1 AND 5),
  complexidade   SMALLINT CHECK (complexidade BETWEEN 1 AND 5),
  conteudo       SMALLINT CHECK (conteudo BETWEEN 1 AND 5),
  objetividade   SMALLINT CHECK (objetividade BETWEEN 1 AND 5),
  clareza        SMALLINT CHECK (clareza BETWEEN 1 AND 5),
  tempo_gasto    SMALLINT CHECK (tempo_gasto BETWEEN 1 AND 5),
  frequencia_testes SMALLINT CHECK (frequencia_testes BETWEEN 1 AND 5),
  importancia    SMALLINT CHECK (importancia BETWEEN 1 AND 5),
  minutos_gastos SMALLINT CHECK (minutos_gastos BETWEEN 0 AND 600),
  comentario     TEXT CHECK (length(comentario) <= 2000),
  criado_em      TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em  TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE UNIQUE INDEX IF NOT EXISTS uq_avaliacao ON app.avaliacao (pessoa_id, coalesce(tema_id, 0), ferramenta);
ALTER TABLE app.avaliacao ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_avaliacao_propria ON app.avaliacao;
CREATE POLICY pol_avaliacao_propria ON app.avaliacao FOR ALL TO api_rw
  USING (pessoa_id = app.pessoa_atual()) WITH CHECK (pessoa_id = app.pessoa_atual());
GRANT SELECT, INSERT, UPDATE ON app.avaliacao TO api_rw;
GRANT USAGE ON SEQUENCE app.avaliacao_avaliacao_id_seq TO api_rw;
COMMENT ON TABLE app.avaliacao IS 'Escala 1-5: apresentacao, conteudo, objetividade, clareza, importancia (1 pessimo, 5 otimo); complexidade, tempo_gasto e frequencia_testes (1 muito baixo/pouco, 3 adequado, 5 muito alto/muito). NPS 0-10.';

-- ---------- (2) duvidas e feedback ----------
CREATE TABLE IF NOT EXISTS app.mensagem_aluno (
  mensagem_id   BIGSERIAL PRIMARY KEY,
  pessoa_id     BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id       BIGINT REFERENCES app.tema(tema_id) ON DELETE SET NULL,
  ferramenta    TEXT CHECK (ferramenta IS NULL OR ferramenta ~ '^[a-z_0-9]{2,40}$'),
  tipo          TEXT NOT NULL CHECK (tipo IN ('duvida','feedback')),
  texto         TEXT NOT NULL CHECK (length(texto) BETWEEN 3 AND 4000),
  status        TEXT NOT NULL DEFAULT 'nova' CHECK (status IN ('nova','respondendo','respondida','erro','registrada')),
  resposta_ia   TEXT,
  modelo_ia     TEXT,
  respondida_em TIMESTAMPTZ,
  util          BOOLEAN,
  revisao_preceptor TEXT,
  revisado_por  BIGINT REFERENCES app.pessoa(pessoa_id),
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS ix_mensagem_status ON app.mensagem_aluno (status, criado_em);
-- Resposta da coordenacao (usada pelo 58); criada aqui tambem para a view de pesquisa abaixo.
ALTER TABLE app.mensagem_aluno ADD COLUMN IF NOT EXISTS resposta TEXT CHECK (length(resposta) <= 8000);
ALTER TABLE app.mensagem_aluno ADD COLUMN IF NOT EXISTS respondida_por BIGINT REFERENCES app.pessoa(pessoa_id);
ALTER TABLE app.mensagem_aluno ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_msg_propria ON app.mensagem_aluno;
CREATE POLICY pol_msg_propria ON app.mensagem_aluno FOR SELECT TO api_rw USING (pessoa_id = app.pessoa_atual());
DROP POLICY IF EXISTS pol_msg_nova ON app.mensagem_aluno;
CREATE POLICY pol_msg_nova ON app.mensagem_aluno FOR INSERT TO api_rw WITH CHECK (pessoa_id = app.pessoa_atual());
DROP POLICY IF EXISTS pol_msg_util ON app.mensagem_aluno;
CREATE POLICY pol_msg_util ON app.mensagem_aluno FOR UPDATE TO api_rw
  USING (pessoa_id = app.pessoa_atual()) WITH CHECK (pessoa_id = app.pessoa_atual());
GRANT SELECT, INSERT ON app.mensagem_aluno TO api_rw;
GRANT UPDATE (util) ON app.mensagem_aluno TO api_rw;
GRANT USAGE ON SEQUENCE app.mensagem_aluno_mensagem_id_seq TO api_rw;

-- Para o respondedor (IA): reserva duvidas novas e devolve o material do tema para fundamentar a resposta.
CREATE OR REPLACE FUNCTION app.duvidas_reservar(p_max INT DEFAULT 5)
RETURNS TABLE (mensagem_id BIGINT, texto TEXT, ferramenta TEXT, tema TEXT, titulo TEXT, material TEXT)
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH r AS (
    SELECT m.mensagem_id FROM app.mensagem_aluno m
     WHERE m.tipo = 'duvida' AND (m.status = 'nova' OR (m.status = 'respondendo' AND m.criado_em < now() - interval '30 minutes'))
     ORDER BY m.criado_em LIMIT p_max FOR UPDATE SKIP LOCKED),
  u AS (UPDATE app.mensagem_aluno m SET status = 'respondendo' FROM r WHERE m.mensagem_id = r.mensagem_id RETURNING m.*)
  SELECT u.mensagem_id, u.texto, u.ferramenta, t.codigo, t.titulo,
         (SELECT string_agg(a.titulo || E'\n' || a.corpo, E'\n\n---\n\n' ORDER BY a.tipo)
            FROM conteudo.artefato a
           WHERE a.tema_id = u.tema_id
             AND a.tipo IN ('sintese_evidencia','resumo','resumo_basico','protocolo','aula','checklist')
             AND a.artefato_id = (SELECT x.artefato_id FROM conteudo.artefato x
                                   WHERE x.tema_id = a.tema_id AND x.tipo = a.tipo AND x.status IN ('publicado','rascunho')
                                   ORDER BY x.versao DESC LIMIT 1))
    FROM u LEFT JOIN app.tema t ON t.tema_id = u.tema_id $$;

CREATE OR REPLACE FUNCTION app.duvida_responder(p_id BIGINT, p_resposta TEXT, p_modelo TEXT, p_ok BOOLEAN) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  UPDATE app.mensagem_aluno
     SET status = CASE WHEN p_ok THEN 'respondida' ELSE 'erro' END,
         resposta_ia = CASE WHEN p_ok THEN left(p_resposta, 8000) ELSE resposta_ia END,
         modelo_ia = p_modelo, respondida_em = CASE WHEN p_ok THEN now() END
   WHERE mensagem_id = p_id $$;
-- Feedback nao vai para a IA: so fica registrado.
CREATE OR REPLACE FUNCTION app.fn_feedback_registrado() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN IF NEW.tipo = 'feedback' THEN NEW.status := 'registrada'; END IF; RETURN NEW; END $$;
DROP TRIGGER IF EXISTS tg_feedback_registrado ON app.mensagem_aluno;
CREATE TRIGGER tg_feedback_registrado BEFORE INSERT ON app.mensagem_aluno FOR EACH ROW EXECUTE FUNCTION app.fn_feedback_registrado();
REVOKE EXECUTE ON FUNCTION app.duvidas_reservar(INT), app.duvida_responder(BIGINT,TEXT,TEXT,BOOLEAN) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.duvidas_reservar(INT), app.duvida_responder(BIGINT,TEXT,TEXT,BOOLEAN) TO api_rw;

-- ---------- (3) uso do material ----------
CREATE TABLE IF NOT EXISTS app.uso_material (
  uso_id     BIGSERIAL PRIMARY KEY,
  pessoa_id  BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id    BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  tipo       TEXT NOT NULL CHECK (tipo ~ '^[a-z_0-9]{2,40}$'),
  segundos   INT NOT NULL CHECK (segundos BETWEEN 1 AND 7200),
  em         TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS ix_uso_pessoa_tema ON app.uso_material (pessoa_id, tema_id, tipo);
ALTER TABLE app.uso_material ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_uso_proprio ON app.uso_material;
CREATE POLICY pol_uso_proprio ON app.uso_material FOR INSERT TO api_rw WITH CHECK (pessoa_id = app.pessoa_atual());
GRANT INSERT ON app.uso_material TO api_rw;
GRANT USAGE ON SEQUENCE app.uso_material_uso_id_seq TO api_rw;

-- ---------- (4) notas ----------
CREATE TABLE IF NOT EXISTS app.nota_teste (
  tentativa_id  BIGINT PRIMARY KEY REFERENCES app.tentativa(tentativa_id) ON DELETE CASCADE,
  pessoa_id     BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id       BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  teste_num     SMALLINT NOT NULL,
  perfil        TEXT,
  ano           TEXT,
  especialidade TEXT,
  acertos       SMALLINT NOT NULL,
  total         SMALLINT NOT NULL,
  pct           NUMERIC(5,1) NOT NULL,
  nota_ponderada NUMERIC(5,1) NOT NULL,
  tempo_total_s INT,
  submetida_em  TIMESTAMPTZ NOT NULL);
CREATE INDEX IF NOT EXISTS ix_nota_pessoa ON app.nota_teste (pessoa_id);
ALTER TABLE app.nota_teste ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON app.nota_teste FROM PUBLIC;

CREATE OR REPLACE FUNCTION app.calcular_nota(p_tentativa BIGINT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.nota_teste (tentativa_id, pessoa_id, tema_id, teste_num, perfil, ano, especialidade,
                              acertos, total, pct, nota_ponderada, tempo_total_s, submetida_em)
  SELECT t.tentativa_id, t.pessoa_id, o.tema_id, o.teste_num, app.perfil_da_pessoa(t.pessoa_id),
         pa.grau::text, pa.especialidade,
         count(*) FILTER (WHERE a.eh_correta)::smallint, count(*)::smallint,
         round(100.0 * count(*) FILTER (WHERE a.eh_correta) / greatest(count(*), 1), 1),
         round(100.0 * sum(CASE WHEN a.eh_correta THEN coalesce(i.dificuldade, 3) ELSE 0 END)
               / greatest(sum(coalesce(i.dificuldade, 3)), 1), 1),
         (sum(r.tempo_resposta_ms) / 1000)::int, t.submetida_em
    FROM app.tentativa t
    JOIN app.onda_instancia o ON o.onda_id = t.onda_id
    JOIN app.resposta r ON r.tentativa_id = t.tentativa_id
    JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
    JOIN app.item i ON i.item_id = r.item_id
    LEFT JOIN LATERAL (SELECT x.grau, x.especialidade FROM app.posicao_anual x
                        WHERE x.pessoa_id = t.pessoa_id AND x.ativo ORDER BY x.ano_letivo DESC LIMIT 1) pa ON true
   WHERE t.tentativa_id = p_tentativa AND t.submetida_em IS NOT NULL AND o.tema_id IS NOT NULL
   GROUP BY t.tentativa_id, t.pessoa_id, o.tema_id, o.teste_num, pa.grau, pa.especialidade, t.submetida_em
  ON CONFLICT (tentativa_id) DO NOTHING $$;

CREATE OR REPLACE FUNCTION app.fn_nota_no_envio() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NEW.submetida_em IS NOT NULL AND OLD.submetida_em IS NULL THEN PERFORM app.calcular_nota(NEW.tentativa_id); END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_nota_no_envio ON app.tentativa;
CREATE TRIGGER tg_nota_no_envio AFTER UPDATE OF submetida_em ON app.tentativa FOR EACH ROW EXECUTE FUNCTION app.fn_nota_no_envio();
-- notas de tentativas ja enviadas
SELECT count(app.calcular_nota(t.tentativa_id)) FROM app.tentativa t WHERE t.submetida_em IS NOT NULL;

-- ---------- (5) ranking ----------
-- Media da nota ponderada de todos os testes enviados no ciclo; desempate pelo numero de testes.
-- p_filtro: 'geral' | 'especialidade' | 'ano' | 'subgrupo'. Mostra nome abreviado; a propria linha vem marcada.
CREATE OR REPLACE FUNCTION app.ranking(p_filtro TEXT DEFAULT 'geral', p_tema TEXT DEFAULT NULL)
RETURNS TABLE (posicao BIGINT, participantes BIGINT, nome TEXT, ano TEXT, especialidade TEXT,
               media NUMERIC, testes BIGINT, eu BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH eu AS (
    SELECT pa.grau::text AS ano, pa.especialidade FROM app.posicao_anual pa
     WHERE pa.pessoa_id = app.pessoa_atual() AND pa.ativo ORDER BY pa.ano_letivo DESC LIMIT 1),
  base AS (
    SELECT n.pessoa_id, avg(n.nota_ponderada) AS media, count(*) AS testes,
           (SELECT x.grau::text FROM app.posicao_anual x WHERE x.pessoa_id = n.pessoa_id AND x.ativo ORDER BY x.ano_letivo DESC LIMIT 1) AS ano,
           (SELECT x.especialidade FROM app.posicao_anual x WHERE x.pessoa_id = n.pessoa_id AND x.ativo ORDER BY x.ano_letivo DESC LIMIT 1) AS especialidade
      FROM app.nota_teste n JOIN app.tema t ON t.tema_id = n.tema_id
     WHERE p_tema IS NULL OR upper(replace(t.codigo,'-','')) = upper(replace(p_tema,'-',''))
     GROUP BY n.pessoa_id),
  filtrado AS (
    SELECT b.* FROM base b, eu
     WHERE app.pessoa_atual() IS NOT NULL
       AND (p_filtro = 'geral'
         OR (p_filtro = 'especialidade' AND b.especialidade IS NOT DISTINCT FROM eu.especialidade)
         OR (p_filtro = 'ano' AND b.ano IS NOT DISTINCT FROM eu.ano)
         OR (p_filtro = 'subgrupo' AND b.ano IS NOT DISTINCT FROM eu.ano AND b.especialidade IS NOT DISTINCT FROM eu.especialidade)))
  SELECT rank() OVER (ORDER BY f.media DESC, f.testes DESC), count(*) OVER (),
         split_part(p.nome_completo, ' ', 1) || coalesce(' ' || left(nullif(split_part(p.nome_completo, ' ', 2), ''), 1) || '.', ''),
         f.ano, f.especialidade, round(f.media, 1), f.testes, f.pessoa_id = app.pessoa_atual()
    FROM filtrado f JOIN app.pessoa p ON p.pessoa_id = f.pessoa_id
   ORDER BY 1, 3 $$;
REVOKE EXECUTE ON FUNCTION app.ranking(TEXT, TEXT), app.calcular_nota(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.ranking(TEXT, TEXT) TO api_rw;

-- Minhas notas (para a tela de desempenho).
CREATE OR REPLACE FUNCTION app.minhas_notas()
RETURNS TABLE (tema TEXT, titulo TEXT, teste_num SMALLINT, acertos SMALLINT, total SMALLINT, pct NUMERIC, nota_ponderada NUMERIC, submetida_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT t.codigo, t.titulo, n.teste_num, n.acertos, n.total, n.pct, n.nota_ponderada, n.submetida_em
    FROM app.nota_teste n JOIN app.tema t ON t.tema_id = n.tema_id
   WHERE n.pessoa_id = app.pessoa_atual() ORDER BY t.codigo, n.teste_num $$;
REVOKE EXECUTE ON FUNCTION app.minhas_notas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.minhas_notas() TO api_rw;

-- ---------- (6) pesquisa ----------
CREATE TABLE IF NOT EXISTS app.consentimento_pesquisa (
  pessoa_id   BIGINT PRIMARY KEY REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  aceito      BOOLEAN NOT NULL,
  versao_tcle TEXT NOT NULL,
  em          TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE app.consentimento_pesquisa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_consent_proprio ON app.consentimento_pesquisa;
CREATE POLICY pol_consent_proprio ON app.consentimento_pesquisa FOR ALL TO api_rw
  USING (pessoa_id = app.pessoa_atual()) WITH CHECK (pessoa_id = app.pessoa_atual());
GRANT SELECT, INSERT, UPDATE ON app.consentimento_pesquisa TO api_rw;

-- Codigo do participante: hash estavel e sem volta (troque o sal no servidor de producao).
CREATE OR REPLACE FUNCTION pesquisa.codigo_participante(p_pessoa BIGINT) RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$ SELECT 'P' || left(encode(digest('cut-2027:' || p_pessoa::text, 'sha256'), 'hex'), 10) $$;

-- So entram pessoas que aceitaram o TCLE.
CREATE OR REPLACE VIEW pesquisa.vw_estudo_notas AS
  SELECT pesquisa.codigo_participante(n.pessoa_id) AS participante, t.codigo AS tema, t.dificuldade AS grau_tema,
         t.papel_curricular, n.teste_num, n.perfil, n.ano, n.especialidade, n.acertos, n.total, n.pct, n.nota_ponderada,
         n.tempo_total_s, n.submetida_em
    FROM app.nota_teste n JOIN app.tema t ON t.tema_id = n.tema_id
    JOIN app.consentimento_pesquisa c ON c.pessoa_id = n.pessoa_id AND c.aceito;
CREATE OR REPLACE VIEW pesquisa.vw_estudo_satisfacao AS
  SELECT pesquisa.codigo_participante(a.pessoa_id) AS participante, t.codigo AS tema, a.ferramenta, a.nps,
         a.apresentacao, a.complexidade, a.conteudo, a.objetividade, a.clareza, a.tempo_gasto,
         a.frequencia_testes, a.importancia, a.minutos_gastos, a.comentario, a.atualizado_em
    FROM app.avaliacao a LEFT JOIN app.tema t ON t.tema_id = a.tema_id
    JOIN app.consentimento_pesquisa c ON c.pessoa_id = a.pessoa_id AND c.aceito;
CREATE OR REPLACE VIEW pesquisa.vw_estudo_uso AS
  SELECT pesquisa.codigo_participante(u.pessoa_id) AS participante, t.codigo AS tema, u.tipo,
         sum(u.segundos) AS segundos, count(*) AS aberturas, min(u.em) AS primeiro, max(u.em) AS ultimo
    FROM app.uso_material u JOIN app.tema t ON t.tema_id = u.tema_id
    JOIN app.consentimento_pesquisa c ON c.pessoa_id = u.pessoa_id AND c.aceito
   GROUP BY 1, 2, 3;
DROP VIEW IF EXISTS pesquisa.vw_estudo_mensagens;
CREATE VIEW pesquisa.vw_estudo_mensagens AS
  SELECT pesquisa.codigo_participante(m.pessoa_id) AS participante, t.codigo AS tema, m.ferramenta, m.tipo,
         m.texto, m.resposta, m.util, m.criado_em, m.respondida_em
    FROM app.mensagem_aluno m LEFT JOIN app.tema t ON t.tema_id = m.tema_id
    JOIN app.consentimento_pesquisa c ON c.pessoa_id = m.pessoa_id AND c.aceito;
-- NPS por ferramenta (promotores 9-10 menos detratores 0-6), para o painel do coordenador.
CREATE OR REPLACE VIEW app.vw_nps_ferramenta AS
  SELECT t.codigo AS tema, a.ferramenta, count(a.nps) AS respostas,
         round(100.0 * (count(*) FILTER (WHERE a.nps >= 9) - count(*) FILTER (WHERE a.nps <= 6)) / nullif(count(a.nps), 0), 0) AS nps,
         round(avg(a.apresentacao), 2) AS apresentacao, round(avg(a.conteudo), 2) AS conteudo,
         round(avg(a.objetividade), 2) AS objetividade, round(avg(a.clareza), 2) AS clareza,
         round(avg(a.complexidade), 2) AS complexidade, round(avg(a.tempo_gasto), 2) AS tempo_gasto,
         round(avg(a.frequencia_testes), 2) AS frequencia_testes, round(avg(a.importancia), 2) AS importancia
    FROM app.avaliacao a LEFT JOIN app.tema t ON t.tema_id = a.tema_id GROUP BY 1, 2;

COMMIT;
\echo 'avaliacao, duvidas, notas, ranking e visoes de pesquisa: prontos'
