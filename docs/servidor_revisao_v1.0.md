# Servidor de revisão com login do Google (v1.0)

O aplicativo roda no seu computador (WSL) e fica acessível pela internet por um túnel HTTPS do **ngrok**. Os revisores entram com a **Conta Google**. Só entram os e-mails cadastrados no `49_revisores_v1.0.sql`:

| Pessoa | E-mail | Papel |
| --- | --- | --- |
| José Pezati | japtenani@gmail.com | coordenador (admin) |
| Aline | aline@sardow.com | revisora (curador) |
| Jorge Carnesecca | jorge.carnesecca@hotmail.com | revisor (curador) |

> Cada e-mail precisa ser uma Conta Google. Um e-mail que não é Gmail vira Conta Google em accounts.google.com → "Criar conta" → "Usar meu endereço de e-mail atual". Se o Jorge ou a Aline preferirem um Gmail, troque o e-mail no `49_revisores_v1.0.sql` e rode de novo.

## Passo 1 — ngrok (uma vez, ~10 min)

O ngrok cria um endereço HTTPS fixo na internet que aponta para o seu computador.

1. Crie uma conta gratuita em **dashboard.ngrok.com/signup** (pode entrar com a própria Conta Google).
2. No painel, menu **Universal Gateway → Domains** (em contas novas aparece também como "Your dev domain"): copie o domínio gratuito fixo, algo como `nome-sorteado.ngrok-free.app`. É ele que vai no `DOMINIO`.
3. No painel, menu **Getting Started → Your Authtoken**: copie o token (não cole em lugar nenhum além do comando abaixo).
4. No WSL (Ubuntu), instale e registre o token:
   ```bash
   curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
   echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" | sudo tee /etc/apt/sources.list.d/ngrok.list
   sudo apt update && sudo apt install -y ngrok
   ngrok config add-authtoken COLE_O_TOKEN_AQUI
   ngrok version          # deve mostrar a versão instalada
   ```
   O token fica em `~/.config/ngrok/ngrok.yml`, só no seu computador.

## Passo 2 — credencial do Google (uma vez, ~15 min)

Faça logado como **japtenani@gmail.com**, em **console.cloud.google.com**. (O Google renomeou os menus: se você vir "Google Auth Platform", use os nomes entre parênteses.)

1. No topo, **Selecionar projeto → Novo projeto** → nome "Programa CUT" → Criar. Confira que ele ficou selecionado.
2. Menu ☰ → **APIs e serviços → Tela de consentimento OAuth** (ou **Google Auth Platform → Branding**) → **Começar**:
   - Nome do app: `Programa de Cirurgia de Urgência e Trauma`; e-mail de suporte: o seu.
   - Público (Audience): **Externo**.
   - Contato do desenvolvedor: o seu e-mail → Criar.
3. **Público-alvo / Audience → Usuários de teste → Adicionar usuários**: `japtenani@gmail.com`, `aline@sardow.com`, `jorge.carnesecca@hotmail.com` → Salvar. Deixe o app **Em teste**: assim só esses três conseguem entrar (até 100 usuários de teste, sem verificação do Google).
4. **Credenciais → Criar credenciais → ID do cliente OAuth** (ou **Clients → Create client**):
   - Tipo: **Aplicativo da Web**; nome: `Servidor de revisão`.
   - **Origens JavaScript autorizadas**: `https://SEU-DOMINIO.ngrok-free.app`
   - **URIs de redirecionamento autorizados**: `https://SEU-DOMINIO.ngrok-free.app/api/auth/callback`
   - (troque `SEU-DOMINIO...` pelo domínio do passo 1, exatamente igual, com `https://` e sem barra no fim)
   - Criar.
5. Na janela que abre, copie o **ID do cliente** (termina em `.apps.googleusercontent.com`) e a **Chave secreta do cliente** (começa com `GOCSPX-`). Se fechar a janela, a chave pode ser vista ou recriada em Credenciais → o cliente → "Chaves secretas".

