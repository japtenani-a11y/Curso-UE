-- 31_importar_T001_rascunhos_v1.0.sql : importa os 12 artefatos do T001 como RASCUNHO (nova versao; nao apaga nada)
BEGIN;
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'sintese_evidencia', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='sintese_evidencia'),0)+1,
       'rascunho', $T001$Síntese de evidência$T001$, $T001$# T001 — Avaliação inicial do traumatizado: o que mudou no xABCDE (síntese de evidência — RASCUNHO)

Base: revisão sistemática do usuário (75 fontes segmentadas, camada 4). Cada afirmação abaixo traz fonte e trecho literal; números conferidos contra o trecho. Rascunho sujeito à revisão por 3 cirurgiões (tolerância: 5% leve / 0 crítico).

## 1. Treinamento e protocolos de suporte de vida
- [A1] Revisão sistemática de 19 estudos / 92.614 pacientes; programas de suporte de vida associaram-se a menor mortalidade (OR 0,60), porém com evidência observacional [A2].
- [A4] Persiste a ausência de evidência de alta qualidade de benefício do ATLS em desfechos de pacientes; ensaios pragmáticos em curso [A5]. Custos variam de USD 3,70 a 1433,5 conforme o programa [A6].

## 2. Checklists e formulários estruturados
- Checklist pode melhorar adesão ao ATLS e fluxo de trabalho [A8, A11], mas as evidências são antes-e-depois [A7]; um estudo mostrou menor mortalidade em ISS > 25 [A9] e outro maior pneumonia [A10].
- O formulário de admissão (TIF) melhorou 14 de 16 indicadores [A13]; avaliação de vias aéreas de 72,9% para 98,4% [A14]. Implementação depende de campeão institucional e adaptação local [A16].

## 3. Equipe, simulação e liderança
- Treinamento por simulação/in situ com debriefing reduz tempos [A17, A18]; cirurgião presente encurta a ressuscitação [A19]. Sem diferença de sobrevida por líder cirurgião, mas menos lesões não identificadas [A20, A21]. Colaboração estreita radiologia intervencionista–cirurgia associou-se a maior sobrevida [A22].

## 4. Hemorragia externa, circulação e choque
- Torniquete pré-hospitalar: redução de mortalidade não significativa e mais amputações iniciais [A23, A24]; curativos compressivos têm pressão muito variável e sem correlação com a autoavaliação [A25, A26].
- Parâmetros clássicos do ATLS para classe de choque tiveram superestimação metodológica [A32]; definição de estabilidade hemodinâmica heterogênea [A33]. RUSH: boa sensibilidade em instáveis [A34]; FAST-PLUS detecta alargamento pélvico crítico [A35].

## 5. Via aérea, oxigênio e ventilação
- Maioria dos respondentes não apoia O2 suplementar sempre para todo grave sem considerar SpO2 [A27]. Via aérea cirúrgica de emergência: 0,24% em coorte japonesa [A28].
- E-FAST para pneumotórax: sens. 93,6%/espec. 99,8% [A29], mas outro estudo prospectivo encontrou baixa sensibilidade da ultrassonografia torácica inicial [A30].

## 6. Hipotermia e ressuscitação
- Hipotermia presente em até 2/3 dos graves e subvalorizada [A36]; sem abordagem baseada em evidência [A37]; fluido a 39 °C só mantém >37 °C em condições específicas [A38].
- Adrenalina na parada traumática extra-hospitalar associou-se a menor sobrevida em 7 dias [A31].

## 7. TC de corpo inteiro e lesões perdidas
- TC de rotina com pouco ou nenhum efeito na mortalidade e no tempo [A12]; sem aumento de mortalidade em choque [A39]; avaliação primária sem alterações em 3,02% [A40].
- Mesmo assim há lesões tardias [A41, A42] e SILENT com sens. 75% [A43]; treinamento in situ por checklist ou algoritmo teve ganhos similares [A44].

