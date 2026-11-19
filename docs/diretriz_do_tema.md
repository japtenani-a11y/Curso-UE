# CUT · Guia de atendimento do tema (a peça "protocolo")

Versão 2.0 · 19/11/2026 · Decisões da coordenação de 19/11/2026.

A peça `pecas/protocolo.md` de cada tema deixa de ser um fluxograma com orientações. Ela passa a ser uma **diretriz
clínica**: uma proposta de norma de conduta escrita, com recomendações graduadas, justificadas e rastreáveis até a fonte, que um
serviço pode adotar.

**Versão 2.0 (decisão da coordenação de 19/11/2026): a peça vira um guia de atendimento completo.** Além da diretriz
clínica, ela serve como guia de **regulação do fluxo de atendimento** e de **gestão da qualidade e da segurança do
paciente**: diz por onde o paciente entra e sai, quem faz o quê em cada etapa (matriz de responsabilidades), com que
tempo-alvo, que indicadores medem o cuidado, como são monitorados e quem responde por eles, que riscos ao paciente
existem e que barreira os previne, e como o serviço implanta o guia. O objetivo é um documento profissional, que a
diretoria e as equipes possam aplicar de forma prática e estruturada.

**A diretriz do curso é sempre uma proposta** (decisão da coordenação de 19/11/2026). Ela é entregue à diretoria do
hospital para avaliação e validada com as equipes listadas na seção "Equipes para validação". Não é apresentada como
definitiva nem como validada, nem no aplicativo, nem no PDF, mesmo depois de publicada no curso. Publicar no curso quer
dizer que a revisão do conteúdo terminou; a validação e a adoção como norma do serviço são da diretoria e das equipes.

## O que foi decidido

| Ponto | Decisão |
|---|---|
| Método | **Adaptação de diretrizes existentes.** Cada recomendação parte das diretrizes publicadas (EAST, WSES, AAST, WTA, ACS COT/ATLS, SBAIT, CBC, ERC, NICE e as da especialidade do tema), recebe força e certeza pelo GRADE e diz se foi adotada, adaptada ou se diverge da fonte, e por quê. |
| Para quem | **Diretriz do curso, adaptável.** Vale para qualquer serviço. A seção "Adaptação local" traz os campos que cada hospital preenche: recursos disponíveis, quem aciona, para onde transferir e contatos. |
| Partes | Cinco blocos: (A) núcleo clínico; (B) fluxo de atendimento e regulação, com a matriz de responsabilidades; (C) qualidade e segurança do paciente, com indicadores, monitoramento e riscos; (D) aplicação no serviço (adaptação local, implantação, exceções, base legal); (E) governança. |
| Natureza | **Proposta.** Toda diretriz é apresentada como proposta para a diretoria avaliar e as equipes validarem; nunca como norma vigente ou já validada. |
| Entrega | Peça do tema no aplicativo, no material de depois da aula, e PDF diagramado para imprimir ou levar à comissão do hospital. |

## Diretriz e protocolo: a diferença que vale aqui

A diretriz apoia a decisão: recomenda, diz a força e a certeza e deixa espaço para o julgamento clínico e para a
preferência do paciente. O protocolo é mais rígido: define passos que se seguem sem decidir. A peça do CUT é uma
diretriz que contém, dentro dela, os pontos protocolares do tema (por exemplo, a sequência de ativação do protocolo de
transfusão maciça), marcados como tal.

## Estrutura obrigatória

O formato é conferido pelo banco (`conteudo.conferir_formato`, SQL 88). São 19 seções obrigatórias e 1 condicional (base legal e ética). A falta de uma seção gera aviso: não bloqueia a
publicação, mas aparece na tela de revisão e na aba "Conferência dos temas".

```
# T00X — Proposta de guia de atendimento: <título do tema>

> PROPOSTA para avaliação da diretoria e validação pelas equipes listadas em "Equipes para validação". Não é norma vigente nem diretriz validada.

Diretriz clínica, fluxo de atendimento e regulação, qualidade e segurança do paciente.

                                  (A) Núcleo clínico
## Escopo e população
## Usuários e cenário
## Definições
## Recomendações
## Fluxograma
## Quadro-resumo
                                  (B) Fluxo de atendimento e regulação
## Fluxo de atendimento e regulação
## Matriz de responsabilidades
                                  (C) Qualidade e segurança do paciente
## Indicadores de qualidade
## Monitoramento e melhoria
## Segurança do paciente
                                  (D) Aplicação no serviço
## Adaptação local
## Implantação
## Exceções
## Base legal e ética          (só quando o tema tiver)
                                  (E) Governança
## Método e fontes
## Equipes para validação
## Grupo de elaboração e conflitos de interesse
## Limitações e lacunas
## Revisão
```

### Núcleo

