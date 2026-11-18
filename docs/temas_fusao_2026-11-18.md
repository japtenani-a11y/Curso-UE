# CUT · Fusão e temas novos (decisão de 18/11/2026)

A coordenação decidiu fundir temas que se sobrepõem antes de criar temas novos. O programa passa de 150 para 153 temas:
150 − 5 fundidos + 8 novos. Os temas principais e o calendário das 39 quintas não mudam.

Arquivos: SQL 53 (títulos e temas novos), SQL 100 (fusão no banco), SQL 65 (árvore), SQL 73 (relevância) e
`BUSCAS_PUBMED_150_temas.txt` (buscas novas no fim do arquivo).

## 1. Temas fundidos

O tema fundido sai do catálogo. As fontes já guardadas, os pedidos de "Avise-me" e as variantes de termo passam para o
tema que o recebe. Se um tema fundido já tivesse material, questões ou ondas, o SQL 100 não mexe nele e avisa na tela.

| Sai | Entra em | Título do tema que recebe |
|---|---|---|
| T078 Fechamento do ciclo clínico | T077 | Caso integrador transversal: consolidação do bloco de trauma e fechamento do ciclo clínico |
| T144 Limites de escopo e transferência | T143 | Governança compartilhada na sala de emergência, limites de escopo e transferência de cuidado |
| T145 Burnout, segunda vítima e apoio | T135 | Desenvolvimento docente, mentoria, burnout e apoio institucional ao preceptor e ao residente |
| T146 Retirada de dreno, paracentese e toracocentese | T081 | Procedimentos à beira-leito com métrica de aquisição: toracostomia, cricotireoidostomia, acessos, drenagens, toracocentese, paracentese e retirada de dreno |
| T147 Peritoneostomia como procedimento | T009 | Peritoneostomia: instalação, cuidados, fechamento mediado por tela, abdome aberto prolongado e retirada |

A segunda vítima continua também no T084. Nos livros (`livros\*\LEIA-ME.txt` e `INDICE_TEMAS.csv`), um capítulo
marcado com um código que saiu vale para o tema que o recebeu.

## 2. Escopo ampliado, sem tema novo

| Tema | Acrescenta |
|---|---|
| T020 | Hemoptise maciça |
| T028 | Síndrome do esmagamento |
| T041 | Volvo (cólon e gástrico) e hérnia paraesofágica encarcerada |
| T048 | Corpo estranho retal |
| T058 | Sedação para procedimento e bloqueios regionais |
| T061 | Ferimentos de partes moles e mordeduras: fechamento, profilaxia de tétano e raiva |
| T066 | Abdome agudo no imunossuprimido (neutropenia, transplante) |
| T067 | Complicações de estomas |
| T114 | Escores de trauma e de cirurgia de urgência (RTS, ISS, TRISS, graus da AAST) |

## 3. Temas novos

Todos opcionais (complementar ou eletivo): o residente escolhe o D0, como nos outros opcionais.

| Tema | Título | Módulo | Depende de | Capítulos dos livros da pasta |
|---|---|---|---|---|
| T151 | Paciente cirrótico na cirurgia de urgência: estratificação (Child, MELD), coagulopatia, ascite e quando não operar | Avaliação de risco perioperatório | T086, T045 | TraumaManual5 cap. 49; Maingot13 cap. 61; Blumgart7, parte 7 |
| T152 | Colite grave: C. difficile fulminante, colite ulcerativa grave e megacólon tóxico | Hemorragia digestiva e colorretal | T050, T046 | ASCRS4 caps. 49 e 52; TraumaManual5 cap. 61; Maingot13 caps. 45 e 46 |
| T153 | Emergências vasculares não traumáticas: aneurisma de aorta abdominal roto e isquemia aguda de membro | Interfaces, urgência vascular e isquemia visceral | T139, T026 | Tintinalli9 caps. 60 e 61; TraumaManual5 cap. 64; ESC2016 cap. 27; Zollinger10 caps. 135 e 137 |
| T154 | Emergências esofágicas não traumáticas: síndrome de Boerhaave, corpo estranho e ingestão cáustica | Endoscopia digestiva na urgência | T019, T101 | ESC2016 cap. 12; Tintinalli9 caps. 77 e 200; Roberts8 cap. 40; Shackelford9, parte de esôfago |
| T155 | Deiscência de anastomose e fístula digestiva pós-operatória: diagnóstico, drenagem, desvio e reoperação | Infecção e sepse cirúrgica | T050, T052 | ASCRS4 cap. 10; TraumaManual5 cap. 73; Maingot13 cap. 16 |
| T156 | Violência interpessoal: maus-tratos à criança, violência doméstica e ao idoso, violência sexual e notificação compulsória | Fim de vida e decisão compartilhada | T001, T100 | Tintinalli9 caps. 150, 293, 294 e 295; Roberts8 cap. 59 |
| T157 | Consentimento e aspectos médico-legais na urgência: paciente incapaz, menor, recusa de transfusão e documentação | Fim de vida e decisão compartilhada | T069, T084 | Tintinalli9 cap. 303; ASCRS4 cap. 70; DSTC6, apêndice F |
| T158 | Lesões ambientais: hipotermia acidental, afogamento e lesão por frio | Reanimação e via aérea no trauma | T001, T004 | TraumaManual5 cap. 51; Tintinalli9 caps. 209 e 215 |

T156 e T157 precisam de fonte brasileira que os livros não têm:
- T156: Estatuto da Criança e do Adolescente, Estatuto da Pessoa Idosa, Lei Maria da Penha e normas de notificação compulsória do Ministério da Saúde;
- T157: Código de Ética Médica e resoluções do CFM sobre consentimento e recusa de tratamento.

O produtor deve pedir esses documentos à coordenação no relatório.