## Mensagens-chave (xABCDE)
1. Estruturar a avaliação (checklist/TIF) melhora processo; efeito em mortalidade ainda incerto.
2. Hemorragia exsanguinante primeiro; torniquete tem benefício de mortalidade não comprovado e risco de amputação.
3. Não usar parâmetros clássicos de classe de choque isoladamente.
4. Ultrassom (E-FAST) é útil, porém com sensibilidade variável para pneumotórax.
5. Reavaliar sempre: lesões tardias ocorrem mesmo com TC de corpo inteiro.
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'objetivos', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='objetivos'),0)+1,
       'rascunho', $T001$Objetivos de aprendizagem$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Objetivos de aprendizagem

Ao final do tema, o residente será capaz de:

1. **Descrever** (lembrar/compreender) a sequência xABCDE e justificar a prioridade do controle da hemorragia exsanguinante. **[DOUTRINA – confirmar na camada 2]**
2. **Interpretar** (analisar) a força da evidência dos programas de suporte de vida no trauma: associação com menor mortalidade (OR 0,60) em estudos observacionais [A2] e ausência de evidência de alta qualidade [A4].
3. **Aplicar** ferramentas estruturadas (checklist, formulário de admissão) na avaliação primária, reconhecendo ganhos de processo [A8, A13, A14] e limites da evidência [A7, A10].
4. **Avaliar** criticamente os instrumentos de avaliação da circulação: limites da classificação clássica de choque [A32], heterogeneidade do conceito de estabilidade hemodinâmica [A33] e papel do ultrassom (RUSH, FAST-PLUS) [A34, A35].
5. **Julgar** a acurácia do ultrassom torácico para pneumotórax diante de resultados conflitantes [A29, A30].
6. **Decidir** sobre intervenções de controle de hemorragia externa conhecendo o balanço benefício/risco do torniquete [A23, A24] e a variabilidade do curativo compressivo [A25, A26].
7. **Reconhecer** a hipotermia como problema frequente e subvalorizado [A36, A37] e planejar medidas de prevenção.
8. **Planejar** reavaliações seriadas (avaliação terciária), sabendo que lesões com diagnóstico tardio ocorrem mesmo com TC de corpo inteiro [A41, A42].
9. **Atuar** em equipe com liderança definida e treinamento por simulação [A17, A18, A19, A21].

| Objetivo | Nível (Bloom) | Avaliado em |
|---|---|---|
| 1 | Compreender | itens 1; flashcards |
| 2 | Analisar | itens 2; simulado |
| 3 | Aplicar | itens 3, 4; checklist |
| 4 | Avaliar | itens 5; caso |
| 5 | Avaliar | item 6; caso |
| 6 | Avaliar | item 7; caso |
| 7 | Compreender | item 8; flashcards |
| 8 | Aplicar | simulado; caso |
| 9 | Aplicar | simulado; aula síncrona |
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'item', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='item'),0)+1,
       'rascunho', $T001$Itens de avaliação$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Banco de itens (múltipla escolha, 4 alternativas)

Itens novos, sem calibração psicométrica (dificuldade/discriminação a estimar após a primeira aplicação).

**1.** Segundo revisão sistemática com 19 estudos e 92.614 pacientes, qual é a melhor descrição do efeito dos programas de treinamento em suporte de vida no trauma (como o ATLS) sobre a mortalidade?

- A) Redução comprovada por ensaios randomizados de alta qualidade
- B) Associação com menor mortalidade (OR 0,60), baseada em evidência observacional
- C) Ausência de qualquer associação com mortalidade
- D) Aumento de mortalidade em países de baixa renda

_Objetivo 2_

**2.** Sobre o uso de checklist na ressuscitação do trauma, assinale a correta.

- A) A evidência vem de ensaios randomizados multicêntricos
- B) Pode melhorar adesão ao ATLS e o fluxo de trabalho; os estudos são do tipo antes-e-depois
- C) Demonstrou reduzir pneumonia em todos os estudos
- D) Não tem qualquer efeito sobre processos de atendimento

_Objetivo 3_

**3.** Após a introdução de um formulário estruturado de admissão do trauma (TIF), qual resultado foi observado?

- A) Melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial
- B) Piora da documentação da via aérea
- C) Nenhuma mudança nos indicadores de processo
- D) Aumento da mortalidade nos pacientes com fisiologia alterada

