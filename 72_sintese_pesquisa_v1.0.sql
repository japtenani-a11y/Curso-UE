-- 72_sintese_pesquisa_v1.0.sql
-- Sintese de evidencia ganha a secao "Sugestoes de temas para trabalho cientifico/artigos": 5 ideias de estudo
-- (so o modelo do estudo e a sugestao), para o residente que quiser procurar um orientador.
-- T001: a secao e acrescentada na versao mais recente. Se essa versao ja estiver publicada, cria-se uma nova
-- versao em rascunho (passa pela revisao como qualquer mudanca). Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;
DO $do$
DECLARE a conteudo.artefato%ROWTYPE; v_sec TEXT := $S$## Sugestões de temas para trabalho científico/artigos

Para quem quiser seguir o caminho da pesquisa. Cada ideia nasce de uma disputa ou lacuna desta síntese. Escolha uma, aprofunde a leitura das fontes indicadas e leve a proposta a um possível orientador. O desenho final (pergunta, população, desfecho e ética) se define com ele.

1. **Coorte retrospectiva (observacional).** Lesões com diagnóstico tardio no politraumatizado da UE-HCFMRP: frequência, lesões mais perdidas e fatores associados, incluindo a realização da avaliação terciária [A41, A42].
2. **Revisão sistemática com metanálise.** Torniquete no atendimento pré-hospitalar e intra-hospitalar: mortalidade e amputação, separando a gravidade da lesão do efeito do dispositivo [A23, A24].
3. **Estudo prospectivo de acurácia diagnóstica.** Ultrassom à beira do leito (eFAST) para pneumotórax no trauma fechado e penetrante, com a tomografia como padrão de referência [A29, A30, A47].
4. **Estudo de intervenção educacional (quase-experimental, antes e depois).** Retenção do conhecimento da avaliação inicial em residentes com pós-testes espaçados (D+15, D+45 e D+90), usando os dados do próprio programa [H5].
5. **Coorte prospectiva (observacional).** Hipotermia na chegada e durante a primeira hora no trauma grave: incidência, medidas de aquecimento realmente aplicadas e associação com coagulopatia e mortalidade [A36, A37].
$S$;
BEGIN
  SELECT x.* INTO a FROM conteudo.artefato x JOIN app.tema t ON t.tema_id = x.tema_id
   WHERE replace(t.codigo,'-','') = 'T001' AND x.tipo = 'sintese_evidencia' ORDER BY x.versao DESC LIMIT 1;
  IF a.artefato_id IS NULL OR position('Sugestões de temas para trabalho científico' IN coalesce(a.corpo,'')) > 0 THEN RETURN; END IF;
  IF a.status IN ('rascunho','revisao') THEN
    UPDATE conteudo.artefato SET corpo = rtrim(corpo, E'\n') || E'\n\n' || v_sec WHERE artefato_id = a.artefato_id;
  ELSE
    INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo)
    VALUES (a.tema_id, a.tipo, a.versao + 1, 'rascunho', a.titulo, rtrim(a.corpo, E'\n') || E'\n\n' || v_sec);
  END IF;
END $do$;
COMMIT;
\echo 'sintese de evidencia: secao de sugestoes de pesquisa incluida'
