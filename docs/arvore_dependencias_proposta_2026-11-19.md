# CUT · Árvore de dependências dos temas: enxugamento de 19/11/2026

Versão 1.0 · 19/11/2026 · Aprovada pela coordenação em 19/11/2026 e aplicada no `65_arvore_temas_v1.0.sql`.

## Critérios usados

1. **Dependência só quando o tema seguinte precisa do anterior para ser compreendido.** Ou seja, o filho usa um conceito,
   uma técnica ou uma decisão ensinada na mãe. Assunto parecido, mesmo módulo ou ordem no calendário não bastam.
2. **Uma mãe por tema, sempre que der.** Uma segunda mãe entra só quando o filho usa duas bases diferentes. Exemplo:
   T023 usa o FAST e a TC (T003) e a hemodinâmica (T004).
3. **Sem ligação em dobro.** Se a mãe já vem por outra mãe do mesmo tema, a ligação direta sai.
4. **Camadas.** O que é base (avaliação inicial, choque, coagulopatia, sepse, segurança do paciente, a pergunta
   clínica) fica embaixo. Os temas de aplicação ficam em cima. Os casos integradores pedem os temas que integram.
5. **Calendário.** A mãe de um tema principal é sempre principal e vem antes no calendário de 2027–2028. Por isso o
   T026 (víscera oca, 14º encontro) continua ligado ao T003, e não ao T023 (24º encontro).
6. **Não travar o optativo.** Tema eletivo ou complementar não fica preso atrás de uma cadeia longa de outros
   optativos sem necessidade.

## Resultado

| | Atual | Proposta |
|---|---|---|
| Ligações | 181 | 161 |
| Temas com mãe | 134 | 128 |
| Temas avulsos (sem mãe nem filho) | 6 | 11 |
| Cadeia mais longa (número de temas antes) | 8 (T070) | 6 |
| Média de temas que precisam vir antes | 3,3 | 2,6 |
| Ligações em dobro | 8 | 0 |

Conferido no banco de teste: sem ciclo, todas as ligações carregadas e todo tema principal com as mães antes dele no
calendário.

## As 29 mudanças