_Objetivo 3_

**4.** Revisão sistemática sobre torniquete pré-hospitalar encontrou:

- A) Redução estatisticamente significativa da mortalidade
- B) Redução de mortalidade não significativa e amputação inicial mais frequente no grupo torniquete
- C) Aumento significativo da mortalidade
- D) Ausência de dados sobre amputação

_Objetivo 6_

**5.** Em relação ao ultrassom torácico para pneumotórax na avaliação inicial, é correto afirmar:

- A) Todos os estudos mostram sensibilidade acima de 90%
- B) Um exame negativo exclui pneumotórax com segurança
- C) Há resultados conflitantes: sensibilidade de 93,6% em um estudo e baixa sensibilidade com muitos falsos negativos em outro
- D) A especificidade é baixa, com muitos falsos positivos

_Objetivo 5_

**6.** Sobre a classificação de choque do ATLS e o conceito de 'estabilidade hemodinâmica':

- A) Há consenso internacional sobre os pontos de corte de estabilidade
- B) A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés que superestimou a classe de choque dos parâmetros tradicionais
- C) O déficit de base nunca foi comparado aos parâmetros do ATLS
- D) Estabilidade hemodinâmica foi definida em 100% dos artigos revisados

_Objetivo 4_

**7.** Sobre hipotermia no trauma grave:

- A) É rara e por isso negligenciável
- B) Está presente em até dois terços dos pacientes com lesão grave e frequentemente é desconsiderada na ressuscitação inicial
- C) Tem manejo padronizado por evidência robusta
- D) Fluido pré-aquecido a 39 °C sempre chega ao paciente acima de 37 °C

_Objetivo 7_

**8.** Paciente politraumatizado realizou TC de corpo inteiro na avaliação primária, sem achados adicionais. Qual a conduta mais adequada quanto a novas avaliações?

- A) Dispensar a avaliação terciária, pois a TC exclui lesões
- B) Manter reavaliações seriadas, pois lesões de diagnóstico tardio ocorreram em 13,9 % dos pacientes mesmo com TC de corpo inteiro
- C) Repetir a TC de corpo inteiro em todos os pacientes em 6 horas
- D) Suspender o exame físico por ser redundante

_Objetivo 8_
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'gabarito', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='gabarito'),0)+1,
       'rascunho', $T001$Gabarito comentado$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Gabarito comentado do banco de itens

| Item | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| Resposta | B | B | A | B | C | B | B | B |

**1.** Segundo revisão sistemática com 19 estudos e 92.614 pacientes, qual é a melhor descrição do efeito dos programas de treinamento em suporte de vida no trauma (como o ATLS) sobre a mortalidade?

- A) Redução comprovada por ensaios randomizados de alta qualidade
- B) Associação com menor mortalidade (OR 0,60), baseada em evidência observacional
- C) Ausência de qualquer associação com mortalidade
- D) Aumento de mortalidade em países de baixa renda

**Gabarito: B.** A associação existe (OR 0,60; IC 95% 0,48–0,75) [A1, A2], mas a evidência é observacional; os próprios pesquisadores afirmam não haver evidência de alta qualidade de benefício em desfechos de pacientes [A4].

_Objetivo 2_

**2.** Sobre o uso de checklist na ressuscitação do trauma, assinale a correta.

- A) A evidência vem de ensaios randomizados multicêntricos
- B) Pode melhorar adesão ao ATLS e o fluxo de trabalho; os estudos são do tipo antes-e-depois
- C) Demonstrou reduzir pneumonia em todos os estudos
- D) Não tem qualquer efeito sobre processos de atendimento

**Gabarito: B.** Os estudos incluídos eram antes-e-depois [A7]; houve melhora de adesão e fluxo [A8]. Um estudo mostrou MAIOR incidência de pneumonia no grupo checklist (aOR 1,69) [A10].

_Objetivo 3_

**3.** Após a introdução de um formulário estruturado de admissão do trauma (TIF), qual resultado foi observado?

