
-- ============================================================
-- 13_setup_pesquisador_v4.4.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.4 / 10-11-2026
--
-- OBJETIVO: criar pesquisador, coorte com 8 participantes,
-- respostas de pesquisa em 4 ondas e uma analise psicometrica
-- inicial. Serve para testar o fluxo do pesquisador e a curva
-- de retencao.
--
-- PRE-REQUISITO: 04_setup_resposta_e_pesquisa_v4.3.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 13_setup_pesquisador_v4.4.sql
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== SETUP PESQUISADOR v4.4 ==='

BEGIN;

-- PESQUISADOR
INSERT INTO app.pessoa (nome_completo, email_primario)
VALUES ('Pesquisador Teste', 'pesquisador.teste@setup.local')
ON CONFLICT (email_primario) DO NOTHING;

INSERT INTO app.designacao (pessoa_id, papel, vigencia_inicio)
SELECT p.pessoa_id, 'pesquisador', '2026-01-01'
  FROM app.pessoa p
 WHERE p.email_primario = 'pesquisador.teste@setup.local'
   AND NOT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p.pessoa_id AND d.papel = 'pesquisador');

-- COORTE (garante existencia)
INSERT INTO pesquisa.coorte (ano_ingresso, n_participantes, trilha_dominante)
VALUES (2026, 8, 'cirurgia')
ON CONFLICT (ano_ingresso) DO NOTHING;

-- PARTICIPANTES (garante 8)
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

    SELECT pessoa_id INTO v_pessoa_id FROM app.pessoa
     WHERE email_primario = 'part' || lpad(i::text, 2, '0') || '@setup.local';

    INSERT INTO pesquisa.participante (coorte_id, pessoa_id, consentimento_em, codigo_anonimo)
    VALUES (v_coorte_id, v_pessoa_id, now() - interval '30 days', 'ANON-' || lpad(i::text, 3, '0'))
    ON CONFLICT (coorte_id, pessoa_id) DO NOTHING;
  END LOOP;
END $$;

-- RESPOSTAS DE PESQUISA (4 ondas x 8 participantes, se ainda nao existirem)
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
      IF NOT EXISTS (SELECT 1 FROM pesquisa.resposta_participante rp
                      WHERE rp.participante_id = v_part.participante_id AND rp.onda_codigo = v_onda) THEN
        v_valor := v_base[v_idx] + (random() * 0.1 - 0.05);
        INSERT INTO pesquisa.resposta_participante (participante_id, onda_codigo, constructo, valor)
        VALUES (v_part.participante_id, v_onda, 'conhecimento_trauma', round(v_valor, 3));
      END IF;
    END LOOP;
  END LOOP;
END $$;

-- ANALISE PSICOMETRICA INICIAL (p e r por item da onda D0)
DO $$
DECLARE
  v_onda_id BIGINT;
  v_item RECORD;
  v_n INTEGER;
  v_acertos INTEGER;
  v_p NUMERIC;
  v_r NUMERIC;
BEGIN
  SELECT onda_id INTO v_onda_id FROM app.onda_instancia WHERE onda_codigo = 'D0';

  FOR v_item IN
    SELECT i.item_id
      FROM app.item i
      JOIN app.item_selecionado ise ON ise.item_id = i.item_id
     WHERE ise.onda_id = v_onda_id
  LOOP
    SELECT count(*) INTO v_n FROM app.resposta r WHERE r.item_id = v_item.item_id;
    SELECT count(*) INTO v_acertos
      FROM app.resposta r
      JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
     WHERE r.item_id = v_item.item_id AND a.eh_correta;

    IF v_n > 0 THEN
      v_p := round(v_acertos::numeric / v_n, 4);
      v_r := round((random() * 0.6 + 0.2)::numeric, 4);

      INSERT INTO pesquisa.analise_item (onda_id, item_id, p, r, n)
      VALUES (v_onda_id, v_item.item_id, v_p, v_r, v_n)
      ON CONFLICT (onda_id, item_id) DO UPDATE
         SET p = EXCLUDED.p, r = EXCLUDED.r, n = EXCLUDED.n, calculado_em = now();
    END IF;
  END LOOP;
END $$;

-- ANALISE DE DISTRATORES
DO $$
DECLARE
  v_onda_id BIGINT;
  v_alt RECORD;
  v_freq INTEGER;
  v_class TEXT;
BEGIN
  SELECT onda_id INTO v_onda_id FROM app.onda_instancia WHERE onda_codigo = 'D0';

  FOR v_alt IN
    SELECT a.alternativa_id, a.eh_correta
      FROM app.alternativa a
      JOIN app.item_selecionado ise ON ise.item_id = a.item_id
     WHERE ise.onda_id = v_onda_id
  LOOP
    SELECT count(*) INTO v_freq FROM app.resposta r WHERE r.alternativa_id = v_alt.alternativa_id;

    IF v_alt.eh_correta THEN
      v_class := 'funcional';
    ELSIF v_freq = 0 THEN
      v_class := 'nula';
    ELSE
      v_class := 'atrativa';
    END IF;

    INSERT INTO pesquisa.analise_distrator (onda_id, alternativa_id, frequencia, classificacao)
    VALUES (v_onda_id, v_alt.alternativa_id, v_freq, v_class)
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;

-- CONFERENCIA
\echo '--- Conferencia ---';

SELECT 'pesquisadores: ' || count(*) FROM app.designacao WHERE papel = 'pesquisador';
SELECT 'participantes: ' || count(*) FROM pesquisa.participante;
SELECT 'respostas de pesquisa: ' || count(*) FROM pesquisa.resposta_participante;
SELECT 'ondas na curva: ' || count(DISTINCT onda_codigo) FROM pesquisa.v_curva_retencao;
SELECT 'analises de item: ' || count(*) FROM pesquisa.analise_item;
SELECT 'analises de distrator: ' || count(*) FROM pesquisa.analise_distrator;

\echo '=== SETUP PESQUISADOR CONCLUIDO ==='

COMMIT;
