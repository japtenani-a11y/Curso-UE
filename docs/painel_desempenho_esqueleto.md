# CUT · Esqueleto do painel de desempenho para o serviço (proposta, não aplicada)

Versão 0.2 · 19/11/2026 · Decisão da coordenação de 19/11/2026: mostrar como o painel seria montado, sem aplicar.
A versão 0.2 usa como base o material da C3 e das fichas do trauma no prontuário (MVPEP) enviado pela coordenação em
19/11/2026: dicionário das fichas C1 a C8, 68 indicadores com fórmula e fonte, base C3 (planilha com código do paciente
no lugar do registro e aba de resumo) e o painel de vigilância on-line.

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

## Como encaixa na C3 e nas fichas do prontuário (base de 19/11/2026)

| Camada | No serviço | Observação |
|---|---|---|
| 1. Registro | Fichas C1 (atendimento inicial), C2 (admissão, com revisão terciária), C3 (codificação das lesões: AIS, ISS, NISS, RTS, TRISS), C4 (evolução), C5 (alta), C6 (retorno), C7 (revisão de óbito e evento grave) e C8 (transferência de cuidados e passagem de plantão, no formato S-xABCDE-BAR), em três degraus: cenário A (textos-padrão), B (campos nas fichas atuais) e C (fichas próprias) | O curso não toca esta camada |
| 2. Totais | Base C3 (planilha do serviço ou do Google, com o código P-… no lugar do registro) e a aba Resumo: ISS mediano, trauma maior, mortalidade, TRISS, estatística W, óbitos inesperados para a C7, fragilidade, RFS, lesões NFS | Só os totais saem da base; o registro não sai do hospital |
| 3. Catálogo | Os 68 indicadores do serviço (fórmula, fonte, cenário a partir do qual saem automáticos) mais os indicadores de cada guia do curso | Cada indicador de guia leva o número do indicador do serviço quando for o mesmo |
| 4. Painel | Painel de vigilância on-line da C3 (já existente) e o painel de desempenho do curso | O do curso mostra o nível de maturidade de cada guia e a série dos indicadores |

### Indicadores do guia T001 e o indicador correspondente do serviço

| Indicador do guia T001 | Indicador do serviço (nº) | Campo de origem | Sai automático a partir do |
|---|---|---|---|
| Temperatura na admissão | 11 Temperatura aferida na chegada | C1_TEMP | Cenário A |
| Hipotensão ou parada após a intubação | 12 Hipotensão ou parada após a IOT | C1_VA_HEMO | Cenário B |
| Ácido tranexâmico em até 3 horas do trauma | 4 ATX em até 3 h do trauma | C1_TRAUMA_DH + C1_ATX_DH | Cenário B |
| Porta-tomografia | 5 Tempo porta-TC (mediana e P90) | Movimentação de leito | Cenário A |
| Porta-centro cirúrgico no hipotenso | 7 Porta-CC no hipotenso | C1_PAS + movimentação | Cenário A |
| Avaliação terciária registrada | 62 Revisão terciária em até 24 h | C2_TERCIARIA | Cenário B |
| Lesão com diagnóstico tardio | 66 Lesão não diagnosticada | C2 + C3 | Cenário C |
| Mortalidade ajustada pela gravidade | 47 Razão observado/esperado e 48 W | C1 + C3 + alta | Cenário C |
| Óbitos inesperados revisados | 50 Óbitos inesperados revisados | C3 + C7 | Cenário C |
| Pausa de segurança antes de sair da sala | 65 Transferências documentadas (C8) | C8 | Cenário B |
| Líder definido antes da chegada | sem correspondente (C1 registra o preceptor líder, não o momento) | C1_PRECEPTOR | Pergunta de adaptação local |
| Passagem estruturada do pré-hospitalar | sem correspondente | — | Pergunta de adaptação local |
| Via aérea avaliada e registrada | sem correspondente direto (C1_VA registra a via aérea definitiva) | C1_VA | Pergunta de adaptação local |
| Cinta pélvica na fratura instável | sem correspondente (C1_APH_PROC e C1_TORNIQUETE_DH registram a cinta) | C1_APH_PROC | Pergunta de adaptação local |

## O que falta para aplicar

- Decidir se o painel do curso lê os totais da aba Resumo da base C3 (exportação mensal só de totais) ou se os
  totais continuam digitados pela coordenação.
- Quem no serviço extrai os totais do mês e quem é responsável por cada linha de cuidado.
- A aprovação da comissão de qualidade do hospital.
- A base C3 tem dado de paciente (mesmo com o código P-…): o curso nunca recebe a base, só os totais.