- A) Melhora em 14 de 16 indicadores da avaliação primária e do cuidado inicial
- B) Piora da documentação da via aérea
- C) Nenhuma mudança nos indicadores de processo
- D) Aumento da mortalidade nos pacientes com fisiologia alterada

**Gabarito: A.** Houve melhora em 14 de 16 indicadores [A13]; a avaliação de vias aéreas passou de 72,9% para 98,4% [A14]; a mortalidade caiu de 17,7% para 12,1% entre 302 pacientes com fisiologia alterada [A15].

_Objetivo 3_

**4.** Revisão sistemática sobre torniquete pré-hospitalar encontrou:

- A) Redução estatisticamente significativa da mortalidade
- B) Redução de mortalidade não significativa e amputação inicial mais frequente no grupo torniquete
- C) Aumento significativo da mortalidade
- D) Ausência de dados sobre amputação

**Gabarito: B.** Mortalidade 4,02% vs. 6,43% (RR 0,70; IC 95% 0,46–1,07 — não significativo) [A23]; amputação inicial 19,32% vs. 6,4% (RR 2,07) [A24]. Atenção: associação observacional, sujeita a confusão por gravidade da lesão.

_Objetivo 6_

**5.** Em relação ao ultrassom torácico para pneumotórax na avaliação inicial, é correto afirmar:

- A) Todos os estudos mostram sensibilidade acima de 90%
- B) Um exame negativo exclui pneumotórax com segurança
- C) Há resultados conflitantes: sensibilidade de 93,6% em um estudo e baixa sensibilidade com muitos falsos negativos em outro
- D) A especificidade é baixa, com muitos falsos positivos

**Gabarito: C.** E-FAST: sensibilidade 93,6% e especificidade 99,8% [A29]; estudo prospectivo encontrou baixa sensibilidade com alta taxa de falsos negativos [A30]. Um exame negativo não deve encerrar a investigação quando a suspeita clínica persiste.

_Objetivo 5_

**6.** Sobre a classificação de choque do ATLS e o conceito de 'estabilidade hemodinâmica':

- A) Há consenso internacional sobre os pontos de corte de estabilidade
- B) A comparação clássica entre déficit de base e parâmetros do ATLS sofreu viés que superestimou a classe de choque dos parâmetros tradicionais
- C) O déficit de base nunca foi comparado aos parâmetros do ATLS
- D) Estabilidade hemodinâmica foi definida em 100% dos artigos revisados

**Gabarito: B.** Viés metodológico apontado em [A32]; a estabilidade hemodinâmica foi definida em 70% dos artigos elegíveis, sem consenso nos pontos de corte [A33].

_Objetivo 4_

**7.** Sobre hipotermia no trauma grave:

- A) É rara e por isso negligenciável
- B) Está presente em até dois terços dos pacientes com lesão grave e frequentemente é desconsiderada na ressuscitação inicial
- C) Tem manejo padronizado por evidência robusta
- D) Fluido pré-aquecido a 39 °C sempre chega ao paciente acima de 37 °C

**Gabarito: B.** Prevalência e subvalorização em [A36]; não há abordagem baseada em evidência [A37]; fluido a 39 °C só se mantém acima de 37 °C em condições específicas de fluxo e temperatura ambiente [A38].

_Objetivo 7_

**8.** Paciente politraumatizado realizou TC de corpo inteiro na avaliação primária, sem achados adicionais. Qual a conduta mais adequada quanto a novas avaliações?

- A) Dispensar a avaliação terciária, pois a TC exclui lesões
- B) Manter reavaliações seriadas, pois lesões de diagnóstico tardio ocorreram em 13,9 % dos pacientes mesmo com TC de corpo inteiro
- C) Repetir a TC de corpo inteiro em todos os pacientes em 6 horas
- D) Suspender o exame físico por ser redundante

**Gabarito: B.** Lesões com diagnóstico tardio em 13,9 % [A42]; lesão potencialmente letal surgiu depois da avaliação terciária em 0,26% dos graves [A41].

_Objetivo 8_
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'simulado', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='simulado'),0)+1,
       'rascunho', $T001$Simulado$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Simulado (10 questões, 15 minutos)

