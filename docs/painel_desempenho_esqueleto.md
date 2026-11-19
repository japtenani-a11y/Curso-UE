# CUT · Esqueleto do painel de desempenho para o serviço (proposta, não aplicada)

Versão 0.1 · 19/11/2026 · Decisão da coordenação de 19/11/2026: mostrar como o painel seria montado, sem aplicar,
até termos o modelo da ficha C3 e do painel de vigilância do HCFMRP-USP.

## Ideia

Cada diretriz clínica do curso traz de 2 a 5 indicadores de qualidade (numerador, denominador, meta, fonte). Juntos,
eles formam o catálogo de indicadores do serviço. O painel mostra, mês a mês, como o serviço está em cada indicador,
no mesmo formato do painel da vigilância da ficha C3, para a comissão de qualidade e a reunião de morbimortalidade.

## As quatro camadas

| Camada | O que é | De onde vem |
|---|---|---|
| 1. Registro | O que acontece com cada paciente (horários, condutas, desfechos) | Ficha da sala de trauma, ficha C3, prontuário, sistemas da radiologia e da agência transfusional |
| 2. Totais do mês | Numerador e denominador de cada indicador, sem nenhum dado que identifique paciente | Extraído do registro pelo serviço (planilha ou consulta) |
| 3. Catálogo de indicadores | Definição, meta, fonte, responsável e diretriz de origem de cada indicador | Diretrizes do curso (seção "Indicadores de qualidade") |
| 4. Painel | Gráficos e semáforo por linha de cuidado | Montado a partir das camadas 2 e 3 |

O curso só toca as camadas 3 e 4. A camada 1 é do serviço; a camada 2 é digitada pela coordenação, como já acontece
com os indicadores clínicos do CUT (`app.indicador_clinico`).

## Catálogo de indicadores (formato)

| Campo | Exemplo (T001) |
|---|---|
| Código | IND-T001-1 |
| Nome | Líder definido antes da chegada |
| Linha de cuidado | Sala de trauma |
| Tipo | Processo (estrutura, processo ou resultado) |
| Numerador | Atendimentos com líder registrado antes da chegada |
| Denominador | Atendimentos com aviso prévio |
| Meta | ≥ 90% |
| Fonte do dado | Ficha da sala de trauma |
| Periodicidade | Mensal |
| Responsável | [a definir pelo serviço] |
| Diretriz de origem | T001, recomendação 1 |
| Campo da ficha C3 | [preencher quando tivermos o modelo da ficha] |

## Linhas de cuidado do painel

1. **Sala de trauma:** indicadores do T001 e dos temas de via aérea, choque, transfusão e imagem.
2. **Centro cirúrgico de urgência:** tempo até a cirurgia, checklist de cirurgia segura, reoperação não planejada.
3. **UTI cirúrgica:** ventilação, sepse, lesão renal, delirium.
4. **Enfermaria e alta:** avaliação terciária, tromboprofilaxia, infecção de sítio cirúrgico, readmissão.
5. **Desfechos gerais:** mortalidade ajustada (TRISS ou equivalente), tempo de internação, eventos adversos.

## Como cada indicador é mostrado

- Gráfico de linha mês a mês (gráfico de controle quando houver 12 meses ou mais), com a meta em linha tracejada.
- Semáforo: na meta; abaixo da meta em um mês; abaixo da meta em três meses seguidos (vai para a reunião de qualidade).
- Número de casos do mês junto do percentual (percentual de denominador pequeno engana).
- Nenhum dado de paciente: só totais.

## O que falta para aplicar

- O modelo da ficha C3 em branco e uma captura do painel de vigilância atual (ou a lista dos indicadores dele), sem
  dado de paciente, para alinhar nomes, campos e formato.
- Quem no serviço extrai os totais do mês e quem é responsável por cada linha de cuidado.
- A aprovação da comissão de qualidade do hospital.

Com isso, o painel pode virar uma aba do aplicativo (como a de indicadores clínicos) ou um artefato compartilhável.