| Tema | Mães hoje | Mães propostas | Motivo |
|---|---|---|---|
| T004 Choque hemorrágico | T003 (Exames adjuntos ao trauma) | T001 (Avaliação inicial do traumatizado) | Choque hemorrágico parte da avaliação primária (C); não precisa de laboratório, TC e FAST para ser compreendido. |
| T006 Tromboembolismo venoso no trauma e no paciente cirúrgico | T001 (Avaliação inicial do traumatizado) | nenhuma | Profilaxia e tratamento do TEV não dependem da avaliação inicial; o tema se sustenta sozinho. |
| T007 Trauma no idoso e no paciente anticoagulado | T014 (Fratura de arcos costais) | T005 (Coagulopatia do trauma, diamante letal, TXA e transfusão) | Reversão de anticoagulante e limites de investimento partem da coagulopatia e da transfusão (T005), não das fraturas de costela. |
| T008 Lesões ambientais | T001 (Avaliação inicial do traumatizado), T004 (Choque hemorrágico) | T001 (Avaliação inicial do traumatizado) | Hipotermia, afogamento e frio partem da avaliação inicial e da exposição; T004 era desnecessária e T001 estava em dobro. |
| T013 Trauma torácico fechado | T015 (Pneumotórax traumático e espontâneo e drenagem torácica) | T001 (Avaliação inicial do traumatizado) | Contusão pulmonar não exige o tema de drenagem; basta a avaliação inicial (respiração). |
| T020 Trauma cardíaco | T015 (Pneumotórax traumático e espontâneo e drenagem torácica), T004 (Choque hemorrágico) | T003 (Exames adjuntos ao trauma), T004 (Choque hemorrágico) | O trauma cardíaco usa o FAST pericárdico (T003) e o choque (T004); a drenagem torácica (T015) não é base. |
| T022 Trauma esofágico | T044 (Trauma cervical penetrante e lesão de estruturas aerodigesti), T017 (Lesão em transição toracoabdominal e lesão de diafragma) | T044 (Trauma cervical penetrante e lesão de estruturas aerodigesti) | A lesão esofágica parte da lesão aerodigestiva cervical (T044); a transição toracoabdominal não é necessária. |
| T023 Trauma abdominal fechado | T004 (Choque hemorrágico) | T003 (Exames adjuntos ao trauma), T004 (Choque hemorrágico) | A escolha entre laparotomia e manejo não operatório depende do FAST e da TC (T003) e da hemodinâmica (T004). |
| T028 Trauma vascular abdominal | T023 (Trauma abdominal fechado), T009 (Cirurgia de controle de danos no trauma e na cirurgia de urg), T037 (Trauma vascular periférico) | T023 (Trauma abdominal fechado), T009 (Cirurgia de controle de danos no trauma e na cirurgia de urg) | Zonas retroperitoneais e REBOA partem do trauma abdominal e do controle de danos; o trauma vascular periférico não é base. |
| T035 Isquemia mesentérica aguda | T051 (Abdome agudo obstrutivo), T066 (Sepse e choque séptico no paciente cirúrgico) | T066 (Sepse e choque séptico no paciente cirúrgico) | Isquemia mesentérica usa ressuscitação e controle do foco (T066); obstrução intestinal não é base. |
| T051 Abdome agudo obstrutivo | T046 (Apendicite aguda) | nenhuma | Abdome agudo obstrutivo não depende de apendicite; vira tema de entrada do bloco. |
| T052 Abdome agudo perfurativo | T046 (Apendicite aguda) | nenhuma | Abdome agudo perfurativo não depende de apendicite; vira tema de entrada do bloco. |
| T055 Técnicas de fechamento de parede, prevenção de hérnia incisi | T010 (Síndrome compartimental abdominal) | nenhuma | Fechamento de parede, evisceração e deiscência se entendem sem a síndrome compartimental abdominal. |
| T062 Síndrome de Fournier e urgências orifiais | T066 (Sepse e choque séptico no paciente cirúrgico) | T067 (Infecções de pele e partes moles) | Fournier é fasceíte necrotizante perineal: a base é T067, não a sepse em geral. |
| T063 Urgências oncológicas e abdome agudo no imunossuprimido (neu | T051 (Abdome agudo obstrutivo) | T066 (Sepse e choque séptico no paciente cirúrgico) | Abdome agudo no imunossuprimido se apoia em sepse e controle do foco (T066), não na obstrução. |
| T069 Deiscência de anastomose e fístula digestiva pós-operatória | T066 (Sepse e choque séptico no paciente cirúrgico), T068 (Peritonite terciária e falência de controle do foco) | T068 (Peritonite terciária e falência de controle do foco) | T066 estava em dobro (já vem por T068). |
| T070 Hemorragia pós-operatória e reoperação não planejada | T069 (Deiscência de anastomose e fístula digestiva pós-operatória), T031 (Interface com radiologia intervencionista) | T031 (Interface com radiologia intervencionista) | Hemorragia pós-operatória: imagem e embolização (T031) antes da reoperação; deiscência (T069) não é base. Encurta a cadeia de 8 para 6. |
| T075 Delirium, sedação e analgesia, inclusive sedação para proced | T071 (Ventilação mecânica no pós-operatório) | nenhuma | Sedação, analgesia, delirium e bloqueios não dependem de ventilação mecânica. |
| T086 Violência interpessoal | T001 (Avaliação inicial do traumatizado), T121 (Trauma na criança) | T001 (Avaliação inicial do traumatizado) | Reconhecer e notificar violência parte da avaliação inicial; trauma pediátrico não é base para violência contra adulto e idoso. |
| T087 Consentimento e aspectos médico-legais na urgência | T084 (Cuidados paliativos na cirurgia de urgência e trauma), T102 (Evento adverso, segunda vítima e cultura de segurança) | nenhuma | Consentimento e aspectos médico-legais se entendem sozinhos; não dependem de paliativos nem de evento adverso. |
| T090 Abdome agudo em anticoagulado | T114 (Farmacologia do paciente cirúrgico de urgência), T046 (Apendicite aguda) | T114 (Farmacologia do paciente cirúrgico de urgência) | O anticoagulado é o centro do caso (T114); apendicite não é base. |
| T103 Liderança da equipe de trauma e comunicação em crise | T100 (Segurança do paciente no centro cirúrgico de urgência) | T001 (Avaliação inicial do traumatizado) | Liderança da equipe de trauma parte da avaliação inicial e do acionamento da equipe (T001). |
| T104 Melhoria da qualidade e implementação de diretrizes | T130 (Auditoria de protocolos, indicadores de qualidade das diretr), T140 (Diretrizes clínicas) | T130 (Auditoria de protocolos, indicadores de qualidade das diretr) | Melhoria da qualidade parte da auditoria e dos indicadores (T130); exigir toda a cadeia de medicina baseada em evidências (até T140) travava o tema. |
| T105 Raciocínio clínico e erro diagnóstico na urgência | T102 (Evento adverso, segunda vítima e cultura de segurança), T100 (Segurança do paciente no centro cirúrgico de urgência) | T100 (Segurança do paciente no centro cirúrgico de urgência) | Erro diagnóstico se apoia na segurança do paciente (T100); T102 não é base e T100 estava em dobro. |
| T117 Ectópica rota e hemoperitônio | T046 (Apendicite aguda) | T004 (Choque hemorrágico) | Ectópica rota é choque hemorrágico (T004); apendicite não é base. |
| T141 Do tema ao projeto de pesquisa | T135 (A pergunta clínica estruturada), T136 (Desenhos de estudo em cirurgia) | T136 (Desenhos de estudo em cirurgia) | T135 estava em dobro (já vem por T136). |
| T148 Pesquisa em educação médica | T144 (Avaliação do residente), T142 (Aprendizagem do adulto e estratégias instrucionais na residê) | T144 (Avaliação do residente) | T142 estava em dobro (já vem por T144). |
| T149 Governança compartilhada na sala de emergência, limites de e | T129 (Sistemas de trauma, triagem, incidente com múltiplas vítimas), T132 (Telemedicina, regulação e transferência inter-hospitalar em ) | T132 (Telemedicina, regulação e transferência inter-hospitalar em ) | T129 estava em dobro (já vem por T132). |
| T150 Organização do serviço de cirurgia de urgência (acute care s | T129 (Sistemas de trauma, triagem, incidente com múltiplas vítimas), T149 (Governança compartilhada na sala de emergência, limites de e) | T149 (Governança compartilhada na sala de emergência, limites de e) | T129 estava em dobro (já vem por T149). |

## O que não muda

- As ligações dos outros temas ficam como estão; cada uma foi conferida pelo critério 1.
- As cadeias em camadas continuam:
  - medicina baseada em evidências: T135, T136, T137, T138, T139, T140;
  - ensino: T142 e T143 na base;
  - controle de danos: T005, T009, T010 e T011;
  - hemorragia digestiva: T057, T059, T122, T123, T124.
- Os casos integradores (T088, T089, T093, T094) seguem pedindo os temas que integram.

## Aplicação

A lista `req` do `65_arvore_temas_v1.0.sql` foi trocada pela proposta. As três conferências do script passaram no
banco de teste: sem ciclo, todas as ligações carregadas e todo tema principal com as mães antes dele no calendário. A
liberação confere as mães no momento do acesso, então a árvore nova vale na hora para todos ao rodar o `subir`.
