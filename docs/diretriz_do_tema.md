# CUT · Diretriz clínica do tema (a peça "protocolo")

Versão 1.0 · 19/11/2026 · Decisão da coordenação de 19/11/2026.

A peça `pecas/protocolo.md` de cada tema deixa de ser um fluxograma com orientações. Ela passa a ser uma **diretriz
clínica**: uma norma de conduta escrita, com recomendações graduadas, justificadas e rastreáveis até a fonte, que um
serviço pode adotar.

## O que foi decidido

| Ponto | Decisão |
|---|---|
| Método | **Adaptação de diretrizes existentes.** Cada recomendação parte das diretrizes publicadas (EAST, WSES, AAST, WTA, ACS COT/ATLS, SBAIT, CBC, ERC, NICE e as da especialidade do tema), recebe força e certeza pelo GRADE e diz se foi adotada, adaptada ou se diverge da fonte, e por quê. |
| Para quem | **Diretriz do curso, adaptável.** Vale para qualquer serviço. A seção "Adaptação local" traz os campos que cada hospital preenche: recursos disponíveis, quem aciona, para onde transferir e contatos. |
| Partes | Núcleo, bloco de qualidade, bloco de governança e, quando o tema tiver, base legal e ética. |
| Entrega | Peça do tema no aplicativo, no material de depois da aula, e PDF diagramado para imprimir ou levar à comissão do hospital. |

## Diretriz e protocolo: a diferença que vale aqui

A diretriz apoia a decisão: recomenda, diz a força e a certeza e deixa espaço para o julgamento clínico e para a
preferência do paciente. O protocolo é mais rígido: define passos que se seguem sem decidir. A peça do CUT é uma
diretriz que contém, dentro dela, os pontos protocolares do tema (por exemplo, a sequência de ativação do protocolo de
transfusão maciça), marcados como tal.

## Estrutura obrigatória

O formato é conferido pelo banco (`conteudo.conferir_formato`, SQL 88). A falta de uma seção gera aviso: não bloqueia a
publicação, mas aparece na tela de revisão e na aba "Conferência dos temas".

```
# T00X — Diretriz clínica: <título do tema>

## Escopo e população
## Usuários e cenário
## Definições
## Recomendações
## Fluxograma
## Quadro-resumo
## Adaptação local
## Indicadores de qualidade
## Exceções
## Base legal e ética          (só quando o tema tiver)
## Método e fontes
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

### Bloco de qualidade

**Adaptação local.** Lista de campos para o serviço preencher, sem valores inventados:
`[ ] Hemocomponentes disponíveis e tempo até a sala:`, `[ ] Quem aciona o protocolo e por qual telefone:`,
`[ ] Serviço de referência para transferência:`, `[ ] Exames disponíveis 24 h:`. Quando um recurso faltar, a
diretriz diz a alternativa (ex.: sem ROTEM, conduta guiada por fibrinogênio e plaquetas).

**Indicadores de qualidade.** De 2 a 5 indicadores para auditar a adesão, cada um com numerador, denominador, meta e
fonte do dado (ex.: "TXA em até 3 h: pacientes com TXA ≤ 3 h / pacientes com indicação; meta ≥ 90%; prontuário").
Sempre agregados: nenhum dado identificável de paciente.

**Exceções.** Situações em que a recomendação não se aplica ou precisa de outra conduta (gestação, anticoagulado,
criança, recusa de hemocomponente, idoso frágil), com o tema do curso que trata cada uma.

**Lista de checagem à beira do leito.** Não fica na diretriz: é a peça `checklist.md` do mesmo tema, derivada das
recomendações fortes.

### Base legal e ética (quando o tema tiver)

Consentimento, recusa, menor e incapaz, notificação compulsória, comunicação à autoridade, documentação obrigatória,
morte encefálica e doação. Cita a norma e o artigo, a partir de `livros\LegislacaoBR\` (ECA, Lei Maria da Penha,
Código de Ética Médica, Resoluções CFM 2.232/2019, 1.995/2012, 1.638/2002 e 2.173/2017, LGPD, Portaria de
Consolidação 4/2017 e outras). Lei e resolução podem ser citadas pelo texto do artigo; conferir a versão vigente.

### Bloco de governança

**Método e fontes.** Como as diretrizes foram escolhidas: a busca do tema (`BUSCAS_PUBMED_150_temas.txt`, filtro de
diretriz dos últimos 10 anos), as diretrizes encontradas e por que cada uma entrou ou saiu (data, escopo, qualidade
metodológica, por exemplo pelos domínios do AGREE II), e como a força e a certeza foram atribuídas. Lista as fontes
com o código de `fontes.csv`.

**Grupo de elaboração e conflitos de interesse.** Quem redigiu (o rascunho é do agente produtor, sob supervisão da
coordenação), quem revisou (revisores cirurgiões do curso), quem aprovou e a declaração de conflitos de interesse de
cada um. Sem nome de revisor que não tenha autorizado.

**Limitações e lacunas.** O que a evidência não responde, as recomendações de certeza baixa e as perguntas que pedem
pesquisa (que podem virar projeto dos residentes).

**Revisão.** Data desta versão, data prevista da próxima (2 anos, ou antes se sair diretriz nova de uma das
sociedades da origem) e o histórico das versões.

## Regras de redação

- A diretriz é uma síntese com as próprias palavras do curso. Não copia parágrafos das diretrizes de origem: cita
  e resume. Trecho literal só em `afirmacoes.csv`, como em todas as peças.
- Cada recomendação tem âncora em `afirmacoes.csv` ([G#], [A#], [D#], [H#]); recomendação sem fonte não entra.
- Números absolutos quando a fonte der (redução de risco, NNT), com a ressalva do desenho do estudo.
- Linguagem de norma: frases curtas, verbo no início ("Administrar...", "Não realizar..."), sem marcas de texto de
  IA e sem emojis.
- Tamanho: de 1.500 a 4.000 palavras. Conta como peça de aprofundamento no tempo de estudo; o quadro-resumo e o
  fluxograma são o essencial para o plantão.

## PDF

Depois de publicada, a diretriz sai também em PDF com a identidade do CUT (capa com tema, versão e data; quadro-resumo
na primeira página; fluxograma em página própria; recomendações; anexos). O PDF é gerado a partir da peça publicada,
sem texto novo.

## Base deste formato

- Nieuwlaat R et al. How to write a guideline: a proposal for a manuscript template that supports the creation of
  trustworthy guidelines. *Blood Adv.* 2021 (modelo de manuscrito de diretriz, McMaster/ASH).
- Agency for Clinical Innovation (NSW). *Developing and Implementing Clinical Guidelines*, versão 1.0, 2015.
- Hammond I. A guide to writing guidelines. *O&G Magazine* (RANZCOG), 2014.
- "Developing clinical practice guidelines and protocols" (diferença entre diretriz e protocolo).
- GRADE Handbook (força da recomendação e certeza da evidência), em `livros\Documentos\`.