Instruções: uma alternativa correta por questão. Itens distintos do banco principal.

**1.** Em parada cardíaca extra-hospitalar traumática, o uso de adrenalina associou-se a:

- A) Maior sobrevida em 7 dias
- B) Menor sobrevida em 7 dias (OR 0,20)
- C) Nenhuma diferença de sobrevida
- D) Maior sobrevida em 30 dias

_Objetivo 4_

**2.** Com cirurgião de trauma presente no local, o tempo total de ressuscitação foi:

- A) 259 segundos menor
- B) 259 segundos maior
- C) Igual
- D) Não mensurado

_Objetivo 9_

**3.** Meta-análise comparando líder de equipe cirurgião vs. não cirurgião mostrou:

- A) Maior sobrevida com líder não cirurgião
- B) Sem diferença de sobrevida (OR 0,82) e menos lesões não identificadas com líder cirurgião (OR 0,48)
- C) Maior mortalidade com líder cirurgião
- D) Mais lesões perdidas com líder cirurgião

_Objetivo 9_

**4.** Sobre oxigênio suplementar no traumatizado grave, pesquisa com profissionais mostrou que a maioria:

- A) Apoia oxigênio sempre, independentemente da SpO2
- B) Não apoia oferecer oxigênio sempre a todos sem considerar a SpO2 (73 %)
- C) Contraindica oxigênio no trauma
- D) Não tem opinião

_Objetivo 1_

**5.** A TC de corpo inteiro de rotina, segundo revisão de revisões:

- A) Reduz claramente a mortalidade
- B) Parece ter pouco ou nenhum efeito em mortalidade e tempo na sala de emergência
- C) Aumenta a mortalidade
- D) Deve substituir a avaliação primária

_Objetivo 8_

**6.** Curativos compressivos aplicados por profissionais tiveram pressão média de 169,35 mmHg, com variação de 50–412 mmHg. A autoavaliação do aplicador:

- A) Correlacionou-se fortemente com a pressão medida
- B) Não se correlacionou com a pressão medida (p = 0,541)
- C) Superestimou sempre a pressão
- D) Não foi estudada

_Objetivo 6_

**7.** O teste SILENT para lesões de membro inferior apresentou:

- A) Sensibilidade 99% e especificidade 75%
- B) Sensibilidade 75% e especificidade 99%
- C) Sensibilidade e especificidade de 50%
- D) Sensibilidade 100%

_Objetivo 8_

**8.** No FAST-PLUS, a avaliação ultrassonográfica da sínfise púbica identificou alargamento crítico em:

- A) 7,5% dos pacientes
- B) 50% dos pacientes
- C) Nenhum paciente
- D) Todos os pacientes

_Objetivo 4_

**9.** A via aérea cirúrgica de emergência (front-of-neck) em coorte japonesa ocorreu em:

- A) 0,24% dos pacientes
- B) 24% dos pacientes
- C) 10% dos pacientes
- D) 2,4% dos pacientes

_Objetivo 1_

**10.** Treinamento in situ baseado em checklist comparado ao baseado em algoritmo produziu, nos modelos mentais compartilhados da equipe:

- A) Ganhos de curto prazo semelhantes
- B) Superioridade clara do algoritmo
- C) Superioridade clara do checklist
- D) Piora em ambos

_Objetivo 9_


---
## Gabarito comentado

1. **B** — [A31] — estudo observacional; não prova causalidade.
2. **A** — [A19].
3. **B** — [A20, A21].
4. **B** — [A27] — trata-se de opinião de profissionais, não de desfecho clínico.
5. **B** — [A12]. Em pacientes em choque, não aumentou a mortalidade precoce (17,4% vs. 27,6%; p = 0,21) [A39].
6. **B** — [A25, A26].
7. **B** — [A43] — útil para confirmar, insuficiente para excluir.
8. **A** — [A35].
9. **A** — [A28].
10. **A** — [A44].
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'aula', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='aula'),0)+1,
       'rascunho', $T001$Aula expositiva$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Aula: Avaliação inicial do traumatizado — o que mudou no xABCDE

