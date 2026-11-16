# CUT · Plano de análise para pré-registro

Versão 1.0 (rascunho para decisão da coordenação e revisão de um estatístico) · 16/11/2026

Este plano deve ser registrado (OSF Registries ou equivalente) **antes da abertura do primeiro pré-teste de 2027**, e
anexado ao protocolo do CEP com o dicionário de dados (`docs/dicionario_dados_pesquisa.md`). As decisões marcadas com
**[decidir]** dependem da coordenação.

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

**Participantes.** Residentes e alunos inscritos no CUT em 2027 que aceitarem o TCLE no aplicativo.
- Excluídos: membros da equipe (preceptores, curadores, administradores, pesquisadores) e contas de teste ou simuladas.
- [decidir] Graduação e egressos entram como grupos à parte ou ficam de fora da análise primária?

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

**Modelo primário (H1, H2, H3).** Regressão logística de efeitos mistos com o acerto da questão como desfecho:
- efeito fixo da onda (pré-teste 1 como referência) e do ano de residência;
- efeitos aleatórios do participante, da questão e do tema.

Contrastes planejados:
- D0 × pré-teste 1 (H1);
- D+90 × pré-teste 1 (H2);
- pré-teste 2 × pré-teste 1 (H3).

Os resultados vêm como razão de chances com IC de 95%. As três comparações são corrigidas por Holm.

```r
library(lme4); library(emmeans)
b <- read.csv2("base_respostas.csv")              # aba "Base de análise" do painel
b <- subset(b, valida == "t")
b$onda <- factor(b$teste_num, levels = 1:6, labels = c("pre1","pre2","D0","D15","D45","D90"))
m <- glmer(correta == "t" ~ onda + ano + (1 | participante) + (1 | item) + (1 | tema),
           data = b, family = binomial, control = glmerControl(optimizer = "bobyqa"))
emmeans(m, trt.vs.ctrl ~ onda, type = "response", adjust = "holm")   # H1, H2, H3
```

**Retenção (H4).** Mesmo modelo, só com as ondas D0 a D+90 e os dias desde a aula como variável contínua. A interação
dias × número de revisões espaçadas feitas no tema é exploratória.

**Calibração (H5).**
- Acerto por nível de certeza.
- Gamma de Goodman-Kruskal por participante, comparado com zero pelo teste de Wilcoxon.
- Mudança do gamma entre as ondas antes e depois da aula: modelo misto com o participante como efeito aleatório.

**Hipercorreção (H6, exploratória).** Nas questões que se repetem entre ondas: depois de um erro, a chance de acertar na
onda seguinte, conforme a certeza do erro. Regressão logística mista com o participante como efeito aleatório.

**Indicadores clínicos (H7).** Série temporal interrompida (regressão segmentada) da proporção mensal de cada indicador,
com o corte no mês em que o tema correspondente é dado. São pelo menos 12 meses antes e 12 depois. [decidir] Quais
meses de 2026 a coordenação consegue levantar no registro de trauma do serviço?

**Dados faltantes.** Os modelos mistos usam todas as ondas respondidas (ausência aleatória condicional às variáveis do
modelo). O relatório traz o abandono por onda. Sensibilidade: só quem respondeu as seis ondas do tema.

**Questões.** Antes da análise confirmatória, cada questão passa pela análise de itens (`app.analise_itens()`, só com
dados válidos). A questão com gabarito errado, ou com discriminação negativa em mais de 30 respostas, é retirada de
todas as ondas daquele tema. A lista das retiradas e o motivo vão no relatório. Essa regra está fixada aqui para não
ser decidida depois de ver o resultado.

## 6. Tamanho da amostra

O número de residentes de 2027 é fixo: todos os inscritos que consentirem. [decidir] Estimativa de inscritos.

O poder vai ser estimado por simulação antes do registro. O script `90_simulacao_5_residentes_v1.0.sql` gera dados no
formato real. Repetindo a simulação com o número esperado de residentes e o efeito mínimo de interesse, a coordenação
vê com que frequência o modelo primário detecta o efeito. [decidir] Efeito mínimo de interesse (sugestão: 10 pontos
percentuais de D0 sobre pré-teste 1).

## 7. Limitações declaradas desde já

- Sem grupo controle: o ganho do pré-teste ao D0 inclui o efeito de repetir o teste (efeito de testagem), que é parte
  da intervenção.
- As formas das ondas não são idênticas: cada onda tem questões próprias, além das que se repetem. O efeito aleatório
  da questão e a análise de itens reduzem esse viés, mas não o eliminam.
- A aplicabilidade é autorrelatada.
- Os indicadores clínicos são do serviço como um todo, não só dos residentes do curso, e mudam por outros motivos.

## 8. O que muda o plano depois do registro

Nenhuma decisão de análise muda depois de ver os dados de 2027. Se algo precisar mudar (por exemplo, por erro no
banco), a mudança é registrada com data e motivo e declarada no artigo como desvio do plano.

## 9. Ensaio com os dados simulados (16/11/2026)

O script `analise/analise_cut_v1.0.py` rodou nos cinco residentes simulados. Ele gera o relatório descritivo deste plano:
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
