-- 84_falas_slides_T001_v1.0.sql
-- Falas dos slides do T001 escritas para o aluno ouvir sozinho (o texto fica em conteudo/T001/v3/T001_slides_falas.md).
-- Cria uma NOVA VERSAO em rascunho da peca "Slides" do T001, igual a mais recente, com uma linha "> **Fala:**" em cada
-- slide (logo antes do proximo slide). A versao publicada, se houver, continua a mesma ate a revisao aprovar a nova.
-- O aplicativo usa a "Fala" no lugar da "Nota do apresentador" e o gerador de audio (--slides) tambem.
-- Pre-requisito: 36 (slides do T001). Pode ser rodado mais de uma vez: se a versao mais recente ja tem falas, nada faz.
-- DESFAZER: DELETE FROM conteudo.artefato WHERE tipo = 'slides' AND status = 'rascunho' AND corpo LIKE '%**Fala:**%';
\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE
  falas TEXT[] := ARRAY[
  $F$Esta aula trata da avaliação inicial do traumatizado: o que mudou no xABCDE e quão sólida é a evidência por trás de cada mudança. Depois dela vêm o caso da aula e o pós-teste D0.$F$,
  $F$Antes de seguir, responda para você mesmo: o ATLS reduz mortalidade? A: sim, comprovado por ensaios randomizados. B: há associação, mas a evidência é observacional. C: não há qualquer associação. Guarde a sua resposta. Ela volta mais adiante na aula.$F$,
  $F$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida [D1]. O que mais pesa no desfecho é a alteração da fisiologia, e não a quantidade de lesões anatômicas [D26]. Um exemplo: quem chega com pressão sistólica abaixo de 90 e precisa de laparotomia de emergência tem mortalidade acima de 40% [D27].$F$,
  $F$Volte à votação: a resposta é B. O treinamento se associa a menor mortalidade, com razão de chances de 0,60, mas esse dado vem de estudos observacionais [A1, A2]. Os próprios autores do ensaio ADVANCE TRAUMA escrevem que não há evidência de alta qualidade de que o ATLS melhore desfechos [A4]. O ensaio, em andamento na Índia, vai incluir pelo menos 4320 pacientes [A5]. Pense: isso muda a forma como o ATLS deve ser ensinado?$F$,
  $F$A mudança está no x, de hemorragia exsanguinante. Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação vem antes da via aérea: é a sequência CAB [D2, D3]. No pré-hospitalar, a hemorragia externa maciça é tratada primeiro [D4]. Depois seguem A, via aérea e coluna cervical; B, ventilação; C, circulação; D, estado neurológico; e E, exposição e temperatura.$F$,
  $F$Torniquete pré-hospitalar: numa revisão sistemática, a mortalidade foi de 4,02% com torniquete e 6,43% sem, risco relativo de 0,70, uma diferença que não foi estatisticamente significativa [A23]. A amputação inicial foi mais frequente com torniquete: 19,32% contra 6,4%, risco relativo de 2,07 [A24]. Atenção: são dados observacionais. Mais amputação pode refletir lesões mais graves e o tempo de torniquete, e não um efeito do torniquete em si. No curativo compressivo, a pressão medida variou de 50 a 412 milímetros de mercúrio [A25], e a percepção de quem aplicou não teve relação com a pressão real [A26]. Por isso, reavalie o sangramento em vez de confiar na sensação.$F$,
  $F$A tomografia de corpo inteiro feita de rotina parece ter pouco ou nenhum efeito na mortalidade e no tempo na sala de emergência [A12]. Em pacientes em choque, a mortalidade precoce foi de 17,4% com a tomografia e 27,6% sem, sem diferença estatística [A39]. E, entre 3976 pacientes que fizeram o exame, 3,02% tinham avaliação primária sem alterações [A40]. A indicação depende de critérios do serviço, a definir no protocolo institucional.$F$,
  $F$Não classifique o choque por um parâmetro isolado. A comparação clássica entre déficit de base e os parâmetros do ATLS superestimou a classe de choque [A32]. Estabilidade hemodinâmica aparece definida em 70% dos artigos, sem consenso nos pontos de corte [A33]. O protocolo RUSH teve sensibilidade de 94,2% em politraumatizados instáveis [A34]. O FAST-PLUS encontrou alargamento crítico da sínfise púbica em 7,5% dos pacientes [A35]. E, na parada cardíaca traumática fora do hospital, a adrenalina se associou a menor sobrevida em 7 dias, num estudo observacional [A31].$F$,
  $F$O checklist na ressuscitação pode melhorar a adesão ao ATLS e o fluxo de trabalho [A8, A11]. Num estudo, pacientes com ISS acima de 25 tiveram menor mortalidade com checklist [A9]; em outro, houve mais pneumonia no grupo checklist [A10]. Todos os estudos são do tipo antes e depois [A7]. Resumo: o checklist melhora o processo, e o efeito sobre a mortalidade continua incerto.$F$,
  $F$Um ensaio randomizado por conglomerados em oito hospitais não terciários de Gana testou um formulário de admissão do trauma [A45]. Melhoraram 14 de 16 indicadores da avaliação primária [A13]; o registro da via aérea passou de 72,9% para 98,4% [A14]. A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada [A15, A46]. Cautela: a mortalidade foi desfecho secundário, num subgrupo, em contexto diferente de um centro de trauma de referência. Para funcionar, o formulário precisa de um responsável na instituição, de adaptação ao contexto local e de integração à rotina [A16].$F$,
  $F$Pergunta antes dos números: um eFAST negativo exclui pneumotórax? Num estudo, a sensibilidade foi de 93,6% e a especificidade, de 99,8% [A29]. Em outro, prospectivo, a sensibilidade foi baixa, com muitos falsos negativos [A30]. Então, se a suspeita clínica continua, o exame negativo não encerra a investigação. Sobre oxigênio: 73% dos profissionais ouvidos não apoiam oferecer sempre, sem olhar a saturação; é opinião, não desfecho [A27]. A via aérea cirúrgica de emergência foi necessária em 0,24% dos pacientes de uma coorte japonesa [A28].$F$,
  $F$Como se faz. Antes da chegada, defina o líder e distribua as funções [D22]. A passagem do pré-hospitalar segue o formato MIST, com a equipe ouvindo, em até 1 minuto [D23, D24]. Na hemorragia: compressão direta, torniquete no membro e cinta pélvica no alto risco [D6, D7, D9]. Via aérea: voz normal indica via aérea pérvia; Glasgow de 8 ou menos indica via aérea definitiva, com exame neurológico antes da sedação [D10, D11, D12]. Circulação: meça a pressão manualmente se houver dúvida e use o acesso intraósseo se a veia falhar [D14, D15]. Repita o Glasgow, dispa o paciente por completo e aqueça [D16, D18, D19]. Depois, a avaliação secundária com a história AMPLA e, após a ressuscitação e as cirurgias, a avaliação terciária [D21, D31].$F$,
  $F$Equipe e liderança. Com o cirurgião de trauma presente, o tempo total de ressuscitação foi 259 segundos menor [A19]. Numa meta-análise, a sobrevida foi igual com líder cirurgião ou não cirurgião [A20], mas houve menos lesões não identificadas com o cirurgião na liderança, razão de chances de 0,48 [A21]. Treino de equipe com simulação reduz o tempo até exames, tomografia e hemostasia [A17], e o treino mensal na própria sala, com debriefing em vídeo, reduz o tempo de ressuscitação [A18].$F$,
  $F$O que dá errado. Confiar no aparelho automático de pressão no choque [D14]. Ler agitação como embriaguez, quando pode ser choque classe III ou IV [D17]. Encerrar a investigação com um eFAST negativo [A30]. Despir e esquecer de aquecer [A36, D19]. Pinçar às cegas uma ferida profunda [D8]. E achar que a tomografia dispensa a reavaliação [A42]. Os dois próximos slides aprofundam a hipotermia e o seguimento.$F$,
  $F$Até dois terços dos pacientes com trauma grave têm hipotermia, e ela costuma ser desconsiderada na ressuscitação inicial [A36]. Não há abordagem baseada em evidência para o manejo [A37]. E o fluido pré-aquecido a 39 graus só chega ao paciente acima de 37 graus com alto fluxo e ambiente quente [A38]. Pense no seu serviço: a temperatura é medida na admissão?$F$,
  $F$O atendimento não acaba na sala de trauma. Mesmo com tomografia de corpo inteiro, 13,9% dos pacientes tiveram lesão com diagnóstico tardio [A42]. Em 0,26% dos pacientes graves, uma lesão potencialmente letal apareceu depois da avaliação terciária [A41]. O teste SILENT, para o membro inferior, teve sensibilidade de 75% e especificidade de 99%: bom para confirmar, insuficiente para excluir [A43]. A avaliação terciária é feita depois da ressuscitação e das intervenções [D31] e, com a revisão das imagens, reduz as lesões não identificadas [D30].$F$,
  $F$Volte à votação do início: a resposta é B. Há associação com menor mortalidade, mas a evidência é observacional [A2, A4]. Leve para o plantão cinco mensagens. Sangramento externo grave vem primeiro. Trate cada problema ao encontrá-lo e reavalie. Um líder e uma passagem curta e estruturada. Dispa, aqueça e repita o Glasgow. E avaliação terciária sempre: a sala de trauma não encerra o diagnóstico. A seguir, o caso da aula.$F$];
  v_t BIGINT; a conteudo.artefato%ROWTYPE; l TEXT; m TEXT[]; n INT := 0; saida TEXT := '';