Roteiro para 40 min (12 slides) + 10 min de discussão. Formato ativo: pergunta de abertura, duas pausas de votação.

**Slide 1 — Abertura (pergunta de votação).** "O ATLS reduz mortalidade? Qual a qualidade da evidência?" Guardar as respostas para o slide 3.

**Slide 2 — Do ABCDE ao xABCDE.** x = hemorragia exsanguinante antes da via aérea. **[DOUTRINA – confirmar na camada 2]**

**Slide 3 — O que sabemos sobre treinamento.** 19 estudos, 92.614 pacientes [A1]; OR 0,60 de mortalidade, evidência observacional [A2]; "não há evidência de alta qualidade" [A4]; ensaio ADVANCE TRAUMA com pelo menos 4320 pacientes em andamento [A5].

**Slide 4 — Estruturar funciona? Checklist.** Melhora adesão e fluxo [A8, A11]; estudos antes-e-depois [A7]; ISS > 25: aOR 0,51 [A9]; mas pneumonia aOR 1,69 em um estudo [A10].

**Slide 5 — Formulário de admissão (TIF).** 14 de 16 indicadores melhores [A13]; via aérea 72,9% → 98,4% [A14]; mortalidade 17,7% → 12,1% [A15]. Como implementar: campeão institucional, adaptação local [A16].

**Slide 6 — x: hemorragia externa.** Torniquete: mortalidade RR 0,70 (não significativo) [A23]; amputação RR 2,07 [A24] — discutir confusão por gravidade. Curativo compressivo: 50–412 mmHg, autoavaliação não confiável [A25, A26].

**Slide 7 — A/B (votação 2).** "eFAST negativo exclui pneumotórax?" Sens. 93,6%/espec. 99,8% [A29] vs. baixa sensibilidade em estudo prospectivo [A30]. O2 suplementar: 73 % não apoiam uso indiscriminado [A27]. Via aérea cirúrgica: 0,24% [A28].

**Slide 8 — C: choque.** Classificação clássica sob crítica [A32]; "estabilidade hemodinâmica" sem consenso [A33]; RUSH sens. 94,2% [A34]; FAST-PLUS e pelve [A35]; adrenalina na parada traumática: OR 0,20 para sobrevida em 7 dias [A31].

**Slide 9 — E: hipotermia.** Até dois terços dos graves [A36]; sem abordagem baseada em evidência [A37]; limite do fluido aquecido [A38].

**Slide 10 — Imagem: TC de corpo inteiro.** Pouco ou nenhum efeito em mortalidade [A12]; em choque não aumentou mortalidade precoce [A39]; avaliação primária normal em 3,02% dos submetidos [A40].

**Slide 11 — Não acabou na sala de trauma.** Lesões tardias: 13,9 % [A42]; lesão potencialmente letal após terciária: 0,26% [A41]; SILENT sens. 75%/espec. 99% [A43].

**Slide 12 — Equipe.** Simulação reduz tempos [A17, A18]; cirurgião presente: −259 s [A19]; líder cirurgião: menos lesões perdidas (OR 0,48), sobrevida igual [A20, A21]; checklist ≈ algoritmo no treino [A44].

**Fechamento.** Retomar a votação do slide 1; 5 mensagens-chave (ver Resumo).
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'caso', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='caso'),0)+1,
       'rascunho', $T001$Caso clínico$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Caso clínico (fictício, para discussão em pequenos grupos)

**Cenário.** Homem, 34 anos, colisão moto × automóvel. Chega pelo pré-hospitalar com torniquete em coxa esquerda (ferimento com sangramento volumoso), agitado, FC 128, PA 92/58, SpO2 91% em ar ambiente, temperatura 34,9 °C. *(Dados inventados; nenhum paciente real.)*

**Ponto de decisão 1 — Por onde começar?**
Discussão esperada: sequência xABCDE com reavaliação do controle da hemorragia externa primeiro **[DOUTRINA – confirmar na camada 2]**. Evidência para debate: torniquete com redução de mortalidade não significativa (RR 0,70) [A23] e mais amputações iniciais (RR 2,07) [A24] — o que isso significa (confusão por gravidade? tempo de torniquete?). Se optar por curativo compressivo: pressão real muito variável e autoavaliação não confiável [A25, A26].

