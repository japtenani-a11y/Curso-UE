# CUT · Rotina da coordenação com agentes

Versão 1.0 · 16/11/2026 · SQL 89, `ponte_coordenacao_v1.0.sh`, aba "Para revisar" do painel.

## O princípio

Os agentes preparam e a coordenação decide. Os agentes não têm acesso ao banco. Eles leem uma pasta e escrevem propostas
nela. Nada chega ao aluno nem vira parecer sem a decisão de uma pessoa da coordenação (admin, curador ou responsável
pelos dados) na aba **Para revisar**. Cada proposta tem três saídas:

| Decisão | O que acontece |
|---|---|
| Aprovar | O sistema executa como veio: publica a resposta, registra o parecer, envia o lembrete ou lança o indicador. |
| Aprovar com a alteração | Executa a versão que você editou. A diferença fica guardada. |
| Vetar | Não executa nada. O motivo é obrigatório e o agente o lê na rodada seguinte. |

A tabela no alto da aba mostra, por agente:
- o que está aguardando e há quanto tempo;
- quanto foi aprovado como veio, alterado ou vetado nos últimos 60 dias.

Esse é o termômetro de qualidade: um agente bom tem muita aprovação como veio e pouco veto.

## Como os dados andam

```
banco do CUT (WSL) --ponte, a cada 10 min--> C:\Users\<você>\CUT_coordenacao\entrada\<agente>.json
agente (tarefa agendada no computador) lê entrada\ e grava propostas\<agente>_<data>.json
ponte --> banco: propostas aguardando --> aba "Para revisar" --> sua decisão --> execução
```

- **Onde fica a pasta.** Fora do OneDrive de propósito, porque tem texto das dúvidas e o primeiro nome dos alunos.
- **Arquivo recusado.** Um arquivo de proposta fora do formato vai para `com_erro\`, com o motivo ao lado.
- **Dados que os agentes nunca recebem:** e-mail, nome completo, telefone, notas individuais com nome e dados de paciente.

## Os oito agentes

Desde 17/11/2026 o trabalho dos agentes fica entre 1h e 6h, quando o computador fica ligado. Cada um tem uma reserva na nuvem
uma hora depois (horários em `agente_produtor.md`). O produtor de temas é descrito em `agente_produtor.md`.

| Agente | Quando roda | Entrada | O que propõe | Ao aprovar |
|---|---|---|---|---|
| Dúvidas dos alunos | Todo dia, 5h10 | Dúvidas sem resposta, material publicado do tema, respostas anteriores | Resposta (`resposta`) ou alerta (`alerta`: dado de paciente, pergunta fora do escopo, conduta de caso real) | A resposta é publicada e o aluno é avisado |
| Revisor de conteúdo | Todo dia, 4h10 | Até 120 textos de afirmação sem parecer (cada texto vale para todas as peças em que aparece), do tema com aula mais próxima, com o trecho citado e o contexto da fonte; referências do tema | Parecer sugerido por afirmação: aprovar, conferir melhor ou reprovar (`parecer`) | O parecer entra na revisão em seu nome, marcado como sugerido pelo agente |
| Pré-revisão das peças | Todo dia, 3h20 | Rascunhos novos, com a conferência de formato, o tempo de estudo, a versão publicada anterior e, para as peças da aula, o material de antes da aula | Veredito (pronta, ajustar ou refazer) e lista de problemas com a correção, incluindo a teoria repetida na aula (`pre_revisao`) | Fica registrado; a correção da peça é feita na produção |
| Alunos atrasados | Segunda-feira, 5h17 | Alunos ativos com testes vencendo, atrasados ou perdidos | Relatório da semana (`relatorio`) e lembrete personalizado por aluno (`lembrete`) | O lembrete sai por e-mail e aviso no celular, só para quem autorizou |
| Indicadores clínicos | Dia 5 de cada mês, 4h33 | Meses já lançados e planilha de totais em `CUT_coordenacao\indicadores\` | Lançamento por indicador e mês (`lancamento`) ou pendência (`pendencia`) | O total do mês entra no painel de indicadores |
| Triador de fontes | Todo dia, 1h47 | PDFs soltos em `CUT_coordenacao\fontes_novas` (a ponte extrai o texto, recusa o que tem cara de dado de paciente e registra) e o catálogo dos 150 temas | Referência conferida no PubMed, camada e todos os temas em que a fonte serve, inclusive os ainda não produzidos (`fonte`), ou recusa | Aprovação automática: assim que o arquivo chega, a fonte fica guardada com o texto integral em cada tema indicado (`conteudo.fonte`). A coordenação não precisa decidir |
| Supervisor | Todo dia, 5h43 (resumo do dia; na sexta, também a auditoria) | Pacotes de todos os agentes, estado da ponte, arquivos recusados, relatórios | Não propõe: escreve o resumo do dia (o que decidir primeiro) e a auditoria semanal da qualidade de cada agente, com a mudança sugerida na skill dele | — |
| Produtor de temas | Todo dia, 1h07 e 13h07 | Tema liberado em `producao\liberados.csv`: fontes do tema, pré-revisões e pareceres que voltaram | Não propõe pelo painel: escreve o material do tema em RASCUNHO em `producao\<TEMA>\`, e a ponte grava no banco | As peças seguem a revisão de sempre |

## Prazos da coordenação

- **Dúvidas.** Resposta publicada em até 24 horas: o agente roda de manhã e a revisão é diária. A aba avisa as dúvidas
  sem resposta há mais de 24 horas.
- **Peças e conteúdo.** Revisão diária do que chegou.
- **Atrasados.** Decisão na segunda-feira, para o lembrete sair no mesmo dia.
- **Indicadores.** Lançamento até o dia 10 do mês seguinte.

## Formato do arquivo de propostas

```json
{"agente": "duvidas", "rodada": "2026-11-16 06:40",
 "propostas": [{"tipo": "resposta", "alvo": {"mensagem_id": 12}, "titulo": "...",
   "proposta": {"texto": "..."}, "justificativa": "...", "fontes": [{"titulo": "...", "pmid": "...", "trecho": "..."}],
   "confianca": "alta"}]}
