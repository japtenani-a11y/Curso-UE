# Lembretes por e-mail e WhatsApp (v1.0)

Os lembretes dos testes chegam ao aluno por três canais: o aviso no aplicativo (sempre), o e-mail e o WhatsApp. E-mail e WhatsApp só são usados para quem autorizou o canal na tela **Lembretes por e-mail e WhatsApp** (`/aluno/contato`).

## Quando o aluno recebe

| Lembrete | Quando |
| --- | --- |
| Pré-teste 2 com prazo terminando | 24 horas antes do prazo, que é 1 hora antes da aula (D0 − 1 h), se ainda não respondeu |
| Pós-teste pendente (D0, D+15, D+45, D+90) | 7, 14, 28 e 60 dias depois da data prevista, se ainda não respondeu |

Quem responde o teste, ou retira a autorização, não recebe o que ainda estava na fila.

## Calendário de um tema

`SELECT * FROM app.agendar_ondas_tema(<tema_id>, '2026-12-03 07:00-03');` recebe a **data e a hora da aula**.

| Teste | Abre | Fecha |
| --- | --- | --- |
| Pré-teste inicial | D−15 | D+180 |
| Pré-teste 2 | junto com o material pré-aula, quando o aluno envia o pré-teste inicial | **1 hora antes da aula** |
| Pós-teste D0 | na hora da aula | D+180 |
| Pós-testes D+15, D+45, D+90 | na data | D+180 |

Quem não respondeu o pré-teste 2 até o prazo segue para o material da reunião sem ele (não fica travado).

## Ligar o envio de verdade

O enviador é `npm run notificar` na pasta `api` (fica rodando; a cada 5 minutos). Para rodar uma vez, pelo cron do servidor: `npm run notificar -- --uma-vez`.

Sem credenciais, ou com `NOTIFICAR_MODO=simular`, ele só registra no log o que seria enviado. Para enviar, `NOTIFICAR_MODO=enviar` e as variáveis abaixo, **só no ambiente do servidor** (nunca em arquivo do repositório nem no chat):

**E-mail (SMTP)**: `SMTP_HOST`, `SMTP_PORT` (587 ou 465), `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM` (por exemplo `"Programa de Cirurgia do Trauma <avisos@...>"`). Pode ser o SMTP institucional do HCFMRP/USP ou um serviço de envio. Uma conta Gmail serve para teste, com senha de app.

**WhatsApp (API oficial da Meta, WhatsApp Cloud API)**: `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_ID`, `WHATSAPP_TEMPLATE` (nome do modelo aprovado); opcionais `WHATSAPP_IDIOMA` (padrão `pt_BR`) e `WHATSAPP_API_VERSAO` (padrão `v21.0`).

Passos do WhatsApp:
1. Conta no Meta Business e um número dedicado ao Programa (não pode estar em uso no WhatsApp comum).
2. Criar o app no Meta for Developers com o produto WhatsApp; anotar o ID do número e gerar um token permanente (usuário de sistema).
3. Cadastrar e aprovar um modelo de mensagem da categoria **Utilidade**, idioma português (BR), com 4 variáveis no corpo:
   > Lembrete do Programa de Cirurgia de Urgência e Trauma: {{1}} do tema {{2}}. {{3}} Responda em: {{4}}

   O enviador preenche: {{1}} nome do teste, {{2}} código do tema, {{3}} prazo ou dias de atraso, {{4}} link.
4. Mensagens iniciadas pela instituição só saem por modelo aprovado; a Meta cobra por conversa.

## LGPD

- Cada canal tem autorização própria, com data e versão do texto (`app.contato_aluno`).
- Os dados de contato são usados só para os lembretes; o aluno muda ou retira a autorização na mesma tela.
- O log do enviador mascara o destino; a fila (`app.notificacao_saida`) não é acessível pelas rotas da API.
- Resumo da fila para o suporte: `SELECT * FROM app.vw_notificacoes_resumo;`
