# CUT · Dicionário de dados da pesquisa

Versão 1.0 · 16/11/2026 · Acompanha o plano de análise (`docs/plano_analise_preregistro.md`).

## Para que serve

Para cada dado que o aplicativo coleta, o dicionário diz:
- o que ele mede;
- como é coletado;
- quem vê;
- se entra na análise e com qual papel: primária (P), secundária (S), exploratória (E) ou não entra (N).

É a base do protocolo para o CEP e do pré-registro.

## Regras gerais

- **Quem entra.** Só participa da pesquisa quem aceitou o TCLE no aplicativo (`app.consentimento_pesquisa`, versão do
  termo registrada). Quem recusa usa o curso normalmente; os dados dessa pessoa não aparecem para o pesquisador e não
  entram em nenhuma análise.
- **Pseudonimização.** O pesquisador vê o código do participante (`P` + 10 caracteres), nunca o nome nem o e-mail. Só
  a coordenação (administrador, responsável pelos dados e curadores) vê o nome, para acompanhar o curso. A ligação
  entre nome e código fica no banco, sob a guarda do responsável pelos dados (LGPD).
- **Dado de paciente.** Nenhum dado de paciente é coletado. Os casos do curso são fictícios. Os indicadores clínicos são
  só totais do mês. As dúvidas e as respostas abertas são revisadas: se um texto trouxer dado de paciente, ele é
  apagado e não entra na análise.
- **Acesso.** O pesquisador baixa a base pelo painel (aba "Base de análise", CSV) ou recebe o arquivo exportado pelo
  responsável pelos dados (`analise/exportar_base_v1.0.sql`).
- **Retenção.** Os dados ficam guardados pelo prazo previsto no protocolo aprovado pelo CEP. Depois disso, a ligação
  entre nome e código é apagada.

## 1. Participante

| Variável | O que mede | Como é coletada | Quem vê | Análise |
|---|---|---|---|---|
| participante | Código do participante (pseudônimo) | Gerado pelo sistema | Pesquisador, coordenação | P (agrupamento) |
| ano | Ano de residência (R1 a R6), graduação, egresso ou preceptor | Ficha de inscrição, confirmada todo março | Pesquisador, coordenação | P (covariável) |
| especialidade | Especialidade da residência | Ficha de inscrição | Pesquisador, coordenação | S |
| turma | Ano de entrada na residência | Ficha de inscrição | Pesquisador, coordenação | S |
| consentiu | Aceitou o TCLE (sim/não) e a versão do termo | Aceite no aplicativo | Coordenação | Critério de inclusão |
| equipe | A pessoa tem função na equipe (preceptor, curador, administrador, pesquisador) | Funções da equipe (`app.designacao`) | Pesquisador, coordenação | Critério de exclusão |
| simulado | Conta de teste ou simulada (@simulado.local, @setup.local, @exemplo.local) | Domínio do e-mail | Pesquisador, coordenação | Critério de exclusão |

## 2. Respostas aos testes (uma linha por questão respondida)

Base: `app.pesquisa_respostas()`, que corresponde à aba "Base de análise" do painel.

| Variável | O que mede | Como é coletada | Análise |
|---|---|---|---|
| tema, teste_num, teste | Tema e onda: pré-teste 1, pré-teste 2, pós-teste D0, D+15, D+45, D+90 | Onda do teste | P |
| dias_da_aula | Dias entre a aula do tema (D0) e o envio; negativo = antes da aula | Hora do envio − D0 | S |
| item, perfil_item, dificuldade | Questão, o ano a que se destina e o grau de dificuldade previsto (1 a 6) | Banco de questões | P (efeito aleatório da questão) |
| correta | Acertou (sim/não) | Alternativa marcada × gabarito | **P (desfecho primário)** |
| certeza | 1 = chutei, 2 = acho que sim, 3 = tenho certeza; marcada antes de ver o gabarito | Botões em cada questão | S (calibração) |
| tempo_s | Segundos gastos na questão | Relógio do aplicativo | S |
| rapida | Resposta em menos de 3 segundos | tempo_s < 3 | Critério de exclusão |
| apos_aula | Pré-teste 2 enviado depois da hora da aula (conteúdo já apresentado) | Hora do envio ≥ D0 | Critério de exclusão das análises do pré-teste 2 |
| aula | Como viu a aula: "ao vivo" (presença registrada), "depois" (abriu a aula ou os slides) ou "sem registro" | Presença e leitura | S (covariável) |
| valida | Resposta usada na análise primária: não rápida, não depois da aula, não da equipe, não simulada, com consentimento | Regra acima | Filtro |
| enviada_em | Data e hora do envio | Sistema | S |
| fixa | Questão âncora: igual nas seis ondas e para todos os anos | Banco de questões | S (análise de sensibilidade) |

## 3. Notas por teste (uma linha por teste enviado)

`app.nota_teste` e aba "Notas" do painel.

