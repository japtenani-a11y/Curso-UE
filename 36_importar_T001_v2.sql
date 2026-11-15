-- 36_importar_T001_v2.sql : T001 no padrao do guia v0.1 (12/11/2026). Novas versoes em RASCUNHO; nada e apagado.
-- Pre-requisito: 32_revisao_v1.0.sql (tabela conteudo.afirmacao). Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;
ALTER TABLE conteudo.artefato DROP CONSTRAINT IF EXISTS artefato_tipo_check;
ALTER TABLE conteudo.artefato ADD CONSTRAINT artefato_tipo_check CHECK (tipo IN ('aula', 'banco_dificuldade', 'caso', 'caso_base', 'caso_semente', 'checklist', 'flashcard', 'gabarito', 'gabarito_1', 'gabarito_2', 'gabarito_3', 'gabarito_4', 'gabarito_5', 'gabarito_6', 'item', 'mapa', 'objetivos', 'podcast_roteiro', 'protocolo', 'resumo', 'resumo_basico', 'simulado', 'sintese_evidencia', 'slides', 'teste_1', 'teste_2', 'teste_3', 'teste_4', 'teste_5', 'teste_6'));
-- renomeia o antigo 'caso semente' para 'caso base' (se ja importado)
UPDATE conteudo.artefato SET tipo='caso_base', titulo=replace(titulo,'Caso semente','Caso base'), corpo=replace(replace(corpo,'Caso semente','Caso base'),'caso semente','caso base') WHERE tipo='caso_semente';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'aula', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='aula'),0)+1, 'rascunho', $T1$Aula$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Aula: avaliação inicial do traumatizado

Duração: 30 minutos, dentro da reunião de 60 (aula 30, caso da aula 15, pós-teste D0 15). Cinco seções e quatro controvérsias marcadas.

## 1. Por que importa (4 min)
- O objetivo é achar e tratar o que mata agora [D1]; a fisiologia pesa mais que a anatomia [D26].
- PAS abaixo de 90 mmHg com laparotomia de emergência: mortalidade acima de 40% [D27].
- Treinamento associa-se a menor mortalidade (OR 0,60), em estudos observacionais [A2].
- Origem: o ATLS nasceu de um acidente em 1976, para treinar quem não atende trauma com frequência [H1, H2].

## 2. O que a evidência diz (10 min)
**[CONTROVÉRSIA 1] Quando inverter a ordem.** ABCDE é o padrão; hemorragia externa ou extremis invertem para CAB [D2, D3]; no pré-hospitalar, hemorragia maciça primeiro [D4]. A edição atual do ATLS adotou o xABCDE [D44].

**[CONTROVÉRSIA 2] Torniquete.** Pode salvar vidas [D7] e é recomendado pela diretriz como adjunto [G2], mas a revisão mostra mortalidade sem redução significativa (RR 0,70) e mais amputação inicial (RR 2,07) [A23, A24].

**[CONTROVÉRSIA 3] TC de corpo inteiro.** A diretriz recomenda TC precoce de corpo inteiro [G9], mas a revisão mostra pouco ou nenhum efeito em mortalidade [A12]; no choque, sem aumento de mortalidade precoce [A39]; lesões tardias em 13,9 % mesmo com ela [A42].

**[CONTROVÉRSIA 4] Classificar o choque.** A diretriz recomenda índice de choque e/ou pressão de pulso [G5]; viés na comparação clássica [A32]; estabilidade hemodinâmica sem consenso [A33]; agitação como sinal de choque [D17].

Estrutura: o formulário de admissão melhorou 14 de 16 indicadores [A13]; checklist melhora adesão, com efeito incerto em mortalidade [A8, A9, A10].

## 3. Como se faz (8 min)
1. Líder e funções antes da chegada [D22]; passagem MIST em até 1 minuto [D23, D24].
2. Compressão, torniquete, cinta pélvica [D6, D7, D9].
3. Via aérea: voz normal, Glasgow ≤8 [D10, D11, D12].
4. Circulação: pressão manual, intraósseo [D14, D15].
5. Glasgow repetido; despir e aquecer [D16, D18, D19].
6. Secundária com AMPLA; terciária após a ressuscitação [D21, D31].

## 4. O que dá errado (5 min)
- Aparelho automático de pressão no choque [D14].
- Agitação lida como embriaguez [D17].
- eFAST negativo encerrando a investigação [A30].
- Paciente despido e frio [A36].
- Confiança cega na TC [A42].

## 5. O que levar para o plantão (3 min)
1. Sangramento externo grave primeiro.
2. Tratar ao encontrar e reavaliar.
3. Um líder e uma passagem curta.
4. Despir, aquecer, repetir o Glasgow.
5. Avaliação terciária sempre.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='aula' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Aula: avaliação inicial do traumatizado

Duração: 30 minutos, dentro da reunião de 60 (aula 30, caso da aula 15, pós-teste D0 15). Cinco seções e quatro controvérsias marcadas.

## 1. Por que importa (4 min)
- O objetivo é achar e tratar o que mata agora [D1]; a fisiologia pesa mais que a anatomia [D26].
- PAS abaixo de 90 mmHg com laparotomia de emergência: mortalidade acima de 40% [D27].
- Treinamento associa-se a menor mortalidade (OR 0,60), em estudos observacionais [A2].
- Origem: o ATLS nasceu de um acidente em 1976, para treinar quem não atende trauma com frequência [H1, H2].

## 2. O que a evidência diz (10 min)
**[CONTROVÉRSIA 1] Quando inverter a ordem.** ABCDE é o padrão; hemorragia externa ou extremis invertem para CAB [D2, D3]; no pré-hospitalar, hemorragia maciça primeiro [D4]. A edição atual do ATLS adotou o xABCDE [D44].

**[CONTROVÉRSIA 2] Torniquete.** Pode salvar vidas [D7] e é recomendado pela diretriz como adjunto [G2], mas a revisão mostra mortalidade sem redução significativa (RR 0,70) e mais amputação inicial (RR 2,07) [A23, A24].

**[CONTROVÉRSIA 3] TC de corpo inteiro.** A diretriz recomenda TC precoce de corpo inteiro [G9], mas a revisão mostra pouco ou nenhum efeito em mortalidade [A12]; no choque, sem aumento de mortalidade precoce [A39]; lesões tardias em 13,9 % mesmo com ela [A42].

**[CONTROVÉRSIA 4] Classificar o choque.** A diretriz recomenda índice de choque e/ou pressão de pulso [G5]; viés na comparação clássica [A32]; estabilidade hemodinâmica sem consenso [A33]; agitação como sinal de choque [D17].

Estrutura: o formulário de admissão melhorou 14 de 16 indicadores [A13]; checklist melhora adesão, com efeito incerto em mortalidade [A8, A9, A10].

## 3. Como se faz (8 min)
1. Líder e funções antes da chegada [D22]; passagem MIST em até 1 minuto [D23, D24].
2. Compressão, torniquete, cinta pélvica [D6, D7, D9].
3. Via aérea: voz normal, Glasgow ≤8 [D10, D11, D12].
4. Circulação: pressão manual, intraósseo [D14, D15].
5. Glasgow repetido; despir e aquecer [D16, D18, D19].
6. Secundária com AMPLA; terciária após a ressuscitação [D21, D31].

## 4. O que dá errado (5 min)
- Aparelho automático de pressão no choque [D14].
- Agitação lida como embriaguez [D17].
- eFAST negativo encerrando a investigação [A30].
- Paciente despido e frio [A36].
- Confiança cega na TC [A42].

## 5. O que levar para o plantão (3 min)
1. Sangramento externo grave primeiro.
2. Tratar ao encontrar e reavaliar.
3. Um líder e uma passagem curta.
4. Despir, aquecer, repetir o Glasgow.
5. Avaliação terciária sempre.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D4', $af$No pré-hospitalar, a hemorragia externa maciça é tratada primeiro.$af$, 'Mattox9_cap10_pre_hospitalar', $af$In the event of external massive hemorrhage, bleeding should be addressed first.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D44', $af$Na edição atual do ATLS, o ABCDE passou a xABCDE: o x indica o controle rápido da hemorragia externa exsanguinante, que salva vidas em alguns pacientes.$af$, 'ACS_ATLS11_anuncio_2025', $af$For certain patients, rapid control of exsanguinating external hemorrhage is lifesaving. To reflect this additional focus, the letter “x” was added to the beginning of the well-known ATLS mnemonic. ABCDE is now xABCDE.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G2', $af$Recomenda-se compressão local das feridas abertas e torniquete como adjunto no sangramento de extremidade com risco de vida (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend adjunct tourniquet use to stop life-threatening bleeding from open extremity injuries in the pre-surgical setting (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G5', $af$Recomenda-se usar o índice de choque e/ou a pressão de pulso para estimar o grau de choque e a necessidade de transfusão (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the shock index (SI) and/or pulse pressure (PP) be used to assess the degree of hypovolaemic shock and transfusion requirements (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G9', $af$Recomenda-se imagem precoce com TC de corpo inteiro contrastada para identificar as lesões e a fonte de sangramento (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend early imaging using contrast-enhanced whole-body CT (WBCT) for the detection and identification of the type of injury and the potential source of bleeding (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H1', $af$O ATLS nasceu depois de um acidente aéreo em 1976 no interior de Nebraska, em que o cirurgião ortopedista James Styner se feriu, perdeu a esposa e teve três filhos gravemente feridos, e considerou errado o atendimento que receberam.$af$, 'Carmont2005_historia_ATLS', $af$He was horrified at the treatment his family received at a local hospital in rural Nebraska and decided that the established system for managing the severely injured was wrong.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H2', $af$O objetivo original era treinar médicos que não atendem trauma com frequência, como generalistas do interior, na abordagem inicial do traumatizado grave.$af$, 'Carmont2005_historia_ATLS', $af$train those doctors who do not manage trauma on a regular basis, such as rural general practitioners, in the initial management of the severely injured patient$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='aula' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='aula')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'banco_dificuldade', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='banco_dificuldade'),0)+1, 'rascunho', $T1$Banco de questões e distribuição de dificuldade$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Banco de questões e distribuição de dificuldade

Questões por perfil e teste com o grau-alvo de cada onda. O grau cresce com a onda e com a experiência do perfil. Dentro de cada teste, as questões variam um grau abaixo e um acima do alvo.

| Perfil | Pré-teste inicial | Pré-teste 2 | Pós D0 | Pós D+15 | Pós D+45 | Pós D+90 | Questão fixa |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Graduação | Muito fácil | Fácil | Fácil | Média | Média | Média | Média |
| R1 | Fácil | Média | Média | Média | Difícil | Difícil | Fácil |
| R2 | Média | Média | Difícil | Difícil | Difícil | Muito difícil | Muito fácil |
| R3 | Média | Difícil | Difícil | Muito difícil | Muito difícil | Muito difícil | Muito fácil |
| R+ | Difícil | Difícil | Muito difícil | Muito difícil | Extrema | Extrema | Muito fácil |

| Grau | Taxa de acerto esperada | Questões no banco |
| --- | --- | --- |
| Muito fácil | acima de 90% | 8 |
| Fácil | 75% a 90% | 23 |
| Média | 50% a 75% | 40 |
| Difícil | 30% a 50% | 46 |
| Muito difícil | 15% a 30% | 33 |
| Extrema | abaixo de 15% | 20 |

Total: 170 questões de caso e 1 questão fixa (igual para todos os perfis). O simulado opcional de cada aluno é formado pelas questões dos outros perfis, que ele não recebe nos testes.

A questão fixa tem grau diferente por perfil porque o mesmo enunciado é mais fácil para quem tem mais experiência.$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='banco_dificuldade' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Banco de questões e distribuição de dificuldade

Questões por perfil e teste com o grau-alvo de cada onda. O grau cresce com a onda e com a experiência do perfil. Dentro de cada teste, as questões variam um grau abaixo e um acima do alvo.

| Perfil | Pré-teste inicial | Pré-teste 2 | Pós D0 | Pós D+15 | Pós D+45 | Pós D+90 | Questão fixa |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Graduação | Muito fácil | Fácil | Fácil | Média | Média | Média | Média |
| R1 | Fácil | Média | Média | Média | Difícil | Difícil | Fácil |
| R2 | Média | Média | Difícil | Difícil | Difícil | Muito difícil | Muito fácil |
| R3 | Média | Difícil | Difícil | Muito difícil | Muito difícil | Muito difícil | Muito fácil |
| R+ | Difícil | Difícil | Muito difícil | Muito difícil | Extrema | Extrema | Muito fácil |

| Grau | Taxa de acerto esperada | Questões no banco |
| --- | --- | --- |
| Muito fácil | acima de 90% | 8 |
| Fácil | 75% a 90% | 23 |
| Média | 50% a 75% | 40 |
| Difícil | 30% a 50% | 46 |
| Muito difícil | 15% a 30% | 33 |
| Extrema | abaixo de 15% | 20 |

Total: 170 questões de caso e 1 questão fixa (igual para todos os perfis). O simulado opcional de cada aluno é formado pelas questões dos outros perfis, que ele não recebe nos testes.

A questão fixa tem grau diferente por perfil porque o mesmo enunciado é mais fácil para quem tem mais experiência.$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A3', $af$Estudo piloto de viabilidade de ensaio randomizado por conglomerados (ATLS, PTC e cuidado padrão) incluiu 376 pacientes e 22 residentes.$af$, '2025_36', $af$We included 376 patients and 22 residents.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A6', $af$O custo de implementação de programas de treinamento variou de USD 3,70 (primeiro respondedor leigo) a USD 1433,5 (ATLS).$af$, '2026_42', $af$starting from USD 3.70 (Lay-First-Responder) to USD 1433.5 (Advanced Trauma Life Support)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A22', $af$A sobrevida no grupo com colaboração próxima entre radiologia intervencionista e cirurgia foi 15,5% maior que a prevista (IC 95% 7,5–23,6%).$af$, '2024_64', $af$the survival rate in the CG was 15.5% higher than the Ps (95% CI: 7.5–23.6%; p < 0.001)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A47', $af$O estudo que mostrou baixa sensibilidade do ultrassom torácico incluiu só trauma torácico fechado.$af$, '2024_47', $af$A prospective observational analysis of patients with blunt chest trauma$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D13', $af$No trauma penetrante sem indicação de proteção cervical, sentar o paciente para que cuspa ou aspire o sangue pode controlar a via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$merely placing patients into an upright sitting position and allowing them to spit or suction the blood$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='banco_dificuldade' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='banco_dificuldade')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'caso', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='caso'),0)+1, 'rascunho', $T1$Caso da aula$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Caso da aula (fictício, para discussão em pequenos grupos)

Duração: 15 minutos na reunião. Dados inventados; nenhum paciente real.

Homem, 34 anos, colisão moto × automóvel. Chega com torniquete na coxa esquerda, aplicado no local por sangramento volumoso. Agitado, FC 128, PA 92/58 no aparelho automático, SpO2 91% em ar ambiente, temperatura 34,9 °C.

**Ponto de decisão 1 — Por onde começar?**
Situação: O paciente entra na sala de trauma. O curativo sob o torniquete está encharcado de sangue.
Discussão: Hemorragia externa com risco de vida: a circulação vem antes da via aérea (CAB) [D2]. Reavaliar o torniquete; o torniquete pode salvar a vida [D7], mas associa-se a mais amputação inicial (RR 2,07) [A24]. Se optar por compressão direta, lembrar que a pressão aplicada varia muito e a percepção de quem aplica não é confiável [D6, A26].

**Ponto de decisão 2 — Ele está agitado**
Situação: O paciente grita e tenta tirar o colar. Um colega sugere sedá-lo para continuar o exame.
Discussão: Agitação pode ser choque classe III ou IV [D17]. Se for preciso intubar, fazer exame neurológico breve antes da sedação [D12].

**Ponto de decisão 3 — Oxigênio e tórax**
Situação: Hemorragia controlada. SpO2 segue em 91%. O eFAST não mostra pneumotórax.
Discussão: Oxigênio guiado pela SpO2, e não para todos [A27]. eFAST negativo não encerra a investigação [A29, A30].

**Ponto de decisão 4 — A pressão melhorou?**
Situação: O aparelho automático marca PA 104/66. A pele segue fria.
Discussão: O aparelho automático pode errar no choque [D14]; medir manualmente. Não decidir por um número isolado [A32, A33].

**Ponto de decisão 5 — Temperatura e TC**
Situação: Temperatura 34,9 °C; a TC está a poucos minutos.
Discussão: Aquecer com mantas, ar forçado e fluidos aquecidos [D19]; a hipotermia é subvalorizada [A36]. A TC de corpo inteiro tem benefício incerto em mortalidade [A12] e, no choque, não aumentou a mortalidade precoce [A39].

**Ponto de decisão 6 — No dia seguinte**
Situação: A TC não mostrou outras lesões. No primeiro dia, ele se queixa de dor no punho direito.
Discussão: Lesões de diagnóstico tardio ocorrem mesmo com TC (13,9 %) [A42]; a avaliação terciária é feita depois da ressuscitação e das cirurgias [D31] e reduz lesões não identificadas [D30].

**Desfecho**
A radiografia mostra fratura do rádio distal, tratada com imobilização. O torniquete foi retirado no centro cirúrgico, com reparo vascular. O paciente teve alta da UTI no terceiro dia. Lição: a avaliação terciária encontrou o que a sala de trauma e a TC não viram [D30, A42].
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='caso' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Caso da aula (fictício, para discussão em pequenos grupos)

Duração: 15 minutos na reunião. Dados inventados; nenhum paciente real.

Homem, 34 anos, colisão moto × automóvel. Chega com torniquete na coxa esquerda, aplicado no local por sangramento volumoso. Agitado, FC 128, PA 92/58 no aparelho automático, SpO2 91% em ar ambiente, temperatura 34,9 °C.

**Ponto de decisão 1 — Por onde começar?**
Situação: O paciente entra na sala de trauma. O curativo sob o torniquete está encharcado de sangue.
Discussão: Hemorragia externa com risco de vida: a circulação vem antes da via aérea (CAB) [D2]. Reavaliar o torniquete; o torniquete pode salvar a vida [D7], mas associa-se a mais amputação inicial (RR 2,07) [A24]. Se optar por compressão direta, lembrar que a pressão aplicada varia muito e a percepção de quem aplica não é confiável [D6, A26].

**Ponto de decisão 2 — Ele está agitado**
Situação: O paciente grita e tenta tirar o colar. Um colega sugere sedá-lo para continuar o exame.
Discussão: Agitação pode ser choque classe III ou IV [D17]. Se for preciso intubar, fazer exame neurológico breve antes da sedação [D12].

**Ponto de decisão 3 — Oxigênio e tórax**
Situação: Hemorragia controlada. SpO2 segue em 91%. O eFAST não mostra pneumotórax.
Discussão: Oxigênio guiado pela SpO2, e não para todos [A27]. eFAST negativo não encerra a investigação [A29, A30].

**Ponto de decisão 4 — A pressão melhorou?**
Situação: O aparelho automático marca PA 104/66. A pele segue fria.
Discussão: O aparelho automático pode errar no choque [D14]; medir manualmente. Não decidir por um número isolado [A32, A33].

**Ponto de decisão 5 — Temperatura e TC**
Situação: Temperatura 34,9 °C; a TC está a poucos minutos.
Discussão: Aquecer com mantas, ar forçado e fluidos aquecidos [D19]; a hipotermia é subvalorizada [A36]. A TC de corpo inteiro tem benefício incerto em mortalidade [A12] e, no choque, não aumentou a mortalidade precoce [A39].

**Ponto de decisão 6 — No dia seguinte**
Situação: A TC não mostrou outras lesões. No primeiro dia, ele se queixa de dor no punho direito.
Discussão: Lesões de diagnóstico tardio ocorrem mesmo com TC (13,9 %) [A42]; a avaliação terciária é feita depois da ressuscitação e das cirurgias [D31] e reduz lesões não identificadas [D30].

**Desfecho**
A radiografia mostra fratura do rádio distal, tratada com imobilização. O torniquete foi retirado no centro cirúrgico, com reparo vascular. O paciente teve alta da UTI no terceiro dia. Lição: a avaliação terciária encontrou o que a sala de trauma e a TC não viram [D30, A42].
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='caso' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='caso')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'caso_base', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='caso_base'),0)+1, 'rascunho', $T1$Caso base$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Caso base

Tempo: cerca de 5 minutos. Caso fictício, para levantar dúvidas que serão discutidas na aula. Não há respostas aqui: anote as suas.

**Situação.** São 23h. A equipe do SAMU avisa por rádio: mulher de 27 anos, ciclista atropelada por carro, ferimento na coxa direita sangrando muito, consciente, chegada em 8 minutos. A sala de trauma tem um residente do segundo ano, um do primeiro ano, dois enfermeiros e o cirurgião assistente a caminho.

**Na chegada.** Ela grita de dor e pede para ser solta da prancha. Há um curativo encharcado na coxa. A pele está fria e úmida. O aparelho automático marca PA 118/76. A saturação é 95%. A equipe do SAMU começa a contar o caso enquanto todos já estão em volta da maca.

**Perguntas para você levar à aula**

1. Quem deveria liderar até o assistente chegar, e o que fazer nos 8 minutos de espera?
2. Por onde você começaria: via aérea ou coxa? Por quê?
3. Ela está gritando e agitada. Isso tranquiliza ou preocupa?
4. A pressão de 118/76 no aparelho automático é confiável neste momento?
5. Ela precisa de oxigênio?
6. Se a compressão não parar o sangramento, o que vem a seguir? E se um torniquete for colocado, quais os riscos?
7. A passagem do SAMU foi feita da melhor forma?
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='caso_base' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Caso base

Tempo: cerca de 5 minutos. Caso fictício, para levantar dúvidas que serão discutidas na aula. Não há respostas aqui: anote as suas.

**Situação.** São 23h. A equipe do SAMU avisa por rádio: mulher de 27 anos, ciclista atropelada por carro, ferimento na coxa direita sangrando muito, consciente, chegada em 8 minutos. A sala de trauma tem um residente do segundo ano, um do primeiro ano, dois enfermeiros e o cirurgião assistente a caminho.

**Na chegada.** Ela grita de dor e pede para ser solta da prancha. Há um curativo encharcado na coxa. A pele está fria e úmida. O aparelho automático marca PA 118/76. A saturação é 95%. A equipe do SAMU começa a contar o caso enquanto todos já estão em volta da maca.

**Perguntas para você levar à aula**

1. Quem deveria liderar até o assistente chegar, e o que fazer nos 8 minutos de espera?
2. Por onde você começaria: via aérea ou coxa? Por quê?
3. Ela está gritando e agitada. Isso tranquiliza ou preocupa?
4. A pressão de 118/76 no aparelho automático é confiável neste momento?
5. Ela precisa de oxigênio?
6. Se a compressão não parar o sangramento, o que vem a seguir? E se um torniquete for colocado, quais os riscos?
7. A passagem do SAMU foi feita da melhor forma?
$T1$);
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'checklist', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='checklist'),0)+1, 'rascunho', $T1$Checklists$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Checklist da sala de trauma (PROPOSTA para validação)

**Antes da chegada**
- [ ] Líder definido e papéis distribuídos [A21]
- [ ] Sala aquecida; manta/fluido aquecido disponíveis [A36]
- [ ] Formulário de admissão do trauma em mãos [A13]

**Avaliação primária**
- [ ] x — Hemorragia externa controlada; horário do torniquete registrado [A24]
- [ ] A — Via aérea avaliada e registrada [A14]
- [ ] B — SpO2 medida; O2 conforme SpO2 [A27]
- [ ] B — eFAST realizado; se negativo com suspeita clínica, investigação mantida [A30]
- [ ] C — Sinais vitais + avaliação por ultrassom (FAST/RUSH); pelve avaliada [A34, A35]
- [ ] D — Glasgow registrado na chegada e repetido [D16]
- [ ] E — Exposição completa; temperatura medida; aquecimento iniciado [A36]

**Antes de sair da sala**
- [ ] Indicação de TC discutida pela equipe [A12]
- [ ] Pendências comunicadas em voz alta

**Depois da ressuscitação e das intervenções** [D31]
- [ ] Avaliação terciária realizada e registrada [A42]
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='checklist' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Checklist da sala de trauma (PROPOSTA para validação)

**Antes da chegada**
- [ ] Líder definido e papéis distribuídos [A21]
- [ ] Sala aquecida; manta/fluido aquecido disponíveis [A36]
- [ ] Formulário de admissão do trauma em mãos [A13]

**Avaliação primária**
- [ ] x — Hemorragia externa controlada; horário do torniquete registrado [A24]
- [ ] A — Via aérea avaliada e registrada [A14]
- [ ] B — SpO2 medida; O2 conforme SpO2 [A27]
- [ ] B — eFAST realizado; se negativo com suspeita clínica, investigação mantida [A30]
- [ ] C — Sinais vitais + avaliação por ultrassom (FAST/RUSH); pelve avaliada [A34, A35]
- [ ] D — Glasgow registrado na chegada e repetido [D16]
- [ ] E — Exposição completa; temperatura medida; aquecimento iniciado [A36]

**Antes de sair da sala**
- [ ] Indicação de TC discutida pela equipe [A12]
- [ ] Pendências comunicadas em voz alta

**Depois da ressuscitação e das intervenções** [D31]
- [ ] Avaliação terciária realizada e registrada [A42]
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='checklist' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='checklist')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'flashcard', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='flashcard'),0)+1, 'rascunho', $T1$Flashcards$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Flashcards (18)

| # | Frente | Verso |
|---|---|---|
| 1 | O que significa a associação OR 0,60 entre treinamento em suporte de vida e mortalidade? | Menor mortalidade associada ao treinamento, porém em estudos observacionais — não prova causalidade [A2]. |
| 2 | Existe evidência de alta qualidade de que o ATLS melhora desfechos? | Não, segundo os autores do ensaio ADVANCE TRAUMA [A4]. |
| 3 | Que tipo de estudo sustenta o uso de checklist na ressuscitação? | Estudos antes-e-depois [A7]. |
| 4 | Efeito adverso associado a checklist em um estudo? | Maior incidência de pneumonia (aOR 1,69) [A10]. |
| 5 | Quantos indicadores melhoraram com o formulário de admissão (TIF)? | 14 de 16 [A13]. |
| 6 | Avaliação de via aérea antes e depois do TIF? | 72,9% → 98,4% [A14]. |
| 7 | Torniquete pré-hospitalar e mortalidade? | RR 0,70 (IC 95% 0,46–1,07): redução não significativa [A23]. |
| 8 | Torniquete e amputação inicial? | Mais frequente: 19,32% vs. 6,4% (RR 2,07) [A24]. |
| 9 | A percepção de quem aplica o curativo compressivo é confiável? | Não: sem correlação com a pressão medida (p = 0,541) [A26]. |
| 10 | E-FAST para pneumotórax: melhor resultado publicado? | Sensibilidade 93,6% e especificidade 99,8% [A29] — mas há estudo com baixa sensibilidade [A30]. |
| 11 | Adrenalina na parada traumática extra-hospitalar? | Associada a menor sobrevida em 7 dias (OR 0,20) [A31]. |
| 12 | Sensibilidade do RUSH em politraumatizados instáveis? | 94,2% [A34]. |
| 13 | Frequência de hipotermia no trauma grave? | Até dois terços dos pacientes [A36]. |
| 14 | TC de corpo inteiro de rotina reduz mortalidade? | Parece ter pouco ou nenhum efeito [A12]. |
| 15 | Lesões com diagnóstico tardio mesmo com TC de corpo inteiro? | 13,9 % dos pacientes [A42]. |
| 16 | SILENT: sensibilidade e especificidade? | 75% e 99% [A43]. |
| 17 | Efeito da presença do cirurgião de trauma no tempo de ressuscitação? | 259 segundos a menos [A19]. |
| 18 | Líder cirurgião vs. não cirurgião: lesões não identificadas? | Menos com cirurgião (OR 0,48) [A21]. |
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='flashcard' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Flashcards (18)

| # | Frente | Verso |
|---|---|---|
| 1 | O que significa a associação OR 0,60 entre treinamento em suporte de vida e mortalidade? | Menor mortalidade associada ao treinamento, porém em estudos observacionais — não prova causalidade [A2]. |
| 2 | Existe evidência de alta qualidade de que o ATLS melhora desfechos? | Não, segundo os autores do ensaio ADVANCE TRAUMA [A4]. |
| 3 | Que tipo de estudo sustenta o uso de checklist na ressuscitação? | Estudos antes-e-depois [A7]. |
| 4 | Efeito adverso associado a checklist em um estudo? | Maior incidência de pneumonia (aOR 1,69) [A10]. |
| 5 | Quantos indicadores melhoraram com o formulário de admissão (TIF)? | 14 de 16 [A13]. |
| 6 | Avaliação de via aérea antes e depois do TIF? | 72,9% → 98,4% [A14]. |
| 7 | Torniquete pré-hospitalar e mortalidade? | RR 0,70 (IC 95% 0,46–1,07): redução não significativa [A23]. |
| 8 | Torniquete e amputação inicial? | Mais frequente: 19,32% vs. 6,4% (RR 2,07) [A24]. |
| 9 | A percepção de quem aplica o curativo compressivo é confiável? | Não: sem correlação com a pressão medida (p = 0,541) [A26]. |
| 10 | E-FAST para pneumotórax: melhor resultado publicado? | Sensibilidade 93,6% e especificidade 99,8% [A29] — mas há estudo com baixa sensibilidade [A30]. |
| 11 | Adrenalina na parada traumática extra-hospitalar? | Associada a menor sobrevida em 7 dias (OR 0,20) [A31]. |
| 12 | Sensibilidade do RUSH em politraumatizados instáveis? | 94,2% [A34]. |
| 13 | Frequência de hipotermia no trauma grave? | Até dois terços dos pacientes [A36]. |
| 14 | TC de corpo inteiro de rotina reduz mortalidade? | Parece ter pouco ou nenhum efeito [A12]. |
| 15 | Lesões com diagnóstico tardio mesmo com TC de corpo inteiro? | 13,9 % dos pacientes [A42]. |
| 16 | SILENT: sensibilidade e especificidade? | 75% e 99% [A43]. |
| 17 | Efeito da presença do cirurgião de trauma no tempo de ressuscitação? | 259 segundos a menos [A19]. |
| 18 | Líder cirurgião vs. não cirurgião: lesões não identificadas? | Menos com cirurgião (OR 0,48) [A21]. |
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='flashcard' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='flashcard')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito_1', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_1'),0)+1, 'rascunho', $T1$Gabarito comentado — Pré-teste inicial$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pré-teste inicial

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D6, D10
- A) erro técnico: Exame de imagem não vem antes de controlar um sangramento que mata em minutos.
- B) **correta**: hemorragia externa com risco de vida vem primeiro, começando pela compressão direta.
- C) erro de conduta: Transportar sangrando para a tomografia é perigoso e atrasa o tratamento.
- D) erro conceitual: A história faz parte da avaliação secundária, depois da primária.
- E) erro de indicação: Ela fala com voz normal: a via aérea está pérvia e intubar agora atrasa o controle do sangramento.

**3. Resposta E** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D10, D11
- A) erro técnico: A fala não informa sobre a coluna.
- B) erro de indicação: Via aérea definitiva é indicada por Glasgow ≤8 ou obstrução, não por fala normal.
- C) erro conceitual: Quem responde às perguntas não tem Glasgow tão baixo.
- D) erro de conduta: Falar não exclui choque: FC 124 e pele fria sugerem o contrário.
- E) **correta**: quem fala com voz normal não tem obstrução de via aérea.

**4. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2
- A) **correta**: hemorragia externa com risco de vida inverte a ordem (CAB).
- B) erro de indicação: O que muda a ordem é o sangramento grave, não o tipo de fratura.
- C) erro conceitual: A idade não muda a ordem da avaliação.
- D) erro técnico: A ordem de medida dos sinais vitais não define a prioridade.
- E) erro de conduta: A via aérea é prioridade na maioria dos casos; a inversão é a exceção.

**5. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D19, A36
- A) erro técnico: Água fria piora a hipotermia.
- B) erro conceitual: Esperar a hipotermia grave contraria a prevenção, que é a prioridade.
- C) erro de conduta: Deixar o paciente descoberto favorece hipotermia.
- D) **correta**: terminado o exame, manter o paciente aquecido é prioridade.
- E) erro de indicação: Aquecer não depende de exame de imagem.


## Perfil R1

**1. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D7, D8, D2
- A) erro técnico: Pinçar às cegas pode lesar nervos e piorar o sangramento.
- B) erro de conduta: Observar sangramento ativo não controlado é perder tempo.
- C) **correta**: no trauma de membro, o torniquete pode salvar a vida.
- D) erro de indicação: A via aérea está pérvia; intubar atrasa o controle do sangramento.
- E) erro conceitual: Imagem não precede o controle de hemorragia com risco de vida.

**3. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D14, D17
- A) erro conceitual: FC 124 e pele fria sugerem choque apesar do número.
- B) erro técnico: Pressão isolada não dispensa a reavaliação.
- C) erro de conduta: Suspender a reposição com base num número possivelmente errado é erro de conduta.
- D) erro de indicação: Atribuir a taquicardia à dor sem excluir sangramento é perigoso.
- E) **correta**: o aparelho automático pode errar no choque.

**4. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D15, D28
- A) erro de indicação: Insistir prolongadamente atrasa a ressuscitação.
- B) **correta**: sem acesso venoso imediato, considerar o intraósseo.
- C) erro técnico: Infusão arterial não é via de reposição.
- D) erro de conduta: Adiar a reposição no choque é erro de conduta.
- E) erro conceitual: Via oral não serve para ressuscitação no choque.

**5. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D18, D19
- A) **correta**: a exposição completa permite o exame em 360 graus.
- B) erro técnico: Cinta pélvica é indicada pelo risco, não justifica despir.
- C) erro de conduta: A exposição vale para todo trauma, não só o penetrante.
- D) erro conceitual: Limpeza não é o objetivo da exposição.
- E) erro de indicação: Despir favorece a perda de calor; por isso se aquece depois.


## Perfil R2

**1. Resposta D** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A23, A24, D7
- A) erro de indicação: A amputação inicial foi mais frequente no grupo torniquete.
- B) **correta**: RR 0,70 não significativo para mortalidade e RR 2,07 para amputação inicial.
- C) erro conceitual: A redução (RR 0,70) não foi estatisticamente significativa.
- D) erro técnico: Não há essa restrição; o torniquete serve para o trauma de membro.
- E) erro de conduta: Não houve aumento de mortalidade.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A32, A33
- A) erro de indicação: Os parâmetros clássicos tiveram viés e não há consenso sobre estabilidade.
- B) erro conceitual: Pacientes jovens podem compensar com lucidez preservada.
- C) **correta**: a classe de choque pelos parâmetros tradicionais foi superestimada e a definição de estabilidade é heterogênea.
- D) erro técnico: Sedar sem indicação piora a avaliação.
- E) erro de conduta: Esperar a hipotensão atrasa o tratamento.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D9
- A) erro de conduta: Laparotomia não é o tratamento do sangramento pélvico.
- B) erro conceitual: Retirar a cinta para imagem expõe a novo sangramento.
- C) erro de indicação: Esperar a imagem atrasa o controle do sangramento.
- D) **correta**: nos pacientes de alto risco, a cinta pélvica deve ser colocada imediatamente.
- E) erro técnico: Manipular a bacia não controla o sangramento e atrasa a cinta.

**5. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D1, D5
- A) **correta**: a avaliação inicial identifica e trata todas as lesões que ameaçam a vida, seguindo as demais letras.
- B) erro conceitual: Controlar um problema não exclui outros.
- C) erro de indicação: A radiografia é adjunta, não o fim da avaliação.
- D) erro técnico: A FC sozinha não completa a avaliação.
- E) erro de conduta: Ainda faltam via aérea, respiração, neurológico e exposição.


## Perfil R3

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D22, D29
- A) **correta**: com o pré-aviso, o líder dirige a equipe e distribui tarefas antes da chegada.
- B) erro de indicação: Reservar a TC não substitui o preparo da equipe.
- C) erro técnico: Sem funções definidas, a avaliação fica desorganizada.
- D) erro de conduta: Distribuir funções depois da chegada desperdiça tempo.
- E) erro conceitual: Treinandos podem liderar, mas sob supervisão próxima.

**3. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D23, D24
- A) erro conceitual: Faltariam mecanismo, lesões suspeitas e tratamentos.
- B) erro de conduta: A informação é necessária na chegada, não depois.
- C) erro técnico: Examinar enquanto o caso é contado faz a equipe perder informação.
- D) **correta**: passagem estruturada como o MIST, em no máximo 45 segundos a 1 minuto.
- E) erro de indicação: A passagem longa atrasa o atendimento.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D26, A39
- A) erro conceitual: Sinais de choque persistentes indicam que algo não está resolvido.
- B) erro técnico: Esperar exame laboratorial atrasa a conduta.
- C) erro de conduta: Alta da sala sem completar a avaliação é erro grave.
- D) **correta**: a fisiologia é o maior determinante do desfecho; o destino depende da resposta.
- E) erro de indicação: Levar à TC um paciente sem resposta clara à ressuscitação é arriscado.

**5. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A13, A14, A15, A45, A46
- A) erro de indicação: A mortalidade foi desfecho secundário e caiu no subgrupo com fisiologia alterada, em ensaio randomizado por conglomerados.
- B) erro conceitual: Houve melhora em 14 de 16 indicadores.
- C) erro de conduta: Não houve aumento de mortalidade.
- D) erro técnico: Os indicadores melhorados são do cuidado, não só do registro.
- E) **correta**: melhora em 14 de 16 indicadores; registro da via aérea de 72,9% para 98,4%.


## Perfil R+

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D7, A23, A24
- A) erro de conduta: Não houve aumento de mortalidade.
- B) erro técnico: Há revisão sistemática sobre o tema.
- C) erro conceitual: A redução de mortalidade não foi significativa (RR 0,70).
- D) erro de indicação: A revisão estudou o torniquete pré-hospitalar.
- E) **correta**: há conflito entre doutrina e evidência observacional, que precisa ser interpretado.

**3. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A2, A4
- A) **correta**: associação em estudos observacionais; falta evidência de alta qualidade.
- B) erro conceitual: Não há ensaio randomizado de alta qualidade demonstrando benefício.
- C) erro de conduta: Há associação com menor mortalidade.
- D) erro de indicação: Não há dado que sustente isso.
- E) erro técnico: Não há dado que sustente isso.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A31
- A) erro de conduta: Dar adrenalina antes de tratar a causa contraria a prioridade.
- B) erro técnico: Houve associação significativa.
- C) erro conceitual: A associação foi com menor sobrevida.
- D) erro de indicação: Não há esse dado.
- E) **correta**: menor sobrevida em 7 dias, em dado observacional; na parada traumática, o foco é a causa.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A7, A9, A10
- A) erro de indicação: O benefício de mortalidade apareceu justamente no ISS > 25.
- B) **correta**: evidência antes-e-depois, com sinal de efeito adverso (pneumonia, aOR 1,69); monitorar desfechos.
- C) erro conceitual: Não há ensaios; os estudos são antes-e-depois.
- D) erro técnico: Há revisão sistemática sobre o tema.
- E) erro de conduta: Um estudo mostrou menor mortalidade no ISS > 25.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_1' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pré-teste inicial

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D6, D10
- A) erro técnico: Exame de imagem não vem antes de controlar um sangramento que mata em minutos.
- B) **correta**: hemorragia externa com risco de vida vem primeiro, começando pela compressão direta.
- C) erro de conduta: Transportar sangrando para a tomografia é perigoso e atrasa o tratamento.
- D) erro conceitual: A história faz parte da avaliação secundária, depois da primária.
- E) erro de indicação: Ela fala com voz normal: a via aérea está pérvia e intubar agora atrasa o controle do sangramento.

**3. Resposta E** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D10, D11
- A) erro técnico: A fala não informa sobre a coluna.
- B) erro de indicação: Via aérea definitiva é indicada por Glasgow ≤8 ou obstrução, não por fala normal.
- C) erro conceitual: Quem responde às perguntas não tem Glasgow tão baixo.
- D) erro de conduta: Falar não exclui choque: FC 124 e pele fria sugerem o contrário.
- E) **correta**: quem fala com voz normal não tem obstrução de via aérea.

**4. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2
- A) **correta**: hemorragia externa com risco de vida inverte a ordem (CAB).
- B) erro de indicação: O que muda a ordem é o sangramento grave, não o tipo de fratura.
- C) erro conceitual: A idade não muda a ordem da avaliação.
- D) erro técnico: A ordem de medida dos sinais vitais não define a prioridade.
- E) erro de conduta: A via aérea é prioridade na maioria dos casos; a inversão é a exceção.

**5. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D19, A36
- A) erro técnico: Água fria piora a hipotermia.
- B) erro conceitual: Esperar a hipotermia grave contraria a prevenção, que é a prioridade.
- C) erro de conduta: Deixar o paciente descoberto favorece hipotermia.
- D) **correta**: terminado o exame, manter o paciente aquecido é prioridade.
- E) erro de indicação: Aquecer não depende de exame de imagem.


## Perfil R1

**1. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D7, D8, D2
- A) erro técnico: Pinçar às cegas pode lesar nervos e piorar o sangramento.
- B) erro de conduta: Observar sangramento ativo não controlado é perder tempo.
- C) **correta**: no trauma de membro, o torniquete pode salvar a vida.
- D) erro de indicação: A via aérea está pérvia; intubar atrasa o controle do sangramento.
- E) erro conceitual: Imagem não precede o controle de hemorragia com risco de vida.

**3. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D14, D17
- A) erro conceitual: FC 124 e pele fria sugerem choque apesar do número.
- B) erro técnico: Pressão isolada não dispensa a reavaliação.
- C) erro de conduta: Suspender a reposição com base num número possivelmente errado é erro de conduta.
- D) erro de indicação: Atribuir a taquicardia à dor sem excluir sangramento é perigoso.
- E) **correta**: o aparelho automático pode errar no choque.

**4. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D15, D28
- A) erro de indicação: Insistir prolongadamente atrasa a ressuscitação.
- B) **correta**: sem acesso venoso imediato, considerar o intraósseo.
- C) erro técnico: Infusão arterial não é via de reposição.
- D) erro de conduta: Adiar a reposição no choque é erro de conduta.
- E) erro conceitual: Via oral não serve para ressuscitação no choque.

**5. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D18, D19
- A) **correta**: a exposição completa permite o exame em 360 graus.
- B) erro técnico: Cinta pélvica é indicada pelo risco, não justifica despir.
- C) erro de conduta: A exposição vale para todo trauma, não só o penetrante.
- D) erro conceitual: Limpeza não é o objetivo da exposição.
- E) erro de indicação: Despir favorece a perda de calor; por isso se aquece depois.


## Perfil R2

**1. Resposta D** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A23, A24, D7
- A) erro de indicação: A amputação inicial foi mais frequente no grupo torniquete.
- B) **correta**: RR 0,70 não significativo para mortalidade e RR 2,07 para amputação inicial.
- C) erro conceitual: A redução (RR 0,70) não foi estatisticamente significativa.
- D) erro técnico: Não há essa restrição; o torniquete serve para o trauma de membro.
- E) erro de conduta: Não houve aumento de mortalidade.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A32, A33
- A) erro de indicação: Os parâmetros clássicos tiveram viés e não há consenso sobre estabilidade.
- B) erro conceitual: Pacientes jovens podem compensar com lucidez preservada.
- C) **correta**: a classe de choque pelos parâmetros tradicionais foi superestimada e a definição de estabilidade é heterogênea.
- D) erro técnico: Sedar sem indicação piora a avaliação.
- E) erro de conduta: Esperar a hipotensão atrasa o tratamento.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D9
- A) erro de conduta: Laparotomia não é o tratamento do sangramento pélvico.
- B) erro conceitual: Retirar a cinta para imagem expõe a novo sangramento.
- C) erro de indicação: Esperar a imagem atrasa o controle do sangramento.
- D) **correta**: nos pacientes de alto risco, a cinta pélvica deve ser colocada imediatamente.
- E) erro técnico: Manipular a bacia não controla o sangramento e atrasa a cinta.

**5. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D1, D5
- A) **correta**: a avaliação inicial identifica e trata todas as lesões que ameaçam a vida, seguindo as demais letras.
- B) erro conceitual: Controlar um problema não exclui outros.
- C) erro de indicação: A radiografia é adjunta, não o fim da avaliação.
- D) erro técnico: A FC sozinha não completa a avaliação.
- E) erro de conduta: Ainda faltam via aérea, respiração, neurológico e exposição.


## Perfil R3

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D22, D29
- A) **correta**: com o pré-aviso, o líder dirige a equipe e distribui tarefas antes da chegada.
- B) erro de indicação: Reservar a TC não substitui o preparo da equipe.
- C) erro técnico: Sem funções definidas, a avaliação fica desorganizada.
- D) erro de conduta: Distribuir funções depois da chegada desperdiça tempo.
- E) erro conceitual: Treinandos podem liderar, mas sob supervisão próxima.

**3. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D23, D24
- A) erro conceitual: Faltariam mecanismo, lesões suspeitas e tratamentos.
- B) erro de conduta: A informação é necessária na chegada, não depois.
- C) erro técnico: Examinar enquanto o caso é contado faz a equipe perder informação.
- D) **correta**: passagem estruturada como o MIST, em no máximo 45 segundos a 1 minuto.
- E) erro de indicação: A passagem longa atrasa o atendimento.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D26, A39
- A) erro conceitual: Sinais de choque persistentes indicam que algo não está resolvido.
- B) erro técnico: Esperar exame laboratorial atrasa a conduta.
- C) erro de conduta: Alta da sala sem completar a avaliação é erro grave.
- D) **correta**: a fisiologia é o maior determinante do desfecho; o destino depende da resposta.
- E) erro de indicação: Levar à TC um paciente sem resposta clara à ressuscitação é arriscado.

**5. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A13, A14, A15, A45, A46
- A) erro de indicação: A mortalidade foi desfecho secundário e caiu no subgrupo com fisiologia alterada, em ensaio randomizado por conglomerados.
- B) erro conceitual: Houve melhora em 14 de 16 indicadores.
- C) erro de conduta: Não houve aumento de mortalidade.
- D) erro técnico: Os indicadores melhorados são do cuidado, não só do registro.
- E) **correta**: melhora em 14 de 16 indicadores; registro da via aérea de 72,9% para 98,4%.


## Perfil R+

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D7, A23, A24
- A) erro de conduta: Não houve aumento de mortalidade.
- B) erro técnico: Há revisão sistemática sobre o tema.
- C) erro conceitual: A redução de mortalidade não foi significativa (RR 0,70).
- D) erro de indicação: A revisão estudou o torniquete pré-hospitalar.
- E) **correta**: há conflito entre doutrina e evidência observacional, que precisa ser interpretado.

**3. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A2, A4
- A) **correta**: associação em estudos observacionais; falta evidência de alta qualidade.
- B) erro conceitual: Não há ensaio randomizado de alta qualidade demonstrando benefício.
- C) erro de conduta: Há associação com menor mortalidade.
- D) erro de indicação: Não há dado que sustente isso.
- E) erro técnico: Não há dado que sustente isso.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A31
- A) erro de conduta: Dar adrenalina antes de tratar a causa contraria a prioridade.
- B) erro técnico: Houve associação significativa.
- C) erro conceitual: A associação foi com menor sobrevida.
- D) erro de indicação: Não há esse dado.
- E) **correta**: menor sobrevida em 7 dias, em dado observacional; na parada traumática, o foco é a causa.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A7, A9, A10
- A) erro de indicação: O benefício de mortalidade apareceu justamente no ISS > 25.
- B) **correta**: evidência antes-e-depois, com sinal de efeito adverso (pneumonia, aOR 1,69); monitorar desfechos.
- C) erro conceitual: Não há ensaios; os estudos são antes-e-depois.
- D) erro técnico: Há revisão sistemática sobre o tema.
- E) erro de conduta: Um estudo mostrou menor mortalidade no ISS > 25.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito_2', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_2'),0)+1, 'rascunho', $T1$Gabarito comentado — Pré-teste após o conhecimento básico$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pré-teste após o conhecimento básico

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D10
- A) erro de conduta: Quem fala e responde não tem Glasgow tão baixo.
- B) erro de indicação: Falar não indica intubação.
- C) **correta**: quem fala com voz normal não tem obstrução.
- D) erro conceitual: Falar não exclui lesão torácica.
- E) erro técnico: A fala não informa sobre a coluna.

**3. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora A27
- A) erro de indicação: Não se espera exame de imagem para tratar hipoxemia.
- B) **correta**: a prática caminha para oxigênio guiado pela SpO2; aqui a saturação está baixa.
- C) erro técnico: O eFAST não é o critério para oxigênio.
- D) erro conceitual: Oxigênio é usado quando indicado.
- E) erro de conduta: Esperar a parada é erro de conduta.

**4. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D18, D19
- A) erro de indicação: Lesões podem estar escondidas sem sangue visível.
- B) **correta**: a exposição completa permite o exame em 360 graus; depois se aquece.
- C) erro de conduta: O frio se evita aquecendo depois do exame, não deixando de examinar.
- D) erro técnico: Outras lesões podem passar despercebidas.
- E) erro conceitual: Lesões precisam ser vistas antes.

**5. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D1, D20
- A) erro conceitual: O diagnóstico completo é tarefa da secundária e da terciária.
- B) erro de conduta: Não é momento de alta.
- C) erro de indicação: A história vem depois.
- D) **correta**: esse é o objetivo da avaliação inicial.
- E) erro técnico: O registro acompanha, mas não é o objetivo.

**6. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D24, D23
- A) erro de conduta: Passagem longa atrasa o atendimento.
- B) **correta**: a passagem não deve passar de 45 segundos a 1 minuto.
- C) erro conceitual: A passagem verbal estruturada melhora a comunicação.
- D) erro técnico: A equipe deve ouvir antes de examinar, salvo extremis.
- E) erro de indicação: O líder conduz e limita a passagem.

**7. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora A30, A29
- A) erro de conduta: O eFAST inclui a avaliação do tórax.
- B) erro conceitual: Os estudos são conflitantes.
- C) erro técnico: Não há esse critério nas fontes.
- D) **correta**: estudo prospectivo mostrou baixa sensibilidade e muitos falsos negativos.
- E) erro de indicação: Falar não exclui pneumotórax.


## Perfil R1

**1. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D23, D24
- A) erro conceitual: A passagem verbal estruturada melhora a comunicação.
- B) erro de indicação: O líder conduz a passagem para toda a equipe.
- C) **correta**: fora do extremis, a passagem é feita antes ou durante a passagem para a maca, com a equipe ouvindo.
- D) erro de conduta: A informação é necessária na chegada.
- E) erro técnico: Examinar enquanto ouve faz perder informação.

**3. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D23
- A) **correta**: 
- B) erro técnico: Não são os elementos do MIST.
- C) erro de conduta: Não são os elementos do MIST.
- D) erro conceitual: Não são os elementos do MIST.
- E) erro de indicação: Não são os elementos do MIST.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D14, A33
- A) erro de conduta: O acesso venoso faz parte da avaliação da circulação.
- B) erro de indicação: Atribuir à ansiedade sem excluir sangramento é perigoso.
- C) erro conceitual: Não há definição consensual de estabilidade que permita concluir isso.
- D) **correta**: o aparelho automático pode errar no choque.
- E) erro técnico: Esperar a hipotensão atrasa o tratamento.

**5. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D21, D20
- A) erro conceitual: Incompleto.
- B) erro de indicação: A história faz parte da avaliação secundária.
- C) **correta**: o AMPLA organiza a história da secundária.
- D) erro de conduta: A história é colhida na secundária.
- E) erro técnico: Não é o método.

**6. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D18
- A) erro técnico: Não é esse o motivo.
- B) erro conceitual: Não é só uma rotina legal.
- C) erro de indicação: O eFAST não exclui outras feridas.
- D) erro de conduta: Feridas escondidas podem passar despercebidas.
- E) **correta**: o exame em 360 graus evita que lesões passem.

**7. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D25
- A) erro de indicação: Achados positivos exigem ação por si.
- B) **correta**: 
- C) erro conceitual: Achados positivos exigem ação.
- D) erro de conduta: O exame tem valor, com limitações.
- E) erro técnico: Vale para todo trauma.


## Perfil R2

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A30, A29
- A) erro técnico: A investigação deve continuar agora.
- B) erro de indicação: Hipoxemia não se explica por ansiedade sem investigação.
- C) erro de conduta: Não há condição para alta.
- D) **correta**: há estudo com baixa sensibilidade e muitos falsos negativos.
- E) erro conceitual: O resultado negativo não basta com a clínica alterada.

**3. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A29, A30
- A) erro técnico: O eFAST inclui a avaliação do tórax.
- B) erro de indicação: Exame negativo não indica drenagem.
- C) **correta**: sensibilidade de 93,6% em um estudo e baixa, com muitos falsos negativos, em outro.
- D) erro conceitual: 99,8% foi a especificidade, não a sensibilidade.
- E) erro de conduta: Sem reavaliação, um pneumotórax pode passar.

**4. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D15, D28
- A) erro conceitual: A TC não resolve o acesso.
- B) erro técnico: Insistir atrasa a ressuscitação.
- C) **correta**: o intraósseo pode salvar vidas no choque.
- D) erro de indicação: Via oral não serve.
- E) erro de conduta: Adiar a reposição é erro de conduta.

**5. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D19, A36
- A) erro de conduta: Despido, perde calor.
- B) erro técnico: Fluidos frios pioram a hipotermia.
- C) **correta**: 
- D) erro de indicação: Prevenção é prioridade.
- E) erro conceitual: Aquecer começa na sala de trauma.

**6. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D2, D3
- A) **correta**: só esses cenários invertem a ordem.
- B) erro de indicação: A idade não inverte a ordem.
- C) erro técnico: O eFAST não define a ordem.
- D) erro conceitual: O mecanismo não inverte a ordem.
- E) erro de conduta: Hipoxemia é tratada no B, não inverte a ordem.

**7. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D11, D12, A28
- A) erro conceitual: Fala difícil com Glasgow 8 não garante a via aérea.
- B) erro de indicação: A via aérea cirúrgica é exceção (0,24% numa grande coorte), não a primeira opção.
- C) erro técnico: Perde-se a informação neurológica de base.
- D) erro de conduta: Esperar piora atrasa a proteção da via aérea.
- E) **correta**: Glasgow ≤8 indica via aérea definitiva, com exame neurológico antes da sedação.


## Perfil R3

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D22
- A) erro de conduta: Fazer a via aérea tira o líder da coordenação.
- B) **correta**: o líder deve ter a 'visão grande' da sala.
- C) erro de indicação: Longe demais para coordenar.
- D) erro conceitual: Fora da sala não coordena.
- E) erro técnico: De costas não acompanha a equipe.

**3. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D22
- A) erro conceitual: Não é critério.
- B) erro de conduta: Decisões fragmentadas desorganizam a equipe.
- C) erro técnico: O enfermeiro tem outras funções.
- D) erro de indicação: O SAMU passa o caso e sai do comando.
- E) **correta**: as decisões são do líder.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A12, A42
- A) erro conceitual: Não há essa comprovação.
- B) erro de conduta: Não há esse dado.
- C) erro de indicação: A TC não substitui o exame.
- D) erro técnico: Lesões tardias ocorrem mesmo com TC.
- E) **correta**: segundo revisão de revisões.

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D24
- A) erro técnico: Atrasa a informação.
- B) erro conceitual: Passagem longa atrasa e dispersa.
- C) erro de indicação: A informação é necessária na chegada.
- D) **correta**: 
- E) erro de conduta: A passagem estruturada é útil.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D29
- A) erro de indicação: Sem supervisão, não.
- B) erro de conduta: Sem supervisão, não.
- C) erro técnico: Não é o critério.
- D) erro conceitual: Treinandos devem ter oportunidade de liderar.
- E) **correta**: 

**7. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A18
- A) erro de conduta: Não foi o que o estudo testou.
- B) erro conceitual: Houve redução de tempo com o treino in situ.
- C) **correta**: 
- D) erro de indicação: Não foi o que o estudo testou.
- E) erro técnico: Não foi o que o estudo testou.


## Perfil R+

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora A29, A30, A47
- A) erro conceitual: Um estudo mostrou baixa sensibilidade.
- B) erro de indicação: Os resultados divergem.
- C) erro técnico: A especificidade foi 99,8% no estudo citado.
- D) erro de conduta: Um estudo mostrou sensibilidade de 93,6%.
- E) **correta**: Atenção: o estudo de baixa sensibilidade incluiu só trauma torácico fechado, e o paciente do caso 2 tem ferimento penetrante.

**3. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora A27
- A) erro de conduta: Não há contraindicação.
- B) erro de indicação: Houve maioria clara.
- C) erro técnico: É pesquisa de opinião.
- D) **correta**: é opinião de profissionais, não desfecho clínico.
- E) erro conceitual: Foi o contrário.

**4. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D10, D11, D12
- A) **correta**: voz normal indica via aérea pérvia; a indicação de via aérea definitiva tem critérios.
- B) erro de conduta: A decisão não depende da TC.
- C) erro de indicação: O mecanismo não indica intubação por si.
- D) erro técnico: O exame neurológico vem antes da sedação.
- E) erro conceitual: A via aérea definitiva pode ser necessária.

**5. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D13
- A) **correta**: pode transformar uma emergência de via aérea em situação mais controlada.
- B) erro conceitual: Sedar sem preparar a via aérea é perigoso.
- C) erro de conduta: Deitado, o sangue tende a ir para a via aérea.
- D) erro técnico: Tamponar a boca obstrui a via aérea.
- E) erro de indicação: O colar não está indicado nesse cenário.

**6. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A2, A4, A5, A6
- A) **correta**: 
- B) erro conceitual: Não há ensaio de alta qualidade concluído.
- C) erro de conduta: Há associação.
- D) erro de indicação: Os custos variam muito.
- E) erro técnico: O ATLS foi o mais caro (USD 1433,5).

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A42, D30
- A) erro de indicação: Não há esse dado.
- B) erro conceitual: Há dado que contradiz.
- C) erro de conduta: Nenhum estudo mostrou isso.
- D) **correta**: 
- E) erro técnico: A terciária reduz lesões não identificadas.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_2' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pré-teste após o conhecimento básico

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D10
- A) erro de conduta: Quem fala e responde não tem Glasgow tão baixo.
- B) erro de indicação: Falar não indica intubação.
- C) **correta**: quem fala com voz normal não tem obstrução.
- D) erro conceitual: Falar não exclui lesão torácica.
- E) erro técnico: A fala não informa sobre a coluna.

**3. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora A27
- A) erro de indicação: Não se espera exame de imagem para tratar hipoxemia.
- B) **correta**: a prática caminha para oxigênio guiado pela SpO2; aqui a saturação está baixa.
- C) erro técnico: O eFAST não é o critério para oxigênio.
- D) erro conceitual: Oxigênio é usado quando indicado.
- E) erro de conduta: Esperar a parada é erro de conduta.

**4. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D18, D19
- A) erro de indicação: Lesões podem estar escondidas sem sangue visível.
- B) **correta**: a exposição completa permite o exame em 360 graus; depois se aquece.
- C) erro de conduta: O frio se evita aquecendo depois do exame, não deixando de examinar.
- D) erro técnico: Outras lesões podem passar despercebidas.
- E) erro conceitual: Lesões precisam ser vistas antes.

**5. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D1, D20
- A) erro conceitual: O diagnóstico completo é tarefa da secundária e da terciária.
- B) erro de conduta: Não é momento de alta.
- C) erro de indicação: A história vem depois.
- D) **correta**: esse é o objetivo da avaliação inicial.
- E) erro técnico: O registro acompanha, mas não é o objetivo.

**6. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D24, D23
- A) erro de conduta: Passagem longa atrasa o atendimento.
- B) **correta**: a passagem não deve passar de 45 segundos a 1 minuto.
- C) erro conceitual: A passagem verbal estruturada melhora a comunicação.
- D) erro técnico: A equipe deve ouvir antes de examinar, salvo extremis.
- E) erro de indicação: O líder conduz e limita a passagem.

**7. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora A30, A29
- A) erro de conduta: O eFAST inclui a avaliação do tórax.
- B) erro conceitual: Os estudos são conflitantes.
- C) erro técnico: Não há esse critério nas fontes.
- D) **correta**: estudo prospectivo mostrou baixa sensibilidade e muitos falsos negativos.
- E) erro de indicação: Falar não exclui pneumotórax.


## Perfil R1

**1. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D23, D24
- A) erro conceitual: A passagem verbal estruturada melhora a comunicação.
- B) erro de indicação: O líder conduz a passagem para toda a equipe.
- C) **correta**: fora do extremis, a passagem é feita antes ou durante a passagem para a maca, com a equipe ouvindo.
- D) erro de conduta: A informação é necessária na chegada.
- E) erro técnico: Examinar enquanto ouve faz perder informação.

**3. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D23
- A) **correta**: 
- B) erro técnico: Não são os elementos do MIST.
- C) erro de conduta: Não são os elementos do MIST.
- D) erro conceitual: Não são os elementos do MIST.
- E) erro de indicação: Não são os elementos do MIST.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D14, A33
- A) erro de conduta: O acesso venoso faz parte da avaliação da circulação.
- B) erro de indicação: Atribuir à ansiedade sem excluir sangramento é perigoso.
- C) erro conceitual: Não há definição consensual de estabilidade que permita concluir isso.
- D) **correta**: o aparelho automático pode errar no choque.
- E) erro técnico: Esperar a hipotensão atrasa o tratamento.

**5. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D21, D20
- A) erro conceitual: Incompleto.
- B) erro de indicação: A história faz parte da avaliação secundária.
- C) **correta**: o AMPLA organiza a história da secundária.
- D) erro de conduta: A história é colhida na secundária.
- E) erro técnico: Não é o método.

**6. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D18
- A) erro técnico: Não é esse o motivo.
- B) erro conceitual: Não é só uma rotina legal.
- C) erro de indicação: O eFAST não exclui outras feridas.
- D) erro de conduta: Feridas escondidas podem passar despercebidas.
- E) **correta**: o exame em 360 graus evita que lesões passem.

**7. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D25
- A) erro de indicação: Achados positivos exigem ação por si.
- B) **correta**: 
- C) erro conceitual: Achados positivos exigem ação.
- D) erro de conduta: O exame tem valor, com limitações.
- E) erro técnico: Vale para todo trauma.


## Perfil R2

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A30, A29
- A) erro técnico: A investigação deve continuar agora.
- B) erro de indicação: Hipoxemia não se explica por ansiedade sem investigação.
- C) erro de conduta: Não há condição para alta.
- D) **correta**: há estudo com baixa sensibilidade e muitos falsos negativos.
- E) erro conceitual: O resultado negativo não basta com a clínica alterada.

**3. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A29, A30
- A) erro técnico: O eFAST inclui a avaliação do tórax.
- B) erro de indicação: Exame negativo não indica drenagem.
- C) **correta**: sensibilidade de 93,6% em um estudo e baixa, com muitos falsos negativos, em outro.
- D) erro conceitual: 99,8% foi a especificidade, não a sensibilidade.
- E) erro de conduta: Sem reavaliação, um pneumotórax pode passar.

**4. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D15, D28
- A) erro conceitual: A TC não resolve o acesso.
- B) erro técnico: Insistir atrasa a ressuscitação.
- C) **correta**: o intraósseo pode salvar vidas no choque.
- D) erro de indicação: Via oral não serve.
- E) erro de conduta: Adiar a reposição é erro de conduta.

**5. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D19, A36
- A) erro de conduta: Despido, perde calor.
- B) erro técnico: Fluidos frios pioram a hipotermia.
- C) **correta**: 
- D) erro de indicação: Prevenção é prioridade.
- E) erro conceitual: Aquecer começa na sala de trauma.

**6. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D2, D3
- A) **correta**: só esses cenários invertem a ordem.
- B) erro de indicação: A idade não inverte a ordem.
- C) erro técnico: O eFAST não define a ordem.
- D) erro conceitual: O mecanismo não inverte a ordem.
- E) erro de conduta: Hipoxemia é tratada no B, não inverte a ordem.

**7. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D11, D12, A28
- A) erro conceitual: Fala difícil com Glasgow 8 não garante a via aérea.
- B) erro de indicação: A via aérea cirúrgica é exceção (0,24% numa grande coorte), não a primeira opção.
- C) erro técnico: Perde-se a informação neurológica de base.
- D) erro de conduta: Esperar piora atrasa a proteção da via aérea.
- E) **correta**: Glasgow ≤8 indica via aérea definitiva, com exame neurológico antes da sedação.


## Perfil R3

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D22
- A) erro de conduta: Fazer a via aérea tira o líder da coordenação.
- B) **correta**: o líder deve ter a 'visão grande' da sala.
- C) erro de indicação: Longe demais para coordenar.
- D) erro conceitual: Fora da sala não coordena.
- E) erro técnico: De costas não acompanha a equipe.

**3. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D22
- A) erro conceitual: Não é critério.
- B) erro de conduta: Decisões fragmentadas desorganizam a equipe.
- C) erro técnico: O enfermeiro tem outras funções.
- D) erro de indicação: O SAMU passa o caso e sai do comando.
- E) **correta**: as decisões são do líder.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A12, A42
- A) erro conceitual: Não há essa comprovação.
- B) erro de conduta: Não há esse dado.
- C) erro de indicação: A TC não substitui o exame.
- D) erro técnico: Lesões tardias ocorrem mesmo com TC.
- E) **correta**: segundo revisão de revisões.

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D24
- A) erro técnico: Atrasa a informação.
- B) erro conceitual: Passagem longa atrasa e dispersa.
- C) erro de indicação: A informação é necessária na chegada.
- D) **correta**: 
- E) erro de conduta: A passagem estruturada é útil.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D29
- A) erro de indicação: Sem supervisão, não.
- B) erro de conduta: Sem supervisão, não.
- C) erro técnico: Não é o critério.
- D) erro conceitual: Treinandos devem ter oportunidade de liderar.
- E) **correta**: 

**7. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A18
- A) erro de conduta: Não foi o que o estudo testou.
- B) erro conceitual: Houve redução de tempo com o treino in situ.
- C) **correta**: 
- D) erro de indicação: Não foi o que o estudo testou.
- E) erro técnico: Não foi o que o estudo testou.


## Perfil R+

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora A29, A30, A47
- A) erro conceitual: Um estudo mostrou baixa sensibilidade.
- B) erro de indicação: Os resultados divergem.
- C) erro técnico: A especificidade foi 99,8% no estudo citado.
- D) erro de conduta: Um estudo mostrou sensibilidade de 93,6%.
- E) **correta**: Atenção: o estudo de baixa sensibilidade incluiu só trauma torácico fechado, e o paciente do caso 2 tem ferimento penetrante.

**3. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora A27
- A) erro de conduta: Não há contraindicação.
- B) erro de indicação: Houve maioria clara.
- C) erro técnico: É pesquisa de opinião.
- D) **correta**: é opinião de profissionais, não desfecho clínico.
- E) erro conceitual: Foi o contrário.

**4. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D10, D11, D12
- A) **correta**: voz normal indica via aérea pérvia; a indicação de via aérea definitiva tem critérios.
- B) erro de conduta: A decisão não depende da TC.
- C) erro de indicação: O mecanismo não indica intubação por si.
- D) erro técnico: O exame neurológico vem antes da sedação.
- E) erro conceitual: A via aérea definitiva pode ser necessária.

**5. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D13
- A) **correta**: pode transformar uma emergência de via aérea em situação mais controlada.
- B) erro conceitual: Sedar sem preparar a via aérea é perigoso.
- C) erro de conduta: Deitado, o sangue tende a ir para a via aérea.
- D) erro técnico: Tamponar a boca obstrui a via aérea.
- E) erro de indicação: O colar não está indicado nesse cenário.

**6. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A2, A4, A5, A6
- A) **correta**: 
- B) erro conceitual: Não há ensaio de alta qualidade concluído.
- C) erro de conduta: Há associação.
- D) erro de indicação: Os custos variam muito.
- E) erro técnico: O ATLS foi o mais caro (USD 1433,5).

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A42, D30
- A) erro de indicação: Não há esse dado.
- B) erro conceitual: Há dado que contradiz.
- C) erro de conduta: Nenhum estudo mostrou isso.
- D) **correta**: 
- E) erro técnico: A terciária reduz lesões não identificadas.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A6', $af$O custo de implementação de programas de treinamento variou de USD 3,70 (primeiro respondedor leigo) a USD 1433,5 (ATLS).$af$, '2026_42', $af$starting from USD 3.70 (Lay-First-Responder) to USD 1433.5 (Advanced Trauma Life Support)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A47', $af$O estudo que mostrou baixa sensibilidade do ultrassom torácico incluiu só trauma torácico fechado.$af$, '2024_47', $af$A prospective observational analysis of patients with blunt chest trauma$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D13', $af$No trauma penetrante sem indicação de proteção cervical, sentar o paciente para que cuspa ou aspire o sangue pode controlar a via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$merely placing patients into an upright sitting position and allowing them to spit or suction the blood$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito_3', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_3'),0)+1, 'rascunho', $T1$Gabarito comentado — Pós-teste D0$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D0

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D11
- A) erro técnico: Insuficiente para Glasgow 7.
- B) erro conceitual: Ronco e Glasgow 7 indicam risco.
- C) **correta**: Glasgow ≤8 indica via aérea definitiva.
- D) erro de conduta: A decisão sobre a via aérea não espera a TC.
- E) erro de indicação: O Glasgow baixo sugere o contrário.

**3. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D17
- A) erro conceitual: Atribuir só ao álcool é perigoso.
- B) **correta**: agitação é sinal clássico de choque classe III e IV.
- C) erro de indicação: Incompleto.
- D) erro técnico: Agitação não é sinal de bem-estar.
- E) erro de conduta: Pode ser grave.

**4. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D19, A36
- A) erro de indicação: Aquecer não depende de imagem.
- B) erro de conduta: Piora a hipotermia.
- C) erro técnico: Reexaminar não justifica deixá-lo frio.
- D) erro conceitual: Abaixo do normal e frequente no trauma grave.
- E) **correta**: 

**5. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D16
- A) **correta**: 
- B) erro conceitual: A avaliação deve ser repetida.
- C) erro de conduta: Vale para todos.
- D) erro de indicação: Começa na sala de trauma.
- E) erro técnico: Antes também.

**6. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D14, D17
- A) erro conceitual: FC 118 e pele fria sugerem choque.
- B) erro técnico: A idade não torna o aparelho confiável.
- C) erro de indicação: FC alta não confirma ausência de choque.
- D) erro de conduta: A pele aqui está fria.
- E) **correta**: 

**7. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2
- A) erro conceitual: Incompleta.
- B) erro de indicação: CAB é para hemorragia externa ou extremis.
- C) **correta**: sem hemorragia externa grave nem extremis, a ordem é ABCDE.
- D) erro técnico: Ordem inexistente.
- E) erro de conduta: Ordem inexistente.


## Perfil R1

**1. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D12
- A) erro de conduta: Perde-se a informação neurológica de base.
- B) erro técnico: Não é o passo antes da intubação.
- C) erro de indicação: A TC não precede a via aérea.
- D) **correta**: 
- E) erro conceitual: O AMPLA é da secundária.

**3. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D14
- A) **correta**: 
- B) erro de conduta: Há motivo.
- C) erro conceitual: Não é a razão.
- D) erro técnico: Falso.
- E) erro de indicação: Não é proibido.

**4. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D17
- A) **correta**: agitação e rebaixamento podem ser choque.
- B) erro de conduta: A causa muda a conduta.
- C) erro conceitual: Atribuir ao álcool é armadilha.
- D) erro de indicação: A idade não muda isso.
- E) erro técnico: A TC não exclui choque.

**5. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D19, A36
- A) erro conceitual: A hipotermia é frequente e subvalorizada.
- B) erro técnico: Começa na sala.
- C) erro de conduta: Esperar piora é erro.
- D) erro de indicação: Não há base para isso aqui.
- E) **correta**: 

**6. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D25
- A) erro conceitual: O exame normal não exclui.
- B) erro de indicação: Achados positivos têm valor.
- C) erro de conduta: Não libera.
- D) erro técnico: O exame físico tem valor.
- E) **correta**: 

**7. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A36, D19, A38
- A) erro de indicação: Não há base para resfriar aqui.
- B) erro técnico: Fluido aquecido sozinho pode não bastar; usar mantas e ar forçado.
- C) **correta**: 
- D) erro conceitual: É frequente.
- E) erro de conduta: Esperar piorar contraria a prevenção.


## Perfil R2

**1. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- B) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.

**2. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora A38
- A) erro de conduta: Existe.
- B) erro conceitual: Não esfria; pode chegar abaixo do esperado.
- C) erro técnico: Perde calor no equipo.
- D) **correta**: 
- E) erro de indicação: Não é contraindicado.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A37
- A) erro de indicação: Não há.
- B) erro técnico: Não há base.
- C) **correta**: é uma lacuna.
- D) erro conceitual: Não há.
- E) erro de conduta: É necessária; é frequente.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A32, D14
- A) erro técnico: Insuficiente.
- B) erro de conduta: Insuficiente.
- C) erro conceitual: A tabela clássica teve viés.
- D) erro de indicação: Pode errar no choque.
- E) **correta**: 

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D30
- A) erro de conduta: Aumenta o risco.
- B) erro técnico: Lesões podem passar no laudo inicial.
- C) erro de indicação: Não é o que a fonte recomenda.
- D) **correta**: 
- E) erro conceitual: Há medida.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D32
- A) erro de conduta: Erro de conduta.
- B) erro de indicação: Não explica.
- C) erro técnico: Não é.
- D) erro conceitual: Atribuir à sedação sem investigar é armadilha.
- E) **correta**: 

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A41, D30
- A) erro de indicação: Inadequado com piora.
- B) erro de conduta: Atraso.
- C) erro conceitual: A terciária reduz, mas não elimina, lesões não identificadas.
- D) **correta**: reexaminar e investigar.
- E) erro técnico: A imagem não substitui o reexame.


## Perfil R3

**1. Resposta E** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A39, D26
- A) erro de conduta: Arriscado.
- B) erro de indicação: Inadequado.
- C) **correta**: no choque, a TC não aumentou a mortalidade precoce, mas a decisão depende da resposta.
- D) erro técnico: Atraso.
- E) erro conceitual: Faltam diagnósticos.

**3. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora A39
- A) **correta**: 
- B) erro técnico: Há estudo.
- C) erro conceitual: Não.
- D) erro de indicação: Não houve significância.
- E) erro de conduta: Não há esse dado.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D5, D22
- A) erro de indicação: Lento.
- B) erro de conduta: Desorganiza.
- C) erro conceitual: Desorganiza.
- D) erro técnico: Atrasa.
- E) **correta**: boa parte da avaliação é simultânea com funções distribuídas.

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D26
- A) erro técnico: Não.
- B) erro conceitual: Não isoladamente.
- C) erro de conduta: Não.
- D) **correta**: 
- E) erro de indicação: Não isoladamente.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D31, A42
- A) erro técnico: Ordem errada.
- B) erro de indicação: Tarde demais.
- C) erro conceitual: Lesões tardias ocorrem mesmo com TC.
- D) erro de conduta: Pacientes intubados não se queixam.
- E) **correta**: 

**7. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A43, D25
- A) erro de indicação: Não há indicação com os dados do caso.
- B) **correta**: bom para confirmar, insuficiente para excluir.
- C) erro técnico: Repetir o teste não muda seu desempenho.
- D) erro conceitual: A especificidade alta serve para confirmar, não para excluir.
- E) erro de conduta: Achado positivo de exame exige ação.


## Perfil R+

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A32
- A) erro conceitual: Há limitações.
- B) **correta**: 
- C) erro de indicação: Foi estudado.
- D) erro de conduta: Há.
- E) erro técnico: Não.

**3. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A33, D14
- A) **correta**: foi definida em 70% dos artigos, sem consenso nos cortes; e o aparelho automático pode errar no choque.
- B) erro técnico: Pode errar no choque.
- C) erro de conduta: FC 118 e pele fria sugerem choque.
- D) erro conceitual: Não há definição única.
- E) erro de indicação: Parâmetro isolado não basta.

**4. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A36, A37
- A) erro de indicação: Não mede a lacuna.
- B) erro conceitual: Não mede a lacuna.
- C) erro técnico: Não mede a lacuna.
- D) erro de conduta: Não mede a lacuna.
- E) **correta**: a hipotermia é frequente, subvalorizada e sem manejo baseado em evidência.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30, A41, A42
- A) erro técnico: O exame tem valor.
- B) **correta**: 
- C) erro de conduta: Há estratégia.
- D) erro de indicação: Aumenta o risco.
- E) erro conceitual: A TC de rotina não eliminou lesões tardias.

**6. Resposta B** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D25
- A) erro conceitual: Baixo valor preditivo negativo.
- B) **correta**: 
- C) erro de conduta: Vale por si.
- D) erro de indicação: Tem valor.
- E) erro técnico: Vale em geral.

**7. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A36, A37, D19
- A) erro de indicação: Há razões.
- B) erro conceitual: Não existe.
- C) **correta**: 
- D) erro de conduta: Não há essa comprovação.
- E) erro técnico: Não é o argumento.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_3' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D0

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D11
- A) erro técnico: Insuficiente para Glasgow 7.
- B) erro conceitual: Ronco e Glasgow 7 indicam risco.
- C) **correta**: Glasgow ≤8 indica via aérea definitiva.
- D) erro de conduta: A decisão sobre a via aérea não espera a TC.
- E) erro de indicação: O Glasgow baixo sugere o contrário.

**3. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D17
- A) erro conceitual: Atribuir só ao álcool é perigoso.
- B) **correta**: agitação é sinal clássico de choque classe III e IV.
- C) erro de indicação: Incompleto.
- D) erro técnico: Agitação não é sinal de bem-estar.
- E) erro de conduta: Pode ser grave.

**4. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D19, A36
- A) erro de indicação: Aquecer não depende de imagem.
- B) erro de conduta: Piora a hipotermia.
- C) erro técnico: Reexaminar não justifica deixá-lo frio.
- D) erro conceitual: Abaixo do normal e frequente no trauma grave.
- E) **correta**: 

**5. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D16
- A) **correta**: 
- B) erro conceitual: A avaliação deve ser repetida.
- C) erro de conduta: Vale para todos.
- D) erro de indicação: Começa na sala de trauma.
- E) erro técnico: Antes também.

**6. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D14, D17
- A) erro conceitual: FC 118 e pele fria sugerem choque.
- B) erro técnico: A idade não torna o aparelho confiável.
- C) erro de indicação: FC alta não confirma ausência de choque.
- D) erro de conduta: A pele aqui está fria.
- E) **correta**: 

**7. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2
- A) erro conceitual: Incompleta.
- B) erro de indicação: CAB é para hemorragia externa ou extremis.
- C) **correta**: sem hemorragia externa grave nem extremis, a ordem é ABCDE.
- D) erro técnico: Ordem inexistente.
- E) erro de conduta: Ordem inexistente.


## Perfil R1

**1. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta D** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D12
- A) erro de conduta: Perde-se a informação neurológica de base.
- B) erro técnico: Não é o passo antes da intubação.
- C) erro de indicação: A TC não precede a via aérea.
- D) **correta**: 
- E) erro conceitual: O AMPLA é da secundária.

**3. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D14
- A) **correta**: 
- B) erro de conduta: Há motivo.
- C) erro conceitual: Não é a razão.
- D) erro técnico: Falso.
- E) erro de indicação: Não é proibido.

**4. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D17
- A) **correta**: agitação e rebaixamento podem ser choque.
- B) erro de conduta: A causa muda a conduta.
- C) erro conceitual: Atribuir ao álcool é armadilha.
- D) erro de indicação: A idade não muda isso.
- E) erro técnico: A TC não exclui choque.

**5. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D19, A36
- A) erro conceitual: A hipotermia é frequente e subvalorizada.
- B) erro técnico: Começa na sala.
- C) erro de conduta: Esperar piora é erro.
- D) erro de indicação: Não há base para isso aqui.
- E) **correta**: 

**6. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D25
- A) erro conceitual: O exame normal não exclui.
- B) erro de indicação: Achados positivos têm valor.
- C) erro de conduta: Não libera.
- D) erro técnico: O exame físico tem valor.
- E) **correta**: 

**7. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A36, D19, A38
- A) erro de indicação: Não há base para resfriar aqui.
- B) erro técnico: Fluido aquecido sozinho pode não bastar; usar mantas e ar forçado.
- C) **correta**: 
- D) erro conceitual: É frequente.
- E) erro de conduta: Esperar piorar contraria a prevenção.


## Perfil R2

**1. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- B) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.

**2. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora A38
- A) erro de conduta: Existe.
- B) erro conceitual: Não esfria; pode chegar abaixo do esperado.
- C) erro técnico: Perde calor no equipo.
- D) **correta**: 
- E) erro de indicação: Não é contraindicado.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A37
- A) erro de indicação: Não há.
- B) erro técnico: Não há base.
- C) **correta**: é uma lacuna.
- D) erro conceitual: Não há.
- E) erro de conduta: É necessária; é frequente.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A32, D14
- A) erro técnico: Insuficiente.
- B) erro de conduta: Insuficiente.
- C) erro conceitual: A tabela clássica teve viés.
- D) erro de indicação: Pode errar no choque.
- E) **correta**: 

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D30
- A) erro de conduta: Aumenta o risco.
- B) erro técnico: Lesões podem passar no laudo inicial.
- C) erro de indicação: Não é o que a fonte recomenda.
- D) **correta**: 
- E) erro conceitual: Há medida.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D32
- A) erro de conduta: Erro de conduta.
- B) erro de indicação: Não explica.
- C) erro técnico: Não é.
- D) erro conceitual: Atribuir à sedação sem investigar é armadilha.
- E) **correta**: 

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A41, D30
- A) erro de indicação: Inadequado com piora.
- B) erro de conduta: Atraso.
- C) erro conceitual: A terciária reduz, mas não elimina, lesões não identificadas.
- D) **correta**: reexaminar e investigar.
- E) erro técnico: A imagem não substitui o reexame.


## Perfil R3

**1. Resposta E** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A39, D26
- A) erro de conduta: Arriscado.
- B) erro de indicação: Inadequado.
- C) **correta**: no choque, a TC não aumentou a mortalidade precoce, mas a decisão depende da resposta.
- D) erro técnico: Atraso.
- E) erro conceitual: Faltam diagnósticos.

**3. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora A39
- A) **correta**: 
- B) erro técnico: Há estudo.
- C) erro conceitual: Não.
- D) erro de indicação: Não houve significância.
- E) erro de conduta: Não há esse dado.

**4. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D5, D22
- A) erro de indicação: Lento.
- B) erro de conduta: Desorganiza.
- C) erro conceitual: Desorganiza.
- D) erro técnico: Atrasa.
- E) **correta**: boa parte da avaliação é simultânea com funções distribuídas.

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D26
- A) erro técnico: Não.
- B) erro conceitual: Não isoladamente.
- C) erro de conduta: Não.
- D) **correta**: 
- E) erro de indicação: Não isoladamente.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D31, A42
- A) erro técnico: Ordem errada.
- B) erro de indicação: Tarde demais.
- C) erro conceitual: Lesões tardias ocorrem mesmo com TC.
- D) erro de conduta: Pacientes intubados não se queixam.
- E) **correta**: 

**7. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A43, D25
- A) erro de indicação: Não há indicação com os dados do caso.
- B) **correta**: bom para confirmar, insuficiente para excluir.
- C) erro técnico: Repetir o teste não muda seu desempenho.
- D) erro conceitual: A especificidade alta serve para confirmar, não para excluir.
- E) erro de conduta: Achado positivo de exame exige ação.


## Perfil R+

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A32
- A) erro conceitual: Há limitações.
- B) **correta**: 
- C) erro de indicação: Foi estudado.
- D) erro de conduta: Há.
- E) erro técnico: Não.

**3. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A33, D14
- A) **correta**: foi definida em 70% dos artigos, sem consenso nos cortes; e o aparelho automático pode errar no choque.
- B) erro técnico: Pode errar no choque.
- C) erro de conduta: FC 118 e pele fria sugerem choque.
- D) erro conceitual: Não há definição única.
- E) erro de indicação: Parâmetro isolado não basta.

**4. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A36, A37
- A) erro de indicação: Não mede a lacuna.
- B) erro conceitual: Não mede a lacuna.
- C) erro técnico: Não mede a lacuna.
- D) erro de conduta: Não mede a lacuna.
- E) **correta**: a hipotermia é frequente, subvalorizada e sem manejo baseado em evidência.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30, A41, A42
- A) erro técnico: O exame tem valor.
- B) **correta**: 
- C) erro de conduta: Há estratégia.
- D) erro de indicação: Aumenta o risco.
- E) erro conceitual: A TC de rotina não eliminou lesões tardias.

**6. Resposta B** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D25
- A) erro conceitual: Baixo valor preditivo negativo.
- B) **correta**: 
- C) erro de conduta: Vale por si.
- D) erro de indicação: Tem valor.
- E) erro técnico: Vale em geral.

**7. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A36, A37, D19
- A) erro de indicação: Há razões.
- B) erro conceitual: Não existe.
- C) **correta**: 
- D) erro de conduta: Não há essa comprovação.
- E) erro técnico: Não é o argumento.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito_4', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_4'),0)+1, 'rascunho', $T1$Gabarito comentado — Pós-teste D+15$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D+15

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D3
- A) erro conceitual: O AMPLA é da secundária.
- B) erro de conduta: A TC não vem antes.
- C) erro técnico: Exame de imagem não vem antes.
- D) erro de indicação: A exposição não precede a circulação.
- E) **correta**: no paciente em extremis, a circulação vem primeiro.

**3. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D9
- A) erro de conduta: Esperar atrasa o controle.
- B) erro técnico: Não é a prioridade.
- C) **correta**: no alto risco, a cinta pélvica vai imediatamente.
- D) erro conceitual: Não trata o sangramento pélvico.
- E) erro de indicação: Não há sangramento de membro.

**4. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D15, D28
- A) **correta**: 
- B) erro de conduta: Atrasa a ressuscitação.
- C) erro de indicação: Não serve para ressuscitação.
- D) erro técnico: Atrasa.
- E) erro conceitual: Não serve.

**5. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D17, D26
- A) erro técnico: Não.
- B) erro de indicação: Não deve ser presumido.
- C) **correta**: alteração do nível de consciência acompanha o choque grave.
- D) erro de conduta: Não.
- E) erro conceitual: Não.

**6. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D26
- A) erro de conduta: Não.
- B) erro de indicação: Não isoladamente.
- C) **correta**: 
- D) erro conceitual: Irrelevante.
- E) erro técnico: Irrelevante.

**7. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D14
- A) erro de indicação: Há motivo.
- B) erro técnico: Não.
- C) **correta**: 
- D) erro de conduta: Há motivo.
- E) erro conceitual: Não é o motivo.


## Perfil R1

**1. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D9
- A) **correta**: 
- B) erro conceitual: É justamente indicada.
- C) erro de indicação: Atraso.
- D) erro técnico: Não controla o sangramento e atrasa.
- E) erro de conduta: Atraso.

**3. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A34, A35
- A) erro conceitual: Há adjuntos.
- B) erro de conduta: Transportar paciente instável é arriscado.
- C) **correta**: adjunto para buscar sangramento intracavitário.
- D) erro técnico: Não é exame de emergência.
- E) erro de indicação: Não se aplica.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D27
- A) erro conceitual: Muito abaixo.
- B) erro de conduta: Há dados.
- C) erro de indicação: Abaixo.
- D) **correta**: 
- E) erro técnico: Não.

**5. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D28
- A) erro de indicação: Não só.
- B) erro técnico: Serve.
- C) erro conceitual: Não só.
- D) erro de conduta: Atraso.
- E) **correta**: 

**6. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D9, A35
- A) erro conceitual: O FAST-PLUS avalia a sínfise.
- B) erro de conduta: Atraso no controle do sangramento.
- C) **correta**: o ultrassom detectou alargamento crítico confirmado na TC, e a cinta vai já no alto risco.
- D) erro técnico: Retirar expõe a novo sangramento.
- E) erro de indicação: Laparotomia não trata o sangramento pélvico.

**7. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D26, A39, D22
- A) erro de conduta: Arriscado.
- B) erro conceitual: Importa.
- C) erro técnico: Atraso.
- D) **correta**: 
- E) erro de indicação: Inadequado.


## Perfil R2

**1. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A34
- A) erro de conduta: Diagnóstico não substitui tratamento.
- B) erro técnico: É exame de beira-leito.
- C) **correta**: teve sensibilidade de 94,2% no politraumatizado instável.
- D) erro conceitual: Não é essa a função.
- E) erro de indicação: Foi estudado justamente no instável.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D26, D27
- A) erro conceitual: Erro de conduta.
- B) erro de indicação: Inadequado.
- C) **correta**: sem resposta, a prioridade é controlar o sangramento.
- D) erro técnico: Atraso.
- E) erro de conduta: Atraso no instável sem resposta.

**4. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A22, D9
- A) erro técnico: Expõe a novo sangramento.
- B) erro de conduta: Atraso.
- C) **correta**: a colaboração próxima associou-se a sobrevida 15,5% maior que a prevista.
- D) erro conceitual: Não exclui sangramento retroperitoneal ou pélvico.
- E) erro de indicação: Não trata o sangramento pélvico.

**5. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A32, D17
- A) erro conceitual: Teve viés.
- B) erro técnico: Não.
- C) erro de indicação: Não deve decidir sozinha.
- D) erro de conduta: Tem utilidade com limites.
- E) **correta**: 

**6. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A35
- A) erro conceitual: Não.
- B) erro de indicação: Não.
- C) **correta**: 
- D) erro técnico: Foi comparado.
- E) erro de conduta: Não.

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D8
- A) erro conceitual: Não é o motivo descrito.
- B) erro técnico: Não é o motivo.
- C) erro de conduta: Há motivo.
- D) **correta**: 
- E) erro de indicação: Não.


## Perfil R3

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D22, D3
- A) **correta**: no extremis, os mais experientes participam ativamente.
- B) erro conceitual: Desorganiza.
- C) erro técnico: Não.
- D) erro de conduta: Não sem supervisão.
- E) erro de indicação: Não.

**3. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A22, D27
- A) erro de conduta: Não.
- B) erro técnico: Não controla.
- C) erro conceitual: Não.
- D) erro de indicação: Não controla.
- E) **correta**: 

**4. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A12, D26
- A) **correta**: a TC de rotina não mostrou efeito em mortalidade e o paciente não respondeu.
- B) erro técnico: Não.
- C) erro conceitual: Não comprovado.
- D) erro de conduta: Atraso.
- E) erro de indicação: Não.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D22, D5
- A) erro de conduta: Não.
- B) **correta**: 
- C) erro conceitual: Desorganiza.
- D) erro técnico: Atrasa.
- E) erro de indicação: Lento.

**6. Resposta D** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D32
- A) erro de conduta: Atraso.
- B) erro técnico: Armadilha descrita.
- C) erro conceitual: Armadilha.
- D) **correta**: 
- E) erro de indicação: Não.

**7. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D27
- A) erro de conduta: Não.
- B) erro técnico: Há.
- C) erro de indicação: Não.
- D) erro conceitual: Não.
- E) **correta**: 


## Perfil R+

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A34, A35
- A) erro conceitual: Não.
- B) erro de conduta: Não.
- C) erro de indicação: Não.
- D) **correta**: 
- E) erro técnico: Há.

**3. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A22
- A) erro de conduta: Não.
- B) **correta**: 
- C) erro técnico: Não há essa restrição.
- D) erro de indicação: Relevante.
- E) erro conceitual: Desenho não permite.

**4. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D3, D22
- A) erro de conduta: Atraso.
- B) erro técnico: Não.
- C) erro conceitual: Há exceção.
- D) erro de indicação: Não no extremis.
- E) **correta**: 

**5. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D27, D3
- A) erro de conduta: Não.
- B) erro de indicação: Indireto.
- C) **correta**: ligado à mortalidade acima de 40% e à prioridade da circulação.
- D) erro técnico: Não.
- E) erro conceitual: Não.

**6. Resposta B** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A32, A33
- A) erro conceitual: Não.
- B) **correta**: 
- C) erro de indicação: Não.
- D) erro de conduta: Não.
- E) erro técnico: Não.

**7. Resposta D** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D28, D15
- A) erro de indicação: Não.
- B) erro conceitual: Não.
- C) erro de conduta: Não.
- D) **correta**: 
- E) erro técnico: Não.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_4' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D+15

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta E** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D3
- A) erro conceitual: O AMPLA é da secundária.
- B) erro de conduta: A TC não vem antes.
- C) erro técnico: Exame de imagem não vem antes.
- D) erro de indicação: A exposição não precede a circulação.
- E) **correta**: no paciente em extremis, a circulação vem primeiro.

**3. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D9
- A) erro de conduta: Esperar atrasa o controle.
- B) erro técnico: Não é a prioridade.
- C) **correta**: no alto risco, a cinta pélvica vai imediatamente.
- D) erro conceitual: Não trata o sangramento pélvico.
- E) erro de indicação: Não há sangramento de membro.

**4. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D15, D28
- A) **correta**: 
- B) erro de conduta: Atrasa a ressuscitação.
- C) erro de indicação: Não serve para ressuscitação.
- D) erro técnico: Atrasa.
- E) erro conceitual: Não serve.

**5. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D17, D26
- A) erro técnico: Não.
- B) erro de indicação: Não deve ser presumido.
- C) **correta**: alteração do nível de consciência acompanha o choque grave.
- D) erro de conduta: Não.
- E) erro conceitual: Não.

**6. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D26
- A) erro de conduta: Não.
- B) erro de indicação: Não isoladamente.
- C) **correta**: 
- D) erro conceitual: Irrelevante.
- E) erro técnico: Irrelevante.

**7. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D14
- A) erro de indicação: Há motivo.
- B) erro técnico: Não.
- C) **correta**: 
- D) erro de conduta: Há motivo.
- E) erro conceitual: Não é o motivo.


## Perfil R1

**1. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D9
- A) **correta**: 
- B) erro conceitual: É justamente indicada.
- C) erro de indicação: Atraso.
- D) erro técnico: Não controla o sangramento e atrasa.
- E) erro de conduta: Atraso.

**3. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A34, A35
- A) erro conceitual: Há adjuntos.
- B) erro de conduta: Transportar paciente instável é arriscado.
- C) **correta**: adjunto para buscar sangramento intracavitário.
- D) erro técnico: Não é exame de emergência.
- E) erro de indicação: Não se aplica.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D27
- A) erro conceitual: Muito abaixo.
- B) erro de conduta: Há dados.
- C) erro de indicação: Abaixo.
- D) **correta**: 
- E) erro técnico: Não.

**5. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D28
- A) erro de indicação: Não só.
- B) erro técnico: Serve.
- C) erro conceitual: Não só.
- D) erro de conduta: Atraso.
- E) **correta**: 

**6. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D9, A35
- A) erro conceitual: O FAST-PLUS avalia a sínfise.
- B) erro de conduta: Atraso no controle do sangramento.
- C) **correta**: o ultrassom detectou alargamento crítico confirmado na TC, e a cinta vai já no alto risco.
- D) erro técnico: Retirar expõe a novo sangramento.
- E) erro de indicação: Laparotomia não trata o sangramento pélvico.

**7. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D26, A39, D22
- A) erro de conduta: Arriscado.
- B) erro conceitual: Importa.
- C) erro técnico: Atraso.
- D) **correta**: 
- E) erro de indicação: Inadequado.


## Perfil R2

**1. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora A34
- A) erro de conduta: Diagnóstico não substitui tratamento.
- B) erro técnico: É exame de beira-leito.
- C) **correta**: teve sensibilidade de 94,2% no politraumatizado instável.
- D) erro conceitual: Não é essa a função.
- E) erro de indicação: Foi estudado justamente no instável.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D26, D27
- A) erro conceitual: Erro de conduta.
- B) erro de indicação: Inadequado.
- C) **correta**: sem resposta, a prioridade é controlar o sangramento.
- D) erro técnico: Atraso.
- E) erro de conduta: Atraso no instável sem resposta.

**4. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A22, D9
- A) erro técnico: Expõe a novo sangramento.
- B) erro de conduta: Atraso.
- C) **correta**: a colaboração próxima associou-se a sobrevida 15,5% maior que a prevista.
- D) erro conceitual: Não exclui sangramento retroperitoneal ou pélvico.
- E) erro de indicação: Não trata o sangramento pélvico.

**5. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A32, D17
- A) erro conceitual: Teve viés.
- B) erro técnico: Não.
- C) erro de indicação: Não deve decidir sozinha.
- D) erro de conduta: Tem utilidade com limites.
- E) **correta**: 

**6. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A35
- A) erro conceitual: Não.
- B) erro de indicação: Não.
- C) **correta**: 
- D) erro técnico: Foi comparado.
- E) erro de conduta: Não.

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D8
- A) erro conceitual: Não é o motivo descrito.
- B) erro técnico: Não é o motivo.
- C) erro de conduta: Há motivo.
- D) **correta**: 
- E) erro de indicação: Não.


## Perfil R3

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D22, D3
- A) **correta**: no extremis, os mais experientes participam ativamente.
- B) erro conceitual: Desorganiza.
- C) erro técnico: Não.
- D) erro de conduta: Não sem supervisão.
- E) erro de indicação: Não.

**3. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A22, D27
- A) erro de conduta: Não.
- B) erro técnico: Não controla.
- C) erro conceitual: Não.
- D) erro de indicação: Não controla.
- E) **correta**: 

**4. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A12, D26
- A) **correta**: a TC de rotina não mostrou efeito em mortalidade e o paciente não respondeu.
- B) erro técnico: Não.
- C) erro conceitual: Não comprovado.
- D) erro de conduta: Atraso.
- E) erro de indicação: Não.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D22, D5
- A) erro de conduta: Não.
- B) **correta**: 
- C) erro conceitual: Desorganiza.
- D) erro técnico: Atrasa.
- E) erro de indicação: Lento.

**6. Resposta D** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D32
- A) erro de conduta: Atraso.
- B) erro técnico: Armadilha descrita.
- C) erro conceitual: Armadilha.
- D) **correta**: 
- E) erro de indicação: Não.

**7. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D27
- A) erro de conduta: Não.
- B) erro técnico: Há.
- C) erro de indicação: Não.
- D) erro conceitual: Não.
- E) **correta**: 


## Perfil R+

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A34, A35
- A) erro conceitual: Não.
- B) erro de conduta: Não.
- C) erro de indicação: Não.
- D) **correta**: 
- E) erro técnico: Há.

**3. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A22
- A) erro de conduta: Não.
- B) **correta**: 
- C) erro técnico: Não há essa restrição.
- D) erro de indicação: Relevante.
- E) erro conceitual: Desenho não permite.

**4. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D3, D22
- A) erro de conduta: Atraso.
- B) erro técnico: Não.
- C) erro conceitual: Há exceção.
- D) erro de indicação: Não no extremis.
- E) **correta**: 

**5. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D27, D3
- A) erro de conduta: Não.
- B) erro de indicação: Indireto.
- C) **correta**: ligado à mortalidade acima de 40% e à prioridade da circulação.
- D) erro técnico: Não.
- E) erro conceitual: Não.

**6. Resposta B** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A32, A33
- A) erro conceitual: Não.
- B) **correta**: 
- C) erro de indicação: Não.
- D) erro de conduta: Não.
- E) erro técnico: Não.

**7. Resposta D** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D28, D15
- A) erro de indicação: Não.
- B) erro conceitual: Não.
- C) erro de conduta: Não.
- D) **correta**: 
- E) erro técnico: Não.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A22', $af$A sobrevida no grupo com colaboração próxima entre radiologia intervencionista e cirurgia foi 15,5% maior que a prevista (IC 95% 7,5–23,6%).$af$, '2024_64', $af$the survival rate in the CG was 15.5% higher than the Ps (95% CI: 7.5–23.6%; p < 0.001)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito_5', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_5'),0)+1, 'rascunho', $T1$Gabarito comentado — Pós-teste D+45$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D+45

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A42
- A) **correta**: 
- B) erro técnico: Não.
- C) erro conceitual: Lesões tardias ocorrem mesmo com TC.
- D) erro de indicação: Não é critério.
- E) erro de conduta: Importa.

**3. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D31
- A) **correta**: 
- B) erro conceitual: Essa é a primária.
- C) erro de indicação: Não.
- D) erro de conduta: Não.
- E) erro técnico: Não.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D32
- A) erro de conduta: Erro.
- B) erro de indicação: Não.
- C) erro técnico: Não.
- D) **correta**: 
- E) erro conceitual: Não presumir.

**5. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora A42
- A) **correta**: num estudo, ocorreram em 13,9 % dos pacientes.
- B) erro de conduta: O reexame é o que encontra essas lesões.
- C) erro técnico: Ocorre em adultos.
- D) erro de indicação: Improvável e não justifica deixar de investigar.
- E) erro conceitual: Não vê.

**6. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D30
- A) erro técnico: Não é o recomendado.
- B) erro de indicação: Não.
- C) erro de conduta: Lesões podem passar.
- D) **correta**: 
- E) erro conceitual: Não.

**7. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D25
- A) erro de indicação: Não.
- B) erro técnico: Atraso.
- C) erro de conduta: Não.
- D) **correta**: 
- E) erro conceitual: Não.


## Perfil R1

**1. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.

**2. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D31
- A) **correta**: 
- B) erro de indicação: Ordem errada.
- C) erro de conduta: Não.
- D) erro conceitual: Tarde.
- E) erro técnico: Não.

**3. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D32
- A) erro conceitual: Não.
- B) erro de conduta: Não.
- C) erro técnico: Armadilha.
- D) erro de indicação: Atraso.
- E) **correta**: 

**4. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A43
- A) erro técnico: É formato de passagem.
- B) erro de indicação: É roteiro de história.
- C) erro de conduta: É protocolo de ultrassom.
- D) **correta**: 
- E) erro conceitual: Não é desse teste.

**5. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A43
- A) erro de indicação: Não.
- B) erro de conduta: Não.
- C) erro conceitual: Não.
- D) erro técnico: Não.
- E) **correta**: 

**6. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A41, D25
- A) erro técnico: A imagem não substitui o exame.
- B) erro conceitual: A terciária não é infalível.
- C) **correta**: lesões potencialmente letais apareceram após a terciária em 0,26% dos graves, e achado positivo exige ação.
- D) erro de indicação: Inadequado com queixa nova.
- E) erro de conduta: Presumir sem examinar é erro.

**7. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30
- A) erro conceitual: Não.
- B) erro técnico: Não é o recomendado.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro de conduta: Não.


## Perfil R2

**1. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora A42, D30
- A) erro de indicação: Não.
- B) **correta**: 
- C) erro conceitual: Não necessariamente.
- D) erro técnico: Improvável.
- E) erro de conduta: Não.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D32
- A) erro de conduta: É o certo.
- B) erro técnico: É o certo.
- C) **correta**: é armadilha comum.
- D) erro conceitual: É o certo.
- E) erro de indicação: É o certo.

**4. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A43
- A) erro de indicação: Útil para confirmar.
- B) erro conceitual: Não.
- C) erro de conduta: Invertido.
- D) **correta**: 
- E) erro técnico: Invertido.

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A40, A12
- A) erro de indicação: Teve pouco ou nenhum efeito em mortalidade.
- B) erro técnico: Não há base.
- C) erro de conduta: Lesões tardias ocorrem mesmo com TC.
- D) **correta**: (120 de 3976).
- E) erro conceitual: Não foi o achado.

**6. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30, D25
- A) erro conceitual: Não.
- B) erro de conduta: Não.
- C) erro de indicação: Não é o recomendado.
- D) **correta**: 
- E) erro técnico: Há.

**7. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D31
- A) erro de conduta: Não.
- B) erro de indicação: Não.
- C) erro conceitual: Importa.
- D) erro técnico: Não.
- E) **correta**: 


## Perfil R3

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D30, A42
- A) erro de conduta: Não.
- B) erro técnico: Há.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro conceitual: Não.

**3. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A18
- A) erro de conduta: Não.
- B) erro técnico: Tarde.
- C) **correta**: debriefing apoia o aprendizado da equipe.
- D) erro conceitual: Perde-se a oportunidade.
- E) erro de indicação: Não.

**4. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A12, A42
- A) erro de indicação: Não.
- B) **correta**: 
- C) erro conceitual: Não.
- D) erro técnico: Não.
- E) erro de conduta: Há.

**5. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A42
- A) erro de indicação: Outro processo.
- B) erro conceitual: Indireto.
- C) erro técnico: Não.
- D) **correta**: 
- E) erro de conduta: Indireto.

**6. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D32
- A) erro de conduta: Atraso.
- B) erro conceitual: Armadilha.
- C) erro de indicação: Não.
- D) erro técnico: Não.
- E) **correta**: 

**7. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A41
- A) erro de conduta: Há.
- B) erro técnico: Outro estudo.
- C) erro conceitual: Não.
- D) erro de indicação: Não.
- E) **correta**: 


## Perfil R+

**1. Resposta D** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A42, D30
- A) erro de conduta: Extrapola.
- B) erro de indicação: Não há base.
- C) erro conceitual: Simplifica demais.
- D) erro técnico: Não há base.
- E) **correta**: 

**3. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30
- A) **correta**: 
- B) erro de conduta: Não.
- C) erro de indicação: Não.
- D) erro técnico: Não.
- E) erro conceitual: Incompleto.

**4. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A43
- A) erro de conduta: Há.
- B) erro conceitual: Não.
- C) erro técnico: Não.
- D) erro de indicação: Invertido.
- E) **correta**: 

**5. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A41, A42
- A) **correta**: 
- B) erro conceitual: Fraco.
- C) erro técnico: Fraco.
- D) erro de conduta: Há base.
- E) erro de indicação: Não é o foco.

**6. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D32
- A) **correta**: 
- B) erro conceitual: Há papel.
- C) erro de conduta: Incompleto.
- D) erro técnico: Não.
- E) erro de indicação: Incompleto.

**7. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A12, A40, D30
- A) erro conceitual: Não há essa comprovação.
- B) erro técnico: Critério isolado e sem base.
- C) **correta**: a TC de rotina tem pouco efeito em mortalidade, a primária normal raramente esconde lesão na imagem, e a terciária reduz lesões não identificadas.
- D) erro de indicação: Sem base.
- E) erro de conduta: Lesões tardias ocorrem mesmo com TC.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_5' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D+45

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora A42
- A) **correta**: 
- B) erro técnico: Não.
- C) erro conceitual: Lesões tardias ocorrem mesmo com TC.
- D) erro de indicação: Não é critério.
- E) erro de conduta: Importa.

**3. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D31
- A) **correta**: 
- B) erro conceitual: Essa é a primária.
- C) erro de indicação: Não.
- D) erro de conduta: Não.
- E) erro técnico: Não.

**4. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D32
- A) erro de conduta: Erro.
- B) erro de indicação: Não.
- C) erro técnico: Não.
- D) **correta**: 
- E) erro conceitual: Não presumir.

**5. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora A42
- A) **correta**: num estudo, ocorreram em 13,9 % dos pacientes.
- B) erro de conduta: O reexame é o que encontra essas lesões.
- C) erro técnico: Ocorre em adultos.
- D) erro de indicação: Improvável e não justifica deixar de investigar.
- E) erro conceitual: Não vê.

**6. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D30
- A) erro técnico: Não é o recomendado.
- B) erro de indicação: Não.
- C) erro de conduta: Lesões podem passar.
- D) **correta**: 
- E) erro conceitual: Não.

**7. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D25
- A) erro de indicação: Não.
- B) erro técnico: Atraso.
- C) erro de conduta: Não.
- D) **correta**: 
- E) erro conceitual: Não.


## Perfil R1

**1. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.

**2. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D31
- A) **correta**: 
- B) erro de indicação: Ordem errada.
- C) erro de conduta: Não.
- D) erro conceitual: Tarde.
- E) erro técnico: Não.

**3. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D32
- A) erro conceitual: Não.
- B) erro de conduta: Não.
- C) erro técnico: Armadilha.
- D) erro de indicação: Atraso.
- E) **correta**: 

**4. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A43
- A) erro técnico: É formato de passagem.
- B) erro de indicação: É roteiro de história.
- C) erro de conduta: É protocolo de ultrassom.
- D) **correta**: 
- E) erro conceitual: Não é desse teste.

**5. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A43
- A) erro de indicação: Não.
- B) erro de conduta: Não.
- C) erro conceitual: Não.
- D) erro técnico: Não.
- E) **correta**: 

**6. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A41, D25
- A) erro técnico: A imagem não substitui o exame.
- B) erro conceitual: A terciária não é infalível.
- C) **correta**: lesões potencialmente letais apareceram após a terciária em 0,26% dos graves, e achado positivo exige ação.
- D) erro de indicação: Inadequado com queixa nova.
- E) erro de conduta: Presumir sem examinar é erro.

**7. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30
- A) erro conceitual: Não.
- B) erro técnico: Não é o recomendado.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro de conduta: Não.


## Perfil R2

**1. Resposta C** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.

**2. Resposta B** · grau Média · taxa de acerto esperada 50% a 75% · âncora A42, D30
- A) erro de indicação: Não.
- B) **correta**: 
- C) erro conceitual: Não necessariamente.
- D) erro técnico: Improvável.
- E) erro de conduta: Não.

**3. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D32
- A) erro de conduta: É o certo.
- B) erro técnico: É o certo.
- C) **correta**: é armadilha comum.
- D) erro conceitual: É o certo.
- E) erro de indicação: É o certo.

**4. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A43
- A) erro de indicação: Útil para confirmar.
- B) erro conceitual: Não.
- C) erro de conduta: Invertido.
- D) **correta**: 
- E) erro técnico: Invertido.

**5. Resposta D** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A40, A12
- A) erro de indicação: Teve pouco ou nenhum efeito em mortalidade.
- B) erro técnico: Não há base.
- C) erro de conduta: Lesões tardias ocorrem mesmo com TC.
- D) **correta**: (120 de 3976).
- E) erro conceitual: Não foi o achado.

**6. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30, D25
- A) erro conceitual: Não.
- B) erro de conduta: Não.
- C) erro de indicação: Não é o recomendado.
- D) **correta**: 
- E) erro técnico: Há.

**7. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D31
- A) erro de conduta: Não.
- B) erro de indicação: Não.
- C) erro conceitual: Importa.
- D) erro técnico: Não.
- E) **correta**: 


## Perfil R3

**1. Resposta B** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- B) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- C) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- D) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D30, A42
- A) erro de conduta: Não.
- B) erro técnico: Há.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro conceitual: Não.

**3. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A18
- A) erro de conduta: Não.
- B) erro técnico: Tarde.
- C) **correta**: debriefing apoia o aprendizado da equipe.
- D) erro conceitual: Perde-se a oportunidade.
- E) erro de indicação: Não.

**4. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A12, A42
- A) erro de indicação: Não.
- B) **correta**: 
- C) erro conceitual: Não.
- D) erro técnico: Não.
- E) erro de conduta: Há.

**5. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A42
- A) erro de indicação: Outro processo.
- B) erro conceitual: Indireto.
- C) erro técnico: Não.
- D) **correta**: 
- E) erro de conduta: Indireto.

**6. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D32
- A) erro de conduta: Atraso.
- B) erro conceitual: Armadilha.
- C) erro de indicação: Não.
- D) erro técnico: Não.
- E) **correta**: 

**7. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A41
- A) erro de conduta: Há.
- B) erro técnico: Outro estudo.
- C) erro conceitual: Não.
- D) erro de indicação: Não.
- E) **correta**: 


## Perfil R+

**1. Resposta D** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- B) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A42, D30
- A) erro de conduta: Extrapola.
- B) erro de indicação: Não há base.
- C) erro conceitual: Simplifica demais.
- D) erro técnico: Não há base.
- E) **correta**: 

**3. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D30
- A) **correta**: 
- B) erro de conduta: Não.
- C) erro de indicação: Não.
- D) erro técnico: Não.
- E) erro conceitual: Incompleto.

**4. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A43
- A) erro de conduta: Há.
- B) erro conceitual: Não.
- C) erro técnico: Não.
- D) erro de indicação: Invertido.
- E) **correta**: 

**5. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A41, A42
- A) **correta**: 
- B) erro conceitual: Fraco.
- C) erro técnico: Fraco.
- D) erro de conduta: Há base.
- E) erro de indicação: Não é o foco.

**6. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D32
- A) **correta**: 
- B) erro conceitual: Há papel.
- C) erro de conduta: Incompleto.
- D) erro técnico: Não.
- E) erro de indicação: Incompleto.

**7. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A12, A40, D30
- A) erro conceitual: Não há essa comprovação.
- B) erro técnico: Critério isolado e sem base.
- C) **correta**: a TC de rotina tem pouco efeito em mortalidade, a primária normal raramente esconde lesão na imagem, e a terciária reduz lesões não identificadas.
- D) erro de indicação: Sem base.
- E) erro de conduta: Lesões tardias ocorrem mesmo com TC.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito_6', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_6'),0)+1, 'rascunho', $T1$Gabarito comentado — Pós-teste D+90$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D+90

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D22
- A) erro de indicação: Não.
- B) erro de conduta: Perde-se tempo.
- C) **correta**: 
- D) erro conceitual: Não.
- E) erro técnico: Sem avaliação.

**3. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D6
- A) erro de conduta: Não.
- B) **correta**: 
- C) erro conceitual: Depois.
- D) erro técnico: Não.
- E) erro de indicação: Não indicada.

**4. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D10, D11
- A) **correta**: 
- B) erro técnico: Não.
- C) erro de indicação: Não.
- D) erro conceitual: Não.
- E) erro de conduta: Não.

**5. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D22
- A) erro de indicação: Não.
- B) erro de conduta: Não.
- C) erro conceitual: Não.
- D) erro técnico: Não.
- E) **correta**: 

**6. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D23, D24
- A) erro técnico: Não.
- B) erro de conduta: Não.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro conceitual: Não.

**7. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D19
- A) **correta**: 
- B) erro técnico: Não.
- C) erro conceitual: Não.
- D) erro de conduta: Não.
- E) erro de indicação: Não.


## Perfil R1

**1. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.

**2. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D29
- A) erro de indicação: Não sem supervisão.
- B) erro técnico: Não é o critério.
- C) **correta**: 
- D) erro conceitual: Treinandos devem ter oportunidade.
- E) erro de conduta: Não.

**3. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora A13, A14
- A) **correta**: 
- B) erro técnico: Não.
- C) erro de indicação: Não.
- D) erro conceitual: Não.
- E) erro de conduta: Não.

**4. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A19, D29, D22
- A) **correta**: 
- B) erro de conduta: Treinandos lideram sob supervisão próxima.
- C) erro conceitual: Não há dado que sustente.
- D) erro técnico: O líder precisa da visão do todo.
- E) erro de indicação: Atraso.

**5. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D12, D11
- A) erro conceitual: Não.
- B) **correta**: 
- C) erro de conduta: Não.
- D) erro de indicação: Não.
- E) erro técnico: Não.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D23
- A) erro de conduta: Não.
- B) erro de indicação: Incompleto.
- C) erro conceitual: Não.
- D) erro técnico: Incompleto.
- E) **correta**: 

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D5
- A) erro de indicação: Não.
- B) erro conceitual: Não.
- C) erro de conduta: Há.
- D) **correta**: 
- E) erro técnico: Não.


## Perfil R2

**1. Resposta E** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A20, A21
- A) erro conceitual: Não.
- B) erro técnico: Não houve diferença de sobrevida.
- C) erro de indicação: Não.
- D) erro de conduta: Houve efeito.
- E) **correta**: (OR 0,48 para lesões não identificadas; OR 0,82 sobrevida).

**3. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A8, A7, A10
- A) erro de indicação: Não há ensaio.
- B) erro de conduta: Um estudo mostrou mais pneumonia.
- C) erro conceitual: Não.
- D) erro técnico: Houve efeito.
- E) **correta**: 

**4. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A17
- A) erro de conduta: Não.
- B) erro técnico: Não.
- C) erro de indicação: Houve.
- D) **correta**: 
- E) erro conceitual: Não.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D1, D2
- A) erro conceitual: Incompleto.
- B) **correta**: 
- C) erro de conduta: Não indicado.
- D) erro de indicação: Não.
- E) erro técnico: Não.

**6. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D3
- A) erro técnico: Não.
- B) erro conceitual: Não.
- C) erro de indicação: Não.
- D) erro de conduta: Não.
- E) **correta**: 

**7. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D22
- A) erro técnico: Não.
- B) erro conceitual: Não.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro de conduta: Não.


## Perfil R3

**1. Resposta D** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D22, D3
- A) erro de indicação: Não.
- B) erro técnico: Não.
- C) **correta**: 
- D) erro de conduta: Não.
- E) erro conceitual: Não.

**3. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A16
- A) erro conceitual: Não.
- B) **correta**: 
- C) erro de indicação: Não.
- D) erro técnico: Não.
- E) erro de conduta: Não.

**4. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A18
- A) **correta**: 
- B) erro técnico: Não.
- C) erro de conduta: Não.
- D) erro conceitual: Não.
- E) erro de indicação: Incompleto.

**5. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A12
- A) erro técnico: Não.
- B) erro de conduta: Não.
- C) erro conceitual: Não.
- D) erro de indicação: Não.
- E) **correta**: 

**6. Resposta D** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A6, A2, A4
- A) erro de conduta: Há associação com menor mortalidade (OR 0,60).
- B) erro conceitual: Não.
- C) erro de indicação: Não há ensaio de alta qualidade.
- D) **correta**: 
- E) erro técnico: O programa para leigos custou USD 3,70.

**7. Resposta B** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A19
- A) erro de indicação: Houve.
- B) **correta**: 
- C) erro conceitual: Não.
- D) erro de conduta: Há.
- E) erro técnico: Não.


## Perfil R+

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A44
- A) erro técnico: Não.
- B) erro de conduta: Não.
- C) erro de indicação: Não.
- D) **correta**: 
- E) erro conceitual: Não.

**3. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A20, A21
- A) erro de indicação: Há valor.
- B) erro de conduta: Há benefício em lesões não identificadas.
- C) **correta**: 
- D) erro técnico: Não.
- E) erro conceitual: Não houve diferença de sobrevida.

**4. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A15, A45, A46
- A) erro conceitual: O efeito foi num subgrupo e em hospitais não terciários.
- B) erro técnico: Há dado de mortalidade.
- C) **correta**: desfecho secundário, num subgrupo e num contexto diferente do nosso; vale aplicar com cautela.
- D) erro de conduta: Não.
- E) erro de indicação: Não.

**5. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A4, A2
- A) **correta**: 
- B) erro conceitual: Não.
- C) erro de conduta: Não.
- D) erro técnico: Incompleto.
- E) erro de indicação: Não há base.

**6. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A3, A7
- A) erro técnico: Comparação sem ajuste é enviesada.
- B) erro de indicação: Não mede desfecho.
- C) erro conceitual: Os estudos antes-e-depois são a limitação atual.
- D) erro de conduta: O piloto mostrou o contrário.
- E) **correta**: piloto com 376 pacientes e 22 residentes mostrou a viabilidade.

**7. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A7, A9, A10
- A) **correta**: 
- B) erro de indicação: Há.
- C) erro conceitual: Não.
- D) erro técnico: Houve mais pneumonia em um estudo.
- E) erro de conduta: Houve benefício em ISS > 25.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito_6' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Gabarito comentado: Pós-teste D+90

Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.


## Perfil Graduação

**1. Resposta D** · grau Média · taxa de acerto esperada 50% a 75% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D22
- A) erro de indicação: Não.
- B) erro de conduta: Perde-se tempo.
- C) **correta**: 
- D) erro conceitual: Não.
- E) erro técnico: Sem avaliação.

**3. Resposta B** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D6
- A) erro de conduta: Não.
- B) **correta**: 
- C) erro conceitual: Depois.
- D) erro técnico: Não.
- E) erro de indicação: Não indicada.

**4. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora D10, D11
- A) **correta**: 
- B) erro técnico: Não.
- C) erro de indicação: Não.
- D) erro conceitual: Não.
- E) erro de conduta: Não.

**5. Resposta E** · grau Média · taxa de acerto esperada 50% a 75% · âncora D22
- A) erro de indicação: Não.
- B) erro de conduta: Não.
- C) erro conceitual: Não.
- D) erro técnico: Não.
- E) **correta**: 

**6. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D23, D24
- A) erro técnico: Não.
- B) erro de conduta: Não.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro conceitual: Não.

**7. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D19
- A) **correta**: 
- B) erro técnico: Não.
- C) erro conceitual: Não.
- D) erro de conduta: Não.
- E) erro de indicação: Não.


## Perfil R1

**1. Resposta A** · grau Fácil · taxa de acerto esperada 75% a 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.

**2. Resposta C** · grau Média · taxa de acerto esperada 50% a 75% · âncora D29
- A) erro de indicação: Não sem supervisão.
- B) erro técnico: Não é o critério.
- C) **correta**: 
- D) erro conceitual: Treinandos devem ter oportunidade.
- E) erro de conduta: Não.

**3. Resposta A** · grau Média · taxa de acerto esperada 50% a 75% · âncora A13, A14
- A) **correta**: 
- B) erro técnico: Não.
- C) erro de indicação: Não.
- D) erro conceitual: Não.
- E) erro de conduta: Não.

**4. Resposta A** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A19, D29, D22
- A) **correta**: 
- B) erro de conduta: Treinandos lideram sob supervisão próxima.
- C) erro conceitual: Não há dado que sustente.
- D) erro técnico: O líder precisa da visão do todo.
- E) erro de indicação: Atraso.

**5. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D12, D11
- A) erro conceitual: Não.
- B) **correta**: 
- C) erro de conduta: Não.
- D) erro de indicação: Não.
- E) erro técnico: Não.

**6. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D23
- A) erro de conduta: Não.
- B) erro de indicação: Incompleto.
- C) erro conceitual: Não.
- D) erro técnico: Incompleto.
- E) **correta**: 

**7. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D5
- A) erro de indicação: Não.
- B) erro conceitual: Não.
- C) erro de conduta: Há.
- D) **correta**: 
- E) erro técnico: Não.


## Perfil R2

**1. Resposta E** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- B) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- C) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- D) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- E) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).

**2. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A20, A21
- A) erro conceitual: Não.
- B) erro técnico: Não houve diferença de sobrevida.
- C) erro de indicação: Não.
- D) erro de conduta: Houve efeito.
- E) **correta**: (OR 0,48 para lesões não identificadas; OR 0,82 sobrevida).

**3. Resposta E** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A8, A7, A10
- A) erro de indicação: Não há ensaio.
- B) erro de conduta: Um estudo mostrou mais pneumonia.
- C) erro conceitual: Não.
- D) erro técnico: Houve efeito.
- E) **correta**: 

**4. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A17
- A) erro de conduta: Não.
- B) erro técnico: Não.
- C) erro de indicação: Houve.
- D) **correta**: 
- E) erro conceitual: Não.

**5. Resposta B** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora D1, D2
- A) erro conceitual: Incompleto.
- B) **correta**: 
- C) erro de conduta: Não indicado.
- D) erro de indicação: Não.
- E) erro técnico: Não.

**6. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D3
- A) erro técnico: Não.
- B) erro conceitual: Não.
- C) erro de indicação: Não.
- D) erro de conduta: Não.
- E) **correta**: 

**7. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora D22
- A) erro técnico: Não.
- B) erro conceitual: Não.
- C) **correta**: 
- D) erro de indicação: Não.
- E) erro de conduta: Não.


## Perfil R3

**1. Resposta D** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- B) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- C) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.
- D) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- E) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.

**2. Resposta C** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora D22, D3
- A) erro de indicação: Não.
- B) erro técnico: Não.
- C) **correta**: 
- D) erro de conduta: Não.
- E) erro conceitual: Não.

**3. Resposta B** · grau Difícil · taxa de acerto esperada 30% a 50% · âncora A16
- A) erro conceitual: Não.
- B) **correta**: 
- C) erro de indicação: Não.
- D) erro técnico: Não.
- E) erro de conduta: Não.

**4. Resposta A** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A18
- A) **correta**: 
- B) erro técnico: Não.
- C) erro de conduta: Não.
- D) erro conceitual: Não.
- E) erro de indicação: Incompleto.

**5. Resposta E** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A12
- A) erro técnico: Não.
- B) erro de conduta: Não.
- C) erro conceitual: Não.
- D) erro de indicação: Não.
- E) **correta**: 

**6. Resposta D** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A6, A2, A4
- A) erro de conduta: Há associação com menor mortalidade (OR 0,60).
- B) erro conceitual: Não.
- C) erro de indicação: Não há ensaio de alta qualidade.
- D) **correta**: 
- E) erro técnico: O programa para leigos custou USD 3,70.

**7. Resposta B** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A19
- A) erro de indicação: Houve.
- B) **correta**: 
- C) erro conceitual: Não.
- D) erro de conduta: Há.
- E) erro técnico: Não.


## Perfil R+

**1. Resposta A** · grau Muito fácil · taxa de acerto esperada acima de 90% · âncora D2, D3, D11
- A) **correta**: nesses casos a circulação vem antes da via aérea (CAB, CABDE).
- B) erro de conduta: O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.
- C) erro conceitual: Fratura sem sangramento grave não muda a ordem ABCDE.
- D) erro técnico: A radiografia é adjunta; a prioridade não espera exame de imagem.
- E) erro de indicação: Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.

**2. Resposta D** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A44
- A) erro técnico: Não.
- B) erro de conduta: Não.
- C) erro de indicação: Não.
- D) **correta**: 
- E) erro conceitual: Não.

**3. Resposta C** · grau Muito difícil · taxa de acerto esperada 15% a 30% · âncora A20, A21
- A) erro de indicação: Há valor.
- B) erro de conduta: Há benefício em lesões não identificadas.
- C) **correta**: 
- D) erro técnico: Não.
- E) erro conceitual: Não houve diferença de sobrevida.

**4. Resposta C** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A15, A45, A46
- A) erro conceitual: O efeito foi num subgrupo e em hospitais não terciários.
- B) erro técnico: Há dado de mortalidade.
- C) **correta**: desfecho secundário, num subgrupo e num contexto diferente do nosso; vale aplicar com cautela.
- D) erro de conduta: Não.
- E) erro de indicação: Não.

**5. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A4, A2
- A) **correta**: 
- B) erro conceitual: Não.
- C) erro de conduta: Não.
- D) erro técnico: Incompleto.
- E) erro de indicação: Não há base.

**6. Resposta E** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A3, A7
- A) erro técnico: Comparação sem ajuste é enviesada.
- B) erro de indicação: Não mede desfecho.
- C) erro conceitual: Os estudos antes-e-depois são a limitação atual.
- D) erro de conduta: O piloto mostrou o contrário.
- E) **correta**: piloto com 376 pacientes e 22 residentes mostrou a viabilidade.

**7. Resposta A** · grau Extrema · taxa de acerto esperada abaixo de 15% · âncora A7, A9, A10
- A) **correta**: 
- B) erro de indicação: Há.
- C) erro conceitual: Não.
- D) erro técnico: Houve mais pneumonia em um estudo.
- E) erro de conduta: Houve benefício em ISS > 25.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A3', $af$Estudo piloto de viabilidade de ensaio randomizado por conglomerados (ATLS, PTC e cuidado padrão) incluiu 376 pacientes e 22 residentes.$af$, '2025_36', $af$We included 376 patients and 22 residents.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A6', $af$O custo de implementação de programas de treinamento variou de USD 3,70 (primeiro respondedor leigo) a USD 1433,5 (ATLS).$af$, '2026_42', $af$starting from USD 3.70 (Lay-First-Responder) to USD 1433.5 (Advanced Trauma Life Support)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='gabarito_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='gabarito_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'mapa', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='mapa'),0)+1, 'rascunho', $T1$Mapa conceitual$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Mapa conceitual

```mermaid
mindmap
  root((Avaliação inicial xABCDE))
    Evidência do treinamento
      OR 0,60 observacional A2
      Sem alta qualidade A4
      Ensaio em andamento A5
    Estrutura
      Checklist adesão A8
      TIF 14 de 16 indicadores A13
      Campeão institucional A16
    x Hemorragia
      Torniquete RR 0,70 NS A23
      Amputação RR 2,07 A24
      Curativo 50 a 412 mmHg A25
    A B
      O2 guiado por SpO2 A27
      Via aérea cirúrgica 0,24% A28
      eFAST sensibilidade variável A29 A30
    C
      Classe de choque sob crítica A32
      Estabilidade sem consenso A33
      RUSH 94,2% A34
      FAST-PLUS pelve A35
    E
      Hipotermia até dois terços A36
      Sem protocolo A37
    Imagem e seguimento
      TC corpo inteiro pouco efeito A12
      Lesões tardias 13,9 % A42
      Terciária sempre A41
    Equipe
      Simulação A17 A18
      Líder cirurgião menos lesões perdidas A21
```
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='mapa' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Mapa conceitual

```mermaid
mindmap
  root((Avaliação inicial xABCDE))
    Evidência do treinamento
      OR 0,60 observacional A2
      Sem alta qualidade A4
      Ensaio em andamento A5
    Estrutura
      Checklist adesão A8
      TIF 14 de 16 indicadores A13
      Campeão institucional A16
    x Hemorragia
      Torniquete RR 0,70 NS A23
      Amputação RR 2,07 A24
      Curativo 50 a 412 mmHg A25
    A B
      O2 guiado por SpO2 A27
      Via aérea cirúrgica 0,24% A28
      eFAST sensibilidade variável A29 A30
    C
      Classe de choque sob crítica A32
      Estabilidade sem consenso A33
      RUSH 94,2% A34
      FAST-PLUS pelve A35
    E
      Hipotermia até dois terços A36
      Sem protocolo A37
    Imagem e seguimento
      TC corpo inteiro pouco efeito A12
      Lesões tardias 13,9 % A42
      Terciária sempre A41
    Equipe
      Simulação A17 A18
      Líder cirurgião menos lesões perdidas A21
```
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='mapa' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='mapa')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'objetivos', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='objetivos'),0)+1, 'rascunho', $T1$Objetivos de aprendizagem por perfil$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Objetivos de aprendizagem por perfil

Cada objetivo tem verbo observável, condição e critério, e um tipo: conhecimento (C), habilidade (H), atitude (A) ou raciocínio clínico (R). O perfil de cima é pré-requisito do de baixo.

## Graduação (4º a 6º ano)

1. (C) **Descrever** a sequência ABCDE e quando a circulação vem antes da via aérea [D2, D3], em uma pergunta oral, sem omitir etapas.
2. (H) **Aplicar** compressão direta em sangramento externo em simulação, antes de qualquer outra medida [D6].
3. (C) **Reconhecer** os sinais de via aérea pérvia e a indicação de via aérea definitiva por Glasgow [D10, D11], em caso escrito, com acerto.
4. (H) **Colher** a história AMPLA completa em paciente simulado [D21].
5. (A) **Manter** o paciente coberto e aquecido após o exame [D19], em toda simulação.

## R1

1. (H) **Executar** a avaliação primária completa em simulação, verbalizando cada etapa, com reavaliação após cada intervenção [D1, D5].
2. (R) **Decidir** entre ABCDE e CAB diante de hemorragia externa ou paciente em extremis [D2, D3, D4], em caso escrito, justificando.
3. (H) **Obter** acesso intraósseo em simulador quando o venoso falhar [D15].
4. (C) **Explicar** por que a agitação pode ser sinal de choque e por que o aparelho automático de pressão engana no choque [D14, D17].
5. (A) **Registrar** a avaliação no formulário estruturado de admissão em todo atendimento [A13, A14].
6. (H) **Realizar** a avaliação secundária completa e documentá-la [D20].

## R2

1. (R) **Interpretar** eFAST e radiografias como adjuntos, sabendo que um eFAST negativo não exclui pneumotórax [A29, A30], em casos com imagens.
2. (R) **Indicar** torniquete, cinta pélvica ou compressão conforme a lesão, conhecendo o risco de amputação associado ao torniquete [D7, D9, A24].
3. (R) **Avaliar** o estado hemodinâmico sem depender só da classe de choque [A32, A33], em casos escritos.
4. (H) **Realizar** a avaliação terciária e revisar as imagens do paciente internado [D30, D31].
5. (A) **Comunicar** achados ao líder em voz alta e de forma concisa durante a simulação.

## R3

1. (H) **Liderar** a equipe de trauma em simulação, distribuindo funções antes da chegada [D22, D29].
2. (H) **Conduzir** a passagem do pré-hospitalar no formato MIST em até 1 minuto [D23, D24].
3. (R) **Decidir** o destino do paciente instável (centro cirúrgico, radiologia intervencionista ou TC) [D27, A12, A39].
4. (R) **Justificar** a indicação de TC de corpo inteiro com base na evidência [A12, A40].
5. (A) **Conduzir** o debriefing da equipe após atendimento real ou simulado [A18].

## R+ (R4 a R6, egressos e preceptores)

1. (R) **Avaliar criticamente** a evidência sobre treinamento, checklist e torniquete, separando associação de causa [A2, A4, A23].
2. (R) **Propor** ajustes ao protocolo institucional de avaliação inicial com base nas lacunas identificadas [A7, A37].
3. (H) **Ensinar** a avaliação inicial em simulação in situ com debriefing [A18, A44].
4. (R) **Auditar** indicadores de processo da sala de trauma (registro da via aérea, temperatura, lesões tardias) [A14, A42].
5. (A) **Supervisionar** treinandos na liderança da equipe sem assumir o comando sem necessidade [D29].
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='objetivos' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Objetivos de aprendizagem por perfil

Cada objetivo tem verbo observável, condição e critério, e um tipo: conhecimento (C), habilidade (H), atitude (A) ou raciocínio clínico (R). O perfil de cima é pré-requisito do de baixo.

## Graduação (4º a 6º ano)

1. (C) **Descrever** a sequência ABCDE e quando a circulação vem antes da via aérea [D2, D3], em uma pergunta oral, sem omitir etapas.
2. (H) **Aplicar** compressão direta em sangramento externo em simulação, antes de qualquer outra medida [D6].
3. (C) **Reconhecer** os sinais de via aérea pérvia e a indicação de via aérea definitiva por Glasgow [D10, D11], em caso escrito, com acerto.
4. (H) **Colher** a história AMPLA completa em paciente simulado [D21].
5. (A) **Manter** o paciente coberto e aquecido após o exame [D19], em toda simulação.

## R1

1. (H) **Executar** a avaliação primária completa em simulação, verbalizando cada etapa, com reavaliação após cada intervenção [D1, D5].
2. (R) **Decidir** entre ABCDE e CAB diante de hemorragia externa ou paciente em extremis [D2, D3, D4], em caso escrito, justificando.
3. (H) **Obter** acesso intraósseo em simulador quando o venoso falhar [D15].
4. (C) **Explicar** por que a agitação pode ser sinal de choque e por que o aparelho automático de pressão engana no choque [D14, D17].
5. (A) **Registrar** a avaliação no formulário estruturado de admissão em todo atendimento [A13, A14].
6. (H) **Realizar** a avaliação secundária completa e documentá-la [D20].

## R2

1. (R) **Interpretar** eFAST e radiografias como adjuntos, sabendo que um eFAST negativo não exclui pneumotórax [A29, A30], em casos com imagens.
2. (R) **Indicar** torniquete, cinta pélvica ou compressão conforme a lesão, conhecendo o risco de amputação associado ao torniquete [D7, D9, A24].
3. (R) **Avaliar** o estado hemodinâmico sem depender só da classe de choque [A32, A33], em casos escritos.
4. (H) **Realizar** a avaliação terciária e revisar as imagens do paciente internado [D30, D31].
5. (A) **Comunicar** achados ao líder em voz alta e de forma concisa durante a simulação.

## R3

1. (H) **Liderar** a equipe de trauma em simulação, distribuindo funções antes da chegada [D22, D29].
2. (H) **Conduzir** a passagem do pré-hospitalar no formato MIST em até 1 minuto [D23, D24].
3. (R) **Decidir** o destino do paciente instável (centro cirúrgico, radiologia intervencionista ou TC) [D27, A12, A39].
4. (R) **Justificar** a indicação de TC de corpo inteiro com base na evidência [A12, A40].
5. (A) **Conduzir** o debriefing da equipe após atendimento real ou simulado [A18].

## R+ (R4 a R6, egressos e preceptores)

1. (R) **Avaliar criticamente** a evidência sobre treinamento, checklist e torniquete, separando associação de causa [A2, A4, A23].
2. (R) **Propor** ajustes ao protocolo institucional de avaliação inicial com base nas lacunas identificadas [A7, A37].
3. (H) **Ensinar** a avaliação inicial em simulação in situ com debriefing [A18, A44].
4. (R) **Auditar** indicadores de processo da sala de trauma (registro da via aérea, temperatura, lesões tardias) [A14, A42].
5. (A) **Supervisionar** treinandos na liderança da equipe sem assumir o comando sem necessidade [D29].
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D4', $af$No pré-hospitalar, a hemorragia externa maciça é tratada primeiro.$af$, 'Mattox9_cap10_pre_hospitalar', $af$In the event of external massive hemorrhage, bleeding should be addressed first.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='objetivos' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='objetivos')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'podcast_roteiro', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='podcast_roteiro'),0)+1, 'rascunho', $T1$Roteiro de podcast$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Roteiro de podcast: "xABCDE: o que mudou e o que a evidência sustenta"

Formato: duas vozes — PRECEPTOR e RESIDENTE. Duração estimada: 8 a 10 minutos (cerca de 1.200 palavras). Tom: conversa de corredor, sem jargão desnecessário.

---

**PRECEPTOR:** Olá, este é o episódio do tema um do Programa de Cirurgia de Urgência e Trauma. Hoje a conversa é sobre a avaliação inicial do traumatizado. Comigo está um residente do primeiro ano.

**RESIDENTE:** Olá! E eu já chego com uma pergunta que sempre quis fazer: todo mundo faz o ATLS, todo mundo repete o ABCDE... mas isso salva vidas mesmo? Existe prova?

**PRECEPTOR:** Ótima pergunta para começar, porque a resposta honesta é: existe sinal, mas não existe prova forte. Uma revisão sistemática juntou 19 estudos, com mais de 92 mil pacientes [A1]. Os programas de treinamento em suporte de vida no trauma se associaram a menor mortalidade: razão de chances de 0,60 [A2].

**RESIDENTE:** Zero vírgula sessenta parece muito bom.

**PRECEPTOR:** Parece. Só que são estudos observacionais. Hospitais que treinam mais também costumam ter mais recursos, mais organização. Os próprios pesquisadores que estão conduzindo um grande ensaio na Índia escrevem que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes [A4]. Esse ensaio vai incluir pelo menos 4320 pacientes [A5]. Então a resposta definitiva ainda está por vir.

**RESIDENTE:** Entendi. A gente ensina porque faz sentido e porque há associação, mas com humildade sobre o tamanho do efeito.

**PRECEPTOR:** Exatamente. E agora o "x" na frente do ABCDE. O que ele significa?

**RESIDENTE:** Hemorragia exsanguinante. A ideia é que o sangramento externo que mata em minutos passa à frente da via aérea. [D2, D4]

**PRECEPTOR:** Isso. E a ferramenta que todo mundo associa a isso é o torniquete. O que você acha que a evidência mostra?

**RESIDENTE:** Imagino que reduz mortalidade, não?

**PRECEPTOR:** Uma revisão sistemática de torniquete pré-hospitalar encontrou mortalidade de 4,02% com torniquete contra 6,43% sem. Risco relativo de 0,70, mas o intervalo de confiança cruza o um. Ou seja: a redução não foi estatisticamente significativa [A23].

**RESIDENTE:** E tem algum lado negativo?

**PRECEPTOR:** Amputação inicial foi mais frequente no grupo torniquete: 19,32% contra 6,4%, risco relativo de 2,07 [A24]. Mas cuidado com a interpretação: quem recebe torniquete provavelmente tem lesão mais grave. É dado observacional. Não dá para dizer que o torniquete causou a amputação.

**RESIDENTE:** E o curativo compressivo? Esse eu faço toda semana.

**PRECEPTOR:** Tem um estudo curioso. Mediram a pressão real dos curativos compressivos: a média foi 169 milímetros de mercúrio, mas variou de 50 a 412 [A25]. E a percepção de quem aplicou não teve correlação com a pressão medida [A26].

**RESIDENTE:** Ou seja, eu acho que apertei bem e posso não ter apertado.

**PRECEPTOR:** Ou apertado demais. A lição é reavaliar o sangramento, não confiar na sensação.

**RESIDENTE:** Vamos para o A e o B. Uma dúvida prática: oxigênio para todo mundo?

**PRECEPTOR:** Uma pesquisa com profissionais mostrou que 73 % não apoiam dar oxigênio suplementar sempre, para todo traumatizado grave, sem olhar a saturação [A27]. Repare que isso é opinião de profissionais, não desfecho clínico. Mas mostra para onde a prática está indo: oxigênio guiado pela saturação.

**RESIDENTE:** E o ultrassom? Se o eFAST não mostra pneumotórax, posso ficar tranquilo?

**PRECEPTOR:** Aqui os estudos discordam. Um deles encontrou sensibilidade de 93,6% e especificidade de 99,8% para pneumotórax [A29]. Outro, prospectivo, encontrou baixa sensibilidade, com muitos falsos negativos [A30].

**RESIDENTE:** Então positivo eu acredito; negativo, com suspeita clínica, eu continuo investigando.

**PRECEPTOR:** Perfeito. Agora o C. Você aprendeu as classes de choque do ATLS?

**RESIDENTE:** Decorei para a prova. Classe um, dois, três, quatro.

**PRECEPTOR:** Pois a comparação clássica entre o déficit de base e esses parâmetros tradicionais teve um viés metodológico, que superestimou a classe de choque dos parâmetros tradicionais [A32]. E tem mais: uma revisão foi atrás da definição de "estabilidade hemodinâmica". Ela só estava definida em 70% dos artigos, e sem consenso nos pontos de corte [A33].

**RESIDENTE:** Então quando alguém diz "o paciente está estável"...

**PRECEPTOR:** ...pergunte: estável segundo o quê? Não classifique o choque por um número isolado. À beira do leito, o ultrassom ajuda: o protocolo RUSH teve sensibilidade de 94,2% em politraumatizados instáveis [A34]. E dá para olhar a sínfise púbica com o ultrassom: num estudo, 7,5% dos pacientes tinham alargamento crítico [A35].

**RESIDENTE:** E a parada cardíaca no trauma? Adrenalina?

**PRECEPTOR:** Num estudo de parada extra-hospitalar traumática, a adrenalina se associou a menor sobrevida em 7 dias: razão de chances de 0,20 [A31]. De novo, observacional. Mas reforça que parada traumática não é parada clínica: o foco é corrigir a causa.

**RESIDENTE:** Chegamos no E, de exposição. Confesso que é a letra que eu faço mais rápido.

**PRECEPTOR:** E é a mais negligenciada. Hipotermia está presente em até dois terços dos pacientes com trauma grave, e muitas vezes é desconsiderada na ressuscitação inicial [A36]. E, ao contrário da acidose e do sangramento, não existe uma abordagem baseada em evidência para manejá-la [A37].

**RESIDENTE:** Mas a gente usa soro aquecido.

**PRECEPTOR:** Um estudo mostrou que o fluido pré-aquecido a 39 graus só chega ao paciente acima de 37 graus com alto fluxo e temperatura ambiente alta [A38]. Aquecer o soro ajuda, mas não basta. Medir a temperatura na admissão e cobrir o paciente depois do exame são medidas simples.

**RESIDENTE:** Última parte: tomografia de corpo inteiro. Resolve tudo?

**PRECEPTOR:** Uma revisão de revisões concluiu que a tomografia de corpo inteiro de rotina parece ter pouco ou nenhum efeito na mortalidade e no tempo na sala de emergência [A12]. E mesmo com ela, um estudo encontrou lesões com diagnóstico tardio em 13,9 % dos pacientes [A42].

**RESIDENTE:** Treze vírgula nove por cento, mesmo com tomografia?

**PRECEPTOR:** Mesmo com tomografia. Por isso existe a avaliação terciária: reexaminar o paciente depois, com calma. E nem ela é infalível: em 0,26% dos pacientes graves, uma lesão potencialmente letal apareceu depois dela [A41].

**RESIDENTE:** Então o atendimento não acaba quando o paciente sai da sala de trauma.

**PRECEPTOR:** Não acaba. E para fazer tudo isso bem, duas coisas ajudam. A primeira é estrutura: um formulário de admissão do trauma melhorou 14 de 16 indicadores da avaliação primária [A13]; o registro da avaliação de vias aéreas subiu de 72,9% para 98,4% [A14]. A segunda é equipe: treinamento mensal no próprio local de trabalho, com debriefing em vídeo, reduziu o tempo de ressuscitação [A18]. E quando o líder era cirurgião, houve menos lesões não identificadas [A21].

**RESIDENTE:** Posso tentar resumir em cinco frases?

**PRECEPTOR:** Por favor.

**RESIDENTE:** Um: estruturar a avaliação melhora o processo, mas o efeito em mortalidade ainda é incerto. Dois: hemorragia que mata vem primeiro, e o benefício do torniquete em mortalidade não está comprovado. Três: não classificar o choque por um número isolado. Quatro: eFAST negativo não exclui pneumotórax. Cinco: reavaliar sempre, porque lesões tardias acontecem mesmo com tomografia.

**PRECEPTOR:** É isso. No aplicativo você encontra o resumo, os flashcards e o caso clínico deste tema. Até o próximo episódio.

**RESIDENTE:** Até lá!
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='podcast_roteiro' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Roteiro de podcast: "xABCDE: o que mudou e o que a evidência sustenta"

Formato: duas vozes — PRECEPTOR e RESIDENTE. Duração estimada: 8 a 10 minutos (cerca de 1.200 palavras). Tom: conversa de corredor, sem jargão desnecessário.

---

**PRECEPTOR:** Olá, este é o episódio do tema um do Programa de Cirurgia de Urgência e Trauma. Hoje a conversa é sobre a avaliação inicial do traumatizado. Comigo está um residente do primeiro ano.

**RESIDENTE:** Olá! E eu já chego com uma pergunta que sempre quis fazer: todo mundo faz o ATLS, todo mundo repete o ABCDE... mas isso salva vidas mesmo? Existe prova?

**PRECEPTOR:** Ótima pergunta para começar, porque a resposta honesta é: existe sinal, mas não existe prova forte. Uma revisão sistemática juntou 19 estudos, com mais de 92 mil pacientes [A1]. Os programas de treinamento em suporte de vida no trauma se associaram a menor mortalidade: razão de chances de 0,60 [A2].

**RESIDENTE:** Zero vírgula sessenta parece muito bom.

**PRECEPTOR:** Parece. Só que são estudos observacionais. Hospitais que treinam mais também costumam ter mais recursos, mais organização. Os próprios pesquisadores que estão conduzindo um grande ensaio na Índia escrevem que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes [A4]. Esse ensaio vai incluir pelo menos 4320 pacientes [A5]. Então a resposta definitiva ainda está por vir.

**RESIDENTE:** Entendi. A gente ensina porque faz sentido e porque há associação, mas com humildade sobre o tamanho do efeito.

**PRECEPTOR:** Exatamente. E agora o "x" na frente do ABCDE. O que ele significa?

**RESIDENTE:** Hemorragia exsanguinante. A ideia é que o sangramento externo que mata em minutos passa à frente da via aérea. [D2, D4]

**PRECEPTOR:** Isso. E a ferramenta que todo mundo associa a isso é o torniquete. O que você acha que a evidência mostra?

**RESIDENTE:** Imagino que reduz mortalidade, não?

**PRECEPTOR:** Uma revisão sistemática de torniquete pré-hospitalar encontrou mortalidade de 4,02% com torniquete contra 6,43% sem. Risco relativo de 0,70, mas o intervalo de confiança cruza o um. Ou seja: a redução não foi estatisticamente significativa [A23].

**RESIDENTE:** E tem algum lado negativo?

**PRECEPTOR:** Amputação inicial foi mais frequente no grupo torniquete: 19,32% contra 6,4%, risco relativo de 2,07 [A24]. Mas cuidado com a interpretação: quem recebe torniquete provavelmente tem lesão mais grave. É dado observacional. Não dá para dizer que o torniquete causou a amputação.

**RESIDENTE:** E o curativo compressivo? Esse eu faço toda semana.

**PRECEPTOR:** Tem um estudo curioso. Mediram a pressão real dos curativos compressivos: a média foi 169 milímetros de mercúrio, mas variou de 50 a 412 [A25]. E a percepção de quem aplicou não teve correlação com a pressão medida [A26].

**RESIDENTE:** Ou seja, eu acho que apertei bem e posso não ter apertado.

**PRECEPTOR:** Ou apertado demais. A lição é reavaliar o sangramento, não confiar na sensação.

**RESIDENTE:** Vamos para o A e o B. Uma dúvida prática: oxigênio para todo mundo?

**PRECEPTOR:** Uma pesquisa com profissionais mostrou que 73 % não apoiam dar oxigênio suplementar sempre, para todo traumatizado grave, sem olhar a saturação [A27]. Repare que isso é opinião de profissionais, não desfecho clínico. Mas mostra para onde a prática está indo: oxigênio guiado pela saturação.

**RESIDENTE:** E o ultrassom? Se o eFAST não mostra pneumotórax, posso ficar tranquilo?

**PRECEPTOR:** Aqui os estudos discordam. Um deles encontrou sensibilidade de 93,6% e especificidade de 99,8% para pneumotórax [A29]. Outro, prospectivo, encontrou baixa sensibilidade, com muitos falsos negativos [A30].

**RESIDENTE:** Então positivo eu acredito; negativo, com suspeita clínica, eu continuo investigando.

**PRECEPTOR:** Perfeito. Agora o C. Você aprendeu as classes de choque do ATLS?

**RESIDENTE:** Decorei para a prova. Classe um, dois, três, quatro.

**PRECEPTOR:** Pois a comparação clássica entre o déficit de base e esses parâmetros tradicionais teve um viés metodológico, que superestimou a classe de choque dos parâmetros tradicionais [A32]. E tem mais: uma revisão foi atrás da definição de "estabilidade hemodinâmica". Ela só estava definida em 70% dos artigos, e sem consenso nos pontos de corte [A33].

**RESIDENTE:** Então quando alguém diz "o paciente está estável"...

**PRECEPTOR:** ...pergunte: estável segundo o quê? Não classifique o choque por um número isolado. À beira do leito, o ultrassom ajuda: o protocolo RUSH teve sensibilidade de 94,2% em politraumatizados instáveis [A34]. E dá para olhar a sínfise púbica com o ultrassom: num estudo, 7,5% dos pacientes tinham alargamento crítico [A35].

**RESIDENTE:** E a parada cardíaca no trauma? Adrenalina?

**PRECEPTOR:** Num estudo de parada extra-hospitalar traumática, a adrenalina se associou a menor sobrevida em 7 dias: razão de chances de 0,20 [A31]. De novo, observacional. Mas reforça que parada traumática não é parada clínica: o foco é corrigir a causa.

**RESIDENTE:** Chegamos no E, de exposição. Confesso que é a letra que eu faço mais rápido.

**PRECEPTOR:** E é a mais negligenciada. Hipotermia está presente em até dois terços dos pacientes com trauma grave, e muitas vezes é desconsiderada na ressuscitação inicial [A36]. E, ao contrário da acidose e do sangramento, não existe uma abordagem baseada em evidência para manejá-la [A37].

**RESIDENTE:** Mas a gente usa soro aquecido.

**PRECEPTOR:** Um estudo mostrou que o fluido pré-aquecido a 39 graus só chega ao paciente acima de 37 graus com alto fluxo e temperatura ambiente alta [A38]. Aquecer o soro ajuda, mas não basta. Medir a temperatura na admissão e cobrir o paciente depois do exame são medidas simples.

**RESIDENTE:** Última parte: tomografia de corpo inteiro. Resolve tudo?

**PRECEPTOR:** Uma revisão de revisões concluiu que a tomografia de corpo inteiro de rotina parece ter pouco ou nenhum efeito na mortalidade e no tempo na sala de emergência [A12]. E mesmo com ela, um estudo encontrou lesões com diagnóstico tardio em 13,9 % dos pacientes [A42].

**RESIDENTE:** Treze vírgula nove por cento, mesmo com tomografia?

**PRECEPTOR:** Mesmo com tomografia. Por isso existe a avaliação terciária: reexaminar o paciente depois, com calma. E nem ela é infalível: em 0,26% dos pacientes graves, uma lesão potencialmente letal apareceu depois dela [A41].

**RESIDENTE:** Então o atendimento não acaba quando o paciente sai da sala de trauma.

**PRECEPTOR:** Não acaba. E para fazer tudo isso bem, duas coisas ajudam. A primeira é estrutura: um formulário de admissão do trauma melhorou 14 de 16 indicadores da avaliação primária [A13]; o registro da avaliação de vias aéreas subiu de 72,9% para 98,4% [A14]. A segunda é equipe: treinamento mensal no próprio local de trabalho, com debriefing em vídeo, reduziu o tempo de ressuscitação [A18]. E quando o líder era cirurgião, houve menos lesões não identificadas [A21].

**RESIDENTE:** Posso tentar resumir em cinco frases?

**PRECEPTOR:** Por favor.

**RESIDENTE:** Um: estruturar a avaliação melhora o processo, mas o efeito em mortalidade ainda é incerto. Dois: hemorragia que mata vem primeiro, e o benefício do torniquete em mortalidade não está comprovado. Três: não classificar o choque por um número isolado. Quatro: eFAST negativo não exclui pneumotórax. Cinco: reavaliar sempre, porque lesões tardias acontecem mesmo com tomografia.

**PRECEPTOR:** É isso. No aplicativo você encontra o resumo, os flashcards e o caso clínico deste tema. Até o próximo episódio.

**RESIDENTE:** Até lá!
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D4', $af$No pré-hospitalar, a hemorragia externa maciça é tratada primeiro.$af$, 'Mattox9_cap10_pre_hospitalar', $af$In the event of external massive hemorrhage, bleeding should be addressed first.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='podcast_roteiro' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='podcast_roteiro')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'protocolo', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='protocolo'),0)+1, 'rascunho', $T1$Protocolo assistencial$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Protocolo assistencial: avaliação inicial do traumatizado

**Proposta** para apresentação à diretoria do HCFMRP após a aula. Não é protocolo vigente. Integra o Protocolo de Imagem no Politrauma da UE-HCFMRP, versão preliminar de agosto de 2026, ainda em validação multidisciplinar [P1].

## 1. Título
Avaliação inicial do paciente traumatizado na sala vermelha.

## 2. Objetivo
Identificar e tratar rapidamente as lesões que ameaçam a vida [D1] de forma padronizada e registrada.

## 3. População-alvo
Todas as vítimas de trauma que entram pela sala vermelha do hospital. Em todas elas a equipe de cirurgia do trauma é acionada.

## 4. Definições
- Avaliação primária: ABCDE, ou CAB quando há hemorragia externa ou extremis [D2, D3].
- Avaliação secundária: história AMPLA (alergias, medicamentos, passado médico e prenhez, líquidos e alimentos ingeridos, ambiente e eventos) e exame completo [D20, D21].
- Avaliação terciária: reexame após a ressuscitação e as cirurgias [D31].
- Comprometimento hemodinâmico (critério institucional), qualquer um: PAS ≤80 mmHg; PAS ≤100 mmHg se TCE moderado ou grave; vasopressor ou transfusão em curso para manter a pressão; FC ≥ PAS, isto é, índice de choque ≥1 [P6]. O índice de choque serve para incluir, não para excluir instabilidade [P7]. O líder pode classificar o paciente como instável mesmo sem critério objetivo [P8].

## 5. Critérios de inclusão
Toda vítima de trauma admitida na sala vermelha (seção 3).

## 6. Critérios de exclusão
Nenhum. Pacientes em extremis seguem o fluxo CABDE [D3].

## 7. Avaliação inicial
1. Antes da chegada: líder (cirurgião do trauma ou Chefe da Emergência) e funções definidos [D22].
2. Passagem MIST em até 1 minuto [D23, D24].
3. Registro em formulário estruturado [A13, A14].

## 8. Conduta passo a passo
1. Hemorragia externa: compressão direta; torniquete no membro; sem pinçamento às cegas; cinta pélvica no alto risco [D6, D7, D8, D9].
2. Via aérea: Glasgow ≤8 indica via aérea definitiva, com exame neurológico antes da sedação [D11, D12].
3. Respiração: eFAST como adjunto; negativo não exclui pneumotórax [A30].
4. Circulação: pressão manual se houver dúvida; intraósseo sem veia [D14, D15]. No choque evidente, sangue e plasma começam cedo, antes ou em vez de cristaloide [D39]. Acionar o protocolo de transfusão maciça pelos critérios do item 8.9.
5. Neurológico: Glasgow na chegada e repetido [D16].
6. Exposição: despir e aquecer [D18, D19]; medir a temperatura.
7. Secundária: AMPLA e exame completo [D21].
8. TC de corpo inteiro (pan-TC): indicada quando há pelo menos um de três grupos de critérios: mecanismo, critérios clínicos ou fisiológicos, ou TCE moderado a grave [P2] (por exemplo, desaceleração severa ou capotamento [P3]; trauma evidente em várias regiões do corpo [P4]; Glasgow ≤12 aferido antes da sedação [P5]). Sem critério, a imagem é dirigida pelo mecanismo, pelo exame e por regras clínicas [P11]. Pan-TC não é sinônimo de qualquer trauma [P15]. O paciente instável ou sem resposta adequada vai primeiro para o controle da causa [P9]; o protocolo rápido de aquisição não é indicação de tomografia [P10]. Não esperar creatinina nem jejum [P12]; afrouxar ou retirar o torniquete antes da angio-TC do membro [P13]. **[Protocolo de tomografia de corpo inteiro em anexo]**
9. Acionamento do protocolo de transfusão maciça. Acionar se houver qualquer um:
   - Escore ABC: FAST positivo, mecanismo penetrante, FC acima de 120 bpm, PAS abaixo de 90 mmHg, um ponto cada [D33]. Acionar com 2 ou mais pontos (ponto de corte confirmado pelo serviço em 12/11/2026).
   - Índice de choque ≥1 ou outro critério institucional de comprometimento hemodinâmico (seção 4) [P6]. Em adultos, índice de choque acima de 0,9 associou-se a risco de morte de 16%, contra 6% abaixo de 0,9 [D38]; a diretriz europeia recomenda o índice de choque e/ou a pressão de pulso para estimar choque e necessidade de transfusão [G5].
   - Avaliação do líder do atendimento: ele pode acionar mesmo sem critério objetivo [P8]. Os escores têm bom valor preditivo negativo, mas valor preditivo positivo fraco; a experiência decide [D34].
   - Durante o atendimento, atingir o limiar crítico de 3 concentrados de hemácias em qualquer período de 1 hora nas primeiras 24 horas [D37].
   Ao acionar, avisar o banco de sangue de imediato [D35]. O hospital deve ter protocolo de transfusão maciça com acesso imediato aos hemocomponentes [D36]. O protocolo de transfusão maciça do HCFMRP estará disponível em anexo próprio, na aula do tema de coagulopatia e transfusão maciça.

## 9. Materiais necessários
Cinta pélvica, torniquetes, kit de intraósseo, mantas aquecidas, manta de ar forçado e aquecedor de fluidos [D19], ultrassom.

## 10. Complicações esperadas
Lesões não identificadas [A42]; hipotermia [A36]; amputação associada ao torniquete [A24].

## 11. Manejo das complicações
Avaliação terciária com revisão das imagens [D30]; hipotensão após a ressuscitação tratada como sangramento até prova em contrário [D32].

## 12. Critérios de transferência da sala vermelha
A decisão é do líder do atendimento [D22], registrada no formulário.
1. **Centro cirúrgico, sem passar pela tomografia.** Paciente instável ou sem resposta adequada à reposição (seção 4) com fonte provável de sangramento, priorizado para controle imediato da causa [P9]. Também o paciente que respondeu à reposição, mas precisa de cirurgia de emergência, como no tamponamento cardíaco ou no trauma de extremidade com sangramento exsanguinante [D40].
   A diretriz europeia recomenda controle imediato do sangramento quando a fonte é evidente e no choque em extremis com fonte suspeita [G6].
2. **Radiologia intervencionista.** Paciente que precisa de controle de sangramento por via endovascular, como na fratura pélvica grave, sem atraso para outros exames [D40]. A colaboração próxima entre radiologia intervencionista e cirurgia associou-se a sobrevida 15,5% maior que a prevista [A22]. Disponível 24 horas por dia (informação do serviço, 12/11/2026). **[definir com a radiologia intervencionista: tempo de acionamento e uso de sala híbrida]**
3. **Tomografia.** Paciente estável, ou que respondeu à reposição sem necessidade evidente de intervenção, com critério de pan-TC (item 8.8) [D41, P2]. Instável não vai à tomografia para diagnóstico [P9, P10]. Sem fonte identificada e sem necessidade de controle imediato, investigar de imediato [G7]. Meta de porta-tomografia de 30 minutos ainda pendente no protocolo de imagem [P14].
4. **UTI.** **[proposta, sem fonte carregada; validar com a UTI]** Depois do controle do sangramento, ou da tomografia sem indicação cirúrgica imediata, se houver: via aérea definitiva ou ventilação mecânica; vasopressor ou transfusão em curso; protocolo de transfusão maciça acionado; TCE grave (Glasgow ≤8); necessidade de monitorização contínua. Na UTI, fazer a avaliação terciária com revisão das imagens [D30].
5. **Enfermaria ou observação.** Paciente estável, com avaliações primária e secundária concluídas, sem indicação cirúrgica, de intervenção ou de UTI. Avaliação terciária depois [D31].

## 13. Critérios de alta da sala de trauma
Avaliações primária e secundária concluídas e registradas; destino definido pelo líder pelos critérios da seção 12 [D22].

## 14. Indicadores de qualidade
Preenchimento do formulário; registro da via aérea [A14]; temperatura medida na admissão; tempo porta-tomografia (meta de 30 minutos a validar [P14]); tempo até acionar o protocolo de transfusão maciça; pacientes instáveis levados à tomografia; lesões de diagnóstico tardio [A42].

## 15. Referências
Camada 1: Carmont, história do ATLS, Postgrad Med J 2005 [H1]. Camada 2: Mattox, Trauma 9ª ed., capítulos 10, 13, 15, 16, 44, 48 e 57; ATLS, edição atual (anúncio oficial do ACS, 2025) [D44]. Camada 3: Protocolo de Imagem no Politrauma da UE-HCFMRP-USP, versão preliminar de agosto de 2026 (em validação) [P1]. Camada 4: artigos A1 a A47 da síntese de evidência do T001. Camada 5: diretriz europeia de sangramento maior no trauma, 6ª edição (Rossaint et al., Crit Care 2023;27:80) [G1].
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='protocolo' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Protocolo assistencial: avaliação inicial do traumatizado

**Proposta** para apresentação à diretoria do HCFMRP após a aula. Não é protocolo vigente. Integra o Protocolo de Imagem no Politrauma da UE-HCFMRP, versão preliminar de agosto de 2026, ainda em validação multidisciplinar [P1].

## 1. Título
Avaliação inicial do paciente traumatizado na sala vermelha.

## 2. Objetivo
Identificar e tratar rapidamente as lesões que ameaçam a vida [D1] de forma padronizada e registrada.

## 3. População-alvo
Todas as vítimas de trauma que entram pela sala vermelha do hospital. Em todas elas a equipe de cirurgia do trauma é acionada.

## 4. Definições
- Avaliação primária: ABCDE, ou CAB quando há hemorragia externa ou extremis [D2, D3].
- Avaliação secundária: história AMPLA (alergias, medicamentos, passado médico e prenhez, líquidos e alimentos ingeridos, ambiente e eventos) e exame completo [D20, D21].
- Avaliação terciária: reexame após a ressuscitação e as cirurgias [D31].
- Comprometimento hemodinâmico (critério institucional), qualquer um: PAS ≤80 mmHg; PAS ≤100 mmHg se TCE moderado ou grave; vasopressor ou transfusão em curso para manter a pressão; FC ≥ PAS, isto é, índice de choque ≥1 [P6]. O índice de choque serve para incluir, não para excluir instabilidade [P7]. O líder pode classificar o paciente como instável mesmo sem critério objetivo [P8].

## 5. Critérios de inclusão
Toda vítima de trauma admitida na sala vermelha (seção 3).

## 6. Critérios de exclusão
Nenhum. Pacientes em extremis seguem o fluxo CABDE [D3].

## 7. Avaliação inicial
1. Antes da chegada: líder (cirurgião do trauma ou Chefe da Emergência) e funções definidos [D22].
2. Passagem MIST em até 1 minuto [D23, D24].
3. Registro em formulário estruturado [A13, A14].

## 8. Conduta passo a passo
1. Hemorragia externa: compressão direta; torniquete no membro; sem pinçamento às cegas; cinta pélvica no alto risco [D6, D7, D8, D9].
2. Via aérea: Glasgow ≤8 indica via aérea definitiva, com exame neurológico antes da sedação [D11, D12].
3. Respiração: eFAST como adjunto; negativo não exclui pneumotórax [A30].
4. Circulação: pressão manual se houver dúvida; intraósseo sem veia [D14, D15]. No choque evidente, sangue e plasma começam cedo, antes ou em vez de cristaloide [D39]. Acionar o protocolo de transfusão maciça pelos critérios do item 8.9.
5. Neurológico: Glasgow na chegada e repetido [D16].
6. Exposição: despir e aquecer [D18, D19]; medir a temperatura.
7. Secundária: AMPLA e exame completo [D21].
8. TC de corpo inteiro (pan-TC): indicada quando há pelo menos um de três grupos de critérios: mecanismo, critérios clínicos ou fisiológicos, ou TCE moderado a grave [P2] (por exemplo, desaceleração severa ou capotamento [P3]; trauma evidente em várias regiões do corpo [P4]; Glasgow ≤12 aferido antes da sedação [P5]). Sem critério, a imagem é dirigida pelo mecanismo, pelo exame e por regras clínicas [P11]. Pan-TC não é sinônimo de qualquer trauma [P15]. O paciente instável ou sem resposta adequada vai primeiro para o controle da causa [P9]; o protocolo rápido de aquisição não é indicação de tomografia [P10]. Não esperar creatinina nem jejum [P12]; afrouxar ou retirar o torniquete antes da angio-TC do membro [P13]. **[Protocolo de tomografia de corpo inteiro em anexo]**
9. Acionamento do protocolo de transfusão maciça. Acionar se houver qualquer um:
   - Escore ABC: FAST positivo, mecanismo penetrante, FC acima de 120 bpm, PAS abaixo de 90 mmHg, um ponto cada [D33]. Acionar com 2 ou mais pontos (ponto de corte confirmado pelo serviço em 12/11/2026).
   - Índice de choque ≥1 ou outro critério institucional de comprometimento hemodinâmico (seção 4) [P6]. Em adultos, índice de choque acima de 0,9 associou-se a risco de morte de 16%, contra 6% abaixo de 0,9 [D38]; a diretriz europeia recomenda o índice de choque e/ou a pressão de pulso para estimar choque e necessidade de transfusão [G5].
   - Avaliação do líder do atendimento: ele pode acionar mesmo sem critério objetivo [P8]. Os escores têm bom valor preditivo negativo, mas valor preditivo positivo fraco; a experiência decide [D34].
   - Durante o atendimento, atingir o limiar crítico de 3 concentrados de hemácias em qualquer período de 1 hora nas primeiras 24 horas [D37].
   Ao acionar, avisar o banco de sangue de imediato [D35]. O hospital deve ter protocolo de transfusão maciça com acesso imediato aos hemocomponentes [D36]. O protocolo de transfusão maciça do HCFMRP estará disponível em anexo próprio, na aula do tema de coagulopatia e transfusão maciça.

## 9. Materiais necessários
Cinta pélvica, torniquetes, kit de intraósseo, mantas aquecidas, manta de ar forçado e aquecedor de fluidos [D19], ultrassom.

## 10. Complicações esperadas
Lesões não identificadas [A42]; hipotermia [A36]; amputação associada ao torniquete [A24].

## 11. Manejo das complicações
Avaliação terciária com revisão das imagens [D30]; hipotensão após a ressuscitação tratada como sangramento até prova em contrário [D32].

## 12. Critérios de transferência da sala vermelha
A decisão é do líder do atendimento [D22], registrada no formulário.
1. **Centro cirúrgico, sem passar pela tomografia.** Paciente instável ou sem resposta adequada à reposição (seção 4) com fonte provável de sangramento, priorizado para controle imediato da causa [P9]. Também o paciente que respondeu à reposição, mas precisa de cirurgia de emergência, como no tamponamento cardíaco ou no trauma de extremidade com sangramento exsanguinante [D40].
   A diretriz europeia recomenda controle imediato do sangramento quando a fonte é evidente e no choque em extremis com fonte suspeita [G6].
2. **Radiologia intervencionista.** Paciente que precisa de controle de sangramento por via endovascular, como na fratura pélvica grave, sem atraso para outros exames [D40]. A colaboração próxima entre radiologia intervencionista e cirurgia associou-se a sobrevida 15,5% maior que a prevista [A22]. Disponível 24 horas por dia (informação do serviço, 12/11/2026). **[definir com a radiologia intervencionista: tempo de acionamento e uso de sala híbrida]**
3. **Tomografia.** Paciente estável, ou que respondeu à reposição sem necessidade evidente de intervenção, com critério de pan-TC (item 8.8) [D41, P2]. Instável não vai à tomografia para diagnóstico [P9, P10]. Sem fonte identificada e sem necessidade de controle imediato, investigar de imediato [G7]. Meta de porta-tomografia de 30 minutos ainda pendente no protocolo de imagem [P14].
4. **UTI.** **[proposta, sem fonte carregada; validar com a UTI]** Depois do controle do sangramento, ou da tomografia sem indicação cirúrgica imediata, se houver: via aérea definitiva ou ventilação mecânica; vasopressor ou transfusão em curso; protocolo de transfusão maciça acionado; TCE grave (Glasgow ≤8); necessidade de monitorização contínua. Na UTI, fazer a avaliação terciária com revisão das imagens [D30].
5. **Enfermaria ou observação.** Paciente estável, com avaliações primária e secundária concluídas, sem indicação cirúrgica, de intervenção ou de UTI. Avaliação terciária depois [D31].

## 13. Critérios de alta da sala de trauma
Avaliações primária e secundária concluídas e registradas; destino definido pelo líder pelos critérios da seção 12 [D22].

## 14. Indicadores de qualidade
Preenchimento do formulário; registro da via aérea [A14]; temperatura medida na admissão; tempo porta-tomografia (meta de 30 minutos a validar [P14]); tempo até acionar o protocolo de transfusão maciça; pacientes instáveis levados à tomografia; lesões de diagnóstico tardio [A42].

## 15. Referências
Camada 1: Carmont, história do ATLS, Postgrad Med J 2005 [H1]. Camada 2: Mattox, Trauma 9ª ed., capítulos 10, 13, 15, 16, 44, 48 e 57; ATLS, edição atual (anúncio oficial do ACS, 2025) [D44]. Camada 3: Protocolo de Imagem no Politrauma da UE-HCFMRP-USP, versão preliminar de agosto de 2026 (em validação) [P1]. Camada 4: artigos A1 a A47 da síntese de evidência do T001. Camada 5: diretriz europeia de sangramento maior no trauma, 6ª edição (Rossaint et al., Crit Care 2023;27:80) [G1].
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A22', $af$A sobrevida no grupo com colaboração próxima entre radiologia intervencionista e cirurgia foi 15,5% maior que a prevista (IC 95% 7,5–23,6%).$af$, '2024_64', $af$the survival rate in the CG was 15.5% higher than the Ps (95% CI: 7.5–23.6%; p < 0.001)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A47', $af$O estudo que mostrou baixa sensibilidade do ultrassom torácico incluiu só trauma torácico fechado.$af$, '2024_47', $af$A prospective observational analysis of patients with blunt chest trauma$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D33', $af$O escore ABC usa quatro variáveis: FAST positivo, mecanismo penetrante, FC acima de 120 bpm e PAS abaixo de 90 mmHg.$af$, 'Mattox9_cap16_coagulopatia', $af$These include a positive FAST, penetrating mechanism, heart rate >120 bpm, and systolic blood pressure less than 90 mm Hg.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D34', $af$Os escores de previsão de transfusão maciça têm alto valor preditivo negativo, mas baixo valor preditivo positivo; a decisão depende da experiência.$af$, 'Mattox9_cap16_coagulopatia', $af$high negative predictive value but universally lack a strong positive predictive value$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D35', $af$O objetivo é avisar cedo o banco de sangue da necessidade urgente de grande volume de hemocomponentes.$af$, 'Mattox9_cap16_coagulopatia', $af$early communication to the blood bank of the urgent need of a large volume of blood products$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D36', $af$O hospital deve ter um protocolo de transfusão maciça que garanta acesso imediato aos hemocomponentes.$af$, 'Mattox9_cap15_choque', $af$Hospitals should have a massive transfusion protocol$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D37', $af$Uma definição atual de transfusão maciça é o limiar crítico: pelo menos 3 concentrados de hemácias em qualquer período de 1 hora nas primeiras 24 horas.$af$, 'Mattox9_cap15_choque', $af$at least 3 PRBC units within any 1-hour period in the first 24 hours of admission$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D38', $af$Em adultos, o risco de morte foi de 16% com índice de choque acima de 0,9 e de 6% abaixo de 0,9.$af$, 'Mattox9_cap48_pediatrico', $af$death is 16% when the SI is greater than 0.9 compared to a 6% risk of death when the SI is less than 0.9$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D39', $af$No choque evidente com possível transfusão maciça, sangue e plasma devem começar cedo, antes ou mesmo em vez de cristaloide.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$should begin prior to and even in lieu of crystalloid$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D40', $af$Pacientes que precisam de intervenção de emergência vão ao centro cirúrgico ou à radiologia intervencionista sem atraso para imagem, mesmo que tenham respondido à reposição.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$emergent surgery or interventional radiology without further radiologic or investigatory delay$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D41', $af$Quem responde à reposição sem necessidade evidente de intervenção pode fazer a investigação completa.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Patients who respond without obvious need for intervention may undergo complete trauma workup as needed.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D44', $af$Na edição atual do ATLS, o ABCDE passou a xABCDE: o x indica o controle rápido da hemorragia externa exsanguinante, que salva vidas em alguns pacientes.$af$, 'ACS_ATLS11_anuncio_2025', $af$For certain patients, rapid control of exsanguinating external hemorrhage is lifesaving. To reflect this additional focus, the letter “x” was added to the beginning of the well-known ATLS mnemonic. ABCDE is now xABCDE.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G1', $af$Recomenda-se reduzir ao mínimo o tempo entre a lesão e o controle do sangramento (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the time elapsed between injury and bleeding control be minimised (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G5', $af$Recomenda-se usar o índice de choque e/ou a pressão de pulso para estimar o grau de choque e a necessidade de transfusão (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the shock index (SI) and/or pulse pressure (PP) be used to assess the degree of hypovolaemic shock and transfusion requirements (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G6', $af$Recomenda-se controle imediato do sangramento quando a fonte é evidente e no choque em extremis com fonte suspeita (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that patients with an obvious bleeding source and those presenting with haemorrhagic shock in extremis and a suspected source of bleeding undergo an immediate bleeding control procedure (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G7', $af$Sem fonte identificada e sem necessidade de controle imediato, recomenda-se investigação imediata para achar a fonte (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that patients with an unidentified source of bleeding, but without a need for immediate bleeding control, undergo immediate further investigation to determine the bleeding source (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H1', $af$O ATLS nasceu depois de um acidente aéreo em 1976 no interior de Nebraska, em que o cirurgião ortopedista James Styner se feriu, perdeu a esposa e teve três filhos gravemente feridos, e considerou errado o atendimento que receberam.$af$, 'Carmont2005_historia_ATLS', $af$He was horrified at the treatment his family received at a local hospital in rural Nebraska and decided that the established system for managing the severely injured was wrong.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P1', $af$O protocolo de imagem da UE é uma versão preliminar, em validação multidisciplinar.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Documento em construção e validação multidisciplinar$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P2', $af$A pan-TC é indicada quando há pelo menos um de três grupos de critérios: mecanismo, critérios clínicos/fisiológicos ou TCE moderado a grave.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Indicar Pan-TC quando houver pelo menos UM dos três grupos abaixo$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P3', $af$Entre os critérios de mecanismo está desaceleração severa ou capotamento.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Desaceleração severa ou capotamento$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P4', $af$Entre os critérios clínicos está trauma evidente em múltiplas regiões corporais.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Trauma evidente em múltiplas regiões corporais$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P5', $af$TCE moderado a grave: Glasgow ≤12, aferido antes de sedação e após corrigir hipóxia, hipotensão e hipoglicemia.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$GCS <=12, aferido antes de sedação/bloqueio e após correção de hipóxia, hipotensão e hipoglicemia$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P6', $af$Comprometimento hemodinâmico é qualquer um: PAS ≤80 mmHg; PAS ≤100 mmHg com TCE moderado/grave; vasopressor ou transfusão para manter a pressão; FC ≥ PAS (índice de choque ≥1).$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Qualquer um: PAS <=80 mmHg; PAS <=100 mmHg se TCE moderado/grave; vasopressor ou transfusão em curso para manter a pressão; FC >= PAS (índice de choque >=1).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P7', $af$O índice de choque serve para incluir, não para excluir instabilidade.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$O índice de choque serve para INCLUIR, não para excluir instabilidade.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P8', $af$O líder do trauma pode classificar o paciente como instável mesmo sem critério objetivo.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$O líder do trauma pode classificar o paciente como instável mesmo sem preenchimento de critério objetivo$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P9', $af$Pacientes instáveis ou sem resposta adequada são priorizados para controle imediato da causa.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$pacientes instáveis ou sem resposta adequada devem ser priorizados para controle imediato da causa$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P10', $af$O protocolo de aquisição rápida não constitui indicação de tomografia.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Sua existência NÃO constitui indicação de tomografia.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P11', $af$Sem critério para pan-TC, a imagem é dirigida pelo mecanismo, exame físico e regras clínicas.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Imagem dirigida conforme mecanismo, exame físico e regras clínicas$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P12', $af$No politrauma com TC contrastada indicada, não é preciso esperar creatinina nem jejum.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$não é necessário aguardar resultado de creatinina nem jejum$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P13', $af$Antes da angio-TC de extremidade, o torniquete deve ser afrouxado ou retirado pela equipe assistente.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$deverá ser afrouxado ou retirado pela equipe assistente$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P14', $af$Está pendente incorporar a meta de porta-tomografia de 30 minutos.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Incorporar a meta de porta-tomografia de 30 minutos$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P15', $af$Pan-TC não é sinônimo de qualquer trauma.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Pan-TC não é sinônimo de qualquer trauma.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='protocolo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='protocolo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'resumo', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='resumo'),0)+1, 'rascunho', $T1$Resumo executivo$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Resumo executivo

Tempo de leitura: cerca de 10 minutos. Cinco seções.

## 1. Por que importa

O objetivo é identificar e tratar rapidamente o que ameaça a vida [D1], e a fisiologia alterada é o que mais pesa no desfecho [D26]: com PAS abaixo de 90 mmHg e necessidade de laparotomia de emergência, a mortalidade passa de 40% [D27]. Treinar a equipe associa-se a menor mortalidade (OR 0,60), mas em estudos observacionais [A2].

## 2. O que a evidência diz

- Hemorragia externa ou extremis: circulação antes da via aérea (CAB) [D2, D3].
- Estruturar funciona para o processo: o formulário de admissão melhorou 14 de 16 indicadores [A13]; checklist melhora a adesão [A8], com efeito em mortalidade incerto [A9, A10].
- Torniquete pré-hospitalar: mortalidade sem redução significativa (RR 0,70) e mais amputação inicial (RR 2,07) [A23, A24].
- eFAST para pneumotórax: resultados conflitantes [A29, A30].
- TC de corpo inteiro de rotina: pouco ou nenhum efeito em mortalidade [A12]; lesões tardias em 13,9 % mesmo com ela [A42].
- Hipotermia em até dois terços dos graves [A36], sem manejo baseado em evidência [A37].

## 3. Como se faz

1. Antes da chegada: líder definido e funções distribuídas [D22].
2. Passagem MIST em até 1 minuto [D23, D24].
3. Compressão direta; torniquete no membro; cinta pélvica no alto risco [D6, D7, D9].
4. Via aérea: voz normal = pérvia; Glasgow ≤8 = via aérea definitiva [D10, D11].
5. Circulação: pressão manual se houver dúvida; intraósseo sem veia [D14, D15].
6. Glasgow repetido; despir e aquecer [D16, D18, D19].
7. Secundária com AMPLA; terciária depois [D21, D31].

## 4. O que dá errado

- Confiar no aparelho automático de pressão no choque [D14].
- Ler agitação como embriaguez, quando pode ser choque [D17].
- Esquecer de aquecer depois de despir [D19, A36].
- Encerrar a investigação com eFAST negativo [A30].
- Pinçar às cegas uma ferida profunda [D8].
- Achar que a TC dispensa reavaliação [A42].

## 5. O que levar para o plantão

1. Sangramento externo grave vem primeiro.
2. Tratar cada problema ao encontrá-lo e reavaliar.
3. Um líder, uma passagem curta e estruturada.
4. Despir, aquecer e repetir o Glasgow.
5. Fazer a avaliação terciária: a sala de trauma não encerra o diagnóstico.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='resumo' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Resumo executivo

Tempo de leitura: cerca de 10 minutos. Cinco seções.

## 1. Por que importa

O objetivo é identificar e tratar rapidamente o que ameaça a vida [D1], e a fisiologia alterada é o que mais pesa no desfecho [D26]: com PAS abaixo de 90 mmHg e necessidade de laparotomia de emergência, a mortalidade passa de 40% [D27]. Treinar a equipe associa-se a menor mortalidade (OR 0,60), mas em estudos observacionais [A2].

## 2. O que a evidência diz

- Hemorragia externa ou extremis: circulação antes da via aérea (CAB) [D2, D3].
- Estruturar funciona para o processo: o formulário de admissão melhorou 14 de 16 indicadores [A13]; checklist melhora a adesão [A8], com efeito em mortalidade incerto [A9, A10].
- Torniquete pré-hospitalar: mortalidade sem redução significativa (RR 0,70) e mais amputação inicial (RR 2,07) [A23, A24].
- eFAST para pneumotórax: resultados conflitantes [A29, A30].
- TC de corpo inteiro de rotina: pouco ou nenhum efeito em mortalidade [A12]; lesões tardias em 13,9 % mesmo com ela [A42].
- Hipotermia em até dois terços dos graves [A36], sem manejo baseado em evidência [A37].

## 3. Como se faz

1. Antes da chegada: líder definido e funções distribuídas [D22].
2. Passagem MIST em até 1 minuto [D23, D24].
3. Compressão direta; torniquete no membro; cinta pélvica no alto risco [D6, D7, D9].
4. Via aérea: voz normal = pérvia; Glasgow ≤8 = via aérea definitiva [D10, D11].
5. Circulação: pressão manual se houver dúvida; intraósseo sem veia [D14, D15].
6. Glasgow repetido; despir e aquecer [D16, D18, D19].
7. Secundária com AMPLA; terciária depois [D21, D31].

## 4. O que dá errado

- Confiar no aparelho automático de pressão no choque [D14].
- Ler agitação como embriaguez, quando pode ser choque [D17].
- Esquecer de aquecer depois de despir [D19, A36].
- Encerrar a investigação com eFAST negativo [A30].
- Pinçar às cegas uma ferida profunda [D8].
- Achar que a TC dispensa reavaliação [A42].

## 5. O que levar para o plantão

1. Sangramento externo grave vem primeiro.
2. Tratar cada problema ao encontrá-lo e reavaliar.
3. Um líder, uma passagem curta e estruturada.
4. Despir, aquecer e repetir o Glasgow.
5. Fazer a avaliação terciária: a sala de trauma não encerra o diagnóstico.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'resumo_basico', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='resumo_basico'),0)+1, 'rascunho', $T1$Resumo básico$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Resumo básico: avaliação inicial do traumatizado

Tempo de leitura: cerca de 10 minutos. Para quem chega ao tema sem base.

## Para que serve

A avaliação inicial existe para achar e tratar, rapidamente, o que pode matar o paciente agora [D1]. Ela não é um questionário: cada problema encontrado é tratado na hora, antes de seguir. O que mais define se o paciente vai bem não é a quantidade de lesões, e sim o quanto a fisiologia dele está alterada [D26].

## A ordem

A ordem padrão é ABCDE: via aérea, respiração, circulação, estado neurológico e exposição. Há uma exceção importante: quando há sangramento externo grave ou o paciente chega em extremis, a circulação vem primeiro (CAB) [D2, D3]. No pré-hospitalar, a regra é a mesma: hemorragia externa maciça primeiro [D4]. Na prática, uma equipe faz várias etapas ao mesmo tempo [D5].

## Letra por letra

- **Sangramento externo:** comprima diretamente o ponto que sangra [D6]. No braço ou na perna, o torniquete pode salvar a vida [D7]. Não pince às cegas dentro de feridas profundas [D8]. Se houver suspeita de fratura de bacia com sangramento, a cinta pélvica vai já [D9].
- **Via aérea:** se o paciente fala com voz normal, a via aérea está pérvia [D10]. Se o Glasgow for 8 ou menos, ele precisa de via aérea definitiva [D11], e o exame neurológico é feito antes de sedar [D12].
- **Respiração:** examine o tórax; o ultrassom ajuda, mas um exame negativo nem sempre exclui pneumotórax [A30].
- **Circulação:** veja pulso, pele e consciência. O aparelho automático de pressão pode errar no choque [D14]. Sem veia, o acesso intraósseo é uma saída [D15].
- **Neurológico:** Glasgow na chegada e de novo durante o atendimento [D16]. Agitação pode ser choque, não só bebida ou trauma de crânio [D17].
- **Exposição:** tire toda a roupa para ver o corpo inteiro [D18] e depois aqueça o paciente [D19]. Hipotermia é comum e esquecida [A36].

## Depois da primária

A avaliação secundária é a história (AMPLA: alergias, medicações, doenças, última refeição, eventos) e o exame da cabeça aos pés [D20, D21]. Mais tarde, com o paciente estabilizado, vem a avaliação terciária, que busca o que passou despercebido [D31]. Isso importa: mesmo com tomografia, lesões são descobertas depois [A42].

## A equipe

Um líder, de preferência o cirurgião do trauma, coordena e fica com a visão do todo [D22]. A equipe do pré-hospitalar passa o caso em menos de um minuto, num formato fixo como o MIST [D23, D24]. Formulários e checklists ajudam a não esquecer etapas [A8, A13].

## Leve para o plantão

1. Sangramento externo grave: comprimir antes de tudo.
2. Tratar cada problema assim que aparece.
3. Despir e aquecer.
4. Reavaliar sempre: lesão escondida aparece depois.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='resumo_basico' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Resumo básico: avaliação inicial do traumatizado

Tempo de leitura: cerca de 10 minutos. Para quem chega ao tema sem base.

## Para que serve

A avaliação inicial existe para achar e tratar, rapidamente, o que pode matar o paciente agora [D1]. Ela não é um questionário: cada problema encontrado é tratado na hora, antes de seguir. O que mais define se o paciente vai bem não é a quantidade de lesões, e sim o quanto a fisiologia dele está alterada [D26].

## A ordem

A ordem padrão é ABCDE: via aérea, respiração, circulação, estado neurológico e exposição. Há uma exceção importante: quando há sangramento externo grave ou o paciente chega em extremis, a circulação vem primeiro (CAB) [D2, D3]. No pré-hospitalar, a regra é a mesma: hemorragia externa maciça primeiro [D4]. Na prática, uma equipe faz várias etapas ao mesmo tempo [D5].

## Letra por letra

- **Sangramento externo:** comprima diretamente o ponto que sangra [D6]. No braço ou na perna, o torniquete pode salvar a vida [D7]. Não pince às cegas dentro de feridas profundas [D8]. Se houver suspeita de fratura de bacia com sangramento, a cinta pélvica vai já [D9].
- **Via aérea:** se o paciente fala com voz normal, a via aérea está pérvia [D10]. Se o Glasgow for 8 ou menos, ele precisa de via aérea definitiva [D11], e o exame neurológico é feito antes de sedar [D12].
- **Respiração:** examine o tórax; o ultrassom ajuda, mas um exame negativo nem sempre exclui pneumotórax [A30].
- **Circulação:** veja pulso, pele e consciência. O aparelho automático de pressão pode errar no choque [D14]. Sem veia, o acesso intraósseo é uma saída [D15].
- **Neurológico:** Glasgow na chegada e de novo durante o atendimento [D16]. Agitação pode ser choque, não só bebida ou trauma de crânio [D17].
- **Exposição:** tire toda a roupa para ver o corpo inteiro [D18] e depois aqueça o paciente [D19]. Hipotermia é comum e esquecida [A36].

## Depois da primária

A avaliação secundária é a história (AMPLA: alergias, medicações, doenças, última refeição, eventos) e o exame da cabeça aos pés [D20, D21]. Mais tarde, com o paciente estabilizado, vem a avaliação terciária, que busca o que passou despercebido [D31]. Isso importa: mesmo com tomografia, lesões são descobertas depois [A42].

## A equipe

Um líder, de preferência o cirurgião do trauma, coordena e fica com a visão do todo [D22]. A equipe do pré-hospitalar passa o caso em menos de um minuto, num formato fixo como o MIST [D23, D24]. Formulários e checklists ajudam a não esquecer etapas [A8, A13].

## Leve para o plantão

1. Sangramento externo grave: comprimir antes de tudo.
2. Tratar cada problema assim que aparece.
3. Despir e aquecer.
4. Reavaliar sempre: lesão escondida aparece depois.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D4', $af$No pré-hospitalar, a hemorragia externa maciça é tratada primeiro.$af$, 'Mattox9_cap10_pre_hospitalar', $af$In the event of external massive hemorrhage, bleeding should be addressed first.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='resumo_basico' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='resumo_basico')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'sintese_evidencia', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='sintese_evidencia'),0)+1, 'rascunho', $T1$Síntese de evidência$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Síntese de evidência: consenso, disputa, lacunas e controvérsias

Tempo de leitura: cerca de 10 minutos. Base nas cinco camadas: história do ATLS e de suas edições antigas (camada 1); capítulos do Mattox e o ATLS vigente (camada 2); Protocolo de Imagem no Politrauma da UE-HCFMRP, versão preliminar (camada 3); 75 artigos da revisão dos últimos 10 anos (camada 4); diretriz europeia de sangramento maior no trauma, 6ª edição, 2023 (camada 5).

## Consenso

- **Origem.** O ATLS nasceu de um acidente aéreo em 1976 no interior de Nebraska, quando um cirurgião julgou errado o atendimento dado à própria família [H1]. Foi feito para quem não atende trauma com frequência [H2]; os cursos-piloto foram em 1977 e, em 1980, o curso já era nacional [H3]. Tratar primeiro a maior ameaça à vida foi controverso no início, por fugir da sequência história, exame e diagnóstico diferencial [H4].
- **Objetivo.** A avaliação inicial serve para identificar e tratar rapidamente as lesões que ameaçam a vida [D1]. A alteração fisiológica é o maior determinante do desfecho [D26].
- **Ordem.** A sequência padrão é ABCDE. Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação vem antes da via aérea (CAB, CABDE) [D2, D3]. No pré-hospitalar, a hemorragia externa maciça é tratada primeiro [D4]. Embora ensinada passo a passo, boa parte da avaliação é feita ao mesmo tempo pela equipe [D5]. A edição atual do ATLS passou a usar xABCDE: o x é o controle rápido da hemorragia externa exsanguinante [D44].
- **Hemorragia externa.** Compressão direta primeiro [D6]; no membro, o torniquete pode salvar a vida [D7]; não pinçar às cegas [D8]; cinta pélvica imediata nos pacientes de alto risco [D9].
- **Via aérea.** Quem fala com voz normal não tem obstrução [D10]. Glasgow ≤8 indica via aérea definitiva [D11], com exame neurológico breve antes de sedar e paralisar [D12].
- **Circulação.** O aparelho automático de pressão pode errar no choque [D14]; sem acesso venoso imediato, considerar o intraósseo [D15], que pode salvar vidas no choque [D28].
- **Neurológico e exposição.** Glasgow na chegada e repetido [D16]; agitação também é sinal de choque classe III e IV [D17]. Despir por completo [D18] e, terminado o exame, aquecer: mantas, ar forçado e fluidos aquecidos [D19].
- **Avaliação secundária e terciária.** A secundária é história (AMPLA) e exame completos para achar todas as demais lesões [D20, D21]. A terciária é feita depois da ressuscitação e das cirurgias [D31] e, com a revisão das imagens, reduz lesões não identificadas [D30].
- **Equipe.** No centro de trauma, o líder é o cirurgião do trauma [D22]; treinandos podem liderar sob supervisão próxima [D29]. A passagem do pré-hospitalar é estruturada (MIST) [D23] e dura no máximo 45 segundos a 1 minuto [D24].
- **Estrutura melhora o processo.** Checklist pode melhorar a adesão ao ATLS e o fluxo [A8, A11]; o formulário de admissão melhorou 14 de 16 indicadores [A13] e levou o registro da via aérea de 72,9% para 98,4% [A14], em ensaio randomizado por conglomerados em hospitais não terciários de Gana [A45].
- **Diretriz.** A diretriz europeia de 2023 recomenda reduzir ao mínimo o tempo até o controle do sangramento [G1]; compressão e torniquete como adjunto no membro [G2]; estimar a hemorragia pela fisiologia, padrão de lesão, mecanismo e resposta à reposição [G4], com índice de choque e/ou pressão de pulso [G5]; controle imediato quando a fonte é evidente ou no choque em extremis [G6]; FAST no trauma toracoabdominal [G8]; cinta pélvica na suspeita de fratura de pelve [G13]; e aquecimento precoce [G12].

## Disputa

- **Treinamento e mortalidade.** Programas de suporte de vida associam-se a menor mortalidade (OR 0,60), mas em estudos observacionais [A2]; não há evidência de alta qualidade de benefício para o paciente [A4].
- **Torniquete.** A doutrina diz que pode salvar a vida [D7] e a diretriz o recomenda como adjunto [G2]; a revisão de dados pré-hospitalares mostra redução de mortalidade não significativa (RR 0,70) [A23] e mais amputação inicial (RR 2,07) [A24], possivelmente por confusão com a gravidade da lesão.
- **Classes de choque.** Sinais clínicos seguem úteis [D17], mas a comparação clássica com o déficit de base teve viés que superestimou a classe pelos parâmetros tradicionais [A32]; "estabilidade hemodinâmica" foi definida em 70% dos artigos, sem consenso [A33].
- **Ultrassom para pneumotórax.** Sensibilidade de 93,6% em um estudo [A29], baixa sensibilidade com muitos falsos negativos em outro, só em trauma fechado [A30, A47].
- **Checklist.** Menor mortalidade no ISS > 25 em um estudo (aOR 0,51) [A9]; mais pneumonia em outro (aOR 1,69) [A10].
- **Formulário e mortalidade.** No mesmo ensaio, a mortalidade caiu de 17,7% para 12,1% só no subgrupo com fisiologia alterada [A15, A46], desfecho secundário e em contexto diferente de um centro de trauma de referência [A45].
- **Oxigênio.** A maioria dos profissionais (73 %) não apoia oxigênio sempre, sem considerar a SpO2 [A27].
- **TC de corpo inteiro.** A diretriz recomenda imagem precoce com TC de corpo inteiro (grau 1B) [G9]; a revisão mostra pouco ou nenhum efeito em mortalidade [A12].

## Lacunas no conhecimento

- O conhecimento do curso cai em seis meses, embora os princípios fiquem por cerca de seis anos [H5]; isso justifica os pós-testes espaçados.
- Os estudos de checklist são todos antes-e-depois [A7]; o ensaio que testará o ATLS de forma pragmática ainda está em andamento [A5].
- Não há abordagem baseada em evidência para a hipotermia no trauma [A37], que atinge até dois terços dos graves [A36].
- Lesões com diagnóstico tardio persistem: 13,9 % mesmo com TC de corpo inteiro [A42]; lesão potencialmente letal após a terciária em 0,26% [A41].
- Na parada traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20), em dado observacional [A31].

## Controvérsias para a aula

1. **Quando inverter a ordem:** CAB/xABCDE para hemorragia externa e extremis [D2, D3] e ABCDE para os demais.
2. **Torniquete:** salva vidas [D7] ou troca morte por amputação [A23, A24]?
3. **TC de corpo inteiro:** rotina ou seletiva [G9, A12, A39, A42]?
4. **Classificar o choque:** a tabela do ATLS ainda serve [A32, A33]?
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='sintese_evidencia' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Síntese de evidência: consenso, disputa, lacunas e controvérsias

Tempo de leitura: cerca de 10 minutos. Base nas cinco camadas: história do ATLS e de suas edições antigas (camada 1); capítulos do Mattox e o ATLS vigente (camada 2); Protocolo de Imagem no Politrauma da UE-HCFMRP, versão preliminar (camada 3); 75 artigos da revisão dos últimos 10 anos (camada 4); diretriz europeia de sangramento maior no trauma, 6ª edição, 2023 (camada 5).

## Consenso

- **Origem.** O ATLS nasceu de um acidente aéreo em 1976 no interior de Nebraska, quando um cirurgião julgou errado o atendimento dado à própria família [H1]. Foi feito para quem não atende trauma com frequência [H2]; os cursos-piloto foram em 1977 e, em 1980, o curso já era nacional [H3]. Tratar primeiro a maior ameaça à vida foi controverso no início, por fugir da sequência história, exame e diagnóstico diferencial [H4].
- **Objetivo.** A avaliação inicial serve para identificar e tratar rapidamente as lesões que ameaçam a vida [D1]. A alteração fisiológica é o maior determinante do desfecho [D26].
- **Ordem.** A sequência padrão é ABCDE. Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação vem antes da via aérea (CAB, CABDE) [D2, D3]. No pré-hospitalar, a hemorragia externa maciça é tratada primeiro [D4]. Embora ensinada passo a passo, boa parte da avaliação é feita ao mesmo tempo pela equipe [D5]. A edição atual do ATLS passou a usar xABCDE: o x é o controle rápido da hemorragia externa exsanguinante [D44].
- **Hemorragia externa.** Compressão direta primeiro [D6]; no membro, o torniquete pode salvar a vida [D7]; não pinçar às cegas [D8]; cinta pélvica imediata nos pacientes de alto risco [D9].
- **Via aérea.** Quem fala com voz normal não tem obstrução [D10]. Glasgow ≤8 indica via aérea definitiva [D11], com exame neurológico breve antes de sedar e paralisar [D12].
- **Circulação.** O aparelho automático de pressão pode errar no choque [D14]; sem acesso venoso imediato, considerar o intraósseo [D15], que pode salvar vidas no choque [D28].
- **Neurológico e exposição.** Glasgow na chegada e repetido [D16]; agitação também é sinal de choque classe III e IV [D17]. Despir por completo [D18] e, terminado o exame, aquecer: mantas, ar forçado e fluidos aquecidos [D19].
- **Avaliação secundária e terciária.** A secundária é história (AMPLA) e exame completos para achar todas as demais lesões [D20, D21]. A terciária é feita depois da ressuscitação e das cirurgias [D31] e, com a revisão das imagens, reduz lesões não identificadas [D30].
- **Equipe.** No centro de trauma, o líder é o cirurgião do trauma [D22]; treinandos podem liderar sob supervisão próxima [D29]. A passagem do pré-hospitalar é estruturada (MIST) [D23] e dura no máximo 45 segundos a 1 minuto [D24].
- **Estrutura melhora o processo.** Checklist pode melhorar a adesão ao ATLS e o fluxo [A8, A11]; o formulário de admissão melhorou 14 de 16 indicadores [A13] e levou o registro da via aérea de 72,9% para 98,4% [A14], em ensaio randomizado por conglomerados em hospitais não terciários de Gana [A45].
- **Diretriz.** A diretriz europeia de 2023 recomenda reduzir ao mínimo o tempo até o controle do sangramento [G1]; compressão e torniquete como adjunto no membro [G2]; estimar a hemorragia pela fisiologia, padrão de lesão, mecanismo e resposta à reposição [G4], com índice de choque e/ou pressão de pulso [G5]; controle imediato quando a fonte é evidente ou no choque em extremis [G6]; FAST no trauma toracoabdominal [G8]; cinta pélvica na suspeita de fratura de pelve [G13]; e aquecimento precoce [G12].

## Disputa

- **Treinamento e mortalidade.** Programas de suporte de vida associam-se a menor mortalidade (OR 0,60), mas em estudos observacionais [A2]; não há evidência de alta qualidade de benefício para o paciente [A4].
- **Torniquete.** A doutrina diz que pode salvar a vida [D7] e a diretriz o recomenda como adjunto [G2]; a revisão de dados pré-hospitalares mostra redução de mortalidade não significativa (RR 0,70) [A23] e mais amputação inicial (RR 2,07) [A24], possivelmente por confusão com a gravidade da lesão.
- **Classes de choque.** Sinais clínicos seguem úteis [D17], mas a comparação clássica com o déficit de base teve viés que superestimou a classe pelos parâmetros tradicionais [A32]; "estabilidade hemodinâmica" foi definida em 70% dos artigos, sem consenso [A33].
- **Ultrassom para pneumotórax.** Sensibilidade de 93,6% em um estudo [A29], baixa sensibilidade com muitos falsos negativos em outro, só em trauma fechado [A30, A47].
- **Checklist.** Menor mortalidade no ISS > 25 em um estudo (aOR 0,51) [A9]; mais pneumonia em outro (aOR 1,69) [A10].
- **Formulário e mortalidade.** No mesmo ensaio, a mortalidade caiu de 17,7% para 12,1% só no subgrupo com fisiologia alterada [A15, A46], desfecho secundário e em contexto diferente de um centro de trauma de referência [A45].
- **Oxigênio.** A maioria dos profissionais (73 %) não apoia oxigênio sempre, sem considerar a SpO2 [A27].
- **TC de corpo inteiro.** A diretriz recomenda imagem precoce com TC de corpo inteiro (grau 1B) [G9]; a revisão mostra pouco ou nenhum efeito em mortalidade [A12].

## Lacunas no conhecimento

- O conhecimento do curso cai em seis meses, embora os princípios fiquem por cerca de seis anos [H5]; isso justifica os pós-testes espaçados.
- Os estudos de checklist são todos antes-e-depois [A7]; o ensaio que testará o ATLS de forma pragmática ainda está em andamento [A5].
- Não há abordagem baseada em evidência para a hipotermia no trauma [A37], que atinge até dois terços dos graves [A36].
- Lesões com diagnóstico tardio persistem: 13,9 % mesmo com TC de corpo inteiro [A42]; lesão potencialmente letal após a terciária em 0,26% [A41].
- Na parada traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20), em dado observacional [A31].

## Controvérsias para a aula

1. **Quando inverter a ordem:** CAB/xABCDE para hemorragia externa e extremis [D2, D3] e ABCDE para os demais.
2. **Torniquete:** salva vidas [D7] ou troca morte por amputação [A23, A24]?
3. **TC de corpo inteiro:** rotina ou seletiva [G9, A12, A39, A42]?
4. **Classificar o choque:** a tabela do ATLS ainda serve [A32, A33]?
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A11', $af$Em revisão de revisões, a abordagem estruturada por checklist pode melhorar a adesão a diretrizes durante a ressuscitação (certeza baixa da evidência).$af$, '2023_62', $af$The application of a structured approach by checklist may improve adherence to guidelines$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A47', $af$O estudo que mostrou baixa sensibilidade do ultrassom torácico incluiu só trauma torácico fechado.$af$, '2024_47', $af$A prospective observational analysis of patients with blunt chest trauma$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D4', $af$No pré-hospitalar, a hemorragia externa maciça é tratada primeiro.$af$, 'Mattox9_cap10_pre_hospitalar', $af$In the event of external massive hemorrhage, bleeding should be addressed first.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D44', $af$Na edição atual do ATLS, o ABCDE passou a xABCDE: o x indica o controle rápido da hemorragia externa exsanguinante, que salva vidas em alguns pacientes.$af$, 'ACS_ATLS11_anuncio_2025', $af$For certain patients, rapid control of exsanguinating external hemorrhage is lifesaving. To reflect this additional focus, the letter “x” was added to the beginning of the well-known ATLS mnemonic. ABCDE is now xABCDE.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G1', $af$Recomenda-se reduzir ao mínimo o tempo entre a lesão e o controle do sangramento (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the time elapsed between injury and bleeding control be minimised (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G2', $af$Recomenda-se compressão local das feridas abertas e torniquete como adjunto no sangramento de extremidade com risco de vida (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend adjunct tourniquet use to stop life-threatening bleeding from open extremity injuries in the pre-surgical setting (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G4', $af$Recomenda-se estimar a hemorragia pela combinação de fisiologia, padrão anatômico, mecanismo e resposta à reposição inicial (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the physician clinically assess the extent of traumatic haemorrhage using a combination of patient physiology, anatomical injury pattern, mechanism of injury and the patient response to initial resuscitation (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G5', $af$Recomenda-se usar o índice de choque e/ou a pressão de pulso para estimar o grau de choque e a necessidade de transfusão (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the shock index (SI) and/or pulse pressure (PP) be used to assess the degree of hypovolaemic shock and transfusion requirements (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G6', $af$Recomenda-se controle imediato do sangramento quando a fonte é evidente e no choque em extremis com fonte suspeita (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that patients with an obvious bleeding source and those presenting with haemorrhagic shock in extremis and a suspected source of bleeding undergo an immediate bleeding control procedure (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G8', $af$Recomenda-se ultrassom à beira do leito, incluindo o FAST, no trauma toracoabdominal (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend the use of point-of-care ultrasonography (POCUS), including FAST, in patients with thoracoabdominal injuries (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G9', $af$Recomenda-se imagem precoce com TC de corpo inteiro contrastada para identificar as lesões e a fonte de sangramento (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend early imaging using contrast-enhanced whole-body CT (WBCT) for the detection and identification of the type of injury and the potential source of bleeding (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G12', $af$Recomenda-se aplicar cedo medidas para reduzir a perda de calor e aquecer o hipotérmico até a normotermia (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend early application of measures to reduce heat loss and warm the hypothermic patient to achieve and maintain normothermia (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G13', $af$Recomenda-se cinta pélvica como adjunto na suspeita de fratura de pelve com sangramento com risco de vida (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend the adjunct use of a pelvic binder in the pre-hospital setting to limit life-threatening bleeding in the presence of a suspected pelvic fracture (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H1', $af$O ATLS nasceu depois de um acidente aéreo em 1976 no interior de Nebraska, em que o cirurgião ortopedista James Styner se feriu, perdeu a esposa e teve três filhos gravemente feridos, e considerou errado o atendimento que receberam.$af$, 'Carmont2005_historia_ATLS', $af$He was horrified at the treatment his family received at a local hospital in rural Nebraska and decided that the established system for managing the severely injured was wrong.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H2', $af$O objetivo original era treinar médicos que não atendem trauma com frequência, como generalistas do interior, na abordagem inicial do traumatizado grave.$af$, 'Carmont2005_historia_ATLS', $af$train those doctors who do not manage trauma on a regular basis, such as rural general practitioners, in the initial management of the severely injured patient$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H3', $af$Os cursos-piloto foram em 1977, em Nebraska, e em 1980 o curso já era nacional, sob o Colégio Americano de Cirurgiões.$af$, 'Carmont2005_historia_ATLS', $af$The pilot courses were run in Aubern, Nebraska in 1977. These had expanded nationally under the auspices of the American College of Surgeons by 1980.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H4', $af$A filosofia do ATLS é tratar primeiro a maior ameaça à vida; no início isso foi controverso, por contrariar a sequência tradicional de história, exame e diagnóstico diferencial.$af$, 'Carmont2005_historia_ATLS', $af$This practice was initially thought to be controversial as it contradicted the established medical wisdom of the need to take a history and examine the patient leading to a differential diagnosis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H5', $af$O conhecimento cai seis meses depois do curso, mas os princípios importantes ficam por cerca de seis anos.$af$, 'Carmont2005_historia_ATLS', $af$Authors report a deterioration of knowledge by six months after the course however the important principles are retained for some six years.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='sintese_evidencia' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='sintese_evidencia')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'slides', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='slides'),0)+1, 'rascunho', $T1$Slides da aula$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Slides da aula
Versão em texto dos 17 slides da aula, com as notas do apresentador. A apresentação visual é projetada na reunião.


## 1. Por que importa: a votação de abertura, o objetivo da avaliação e o que a evidência diz sobre o treinamento.

### Slide 1. Avaliação inicial do traumatizado
- Programa de Cirurgia de Urgência e Trauma · T001
- O que mudou no xABCDE — e quão sólida é a evidência

*Rascunho para revisão pelos preceptores · conteúdo ainda não aprovado*

> **Nota do apresentador:** Aula de 30 minutos, dentro da reunião de 60 (aula 30, caso da aula 15, pós-teste D0 15). Os códigos nas notas remetem às afirmações da síntese de evidência (A#) e do Mattox (D#), cada uma com trecho literal da fonte. Este material é rascunho: ainda não passou pela revisão dos três cirurgiões.

### Slide 2. O ATLS reduz mortalidade?
- Votação de abertura
- A · Sim, comprovado por ensaios randomizados
- B · Há associação, mas a evidência é observacional
- C · Não há qualquer associação

*T001 · Seção 1 · Guarde a sua resposta: voltamos a ela no fim da aula*

> **Nota do apresentador:** Peça que cada residente vote antes de qualquer explicação. Não comente as respostas agora; retome no slide de treinamento e no fechamento. Resposta sustentada pelas fontes: B [A2, A4].

### Slide 3. 1 · Por que importa
- Achar e tratar
- O objetivo é identificar e tratar rapidamente o que ameaça a vida
- Fisiologia
- A alteração fisiológica é o maior determinante do desfecho
- > 40%
- Mortalidade com PAS abaixo de 90 mmHg e laparotomia de emergência

*T001 · Seção 1 · Fontes: D1, D26, D27 (Mattox, cap. 13)*

> **Nota do apresentador:** O objetivo da avaliação inicial é a identificação e o tratamento rápidos das lesões que ameaçam a vida [D1]. A alteração da fisiologia, e não a carga anatômica, é o maior determinante do desfecho [D26]. Pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência têm mortalidade acima de 40% [D27].

### Slide 4. O que sabemos sobre o treinamento
- 0,60
- Razão de chances de mortalidade com treinamento
- IC 95% 0,48–0,75 · 19 estudos, 92.614 pacientes
- Observacional
- Não há evidência de alta qualidade de benefício em desfechos
- É o que afirmam os próprios autores do novo ensaio
- 4320
- Pacientes, no mínimo, no ensaio ADVANCE TRAUMA
- Em andamento na Índia; adultos com 15 anos ou mais

*T001 · Seção 1 · Fontes: A1, A2, A4, A5*

> **Nota do apresentador:** Retome a votação: a resposta é B. Há associação com menor mortalidade (OR 0,60), mas vinda de estudos observacionais [A1, A2]. Os autores do ADVANCE TRAUMA escrevem que não há evidência de alta qualidade de que o ATLS melhore desfechos [A4]; o ensaio incluirá pelo menos 4320 pacientes [A5]. Contexto histórico: o ATLS nasceu de um acidente em 1976 e foi feito para quem não atende trauma com frequência [H1, H2]. Pergunta ao grupo: isso muda a forma como ensinamos o ATLS?


## 2. O que a evidência diz: as quatro controvérsias, os formulários e checklists e o ultrassom.

### Slide 5. Do ABCDE ao xABCDE
- x
- Hemorragia exsanguinante
- A
- Via aérea e coluna cervical
- B
- Ventilação
- C
- Circulação
- D
- Estado neurológico
- E
- Exposição e temperatura
- O que mudou: o sangramento que mata em minutos passa à frente da via aérea.

*T001 · Controvérsia 1: quando inverter a ordem · Fontes: D2, D3, D4 (Mattox, Trauma 9ª ed.), D44 (ATLS), G2, G6 (diretriz europeia 2023)*

> **Nota do apresentador:** Mattox, capítulo 13: na hemorragia externa ou compressível com risco de vida e no paciente em extremis, a circulação vem antes da via aérea (CAB, CABDE) [D2, D3]. Capítulo 10: no pré-hospitalar, a hemorragia externa maciça é tratada primeiro [D4]. A edição atual do ATLS passou a usar xABCDE: o x é o controle rápido da hemorragia externa exsanguinante [D44]. A diretriz europeia de 2023 recomenda compressão e torniquete como adjunto [G2] e controle imediato quando a fonte é evidente [G6].

### Slide 6. x · Hemorragia externa
- Torniquete pré-hospitalar
- Mortalidade: 4,02% contra 6,43% · RR 0,70 · diferença não significativa
- Amputação inicial: 19,32% contra 6,4% · RR 2,07
- Curativo compressivo
- Pressão aplicada: de 50 a 412 mmHg (média 169,35)
- Percepção de quem aplica: sem correlação com a pressão medida
- Atenção: dados observacionais. Mais amputação pode refletir lesões mais graves, não efeito do torniquete.

*T001 · Controvérsia 2: torniquete · Fontes: A23, A24, A25, A26, D6, D7, G2*

> **Nota do apresentador:** Revisão sistemática de torniquete pré-hospitalar: mortalidade 4,02% vs 6,43%, RR 0,70 (IC 95% 0,46–1,07), não significativo [A23]; amputação inicial 19,32% vs 6,4%, RR 2,07 (IC 95% 1,21–3,52) [A24]. Discutir confusão por gravidade e tempo de torniquete. A diretriz europeia de 2023 recomenda torniquete como adjunto no sangramento de extremidade com risco de vida (grau 1B) [G2]. Curativos compressivos: pressão média 169,35 ± 84,33 mmHg, variação 50–412 [A25]; sem correlação entre autoavaliação e pressão medida, p = 0,541 [A26].

### Slide 7. Tomografia de corpo inteiro
- Pouco ou nenhum efeito
- Na mortalidade e no tempo na sala de emergência, quando feita de rotina
- 17,4% e 27,6%
- Mortalidade em 24 h no choque, com e sem a TC: sem diferença (p = 0,21)
- 3,02%
- Dos submetidos tinham avaliação primária sem alterações

*T001 · Controvérsia 3: TC de corpo inteiro · Fontes: G9, A12, A39, A40, P2*

> **Nota do apresentador:** Revisão de revisões: TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito em mortalidade e tempo na sala de emergência [A12]. Em pacientes em choque, mortalidade precoce de 17,4% com TC e 27,6% sem, p = 0,21 — sem diferença [A39]. Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações [A40]. A diretriz europeia de 2023 recomenda TC de corpo inteiro precoce (grau 1B) [G9]; a revisão não mostra ganho de mortalidade com a rotina [A12]. No HCFMRP, a indicação segue o protocolo de imagem da UE: pelo menos um dos três grupos de critérios [P2].

### Slide 8. C · O paciente está “estável”?
- Ferramenta ou conceito
- O que a evidência mostra
- Classe de choque do ATLS
- A comparação clássica com o déficit de base teve viés metodológico
- Estabilidade hemodinâmica
- Definida em 70% dos artigos, sem consenso nos pontos de corte
- RUSH
- Sensibilidade de 94,2% em politraumatizados instáveis
- FAST-PLUS
- Alargamento crítico da sínfise púbica em 7,5% dos pacientes
- Adrenalina na parada traumática
- Associada a menor sobrevida em 7 dias (OR 0,20)

*T001 · Controvérsia 4: classificar o choque · Fontes: A31, A32, A33, A34, A35, D17, G5*

> **Nota do apresentador:** Não classificar o choque por um parâmetro isolado; a diretriz europeia recomenda índice de choque e/ou pressão de pulso [G5]: a comparação clássica entre déficit de base e parâmetros do ATLS superestimou a classe de choque dos parâmetros tradicionais [A32]. Estabilidade hemodinâmica: 67 artigos elegíveis, definida em 70% deles, sem consenso [A33]. RUSH 94,2% de sensibilidade [A34]. FAST-PLUS: 5 de 67 pacientes, 7,5% [A35]. Adrenalina na parada extra-hospitalar traumática: OR 0,20 (IC 95% 0,08–0,48) para sobrevida em 7 dias — observacional [A31].

### Slide 9. Checklist na ressuscitação
- A favor
- Pode melhorar a adesão ao ATLS e o fluxo de trabalho
- ISS acima de 25: menor mortalidade em um estudo (aOR 0,51)
- Cautela
- Só estudos do tipo antes-e-depois
- Mais pneumonia no grupo checklist em um estudo (aOR 1,69)
- Melhora o processo. O efeito sobre a mortalidade continua incerto.

*T001 · Seção 2 · Fontes: A7, A8, A9, A10, A11*

> **Nota do apresentador:** Revisão sistemática: 625 artigos identificados, 3 incluídos, todos antes-e-depois [A7]. Checklist pode melhorar adesão e fluxo [A8, A11]. Um estudo: menor mortalidade no grupo ISS > 25, aOR 0,51 (IC 95% 0,30–0,89) [A9]. Outro: maior incidência de pneumonia, aOR 1,69 (IC 95% 1,03–2,80) [A10].

### Slide 10. Formulário de admissão do trauma
- 14 de 16
- Indicadores da avaliação primária melhoraram
- 72,9% → 98,4%
- Avaliação de vias aéreas registrada
- 17,7% → 12,1%
- Mortalidade em 302 pacientes com fisiologia alterada
- Para funcionar: um responsável na instituição, adaptação ao contexto local e integração à rotina e à documentação.

*T001 · Seção 2 · Ensaio randomizado em hospitais não terciários de Gana · Fontes: A13 a A16, A45, A46*

> **Nota do apresentador:** Ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana [A45]: melhora em 14 de 16 indicadores [A13]; via aérea de 72,9% para 98,4% [A14]; mortalidade de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada [A15], OR ajustado 0,10 [A46]. Cautela: a mortalidade foi desfecho secundário, num subgrupo, em contexto diferente de um centro de trauma de referência. Fatores de sucesso do WHO Trauma Care Checklist: campeão institucional, adaptação e integração [A16].

### Slide 11. A e B · eFAST negativo exclui pneumotórax?
- 93,6%
- Sensibilidade em um estudo (especificidade 99,8%)
- Baixa sensibilidade
- Em outro estudo prospectivo, com muitos falsos negativos
- Oxigênio: 73 % dos profissionais não apoiam oferecer sempre, sem considerar a SpO2
- Via aérea cirúrgica de emergência: 0,24% dos pacientes em coorte japonesa

*T001 · Seção 2 · Segunda votação · Fontes: A27, A28, A29, A30*

> **Nota do apresentador:** Segunda votação antes de mostrar os números: "eFAST negativo exclui pneumotórax?". E-FAST: sensibilidade 93,6%, especificidade 99,8% [A29]. Outro estudo prospectivo: baixa sensibilidade com alta taxa de falsos negativos [A30]. Mensagem: exame negativo não encerra a investigação se a suspeita clínica persiste. Oxigênio: pesquisa de opinião, 73 % (IC 95% 70 a 76 %) não apoiam uso indiscriminado [A27] — é opinião, não desfecho. Via aérea cirúrgica: 467 pacientes, 0,24% [A28].


## 3. Como se faz: a sequência na sala de trauma e o papel da equipe.

### Slide 12. 3 · Como se faz
- Momento
- O que fazer
- Antes da chegada
- Líder definido (cirurgião do trauma) e funções distribuídas
- Passagem
- MIST, com a equipe ouvindo, em até 1 minuto
- Hemorragia
- Compressão direta; torniquete no membro; cinta pélvica no alto risco
- Via aérea
- Voz normal: pérvia. Glasgow ≤8: via aérea definitiva, com exame neurológico antes
- Circulação
- Pressão manual se houver dúvida; intraósseo se a veia falhar
- D e E
- Glasgow repetido; despir por completo e aquecer
- Depois
- Secundária com AMPLA; terciária após a ressuscitação e as cirurgias

*T001 · Seção 3 · Fontes: D6, D7, D9 a D12, D14 a D16, D18, D19, D21 a D24, D31*

> **Nota do apresentador:** Líder e funções antes da chegada [D22]; MIST [D23] em até 45 segundos a 1 minuto [D24]. Compressão direta [D6], torniquete [D7], cinta pélvica [D9]. Voz normal [D10]; Glasgow ≤8 [D11]; exame neurológico antes da sedação [D12]. Pressão manual [D14]; intraósseo [D15]. Glasgow repetido [D16]; despir [D18]; aquecer [D19]. AMPLA [D21]; terciária [D31].

### Slide 13. Equipe e liderança
- −259 s
- No tempo de ressuscitação com cirurgião de trauma presente
- 0,48
- Razão de chances de lesão não identificada com líder cirurgião; sobrevida igual
- Simulação in situ
- Treino mensal com debriefing em vídeo reduz o tempo de ressuscitação

*T001 · Seção 3 · Fontes: A17, A18, A19, A20, A21, A44*

> **Nota do apresentador:** Cirurgião de trauma presente: tempo total de ressuscitação 259 segundos menor, p = 0,03 [A19]. Meta-análise: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82) [A20], mas menos lesões não identificadas com cirurgião (OR 0,48; IC 95% 0,25-0,92) [A21]. Simulação de equipe reduz tempo até exames, tomografia e hemostasia [A17]; treino mensal in situ com debriefing em vídeo reduz o tempo de ressuscitação [A18]. Treino por checklist ou por algoritmo: ganhos de curto prazo semelhantes [A44].


## 4. O que dá errado: as armadilhas, a hipotermia e as lesões descobertas depois.

### Slide 14. 4 · O que dá errado
- Confiar no aparelho automático de pressão no choque
- Ler agitação como embriaguez , quando pode ser choque
- Encerrar a investigação com eFAST negativo
- Despir e esquecer de aquecer
- Pinçar às cegas uma ferida profunda
- Achar que a TC dispensa a reavaliação

*T001 · Seção 4 · Fontes: D8, D14, D17, D19, A30, A36, A42*

> **Nota do apresentador:** O aparelho automático pode errar no choque [D14]. Agitação e agressividade são sinais clássicos de choque classe III e IV [D17]. eFAST negativo não exclui pneumotórax [A30]. Hipotermia em até dois terços dos graves [A36]; aquecer depois de despir [D19]. Pinçamento às cegas deve ser evitado [D8]. Lesões tardias em 13,9 % mesmo com TC [A42]. Os dois próximos slides aprofundam hipotermia e seguimento.

### Slide 15. E · Hipotermia
- até 2/3
- dos pacientes com trauma grave têm hipotermia — e ela costuma ser desconsiderada na ressuscitação inicial.
- Não há abordagem baseada em evidência para o manejo, ao contrário da acidose e do sangramento.
- Fluido pré-aquecido a 39 °C só chega acima de 37 °C com alto fluxo e ambiente quente.

*T001 · Seção 4 · Fontes: A36, A37, A38*

> **Nota do apresentador:** Hipotermia em até dois terços dos pacientes com lesão grave, frequentemente desconsiderada [A36]. Não há abordagem baseada em evidência [A37]. Fluido pré-aquecido a 39 °C só permanece acima de 37 °C ao chegar ao paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm [A38]. Pergunta ao grupo: o que fazemos hoje na nossa sala? Medimos a temperatura na admissão?

### Slide 16. Não acabou na sala de trauma
- 13,9 %
- Tiveram lesão com diagnóstico tardio, mesmo com TC de corpo inteiro
- 0,26%
- Lesão potencialmente letal surgiu depois da avaliação terciária
- 75% e 99%
- Sensibilidade e especificidade do teste SILENT para membro inferior
- Reavaliar sempre: a avaliação terciária é parte do atendimento.

*T001 · Seção 4 · Fontes: A41, A42, A43, D30, D31*

> **Nota do apresentador:** Lesões com diagnóstico tardio em 13,9 % dos pacientes, mesmo com TC de corpo inteiro na avaliação primária [A42]. Lesão potencialmente letal depois da avaliação terciária em 0,26% dos pacientes graves [A41]. SILENT: sensibilidade 75% (IC 95% 64 a 84%), especificidade 99% (IC 95% 97 a 100%) — bom para confirmar, insuficiente para excluir [A43]. A avaliação terciária é feita depois da ressuscitação inicial e das intervenções [D31] e, com a revisão das imagens, reduz lesões não identificadas [D30].


## 5. O que levar para o plantão: as cinco mensagens.

### Slide 17. 5 · O que levar para o plantão
- Sangramento externo grave vem primeiro.
- Tratar cada problema ao encontrá-lo e reavaliar.
- Um líder e uma passagem curta e estruturada.
- Despir, aquecer e repetir o Glasgow.
- Avaliação terciária sempre: a sala de trauma não encerra o diagnóstico.

*T001 · Seção 5 · E a votação inicial? Há associação com menor mortalidade, mas a evidência é observacional.*

> **Nota do apresentador:** Retome a votação do início e peça que alguém explique por que a resposta é B [A2, A4]. Feche com as cinco mensagens. Em seguida: discussão de 10 minutos e o caso clínico em pequenos grupos.
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='slides' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Slides da aula
Versão em texto dos 17 slides da aula, com as notas do apresentador. A apresentação visual é projetada na reunião.


## 1. Por que importa: a votação de abertura, o objetivo da avaliação e o que a evidência diz sobre o treinamento.

### Slide 1. Avaliação inicial do traumatizado
- Programa de Cirurgia de Urgência e Trauma · T001
- O que mudou no xABCDE — e quão sólida é a evidência

*Rascunho para revisão pelos preceptores · conteúdo ainda não aprovado*

> **Nota do apresentador:** Aula de 30 minutos, dentro da reunião de 60 (aula 30, caso da aula 15, pós-teste D0 15). Os códigos nas notas remetem às afirmações da síntese de evidência (A#) e do Mattox (D#), cada uma com trecho literal da fonte. Este material é rascunho: ainda não passou pela revisão dos três cirurgiões.

### Slide 2. O ATLS reduz mortalidade?
- Votação de abertura
- A · Sim, comprovado por ensaios randomizados
- B · Há associação, mas a evidência é observacional
- C · Não há qualquer associação

*T001 · Seção 1 · Guarde a sua resposta: voltamos a ela no fim da aula*

> **Nota do apresentador:** Peça que cada residente vote antes de qualquer explicação. Não comente as respostas agora; retome no slide de treinamento e no fechamento. Resposta sustentada pelas fontes: B [A2, A4].

### Slide 3. 1 · Por que importa
- Achar e tratar
- O objetivo é identificar e tratar rapidamente o que ameaça a vida
- Fisiologia
- A alteração fisiológica é o maior determinante do desfecho
- > 40%
- Mortalidade com PAS abaixo de 90 mmHg e laparotomia de emergência

*T001 · Seção 1 · Fontes: D1, D26, D27 (Mattox, cap. 13)*

> **Nota do apresentador:** O objetivo da avaliação inicial é a identificação e o tratamento rápidos das lesões que ameaçam a vida [D1]. A alteração da fisiologia, e não a carga anatômica, é o maior determinante do desfecho [D26]. Pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência têm mortalidade acima de 40% [D27].

### Slide 4. O que sabemos sobre o treinamento
- 0,60
- Razão de chances de mortalidade com treinamento
- IC 95% 0,48–0,75 · 19 estudos, 92.614 pacientes
- Observacional
- Não há evidência de alta qualidade de benefício em desfechos
- É o que afirmam os próprios autores do novo ensaio
- 4320
- Pacientes, no mínimo, no ensaio ADVANCE TRAUMA
- Em andamento na Índia; adultos com 15 anos ou mais

*T001 · Seção 1 · Fontes: A1, A2, A4, A5*

> **Nota do apresentador:** Retome a votação: a resposta é B. Há associação com menor mortalidade (OR 0,60), mas vinda de estudos observacionais [A1, A2]. Os autores do ADVANCE TRAUMA escrevem que não há evidência de alta qualidade de que o ATLS melhore desfechos [A4]; o ensaio incluirá pelo menos 4320 pacientes [A5]. Contexto histórico: o ATLS nasceu de um acidente em 1976 e foi feito para quem não atende trauma com frequência [H1, H2]. Pergunta ao grupo: isso muda a forma como ensinamos o ATLS?


## 2. O que a evidência diz: as quatro controvérsias, os formulários e checklists e o ultrassom.

### Slide 5. Do ABCDE ao xABCDE
- x
- Hemorragia exsanguinante
- A
- Via aérea e coluna cervical
- B
- Ventilação
- C
- Circulação
- D
- Estado neurológico
- E
- Exposição e temperatura
- O que mudou: o sangramento que mata em minutos passa à frente da via aérea.

*T001 · Controvérsia 1: quando inverter a ordem · Fontes: D2, D3, D4 (Mattox, Trauma 9ª ed.), D44 (ATLS), G2, G6 (diretriz europeia 2023)*

> **Nota do apresentador:** Mattox, capítulo 13: na hemorragia externa ou compressível com risco de vida e no paciente em extremis, a circulação vem antes da via aérea (CAB, CABDE) [D2, D3]. Capítulo 10: no pré-hospitalar, a hemorragia externa maciça é tratada primeiro [D4]. A edição atual do ATLS passou a usar xABCDE: o x é o controle rápido da hemorragia externa exsanguinante [D44]. A diretriz europeia de 2023 recomenda compressão e torniquete como adjunto [G2] e controle imediato quando a fonte é evidente [G6].

### Slide 6. x · Hemorragia externa
- Torniquete pré-hospitalar
- Mortalidade: 4,02% contra 6,43% · RR 0,70 · diferença não significativa
- Amputação inicial: 19,32% contra 6,4% · RR 2,07
- Curativo compressivo
- Pressão aplicada: de 50 a 412 mmHg (média 169,35)
- Percepção de quem aplica: sem correlação com a pressão medida
- Atenção: dados observacionais. Mais amputação pode refletir lesões mais graves, não efeito do torniquete.

*T001 · Controvérsia 2: torniquete · Fontes: A23, A24, A25, A26, D6, D7, G2*

> **Nota do apresentador:** Revisão sistemática de torniquete pré-hospitalar: mortalidade 4,02% vs 6,43%, RR 0,70 (IC 95% 0,46–1,07), não significativo [A23]; amputação inicial 19,32% vs 6,4%, RR 2,07 (IC 95% 1,21–3,52) [A24]. Discutir confusão por gravidade e tempo de torniquete. A diretriz europeia de 2023 recomenda torniquete como adjunto no sangramento de extremidade com risco de vida (grau 1B) [G2]. Curativos compressivos: pressão média 169,35 ± 84,33 mmHg, variação 50–412 [A25]; sem correlação entre autoavaliação e pressão medida, p = 0,541 [A26].

### Slide 7. Tomografia de corpo inteiro
- Pouco ou nenhum efeito
- Na mortalidade e no tempo na sala de emergência, quando feita de rotina
- 17,4% e 27,6%
- Mortalidade em 24 h no choque, com e sem a TC: sem diferença (p = 0,21)
- 3,02%
- Dos submetidos tinham avaliação primária sem alterações

*T001 · Controvérsia 3: TC de corpo inteiro · Fontes: G9, A12, A39, A40, P2*

> **Nota do apresentador:** Revisão de revisões: TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito em mortalidade e tempo na sala de emergência [A12]. Em pacientes em choque, mortalidade precoce de 17,4% com TC e 27,6% sem, p = 0,21 — sem diferença [A39]. Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações [A40]. A diretriz europeia de 2023 recomenda TC de corpo inteiro precoce (grau 1B) [G9]; a revisão não mostra ganho de mortalidade com a rotina [A12]. No HCFMRP, a indicação segue o protocolo de imagem da UE: pelo menos um dos três grupos de critérios [P2].

### Slide 8. C · O paciente está “estável”?
- Ferramenta ou conceito
- O que a evidência mostra
- Classe de choque do ATLS
- A comparação clássica com o déficit de base teve viés metodológico
- Estabilidade hemodinâmica
- Definida em 70% dos artigos, sem consenso nos pontos de corte
- RUSH
- Sensibilidade de 94,2% em politraumatizados instáveis
- FAST-PLUS
- Alargamento crítico da sínfise púbica em 7,5% dos pacientes
- Adrenalina na parada traumática
- Associada a menor sobrevida em 7 dias (OR 0,20)

*T001 · Controvérsia 4: classificar o choque · Fontes: A31, A32, A33, A34, A35, D17, G5*

> **Nota do apresentador:** Não classificar o choque por um parâmetro isolado; a diretriz europeia recomenda índice de choque e/ou pressão de pulso [G5]: a comparação clássica entre déficit de base e parâmetros do ATLS superestimou a classe de choque dos parâmetros tradicionais [A32]. Estabilidade hemodinâmica: 67 artigos elegíveis, definida em 70% deles, sem consenso [A33]. RUSH 94,2% de sensibilidade [A34]. FAST-PLUS: 5 de 67 pacientes, 7,5% [A35]. Adrenalina na parada extra-hospitalar traumática: OR 0,20 (IC 95% 0,08–0,48) para sobrevida em 7 dias — observacional [A31].

### Slide 9. Checklist na ressuscitação
- A favor
- Pode melhorar a adesão ao ATLS e o fluxo de trabalho
- ISS acima de 25: menor mortalidade em um estudo (aOR 0,51)
- Cautela
- Só estudos do tipo antes-e-depois
- Mais pneumonia no grupo checklist em um estudo (aOR 1,69)
- Melhora o processo. O efeito sobre a mortalidade continua incerto.

*T001 · Seção 2 · Fontes: A7, A8, A9, A10, A11*

> **Nota do apresentador:** Revisão sistemática: 625 artigos identificados, 3 incluídos, todos antes-e-depois [A7]. Checklist pode melhorar adesão e fluxo [A8, A11]. Um estudo: menor mortalidade no grupo ISS > 25, aOR 0,51 (IC 95% 0,30–0,89) [A9]. Outro: maior incidência de pneumonia, aOR 1,69 (IC 95% 1,03–2,80) [A10].

### Slide 10. Formulário de admissão do trauma
- 14 de 16
- Indicadores da avaliação primária melhoraram
- 72,9% → 98,4%
- Avaliação de vias aéreas registrada
- 17,7% → 12,1%
- Mortalidade em 302 pacientes com fisiologia alterada
- Para funcionar: um responsável na instituição, adaptação ao contexto local e integração à rotina e à documentação.

*T001 · Seção 2 · Ensaio randomizado em hospitais não terciários de Gana · Fontes: A13 a A16, A45, A46*

> **Nota do apresentador:** Ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana [A45]: melhora em 14 de 16 indicadores [A13]; via aérea de 72,9% para 98,4% [A14]; mortalidade de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada [A15], OR ajustado 0,10 [A46]. Cautela: a mortalidade foi desfecho secundário, num subgrupo, em contexto diferente de um centro de trauma de referência. Fatores de sucesso do WHO Trauma Care Checklist: campeão institucional, adaptação e integração [A16].

### Slide 11. A e B · eFAST negativo exclui pneumotórax?
- 93,6%
- Sensibilidade em um estudo (especificidade 99,8%)
- Baixa sensibilidade
- Em outro estudo prospectivo, com muitos falsos negativos
- Oxigênio: 73 % dos profissionais não apoiam oferecer sempre, sem considerar a SpO2
- Via aérea cirúrgica de emergência: 0,24% dos pacientes em coorte japonesa

*T001 · Seção 2 · Segunda votação · Fontes: A27, A28, A29, A30*

> **Nota do apresentador:** Segunda votação antes de mostrar os números: "eFAST negativo exclui pneumotórax?". E-FAST: sensibilidade 93,6%, especificidade 99,8% [A29]. Outro estudo prospectivo: baixa sensibilidade com alta taxa de falsos negativos [A30]. Mensagem: exame negativo não encerra a investigação se a suspeita clínica persiste. Oxigênio: pesquisa de opinião, 73 % (IC 95% 70 a 76 %) não apoiam uso indiscriminado [A27] — é opinião, não desfecho. Via aérea cirúrgica: 467 pacientes, 0,24% [A28].


## 3. Como se faz: a sequência na sala de trauma e o papel da equipe.

### Slide 12. 3 · Como se faz
- Momento
- O que fazer
- Antes da chegada
- Líder definido (cirurgião do trauma) e funções distribuídas
- Passagem
- MIST, com a equipe ouvindo, em até 1 minuto
- Hemorragia
- Compressão direta; torniquete no membro; cinta pélvica no alto risco
- Via aérea
- Voz normal: pérvia. Glasgow ≤8: via aérea definitiva, com exame neurológico antes
- Circulação
- Pressão manual se houver dúvida; intraósseo se a veia falhar
- D e E
- Glasgow repetido; despir por completo e aquecer
- Depois
- Secundária com AMPLA; terciária após a ressuscitação e as cirurgias

*T001 · Seção 3 · Fontes: D6, D7, D9 a D12, D14 a D16, D18, D19, D21 a D24, D31*

> **Nota do apresentador:** Líder e funções antes da chegada [D22]; MIST [D23] em até 45 segundos a 1 minuto [D24]. Compressão direta [D6], torniquete [D7], cinta pélvica [D9]. Voz normal [D10]; Glasgow ≤8 [D11]; exame neurológico antes da sedação [D12]. Pressão manual [D14]; intraósseo [D15]. Glasgow repetido [D16]; despir [D18]; aquecer [D19]. AMPLA [D21]; terciária [D31].

### Slide 13. Equipe e liderança
- −259 s
- No tempo de ressuscitação com cirurgião de trauma presente
- 0,48
- Razão de chances de lesão não identificada com líder cirurgião; sobrevida igual
- Simulação in situ
- Treino mensal com debriefing em vídeo reduz o tempo de ressuscitação

*T001 · Seção 3 · Fontes: A17, A18, A19, A20, A21, A44*

> **Nota do apresentador:** Cirurgião de trauma presente: tempo total de ressuscitação 259 segundos menor, p = 0,03 [A19]. Meta-análise: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82) [A20], mas menos lesões não identificadas com cirurgião (OR 0,48; IC 95% 0,25-0,92) [A21]. Simulação de equipe reduz tempo até exames, tomografia e hemostasia [A17]; treino mensal in situ com debriefing em vídeo reduz o tempo de ressuscitação [A18]. Treino por checklist ou por algoritmo: ganhos de curto prazo semelhantes [A44].


## 4. O que dá errado: as armadilhas, a hipotermia e as lesões descobertas depois.

### Slide 14. 4 · O que dá errado
- Confiar no aparelho automático de pressão no choque
- Ler agitação como embriaguez , quando pode ser choque
- Encerrar a investigação com eFAST negativo
- Despir e esquecer de aquecer
- Pinçar às cegas uma ferida profunda
- Achar que a TC dispensa a reavaliação

*T001 · Seção 4 · Fontes: D8, D14, D17, D19, A30, A36, A42*

> **Nota do apresentador:** O aparelho automático pode errar no choque [D14]. Agitação e agressividade são sinais clássicos de choque classe III e IV [D17]. eFAST negativo não exclui pneumotórax [A30]. Hipotermia em até dois terços dos graves [A36]; aquecer depois de despir [D19]. Pinçamento às cegas deve ser evitado [D8]. Lesões tardias em 13,9 % mesmo com TC [A42]. Os dois próximos slides aprofundam hipotermia e seguimento.

### Slide 15. E · Hipotermia
- até 2/3
- dos pacientes com trauma grave têm hipotermia — e ela costuma ser desconsiderada na ressuscitação inicial.
- Não há abordagem baseada em evidência para o manejo, ao contrário da acidose e do sangramento.
- Fluido pré-aquecido a 39 °C só chega acima de 37 °C com alto fluxo e ambiente quente.

*T001 · Seção 4 · Fontes: A36, A37, A38*

> **Nota do apresentador:** Hipotermia em até dois terços dos pacientes com lesão grave, frequentemente desconsiderada [A36]. Não há abordagem baseada em evidência [A37]. Fluido pré-aquecido a 39 °C só permanece acima de 37 °C ao chegar ao paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm [A38]. Pergunta ao grupo: o que fazemos hoje na nossa sala? Medimos a temperatura na admissão?

### Slide 16. Não acabou na sala de trauma
- 13,9 %
- Tiveram lesão com diagnóstico tardio, mesmo com TC de corpo inteiro
- 0,26%
- Lesão potencialmente letal surgiu depois da avaliação terciária
- 75% e 99%
- Sensibilidade e especificidade do teste SILENT para membro inferior
- Reavaliar sempre: a avaliação terciária é parte do atendimento.

*T001 · Seção 4 · Fontes: A41, A42, A43, D30, D31*

> **Nota do apresentador:** Lesões com diagnóstico tardio em 13,9 % dos pacientes, mesmo com TC de corpo inteiro na avaliação primária [A42]. Lesão potencialmente letal depois da avaliação terciária em 0,26% dos pacientes graves [A41]. SILENT: sensibilidade 75% (IC 95% 64 a 84%), especificidade 99% (IC 95% 97 a 100%) — bom para confirmar, insuficiente para excluir [A43]. A avaliação terciária é feita depois da ressuscitação inicial e das intervenções [D31] e, com a revisão das imagens, reduz lesões não identificadas [D30].


## 5. O que levar para o plantão: as cinco mensagens.

### Slide 17. 5 · O que levar para o plantão
- Sangramento externo grave vem primeiro.
- Tratar cada problema ao encontrá-lo e reavaliar.
- Um líder e uma passagem curta e estruturada.
- Despir, aquecer e repetir o Glasgow.
- Avaliação terciária sempre: a sala de trauma não encerra o diagnóstico.

*T001 · Seção 5 · E a votação inicial? Há associação com menor mortalidade, mas a evidência é observacional.*

> **Nota do apresentador:** Retome a votação do início e peça que alguém explique por que a resposta é B [A2, A4]. Feche com as cinco mensagens. Em seguida: discussão de 10 minutos e o caso clínico em pequenos grupos.
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A1', $af$Revisão sistemática com 19 estudos e 92.614 pacientes sobre programas de suporte de vida no trauma (ATLS o mais comum).$af$, '2026_24', $af$we identified and included 19 eligible studies. There were 92,614 patients cumulatively across the 19 studies$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A11', $af$Em revisão de revisões, a abordagem estruturada por checklist pode melhorar a adesão a diretrizes durante a ressuscitação (certeza baixa da evidência).$af$, '2023_62', $af$The application of a structured approach by checklist may improve adherence to guidelines$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A25', $af$Nos conjuntos de dados válidos, a pressão máxima média dos curativos compressivos foi 169,35 ± 84,33 mmHg (variação de 50–412 mmHg).$af$, '2026_71', $af$Mean maximum pressure was 169.35 ± 84.33 mmHg (range 50–412 mmHg)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A26', $af$Não houve correlação entre a autoavaliação subjetiva e a pressão objetiva medida (p = 0,541).$af$, '2026_71', $af$No correlation was found between subjective self-assessment and objective pressure measurements (p = 0.541)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D4', $af$No pré-hospitalar, a hemorragia externa maciça é tratada primeiro.$af$, 'Mattox9_cap10_pre_hospitalar', $af$In the event of external massive hemorrhage, bleeding should be addressed first.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D44', $af$Na edição atual do ATLS, o ABCDE passou a xABCDE: o x indica o controle rápido da hemorragia externa exsanguinante, que salva vidas em alguns pacientes.$af$, 'ACS_ATLS11_anuncio_2025', $af$For certain patients, rapid control of exsanguinating external hemorrhage is lifesaving. To reflect this additional focus, the letter “x” was added to the beginning of the well-known ATLS mnemonic. ABCDE is now xABCDE.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G2', $af$Recomenda-se compressão local das feridas abertas e torniquete como adjunto no sangramento de extremidade com risco de vida (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend adjunct tourniquet use to stop life-threatening bleeding from open extremity injuries in the pre-surgical setting (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G5', $af$Recomenda-se usar o índice de choque e/ou a pressão de pulso para estimar o grau de choque e a necessidade de transfusão (grau 1C).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that the shock index (SI) and/or pulse pressure (PP) be used to assess the degree of hypovolaemic shock and transfusion requirements (Grade 1C).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G6', $af$Recomenda-se controle imediato do sangramento quando a fonte é evidente e no choque em extremis com fonte suspeita (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend that patients with an obvious bleeding source and those presenting with haemorrhagic shock in extremis and a suspected source of bleeding undergo an immediate bleeding control procedure (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'G9', $af$Recomenda-se imagem precoce com TC de corpo inteiro contrastada para identificar as lesões e a fonte de sangramento (grau 1B).$af$, 'Diretriz_europeia_sangramento_2023', $af$We recommend early imaging using contrast-enhanced whole-body CT (WBCT) for the detection and identification of the type of injury and the potential source of bleeding (Grade 1B).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H1', $af$O ATLS nasceu depois de um acidente aéreo em 1976 no interior de Nebraska, em que o cirurgião ortopedista James Styner se feriu, perdeu a esposa e teve três filhos gravemente feridos, e considerou errado o atendimento que receberam.$af$, 'Carmont2005_historia_ATLS', $af$He was horrified at the treatment his family received at a local hospital in rural Nebraska and decided that the established system for managing the severely injured was wrong.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'H2', $af$O objetivo original era treinar médicos que não atendem trauma com frequência, como generalistas do interior, na abordagem inicial do traumatizado grave.$af$, 'Carmont2005_historia_ATLS', $af$train those doctors who do not manage trauma on a regular basis, such as rural general practitioners, in the initial management of the severely injured patient$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'P2', $af$A pan-TC é indicada quando há pelo menos um de três grupos de critérios: mecanismo, critérios clínicos/fisiológicos ou TCE moderado a grave.$af$, 'HCFMRP_protocolo_imagem_politrauma_v2026-08', $af$Indicar Pan-TC quando houver pelo menos UM dos três grupos abaixo$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='slides' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='slides')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'teste_1', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_1'),0)+1, 'rascunho', $T1$Pré-teste inicial$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pré-teste inicial

Tempo estimado: cerca de 10 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 1.

**Caso 1.** Mulher de 45 anos, motorista, colisão frontal. Chega acordada e responde às perguntas com voz normal. Há fratura exposta da perna direita com sangramento ativo em jato, que encharca o lençol. FC 124, pele fria e pálida. A equipe ainda não fez nenhuma intervenção.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 1, qual é a primeira medida?
- A) Pedir radiografia de tórax
- B) Comprimir diretamente o ponto que sangra
- C) Levar para a tomografia
- D) Colher a história AMPLA
- E) Intubar a paciente

**3.** A paciente do caso 1 responde às perguntas com voz normal. O que isso indica?
- A) Que a coluna cervical está lesada
- B) Que ela precisa de via aérea definitiva
- C) Que o Glasgow é menor que 8
- D) Que não há choque
- E) Que a via aérea está pérvia

**4.** Por que, no caso 1, a circulação é tratada antes da via aérea?
- A) Porque há hemorragia externa com risco de vida
- B) Porque a fratura é exposta
- C) Porque ela tem mais de 40 anos
- D) Porque a FC é o primeiro sinal vital medido
- E) Porque a via aérea nunca é prioridade no trauma

**5.** Controlado o sangramento e terminado o exame com a paciente despida, o que deve ser feito?
- A) Dar banho com água fria para limpar
- B) Aquecer só se a temperatura cair abaixo de 32 °C
- C) Mantê-la descoberta para reexaminar
- D) Aquecê-la com mantas, ar forçado e fluidos aquecidos
- E) Esperar a TC para decidir


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 1, a compressão direta não controla o sangramento da perna. Qual é a próxima medida?
- A) Pinçar às cegas dentro da ferida
- B) Elevar o membro e observar por 10 minutos
- C) Aplicar torniquete proximal à lesão
- D) Intubar antes de qualquer outra coisa
- E) Pedir angiotomografia antes de agir

**3.** No caso 1, o aparelho automático marca PA 120/80. Como interpretar?
- A) A paciente não está em choque
- B) A pressão normal libera a paciente para a TC sem reavaliação
- C) Deve-se suspender a reposição
- D) A FC alta é só dor
- E) O aparelho automático pode errar no choque; confirmar com medida manual e com a clínica

**4.** No caso 1, a equipe não consegue acesso venoso em duas tentativas. Qual a melhor alternativa?
- A) Continuar tentando veia periférica por 15 minutos
- B) Acesso intraósseo
- C) Puncionar a artéria femoral para infundir
- D) Adiar a reposição até chegar à TC
- E) Dar líquidos por via oral

**5.** Ao despir a paciente do caso 1, o que justifica remover toda a roupa?
- A) Permitir o exame completo em 360 graus, para não deixar lesões passarem
- B) Facilitar o uso da cinta pélvica em todos os casos
- C) Só é necessário no trauma penetrante
- D) Só facilitar a limpeza
- E) Evitar a hipotermia


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Em todo paciente com fratura de membro
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 1, um torniquete é aplicado e controla o sangramento. O que a evidência mostra sobre o torniquete pré-hospitalar?
- A) Não altera a taxa de amputação
- B) Redução de mortalidade não significativa e mais amputação inicial
- C) Reduz a mortalidade de forma significativa
- D) Só deve ser usado no membro superior
- E) Aumenta a mortalidade

**3.** No caso 1, FC 124 e pele fria, mas a paciente está lúcida e responde bem. O que considerar?
- A) A tabela de classes de choque é suficiente para decidir
- B) Lucidez exclui choque grave
- C) Não decidir por um parâmetro isolado; a classificação clássica tem limitações
- D) Sedar para medir melhor a FC
- E) Aguardar a hipotensão para tratar

**4.** No caso 1, há suspeita de lesão de bacia associada, com sangramento. Qual a conduta inicial?
- A) Fazer laparotomia exploradora antes de qualquer imagem
- B) Retirar a cinta para radiografar
- C) Esperar a TC para confirmar
- D) Colocar a cinta pélvica imediatamente
- E) Testar a estabilidade da bacia várias vezes

**5.** No caso 1, um colega diz que, com a perna controlada, a 'avaliação primária acabou'. O que está errado?
- A) A primária segue por todas as letras, reavaliando após cada intervenção
- B) Nada; o sangramento era o único problema
- C) A primária termina com a radiografia de tórax
- D) Basta repetir a FC
- E) É hora de dar alta da sala


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Em todo paciente com fratura de membro
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 1, você é o líder. Antes da chegada da paciente, o que deveria ter sido feito?
- A) Definir funções e preparar material, já que houve aviso prévio
- B) Chamar a TC para reservar horário e nada mais
- C) Pedir que todos examinem a paciente ao mesmo tempo, sem funções
- D) Esperar a paciente para distribuir funções
- E) Deixar o residente mais novo liderar sem supervisão

**3.** No caso 1, como deveria ser a passagem do caso pelo pré-hospitalar?
- A) Só com os sinais vitais
- B) Por escrito, lida depois do atendimento
- C) Livre, enquanto a equipe já examina
- D) Estruturada (MIST), com a equipe parada ouvindo, em até 1 minuto
- E) Longa, com todos os detalhes da cena

**4.** No caso 1, após o torniquete, a paciente segue com FC 124 e pele fria. Qual a decisão do líder?
- A) Encerrar a reposição porque o torniquete resolveu
- B) Esperar o resultado do lactato antes de qualquer conduta
- C) Dar alta da sala para a enfermaria
- D) Manter a avaliação primária, buscar outras fontes de sangramento e decidir o destino com base na resposta à ressuscitação
- E) Mandar para a TC e reavaliar na volta

**5.** No caso 1, o enfermeiro registra a avaliação em um formulário estruturado. O que a evidência mostra sobre esse tipo de formulário?
- A) Redução de mortalidade em todos os pacientes, como desfecho principal
- B) Nenhum efeito sobre o processo
- C) Aumento comprovado da mortalidade
- D) Só serve para fins de auditoria, sem relação com o cuidado
- E) Melhora de indicadores da avaliação primária, como o registro da via aérea


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Em todo paciente com fratura de membro
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 1, um residente pergunta se o torniquete 'salva vidas'. Qual a resposta mais fiel à evidência?
- A) Não, ele aumenta a mortalidade
- B) Não há dados sobre o tema
- C) Sim, com redução significativa comprovada
- D) Só salva vidas quando colocado no hospital
- E) A doutrina o considera potencialmente salvador, mas a revisão pré-hospitalar não mostrou redução significativa e há mais amputação inicial, possivelmente por confusão com a gravidade

**3.** Ainda no caso 1: qual afirmação sobre treinamentos como o ATLS é a mais precisa?
- A) Associam-se a menor mortalidade (OR 0,60) em estudos observacionais, sem evidência de alta qualidade
- B) Reduzem a mortalidade, como mostram ensaios randomizados
- C) Não têm associação com mortalidade
- D) Só funcionam em países de alta renda
- E) Aumentam o tempo de atendimento

**4.** Se a paciente do caso 1 chegasse em parada cardíaca traumática, o que a evidência observacional mostra sobre a adrenalina?
- A) Obrigatória antes de qualquer outra medida
- B) Sem associação com sobrevida
- C) Associada a maior sobrevida em 7 dias
- D) Associada a melhor desfecho neurológico comprovado
- E) Associada a menor sobrevida em 7 dias (OR 0,20)

**5.** Você vai propor ao serviço um checklist para a sala de trauma, usando casos como o 1. Qual cautela a evidência impõe?
- A) O checklist só funciona em pacientes com ISS abaixo de 25
- B) Os estudos são antes-e-depois e um deles mostrou mais pneumonia; medir desfechos após implantar
- C) Nenhuma; os benefícios são comprovados por ensaios
- D) Não há estudos sobre checklist no trauma
- E) O checklist aumenta a mortalidade
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_1' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pré-teste inicial

Tempo estimado: cerca de 10 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 1.

**Caso 1.** Mulher de 45 anos, motorista, colisão frontal. Chega acordada e responde às perguntas com voz normal. Há fratura exposta da perna direita com sangramento ativo em jato, que encharca o lençol. FC 124, pele fria e pálida. A equipe ainda não fez nenhuma intervenção.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 1, qual é a primeira medida?
- A) Pedir radiografia de tórax
- B) Comprimir diretamente o ponto que sangra
- C) Levar para a tomografia
- D) Colher a história AMPLA
- E) Intubar a paciente

**3.** A paciente do caso 1 responde às perguntas com voz normal. O que isso indica?
- A) Que a coluna cervical está lesada
- B) Que ela precisa de via aérea definitiva
- C) Que o Glasgow é menor que 8
- D) Que não há choque
- E) Que a via aérea está pérvia

**4.** Por que, no caso 1, a circulação é tratada antes da via aérea?
- A) Porque há hemorragia externa com risco de vida
- B) Porque a fratura é exposta
- C) Porque ela tem mais de 40 anos
- D) Porque a FC é o primeiro sinal vital medido
- E) Porque a via aérea nunca é prioridade no trauma

**5.** Controlado o sangramento e terminado o exame com a paciente despida, o que deve ser feito?
- A) Dar banho com água fria para limpar
- B) Aquecer só se a temperatura cair abaixo de 32 °C
- C) Mantê-la descoberta para reexaminar
- D) Aquecê-la com mantas, ar forçado e fluidos aquecidos
- E) Esperar a TC para decidir


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 1, a compressão direta não controla o sangramento da perna. Qual é a próxima medida?
- A) Pinçar às cegas dentro da ferida
- B) Elevar o membro e observar por 10 minutos
- C) Aplicar torniquete proximal à lesão
- D) Intubar antes de qualquer outra coisa
- E) Pedir angiotomografia antes de agir

**3.** No caso 1, o aparelho automático marca PA 120/80. Como interpretar?
- A) A paciente não está em choque
- B) A pressão normal libera a paciente para a TC sem reavaliação
- C) Deve-se suspender a reposição
- D) A FC alta é só dor
- E) O aparelho automático pode errar no choque; confirmar com medida manual e com a clínica

**4.** No caso 1, a equipe não consegue acesso venoso em duas tentativas. Qual a melhor alternativa?
- A) Continuar tentando veia periférica por 15 minutos
- B) Acesso intraósseo
- C) Puncionar a artéria femoral para infundir
- D) Adiar a reposição até chegar à TC
- E) Dar líquidos por via oral

**5.** Ao despir a paciente do caso 1, o que justifica remover toda a roupa?
- A) Permitir o exame completo em 360 graus, para não deixar lesões passarem
- B) Facilitar o uso da cinta pélvica em todos os casos
- C) Só é necessário no trauma penetrante
- D) Só facilitar a limpeza
- E) Evitar a hipotermia


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Em todo paciente com fratura de membro
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 1, um torniquete é aplicado e controla o sangramento. O que a evidência mostra sobre o torniquete pré-hospitalar?
- A) Não altera a taxa de amputação
- B) Redução de mortalidade não significativa e mais amputação inicial
- C) Reduz a mortalidade de forma significativa
- D) Só deve ser usado no membro superior
- E) Aumenta a mortalidade

**3.** No caso 1, FC 124 e pele fria, mas a paciente está lúcida e responde bem. O que considerar?
- A) A tabela de classes de choque é suficiente para decidir
- B) Lucidez exclui choque grave
- C) Não decidir por um parâmetro isolado; a classificação clássica tem limitações
- D) Sedar para medir melhor a FC
- E) Aguardar a hipotensão para tratar

**4.** No caso 1, há suspeita de lesão de bacia associada, com sangramento. Qual a conduta inicial?
- A) Fazer laparotomia exploradora antes de qualquer imagem
- B) Retirar a cinta para radiografar
- C) Esperar a TC para confirmar
- D) Colocar a cinta pélvica imediatamente
- E) Testar a estabilidade da bacia várias vezes

**5.** No caso 1, um colega diz que, com a perna controlada, a 'avaliação primária acabou'. O que está errado?
- A) A primária segue por todas as letras, reavaliando após cada intervenção
- B) Nada; o sangramento era o único problema
- C) A primária termina com a radiografia de tórax
- D) Basta repetir a FC
- E) É hora de dar alta da sala


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Em todo paciente com fratura de membro
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 1, você é o líder. Antes da chegada da paciente, o que deveria ter sido feito?
- A) Definir funções e preparar material, já que houve aviso prévio
- B) Chamar a TC para reservar horário e nada mais
- C) Pedir que todos examinem a paciente ao mesmo tempo, sem funções
- D) Esperar a paciente para distribuir funções
- E) Deixar o residente mais novo liderar sem supervisão

**3.** No caso 1, como deveria ser a passagem do caso pelo pré-hospitalar?
- A) Só com os sinais vitais
- B) Por escrito, lida depois do atendimento
- C) Livre, enquanto a equipe já examina
- D) Estruturada (MIST), com a equipe parada ouvindo, em até 1 minuto
- E) Longa, com todos os detalhes da cena

**4.** No caso 1, após o torniquete, a paciente segue com FC 124 e pele fria. Qual a decisão do líder?
- A) Encerrar a reposição porque o torniquete resolveu
- B) Esperar o resultado do lactato antes de qualquer conduta
- C) Dar alta da sala para a enfermaria
- D) Manter a avaliação primária, buscar outras fontes de sangramento e decidir o destino com base na resposta à ressuscitação
- E) Mandar para a TC e reavaliar na volta

**5.** No caso 1, o enfermeiro registra a avaliação em um formulário estruturado. O que a evidência mostra sobre esse tipo de formulário?
- A) Redução de mortalidade em todos os pacientes, como desfecho principal
- B) Nenhum efeito sobre o processo
- C) Aumento comprovado da mortalidade
- D) Só serve para fins de auditoria, sem relação com o cuidado
- E) Melhora de indicadores da avaliação primária, como o registro da via aérea


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Em todo paciente com fratura de membro
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 1, um residente pergunta se o torniquete 'salva vidas'. Qual a resposta mais fiel à evidência?
- A) Não, ele aumenta a mortalidade
- B) Não há dados sobre o tema
- C) Sim, com redução significativa comprovada
- D) Só salva vidas quando colocado no hospital
- E) A doutrina o considera potencialmente salvador, mas a revisão pré-hospitalar não mostrou redução significativa e há mais amputação inicial, possivelmente por confusão com a gravidade

**3.** Ainda no caso 1: qual afirmação sobre treinamentos como o ATLS é a mais precisa?
- A) Associam-se a menor mortalidade (OR 0,60) em estudos observacionais, sem evidência de alta qualidade
- B) Reduzem a mortalidade, como mostram ensaios randomizados
- C) Não têm associação com mortalidade
- D) Só funcionam em países de alta renda
- E) Aumentam o tempo de atendimento

**4.** Se a paciente do caso 1 chegasse em parada cardíaca traumática, o que a evidência observacional mostra sobre a adrenalina?
- A) Obrigatória antes de qualquer outra medida
- B) Sem associação com sobrevida
- C) Associada a maior sobrevida em 7 dias
- D) Associada a melhor desfecho neurológico comprovado
- E) Associada a menor sobrevida em 7 dias (OR 0,20)

**5.** Você vai propor ao serviço um checklist para a sala de trauma, usando casos como o 1. Qual cautela a evidência impõe?
- A) O checklist só funciona em pacientes com ISS abaixo de 25
- B) Os estudos são antes-e-depois e um deles mostrou mais pneumonia; medir desfechos após implantar
- C) Nenhuma; os benefícios são comprovados por ensaios
- D) Não há estudos sobre checklist no trauma
- E) O checklist aumenta a mortalidade
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A23', $af$Revisão sistemática de torniquete pré-hospitalar: redução de mortalidade não significativa (4,02% vs. 6,43%; RR 0,70; IC 95% 0,46–1,07).$af$, '2024_43', $af$a non-statistically significant reduction in mortality risk with tourniquet application (4.02% vs. 6.43%, RR 0.70, 95% CI 0.46–1.07)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A24', $af$A amputação inicial foi mais frequente com torniquete (19,32% vs. 6,4%; RR 2,07; IC 95% 1,21–3,52).$af$, '2024_43', $af$initial amputation in the tourniquet group (19.32% vs. 6.4%, RR 2.07, 95% CI 1.21–3.52)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A31', $af$Na parada cardíaca extra-hospitalar traumática, a adrenalina associou-se a menor sobrevida em 7 dias (OR 0,20; IC 95% 0,08–0,48).$af$, '2019_31', $af$The use of epinephrine was significantly associated with decreased 7-day survival (odds ratio = 0.20; 95% CI = 0.08–0.48; P < 0.01)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D7', $af$No trauma de extremidade, o torniquete pode salvar a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$For extremity trauma, placement of a tourniquet can be lifesaving.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_1' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_1')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'teste_2', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_2'),0)+1, 'rascunho', $T1$Pré-teste após o conhecimento básico$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pré-teste após o conhecimento básico

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 2.

**Caso 2.** Homem de 22 anos, ferido por faca no hemitórax esquerdo. Chega falando, ansioso, com respiração rápida. SpO2 89% em ar ambiente, FC 112, o aparelho automático marca PA 104/70. O eFAST não mostra sinais de pneumotórax. A equipe do SAMU quer contar o caso enquanto o paciente é passado para a maca.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Apenas depois de obtida a radiografia de tórax
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 2, o paciente fala. O que isso indica sobre a via aérea?
- A) Que o Glasgow é menor que 8
- B) Que precisa ser intubado
- C) Que está pérvia
- D) Que não há lesão no tórax
- E) Que há lesão de coluna

**3.** No caso 2, a SpO2 é 89%. O oxigênio está indicado?
- A) Só depois da TC
- B) Sim, guiado pela saturação baixa
- C) Só se o eFAST for positivo
- D) Não, oxigênio nunca é usado no trauma
- E) Só se houver parada

**4.** No caso 2, o que fazer com a roupa do paciente?
- A) Retirar só se houver sangue visível
- B) Retirar toda a roupa para examinar o corpo inteiro
- C) Manter a roupa para evitar frio
- D) Cortar só a camisa
- E) Retirar depois da TC

**5.** No caso 2, qual é o objetivo da avaliação primária?
- A) Fazer o diagnóstico completo de todas as lesões
- B) Decidir a alta
- C) Colher a história da família
- D) Identificar e tratar rapidamente as lesões que ameaçam a vida
- E) Preencher o prontuário

**6.** No caso 2, quanto tempo a passagem do caso pelo SAMU deveria durar?
- A) Pelo menos 5 minutos
- B) No máximo 45 segundos a 1 minuto
- C) Não deve haver passagem verbal
- D) Só depois do exame da equipe
- E) O tempo que o SAMU quiser

**7.** No caso 2, o eFAST não mostra pneumotórax. Isso exclui pneumotórax?
- A) O eFAST não avalia o tórax
- B) Sim, sempre
- C) Só exclui se repetido três vezes
- D) Não necessariamente; houve estudo com baixa sensibilidade
- E) Sim, se o paciente fala


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Apenas depois de obtida a radiografia de tórax
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 2, como conduzir a passagem do SAMU?
- A) O SAMU entrega um papel e sai
- B) Só o enfermeiro ouve
- C) A equipe para e ouve uma passagem estruturada, como o MIST, antes de passar o paciente
- D) A passagem é feita depois da TC
- E) Todos examinam enquanto o SAMU fala

**3.** No caso 2, quais são os elementos do MIST?
- A) Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos
- B) Monitorização, imagem, sangue, tomografia
- C) Motivo, informante, situação, telefone
- D) Medicações, idade, sexo, tempo
- E) Mecanismo, intubação, sedação, transporte

**4.** No caso 2, PA 104/70 no aparelho automático e FC 112. Qual a interpretação correta?
- A) A pressão normal dispensa acesso venoso
- B) A FC alta é só ansiedade
- C) O paciente está estável
- D) O aparelho pode errar no choque; medir manualmente e avaliar a clínica
- E) Deve-se esperar a pressão cair

**5.** No caso 2, depois da primária, como colher a história?
- A) Perguntando só sobre dor
- B) Não é necessário colher história no trauma
- C) Usando o AMPLA: alergias, medicações, doenças prévias, última refeição, eventos
- D) Só com a família, depois da alta
- E) Pedindo que o paciente escreva

**6.** No caso 2, por que examinar as costas e as axilas do paciente esfaqueado?
- A) Porque a TC não vê as costas
- B) Porque é rotina só para fins legais
- C) Porque o eFAST já excluiu lesões
- D) Não é necessário examinar as costas
- E) Porque a exposição completa permite achar outras lesões

**7.** No caso 2, achados positivos no exame físico do tórax devem ser valorizados?
- A) Só se o eFAST concordar
- B) Sim: o exame tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave
- C) Não, só valem com imagem
- D) Não, o exame físico não tem valor no trauma
- E) Só no trauma fechado


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 2, o eFAST não mostrou pneumotórax, mas a SpO2 segue 89% e a respiração rápida. O que fazer?
- A) Repetir o eFAST só no dia seguinte
- B) Atribuir à ansiedade
- C) Dar alta da sala
- D) Manter a investigação e o exame, porque o ultrassom pode dar falso negativo
- E) Encerrar a hipótese de pneumotórax

**3.** No caso 2, o eFAST foi negativo e a SpO2 melhora com oxigênio. Como usar esse eFAST negativo na decisão?
- A) Ignorá-lo, porque o ultrassom não avalia o tórax
- B) Para indicar drenagem torácica imediata
- C) Como dado de apoio, sem descartar pneumotórax: a sensibilidade variou entre os estudos
- D) Para descartar pneumotórax, porque a sensibilidade é sempre maior que 99%
- E) Para liberar o paciente da sala sem reavaliar

**4.** No caso 2, sem acesso venoso após tentativas, qual a melhor opção?
- A) Esperar a TC
- B) Insistir na veia por tempo indefinido
- C) Acesso intraósseo
- D) Usar só via oral
- E) Adiar a reposição

**5.** No caso 2, o paciente em choque tem a pele fria. Qual medida não deve ser esquecida após o exame?
- A) Manter despido
- B) Dar líquidos frios
- C) Aquecer com mantas, ar forçado e fluidos aquecidos
- D) Esperar a temperatura cair para agir
- E) Aquecer só na UTI

**6.** No caso 2, por que a ordem padrão ABCDE é mantida e não invertida para CAB?
- A) Porque não há hemorragia externa com risco de vida nem o paciente está em extremis
- B) Porque o paciente é jovem
- C) Porque o eFAST foi negativo
- D) Porque o ferimento é penetrante
- E) Porque a SpO2 está baixa

**7.** No caso 2, o paciente fica sonolento, com Glasgow 8, e fala com dificuldade. Qual a conduta de via aérea?
- A) Nenhuma, porque ele ainda fala
- B) Cricotireoidostomia imediata, sem tentar intubação
- C) Sedar e paralisar antes de qualquer exame neurológico
- D) Aguardar o Glasgow cair mais
- E) Via aérea definitiva, com exame neurológico breve antes da sedação


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Apenas depois de obtida a radiografia de tórax
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 2, você lidera. Onde se posicionar durante o atendimento?
- A) Na cabeceira, fazendo a via aérea
- B) Onde tenha a visão do todo, geralmente aos pés da maca
- C) No posto de enfermagem
- D) Fora da sala, ao telefone
- E) Junto ao monitor, de costas para o paciente

**3.** No caso 2, quem deve tomar as decisões sobre os próximos passos?
- A) Quem chegar primeiro
- B) Cada membro decide sua parte
- C) O enfermeiro da maca
- D) O SAMU
- E) O líder da equipe

**4.** No caso 2, o paciente responde à reposição e segue com SpO2 baixa. A TC de corpo inteiro de rotina reduz mortalidade?
- A) Reduz a mortalidade de forma comprovada
- B) Aumenta a mortalidade
- C) Dispensa a avaliação secundária
- D) Dispensa a avaliação terciária
- E) Parece ter pouco ou nenhum efeito em mortalidade

**5.** No caso 2, a passagem do SAMU durou 4 minutos com detalhes da cena. Qual a correção?
- A) Pedir que o SAMU volte depois
- B) Nenhuma; detalhes são sempre úteis
- C) Deixar a passagem para o fim
- D) O líder deve conduzir e limitar a passagem a 45 segundos a 1 minuto
- E) Proibir a passagem verbal

**6.** No caso 2, quando o residente do primeiro ano pode liderar?
- A) Sempre que quiser
- B) Só se o assistente sair
- C) Só em pacientes graves
- D) Nunca
- E) Sob supervisão próxima do assistente

**7.** No caso 2, qual estratégia de treinamento da equipe reduz o tempo de ressuscitação, segundo estudo?
- A) Avaliação escrita semestral
- B) Nenhuma estratégia mostrou efeito
- C) Treino mensal in situ com debriefing em vídeo
- D) Aulas teóricas anuais
- E) Leitura de protocolos


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Em todo paciente com fratura de membro
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 2, discutindo com residentes os dois estudos de eFAST para pneumotórax, qual a síntese correta?
- A) O eFAST é sempre sensível
- B) Os dois estudos concordam
- C) A especificidade é baixa
- D) O eFAST é sempre inútil
- E) Resultados conflitantes: sensibilidade alta em um, baixa em outro; negativo não encerra a investigação

**3.** No caso 2, sobre oxigênio suplementar no traumatizado grave, o que a pesquisa com profissionais mostrou?
- A) Contraindica oxigênio no trauma
- B) Não houve consenso algum
- C) É um ensaio clínico com desfecho de mortalidade
- D) A maioria (73 %) não apoia dar oxigênio sempre, sem considerar a SpO2
- E) A maioria apoia oxigênio para todos

**4.** No caso 2, um residente quer intubar porque o paciente 'pode piorar'. Qual a melhor resposta baseada na doutrina?
- A) O paciente fala com voz normal e tem Glasgow alto; tratar a hipoxemia e reavaliar
- B) Intubar só após a TC
- C) Intubar sempre no trauma penetrante de tórax
- D) Intubar sem exame neurológico prévio
- E) Nunca intubar no trauma de tórax

**5.** No caso 2, se o paciente sangrasse muito pela boca após trauma de face penetrante, sem indicação de proteção cervical, qual medida simples pode ajudar?
- A) Sentá-lo para que cuspa ou aspire o sangue
- B) Sedar profundamente antes de avaliar
- C) Deitá-lo em decúbito dorsal
- D) Tamponar a boca
- E) Colocar colar cervical

**6.** No caso 2, como interpretar a evidência sobre treinamentos de suporte de vida ao planejar o ensino da equipe?
- A) Associação com menor mortalidade em estudos observacionais e ensaio pragmático em andamento
- B) Benefício comprovado por ensaios
- C) Nenhuma associação
- D) Custos iguais entre programas
- E) O ATLS é o programa mais barato

**7.** No caso 2, um colega afirma que lesões passam despercebidas só sem TC. Qual dado o contradiz?
- A) Lesões tardias só ocorrem em crianças
- B) Nenhum dado
- C) A TC detecta 100% das lesões
- D) Lesões com diagnóstico tardio em 13,9 % mesmo com TC de corpo inteiro
- E) A avaliação terciária é desnecessária
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_2' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pré-teste após o conhecimento básico

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 2.

**Caso 2.** Homem de 22 anos, ferido por faca no hemitórax esquerdo. Chega falando, ansioso, com respiração rápida. SpO2 89% em ar ambiente, FC 112, o aparelho automático marca PA 104/70. O eFAST não mostra sinais de pneumotórax. A equipe do SAMU quer contar o caso enquanto o paciente é passado para a maca.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Apenas depois de obtida a radiografia de tórax
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 2, o paciente fala. O que isso indica sobre a via aérea?
- A) Que o Glasgow é menor que 8
- B) Que precisa ser intubado
- C) Que está pérvia
- D) Que não há lesão no tórax
- E) Que há lesão de coluna

**3.** No caso 2, a SpO2 é 89%. O oxigênio está indicado?
- A) Só depois da TC
- B) Sim, guiado pela saturação baixa
- C) Só se o eFAST for positivo
- D) Não, oxigênio nunca é usado no trauma
- E) Só se houver parada

**4.** No caso 2, o que fazer com a roupa do paciente?
- A) Retirar só se houver sangue visível
- B) Retirar toda a roupa para examinar o corpo inteiro
- C) Manter a roupa para evitar frio
- D) Cortar só a camisa
- E) Retirar depois da TC

**5.** No caso 2, qual é o objetivo da avaliação primária?
- A) Fazer o diagnóstico completo de todas as lesões
- B) Decidir a alta
- C) Colher a história da família
- D) Identificar e tratar rapidamente as lesões que ameaçam a vida
- E) Preencher o prontuário

**6.** No caso 2, quanto tempo a passagem do caso pelo SAMU deveria durar?
- A) Pelo menos 5 minutos
- B) No máximo 45 segundos a 1 minuto
- C) Não deve haver passagem verbal
- D) Só depois do exame da equipe
- E) O tempo que o SAMU quiser

**7.** No caso 2, o eFAST não mostra pneumotórax. Isso exclui pneumotórax?
- A) O eFAST não avalia o tórax
- B) Sim, sempre
- C) Só exclui se repetido três vezes
- D) Não necessariamente; houve estudo com baixa sensibilidade
- E) Sim, se o paciente fala


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Apenas depois de obtida a radiografia de tórax
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 2, como conduzir a passagem do SAMU?
- A) O SAMU entrega um papel e sai
- B) Só o enfermeiro ouve
- C) A equipe para e ouve uma passagem estruturada, como o MIST, antes de passar o paciente
- D) A passagem é feita depois da TC
- E) Todos examinam enquanto o SAMU fala

**3.** No caso 2, quais são os elementos do MIST?
- A) Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos
- B) Monitorização, imagem, sangue, tomografia
- C) Motivo, informante, situação, telefone
- D) Medicações, idade, sexo, tempo
- E) Mecanismo, intubação, sedação, transporte

**4.** No caso 2, PA 104/70 no aparelho automático e FC 112. Qual a interpretação correta?
- A) A pressão normal dispensa acesso venoso
- B) A FC alta é só ansiedade
- C) O paciente está estável
- D) O aparelho pode errar no choque; medir manualmente e avaliar a clínica
- E) Deve-se esperar a pressão cair

**5.** No caso 2, depois da primária, como colher a história?
- A) Perguntando só sobre dor
- B) Não é necessário colher história no trauma
- C) Usando o AMPLA: alergias, medicações, doenças prévias, última refeição, eventos
- D) Só com a família, depois da alta
- E) Pedindo que o paciente escreva

**6.** No caso 2, por que examinar as costas e as axilas do paciente esfaqueado?
- A) Porque a TC não vê as costas
- B) Porque é rotina só para fins legais
- C) Porque o eFAST já excluiu lesões
- D) Não é necessário examinar as costas
- E) Porque a exposição completa permite achar outras lesões

**7.** No caso 2, achados positivos no exame físico do tórax devem ser valorizados?
- A) Só se o eFAST concordar
- B) Sim: o exame tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave
- C) Não, só valem com imagem
- D) Não, o exame físico não tem valor no trauma
- E) Só no trauma fechado


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 2, o eFAST não mostrou pneumotórax, mas a SpO2 segue 89% e a respiração rápida. O que fazer?
- A) Repetir o eFAST só no dia seguinte
- B) Atribuir à ansiedade
- C) Dar alta da sala
- D) Manter a investigação e o exame, porque o ultrassom pode dar falso negativo
- E) Encerrar a hipótese de pneumotórax

**3.** No caso 2, o eFAST foi negativo e a SpO2 melhora com oxigênio. Como usar esse eFAST negativo na decisão?
- A) Ignorá-lo, porque o ultrassom não avalia o tórax
- B) Para indicar drenagem torácica imediata
- C) Como dado de apoio, sem descartar pneumotórax: a sensibilidade variou entre os estudos
- D) Para descartar pneumotórax, porque a sensibilidade é sempre maior que 99%
- E) Para liberar o paciente da sala sem reavaliar

**4.** No caso 2, sem acesso venoso após tentativas, qual a melhor opção?
- A) Esperar a TC
- B) Insistir na veia por tempo indefinido
- C) Acesso intraósseo
- D) Usar só via oral
- E) Adiar a reposição

**5.** No caso 2, o paciente em choque tem a pele fria. Qual medida não deve ser esquecida após o exame?
- A) Manter despido
- B) Dar líquidos frios
- C) Aquecer com mantas, ar forçado e fluidos aquecidos
- D) Esperar a temperatura cair para agir
- E) Aquecer só na UTI

**6.** No caso 2, por que a ordem padrão ABCDE é mantida e não invertida para CAB?
- A) Porque não há hemorragia externa com risco de vida nem o paciente está em extremis
- B) Porque o paciente é jovem
- C) Porque o eFAST foi negativo
- D) Porque o ferimento é penetrante
- E) Porque a SpO2 está baixa

**7.** No caso 2, o paciente fica sonolento, com Glasgow 8, e fala com dificuldade. Qual a conduta de via aérea?
- A) Nenhuma, porque ele ainda fala
- B) Cricotireoidostomia imediata, sem tentar intubação
- C) Sedar e paralisar antes de qualquer exame neurológico
- D) Aguardar o Glasgow cair mais
- E) Via aérea definitiva, com exame neurológico breve antes da sedação


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Apenas depois de obtida a radiografia de tórax
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 2, você lidera. Onde se posicionar durante o atendimento?
- A) Na cabeceira, fazendo a via aérea
- B) Onde tenha a visão do todo, geralmente aos pés da maca
- C) No posto de enfermagem
- D) Fora da sala, ao telefone
- E) Junto ao monitor, de costas para o paciente

**3.** No caso 2, quem deve tomar as decisões sobre os próximos passos?
- A) Quem chegar primeiro
- B) Cada membro decide sua parte
- C) O enfermeiro da maca
- D) O SAMU
- E) O líder da equipe

**4.** No caso 2, o paciente responde à reposição e segue com SpO2 baixa. A TC de corpo inteiro de rotina reduz mortalidade?
- A) Reduz a mortalidade de forma comprovada
- B) Aumenta a mortalidade
- C) Dispensa a avaliação secundária
- D) Dispensa a avaliação terciária
- E) Parece ter pouco ou nenhum efeito em mortalidade

**5.** No caso 2, a passagem do SAMU durou 4 minutos com detalhes da cena. Qual a correção?
- A) Pedir que o SAMU volte depois
- B) Nenhuma; detalhes são sempre úteis
- C) Deixar a passagem para o fim
- D) O líder deve conduzir e limitar a passagem a 45 segundos a 1 minuto
- E) Proibir a passagem verbal

**6.** No caso 2, quando o residente do primeiro ano pode liderar?
- A) Sempre que quiser
- B) Só se o assistente sair
- C) Só em pacientes graves
- D) Nunca
- E) Sob supervisão próxima do assistente

**7.** No caso 2, qual estratégia de treinamento da equipe reduz o tempo de ressuscitação, segundo estudo?
- A) Avaliação escrita semestral
- B) Nenhuma estratégia mostrou efeito
- C) Treino mensal in situ com debriefing em vídeo
- D) Aulas teóricas anuais
- E) Leitura de protocolos


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Em todo paciente com fratura de membro
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 2, discutindo com residentes os dois estudos de eFAST para pneumotórax, qual a síntese correta?
- A) O eFAST é sempre sensível
- B) Os dois estudos concordam
- C) A especificidade é baixa
- D) O eFAST é sempre inútil
- E) Resultados conflitantes: sensibilidade alta em um, baixa em outro; negativo não encerra a investigação

**3.** No caso 2, sobre oxigênio suplementar no traumatizado grave, o que a pesquisa com profissionais mostrou?
- A) Contraindica oxigênio no trauma
- B) Não houve consenso algum
- C) É um ensaio clínico com desfecho de mortalidade
- D) A maioria (73 %) não apoia dar oxigênio sempre, sem considerar a SpO2
- E) A maioria apoia oxigênio para todos

**4.** No caso 2, um residente quer intubar porque o paciente 'pode piorar'. Qual a melhor resposta baseada na doutrina?
- A) O paciente fala com voz normal e tem Glasgow alto; tratar a hipoxemia e reavaliar
- B) Intubar só após a TC
- C) Intubar sempre no trauma penetrante de tórax
- D) Intubar sem exame neurológico prévio
- E) Nunca intubar no trauma de tórax

**5.** No caso 2, se o paciente sangrasse muito pela boca após trauma de face penetrante, sem indicação de proteção cervical, qual medida simples pode ajudar?
- A) Sentá-lo para que cuspa ou aspire o sangue
- B) Sedar profundamente antes de avaliar
- C) Deitá-lo em decúbito dorsal
- D) Tamponar a boca
- E) Colocar colar cervical

**6.** No caso 2, como interpretar a evidência sobre treinamentos de suporte de vida ao planejar o ensino da equipe?
- A) Associação com menor mortalidade em estudos observacionais e ensaio pragmático em andamento
- B) Benefício comprovado por ensaios
- C) Nenhuma associação
- D) Custos iguais entre programas
- E) O ATLS é o programa mais barato

**7.** No caso 2, um colega afirma que lesões passam despercebidas só sem TC. Qual dado o contradiz?
- A) Lesões tardias só ocorrem em crianças
- B) Nenhum dado
- C) A TC detecta 100% das lesões
- D) Lesões com diagnóstico tardio em 13,9 % mesmo com TC de corpo inteiro
- E) A avaliação terciária é desnecessária
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A5', $af$O ensaio ADVANCE TRAUMA (stepped-wedge, Índia) incluirá pelo menos 4320 pacientes adultos com 15 anos ou mais.$af$, '2026_26', $af$The trial will include at least 4320 adult trauma patients (≥ 15 years)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A6', $af$O custo de implementação de programas de treinamento variou de USD 3,70 (primeiro respondedor leigo) a USD 1433,5 (ATLS).$af$, '2026_42', $af$starting from USD 3.70 (Lay-First-Responder) to USD 1433.5 (Advanced Trauma Life Support)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A27', $af$Em pesquisa com respondentes, 73 % (IC 95% 70 a 76 %) não apoiaram oxigênio suplementar sempre para todo traumatizado grave sem considerar a SpO2.$af$, '2025_12', $af$A majority of respondents (73 % [95 % CI: 70 to 76 %]) did not support that supplemental oxygen should always be provided to all severely injured trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A28', $af$A cricotireoidostomia/via aérea cirúrgica de emergência ocorreu em 467 pacientes (0,24%) de uma coorte retrospectiva japonesa.$af$, '2020_18', $af$emergency front-of-neck airway occurred in 467 patients (0.24%)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A29', $af$O E-FAST para pneumotórax teve sensibilidade de 93,6% e especificidade de 99,8%.$af$, '2019_35', $af$The overall sensitivity of E-FAST for PNX detection was 93.6% (1244/1328), the specificity of E-FAST was 99.8% (5312/5322)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A30', $af$Em estudo prospectivo, a ultrassonografia torácica na avaliação inicial teve baixa sensibilidade para pneumotórax, com muitos falsos negativos.$af$, '2024_47', $af$Chest ultrasonography performed on initial trauma evaluation has low sensitivity with a high rate of false negative examinations.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A47', $af$O estudo que mostrou baixa sensibilidade do ultrassom torácico incluiu só trauma torácico fechado.$af$, '2024_47', $af$A prospective observational analysis of patients with blunt chest trauma$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D13', $af$No trauma penetrante sem indicação de proteção cervical, sentar o paciente para que cuspa ou aspire o sangue pode controlar a via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$merely placing patients into an upright sitting position and allowing them to spit or suction the blood$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D18', $af$Toda a roupa é retirada para um exame completo em 360 graus.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$All clothing should be removed to facilitate a complete 360-degree exam.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D20', $af$A avaliação secundária é uma história e exame completos, cujo objetivo é identificar todas as demais lesões.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$whose aim is to identify all other injuries$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D21', $af$A história segue o AMPLE (em português, AMPLA): alergias, medicações, doenças prévias, última refeição e eventos/mecanismo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$ATLS suggests using AMPLE (allergies, medications, past illnesses, last meal, events/environment/mechanism)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_2' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_2')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'teste_3', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_3'),0)+1, 'rascunho', $T1$Pós-teste D0$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D0

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 3.

**Caso 3.** Homem de 72 anos, caiu de uma escada de 3 metros. Chega com Glasgow 7, ronco, hálito alcoólico. No caminho estava agitado. FC 118, pele fria, temperatura 35,1 °C. O aparelho automático marca PA 132/84.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Em todo paciente com fratura de membro
- D) Apenas depois de obtida a radiografia de tórax
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 3, o Glasgow é 7. O que isso indica?
- A) Que basta oxigênio por cateter
- B) Que a via aérea está garantida
- C) Necessidade de via aérea definitiva
- D) Que pode esperar a TC para decidir
- E) Que não há trauma de crânio

**3.** No caso 3, a agitação no caminho pode significar o quê?
- A) Só embriaguez
- B) Choque, além de álcool ou trauma de crânio
- C) Só dor
- D) Que o paciente está bem
- E) Nada de importante

**4.** No caso 3, temperatura de 35,1 °C. O que fazer?
- A) Esperar a TC
- B) Dar banho frio
- C) Retirar as mantas para examinar de novo
- D) Nada, é normal
- E) Aquecer: mantas, ar forçado, fluidos aquecidos

**5.** No caso 3, quando o Glasgow deve ser avaliado?
- A) Na chegada e de novo durante a ressuscitação
- B) Só na chegada
- C) Só se houver fratura de crânio
- D) Só na UTI
- E) Só depois da intubação

**6.** No caso 3, a pressão de 132/84 no aparelho automático exclui choque?
- A) Sim
- B) Sim, no idoso
- C) Sim, se a FC for alta
- D) Só se a pele estiver quente
- E) Não; o aparelho automático pode errar no choque

**7.** No caso 3, qual é a sequência padrão da avaliação primária neste paciente sem hemorragia externa?
- A) Só AB
- B) CAB
- C) ABCDE
- D) EDCBA
- E) DEABC


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Em todo paciente com fratura de membro
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Apenas depois de obtida a radiografia de tórax
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 3, antes de sedar e intubar, o que deve ser feito?
- A) Nada; intubar imediatamente sem exame
- B) Retirar o colar
- C) TC de crânio
- D) Exame neurológico breve e completo
- E) Colher o AMPLA completo

**3.** No caso 3, por que medir a pressão manualmente?
- A) Porque o aparelho automático pode errar no choque
- B) Por tradição, sem motivo
- C) Porque o manual é sempre mais alto
- D) Porque o idoso não tem pulso
- E) Porque o automático é proibido

**4.** No caso 3, o hálito alcoólico explica o Glasgow 7?
- A) Não se deve atribuir ao álcool sem excluir choque e trauma de crânio
- B) Não importa a causa
- C) Sim, sempre
- D) Sim, se o paciente for idoso
- E) Sim, se a TC for normal

**5.** No caso 3, após a intubação, qual cuidado com a temperatura?
- A) Nenhum
- B) Só na UTI
- C) Só se abaixo de 30 °C
- D) Resfriar para proteger o cérebro
- E) Aquecer ativamente e medir

**6.** No caso 3, um colega diz que o exame físico normal da barriga dispensa investigação. O que a doutrina diz?
- A) Exame normal exclui lesão
- B) Exame físico não tem valor
- C) Exame normal libera a alta
- D) Só a TC tem valor
- E) O exame físico tem baixo valor preditivo negativo; um exame normal não exclui lesão

**7.** No caso 3, a temperatura é 35,1 °C e um colega diz que isso não é prioridade. Como responder?
- A) Resfriar para proteger o cérebro
- B) Aquecer só com fluido, sem mantas
- C) A hipotermia atinge até dois terços dos graves e é subvalorizada: aquecer já
- D) Hipotermia é rara no trauma
- E) Concordar: só tratar abaixo de 32 °C


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Sempre que houver trauma penetrante, independentemente do sangramento
- B) Apenas depois de obtida a radiografia de tórax
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Em todo paciente com fratura de membro

**2.** No caso 3, por que o aquecimento com fluido aquecido pode ser insuficiente?
- A) Fluido aquecido não existe na prática
- B) Fluido aquecido esfria o paciente
- C) O fluido chega sempre a 39 °C
- D) Fluido a 39 °C só chega acima de 37 °C com alto fluxo e ambiente quente
- E) O fluido aquecido é contraindicado

**3.** No caso 3, existe abordagem baseada em evidência para manejar a hipotermia no trauma?
- A) Sim, só para idosos
- B) Sim, resfriar ativamente
- C) Não, ao contrário da acidose e do sangramento
- D) Sim, com ensaios definitivos
- E) Não é necessária

**4.** No caso 3, FC 118 e pele fria com PA normal no automático. Como avaliar o choque?
- A) Pela FC apenas
- B) Pelo Glasgow apenas
- C) Pela tabela de classes apenas
- D) Pela PA apenas
- E) Sem depender de um parâmetro isolado; a classificação clássica tem limitações

**5.** No caso 3, ao revisar o caso no dia seguinte, o que reduz lesões não identificadas?
- A) Dar alta precoce
- B) Confiar só no laudo inicial
- C) Repetir a TC de corpo inteiro em todos
- D) Avaliação terciária com revisão cuidadosa das imagens
- E) Nada

**6.** No caso 3, após intubação, a PA cai. Como interpretar?
- A) Ignorar
- B) É do álcool
- C) É normal no idoso
- D) É só efeito da sedação
- E) Hipotensão após a ressuscitação é sangramento até prova em contrário

**7.** No caso 3, a avaliação terciária no segundo dia não achou nada. No quarto dia, o paciente piora. Como pensar?
- A) Dar alta da UTI
- B) Aguardar 48 horas
- C) A terciária excluiu tudo; pensar só em causas clínicas
- D) Ainda pode haver lesão não identificada: houve lesão potencialmente letal após a terciária em 0,26% dos graves
- E) Repetir a TC de corpo inteiro sem examinar


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Em todo paciente com fratura de membro
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 3, como líder, qual o destino após estabilizar a via aérea e a circulação?
- A) TC sempre, mesmo instável sem resposta
- B) Alta da sala sem TC
- C) Decidir pela resposta à ressuscitação; a TC é possível no paciente que responde
- D) Esperar 6 horas
- E) UTI sem imagem

**3.** No caso 3, em pacientes em choque, a TC de corpo inteiro aumentou a mortalidade em 24 h?
- A) Não: 17,4% com TC e 27,6% sem, p = 0,21
- B) Não há estudos
- C) Sim, dobrou
- D) Sim, com significância
- E) Só nos idosos

**4.** No caso 3, como garantir que a equipe faça a avaliação em paralelo?
- A) Um faz tudo sozinho
- B) Sem liderança definida
- C) Todos fazem tudo
- D) Esperar o assistente
- E) Funções definidas pelo líder antes da chegada

**5.** No caso 3, qual o maior determinante do desfecho?
- A) O número de exames
- B) A idade isolada
- C) O horário da chegada
- D) A alteração fisiológica
- E) O mecanismo isolado

**6.** No caso 3, após a TC, quem deve fazer a avaliação terciária e quando?
- A) Antes da primária
- B) Só na alta
- C) Ninguém, a TC basta
- D) Só se houver queixa
- E) A equipe, depois de concluídas a ressuscitação inicial e as intervenções

**7.** No caso 3, o paciente intubado tem a perna esquerda edemaciada e o teste clínico SILENT é negativo. Como agir?
- A) Indicar fasciotomia imediata
- B) Não excluir lesão: o SILENT tem sensibilidade de 75%; investigar com imagem
- C) Repetir o SILENT até ficar positivo
- D) Excluir lesão, porque a especificidade é 99%
- E) Ignorar o edema


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Em todo paciente com fratura de membro
- C) Apenas depois de obtida a radiografia de tórax
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 3, ao ensinar sobre classes de choque, qual crítica metodológica deve ser apresentada?
- A) A tabela foi validada sem limitações
- B) A comparação clássica com o déficit de base teve viés que superestimou a classe pelos parâmetros tradicionais
- C) O déficit de base nunca foi estudado
- D) Não há críticas publicadas
- E) A classe de choque é definida pela idade

**3.** No caso 3, um residente diz que o paciente está 'hemodinamicamente estável' porque a PA do aparelho automático é normal. Como corrigir o raciocínio?
- A) Estabilidade não tem definição consensual; descrever os parâmetros e a resposta, e medir a PA manualmente
- B) Confiar no aparelho automático no choque
- C) Encerrar a reposição
- D) Concordar: PA normal define estabilidade
- E) Usar só a FC para decidir

**4.** No caso 3, você audita o serviço. Qual indicador de processo é mais coerente com as lacunas do tema?
- A) Tempo de alta hospitalar
- B) Número de TCs por mês
- C) Custo do material
- D) Número de residentes
- E) Temperatura medida na admissão

**5.** No caso 3, ao discutir lesões não identificadas, qual a melhor estratégia institucional baseada nas fontes?
- A) Restringir o exame físico
- B) Avaliação terciária com revisão de imagens e vigilância depois dela
- C) Nada a fazer
- D) Alta precoce
- E) Mais TCs de rotina

**6.** No caso 3, qual a interpretação correta de 'achados positivos no exame físico quase sempre indicam lesão grave'?
- A) O exame normal exclui lesão
- B) Achados positivos exigem ação, mesmo que o exame normal não exclua lesão
- C) Só vale com TC
- D) O exame não tem valor
- E) Só vale para o tórax

**7.** No caso 3, ao revisar o protocolo, o que justificaria manter o aquecimento ativo como item obrigatório, apesar da falta de evidência de manejo?
- A) Nenhuma razão
- B) Ensaio randomizado definitivo
- C) A frequência alta e a subvalorização da hipotermia, e a recomendação da doutrina de aquecer
- D) Mortalidade comprovadamente reduzida
- E) Custo zero comprovado
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_3' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D0

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 3.

**Caso 3.** Homem de 72 anos, caiu de uma escada de 3 metros. Chega com Glasgow 7, ronco, hálito alcoólico. No caminho estava agitado. FC 118, pele fria, temperatura 35,1 °C. O aparelho automático marca PA 132/84.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Em todo paciente com fratura de membro
- D) Apenas depois de obtida a radiografia de tórax
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 3, o Glasgow é 7. O que isso indica?
- A) Que basta oxigênio por cateter
- B) Que a via aérea está garantida
- C) Necessidade de via aérea definitiva
- D) Que pode esperar a TC para decidir
- E) Que não há trauma de crânio

**3.** No caso 3, a agitação no caminho pode significar o quê?
- A) Só embriaguez
- B) Choque, além de álcool ou trauma de crânio
- C) Só dor
- D) Que o paciente está bem
- E) Nada de importante

**4.** No caso 3, temperatura de 35,1 °C. O que fazer?
- A) Esperar a TC
- B) Dar banho frio
- C) Retirar as mantas para examinar de novo
- D) Nada, é normal
- E) Aquecer: mantas, ar forçado, fluidos aquecidos

**5.** No caso 3, quando o Glasgow deve ser avaliado?
- A) Na chegada e de novo durante a ressuscitação
- B) Só na chegada
- C) Só se houver fratura de crânio
- D) Só na UTI
- E) Só depois da intubação

**6.** No caso 3, a pressão de 132/84 no aparelho automático exclui choque?
- A) Sim
- B) Sim, no idoso
- C) Sim, se a FC for alta
- D) Só se a pele estiver quente
- E) Não; o aparelho automático pode errar no choque

**7.** No caso 3, qual é a sequência padrão da avaliação primária neste paciente sem hemorragia externa?
- A) Só AB
- B) CAB
- C) ABCDE
- D) EDCBA
- E) DEABC


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Em todo paciente com fratura de membro
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Apenas depois de obtida a radiografia de tórax
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 3, antes de sedar e intubar, o que deve ser feito?
- A) Nada; intubar imediatamente sem exame
- B) Retirar o colar
- C) TC de crânio
- D) Exame neurológico breve e completo
- E) Colher o AMPLA completo

**3.** No caso 3, por que medir a pressão manualmente?
- A) Porque o aparelho automático pode errar no choque
- B) Por tradição, sem motivo
- C) Porque o manual é sempre mais alto
- D) Porque o idoso não tem pulso
- E) Porque o automático é proibido

**4.** No caso 3, o hálito alcoólico explica o Glasgow 7?
- A) Não se deve atribuir ao álcool sem excluir choque e trauma de crânio
- B) Não importa a causa
- C) Sim, sempre
- D) Sim, se o paciente for idoso
- E) Sim, se a TC for normal

**5.** No caso 3, após a intubação, qual cuidado com a temperatura?
- A) Nenhum
- B) Só na UTI
- C) Só se abaixo de 30 °C
- D) Resfriar para proteger o cérebro
- E) Aquecer ativamente e medir

**6.** No caso 3, um colega diz que o exame físico normal da barriga dispensa investigação. O que a doutrina diz?
- A) Exame normal exclui lesão
- B) Exame físico não tem valor
- C) Exame normal libera a alta
- D) Só a TC tem valor
- E) O exame físico tem baixo valor preditivo negativo; um exame normal não exclui lesão

**7.** No caso 3, a temperatura é 35,1 °C e um colega diz que isso não é prioridade. Como responder?
- A) Resfriar para proteger o cérebro
- B) Aquecer só com fluido, sem mantas
- C) A hipotermia atinge até dois terços dos graves e é subvalorizada: aquecer já
- D) Hipotermia é rara no trauma
- E) Concordar: só tratar abaixo de 32 °C


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Sempre que houver trauma penetrante, independentemente do sangramento
- B) Apenas depois de obtida a radiografia de tórax
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Em todo paciente com fratura de membro

**2.** No caso 3, por que o aquecimento com fluido aquecido pode ser insuficiente?
- A) Fluido aquecido não existe na prática
- B) Fluido aquecido esfria o paciente
- C) O fluido chega sempre a 39 °C
- D) Fluido a 39 °C só chega acima de 37 °C com alto fluxo e ambiente quente
- E) O fluido aquecido é contraindicado

**3.** No caso 3, existe abordagem baseada em evidência para manejar a hipotermia no trauma?
- A) Sim, só para idosos
- B) Sim, resfriar ativamente
- C) Não, ao contrário da acidose e do sangramento
- D) Sim, com ensaios definitivos
- E) Não é necessária

**4.** No caso 3, FC 118 e pele fria com PA normal no automático. Como avaliar o choque?
- A) Pela FC apenas
- B) Pelo Glasgow apenas
- C) Pela tabela de classes apenas
- D) Pela PA apenas
- E) Sem depender de um parâmetro isolado; a classificação clássica tem limitações

**5.** No caso 3, ao revisar o caso no dia seguinte, o que reduz lesões não identificadas?
- A) Dar alta precoce
- B) Confiar só no laudo inicial
- C) Repetir a TC de corpo inteiro em todos
- D) Avaliação terciária com revisão cuidadosa das imagens
- E) Nada

**6.** No caso 3, após intubação, a PA cai. Como interpretar?
- A) Ignorar
- B) É do álcool
- C) É normal no idoso
- D) É só efeito da sedação
- E) Hipotensão após a ressuscitação é sangramento até prova em contrário

**7.** No caso 3, a avaliação terciária no segundo dia não achou nada. No quarto dia, o paciente piora. Como pensar?
- A) Dar alta da UTI
- B) Aguardar 48 horas
- C) A terciária excluiu tudo; pensar só em causas clínicas
- D) Ainda pode haver lesão não identificada: houve lesão potencialmente letal após a terciária em 0,26% dos graves
- E) Repetir a TC de corpo inteiro sem examinar


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Em todo paciente com fratura de membro
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 3, como líder, qual o destino após estabilizar a via aérea e a circulação?
- A) TC sempre, mesmo instável sem resposta
- B) Alta da sala sem TC
- C) Decidir pela resposta à ressuscitação; a TC é possível no paciente que responde
- D) Esperar 6 horas
- E) UTI sem imagem

**3.** No caso 3, em pacientes em choque, a TC de corpo inteiro aumentou a mortalidade em 24 h?
- A) Não: 17,4% com TC e 27,6% sem, p = 0,21
- B) Não há estudos
- C) Sim, dobrou
- D) Sim, com significância
- E) Só nos idosos

**4.** No caso 3, como garantir que a equipe faça a avaliação em paralelo?
- A) Um faz tudo sozinho
- B) Sem liderança definida
- C) Todos fazem tudo
- D) Esperar o assistente
- E) Funções definidas pelo líder antes da chegada

**5.** No caso 3, qual o maior determinante do desfecho?
- A) O número de exames
- B) A idade isolada
- C) O horário da chegada
- D) A alteração fisiológica
- E) O mecanismo isolado

**6.** No caso 3, após a TC, quem deve fazer a avaliação terciária e quando?
- A) Antes da primária
- B) Só na alta
- C) Ninguém, a TC basta
- D) Só se houver queixa
- E) A equipe, depois de concluídas a ressuscitação inicial e as intervenções

**7.** No caso 3, o paciente intubado tem a perna esquerda edemaciada e o teste clínico SILENT é negativo. Como agir?
- A) Indicar fasciotomia imediata
- B) Não excluir lesão: o SILENT tem sensibilidade de 75%; investigar com imagem
- C) Repetir o SILENT até ficar positivo
- D) Excluir lesão, porque a especificidade é 99%
- E) Ignorar o edema


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Em todo paciente com fratura de membro
- C) Apenas depois de obtida a radiografia de tórax
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 3, ao ensinar sobre classes de choque, qual crítica metodológica deve ser apresentada?
- A) A tabela foi validada sem limitações
- B) A comparação clássica com o déficit de base teve viés que superestimou a classe pelos parâmetros tradicionais
- C) O déficit de base nunca foi estudado
- D) Não há críticas publicadas
- E) A classe de choque é definida pela idade

**3.** No caso 3, um residente diz que o paciente está 'hemodinamicamente estável' porque a PA do aparelho automático é normal. Como corrigir o raciocínio?
- A) Estabilidade não tem definição consensual; descrever os parâmetros e a resposta, e medir a PA manualmente
- B) Confiar no aparelho automático no choque
- C) Encerrar a reposição
- D) Concordar: PA normal define estabilidade
- E) Usar só a FC para decidir

**4.** No caso 3, você audita o serviço. Qual indicador de processo é mais coerente com as lacunas do tema?
- A) Tempo de alta hospitalar
- B) Número de TCs por mês
- C) Custo do material
- D) Número de residentes
- E) Temperatura medida na admissão

**5.** No caso 3, ao discutir lesões não identificadas, qual a melhor estratégia institucional baseada nas fontes?
- A) Restringir o exame físico
- B) Avaliação terciária com revisão de imagens e vigilância depois dela
- C) Nada a fazer
- D) Alta precoce
- E) Mais TCs de rotina

**6.** No caso 3, qual a interpretação correta de 'achados positivos no exame físico quase sempre indicam lesão grave'?
- A) O exame normal exclui lesão
- B) Achados positivos exigem ação, mesmo que o exame normal não exclua lesão
- C) Só vale com TC
- D) O exame não tem valor
- E) Só vale para o tórax

**7.** No caso 3, ao revisar o protocolo, o que justificaria manter o aquecimento ativo como item obrigatório, apesar da falta de evidência de manejo?
- A) Nenhuma razão
- B) Ensaio randomizado definitivo
- C) A frequência alta e a subvalorização da hipotermia, e a recomendação da doutrina de aquecer
- D) Mortalidade comprovadamente reduzida
- E) Custo zero comprovado
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A36', $af$A hipotermia está presente em até dois terços dos pacientes com trauma grave, embora muitas vezes seja desconsiderada na ressuscitação inicial.$af$, '2016_01', $af$Hypothermia is present in up to two-thirds of patients with severe injury, although it is often disregarded during the initial resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A37', $af$Não há abordagem baseada em evidência para manejo da hipotermia no trauma, ao contrário da acidose e do sangramento.$af$, '2016_01', $af$there is no evidence-based approach to managing hypothermia in trauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A38', $af$Fluido pré-aquecido a 39 °C só permanece acima de 37 °C no paciente com alto fluxo e alta temperatura ambiente, em equipo não isolado de 175 cm.$af$, '2024_07', $af$preheated to 39 °C is to remain above 37 °C when it reaches the patient using a 175-cm-long uninsulated infusion set$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D16', $af$O Glasgow é avaliado na chegada e repetido durante a ressuscitação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The GCS score should be assessed immediately upon presentation and sequentially during the resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_3' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_3')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'teste_4', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_4'),0)+1, 'rascunho', $T1$Pós-teste D+15$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D+15

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 4.

**Caso 4.** Homem de 30 anos, motociclista, colisão contra poste. Chega pálido e sonolento. PA 78/50 medida manualmente, FC 136. Dor à palpação da bacia, sem sangramento externo. Duas tentativas de acesso venoso falharam. O ultrassom à beira-leito está disponível.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 4, o paciente está em choque grave. Qual a ordem da avaliação?
- A) Primeiro a história AMPLA
- B) Primeiro a TC
- C) Primeiro a radiografia
- D) Exposição antes de tudo
- E) A circulação tem precedência (CABDE)

**3.** No caso 4, há dor na bacia e choque. O que colocar imediatamente?
- A) Nada até a TC
- B) Sonda vesical
- C) Cinta pélvica
- D) Colar cervical apenas
- E) Torniquete na coxa

**4.** No caso 4, as veias falharam. Qual acesso usar?
- A) Intraósseo
- B) Nenhum até a TC
- C) Intramuscular
- D) Continuar tentando veia por muito tempo
- E) Oral

**5.** No caso 4, o paciente sonolento e pálido. A sonolência pode ser sinal de quê?
- A) Nada
- B) Só álcool
- C) Choque
- D) Boa evolução
- E) Só cansaço

**6.** No caso 4, o que mais define o prognóstico deste paciente?
- A) O número de exames
- B) A idade
- C) A alteração fisiológica
- D) A marca da moto
- E) O horário

**7.** No caso 4, a PA foi medida manualmente. Por quê?
- A) Por tradição
- B) Porque o automático não existe
- C) Porque o aparelho automático pode errar no choque
- D) Sem motivo
- E) Porque é mais rápido


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Apenas depois de obtida a radiografia de tórax
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 4, ao colocar a cinta pélvica, o que a doutrina recomenda?
- A) Colocá-la imediatamente nos pacientes de alto risco
- B) Não usar no choque
- C) Colocar só no centro cirúrgico
- D) Testar a bacia repetidamente antes
- E) Esperar a radiografia

**3.** No caso 4, qual exame à beira-leito ajuda a buscar sangramento cavitário?
- A) Nenhum
- B) TC antes de qualquer conduta
- C) Ultrassom (FAST)
- D) Ressonância
- E) Endoscopia

**4.** No caso 4, qual a mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência?
- A) Abaixo de 5%
- B) Não há dados
- C) Cerca de 10%
- D) Acima de 40%
- E) Zero

**5.** No caso 4, o intraósseo foi obtido. Qual o papel dele?
- A) Só para medicação de parada
- B) Não serve no adulto
- C) Só para colher exames
- D) Só depois da TC
- E) Iniciar a ressuscitação; pode salvar vidas no choque

**6.** No caso 4, o ultrassom à beira-leito mostra afastamento da sínfise púbica. O que fazer?
- A) Ignorar: o ultrassom não avalia a bacia
- B) Aguardar a TC para colocar a cinta
- C) Manter a cinta pélvica e tratar como sangramento pélvico
- D) Retirar a cinta para radiografar
- E) Laparotomia imediata para tratar a bacia

**7.** No caso 4, um colega quer levar o paciente para a TC antes de qualquer resposta à reposição. O que considerar?
- A) TC sempre primeiro
- B) Não importa
- C) Esperar 2 horas
- D) A decisão depende da resposta à ressuscitação; paciente sem resposta não deve sair para a TC sem decisão do líder
- E) Alta da sala


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Sempre que houver trauma penetrante, independentemente do sangramento
- B) Em todo paciente com fratura de membro
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Apenas depois de obtida a radiografia de tórax
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 4, você faz o protocolo RUSH à beira-leito. Para que ele serve neste paciente?
- A) Substituir o controle do sangramento
- B) Deve ser feito dentro da TC
- C) Buscar a causa do choque sem sair da sala
- D) Definir a classe de choque pela tabela
- E) Só serve para pacientes estáveis

**3.** No caso 4, após a cinta e a reposição, a PA segue 80/50. Qual a decisão mais adequada?
- A) Suspender a reposição
- B) Dar alta para a enfermaria
- C) Controle do sangramento (centro cirúrgico ou radiologia intervencionista), conforme a fonte
- D) Observar na sala
- E) TC de corpo inteiro e aguardar

**4.** No caso 4, o FAST não mostra líquido livre e há suspeita de sangramento pélvico ativo. Qual o próximo passo mais adequado?
- A) Retirar a cinta para examinar a bacia
- B) Esperar o resultado do lactato
- C) Acionar cirurgia e radiologia intervencionista juntas
- D) Concluir que o FAST negativo exclui sangramento
- E) Laparotomia exploradora de rotina

**5.** No caso 4, a FC 136 e a PA baixa. O que dizer da tabela de classes de choque?
- A) Perfeitamente validada
- B) Só vale no idoso
- C) Define a conduta sozinha
- D) Inútil
- E) Útil como referência, mas com limitações metodológicas; não decidir por ela sozinha

**6.** No caso 4, o FAST-PLUS teve qual concordância com a TC para alargamento crítico da sínfise?
- A) Nenhum confirmado
- B) Metade confirmada
- C) Todos os casos confirmados na TC
- D) Não foi comparado
- E) Só 10% confirmados

**7.** No caso 4, por que não pinçar às cegas um sangramento profundo encontrado durante o exame?
- A) Porque é sempre ineficaz
- B) Porque atrasa a TC
- C) Não há motivo
- D) Risco de lesar nervos e criar novo trauma e sangramento
- E) Porque é proibido por lei


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Em todo paciente com fratura de membro
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 4, quem deve liderar e como?
- A) O cirurgião do trauma, com participação ativa, dada a gravidade
- B) Ninguém em particular
- C) O radiologista
- D) Um residente sem supervisão
- E) O SAMU

**3.** No caso 4, quais as opções para controlar o sangramento pélvico e abdominal?
- A) Só observação
- B) Só TC
- C) Alta
- D) Só reposição
- E) Centro cirúrgico ou radiologia intervencionista, conforme a fonte

**4.** No caso 4, qual o papel da TC de corpo inteiro neste paciente sem resposta à reposição?
- A) Não é prioridade antes do controle do sangramento
- B) Substitui o FAST
- C) Reduz a mortalidade comprovadamente
- D) Obrigatória antes da cirurgia
- E) Deve ser repetida a cada hora

**5.** No caso 4, na equipe, como organizar os procedimentos simultâneos?
- A) Sem organização
- B) O líder define antes quem faz cada procedimento
- C) Cada um escolhe na hora
- D) Esperar o assistente
- E) Um só faz todos

**6.** No caso 4, após cirurgia, o paciente volta hipotenso na UTI. Como pensar?
- A) Esperar a manhã
- B) Só fratura de fêmur
- C) Efeito da anestesia apenas
- D) Sangramento até prova em contrário; investigar lesão não identificada
- E) Normal

**7.** No caso 4, qual a mortalidade a esperar e qual a implicação para a equipe?
- A) Igual à de pacientes estáveis
- B) Não há dados
- C) Zero; não há urgência
- D) Abaixo de 5%; pode esperar
- E) Acima de 40%; exige os mais experientes e decisão rápida


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 4, ao discutir com residentes a avaliação ultrassonográfica, qual síntese das fontes é correta?
- A) Ultrassom sem utilidade no choque
- B) Ultrassom substitui a TC sempre
- C) Sensibilidade de 100% em todos os estudos
- D) RUSH sensível no instável e FAST-PLUS com alargamento pélvico confirmado na TC
- E) Não há estudos

**3.** No caso 4, um estudo de colaboração entre cirurgia e radiologia intervencionista mostrou sobrevida maior que a prevista. Como interpretar?
- A) Mostra pior desfecho
- B) Associação favorável num desenho observacional; apoia a integração, sem provar causa
- C) Só vale para trauma penetrante
- D) Sem relevância
- E) Prova causal definitiva

**4.** No caso 4, qual frase resume a doutrina do paciente em extremis?
- A) Esperar estabilizar para decidir
- B) Exposição primeiro
- C) ABCDE sem exceção
- D) A via aérea sempre primeiro
- E) A circulação tem precedência (CABDE) e os mais experientes conduzem

**5.** No caso 4, você revisa o protocolo. Que indicador captaria atraso neste tipo de paciente?
- A) Número de residentes
- B) Tempo de internação
- C) Tempo até o controle do sangramento
- D) Custo da cinta
- E) Número de radiografias

**6.** No caso 4, qual crítica faria a quem decide só pela tabela de classes de choque?
- A) A tabela é perfeita
- B) A comparação clássica teve viés e não há consenso sobre estabilidade
- C) Classes não existem
- D) Só a FC importa
- E) Só a PA importa

**7.** No caso 4, um residente pergunta sobre o acesso intraósseo no adulto em choque. Qual resposta das fontes?
- A) Só para crianças
- B) Contraindicado no adulto
- C) Sem papel no trauma
- D) Pode salvar vidas ao iniciar a ressuscitação quando a veia falha
- E) Só para colher sangue
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_4' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D+15

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 4.

**Caso 4.** Homem de 30 anos, motociclista, colisão contra poste. Chega pálido e sonolento. PA 78/50 medida manualmente, FC 136. Dor à palpação da bacia, sem sangramento externo. Duas tentativas de acesso venoso falharam. O ultrassom à beira-leito está disponível.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 4, o paciente está em choque grave. Qual a ordem da avaliação?
- A) Primeiro a história AMPLA
- B) Primeiro a TC
- C) Primeiro a radiografia
- D) Exposição antes de tudo
- E) A circulação tem precedência (CABDE)

**3.** No caso 4, há dor na bacia e choque. O que colocar imediatamente?
- A) Nada até a TC
- B) Sonda vesical
- C) Cinta pélvica
- D) Colar cervical apenas
- E) Torniquete na coxa

**4.** No caso 4, as veias falharam. Qual acesso usar?
- A) Intraósseo
- B) Nenhum até a TC
- C) Intramuscular
- D) Continuar tentando veia por muito tempo
- E) Oral

**5.** No caso 4, o paciente sonolento e pálido. A sonolência pode ser sinal de quê?
- A) Nada
- B) Só álcool
- C) Choque
- D) Boa evolução
- E) Só cansaço

**6.** No caso 4, o que mais define o prognóstico deste paciente?
- A) O número de exames
- B) A idade
- C) A alteração fisiológica
- D) A marca da moto
- E) O horário

**7.** No caso 4, a PA foi medida manualmente. Por quê?
- A) Por tradição
- B) Porque o automático não existe
- C) Porque o aparelho automático pode errar no choque
- D) Sem motivo
- E) Porque é mais rápido


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Apenas depois de obtida a radiografia de tórax
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 4, ao colocar a cinta pélvica, o que a doutrina recomenda?
- A) Colocá-la imediatamente nos pacientes de alto risco
- B) Não usar no choque
- C) Colocar só no centro cirúrgico
- D) Testar a bacia repetidamente antes
- E) Esperar a radiografia

**3.** No caso 4, qual exame à beira-leito ajuda a buscar sangramento cavitário?
- A) Nenhum
- B) TC antes de qualquer conduta
- C) Ultrassom (FAST)
- D) Ressonância
- E) Endoscopia

**4.** No caso 4, qual a mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência?
- A) Abaixo de 5%
- B) Não há dados
- C) Cerca de 10%
- D) Acima de 40%
- E) Zero

**5.** No caso 4, o intraósseo foi obtido. Qual o papel dele?
- A) Só para medicação de parada
- B) Não serve no adulto
- C) Só para colher exames
- D) Só depois da TC
- E) Iniciar a ressuscitação; pode salvar vidas no choque

**6.** No caso 4, o ultrassom à beira-leito mostra afastamento da sínfise púbica. O que fazer?
- A) Ignorar: o ultrassom não avalia a bacia
- B) Aguardar a TC para colocar a cinta
- C) Manter a cinta pélvica e tratar como sangramento pélvico
- D) Retirar a cinta para radiografar
- E) Laparotomia imediata para tratar a bacia

**7.** No caso 4, um colega quer levar o paciente para a TC antes de qualquer resposta à reposição. O que considerar?
- A) TC sempre primeiro
- B) Não importa
- C) Esperar 2 horas
- D) A decisão depende da resposta à ressuscitação; paciente sem resposta não deve sair para a TC sem decisão do líder
- E) Alta da sala


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Sempre que houver trauma penetrante, independentemente do sangramento
- B) Em todo paciente com fratura de membro
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Apenas depois de obtida a radiografia de tórax
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 4, você faz o protocolo RUSH à beira-leito. Para que ele serve neste paciente?
- A) Substituir o controle do sangramento
- B) Deve ser feito dentro da TC
- C) Buscar a causa do choque sem sair da sala
- D) Definir a classe de choque pela tabela
- E) Só serve para pacientes estáveis

**3.** No caso 4, após a cinta e a reposição, a PA segue 80/50. Qual a decisão mais adequada?
- A) Suspender a reposição
- B) Dar alta para a enfermaria
- C) Controle do sangramento (centro cirúrgico ou radiologia intervencionista), conforme a fonte
- D) Observar na sala
- E) TC de corpo inteiro e aguardar

**4.** No caso 4, o FAST não mostra líquido livre e há suspeita de sangramento pélvico ativo. Qual o próximo passo mais adequado?
- A) Retirar a cinta para examinar a bacia
- B) Esperar o resultado do lactato
- C) Acionar cirurgia e radiologia intervencionista juntas
- D) Concluir que o FAST negativo exclui sangramento
- E) Laparotomia exploradora de rotina

**5.** No caso 4, a FC 136 e a PA baixa. O que dizer da tabela de classes de choque?
- A) Perfeitamente validada
- B) Só vale no idoso
- C) Define a conduta sozinha
- D) Inútil
- E) Útil como referência, mas com limitações metodológicas; não decidir por ela sozinha

**6.** No caso 4, o FAST-PLUS teve qual concordância com a TC para alargamento crítico da sínfise?
- A) Nenhum confirmado
- B) Metade confirmada
- C) Todos os casos confirmados na TC
- D) Não foi comparado
- E) Só 10% confirmados

**7.** No caso 4, por que não pinçar às cegas um sangramento profundo encontrado durante o exame?
- A) Porque é sempre ineficaz
- B) Porque atrasa a TC
- C) Não há motivo
- D) Risco de lesar nervos e criar novo trauma e sangramento
- E) Porque é proibido por lei


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Em todo paciente com fratura de membro
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 4, quem deve liderar e como?
- A) O cirurgião do trauma, com participação ativa, dada a gravidade
- B) Ninguém em particular
- C) O radiologista
- D) Um residente sem supervisão
- E) O SAMU

**3.** No caso 4, quais as opções para controlar o sangramento pélvico e abdominal?
- A) Só observação
- B) Só TC
- C) Alta
- D) Só reposição
- E) Centro cirúrgico ou radiologia intervencionista, conforme a fonte

**4.** No caso 4, qual o papel da TC de corpo inteiro neste paciente sem resposta à reposição?
- A) Não é prioridade antes do controle do sangramento
- B) Substitui o FAST
- C) Reduz a mortalidade comprovadamente
- D) Obrigatória antes da cirurgia
- E) Deve ser repetida a cada hora

**5.** No caso 4, na equipe, como organizar os procedimentos simultâneos?
- A) Sem organização
- B) O líder define antes quem faz cada procedimento
- C) Cada um escolhe na hora
- D) Esperar o assistente
- E) Um só faz todos

**6.** No caso 4, após cirurgia, o paciente volta hipotenso na UTI. Como pensar?
- A) Esperar a manhã
- B) Só fratura de fêmur
- C) Efeito da anestesia apenas
- D) Sangramento até prova em contrário; investigar lesão não identificada
- E) Normal

**7.** No caso 4, qual a mortalidade a esperar e qual a implicação para a equipe?
- A) Igual à de pacientes estáveis
- B) Não há dados
- C) Zero; não há urgência
- D) Abaixo de 5%; pode esperar
- E) Acima de 40%; exige os mais experientes e decisão rápida


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Sempre que houver trauma penetrante, independentemente do sangramento
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 4, ao discutir com residentes a avaliação ultrassonográfica, qual síntese das fontes é correta?
- A) Ultrassom sem utilidade no choque
- B) Ultrassom substitui a TC sempre
- C) Sensibilidade de 100% em todos os estudos
- D) RUSH sensível no instável e FAST-PLUS com alargamento pélvico confirmado na TC
- E) Não há estudos

**3.** No caso 4, um estudo de colaboração entre cirurgia e radiologia intervencionista mostrou sobrevida maior que a prevista. Como interpretar?
- A) Mostra pior desfecho
- B) Associação favorável num desenho observacional; apoia a integração, sem provar causa
- C) Só vale para trauma penetrante
- D) Sem relevância
- E) Prova causal definitiva

**4.** No caso 4, qual frase resume a doutrina do paciente em extremis?
- A) Esperar estabilizar para decidir
- B) Exposição primeiro
- C) ABCDE sem exceção
- D) A via aérea sempre primeiro
- E) A circulação tem precedência (CABDE) e os mais experientes conduzem

**5.** No caso 4, você revisa o protocolo. Que indicador captaria atraso neste tipo de paciente?
- A) Número de residentes
- B) Tempo de internação
- C) Tempo até o controle do sangramento
- D) Custo da cinta
- E) Número de radiografias

**6.** No caso 4, qual crítica faria a quem decide só pela tabela de classes de choque?
- A) A tabela é perfeita
- B) A comparação clássica teve viés e não há consenso sobre estabilidade
- C) Classes não existem
- D) Só a FC importa
- E) Só a PA importa

**7.** No caso 4, um residente pergunta sobre o acesso intraósseo no adulto em choque. Qual resposta das fontes?
- A) Só para crianças
- B) Contraindicado no adulto
- C) Sem papel no trauma
- D) Pode salvar vidas ao iniciar a ressuscitação quando a veia falha
- E) Só para colher sangue
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A22', $af$A sobrevida no grupo com colaboração próxima entre radiologia intervencionista e cirurgia foi 15,5% maior que a prevista (IC 95% 7,5–23,6%).$af$, '2024_64', $af$the survival rate in the CG was 15.5% higher than the Ps (95% CI: 7.5–23.6%; p < 0.001)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A32', $af$A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés metodológico que superestimou a classe de choque dos parâmetros tradicionais.$af$, '2024_57', $af$caused a systematic overestimation of shock class for traditional ATLS parameters, favoring the association between BD and transfusion$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A33', $af$Revisão de 222 artigos: 67 elegíveis; a estabilidade hemodinâmica foi definida em 70% deles, sem consenso nos pontos de corte.$af$, '2017_15', $af$Out of a total of 222, 67 articles were found to be eligible for inclusion. HD stability was defined in 70% of these articles.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A34', $af$O RUSH teve sensibilidade de 94,2% no diagnóstico de politraumatizados instáveis.$af$, '2018_03', $af$RUSH had 94.2% sensitivity in the diagnosis of unstable polytrauma patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A35', $af$No FAST-PLUS, 7,5% dos pacientes tinham alargamento crítico da sínfise púbica.$af$, '2021_19', $af$5/67 patients (7.5%) with a critical pubic SW$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A39', $af$Em pacientes em choque circulatório, a TC de corpo inteiro não alterou a mortalidade precoce em 24 h (17,4% vs. 27,6%; p = 0,21).$af$, '2020_70', $af$no difference in early (24 h) mortality was observed (WBCT, 23 (17.4%) and no-WBCT, 8 (27.6%); p = 0.21)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D8', $af$O pinçamento às cegas de feridas profundas deve ser evitado.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Blind clamping of deep wounds is discouraged$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D9', $af$Nos pacientes de alto risco para sangramento pélvico, a cinta pélvica deve ser colocada imediatamente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a pelvic binder should be immediately placed in high-risk patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D14', $af$O medidor automático de pressão pode errar no paciente em choque; se for medir, medir manualmente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$noninvasive blood pressure devices may be erroneous in patients in shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D15', $af$Sem acesso venoso imediato, considerar o acesso intraósseo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$consideration should be made to perform intraosseous access$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D17', $af$Agitação e agressividade também são sinais clássicos de choque classe III e IV.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$generalized agitation and combativeness are also classic symptoms of class III and IV shock$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D26', $af$A alteração fisiológica é o maior determinante do desfecho.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$that is the greatest determinant of outcome$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D27', $af$A mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência passa de 40%.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the mortality rate of patients presenting with a systolic blood pressure of less than 90 mm Hg who require an emergent laparotomy is greater than 40%$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D28', $af$O acesso intraósseo para iniciar a ressuscitação pode salvar vidas no choque.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Initiating the resuscitation with intraosseous access can be lifesaving in patients in shock.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_4' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_4')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'teste_5', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_5'),0)+1, 'rascunho', $T1$Pós-teste D+45$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D+45

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 5.

**Caso 5.** Mulher de 41 anos, atropelada. Foi avaliada na sala de trauma, com avaliações primária e secundária sem alterações importantes, e fez TC de corpo inteiro, sem lesões. Foi internada para observação. No dia seguinte, refere dor no pé esquerdo e no ombro direito. À tarde, a PA cai para 88/56.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Em todo paciente com fratura de membro
- D) Apenas depois de obtida a radiografia de tórax
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 5, a TC foi normal. A dor nova pode ser uma lesão?
- A) Sim; lesões podem ser descobertas depois, mesmo com TC
- B) Só em crianças
- C) Não, a TC exclui tudo
- D) Só se houver febre
- E) Não importa

**3.** No caso 5, o que é a avaliação terciária?
- A) Um reexame completo depois da ressuscitação e das intervenções
- B) A primeira avaliação na sala
- C) A TC de corpo inteiro
- D) O exame do SAMU
- E) A alta

**4.** No caso 5, a PA caiu para 88/56. O que pensar primeiro?
- A) Nada
- B) Ansiedade
- C) Sono
- D) Sangramento até prova em contrário
- E) Desidratação

**5.** No caso 5, a família pergunta por que a lesão não apareceu na TC. Qual a explicação correta?
- A) Lesões podem ser descobertas depois mesmo com TC
- B) Não é preciso reexaminar
- C) Isso só acontece em crianças
- D) A lesão surgiu depois, sem relação com o atropelamento
- E) A TC vê todas as lesões

**6.** No caso 5, o que fazer com as imagens já feitas?
- A) Repetir todas sem revisar
- B) Ignorar
- C) Confiar só no primeiro laudo
- D) Revisá-las cuidadosamente na avaliação terciária
- E) Descartar

**7.** No caso 5, o exame físico achou dor no pé. Como valorizar o achado?
- A) Só valorizar se houver deformidade
- B) Só na alta
- C) Não valorizar
- D) Achados positivos quase sempre indicam lesão e exigem ação
- E) Ignorar sem imagem


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Apenas depois de obtida a radiografia de tórax
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Em todo paciente com fratura de membro

**2.** No caso 5, quando a avaliação terciária deveria ser feita?
- A) Depois da ressuscitação inicial e das intervenções
- B) Antes da primária
- C) Nunca
- D) Só na alta
- E) Só se a TC for anormal

**3.** No caso 5, qual a conduta diante da hipotensão?
- A) Dar só analgésico
- B) Alta
- C) Atribuir à dor
- D) Esperar a manhã
- E) Reavaliar como sangramento e procurar lesão não identificada

**4.** No caso 5, qual teste clínico tem especificidade de 99% para lesão de membro inferior?
- A) MIST
- B) AMPLA
- C) RUSH
- D) SILENT
- E) FAST

**5.** No caso 5, o SILENT negativo exclui lesão?
- A) Sim, se a TC for normal
- B) Sempre
- C) Sim
- D) Só no idoso
- E) Não; sensibilidade de 75%

**6.** No caso 5, a avaliação terciária foi feita no segundo dia e não achou nada. A dor no ombro surge no terceiro. O que fazer?
- A) Repetir a TC de corpo inteiro sem exame
- B) Ignorar, porque a terciária já foi feita
- C) Reexaminar e investigar
- D) Dar alta e reavaliar no ambulatório
- E) Atribuir à posição no leito sem examinar

**7.** No caso 5, quem atendeu a paciente na UTI deve fazer o quê?
- A) Nada
- B) Só repetir a TC
- C) Avaliação terciária e revisão das imagens
- D) Só prescrição
- E) Alta


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 5, qual a melhor explicação para a lesão só aparecer no dia seguinte?
- A) A TC sempre vê tudo
- B) Lesões ocultas são comuns e a TC não elimina o risco
- C) Erro grosseiro sempre
- D) Lesão nova sem relação com o trauma
- E) Simulação da paciente

**3.** No caso 5, hipotensão após ressuscitação. Qual armadilha evitar?
- A) Chamar o líder
- B) Revisar imagens
- C) Assumir que é por outra causa e ignorar o episódio
- D) Investigar sangramento
- E) Reexaminar

**4.** No caso 5, qual o desempenho do SILENT e o que isso implica?
- A) Inútil
- B) Ótimo para excluir
- C) Especificidade 75%
- D) Sensibilidade 75% e especificidade 99%: bom para confirmar, ruim para excluir
- E) Sensibilidade 99%

**5.** Ao revisar a indicação da TC no caso 5, qual argumento é sustentado pela evidência?
- A) A TC de rotina reduz a mortalidade de forma comprovada
- B) A TC deve ser repetida a cada 12 horas
- C) A TC dispensa a avaliação terciária
- D) Com primária sem alterações, a TC de corpo inteiro acrescentou pouco: 3,02% dos submetidos estavam nesse grupo e nenhum teve lesão na imagem
- E) A TC encontra lesão grave em metade desses pacientes

**6.** No caso 5, como reduzir a chance de nova lesão despercebida até a alta?
- A) Alta precoce
- B) Proibir queixas
- C) Nova TC de rotina sem exame
- D) Avaliação terciária, revisão de imagens e reexame ao surgirem queixas
- E) Nenhuma medida

**7.** No caso 5, a paciente estava acordada. Por que a terciária importa mais ainda nos intubados?
- A) Porque têm alta mais cedo
- B) Porque têm menos lesões
- C) Não importa
- D) Porque a TC é melhor neles
- E) Não se queixam e o exame neurológico fica indisponível


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Sempre que houver trauma penetrante, independentemente do sangramento
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 5, você revisa o caso com a equipe. Qual mensagem principal?
- A) Evitar internar
- B) Nada a aprender
- C) A sala de trauma e a TC não encerram o diagnóstico; a terciária é parte do atendimento
- D) A paciente simulou
- E) A TC basta

**3.** No caso 5, como conduzir o debriefing?
- A) Punindo o residente
- B) Só por escrito meses depois
- C) Com a equipe, logo após, focando no processo
- D) Não fazer
- E) Sem a equipe

**4.** No caso 5, qual dado sobre a TC de rotina ajuda a explicar o caso?
- A) Aumenta a mortalidade
- B) Pouco ou nenhum efeito em mortalidade e lesões tardias mesmo com ela
- C) Reduz lesões tardias a zero
- D) Dispensa a terciária
- E) Não há dados

**5.** No caso 5, qual indicador de qualidade acompanharia este problema?
- A) Tempo de passagem do SAMU
- B) Número de TCs
- C) Custo da TC
- D) Lesões de diagnóstico tardio
- E) Número de radiografias

**6.** No caso 5, hipotensão à tarde. Qual a primeira decisão do líder?
- A) Esperar o plantão seguinte
- B) Atribuir à dor
- C) Dar alta
- D) Suspender o soro
- E) Tratar como sangramento e investigar já

**7.** No caso 5, qual a proporção de lesões tardias após terciária, e o que implica?
- A) Não há dados
- B) 13,9 %: só depende da TC
- C) 26%: a terciária é inútil
- D) 0%: a terciária é infalível
- E) 0,26%: a vigilância continua depois da terciária


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Apenas depois de obtida a radiografia de tórax
- C) Em todo paciente com fratura de membro
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 5, como você explicaria os 13,9 % de lesões tardias mesmo com TC?
- A) A TC é inútil
- B) Estudo inválido
- C) Erro de leitura sempre
- D) Só em hospitais pequenos
- E) A TC não elimina lesões ocultas; exame seriado e revisão de imagens seguem necessários

**3.** No caso 5, o que a doutrina recomenda para o paciente de UTI?
- A) Avaliação terciária e revisão cuidadosa das imagens
- B) Alta precoce
- C) Nova TC diária
- D) Nada
- E) Só exames laboratoriais

**4.** No caso 5, o teste SILENT poderia substituir a imagem?
- A) Não há dados
- B) Sim, sempre
- C) Sim, nos idosos
- D) Sim, com especificidade de 75%
- E) Não para excluir lesão: sensibilidade de 75%

**5.** No caso 5, ao propor mudança de protocolo, qual seria a base mais sólida?
- A) Lesões tardias e lesões após terciária documentadas, apoiando reexame seriado
- B) Opinião isolada
- C) Preferência do residente
- D) Nenhuma
- E) Custo da TC

**6.** No caso 5, qual seria o papel de reavaliar a hipotensão tardia na auditoria?
- A) Identificar lesão não identificada ou ressangramento
- B) Nenhum
- C) Só para pesquisa
- D) Só multar
- E) Só registrar

**7.** No caso 5, você revisa o critério de TC de corpo inteiro do serviço. Qual proposta é coerente com as fontes?
- A) Tornar a TC universal porque reduz mortalidade
- B) Indicar só pela idade
- C) Indicar por critérios e manter a avaliação terciária
- D) Nunca fazer TC em atropelados
- E) TC para todos, dispensando a terciária
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_5' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D+45

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 5.

**Caso 5.** Mulher de 41 anos, atropelada. Foi avaliada na sala de trauma, com avaliações primária e secundária sem alterações importantes, e fez TC de corpo inteiro, sem lesões. Foi internada para observação. No dia seguinte, refere dor no pé esquerdo e no ombro direito. À tarde, a PA cai para 88/56.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Em todo paciente com fratura de membro
- D) Apenas depois de obtida a radiografia de tórax
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 5, a TC foi normal. A dor nova pode ser uma lesão?
- A) Sim; lesões podem ser descobertas depois, mesmo com TC
- B) Só em crianças
- C) Não, a TC exclui tudo
- D) Só se houver febre
- E) Não importa

**3.** No caso 5, o que é a avaliação terciária?
- A) Um reexame completo depois da ressuscitação e das intervenções
- B) A primeira avaliação na sala
- C) A TC de corpo inteiro
- D) O exame do SAMU
- E) A alta

**4.** No caso 5, a PA caiu para 88/56. O que pensar primeiro?
- A) Nada
- B) Ansiedade
- C) Sono
- D) Sangramento até prova em contrário
- E) Desidratação

**5.** No caso 5, a família pergunta por que a lesão não apareceu na TC. Qual a explicação correta?
- A) Lesões podem ser descobertas depois mesmo com TC
- B) Não é preciso reexaminar
- C) Isso só acontece em crianças
- D) A lesão surgiu depois, sem relação com o atropelamento
- E) A TC vê todas as lesões

**6.** No caso 5, o que fazer com as imagens já feitas?
- A) Repetir todas sem revisar
- B) Ignorar
- C) Confiar só no primeiro laudo
- D) Revisá-las cuidadosamente na avaliação terciária
- E) Descartar

**7.** No caso 5, o exame físico achou dor no pé. Como valorizar o achado?
- A) Só valorizar se houver deformidade
- B) Só na alta
- C) Não valorizar
- D) Achados positivos quase sempre indicam lesão e exigem ação
- E) Ignorar sem imagem


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Apenas depois de obtida a radiografia de tórax
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Em todo paciente com fratura de membro

**2.** No caso 5, quando a avaliação terciária deveria ser feita?
- A) Depois da ressuscitação inicial e das intervenções
- B) Antes da primária
- C) Nunca
- D) Só na alta
- E) Só se a TC for anormal

**3.** No caso 5, qual a conduta diante da hipotensão?
- A) Dar só analgésico
- B) Alta
- C) Atribuir à dor
- D) Esperar a manhã
- E) Reavaliar como sangramento e procurar lesão não identificada

**4.** No caso 5, qual teste clínico tem especificidade de 99% para lesão de membro inferior?
- A) MIST
- B) AMPLA
- C) RUSH
- D) SILENT
- E) FAST

**5.** No caso 5, o SILENT negativo exclui lesão?
- A) Sim, se a TC for normal
- B) Sempre
- C) Sim
- D) Só no idoso
- E) Não; sensibilidade de 75%

**6.** No caso 5, a avaliação terciária foi feita no segundo dia e não achou nada. A dor no ombro surge no terceiro. O que fazer?
- A) Repetir a TC de corpo inteiro sem exame
- B) Ignorar, porque a terciária já foi feita
- C) Reexaminar e investigar
- D) Dar alta e reavaliar no ambulatório
- E) Atribuir à posição no leito sem examinar

**7.** No caso 5, quem atendeu a paciente na UTI deve fazer o quê?
- A) Nada
- B) Só repetir a TC
- C) Avaliação terciária e revisão das imagens
- D) Só prescrição
- E) Alta


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Apenas depois de obtida a radiografia de tórax

**2.** No caso 5, qual a melhor explicação para a lesão só aparecer no dia seguinte?
- A) A TC sempre vê tudo
- B) Lesões ocultas são comuns e a TC não elimina o risco
- C) Erro grosseiro sempre
- D) Lesão nova sem relação com o trauma
- E) Simulação da paciente

**3.** No caso 5, hipotensão após ressuscitação. Qual armadilha evitar?
- A) Chamar o líder
- B) Revisar imagens
- C) Assumir que é por outra causa e ignorar o episódio
- D) Investigar sangramento
- E) Reexaminar

**4.** No caso 5, qual o desempenho do SILENT e o que isso implica?
- A) Inútil
- B) Ótimo para excluir
- C) Especificidade 75%
- D) Sensibilidade 75% e especificidade 99%: bom para confirmar, ruim para excluir
- E) Sensibilidade 99%

**5.** Ao revisar a indicação da TC no caso 5, qual argumento é sustentado pela evidência?
- A) A TC de rotina reduz a mortalidade de forma comprovada
- B) A TC deve ser repetida a cada 12 horas
- C) A TC dispensa a avaliação terciária
- D) Com primária sem alterações, a TC de corpo inteiro acrescentou pouco: 3,02% dos submetidos estavam nesse grupo e nenhum teve lesão na imagem
- E) A TC encontra lesão grave em metade desses pacientes

**6.** No caso 5, como reduzir a chance de nova lesão despercebida até a alta?
- A) Alta precoce
- B) Proibir queixas
- C) Nova TC de rotina sem exame
- D) Avaliação terciária, revisão de imagens e reexame ao surgirem queixas
- E) Nenhuma medida

**7.** No caso 5, a paciente estava acordada. Por que a terciária importa mais ainda nos intubados?
- A) Porque têm alta mais cedo
- B) Porque têm menos lesões
- C) Não importa
- D) Porque a TC é melhor neles
- E) Não se queixam e o exame neurológico fica indisponível


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Sempre que houver trauma penetrante, independentemente do sangramento
- B) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- C) Apenas depois de obtida a radiografia de tórax
- D) Em todo paciente com fratura de membro
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 5, você revisa o caso com a equipe. Qual mensagem principal?
- A) Evitar internar
- B) Nada a aprender
- C) A sala de trauma e a TC não encerram o diagnóstico; a terciária é parte do atendimento
- D) A paciente simulou
- E) A TC basta

**3.** No caso 5, como conduzir o debriefing?
- A) Punindo o residente
- B) Só por escrito meses depois
- C) Com a equipe, logo após, focando no processo
- D) Não fazer
- E) Sem a equipe

**4.** No caso 5, qual dado sobre a TC de rotina ajuda a explicar o caso?
- A) Aumenta a mortalidade
- B) Pouco ou nenhum efeito em mortalidade e lesões tardias mesmo com ela
- C) Reduz lesões tardias a zero
- D) Dispensa a terciária
- E) Não há dados

**5.** No caso 5, qual indicador de qualidade acompanharia este problema?
- A) Tempo de passagem do SAMU
- B) Número de TCs
- C) Custo da TC
- D) Lesões de diagnóstico tardio
- E) Número de radiografias

**6.** No caso 5, hipotensão à tarde. Qual a primeira decisão do líder?
- A) Esperar o plantão seguinte
- B) Atribuir à dor
- C) Dar alta
- D) Suspender o soro
- E) Tratar como sangramento e investigar já

**7.** No caso 5, qual a proporção de lesões tardias após terciária, e o que implica?
- A) Não há dados
- B) 13,9 %: só depende da TC
- C) 26%: a terciária é inútil
- D) 0%: a terciária é infalível
- E) 0,26%: a vigilância continua depois da terciária


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Somente quando o Glasgow é menor ou igual a 8
- B) Apenas depois de obtida a radiografia de tórax
- C) Em todo paciente com fratura de membro
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 5, como você explicaria os 13,9 % de lesões tardias mesmo com TC?
- A) A TC é inútil
- B) Estudo inválido
- C) Erro de leitura sempre
- D) Só em hospitais pequenos
- E) A TC não elimina lesões ocultas; exame seriado e revisão de imagens seguem necessários

**3.** No caso 5, o que a doutrina recomenda para o paciente de UTI?
- A) Avaliação terciária e revisão cuidadosa das imagens
- B) Alta precoce
- C) Nova TC diária
- D) Nada
- E) Só exames laboratoriais

**4.** No caso 5, o teste SILENT poderia substituir a imagem?
- A) Não há dados
- B) Sim, sempre
- C) Sim, nos idosos
- D) Sim, com especificidade de 75%
- E) Não para excluir lesão: sensibilidade de 75%

**5.** No caso 5, ao propor mudança de protocolo, qual seria a base mais sólida?
- A) Lesões tardias e lesões após terciária documentadas, apoiando reexame seriado
- B) Opinião isolada
- C) Preferência do residente
- D) Nenhuma
- E) Custo da TC

**6.** No caso 5, qual seria o papel de reavaliar a hipotensão tardia na auditoria?
- A) Identificar lesão não identificada ou ressangramento
- B) Nenhum
- C) Só para pesquisa
- D) Só multar
- E) Só registrar

**7.** No caso 5, você revisa o critério de TC de corpo inteiro do serviço. Qual proposta é coerente com as fontes?
- A) Tornar a TC universal porque reduz mortalidade
- B) Indicar só pela idade
- C) Indicar por critérios e manter a avaliação terciária
- D) Nunca fazer TC em atropelados
- E) TC para todos, dispensando a terciária
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A40', $af$Entre 3976 pacientes com TC de corpo inteiro, 120 (3,02%) tinham avaliação primária sem alterações e nenhum teve lesão à imagem.$af$, '2024_48', $af$From 3976 patients treated with WBCT, 120 patients (3.02%) showed an inconspicuous primary survey.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A41', $af$Apesar do algoritmo da sala de trauma, lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos pacientes graves.$af$, '2022_17', $af$In seven patients (0.26%; mean age 50.4 years, range 18–90; mean ISS 39.7, range 34–50), a life-threatening injury occurred in the further course$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A42', $af$Mesmo com TC de corpo inteiro na avaliação primária, houve lesões com diagnóstico tardio em 13,9 % dos pacientes.$af$, '2024_16', $af$Delayed diagnosed injuries were found in 97 patients (13.9 %)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A43', $af$O teste SILENT (membro inferior) teve sensibilidade de 75% (IC 95% 64 a 84%) e especificidade de 99% (IC 95% 97 a 100%).$af$, '2024_11', $af$Overall sensitivity was 75% (95%CI 64 to 84%), and overall specificity was 99% (95%CI 97 to 100%).$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D25', $af$O exame físico tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave e exigem ação.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$positive findings are almost always secondary to serious injuries and should be acted upon$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D30', $af$No paciente de UTI, a avaliação terciária e a revisão cuidadosa das imagens reduzem o risco de lesão não identificada.$af$, 'Mattox9_cap57_uti', $af$Trauma patients in the ICU should undergo a tertiary survey and careful review of imaging results to reduce the risk of missed injury.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D31', $af$A avaliação terciária deve ser feita depois de completadas a ressuscitação inicial e as intervenções cirúrgicas.$af$, 'Mattox9_cap44_membro_inferior', $af$A “tertiary survey” should be completed after the initial resuscitation and operative interventions are complete$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D32', $af$A hipotensão após a ressuscitação é sangramento até prova em contrário.$af$, 'Mattox9_cap57_uti', $af$Any patient developing hypotension postresuscitation is bleeding until proven otherwise$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_5' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_5')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'teste_6', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_6'),0)+1, 'rascunho', $T1$Pós-teste D+90$T1$, $T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D+90

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 6.

**Caso 6.** Sábado à noite. O SAMU avisa que dois pacientes de um mesmo acidente chegarão em 10 minutos: um motorista consciente com sangramento em antebraço e um passageiro inconsciente. Na sala estão um R1, um R2, um R3, dois enfermeiros e o cirurgião assistente.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Em todo paciente com fratura de membro
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 6, o que a equipe deve fazer antes de os pacientes chegarem?
- A) Ir tomar café
- B) Esperar para ver quem chega
- C) Definir funções e preparar o material
- D) Nada
- E) Pedir TC para os dois

**3.** No caso 6, o motorista sangra no antebraço. Qual a primeira medida?
- A) TC
- B) Compressão direta
- C) AMPLA
- D) Radiografia
- E) Intubação

**4.** No caso 6, o passageiro está inconsciente. O que avaliar logo na via aérea?
- A) Se a via aérea está pérvia e se o Glasgow indica via aérea definitiva
- B) Só a temperatura
- C) Só a pressão
- D) Só a cor da pele
- E) Nada

**5.** No caso 6, quem deve ser o líder?
- A) O enfermeiro
- B) Ninguém
- C) Quem chegar primeiro
- D) O SAMU
- E) O cirurgião do trauma

**6.** No caso 6, como o SAMU deve passar o caso?
- A) Só para o enfermeiro
- B) Não passar
- C) De forma estruturada e curta
- D) Por escrito depois
- E) Livre e longa

**7.** No caso 6, depois do exame, o que fazer com os pacientes despidos?
- A) Aquecê-los
- B) Banho frio
- C) Nada
- D) Deixá-los descobertos
- E) Esperar a TC


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Apenas depois de obtida a radiografia de tórax
- E) Em todo paciente com fratura de membro

**2.** No caso 6, o R1 pergunta se pode liderar o atendimento do motorista. Qual a resposta?
- A) Sim, sozinho
- B) Só no próximo ano
- C) Sim, sob supervisão próxima do assistente
- D) Não, nunca
- E) Só se o assistente sair

**3.** No caso 6, o formulário de admissão do trauma foi associado a quê?
- A) Melhora de indicadores, como o registro da via aérea
- B) Mais tempo de sala
- C) Nenhum efeito
- D) Piora dos indicadores
- E) Mais mortes

**4.** No caso 6, o assistente sugere orientar por telefone, de fora da sala. O que a evidência indica?
- A) Ele deve estar presente: a presença do cirurgião de trauma encurtou a ressuscitação em 259 segundos
- B) Deixar o R1 liderar sozinho
- C) O telefone é equivalente
- D) Liderar da porta, sem ver o paciente
- E) Só chamá-lo se houver parada

**5.** No caso 6, o passageiro tem Glasgow 6. O que fazer antes de sedar para intubar?
- A) AMPLA
- B) Exame neurológico breve e completo
- C) Nada
- D) TC
- E) Alta

**6.** No caso 6, quais elementos do MIST o SAMU deve trazer?
- A) Nenhum
- B) Só sinais vitais
- C) Nome, endereço, telefone
- D) Só mecanismo
- E) Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos

**7.** No caso 6, em equipe, a avaliação deve ser feita em sequência rígida por uma pessoa?
- A) Só à noite
- B) Sim, sempre
- C) Não há regra
- D) Não; boa parte pode ser feita simultaneamente
- E) Só com dois pacientes


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Apenas depois de obtida a radiografia de tórax
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 6, o líder cirurgião foi associado a quê em meta-análise?
- A) Mais mortes
- B) Sobrevida muito maior
- C) Mais lesões perdidas
- D) Nada
- E) Menos lesões não identificadas, sobrevida semelhante

**3.** No caso 6, o checklist na ressuscitação foi associado a quê?
- A) Prova de menor mortalidade por ensaio
- B) Menos pneumonia comprovada
- C) Pior adesão
- D) Nada
- E) Melhor adesão ao ATLS e ao fluxo; evidência antes-e-depois

**4.** No caso 6, treinamento de equipe por simulação mostrou qual efeito?
- A) Só satisfação
- B) Mais erros
- C) Nenhum
- D) Redução do tempo até exames, tomografia e hemostasia
- E) Aumento do tempo

**5.** No caso 6, qual a ordem para o motorista com sangramento controlado e falando?
- A) Só tratar o braço
- B) Seguir ABCDE, reavaliando o sangramento
- C) Intubar
- D) Alta
- E) TC sem avaliação

**6.** No caso 6, o passageiro chega hipotenso e em extremis. Qual a prioridade?
- A) TC
- B) AMPLA
- C) Exposição
- D) Radiografia
- E) Circulação (CABDE), com os mais experientes

**7.** No caso 6, onde o líder deve ficar?
- A) De costas
- B) No posto
- C) Com visão de toda a sala
- D) Fora da sala
- E) Na via aérea


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Em todo paciente com fratura de membro
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 6, você lidera. Como distribuir a equipe entre os dois pacientes?
- A) Sem distribuição
- B) Só o R1 nos dois
- C) Funções definidas antes da chegada, com o mais experiente no paciente mais grave
- D) Todos no primeiro que chegar
- E) Esperar o terceiro paciente

**3.** No caso 6, a OMS tem um checklist de cuidado ao trauma. O que favorece sua implantação?
- A) Nada
- B) Campeão institucional, adaptação ao contexto e integração à rotina e à documentação
- C) Só distribuir o papel
- D) Usar só em auditorias
- E) Imposição sem treinamento

**4.** No caso 6, após os atendimentos, qual a melhor prática de equipe?
- A) Debriefing e treinamento in situ periódico
- B) Punição de erros
- C) Trocar a equipe
- D) Nada
- E) Só relatório escrito

**5.** No caso 6, um R2 quer pedir TC de corpo inteiro para os dois de rotina. O que dizer?
- A) Só pedir para o mais jovem
- B) Pedir antes da primária
- C) Sempre pedir
- D) Nunca pedir
- E) A TC de rotina tem pouco ou nenhum efeito em mortalidade; indicar por critérios

**6.** Depois do caso 6, o serviço quer treinar toda a equipe. Qual argumento sobre o ATLS é correto ao planejar o orçamento?
- A) Treinar não tem efeito, então não vale treinar
- B) É gratuito
- C) Tem benefício comprovado por ensaio, o que justifica qualquer custo
- D) É o programa de maior custo (USD 1433,5), e o benefício em mortalidade vem de estudos observacionais
- E) Custa o mesmo que programas para leigos

**7.** No caso 6, qual efeito da presença do cirurgião de trauma no tempo de ressuscitação?
- A) Nenhum
- B) 259 segundos a menos
- C) Mais tempo
- D) Não há dados
- E) Dobro do tempo


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Em todo paciente com fratura de membro
- D) Apenas depois de obtida a radiografia de tórax
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 6, você vai ensinar a equipe. Qual formato de treino in situ é equivalente no curto prazo?
- A) Nenhum funciona
- B) Só aula teórica
- C) Só algoritmo funciona
- D) Por checklist ou por algoritmo, com ganhos semelhantes
- E) Só checklist funciona

**3.** No caso 6, como explicar ao serviço o valor de ter o cirurgião como líder?
- A) Nenhum valor
- B) Mais custo sem benefício comprovado algum
- C) Menos lesões não identificadas, sem diferença de sobrevida
- D) Mais lesões perdidas
- E) Sobrevida muito maior

**4.** No caso 6, qual a evidência sobre o formulário de admissão e a mortalidade?
- A) Redução comprovada em todos os pacientes de centros de trauma de alta complexidade
- B) Nenhum dado de mortalidade
- C) Queda de 17,7% para 12,1% nos pacientes com fisiologia alterada, em ensaio randomizado por conglomerados em hospitais não terciários de Gana
- D) Queda para zero
- E) Aumento de mortalidade

**5.** No caso 6, como você propõe avaliar o ATLS no seu serviço, dada a evidência?
- A) Medir desfechos e processo, sabendo que falta evidência de alta qualidade
- B) Assumir benefício comprovado
- C) Nada
- D) Só medir custo
- E) Abandonar o treinamento

**6.** Após o caso 6, você quer estudar o efeito do treinamento no seu serviço. Que desenho as fontes mostram ser viável e mais informativo?
- A) Comparar com dados de outro país sem ajuste
- B) Só pesquisa de opinião
- C) Antes-e-depois sem controle, que já basta
- D) Nenhum estudo é possível
- E) Ensaio randomizado por conglomerados, com viabilidade testada em piloto

**7.** No caso 6, qual seria a principal lacuna a explicar aos residentes sobre checklists?
- A) Só há estudos antes-e-depois, com sinais mistos de benefício e dano
- B) Não há estudos
- C) Ensaios definitivos já existem
- D) Só há benefício
- E) Só há dano
$T1$, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='teste_6' AND a.corpo=$T1$> RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico). [H#] = histórico (camada 1); [D#] = livro-texto: Mattox, Trauma 9ª ed., e ATLS vigente (camada 2); [P#] = protocolo institucional da UE-HCFMRP (camada 3); [A#] = artigo da revisão (camada 4); [G#] = diretriz (camada 5). Casos e dados de pacientes são fictícios.

# T001 — Pós-teste D+90

Tempo estimado: 10 a 15 minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do caso 6.

**Caso 6.** Sábado à noite. O SAMU avisa que dois pacientes de um mesmo acidente chegarão em 10 minutos: um motorista consciente com sangramento em antebraço e um passageiro inconsciente. Na sala estão um R1, um R2, um R3, dois enfermeiros e o cirurgião assistente.


## Perfil Graduação

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Somente quando o Glasgow é menor ou igual a 8
- C) Em todo paciente com fratura de membro
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 6, o que a equipe deve fazer antes de os pacientes chegarem?
- A) Ir tomar café
- B) Esperar para ver quem chega
- C) Definir funções e preparar o material
- D) Nada
- E) Pedir TC para os dois

**3.** No caso 6, o motorista sangra no antebraço. Qual a primeira medida?
- A) TC
- B) Compressão direta
- C) AMPLA
- D) Radiografia
- E) Intubação

**4.** No caso 6, o passageiro está inconsciente. O que avaliar logo na via aérea?
- A) Se a via aérea está pérvia e se o Glasgow indica via aérea definitiva
- B) Só a temperatura
- C) Só a pressão
- D) Só a cor da pele
- E) Nada

**5.** No caso 6, quem deve ser o líder?
- A) O enfermeiro
- B) Ninguém
- C) Quem chegar primeiro
- D) O SAMU
- E) O cirurgião do trauma

**6.** No caso 6, como o SAMU deve passar o caso?
- A) Só para o enfermeiro
- B) Não passar
- C) De forma estruturada e curta
- D) Por escrito depois
- E) Livre e longa

**7.** No caso 6, depois do exame, o que fazer com os pacientes despidos?
- A) Aquecê-los
- B) Banho frio
- C) Nada
- D) Deixá-los descobertos
- E) Esperar a TC


## Perfil R1

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Apenas depois de obtida a radiografia de tórax
- E) Em todo paciente com fratura de membro

**2.** No caso 6, o R1 pergunta se pode liderar o atendimento do motorista. Qual a resposta?
- A) Sim, sozinho
- B) Só no próximo ano
- C) Sim, sob supervisão próxima do assistente
- D) Não, nunca
- E) Só se o assistente sair

**3.** No caso 6, o formulário de admissão do trauma foi associado a quê?
- A) Melhora de indicadores, como o registro da via aérea
- B) Mais tempo de sala
- C) Nenhum efeito
- D) Piora dos indicadores
- E) Mais mortes

**4.** No caso 6, o assistente sugere orientar por telefone, de fora da sala. O que a evidência indica?
- A) Ele deve estar presente: a presença do cirurgião de trauma encurtou a ressuscitação em 259 segundos
- B) Deixar o R1 liderar sozinho
- C) O telefone é equivalente
- D) Liderar da porta, sem ver o paciente
- E) Só chamá-lo se houver parada

**5.** No caso 6, o passageiro tem Glasgow 6. O que fazer antes de sedar para intubar?
- A) AMPLA
- B) Exame neurológico breve e completo
- C) Nada
- D) TC
- E) Alta

**6.** No caso 6, quais elementos do MIST o SAMU deve trazer?
- A) Nenhum
- B) Só sinais vitais
- C) Nome, endereço, telefone
- D) Só mecanismo
- E) Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos

**7.** No caso 6, em equipe, a avaliação deve ser feita em sequência rígida por uma pessoa?
- A) Só à noite
- B) Sim, sempre
- C) Não há regra
- D) Não; boa parte pode ser feita simultaneamente
- E) Só com dois pacientes


## Perfil R2

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Em todo paciente com fratura de membro
- B) Apenas depois de obtida a radiografia de tórax
- C) Sempre que houver trauma penetrante, independentemente do sangramento
- D) Somente quando o Glasgow é menor ou igual a 8
- E) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis

**2.** No caso 6, o líder cirurgião foi associado a quê em meta-análise?
- A) Mais mortes
- B) Sobrevida muito maior
- C) Mais lesões perdidas
- D) Nada
- E) Menos lesões não identificadas, sobrevida semelhante

**3.** No caso 6, o checklist na ressuscitação foi associado a quê?
- A) Prova de menor mortalidade por ensaio
- B) Menos pneumonia comprovada
- C) Pior adesão
- D) Nada
- E) Melhor adesão ao ATLS e ao fluxo; evidência antes-e-depois

**4.** No caso 6, treinamento de equipe por simulação mostrou qual efeito?
- A) Só satisfação
- B) Mais erros
- C) Nenhum
- D) Redução do tempo até exames, tomografia e hemostasia
- E) Aumento do tempo

**5.** No caso 6, qual a ordem para o motorista com sangramento controlado e falando?
- A) Só tratar o braço
- B) Seguir ABCDE, reavaliando o sangramento
- C) Intubar
- D) Alta
- E) TC sem avaliação

**6.** No caso 6, o passageiro chega hipotenso e em extremis. Qual a prioridade?
- A) TC
- B) AMPLA
- C) Exposição
- D) Radiografia
- E) Circulação (CABDE), com os mais experientes

**7.** No caso 6, onde o líder deve ficar?
- A) De costas
- B) No posto
- C) Com visão de toda a sala
- D) Fora da sala
- E) Na via aérea


## Perfil R3

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Apenas depois de obtida a radiografia de tórax
- B) Em todo paciente com fratura de membro
- C) Somente quando o Glasgow é menor ou igual a 8
- D) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- E) Sempre que houver trauma penetrante, independentemente do sangramento

**2.** No caso 6, você lidera. Como distribuir a equipe entre os dois pacientes?
- A) Sem distribuição
- B) Só o R1 nos dois
- C) Funções definidas antes da chegada, com o mais experiente no paciente mais grave
- D) Todos no primeiro que chegar
- E) Esperar o terceiro paciente

**3.** No caso 6, a OMS tem um checklist de cuidado ao trauma. O que favorece sua implantação?
- A) Nada
- B) Campeão institucional, adaptação ao contexto e integração à rotina e à documentação
- C) Só distribuir o papel
- D) Usar só em auditorias
- E) Imposição sem treinamento

**4.** No caso 6, após os atendimentos, qual a melhor prática de equipe?
- A) Debriefing e treinamento in situ periódico
- B) Punição de erros
- C) Trocar a equipe
- D) Nada
- E) Só relatório escrito

**5.** No caso 6, um R2 quer pedir TC de corpo inteiro para os dois de rotina. O que dizer?
- A) Só pedir para o mais jovem
- B) Pedir antes da primária
- C) Sempre pedir
- D) Nunca pedir
- E) A TC de rotina tem pouco ou nenhum efeito em mortalidade; indicar por critérios

**6.** Depois do caso 6, o serviço quer treinar toda a equipe. Qual argumento sobre o ATLS é correto ao planejar o orçamento?
- A) Treinar não tem efeito, então não vale treinar
- B) É gratuito
- C) Tem benefício comprovado por ensaio, o que justifica qualquer custo
- D) É o programa de maior custo (USD 1433,5), e o benefício em mortalidade vem de estudos observacionais
- E) Custa o mesmo que programas para leigos

**7.** No caso 6, qual efeito da presença do cirurgião de trauma no tempo de ressuscitação?
- A) Nenhum
- B) 259 segundos a menos
- C) Mais tempo
- D) Não há dados
- E) Dobro do tempo


## Perfil R+

**1.** Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?
- A) Na hemorragia externa ou compressível com risco de vida e no paciente em extremis
- B) Sempre que houver trauma penetrante, independentemente do sangramento
- C) Em todo paciente com fratura de membro
- D) Apenas depois de obtida a radiografia de tórax
- E) Somente quando o Glasgow é menor ou igual a 8

**2.** No caso 6, você vai ensinar a equipe. Qual formato de treino in situ é equivalente no curto prazo?
- A) Nenhum funciona
- B) Só aula teórica
- C) Só algoritmo funciona
- D) Por checklist ou por algoritmo, com ganhos semelhantes
- E) Só checklist funciona

**3.** No caso 6, como explicar ao serviço o valor de ter o cirurgião como líder?
- A) Nenhum valor
- B) Mais custo sem benefício comprovado algum
- C) Menos lesões não identificadas, sem diferença de sobrevida
- D) Mais lesões perdidas
- E) Sobrevida muito maior

**4.** No caso 6, qual a evidência sobre o formulário de admissão e a mortalidade?
- A) Redução comprovada em todos os pacientes de centros de trauma de alta complexidade
- B) Nenhum dado de mortalidade
- C) Queda de 17,7% para 12,1% nos pacientes com fisiologia alterada, em ensaio randomizado por conglomerados em hospitais não terciários de Gana
- D) Queda para zero
- E) Aumento de mortalidade

**5.** No caso 6, como você propõe avaliar o ATLS no seu serviço, dada a evidência?
- A) Medir desfechos e processo, sabendo que falta evidência de alta qualidade
- B) Assumir benefício comprovado
- C) Nada
- D) Só medir custo
- E) Abandonar o treinamento

**6.** Após o caso 6, você quer estudar o efeito do treinamento no seu serviço. Que desenho as fontes mostram ser viável e mais informativo?
- A) Comparar com dados de outro país sem ajuste
- B) Só pesquisa de opinião
- C) Antes-e-depois sem controle, que já basta
- D) Nenhum estudo é possível
- E) Ensaio randomizado por conglomerados, com viabilidade testada em piloto

**7.** No caso 6, qual seria a principal lacuna a explicar aos residentes sobre checklists?
- A) Só há estudos antes-e-depois, com sinais mistos de benefício e dano
- B) Não há estudos
- C) Ensaios definitivos já existem
- D) Só há benefício
- E) Só há dano
$T1$);
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A2', $af$Programas de treinamento em suporte de vida no trauma associaram-se a menor mortalidade (OR 0,60; IC 95% 0,48–0,75), mas a evidência é observacional.$af$, '2026_24', $af$Trauma life support training programmes were associated with reduced mortality at an odds ratio of 0.60 (95% CI 0.48–0.75)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A3', $af$Estudo piloto de viabilidade de ensaio randomizado por conglomerados (ATLS, PTC e cuidado padrão) incluiu 376 pacientes e 22 residentes.$af$, '2025_36', $af$We included 376 patients and 22 residents.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A4', $af$Os autores afirmam que não há evidência de alta qualidade de que o ATLS melhore desfechos de pacientes, motivando um novo ensaio pragmático.$af$, '2026_26', $af$there is no high-quality evidence that it can improve patient outcomes$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A6', $af$O custo de implementação de programas de treinamento variou de USD 3,70 (primeiro respondedor leigo) a USD 1433,5 (ATLS).$af$, '2026_42', $af$starting from USD 3.70 (Lay-First-Responder) to USD 1433.5 (Advanced Trauma Life Support)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A7', $af$A revisão sistemática sobre checklist na ressuscitação identificou 625 artigos e incluiu apenas estudos do tipo antes-e-depois.$af$, '2020_27', $af$Three of the 625 identified articles were included, which all used a before-and-after study design$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A8', $af$O uso de checklist pode melhorar a adesão ao ATLS e o fluxo de trabalho durante a ressuscitação do trauma.$af$, '2020_27', $af$The application of a checklist may improve ATLS adherence and workflow during trauma resuscitation.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A9', $af$Em um estudo, houve menor mortalidade no grupo mais grave (ISS > 25, aOR 0,51; IC 95% 0,30–0,89) com checklist.$af$, '2020_27', $af$Reduced mortality rates were found in the most severely injured patient group (Injury Severity score > 25, aOR 0.51, 95% CI 0.30–0.89)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A10', $af$Um estudo mostrou maior incidência de pneumonia no grupo com checklist (aOR 1,69; IC 95% 1,03–2,80).$af$, '2020_27', $af$the incidence of pneumonia was higher in the group where a checklist was applied [adjusted odds ratio (aOR) 1.69, 95% Confidence Interval (CI 1.03–2.80)]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A12', $af$A TC de corpo inteiro de rotina parece ter pouco ou nenhum efeito na redução da mortalidade e do tempo na sala de emergência.$af$, '2023_62', $af$The use of routine WBCT seems to offer little to no effects in reducing mortality and time spent in emergency room or department$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A13', $af$Após o formulário de admissão do trauma (TIF), houve melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial.$af$, '2023_60', $af$There was improvement in 14 of 16 primary survey and initial care KPIs after TIF introduction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A14', $af$A avaliação das vias aéreas subiu de 72,9% para 98,4% após a introdução do TIF.$af$, '2023_60', $af$Airway assessment increased from 72.9 to 98.4 per cent$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A15', $af$A mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada na chegada.$af$, '2023_60', $af$The mortality rate decreased from 17.7 to 12.1 per cent among 302 patients$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A16', $af$O uso do WHO Trauma Care Checklist foi favorecido por campeão institucional, adaptação ao contexto e integração às rotinas e à documentação.$af$, '2020_40', $af$Presence of an institutional champion, context-specific adaptation, and integration of the TCC with existing care and documentation practices contribute to successful utilization.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A17', $af$O treinamento de equipe por simulação pode reduzir o tempo até exames de sangue, tomografia e hemostasia.$af$, '2018_23', $af$Simulation team training could help reduce time to blood routine reports, scans and hemostasis.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A18', $af$Treinamento mensal em equipe, in situ, com debriefing em vídeo reduziu significativamente o tempo de ressuscitação na sala de emergência.$af$, '2018_55', $af$Monthly video assisted team based in situ training with video debriefing significantly reduces resuscitation time in the emergency bay.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A19', $af$Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi 259 segundos menor (p = 0,03).$af$, '2022_65', $af$the mean total resuscitation time was 259 seconds shorter (p = 0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A20', $af$Meta-análise de coortes retrospectivas: sem diferença de sobrevida entre líder cirurgião e não cirurgião (OR 0,82; IC 95% 0,61-1,10).$af$, '2017_75', $af$no difference in survival [odds ratio (OR): 0.82, 95% confidence interval (CI) 0.61-1.10, P=0.19]$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A21', $af$Houve menos lesões não identificadas quando a equipe era liderada por cirurgião (OR 0,48; IC 95% 0,25-0,92).$af$, '2017_75', $af$fewer injuries were missed when the trauma team was led by a surgeon (OR: 0.48, 95% CI 0.25-0.92, P=0.03)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A44', $af$Treinamento in situ baseado em checklist e baseado em algoritmo produziu ganhos de curto prazo semelhantes nos modelos mentais compartilhados da equipe.$af$, '2026_10', $af$Checklist- and algorithm-based formats produced similar short-term gains.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A45', $af$O estudo do formulário de admissão (TIF) foi um ensaio randomizado por conglomerados (stepped-wedge) em oito hospitais não terciários de Gana.$af$, '2023_60', $af$A stepped-wedge cluster randomized trial was conducted by stationing research assistants at emergency units of eight nontertiary hospitals$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'A46', $af$A redução de mortalidade com o TIF foi no subgrupo com fisiologia alterada na chegada (OR ajustado 0,10; intervalo 0,02 a 0,56).$af$, '2023_60', $af$(adjusted OR 0.10, 0.02 to 0.56; P = 0.009)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D1', $af$O objetivo da avaliação inicial é identificar e tratar rapidamente as lesões que ameaçam a vida.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$The goal of the initial assessment is the rapid identification and treatment of life-threatening injuries.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D2', $af$Na hemorragia externa ou compressível com risco de vida, e no paciente em extremis, a circulação é avaliada e tratada antes da via aérea (CAB).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$circulation evaluation and treatment will come before airway (ie, CAB [circulation, airway, breathing])$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D3', $af$No paciente que chega em extremis, a circulação tem precedência (CABDE).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$where circulation takes precedence (ie, CABDE)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D5', $af$Embora ensinada passo a passo, boa parte da avaliação primária pode ser feita simultaneamente.$af$, 'Mattox9_cap10_pre_hospitalar', $af$many aspects of this evaluation can be done simultaneously$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D6', $af$O sangramento externo ativo é tratado primeiro com compressão direta.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Treatment for active external bleeding identified through these exams should begin with direct pressure.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D10', $af$O paciente que fala com voz normal não tem obstrução de via aérea.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a patient who is able to speak in his or her normal voice does not have airway obstruction$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D11', $af$A via aérea deve ser assegurada no paciente com alteração importante do nível de consciência (Glasgow ≤8).$af$, 'Mattox9_cap13_avaliacao_inicial', $af$Airway stabilization should also be performed in the patient with a significant alteration in mental status (Glasgow Coma Scale [GCS] score ≤8)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D12', $af$Antes da sedação e do bloqueio neuromuscular, faz-se um exame neurológico breve e completo.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$a brief but thorough neurologic exam should be performed prior to the administration of paralytics and sedation$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D19', $af$Terminado o exame, manter o paciente aquecido é prioridade: mantas aquecidas, manta de ar forçado e fluidos aquecidos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$warm blankets, forced hot air blankets, and warm intravenous fluids$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D22', $af$No centro de trauma, o líder da equipe deve ser o cirurgião do trauma.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$In a trauma center, this should be the trauma surgeon.$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D23', $af$A passagem do pré-hospitalar segue um formato estruturado, como o MIST: mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$MIST (mechanism, injuries suspected, vital signs and symptoms, treatments)$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D24', $af$A passagem do pré-hospitalar não deve durar mais que 45 segundos a 1 minuto.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$the prehospital report should not take more than 45 seconds to 1 minute$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, 'D29', $af$Treinandos podem liderar a equipe sob supervisão próxima do assistente.$af$, 'Mattox9_cap13_avaliacao_inicial', $af$opportunities should be made for them to be team leader under the close supervision of the attending$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='teste_6' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='teste_6')
ON CONFLICT (artefato_id, codigo) DO NOTHING;
SELECT a.tipo, max(a.versao) AS versao FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' GROUP BY a.tipo ORDER BY 1;
COMMIT;
