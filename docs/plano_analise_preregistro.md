# CUT · Plano de análise para pré-registro

Versão 1.3 (decisões da coordenação incorporadas; falta a revisão de um estatístico) · 17/11/2026

Este plano deve ser registrado (OSF Registries ou equivalente) **antes da abertura do primeiro pré-teste de 2027**, e
anexado ao protocolo do CEP com o dicionário de dados (`docs/dicionario_dados_pesquisa.md`).

Decisões da coordenação em 16/11/2026:
- graduação e egressos entram na análise principal;
- são esperados cerca de 40 alunos em 2027, com presença irregular nas aulas;
- o efeito mínimo que importa é de 10 pontos percentuais do pré-teste 1 ao D0;
- ainda não há meses de 2026 levantados no registro de trauma;
- o modelo principal roda em Python, integrado ao relatório.

## 1. Pergunta e desenho

**Pergunta.** Num curso de cirurgia de urgência e trauma com aprendizagem por testes espaçados, o conhecimento dos
residentes aumenta depois do material e da aula de cada tema? Quanto desse conhecimento fica guardado 15, 45 e 90 dias
depois? A certeza que o residente marca em cada questão acompanha o acerto?

**Desenho.** Coorte prospectiva com medidas repetidas, sem grupo controle. Cada tema tem seis ondas:
- pré-teste 1, 15 dias antes da aula;
- pré-teste 2, depois do material básico e antes da aula;
- pós-teste D0, logo depois da aula;
- pós-testes D+15, D+45 e D+90.

Cada participante é o próprio controle: a comparação é entre ondas, dentro da mesma pessoa e do mesmo tema.

**Participantes.** Todos os inscritos no CUT em 2027 que aceitarem o TCLE no aplicativo: residentes, alunos da
graduação e egressos. Todos entram na análise principal, com o grupo de ano como covariável: R1, R2, R3, R+ (R4 a R6,
egressos e preceptores que fazem o curso como alunos) e graduação.
- Excluídos: membros da equipe (preceptores, curadores, administradores, pesquisadores) e contas de teste ou simuladas.

## 2. Hipóteses

| | Hipótese | Tipo |
|---|---|---|
| H1 | O acerto no pós-teste D0 é maior que no pré-teste 1 (efeito do material e da aula) | **Primária** |
| H2 | O acerto no D+90 continua maior que no pré-teste 1 (retenção) | **Primária** |
| H3 | O acerto no pré-teste 2 é maior que no pré-teste 1 (efeito do material antes da aula) | Secundária |
| H4 | O acerto cai do D0 ao D+90, e a queda é menor nos temas em que o aluno fez mais revisão espaçada | Secundária / exploratória |
| H5 | A certeza acompanha o acerto (gamma > 0), e essa relação melhora ao longo do curso | Secundária |
| H6 | O erro cometido com "tenho certeza" é corrigido com mais frequência na onda seguinte do que o erro com pouca certeza (hipercorreção) | Exploratória |
| H7 | Os indicadores da sala de trauma melhoram depois que o tema é dado (nível 3 de Kirkpatrick) | Secundária |
| H8 | O uso de cada formato do material (texto, áudio, slides com fala, caso, flashcards) antes da aula se associa ao acerto no pré-teste 2 e no D0 | Exploratória |

## 3. Desfechos

- **Primário:** acerto em cada questão (0/1), por onda.
- **Secundários:**
  - % de acerto por teste;
  - acerto por nível de certeza;
  - gamma de Goodman-Kruskal entre certeza e acerto, por participante;
  - proporção mensal de cada indicador clínico;
  - avaliações e aplicabilidade autorrelatada.

## 4. Regras de inclusão e exclusão das respostas (fixadas antes da coleta)

1. Só respostas de quem consentiu (`consentiu`).
2. Exclui as respostas da equipe e das contas de teste ou simuladas (`equipe`, `simulado`).
3. Exclui as respostas dadas em menos de 3 segundos (`rapida`). Análise de sensibilidade: com elas.
4. **Pré-teste 2 feito depois da aula** (`apos_aula`): o conteúdo já tinha sido apresentado, então fica fora de H1 a H3.
   Análise de sensibilidade: comparar quem fez no prazo com quem fez depois.
5. Testes fora da janela (por exemplo, D+90 respondido depois de D+120) entram com o número de dias como covariável
   (`dias_da_aula`). Sensibilidade: sem eles.

## 5. Análise

**Modelo primário (H1, H2, H3).** Regressão logística com o acerto da questão como desfecho:
- efeito fixo da onda (pré-teste 1 como referência), do grupo de ano (R1 como referência) e do grau de dificuldade da
  questão;
- erro padrão robusto agrupado por participante (sanduíche, com correção G/(G−1)), que equivale a uma GEE com
  correlação de trabalho independente. As respostas da mesma pessoa não contam como independentes.
- Intervalos de confiança e p pela distribuição t com (número de participantes − 1) graus de liberdade, mais
  conservadora com poucos participantes.

