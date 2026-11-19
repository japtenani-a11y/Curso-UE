# CUT · Reestruturação e renumeração dos temas (decisão de 19/11/2026)

O programa passa a ter **150 temas**, com os códigos renumerados de **T001 a T150 na ordem dos módulos**. T001 e T002 não mudaram. O tema continua o mesmo no banco (mesmo `tema_id`): material, questões, notas, presença e calendário seguem ligados a ele.

Arquivos: `101_reestruturacao_temas_v1.0.sql` (fusões e troca dos códigos no banco, roda antes do 53), SQL 53, 65, 73 e 92, `BUSCAS_PUBMED_150_temas.txt`, `fila_producao_150.md` e a tabela completa `renumeracao_temas_2026-11-19.csv` (código novo, código antigo, título, módulo).

## Fusões de 19/11/2026

| Sai (código antigo) | Entra em | Código novo do tema que recebe |
|---|---|---|
| T126 | T121 | T138 |
| T125 | T122 | T139 |
| T129 | T130 | T143 |
| T132 | T131 | T144 |
| T150 | T134 | T146 |

As 11 fusões de 18/11/2026 continuam valendo (ver `temas_fusao_2026-11-18.md`, que usa os códigos antigos).

## Temas novos

| Código | Título | Módulo | Papel |
|---|---|---|---|
| T070 | Hemorragia pós-operatória e reoperação não planejada: reconhecimento, imagem, embolização ou reoperação | Infecção e sepse cirúrgica | complementar |
| T104 | Melhoria da qualidade e implementação de diretrizes: PDSA, lean, auditoria e retroalimentação, barreiras e ciência da implementação | Segurança do paciente e qualidade | complementar |
| T105 | Raciocínio clínico e erro diagnóstico na urgência: vieses cognitivos, tempo de decisão e checagem | Segurança do paciente e qualidade | complementar |
| T133 | Registro de trauma, vigilância e painéis de desempenho do serviço: da ficha ao indicador | Auditoria, governança e sistemas | complementar |
| T134 | Custos e economia em saúde na urgência: custo-efetividade de protocolos, desperdício e o argumento financeiro de uma diretriz | Auditoria, governança e sistemas | eletivo |
| T141 | Do tema ao projeto de pesquisa: pergunta, protocolo, CEP e Plataforma Brasil, LGPD, registro de dados e publicação | Medicina baseada em evidências — julgar e aplicar | eletivo |
| T148 | Pesquisa em educação médica: como avaliar o próprio curso (Kirkpatrick, desenho, instrumentos e ética) | Ensino, preceptoria e avaliação | eletivo |
| T150 | Organização do serviço de cirurgia de urgência (acute care surgery): escala, sala dedicada, fluxo do paciente e superlotação | Governança compartilhada e saúde do profissional | complementar |

"Liderança da equipe de trauma" não virou tema: foi incorporada ao tema de simulação, CRM e TeamSTEPPS.

## Escopo ampliado

| Código novo | Antigo | Título |
|---|---|---|
| T009 | T007 | Cirurgia de controle de danos no trauma e na cirurgia de urgência não traumática: indicação e timing de reoperação |
| T055 | T141 | Técnicas de fechamento de parede, prevenção de hérnia incisional, evisceração e deiscência de parede |
| T066 | T050 | Sepse e choque séptico no paciente cirúrgico: foco abdominal, controle do foco e ressuscitação |
| T084 | T069 | Cuidados paliativos na cirurgia de urgência e trauma: comunicação de más notícias e conversa com a família |
| T103 | T085 | Liderança da equipe de trauma e comunicação em crise: briefing, debriefing, CRM, TeamSTEPPS e simulação realística |
| T106 | T086 | Avaliação perioperatória, estratificação de risco e recuperação acelerada (ERAS) na cirurgia de urgência |
| T130 | T114 | Auditoria de protocolos, indicadores de qualidade das diretrizes e escores de trauma e de cirurgia de urgência (RTS, ISS, TRISS, AAST) |
| T138 | T121 | Revisão sistemática, metanálise e qualidade do relato: forest plot, risco de viés, PRISMA, CONSORT, STROBE e IDEAL |
| T139 | T122 | Da evidência à decisão: GRADE, força da recomendação e aplicabilidade ao meu paciente |
| T140 | T123 | Diretrizes clínicas: leitura crítica, adaptação e elaboração (AGREE II, ADAPTE, GRADE), conflito de interesse e sociedades que discordam |
| T143 | T130 | Preceptoria à beira do leito: autonomia supervisionada, prática deliberada e feedback que muda desempenho |
| T144 | T131 | Avaliação do residente: instrumentos, validade, construção de questões e rubricas e análise psicométrica |
| T146 | T134 | Ensino e certificação de procedimentos: laboratório, simulação, transferência para o ambiente real e medida da habilidade |

## Os 150 temas por módulo

**Reanimação e via aérea no trauma:** T001, T002, T003, T004, T005, T006, T007, T008

**Controle de danos e abdome aberto:** T009, T010, T011, T012

**Trauma de parede torácica e pleural:** T013, T014, T015, T016, T017, T018

**Trauma cardíaco e de grandes vasos:** T019, T020, T021, T022

**Trauma abdominal:** T023, T024, T025, T026, T027, T028, T029

**Interfaces, urgência vascular e isquemia visceral:** T030, T031, T032, T033, T034, T035, T036

**Trauma de extremidade, pelve e vascular:** T037, T038, T039

**Neurotrauma:** T040, T041, T042

**Cabeça e pescoço:** T043, T044, T045

**Abdome agudo inflamatório e obstrutivo:** T046, T047, T048, T049, T050, T051, T052

**Hérnias e parede abdominal:** T053, T054, T055, T056

**Hemorragia digestiva e colorretal:** T057, T058, T059, T060, T061, T062, T063, T064, T065

**Infecção e sepse cirúrgica:** T066, T067, T068, T069, T070

**Intensivismo cirúrgico:** T071, T072, T073, T074, T075

**Queimaduras:** T076, T077, T078

**Urologia e geniturinário:** T079, T080, T081, T082

**Fim de vida e decisão compartilhada:** T083, T084, T085, T086, T087

**Casos integradores e fechamento:** T088, T089, T090, T091, T092, T093, T094

**Imagem pelo cirurgião:** T095, T096

**Procedimentos à beira-leito:** T097, T098, T099

**Segurança do paciente e qualidade:** T100, T101, T102, T103, T104, T105

**Avaliação de risco perioperatório:** T106, T107, T108, T109, T110

**Suporte perioperatório e farmacologia:** T111, T112, T113, T114

**Ginecologia e obstetrícia na urgência:** T115, T116, T117, T118, T119

**Cirurgia pediátrica de urgência:** T120, T121

**Endoscopia digestiva na urgência:** T122, T123, T124, T125

**MIS e cirurgia especializada na urgência:** T126, T127, T128

**Auditoria, governança e sistemas:** T129, T130, T131, T132, T133, T134

**Medicina baseada em evidências — ler e entender:** T135, T136, T137

**Medicina baseada em evidências — julgar e aplicar:** T138, T139, T140, T141

**Ensino, preceptoria e avaliação:** T142, T143, T144, T145, T146, T147, T148

**Governança compartilhada e saúde do profissional:** T149, T150
