# CUT · Formato fixo das peças

Versão 1.0 · 16/11/2026 · Conferido pelo banco em `conteudo.conferir_formato(tipo, corpo)` (SQL 88).

## Regras gerais

- **Erro bloqueia a publicação.** O banco recusa publicar uma peça com erro de formato. A mensagem aparece:
  - na tela de revisão;
  - na prévia;
  - na aba "Conferência dos temas" do painel.
- **Aviso não bloqueia.** Ele indica o que falta para a peça ficar completa.
- **Comum a todas as peças:**
  - começar com um título `# T00X — Nome da peça`;
  - ter pelo menos 200 caracteres;
  - nenhum número de prontuário, registro ou CPF (é erro).
  - A faixa "RASCUNHO" na primeira linha gera aviso: tire-a depois da revisão.

## O que cada momento ensina (decisão de 16/11/2026)

| Momento | Peças | Papel |
|---|---|---|
| Antes da aula | objetivos, resumo básico, podcast, caso base, síntese de evidência, mapa | A fonte teórica do tema. Tudo o que o aluno precisa saber de base chega aqui. |
| Aula | aula (texto), slides, caso da aula | Não repete a teoria de antes da aula. Parte do pressuposto de que o aluno a leu e vai além: discussão de caso clínico, decisão em cada ponto, técnica cirúrgica passo a passo, anatomia cirúrgica, armadilhas e complicações. |
| Depois da aula | resumo executivo, diretriz clínica (protocolo), checklist, flashcards | Consolida e leva à prática: o que fazer no plantão. A diretriz é a norma de conduta do tema. |

**Na aula, o que pode voltar da teoria:** só a frase que serve de ponte para a discussão, citando a peça em que ela está ("como no resumo básico, ..."). Um slide que só reexplica um conceito do resumo básico é retrabalho e sai.

**O que a aula precisa ter:**
- pelo menos um caso clínico com pontos de decisão;
- a técnica operatória do procedimento central do tema: indicação, posicionamento, acesso, passos, controle e fechamento;
- a anatomia cirúrgica que o cirurgião usa no procedimento (relações, marcos, planos, o que não lesar);
- as complicações e armadilhas, e como evitá-las.

Em temas sem procedimento cirúrgico (gestão, ensino, pesquisa), a técnica é substituída pelo como fazer na prática do serviço, com exemplo real e anonimizado.

O agente de pré-revisão recebe, junto com cada peça da aula, o material de antes da aula do mesmo tema. Ele aponta o trecho repetido como problema e propõe o aprofundamento no lugar.

## Por peça

| Peça | Formato obrigatório (erro se faltar) | Recomendado (aviso se faltar) |
|---|---|---|
| Objetivos | Uma seção `## ` para cada perfil: Graduação, R1, R2, R3, R+ | — |
| Resumo básico, resumo executivo, aula | Pelo menos 2 seções `## título` | — |
| Protocolo (diretriz clínica do tema, `docs/diretriz_do_tema.md`) | Pelo menos 2 seções `## título` | As 13 seções da diretriz (Escopo e população ... Revisão); ao menos 3 `**Recomendação N.**`, cada uma com `Força: ... \| Certeza: ...` e `Origem: ...`; fluxograma em bloco ` ```mermaid ` |
| Síntese de evidência | Pelo menos 2 seções `## título` | `## Consenso`, `## Disputa`, `## Lacunas` |
| Caso base | Bloco `**Perguntas...**` (ou `## Perguntas`) seguido de perguntas numeradas `1.`, `2.` | — |
| Caso da aula | Pelo menos 2 `**Ponto de decisão N — título**`; cada um com `Situação:` e `Discussão:` em linhas próprias | `Dica:` em cada ponto; `**Desfecho**` no fim |
| Checklist | Pelo menos 3 itens `- [ ] ...` | Grupos em negrito (`**Antes da chegada**`) |
| Slides | Pelo menos 3 `### Slide N. título` | `> **Fala:** ...` em cada slide (sem fala, o slide fica sem áudio) |
| Mapa conceitual | Bloco ` ```mermaid ` com `mindmap` e a raiz `root((...))` | — |
| Flashcards | Pelo menos 5 linhas `\| n \| frente \| verso \|` | — |
| Roteiro de podcast | Pelo menos 4 falas `**PRECEPTOR:**` / `**RESIDENTE:**` | — |
| Testes (1 a 6) | Seções `## Perfil Graduação`, `R1`, `R2`, `R3`, `R+`; cada questão `**N.**` com 5 alternativas `- A)` a `- E)` | — |

## Questões âncora

- **O que são.** De 2 a 3 questões por tema, iguais nas seis ondas e para todos os anos (`app.item.fixa = true`).
- **Para que servem.** Medem o mesmo conteúdo do pré-teste 1 ao D+90, sem a diferença entre as questões de cada onda.
- **Na análise.** Entram como análise de sensibilidade do modelo principal (plano de análise, seção 5).
- **O gabarito no meio das ondas.** O aluno vê o gabarito da âncora ao fim de cada onda. Isso é intencional: faz parte da aprendizagem por testes e está declarado como limitação.
- **Conferência.** A aba "Conferência dos temas" avisa o tema com menos de 2 âncoras.
- **Situação do T001.** Tem 1 âncora (T001-FIXA).

## Tempo de estudo

Cada peça mostra ao aluno "Essencial · N min" ou "Aprofundamento · N min". Cada grupo (antes da aula, aula, depois da aula) mostra também o total essencial.

**Nível padrão** (pode ser mudado peça a peça na coluna `conteudo.artefato.nivel`):

| Nível | Peças |
|---|---|
| Essencial | objetivos, resumo básico, caso base, slides, caso da aula, resumo executivo, checklist |
| Aprofundamento | podcast, síntese de evidência, mapa conceitual, aula (texto), protocolo, flashcards, banco de questões |

**Minutos estimados** (podem ser corrigidos na coluna `conteudo.artefato.minutos`):
- leitura de estudo a 130 palavras por minuto;
- slides com fala e podcast: a fala a 150 palavras por minuto;
- caso da aula: mais 3 minutos por ponto de decisão;
- caso base: mais 3 minutos por pergunta;
- flashcards: 30 segundos por cartão;
- mapa conceitual: 10 minutos;
- banco de questões: 1 minuto por questão;
- mínimo de 3 minutos por peça.

**Meta.** O essencial antes da aula fica entre 60 e 90 minutos. Acima de 90 minutos, a conferência avisa. No T001, o essencial antes da aula soma cerca de 30 minutos.
