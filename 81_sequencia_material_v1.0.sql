-- 81_sequencia_material_v1.0.sql
-- Nova sequencia de entrega do material ao aluno (decisao da coordenacao em 15/11/2026).
--   Etapa 1  D-15: so o pre-teste 1.
--   Etapa 2  ao enviar o pre-teste 1: objetivos de aprendizagem (por perfil), resumo basico, podcast (roteiro e audio),
--            caso base, sintese de evidencia, mapa conceitual e o pre-teste 2.
--   Etapa 3  com o pre-teste 2 enviado e na hora da aula (D0): aula, slides, caso da aula e pos-teste D0.
--            O pre-teste 2 fecha 1 hora antes da aula; quem perdeu esse prazo recebe a etapa 3 na hora da aula
--            (o pre-teste 2 fica como perdido), para nao travar o tema.
--   Etapa 4  ao enviar o pos-teste D0: resumo executivo, protocolo assistencial, checklists, flashcards e banco de
--            questoes; os pos-testes D+15, D+45 e D+90 abrem nas datas deles.
-- Muda em relacao ao 60/65: sintese de evidencia e mapa passam do pos-aula para o pre-aula; a etapa 3 passa a
-- exigir o pre-teste 2 enviado (ou vencido); "Pre-teste inicial" passa a se chamar "Pre-teste 1".
-- Pre-requisito: 60, 65, 68. Pode ser rodado mais de uma vez.
-- DESFAZER: rodar de novo 60 e 65 (recriam as funcoes antigas).
\set ON_ERROR_STOP on
BEGIN;

-- Etapa 0 = bloqueado pela arvore (65); as demais como descrito acima.
CREATE OR REPLACE FUNCTION app.etapa_liberada(p_pessoa BIGINT, p_tema BIGINT) RETURNS INT
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint)
         AND EXISTS (SELECT 1 FROM app.tema_requisito r WHERE r.tema_id = p_tema AND NOT app.tema_concluido(p_pessoa, r.requisito_id)) THEN 0
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint) THEN 1
    WHEN coalesce(now() < app.d0_da_pessoa(p_pessoa, p_tema), true) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 2::smallint)
         AND NOT EXISTS (SELECT 1 FROM app.onda_instancia o WHERE o.onda_id = app.onda_da_pessoa(p_pessoa, p_tema, 2::smallint)
                            AND o.data_fechamento <= now()) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 3::smallint) THEN 3
    ELSE 4 END $$;

CREATE OR REPLACE FUNCTION app.etapa_do_material(p_tipo TEXT) RETURNS INT
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE
    WHEN p_tipo IN ('objetivos','resumo_basico','podcast_roteiro','caso_base','sintese_evidencia','mapa') THEN 2
    WHEN p_tipo IN ('aula','slides','caso') THEN 3
    WHEN p_tipo IN ('resumo','protocolo','checklist','flashcard','simulado') THEN 4
    ELSE NULL END $$;

CREATE OR REPLACE FUNCTION app.nome_teste(p_n SMALLINT) RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT (ARRAY['Pré-teste 1','Pré-teste 2','Pós-teste D0','Pós-teste D+15','Pós-teste D+45','Pós-teste D+90'])[p_n] $$;

CREATE OR REPLACE FUNCTION app.nome_material(p_tipo TEXT) RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p_tipo
    WHEN 'objetivos' THEN 'Objetivos de aprendizagem' WHEN 'resumo_basico' THEN 'Resumo básico' WHEN 'podcast_roteiro' THEN 'Podcast'
    WHEN 'caso_base' THEN 'Caso base' WHEN 'sintese_evidencia' THEN 'Síntese de evidência' WHEN 'mapa' THEN 'Mapa conceitual'
    WHEN 'aula' THEN 'Aula' WHEN 'slides' THEN 'Slides da aula' WHEN 'caso' THEN 'Caso da aula'
    WHEN 'resumo' THEN 'Resumo executivo' WHEN 'protocolo' THEN 'Proposta de diretriz clínica' WHEN 'checklist' THEN 'Checklists'
    WHEN 'flashcard' THEN 'Flashcards' WHEN 'simulado' THEN 'Banco de questões' ELSE p_tipo END $$;

GRANT EXECUTE ON FUNCTION app.etapa_liberada(BIGINT, BIGINT), app.etapa_do_material(TEXT), app.nome_teste(SMALLINT),
  app.nome_material(TEXT) TO api_rw;

-- Lista de material da tela do tema na ordem da entrega (a funcao e do 60; so a lista muda).
DO $$
DECLARE d TEXT; antigo TEXT := $a$ARRAY['objetivos','resumo_basico','podcast_roteiro','caso_base','aula','slides','caso','sintese_evidencia',
                        'resumo','mapa','flashcard','protocolo','checklist','simulado']$a$;
        novo TEXT := $a$ARRAY['objetivos','resumo_basico','podcast_roteiro','caso_base','sintese_evidencia','mapa',
                        'aula','slides','caso','resumo','protocolo','checklist','flashcard','simulado']$a$;
BEGIN
  SELECT pg_get_functiondef('app.jornada_tema(text)'::regprocedure) INTO d;
  IF position(antigo IN d) > 0 THEN EXECUTE replace(d, antigo, novo);
  ELSIF position(novo IN d) = 0 THEN RAISE WARNING 'jornada_tema: lista de material nao encontrada; ordem mantida';
  END IF;
END $$;

-- Nome antigo nos titulos das ondas ja criadas, se houver coluna de nome.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'onda_instancia' AND column_name = 'nome') THEN
    EXECUTE $u$UPDATE app.onda_instancia SET nome = replace(replace(nome, 'Pré-teste inicial', 'Pré-teste 1'), 'pré-teste inicial', 'pré-teste 1')
               WHERE nome ILIKE '%pré-teste inicial%'$u$;
  END IF;
END $$;

COMMIT;
\echo 'sequencia de entrega do material: pronta'
