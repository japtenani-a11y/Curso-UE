-- 43_calendario_lembretes_v1.0.sql
-- (1) app.agendar_ondas_tema(tema, D0): cria as 6 ondas de um tema a partir da data da reuniao (D0)
--     e coloca nelas as questoes (fixa + questoes de caso do teste, de todos os perfis).
--     Datas: pre-teste inicial D-15 | pre-teste 2 D-7 (proposta) | pos-teste D0 | D+15 | D+45 | D+90.
--     Cada onda fica aberta ate D+180, para o aluno poder responder com atraso.
-- (2) Lembretes de pos-teste pendente: 7, 14, 28 e 60 dias depois da data prevista.
--     app.gerar_lembretes_pessoa() cria os lembretes da pessoa logada (a API chama ao abrir os testes);
--     app.gerar_lembretes() cria para todos (para um agendador diario, quando houver envio por e-mail).
-- Pre-requisito: 37 e 38. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

DROP FUNCTION IF EXISTS app.agendar_ondas_tema(BIGINT, DATE, INT);
CREATE OR REPLACE FUNCTION app.agendar_ondas_tema(p_tema BIGINT, p_d0 DATE, p_pre2_dias INT DEFAULT -7)
RETURNS TABLE (onda TEXT, teste SMALLINT, data_prevista DATE, questoes BIGINT)
LANGUAGE plpgsql AS $$
#variable_conflict use_column
DECLARE
  v_cod TEXT; v_ciclo BIGINT;
BEGIN
  SELECT replace(t.codigo,'-',''), t.ciclo_id INTO v_cod, v_ciclo FROM app.tema t WHERE t.tema_id = p_tema;
  IF v_cod IS NULL THEN RAISE EXCEPTION 'tema % nao existe', p_tema; END IF;

  INSERT INTO app.onda_instancia (ciclo_id, onda_codigo, ordem_onda, data_abertura, data_fechamento, status, tema_id, teste_num)
  SELECT v_ciclo, v_cod || '-' || v.cod, 100 + v.n,
         (p_d0 + v.dias)::timestamptz, (p_d0 + 180)::timestamptz,
         CASE WHEN p_d0 + v.dias <= current_date THEN 'aberta' ELSE 'planejada' END::app.status_onda,
         p_tema, v.n
    FROM (VALUES (1,'PRE1',-15),(2,'PRE2',p_pre2_dias),(3,'POS-D0',0),(4,'POS-D15',15),(5,'POS-D45',45),(6,'POS-D90',90)) v(n, cod, dias)
  ON CONFLICT (ciclo_id, onda_codigo) DO UPDATE
     SET data_abertura = EXCLUDED.data_abertura, data_fechamento = EXCLUDED.data_fechamento,
         status = EXCLUDED.status, tema_id = EXCLUDED.tema_id, teste_num = EXCLUDED.teste_num;

  INSERT INTO app.item_selecionado (onda_id, item_id, ordem_apresentada)
  SELECT o.onda_id, i.item_id,
         row_number() OVER (PARTITION BY o.onda_id ORDER BY i.fixa DESC, i.perfil, i.codigo)::smallint
    FROM app.onda_instancia o
    JOIN app.item i ON i.tema_id = o.tema_id AND (i.fixa OR i.teste_num = o.teste_num)
   WHERE o.tema_id = p_tema
  ON CONFLICT (onda_id, item_id) DO NOTHING;

  RETURN QUERY
  SELECT o.onda_codigo, o.teste_num, o.data_abertura::date, (SELECT count(*) FROM app.item_selecionado s WHERE s.onda_id = o.onda_id)
    FROM app.onda_instancia o WHERE o.tema_id = p_tema ORDER BY o.teste_num;
END $$;

-- Abre as ondas cuja data chegou (rodar diariamente, ou ao abrir a tela de testes).
CREATE OR REPLACE FUNCTION app.abrir_ondas_do_dia() RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH u AS (UPDATE app.onda_instancia SET status = 'aberta'
              WHERE tema_id IS NOT NULL AND status = 'planejada' AND data_abertura <= now() RETURNING 1)
  SELECT count(*)::int FROM u $$;

CREATE TABLE IF NOT EXISTS app.lembrete (
  lembrete_id BIGSERIAL PRIMARY KEY,
  pessoa_id   BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  onda_id     BIGINT NOT NULL REFERENCES app.onda_instancia(onda_id) ON DELETE CASCADE,
  dias_apos   SMALLINT NOT NULL CHECK (dias_apos IN (7, 14, 28, 60)),
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  lido_em     TIMESTAMPTZ,
  UNIQUE (pessoa_id, onda_id, dias_apos));
ALTER TABLE app.lembrete ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_lembrete_proprio ON app.lembrete;
CREATE POLICY pol_lembrete_proprio ON app.lembrete FOR SELECT TO api_rw USING (pessoa_id = app.pessoa_atual());
DROP POLICY IF EXISTS pol_lembrete_lido ON app.lembrete;
CREATE POLICY pol_lembrete_lido ON app.lembrete FOR UPDATE TO api_rw
  USING (pessoa_id = app.pessoa_atual()) WITH CHECK (pessoa_id = app.pessoa_atual());
GRANT SELECT, UPDATE (lido_em) ON app.lembrete TO api_rw;

-- Lembretes de uma pessoa: pos-testes (3 a 6) liberados para ela, nao submetidos, com 7/14/28/60 dias de atraso.
CREATE OR REPLACE FUNCTION app.gerar_lembretes_para(p_pessoa BIGINT) RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH novos AS (
    INSERT INTO app.lembrete (pessoa_id, onda_id, dias_apos)
    SELECT p_pessoa, o.onda_id, d.dias
      FROM app.onda_instancia o
      CROSS JOIN (VALUES (7),(14),(28),(60)) d(dias)
     WHERE o.tema_id IS NOT NULL AND o.teste_num BETWEEN 3 AND 6
       AND o.data_abertura + make_interval(days => d.dias) <= now()
       AND app.teste_liberado(p_pessoa, o.tema_id, o.teste_num)
       AND NOT app.teste_submetido(p_pessoa, o.tema_id, o.teste_num)
    ON CONFLICT (pessoa_id, onda_id, dias_apos) DO NOTHING
    RETURNING 1)
  SELECT count(*)::int FROM novos $$;

-- Versao para a API: so gera para a pessoa logada.
CREATE OR REPLACE FUNCTION app.gerar_lembretes_pessoa() RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT CASE WHEN app.pessoa_atual() IS NULL THEN 0 ELSE app.gerar_lembretes_para(app.pessoa_atual()) END $$;

-- Para um agendador diario: todos os alunos ativos.
CREATE OR REPLACE FUNCTION app.gerar_lembretes() RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(sum(app.gerar_lembretes_para(x.pessoa_id)), 0)::int
    FROM (SELECT DISTINCT pa.pessoa_id FROM app.posicao_anual pa JOIN app.perfil pr USING (perfil_id)
           WHERE pa.ativo AND pr.codigo = 'aluno') x $$;

REVOKE EXECUTE ON FUNCTION app.gerar_lembretes_para(BIGINT), app.gerar_lembretes() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.gerar_lembretes_pessoa(), app.abrir_ondas_do_dia() TO api_rw;
REVOKE EXECUTE ON FUNCTION app.gerar_lembretes_pessoa() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.gerar_lembretes_pessoa() TO api_rw;

COMMIT;
\echo 'calendario e lembretes: prontos'