Contrastes planejados:
- D0 × pré-teste 1 (H1);
- D+90 × pré-teste 1 (H2);
- pré-teste 2 × pré-teste 1 (H3).

Resultado: razão de chances com IC de 95% e a diferença em pontos percentuais de acerto, na média das outras
variáveis. As três comparações são corrigidas por Holm. A diferença é comparada com o efeito mínimo de 10 pontos.

**Implementação.** O modelo está em `analise/modelo_cut.py`, só com numpy e scipy, e entra no relatório gerado por
`analise/analise_cut_v1.0.py` (seção 5). Em 16/11/2026, duas conferências:
- os coeficientes bateram com os do scikit-learn (diferença menor que 10⁻⁷);
- com 40 participantes simulados, o erro padrão robusto bateu com o bootstrap por participante.

O modelo estima o efeito médio da população, que costuma ser um pouco menor que o efeito "por pessoa" de um modelo de
efeitos mistos.

**Sensibilidade com as questões âncora.** Cada tema tem de 2 a 3 questões âncora, iguais nas seis ondas e para todos
os anos (`fixa` na base). O modelo principal é repetido só com elas. Se o efeito for parecido, a diferença entre as
questões de cada onda não explica o resultado. O aluno vê o gabarito da âncora ao fim de cada onda: isso faz parte da
intervenção (aprendizagem por testes) e entra nas limitações. Implementado no relatório (seção 5).

**Análise de sensibilidade.** Regressão logística de efeitos mistos (participante, questão e tema como efeitos
aleatórios), rodada por um estatístico em R, se houver um disponível. Código para o estatístico:

```r
library(lme4); library(emmeans)
b <- read.csv2("base_respostas.csv")              # aba "Base de análise" do painel
b <- subset(b, valida == "t")
b$onda <- factor(b$teste_num, levels = 1:6, labels = c("pre1","pre2","D0","D15","D45","D90"))
m <- glmer(correta == "t" ~ onda + ano + dificuldade + (1 | participante) + (1 | item) + (1 | tema),
           data = b, family = binomial, control = glmerControl(optimizer = "bobyqa"))
emmeans(m, trt.vs.ctrl ~ onda, type = "response", adjust = "holm")
```

**Retenção (H4).** Mesmo modelo, só com as ondas D0 a D+90 e os dias desde a aula como variável contínua: razão de
chances por 30 dias. A interação dias × número de revisões espaçadas feitas no tema é exploratória.

**Calibração (H5).**
- Acerto por nível de certeza, e a razão de chances de acerto com "acho que sim" e "tenho certeza" em relação a
  "chutei", no mesmo modelo, ajustado por onda, ano e dificuldade.
- Gamma de Goodman-Kruskal por participante, comparado com zero pelo teste de Wilcoxon.
- Mudança do gamma entre as ondas antes e depois da aula: modelo misto com o participante como efeito aleatório.

**Hipercorreção (H6, exploratória).** Nas questões que se repetem entre ondas: depois de um erro, a chance de acertar na
onda seguinte, conforme a certeza do erro. Regressão logística mista com o participante como efeito aleatório.