**Escopo e população.** A pergunta clínica que a diretriz responde; quem está incluído (idade, mecanismo, gravidade,
cenário) e quem está fora, com o tema do curso que cobre os excluídos ("gestante: ver T119").

**Usuários e cenário.** Para quem a diretriz foi escrita (cirurgião, emergencista, residente, enfermagem, equipe de
trauma) e onde se aplica (sala de emergência, centro cirúrgico, UTI, enfermaria; hospital com ou sem cirurgião 24 h).

**Definições.** Os termos que mudam a conduta, com o critério objetivo (ex.: "instabilidade hemodinâmica: PAS < 90 mmHg
ou necessidade de transfusão em curso..."), citando a fonte da definição.

**Recomendações.** De 5 a 15 recomendações, numeradas, cada uma neste bloco:

```
**Recomendação 3.** Em adulto com trauma e sangramento significativo, administrar ácido tranexâmico até 3 horas
após o trauma.
Força: forte | Certeza: moderada
Origem: adotada de [G2] (diretriz X, 2023); consistente com [G4].
Justificativa: <benefício e dano, em números absolutos quando a fonte der; por que forte ou condicional>.
Na prática: <dose, momento, quem faz, o que conferir>.
Divergência: <quando as diretrizes discordam: qual diz o quê, e qual foi seguida pela regra da mais recente>.
```

- **Força** (GRADE): `forte` ("recomenda-se", "deve") ou `condicional` ("sugere-se", "pode"). Recomendação contra
  é escrita como contra ("Recomenda-se não...").
- **Certeza da evidência** (GRADE): `alta`, `moderada`, `baixa` ou `muito baixa`. Recomendação sem evidência e
  baseada só em consenso leva `Certeza: consenso de especialistas` e não pode ser forte sem dizer por quê.
- **Origem**: `adotada` (igual à da diretriz), `adaptada` (mudou a forma, a dose ou o cenário, e diz o quê) ou
  `própria` (nenhuma diretriz cobre; vem da literatura do tema). Sempre com o código da fonte de `afirmacoes.csv`.
- **Conflito entre fontes**: vale a mais recente, pela data de publicação; no mesmo ano, diretriz, depois revisão
  sistemática, depois ensaio, depois livro (regra de 19/11/2026). O conflito fica escrito em `Divergência:`.
- Pontos que são protocolo (sequência fixa) ganham a marca `Ponto de protocolo:` no início da linha `Na prática:`.

**Fluxograma.** O caminho de decisão num bloco ` ```mermaid ` (`flowchart TD`). Cada decisão do fluxograma remete à
recomendação que a sustenta ("R3").

**Quadro-resumo.** Uma tabela de uma página: recomendação, força, certeza. É o que vai para a parede do serviço.

### Bloco de fluxo de atendimento e regulação

**Fluxo de atendimento e regulação.** A linha de cuidado do tema, da entrada à saída, numa tabela por etapa:

| Etapa | Gatilho de entrada | O que acontece (recomendações) | Responsável | Tempo-alvo | Registro |
|---|---|---|---|---|---|

- Etapas típicas: aviso e regulação de entrada; chegada e passagem do caso; avaliação e tratamento; decisão de
  destino; transferência interna (centro cirúrgico, UTI, enfermaria) ou externa; passagem de cuidado; reavaliação e
  alta. Cada etapa remete às recomendações (R#) e ao fluxograma.
- Tempo-alvo só com fonte (diretriz, protocolo do serviço, livro). Sem fonte: `[meta a definir pelo serviço]`. Nunca
  inventar número.
- **Regulação.** Em subseção própria: como o caso chega (central de regulação de urgência, atendimento
  pré-hospitalar, demanda espontânea, transferência de outro hospital), quem aceita, critérios de transferência
  para fora quando falta recurso (contato médico a médico, condições de transporte, documentação), e a regulação
  interna de leitos (núcleo interno de regulação ou equivalente). Normas de regulação e transporte vêm da
  pasta de legislação do curso e entram no guia como referência numerada (ref. N), com "conferir a versão vigente".
- **Passagem de cuidado.** Como o caso é passado entre equipes (modelo estruturado do serviço; o curso sugere um,
  marcado como sugestão).

**Matriz de responsabilidades.** Tabela RACI: as atividades do fluxo nas linhas, os papéis nas colunas (líder do
atendimento, demais médicos, anestesiologia, enfermagem, técnicos, radiologia, agência transfusional, regulação ou
núcleo interno de regulação, coordenação do serviço, comissão de qualidade e segurança). R = executa; A = responde
pelo resultado (um só A por linha); C = consultado; I = informado. É sugestão do curso: o serviço confirma na
implantação.

### Bloco de qualidade e segurança do paciente

**Indicadores de qualidade.** De 3 a 8 indicadores, cada um com a ficha técnica completa numa tabela: nome, tipo
(estrutura, processo ou resultado), numerador, denominador, meta (com fonte, ou `[meta a definir pelo serviço]`),
fonte do dado, periodicidade, responsável pela coleta e responsável pela análise. Ao menos um indicador de processo
ligado a cada recomendação forte que se possa medir e ao menos um de resultado. Sempre agregados: nenhum dado
identificável de paciente. Eles alimentam o painel de desempenho (`docs/painel_desempenho_esqueleto.md`).

**Monitoramento e melhoria.** Como o serviço acompanha: quem coleta e quando; onde os totais são guardados; quem
analisa e em que reunião (comissão de qualidade, reunião de morbimortalidade); como é mostrado (gráfico mês a mês,
gráfico de controle com 12 meses ou mais); gatilhos de ação (ex.: abaixo da meta por 3 meses seguidos → análise de
causa e ciclo de melhoria PDSA); casos que vão sempre para revisão (óbito, evento adverso grave, lesão não
identificada, atraso além do tempo-alvo); auditoria por amostragem; relatório periódico à diretoria.

**Segurança do paciente.** Tabela de riscos do tema: risco, como acontece, barreira prevista no guia (R# ou etapa do
fluxo), protocolo básico de segurança relacionado (identificação do paciente, comunicação efetiva, segurança na
prescrição e administração de medicamentos e hemocomponentes, cirurgia segura, prevenção de quedas, prevenção de
lesão por pressão, higiene das mãos e prevenção de infecção) e o que notificar ao núcleo de segurança do paciente.
Evento grave: notificação e análise conforme a norma vigente, citada como referência numerada.

### Bloco de aplicação no serviço

**Adaptação local.** Lista de campos para o serviço preencher, sem valores inventados:
`[ ] Hemocomponentes disponíveis e tempo até a sala:`, `[ ] Quem aciona o protocolo e por qual telefone:`,
`[ ] Serviço de referência para transferência:`, `[ ] Exames disponíveis 24 h:`. Quando um recurso faltar, a
diretriz diz a alternativa (ex.: sem ROTEM, conduta guiada por fibrinogênio e plaquetas).

**Indicadores de qualidade.** De 2 a 5 indicadores para auditar a adesão, cada um com numerador, denominador, meta e
fonte do dado (ex.: "TXA em até 3 h: pacientes com TXA ≤ 3 h / pacientes com indicação; meta ≥ 90%; prontuário").
Sempre agregados: nenhum dado identificável de paciente.

**Implantação.** Pelo modelo de maturidade do curso (`docs/maturidade_implantacao.md`): níveis 0 (sem protocolo) a 5
(excelência, com processo e resultado ajustado no P90 da referência internacional). A seção traz: (1) a tabela do tema,
uma linha por nível, com objetivo, marcadores e indicadores do tema e o critério para passar ao nível seguinte;
(2) a execução passo a passo do nível 0 ao 2 (o que entregar, quem responde, prazo sugerido, nível ao terminar);
(3) a referência externa do P90 de cada indicador, com fonte e ano, ou a marca de que não há referência publicada
carregada (nunca um número inventado); (4) materiais de apoio e barreiras previsíveis.

**Exceções.** Situações em que a recomendação não se aplica ou precisa de outra conduta (gestação, anticoagulado,
criança, recusa de hemocomponente, idoso frágil), com o tema do curso que trata cada uma.

**Lista de checagem à beira do leito.** Não fica na diretriz: é a peça `checklist.md` do mesmo tema, derivada das
recomendações fortes.

### Base legal e ética (quando o tema tiver)

Consentimento, recusa, menor e incapaz, notificação compulsória, comunicação à autoridade, documentação obrigatória,
morte encefálica e doação. Cita a norma e o artigo como referência numerada (ref. N) em "Método e fontes" (ECA, Lei Maria da Penha,
Código de Ética Médica, Resoluções CFM 2.232/2019, 1.995/2012, 1.638/2002 e 2.173/2017, LGPD, Portaria de
Consolidação 4/2017 e outras). Lei e resolução podem ser citadas pelo texto do artigo; conferir a versão vigente.

### Bloco de governança

**Método e fontes.** Escrita para o leitor do serviço, sem citar nome de arquivo, pasta ou documento interno do curso.
(1) O método, em passos numerados: pergunta e escopo; busca no PubMed com a data e o número de registros; as duas
passadas (varredura ampla e filtro de desenho); diretrizes e consensos de sociedade dos últimos 10 anos, com a
qualidade avaliada pelos domínios do AGREE II; livros-texto; protocolos do serviço; extração com trecho literal;
graduação pelo GRADE; regra de conflito entre fontes; revisão. (2) A **linha de busca do PubMed escrita por inteiro**,
em bloco de código, e o filtro de desenho da segunda passada. (3) A subseção `### Referências`, em ABNT, numerada e
agrupada (diretrizes e consensos; livros-texto, com os capítulos usados; artigos; protocolos e documentos do serviço;
método; legislação e normas). Cada referência traz DOI e PMID quando houver e, no fim, os códigos de âncora que ela
sustenta (ex.: "[G1 a G7]"); no texto, as âncoras continuam entre colchetes e a legislação é citada como "ref. N".
Lei e resolução com "conferir a versão vigente". Documento institucional não publicado entra como tal. Dado
bibliográfico que não puder ser conferido (ano de edição, por exemplo) fica como `[a conferir]`, nunca inventado.

**Equipes para validação.** As equipes do hospital que precisam validar a diretriz antes da adoção, conforme a
pertinência ao tema, cada uma com o motivo (que recomendação ou etapa do fluxo depende dela) e se valida o texto
inteiro ou só as recomendações da sua área. A cirurgia de urgência e trauma conduz; entram, conforme o tema, medicina
de emergência, clínica médica, anestesiologia, terapia intensiva, radiologia e radiologia intervencionista,
hemoterapia, ortopedia, neurocirurgia, cirurgia de cabeça e pescoço, cirurgia vascular, cirurgia torácica, urologia,
ginecologia e obstetrícia, pediatria e cirurgia pediátrica, endoscopia, infectologia e controle de infecção, cuidados
paliativos, psiquiatria, enfermagem, farmácia, serviço social, atendimento pré-hospitalar e regulação, comissão de
qualidade e segurança do paciente, jurídico do hospital (temas com base legal). Formato: tabela com equipe, por que
participa, o que valida e situação (a convidar, em validação, validou em data).

**Grupo de elaboração e conflitos de interesse.** Quem redigiu (o rascunho é do agente produtor, sob supervisão da
coordenação), quem revisou (revisores cirurgiões do curso), quem aprovou e a declaração de conflitos de interesse de
cada um. Sem nome de revisor que não tenha autorizado.

**Limitações e lacunas.** O que a evidência não responde, as recomendações de certeza baixa e as perguntas que pedem
pesquisa (que podem virar projeto dos residentes).

**Situação da proposta** (dentro de "Revisão"). Uma linha fixa: "Situação: proposta; entregue à diretoria em [data];
validação pelas equipes: [a iniciar, em andamento, concluída em data]; adoção pelo serviço: [pendente, aprovada pela
instância X em data]". Até a diretoria aprovar, o texto continua dizendo "proposta".

**Revisão.** Data desta versão, data prevista da próxima (2 anos, ou antes se sair diretriz nova de uma das
sociedades da origem) e o histórico das versões.

## Regras de redação

- A diretriz é uma síntese com as próprias palavras do curso. Não copia parágrafos das diretrizes de origem: cita
  e resume. Trecho literal só em `afirmacoes.csv`, como em todas as peças.
- Cada recomendação tem âncora em `afirmacoes.csv` ([G#], [A#], [D#], [H#]); recomendação sem fonte não entra.
- Números absolutos quando a fonte der (redução de risco, NNT), com a ressalva do desenho do estudo.
- Linguagem de norma: frases curtas, verbo no início ("Administrar...", "Não realizar..."), sem marcas de texto de
  IA e sem emojis.
- Tamanho: de 3.000 a 7.000 palavras. Conta como peça de aprofundamento no tempo de estudo; o quadro-resumo e o
  fluxograma são o essencial para o plantão.

## PDF

Depois de publicado, o guia sai também em PDF com a identidade do CUT (capa com tema, versão e data; quadro-resumo
na primeira página; fluxograma em página própria; recomendações; anexos). O PDF é gerado a partir da peça publicada,
sem texto novo.

Como gerar (no Ubuntu do curso): `python3 ferramentas/diretriz_pdf.py conteudo/T00X/pecas/protocolo.md T00X_diretriz.pdf`.
Cores, fonte e logo vêm do Design System "CUT"; as recomendações fortes saem na caixa de CONDUTA.

## Base deste formato

- Nieuwlaat R et al. How to write a guideline: a proposal for a manuscript template that supports the creation of
  trustworthy guidelines. *Blood Adv.* 2021 (modelo de manuscrito de diretriz, McMaster/ASH).
- Agency for Clinical Innovation (NSW). *Developing and Implementing Clinical Guidelines*, versão 1.0, 2015.
- Hammond I. A guide to writing guidelines. *O&G Magazine* (RANZCOG), 2014.
- "Developing clinical practice guidelines and protocols" (diferença entre diretriz e protocolo).
- GRADE Handbook (força da recomendação e certeza da evidência), em `livros\Documentos\`.
