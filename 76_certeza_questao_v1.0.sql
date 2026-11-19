-- 76_certeza_questao_v1.0.sql
-- Certeza por questao (decisao da coordenacao em 15/11/2026): em cada questao das ondas o residente marca
-- "chutei" (1), "acho que sim" (2) ou "tenho certeza" (3), ANTES de ver o gabarito. O teste so pode ser enviado
-- com alternativa e certeza em todas as questoes. Substitui a confianca unica de 0 a 100% por teste (73), cujos
-- dados ja coletados continuam em app.confianca_teste e no painel "Calibracao e aplicabilidade".
-- Base: erro cometido com certeza alta e o que mais se corrige com o feedback (hipercorrecao; Butterfield e Metcalfe, 2001, PMID 11713883).
-- Pre-requisito: 37, 38, 60, 73. Pode ser rodado mais de uma vez.
-- Rascunho: app.resposta e imutavel (27). Enquanto o teste esta aberto, cada resposta (alternativa e certeza) e salva
-- em app.resposta_rascunho, que pode mudar; no envio, as respostas vao de uma vez para app.resposta, que segue imutavel.
-- Assim o residente retoma o teste de onde parou (plantao, internet ruim) sem quebrar a regra de imutabilidade.
-- DESFAZER: DROP FUNCTION app.salvar_rascunho, app.rascunho_onda, app.painel_certeza; DROP TABLE app.resposta_rascunho;
--           ALTER TABLE app.resposta DROP COLUMN certeza;
\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE app.resposta ADD COLUMN IF NOT EXISTS certeza SMALLINT;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'resposta_certeza_chk') THEN
    ALTER TABLE app.resposta ADD CONSTRAINT resposta_certeza_chk CHECK (certeza BETWEEN 1 AND 3);
  END IF;
END $$;
COMMENT ON COLUMN app.resposta.certeza IS 'certeza marcada antes do gabarito: 1 chutei, 2 acho que sim, 3 tenho certeza (nulo nas tentativas anteriores a 15/11/2026)';

CREATE TABLE IF NOT EXISTS app.resposta_rascunho (
  tentativa_id      BIGINT NOT NULL REFERENCES app.tentativa(tentativa_id) ON DELETE CASCADE,
  item_id           BIGINT NOT NULL REFERENCES app.item(item_id) ON DELETE CASCADE,
  alternativa_id    BIGINT NOT NULL REFERENCES app.alternativa(alternativa_id) ON DELETE CASCADE,
  certeza           SMALLINT CHECK (certeza BETWEEN 1 AND 3),
  tempo_resposta_ms INTEGER,
  atualizado_em     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tentativa_id, item_id));
REVOKE ALL ON app.resposta_rascunho FROM PUBLIC;