**Indicadores clínicos (H7, exploratória).** Ainda não há meses de 2026 levantados no registro de trauma. Por isso:
- a coordenação passa a registrar os totais mensais a partir de dezembro de 2026, no painel (aba "Indicadores
  clínicos"); os meses antes do início do curso servem de linha de base;
- como os temas são dados em datas diferentes, cada indicador é comparado antes e depois do tema correspondente (por
  exemplo, temperatura na admissão antes e depois do T001), usando os indicadores de temas ainda não dados como
  comparação no mesmo período;
- com menos de 6 meses antes do tema, a análise é só descritiva (gráfico mensal, sem teste).

H7 passa a ser exploratória.

**Uso do material por formato (H8, exploratória).** Incluída em 17/11/2026, antes de qualquer coleta. O curso oferece
o mesmo conteúdo em vários formatos e não pergunta ao aluno o seu "estilo de aprendizagem". A ideia de ensinar no
estilo preferido de cada aluno não tem apoio experimental (Pashler et al., 2008, doi:10.1111/j.1539-6053.2009.01038.x),
e estudos com o questionário VARK medem só a preferência declarada, sem desempenho (por exemplo, Ullrich e Obisesan,
J Surg Educ 2026, doi:10.1016/j.jsurg.2026.104252). Por isso, a análise usa o uso real do material, já registrado pelo
aplicativo (`uso_material` e `leitura_tempo`, no dicionário de dados), e não um questionário.
- **Exposição:** para cada aluno e tema, os minutos com cada formato antes da hora da aula, agrupados em: texto
  (resumo básico, resumo executivo, síntese, protocolo, objetivos), áudio (podcast), slides com fala, caso (caso base e
  caso da aula) e revisão ativa (flashcards e banco de questões). Também o número de formatos usados (0 a 5).
- **Modelo:** o mesmo modelo primário, com o acerto da questão como desfecho, só no pré-teste 2 e no D0, ajustado pelo
  acerto do mesmo aluno no pré-teste 1 do tema, pelo ano e pela dificuldade, com os minutos por formato (escala
  logarítmica, log(1 + minutos)) e o número de formatos como variáveis. Erro padrão agrupado por participante.
- **Leitura:** associação, não causa. Quem estuda mais tende a acertar mais por outros motivos (motivação, tempo livre,
  experiência), e o tempo com a tela aberta não garante leitura. Nenhum resultado desta análise muda o material de um
  aluno durante o curso.
- **Descritiva:** a proporção de alunos que usa cada formato, por ano e por tema, entra no relatório mesmo sem teste.

**Dados faltantes.** Os modelos mistos usam todas as ondas respondidas (ausência aleatória condicional às variáveis do
modelo). O relatório traz o abandono por onda. Sensibilidade: só quem respondeu as seis ondas do tema.

**Questões.** Antes da análise confirmatória, cada questão passa pela análise de itens (`app.analise_itens()`, só com
dados válidos). A questão com gabarito errado, ou com discriminação negativa em mais de 30 respostas, é retirada de
todas as ondas daquele tema. A lista das retiradas e o motivo vão no relatório. Essa regra está fixada aqui para não
ser decidida depois de ver o resultado.

## 6. Tamanho da amostra

São esperados cerca de 40 alunos em 2027, com presença irregular. O poder foi estimado por simulação em 16/11/2026
(`analise/poder_cut_v1.0.py`), com as hipóteses abaixo:
- 7 questões por onda;
- 60% de chance de o aluno fazer cada onda de cada tema;
- variação entre alunos, temas e questões compatível com testes de múltipla escolha;
- acerto de 55% no pré-teste 1;
- teste pareado das médias por aluno, com α de 0,05 dividido por 3 (Holm, no pior caso). É mais conservador que o
  modelo principal.

| Temas analisados juntos | Poder para 10 pontos (D0 × pré-teste 1) | Poder para 5 pontos |
|---|---|---|
| 1 | 0,14 | 0,03 |
| 3 | 0,35 | 0,08 |
| 10 | 0,87 | 0,31 |
| 39 (todos os principais) | 1,00 | 0,90 |

**Consequência para o plano.** Um tema sozinho não tem poder para nada. A análise confirmatória junta todos os temas do
ano, com o tema no modelo. Com uns 10 temas já se detecta o efeito mínimo de 10 pontos. A retenção no D+90 (efeito
esperado menor, perto de 5 pontos) precisa do ano inteiro. Por isso:
- a análise confirmatória acontece ao fim de 2027;
- análises parciais, tema a tema, são descritivas e não testam hipótese.

## 7. Limitações declaradas desde já

- Sem grupo controle: o ganho do pré-teste ao D0 inclui o efeito de repetir o teste (efeito de testagem), que é parte
  da intervenção.
- As formas das ondas não são idênticas: cada onda tem questões próprias, além das 2 ou 3 âncoras que se repetem. A
  âncora repetida, com gabarito visto ao fim de cada onda, mede também a memória da própria questão. O efeito aleatório
  da questão e a análise de itens reduzem esse viés, mas não o eliminam.
- A aplicabilidade é autorrelatada.
- O uso do material por formato (H8) é medido pelo tempo com a peça aberta na tela, que não garante leitura nem
  atenção; e quem usa mais o material pode diferir de quem usa menos por motivos não medidos.
- Os indicadores clínicos são do serviço como um todo, não só dos residentes do curso, e mudam por outros motivos. Sem
  linha de base de 2026, a comparação fica limitada aos meses registrados a partir de dezembro de 2026.
- O modelo principal estima o efeito médio da população (erro padrão agrupado), não o efeito por pessoa de um modelo
  de efeitos mistos. O modelo misto entra como sensibilidade, se houver estatístico para rodar.
- Com presença irregular, quem faz mais ondas pode ser diferente de quem faz menos. O relatório mostra o acerto
  conforme o número de ondas feitas.

## 8. O que muda o plano depois do registro

Nenhuma decisão de análise muda depois de ver os dados de 2027. Se algo precisar mudar (por exemplo, por erro no
banco), a mudança é registrada com data e motivo e declarada no artigo como desvio do plano.

## 9. Ensaio com os dados simulados (16/11/2026)

O script `analise/analise_cut_v1.0.py` rodou nos cinco residentes simulados. Ele gera o relatório deste plano, com o
modelo principal:
- qualidade dos dados;
- curva por onda com IC por bootstrap;
- ganho e retenção por participante;
- calibração e hipercorreção;
- questões.

O ensaio mostrou que as regras de exclusão funcionam:
- a residente simulada que recusou a pesquisa saiu da base do pesquisador;
- as respostas rápidas demais saíram;
- o pré-teste 2 feito depois da aula saiu.

Os números do ensaio não descrevem residentes reais.