BEGIN
  SELECT tema_id INTO v_t FROM app.tema WHERE upper(replace(codigo, '-', '')) = 'T001';
  IF v_t IS NULL THEN RAISE NOTICE 'T001 nao encontrado; nada feito'; RETURN; END IF;
  SELECT * INTO a FROM conteudo.artefato WHERE tema_id = v_t AND tipo = 'slides' ORDER BY versao DESC LIMIT 1;
  IF a.artefato_id IS NULL THEN RAISE NOTICE 'T001 sem slides; nada feito'; RETURN; END IF;
  IF a.corpo LIKE '%**Fala:**%' THEN RAISE NOTICE 'slides do T001 ja tem falas (versao %); nada feito', a.versao; RETURN; END IF;
  FOREACH l IN ARRAY string_to_array(a.corpo, E'\n') LOOP
    m := regexp_match(l, '^###\s+Slide\s+(\d+)');
    IF (m IS NOT NULL OR l ~ '^##\s') AND n BETWEEN 1 AND cardinality(falas) THEN
      saida := rtrim(saida, E'\n') || E'\n\n> **Fala:** ' || falas[n] || E'\n\n'; n := 0;
    END IF;
    IF m IS NOT NULL THEN n := m[1]::int; END IF;
    saida := saida || l || E'\n';
  END LOOP;
  IF n BETWEEN 1 AND cardinality(falas) THEN saida := rtrim(saida, E'\n') || E'\n\n> **Fala:** ' || falas[n] || E'\n'; END IF;
  saida := regexp_replace(saida, 'Programa de Cirurgia de Urg[eê]ncia e Trauma', 'CUT', 'g');
  INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
  VALUES (v_t, 'slides', a.versao + 1, 'rascunho', a.titulo, saida, false);
  RAISE NOTICE 'slides do T001: versao % criada em rascunho, com as falas', a.versao + 1;
END $$;
COMMIT;
\echo 'falas dos slides do T001: prontas (rascunho para revisao)'