**Ponto de decisão 2 — Oxigênio e tórax.**
SpO2 91%: aqui há indicação guiada por SpO2 — contraste com o uso indiscriminado, não apoiado por 73 % dos profissionais [A27]. eFAST sem sinais de pneumotórax: pode encerrar a investigação? Não: resultados conflitantes de sensibilidade [A29, A30].

**Ponto de decisão 3 — Está "estável"?**
O grupo deve definir estabilidade e perceber que a literatura não tem consenso [A33] e que a classificação clássica de choque tem limitações [A32]. Ferramentas à beira-leito: RUSH [A34]; FAST-PLUS para alargamento pélvico [A35].

**Ponto de decisão 4 — Temperatura 34,9 °C.**
Hipotermia é frequente e subvalorizada [A36]; não há protocolo baseado em evidência [A37]; fluido aquecido a 39 °C pode não chegar acima de 37 °C ao paciente [A38]. O que a equipe fará na prática?

**Ponto de decisão 5 — TC de corpo inteiro?**
Benefício em mortalidade incerto [A12]; em choque, não aumentou mortalidade precoce [A39]. Decisão depende da resposta à ressuscitação e da logística local **[definir no protocolo institucional]**.

**Ponto de decisão 6 — 24 h depois.**
TC sem outras lesões. Dor em punho direito no D1. Mensagem: lesões de diagnóstico tardio em 13,9 % [A42]; avaliação terciária obrigatória; mesmo ela não é infalível (0,26% de lesão potencialmente letal posterior) [A41].

**Perguntas de fechamento.** (1) Qual ferramenta estruturada teria ajudado a equipe? [A8, A13] (2) Quem liderou e como isso afeta lesões perdidas? [A21]
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'resumo', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='resumo'),0)+1,
       'rascunho', $T001$Resumo executivo$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Resumo executivo (1 página)

**Pergunta do tema:** o que mudou na avaliação inicial do traumatizado e quão sólida é a evidência?

1. **Treinamento (ATLS e similares):** associado a menor mortalidade (OR 0,60) em estudos observacionais [A2]; sem evidência de alta qualidade [A4]; ensaio grande em andamento [A5].
2. **Estrutura melhora processo:** checklist melhora adesão e fluxo [A8]; formulário de admissão melhorou 14 de 16 indicadores [A13]. Efeito em mortalidade ainda incerto [A7, A9, A10].
3. **Hemorragia externa:** torniquete sem redução significativa de mortalidade (RR 0,70) e com mais amputação inicial (RR 2,07) em dados observacionais [A23, A24]; curativo compressivo com pressão imprevisível [A25, A26].
4. **Via aérea/ventilação:** O2 guiado por SpO2 é a posição da maioria [A27]; ultrassom torácico tem sensibilidade variável — negativo não exclui pneumotórax [A29, A30].
5. **Circulação:** classificação clássica de choque e "estabilidade hemodinâmica" têm bases frágeis [A32, A33]; RUSH e FAST-PLUS ajudam à beira-leito [A34, A35]; adrenalina na parada traumática associou-se a pior sobrevida [A31].
6. **Exposição:** hipotermia em até dois terços dos graves, subvalorizada e sem protocolo baseado em evidência [A36, A37].
7. **Imagem e seguimento:** TC de corpo inteiro com pouco ou nenhum efeito em mortalidade [A12]; lesões tardias em 13,9 % mesmo com ela [A42] → avaliação terciária sempre.
8. **Equipe:** simulação reduz tempos [A17, A18]; liderança por cirurgião associada a menos lesões perdidas [A21].

**Lacunas desta síntese:** a base é a revisão de artigos (camada 4); doutrina do xABCDE, doses e técnicas devem vir do livro-texto (camada 2) e do protocolo institucional (camada 3).
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'mapa', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='mapa'),0)+1,
       'rascunho', $T001$Mapa conceitual$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

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
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'flashcard', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='flashcard'),0)+1,
       'rascunho', $T001$Flashcards$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

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
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'protocolo', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='protocolo'),0)+1,
       'rascunho', $T001$Protocolo assistencial$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

