-- ============================================================
-- 12_setup_conteudo_minimo_v4.4.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.4 / 10-11-2026
--
-- OBJETIVO: criar os 12 artefatos do tema 1, com blocos e
-- checklist conforme, todos publicados. Serve para testar o
-- fluxo do curador e a auditoria visual.
--
-- PRE-REQUISITO: 03_setup_minimo_v4.3.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 12_setup_conteudo_minimo_v4.4.sql
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== SETUP CONTEUDO MINIMO v4.4 ==='

BEGIN;

DO $$
DECLARE
  v_tema_id BIGINT;
  v_artefato_id BIGINT;
  v_tipo TEXT;
  v_tipos TEXT[] := ARRAY[
    'sintese_evidencia','objetivos','item','gabarito','aula','caso',
    'protocolo','checklist','resumo','mapa','flashcard','simulado'
  ];
  v_titulos TEXT[] := ARRAY[
    'Sintese de evidencia','Objetivos de aprendizagem','Item de avaliacao',
    'Gabarito comentado','Aula expositiva','Caso clinico','Protocolo assistencial',
    'Checklist de procedimento','Resumo executivo','Mapa conceitual',
    'Flashcards','Simulado'
  ];
  i INTEGER;
BEGIN
  SELECT tema_id INTO v_tema_id FROM app.tema WHERE codigo = 'T-001';

  FOR i IN 1..12 LOOP
    v_tipo := v_tipos[i];

    INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
    VALUES (v_tema_id, v_tipo, 1, 'rascunho', v_titulos[i],
            'Conteudo do artefato ' || v_tipo || ' do tema T-001.', false)
    ON CONFLICT (tema_id, tipo, versao) DO NOTHING
    RETURNING artefato_id INTO v_artefato_id;

    IF v_artefato_id IS NULL THEN
      SELECT artefato_id INTO v_artefato_id FROM conteudo.artefato
       WHERE tema_id = v_tema_id AND tipo = v_tipo AND versao = 1;
    END IF;

    INSERT INTO conteudo.bloco (artefato_id, ordem, tipo, conteudo)
    VALUES (v_artefato_id, 1, 'texto', 'Bloco 1 do artefato ' || v_tipo)
    ON CONFLICT (artefato_id, ordem) DO NOTHING;

    INSERT INTO conteudo.bloco (artefato_id, ordem, tipo, conteudo)
    VALUES (v_artefato_id, 2, 'texto', 'Bloco 2 do artefato ' || v_tipo)
    ON CONFLICT (artefato_id, ordem) DO NOTHING;

    INSERT INTO conteudo.checklist_item (artefato_id, descricao, conforme, obrigatorio)
    VALUES (v_artefato_id, 'Estrutura conforme', true, true)
    ON CONFLICT DO NOTHING;

    INSERT INTO conteudo.checklist_item (artefato_id, descricao, conforme, obrigatorio)
    VALUES (v_artefato_id, 'Fontes citadas', true, true)
    ON CONFLICT DO NOTHING;

    UPDATE conteudo.artefato
       SET checklist_conforme = true,
           status = 'publicado',
           publicado_em = now()
     WHERE artefato_id = v_artefato_id;
  END LOOP;
END $$;

-- FONTES
INSERT INTO conteudo.fonte (tema_id, camada, titulo, autores, ano, doi, trecho_literal)
SELECT tema_id, 1, 'ATLS 10th Edition', 'American College of Surgeons', 2018, '10.1016/atls.2018', 'Avaliacao inicial segue ABCDE.'
  FROM app.tema WHERE codigo = 'T-001'
  AND NOT EXISTS (SELECT 1 FROM conteudo.fonte WHERE tema_id = (SELECT tema_id FROM app.tema WHERE codigo = 'T-001') AND camada = 1);

INSERT INTO conteudo.fonte (tema_id, camada, titulo, autores, ano, doi, trecho_literal)
SELECT tema_id, 2, 'Diretriz de atendimento ao politraumatizado', 'Sociedade Brasileira de Cirurgia', 2022, '10.1590/diretriz.2022', 'Controle de hemorragia e prioridade.'
  FROM app.tema WHERE codigo = 'T-001'
  AND NOT EXISTS (SELECT 1 FROM conteudo.fonte WHERE tema_id = (SELECT tema_id FROM app.tema WHERE codigo = 'T-001') AND camada = 2);

-- CONFERENCIA
\echo '--- Conferencia ---'

SELECT 'artefatos publicados: ' || count(*) FROM conteudo.artefato WHERE tema_id = (SELECT tema_id FROM app.tema WHERE codigo = 'T-001') AND status = 'publicado';
SELECT 'blocos: ' || count(*) FROM conteudo.bloco;
SELECT 'fontes: ' || count(*) FROM conteudo.fonte;

\echo '=== SETUP CONTEUDO MINIMO CONCLUIDO ==='

COMMIT;