-- Salva (ou troca) a resposta em rascunho da pessoa logada; so com o teste aberto, nao enviado e questao do perfil dela.
CREATE OR REPLACE FUNCTION app.salvar_rascunho(p_onda BIGINT, p_item BIGINT, p_alt BIGINT, p_certeza INT, p_tempo INT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_t BIGINT; v_perfil TEXT;
BEGIN
  SELECT t.tentativa_id INTO v_t FROM app.tentativa t
   WHERE t.onda_id = p_onda AND t.pessoa_id = app.pessoa_atual() AND t.submetida_em IS NULL AND app.onda_respondivel(p_onda);
  IF v_t IS NULL THEN RETURN false; END IF;
  v_perfil := app.perfil_da_pessoa(app.pessoa_atual());
  IF NOT EXISTS (SELECT 1 FROM app.item_selecionado s
                   JOIN app.item i ON i.item_id = s.item_id AND (i.fixa OR i.perfil = v_perfil)
                   JOIN app.alternativa a ON a.item_id = i.item_id AND a.alternativa_id = p_alt
                  WHERE s.onda_id = p_onda AND i.item_id = p_item) THEN RETURN false; END IF;
  INSERT INTO app.resposta_rascunho (tentativa_id, item_id, alternativa_id, certeza, tempo_resposta_ms)
  VALUES (v_t, p_item, p_alt, CASE WHEN p_certeza BETWEEN 1 AND 3 THEN p_certeza END, greatest(p_tempo, 0))
  ON CONFLICT (tentativa_id, item_id) DO UPDATE SET alternativa_id = EXCLUDED.alternativa_id,
         certeza = coalesce(EXCLUDED.certeza, app.resposta_rascunho.certeza),
         tempo_resposta_ms = coalesce(EXCLUDED.tempo_resposta_ms, app.resposta_rascunho.tempo_resposta_ms), atualizado_em = now();
  RETURN true;
END $$;

-- Rascunho da pessoa logada numa onda (para retomar o teste).
CREATE OR REPLACE FUNCTION app.rascunho_onda(p_onda BIGINT)
RETURNS TABLE (item_id BIGINT, alternativa_id BIGINT, certeza SMALLINT, tempo_resposta_ms INT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT r.item_id, r.alternativa_id, r.certeza, r.tempo_resposta_ms
    FROM app.resposta_rascunho r JOIN app.tentativa t ON t.tentativa_id = r.tentativa_id
   WHERE t.onda_id = p_onda AND t.pessoa_id = app.pessoa_atual() $$;
REVOKE EXECUTE ON FUNCTION app.salvar_rascunho(BIGINT, BIGINT, BIGINT, INT, INT), app.rascunho_onda(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.salvar_rascunho(BIGINT, BIGINT, BIGINT, INT, INT), app.rascunho_onda(BIGINT) TO api_rw;

-- Painel (preceptor, curador, pesquisador): acerto por nivel de certeza, por aluno, tema e teste enviado.
-- erros_com_certeza = respostas erradas marcadas "tenho certeza" (o alvo principal do gabarito comentado).
DROP FUNCTION IF EXISTS app.painel_certeza();
CREATE FUNCTION app.painel_certeza()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, tema TEXT, teste SMALLINT, questoes INT, acertos INT,
               chutei INT, chutei_acertos INT, acho INT, acho_acertos INT, certeza INT, certeza_acertos INT,
               erros_com_certeza INT, sem_certeza INT, enviado_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH r AS (
    SELECT tt.pessoa_id, o.tema_id, o.teste_num, tt.submetida_em, r.certeza, a.eh_correta AS ok
      FROM app.tentativa tt
      JOIN app.onda_instancia o ON o.onda_id = tt.onda_id
      JOIN app.resposta r ON r.tentativa_id = tt.tentativa_id
      JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
     WHERE tt.submetida_em IS NOT NULL)
  SELECT app.aluno_painel(r.pessoa_id), pf.ano, pf.especialidade, t.codigo, r.teste_num,
         count(*)::int, count(*) FILTER (WHERE ok)::int,
         count(*) FILTER (WHERE certeza = 1)::int, count(*) FILTER (WHERE certeza = 1 AND ok)::int,
         count(*) FILTER (WHERE certeza = 2)::int, count(*) FILTER (WHERE certeza = 2 AND ok)::int,
         count(*) FILTER (WHERE certeza = 3)::int, count(*) FILTER (WHERE certeza = 3 AND ok)::int,
         count(*) FILTER (WHERE certeza = 3 AND NOT ok)::int, count(*) FILTER (WHERE certeza IS NULL)::int,
         max(r.submetida_em)
    FROM r JOIN app.tema t ON t.tema_id = r.tema_id, LATERAL app.perfil_aluno(r.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   GROUP BY r.pessoa_id, pf.ano, pf.especialidade, t.codigo, r.teste_num
   ORDER BY 1, 4, 5 $$;
REVOKE EXECUTE ON FUNCTION app.painel_certeza() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.painel_certeza() TO api_rw;

COMMIT;
\echo 'certeza por questao: pronta'