```

| Tipo | alvo | proposta |
|---|---|---|
| resposta | mensagem_id | texto |
| alerta | mensagem_id | texto |
| parecer | artefato_id, afirmacao_codigo | sugestao (aprovar, conferir, reprovar), decisao (correto, erro_leve, erro_critico ou vazio), comentario, evidencias |
| pre_revisao | artefato_id, versao | veredito (pronta, ajustar, refazer), resumo, itens [{tipo, trecho, problema, correcao}] |
| relatorio | semana | texto |
| lembrete | pessoa_id, semana | assunto, texto, pendencias |
| lancamento | indicador, mes (AAAA-MM-01) | numerador, denominador, fonte, nome |
| pendencia | mes | texto |

As skills detalham o modo de trabalho:
- `cut-agente-duvidas`;
- `cut-agente-revisao` (revisor de conteúdo e pré-revisão das peças);
- `cut-agente-acompanhamento` (atrasados, indicadores e supervisor);
- `cut-agente-triador-fontes`.

Os agentes consultam as regras do curso em `CUT_coordenacao\referencia\`, que a ponte atualiza a cada instalação. A
planilha de indicadores segue o `CUT_coordenacao\indicadores\MODELO_totais.csv`.

## Revisão uma vez por texto (decisão de 16/11/2026)

A mesma afirmação aparece em várias peças do tema: no T001, 809 afirmações eram só 103 textos diferentes. O parecer dado
a uma afirmação vale para as cópias idênticas (mesmo texto e mesma fonte) nas outras peças do mesmo tema, em nome da
mesma pessoa, com a origem anotada no comentário. Isso vale para o revisor na tela de revisão e para a coordenação ao
aprovar a sugestão do agente (gatilho `tg_parecer_replica`, SQL 89).

## Fontes aprovadas automaticamente (decisão de 16/11/2026)

As propostas do triador de fontes não esperam a coordenação. A cada rodada, a ponte aprova como veio toda proposta de fonte
cujo arquivo já chegou (`app.coord_aprovar_fontes`, SQL 89), e a fonte fica guardada nos temas indicados. Elas aparecem
em "decididas", com a nota "aprovada automaticamente". Uma fonte guardada num tema errado não prejudica o aluno: ela só
entra no material depois de citada numa peça e revisada.