| Variável | O que mede | Análise |
|---|---|---|
| pct | % de acerto no teste | S (descritiva) |
| nota_ponderada | Acerto ponderado pela dificuldade das questões | S |
| esperado | Nota esperada para o ano do aluno, pelo grau das questões | S |
| tempo_total_s | Tempo total no teste | E |
| observacao | "feito depois da aula", quando for o caso | Filtro |

## 4. Material e estudo

| Variável | O que mede | Como é coletada | Análise |
|---|---|---|---|
| leitura_tempo (tipo, segundos) | Tempo com cada peça aberta na tela | Relógio da tela de leitura | E (dose de estudo) |
| uso_material | Peça aberta (tipo, segundos) | Tela de leitura | E |
| situação da peça | Peça vista ou feita (caso concluído, caso base respondido, checklist marcado) | Estado do material | E |
| caso da aula: conduta, certeza, explicação, comparação, tentativa | Conduta escrita em cada ponto de decisão antes da discussão, certeza, explicação em uma frase depois da discussão e comparação ("parecida", "em parte", "diferente") | Caso interativo (aba "Caso da aula" do painel) | E (raciocínio clínico; texto livre) |
| caso base: antes e depois da aula | Resposta às perguntas do caso base antes da aula e o que responderia depois | Caso base (aba "Caso base") | E |
| dica vista | O aluno de graduação, R1 ou R2 abriu a dica do ponto de decisão | Caso interativo | E |
| revisão espaçada (item_revisao) | Caixa e data da próxima revisão de cada questão | Testes e simulados do estudo dirigido | E |
| simulados do estudo dirigido | Questões, acertos e modo (sob medida, revisão, misturado) | Estudo dirigido | E |
| flashcards revisados | Acertos, erros e intervalo de cada cartão | Estudo dirigido | E |

## 5. Avaliação do curso pelo aluno (nível 1 de Kirkpatrick)

| Variável | O que mede | Análise |
|---|---|---|
| nps (0 a 10) por peça, teste e tema | Quanto recomendaria | S |
| conteúdo, adequação, dificuldade (1 a 5), utilidade (1 a 3), minutos gastos | Avaliação do tema | S |
| comentário | Texto livre | E (análise de conteúdo) |
| aplicabilidade (D+15): usou, mudou conduta, confiança, exemplo, barreira | Uso do que aprendeu no plantão, autorrelatado | S (nível 3, autorrelato) |
| presença (ao vivo pelo código ou pelo relatório do Meet) | Participação na aula | S |
| dúvidas e feedback | Texto livre por peça | E |

## 6. Indicadores clínicos (nível 3 de Kirkpatrick, dado agregado)

`app.indicador_clinico`; aba "Indicadores clínicos" do painel. A coordenação digita os totais do mês a partir do
registro de trauma do serviço.

| Indicador | Numerador / denominador (por mês) | Análise |
|---|---|---|
| via_aerea_registrada | Admissões com via aérea avaliada e registrada / admissões de trauma | S |
| temperatura_admissao | Admissões com temperatura medida / admissões | S |
| aquecimento_iniciado | Admissões com aquecimento iniciado na sala de trauma / admissões | S |
| terciaria_registrada | Internados com avaliação terciária registrada / internados por trauma | S |
| lider_definido | Atendimentos com líder definido antes da chegada / atendimentos com aviso prévio | S |
| torniquete_horario | Torniquetes com horário registrado / torniquetes | E |

Só números. Nunca nome, prontuário, data de nascimento ou qualquer dado que identifique paciente.

## 7. Dados que não entram na pesquisa

- Sessão, acesso e marca d'água (segurança).
- Contato e preferências de aviso.
- Inscrições nos avisos no celular.
- Registro de envio de e-mails.
- Rascunho das respostas de um teste ainda não enviado.
- Onde o aluno parou (posição de leitura, slide, áudio).

## 8. Onde cada dado está no banco

| Bloco | Tabela ou função |
|---|---|
| Participante | `app.pessoa`, `app.ficha_aluno`, `app.posicao_anual`, `app.consentimento_pesquisa`, `app.designacao`; `pesquisa.codigo_participante()` |
| Respostas | `app.resposta`, `app.tentativa`, `app.onda_instancia`, `app.item`, `app.alternativa`; `app.pesquisa_respostas()` |
| Notas | `app.nota_teste`; `app.painel_notas()` |
| Material e estudo | `app.leitura_tempo`, `app.uso_material`, `app.estado_material`, `app.item_revisao`, `app.simulado_aluno`, `app.flashcard_revisao` |
| Avaliação | `app.avaliacao`, `app.aplicabilidade`, `app.presenca`, `app.mensagem_aluno` |
| Indicadores | `app.indicador_clinico`; `app.painel_indicadores()` |
| Questões | `app.analise_itens()` (dados válidos), `app.painel_questoes()` (todas as respostas) |