Se ao entrar aparecer **"Erro 400: redirect_uri_mismatch"**, o endereço do item 4 não está idêntico ao `DOMINIO`. Se aparecer **"Acesso bloqueado: o app não concluiu a verificação"**, o e-mail não está na lista de usuários de teste.

> No teste local (`localhost:5173`) o botão do Google não funciona de propósito: não há credencial lá. Ele mostra um aviso e você entra pelo campo de e-mail de teste. O login do Google funciona no endereço do ngrok.

## Passo 3 — arquivo de configuração (uma vez, fora do repositório)

```bash
mkdir -p ~/.config/curso-ue && chmod 700 ~/.config/curso-ue
nano ~/.config/curso-ue/servidor.env      # cole as 3 linhas abaixo, preenchidas
chmod 600 ~/.config/curso-ue/servidor.env
```
```
DOMINIO=SEU-DOMINIO.ngrok-free.app
GOOGLE_CLIENT_ID=....apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=....
```
Nunca coloque esses valores no repositório nem no chat.

## Passo 4 — e-mail pelo seu Gmail (uma vez): lembretes, dúvidas e respostas

1. Em myaccount.google.com → Segurança, ligue a **verificação em duas etapas**.
2. Em myaccount.google.com/apppasswords, crie uma **senha de app** ("Programa CUT").
3. No WSL: `bash 52_configurar_email_v1.0.sh` — ele pede a senha (sem mostrar), guarda em `~/.config/curso-ue/email.env` e manda um e-mail de teste para você. WhatsApp fica desligado.

## Passo 5 — ligar e desligar

```bash
cd ~/Curso-UE
bash subir_api_pwa_wsl_v1.0.sh SUA_SENHA_DO_BANCO      # gera, instala e testa localmente (uma vez por atualização)
bash 50_servidor_revisao_v1.0.sh SUA_SENHA_DO_BANCO    # coloca no ar em https://SEU-DOMINIO
bash 50_servidor_revisao_v1.0.sh parar       # tira do ar
```
O computador precisa ficar ligado (e o WSL aberto) enquanto os revisores trabalham. Na primeira visita, o ngrok gratuito mostra uma página de aviso: é só clicar em **Visit Site**.

## Revisão e publicação

- Basta **1 revisor**: quando todas as afirmações de uma peça tiverem parecer, sem erro crítico, com até 5% de erro leve e sem parecer geral crítico, o botão **Aprovar e publicar** (tela Revisão) libera. Peça sem afirmações (ex.: caso base) precisa só do parecer geral "Correto".
- Se outro revisor marcar erro crítico, a publicação fica bloqueada até corrigir o parecer ou o texto.
- Publicar arquiva a versão publicada anterior da mesma peça.

## Dúvidas dos alunos

- Cada dúvida nova gera um e-mail para você, Aline e Jorge (admin e curadores), com o texto e o link.
- A resposta é escrita por vocês na tela **Dúvidas** (menu do curador), depois da avaliação; não há resposta automática.
- O aluno vê a resposta na tela Dúvidas dele e recebe por e-mail se autorizou e-mails em Lembretes.

## O que protege o conteúdo

- Entrada só por Conta Google de e-mail cadastrado; sessão de 12 horas; sem login de teste em produção.
- Toda tela de conteúdo leva **marca d'água** com nome, e-mail, data e hora de quem a abriu; cópia, arrastar, botão direito e impressão ficam bloqueados.
- Respostas com `no-store` e `noindex`; `robots.txt` bloqueia buscadores; o aplicativo não pode ser aberto dentro de outro site.
- Cada acesso fica registrado (`app.acesso_conteudo`); acima de 600 acessos por hora a mesma pessoa é bloqueada. Para ver: `SELECT * FROM app.vw_acessos_por_dia ORDER BY dia DESC;`
- O aplicativo instalável guarda só a "casca" no aparelho; o conteúdo nunca fica salvo offline.

Nada disso impede alguém de fotografar a tela, mas a marca d'água identifica a origem de qualquer cópia.