# T001 — Protocolo assistencial: avaliação inicial do traumatizado (PROPOSTA)

**Situação:** minuta para discussão. Não é protocolo vigente. Exige validação institucional (camada 3), definição de responsáveis e adequação aos recursos do serviço. Itens de conduta clínica direta estão marcados **[DOUTRINA – confirmar na camada 2]**; especialidades de apoio a definir tema a tema.

## 1. Objetivo
Padronizar a avaliação primária (xABCDE) e a reavaliação do paciente traumatizado na sala de trauma.

## 2. Antes da chegada
- Definir o líder da equipe e papéis. Justificativa: liderança por cirurgião associou-se a menos lesões não identificadas [A21]; presença do cirurgião encurtou a ressuscitação [A19].
- Aquecer a sala e preparar medidas de prevenção de hipotermia [A36].

## 3. Avaliação primária — registrar em formulário estruturado
Justificativa: formulário de admissão melhorou 14 de 16 indicadores [A13]; checklist melhora adesão [A8].
- **x** — Hemorragia exsanguinante: controle imediato **[DOUTRINA]**. Ao usar curativo compressivo, não confiar na percepção da pressão aplicada [A26]. Torniquete: registrar horário; reavaliar necessidade precocemente [A24].
- **A** — Via aérea com proteção cervical **[DOUTRINA]**.
- **B** — Ventilação; oxigênio guiado por SpO2 [A27]; eFAST como adjunto — resultado negativo não exclui pneumotórax [A30].
- **C** — Circulação: não classificar o choque por parâmetro isolado [A32]; RUSH/FAST e avaliação pélvica (FAST-PLUS) conforme treinamento da equipe [A34, A35].
- **D** — Estado neurológico **[DOUTRINA]**.
- **E** — Exposição e prevenção ativa de hipotermia; medir temperatura na admissão [A36, A37].

## 4. Imagem
TC de corpo inteiro: indicação por critérios do serviço **[definir]** — benefício em mortalidade incerto [A12]; pode ser realizada em pacientes em choque que respondem à ressuscitação, sem aumento de mortalidade precoce observado [A39].

## 5. Reavaliação
- Avaliação secundária completa e **avaliação terciária em até 24 h** (prazo: **[DOUTRINA – confirmar na camada 2]**) — lesões de diagnóstico tardio em 13,9 % [A42].
- Manter vigilância após a terciária [A41].

## 6. Treinamento e implementação
- Simulação in situ periódica com debriefing [A18].
- Designar responsável ("campeão") e adaptar o formulário ao contexto local [A16].

## 7. Indicadores sugeridos
Preenchimento do formulário; registro de via aérea; temperatura medida na admissão; tempo até TC; lesões de diagnóstico tardio.
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, 'checklist', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='checklist'),0)+1,
       'rascunho', $T001$Checklist de procedimento$T001$, $T001$> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). Códigos [A#] remetem às afirmações com trecho literal da fonte. Trechos marcados **[DOUTRINA – confirmar na camada 2]** não vêm da revisão de artigos e devem ser conferidos no livro-texto (Mattox) antes da publicação.

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
- [ ] D — Avaliação neurológica registrada **[DOUTRINA – confirmar na camada 2]**
- [ ] E — Exposição completa; temperatura medida; aquecimento iniciado [A36]

**Antes de sair da sala**
- [ ] Indicação de TC discutida pela equipe [A12]
- [ ] Pendências comunicadas em voz alta

**Em até 24 h** (prazo: **[DOUTRINA – confirmar na camada 2]**)
- [ ] Avaliação terciária realizada e registrada [A42]
$T001$, false
FROM app.tema t WHERE replace(t.codigo,'-','')='T001';
SELECT tipo, versao, status, length(corpo) AS caracteres FROM conteudo.artefato WHERE tema_id=(SELECT tema_id FROM app.tema WHERE replace(codigo,'-','')='T001') ORDER BY tipo, versao;
COMMIT;
