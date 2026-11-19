-- 86_dicas_caso_T001_v1.0.sql
-- Dicas do caso da aula do T001 para quem esta no inicio (graduacao, R1 e R2). Do R3 em diante o caso vai sem apoio.
-- Cada dica orienta o raciocinio sem dar a resposta; o aplicativo so mostra quando o aluno pede ("Ver uma dica").
-- Cria uma NOVA VERSAO em rascunho do "Caso da aula" do T001, igual a mais recente, com uma linha "Dica:" em cada
-- ponto de decisao (logo depois da situacao). A versao publicada continua a mesma ate a revisao aprovar a nova.
-- Pre-requisito: 36 (caso do T001). Pode ser rodado mais de uma vez: se a versao mais recente ja tem dicas, nada faz.
-- DESFAZER: DELETE FROM conteudo.artefato WHERE tipo = 'caso' AND status = 'rascunho' AND corpo LIKE '%' || chr(10) || 'Dica:%';
\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE
  dicas TEXT[] := ARRAY[
    'Antes de seguir a ordem decorada, olhe o que está na sua frente: o que pode matar este paciente nos próximos minutos?',
    'Antes de pensar em comportamento, pense em perfusão: o que mais pode deixar um traumatizado agitado?',
    'O que um exame de imagem negativo garante, e o que não garante, quando a suspeita clínica continua?',
    'Até onde confiar no número do aparelho automático? Compare com o que a pele e o exame mostram.',
    'O frio piora o sangramento. O tempo de ida e volta da tomografia é parte do atendimento ou uma pausa nele?',
    'O que costuma passar despercebido na sala de trauma e na primeira tomografia?'];
  v_t BIGINT; a conteudo.artefato%ROWTYPE; l TEXT; n INT := 0; saida TEXT := ''; espera BOOLEAN := false;
BEGIN
  SELECT tema_id INTO v_t FROM app.tema WHERE upper(replace(codigo, '-', '')) = 'T001';
  IF v_t IS NULL THEN RAISE NOTICE 'T001 nao encontrado; nada feito'; RETURN; END IF;
  SELECT * INTO a FROM conteudo.artefato WHERE tema_id = v_t AND tipo = 'caso' ORDER BY versao DESC LIMIT 1;
  IF a.artefato_id IS NULL THEN RAISE NOTICE 'T001 sem caso; nada feito'; RETURN; END IF;
  IF a.corpo ~ '(^|\n)Dica:' THEN RAISE NOTICE 'caso do T001 ja tem dicas (versao %); nada feito', a.versao; RETURN; END IF;
  FOREACH l IN ARRAY string_to_array(a.corpo, E'\n') LOOP
    IF l ~ '^\*\*Ponto de decis' THEN n := n + 1; espera := true; END IF;
    saida := saida || l || E'\n';
    IF espera AND l ~ '^Situação:' AND n BETWEEN 1 AND cardinality(dicas) THEN
      saida := saida || 'Dica: ' || dicas[n] || E'\n'; espera := false;
    END IF;
  END LOOP;
  INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
  VALUES (v_t, 'caso', a.versao + 1, 'rascunho', a.titulo, rtrim(saida, E'\n'), false);
  RAISE NOTICE 'caso do T001: versao % criada em rascunho, com % dicas', a.versao + 1, least(n, cardinality(dicas));
END $$;
COMMIT;
\echo 'dicas do caso do T001: prontas (rascunho para revisao)'
