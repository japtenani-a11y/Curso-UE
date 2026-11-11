linha_sql
-- ============================================================
-- 04_setup_resposta_e_pesquisa_v4.3.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.3 / 10-11-2026
--
-- OBJETIVO: criar tentativa e respostas do aluno de teste na
-- onda D0, e popular a camada de pesquisa com coorte,
-- participantes e respostas por onda.
--
-- PRE-REQUISITO: 03_setup_minimo_v4.3.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 04_setup_resposta_e_pesquisa_v4.3.sql
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== SETUP RESPOSTA E PESQUISA v4.3 ==='

BEGIN;

-- TENTATIVA DO ALUNO DE TESTE
INSERT INTO app.tentativa (onda_id, pessoa_id, iniciada_em, submetida_em)
SELECT oi.onda_id, p.pessoa_id, now() - interval '1 hour', now()
  FROM app.onda_instancia oi, app.pessoa p
 WHERE oi.onda_codigo = 'D0' AND p.email_primario = 'r1.teste@setup.local'
ON CONFLICT (onda_id, pessoa_id) DO NOTHING;

-- RESPOSTAS (5 corretas, 2 erradas)
DO $$
DECLARE
  v_tentativa_id BIGINT;
  v_item RECORD;
  v_alt_id BIGINT;
  v_contador INTEGER := 0;
BEGIN
  SELECT t.tentativa_id INTO v_tentativa_id
    FROM app.tentativa t
    JOIN app.pessoa p ON p.pessoa_id = t.pessoa_id
   WHERE p.email_primario = 'r1.teste@setup.local';

  FOR v_item IN
    SELECT ise.item_id, ise.ordem_apresentada
      FROM app.item_selecionado ise
      JOIN app.onda_instancia oi ON oi.onda_id = ise.onda_id
     WHERE oi.onda_codigo = 'D0'
     ORDER BY ise.ordem_apresentada
  LOOP
    v_contador := v_contador + 1;
    IF v_contador <= 5 THEN
      SELECT alternativa_id INTO v_alt_id FROM app.alternativa
       WHERE item_id = v_item.item_id AND eh_correta LIMIT 1;
    ELSE
      SELECT alternativa_id INTO v_alt_id FROM app.alternativa
       WHERE item_id = v_item.item_id AND NOT eh_correta ORDER BY ordem LIMIT 1;
    END IF;

    INSERT INTO app.resposta (tentativa_id, item_id, alternativa_id, tempo_resposta_ms, ordem_apresentada)
    VALUES (v_tentativa_id, v_item.item_id, v_alt_id, 45000 + (v_contador * 1000), v_item.ordem_apresentada)
    ON CONFLICT (tentativa_id, item_id) DO NOTHING;
  END LOOP;
END $$;

-- COORTE
INSERT INTO pesquisa.coorte (ano_ingresso, n_participantes, trilha_dominante)
VALUES (2026, 8, 'cirurgia')
ON CONFLICT (ano_ingresso) DO NOTHING;

-- PARTICIPANTES (8)
DO $$
DECLARE
  v_coorte_id BIGINT;
  i INTEGER;
  v_pessoa_id BIGINT;
BEGIN
  SELECT coorte_id INTO v_coorte_id FROM pesquisa.coorte WHERE ano_ingresso = 2026;

  FOR i IN 1..8 LOOP
    INSERT INTO app.pessoa (nome_completo, email_primario)
    VALUES ('Participante ' || lpad(i::text, 2, '0'), 'part' || lpad(i::text, 2, '0') || '@setup.local')
    ON CONFLICT (email_primario) DO NOTHING;

    SELECT pessoa_id INTO v_pessoa_id FROM app.pessoa WHERE email_primario = 'part' || lpad(i::text, 2, '0') || '@setup.local';

    INSERT INTO pesquisa.participante (coorte_id, pessoa_id, consentimento_em, codigo_anonimo)
    VALUES (v_coorte_id, v_pessoa_id, now() - interval '30 days', 'ANON-' || lpad(i::text, 3, '0'))
    ON CONFLICT (coorte_id, pessoa_id) DO NOTHING;
  END LOOP;
END $$;

-- RESPOSTAS DE PESQUISA (4 ondas x 8 participantes)
DO $$
DECLARE
  v_part RECORD;
  v_onda TEXT;
  v_valor NUMERIC;
  v_ondas TEXT[] := ARRAY['D0','D1','D2','D3'];
  v_base NUMERIC[] := ARRAY[0.85, 0.78, 0.72, 0.68];
  v_idx INTEGER;
BEGIN
  FOR v_part IN SELECT participante_id FROM pesquisa.participante LOOP
    FOR v_idx IN 1..4 LOOP
      v_onda := v_ondas[v_idx];
      v_valor := v_base[v_idx] + (random() * 0.1 - 0.05);
      INSERT INTO pesquisa.resposta_participante (participante_id, onda_codigo, constructo, valor)
      VALUES (v_part.participante_id, v_onda, 'conhecimento_trauma', round(v_valor, 3));
    END LOOP;
  END LOOP;
END $$;

-- CONFERENCIA
\echo '--- Conferencia ---'

SELECT 'respostas do aluno: ' || count(*) FROM app.resposta;
SELECT 'participantes: ' || count(*) FROM pesquisa.participante;
SELECT 'respostas de pesquisa: ' || count(*) FROM pesquisa.resposta_participante;
SELECT 'ondas na curva: ' || count(DISTINCT onda_codigo) FROM pesquisa.v_curva_retencao;

\echo '=== SETUP RESPOSTA E PESQUISA CONCLUIDO ==='

COMMIT;
