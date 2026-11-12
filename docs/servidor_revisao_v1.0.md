# Servidor de revisão com login do Google (v1.0)

O aplicativo roda no seu computador (WSL) e fica acessível pela internet por um túnel HTTPS do **ngrok**. Os revisores entram com a **Conta Google**. Só entram os e-mails cadastrados no `49_revisores_v1.0.sql`:

| Pessoa | E-mail | Papel |
| --- | --- | --- |
| José Pezati | japtenani@gmail.com | coordenador (admin) |
| Aline | aline@sardow.com | revisora (curador) |
| Jorge Carnesecca | jorge.carnesecca@hotmail.com | revisor (curador) |

> Cada e-mail precisa ser uma Conta Google. Um e-mail que não é Gmail vira Conta Google em accounts.google.com → "Criar conta" → "Usar meu endereço de e-mail atual". Se o Jorge ou a Aline preferirem um Gmail, troque o e-mail no `49_revisores_v1.0.sql` e rode de novo.

## Passo 1 — ngrok (uma vez)

1. Crie uma conta gratuita em ngrok.com.
2. No painel, em **Domains**, pegue o domínio estático gratuito (algo como `nome-escolhido.ngrok-free.app`).
3. No WSL, instale e registre o token:
   ```bash
   curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
   echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" | sudo tee /etc/apt/sources.list.d/ngrok.list
   sudo apt update && sudo apt install -y ngrok
   ngrok config add-authtoken SEU_TOKEN_DO_PAINEL
   ```

## Passo 2 — credencial do Google (uma vez)

1. Em console.cloud.google.com, crie um projeto (ex.: "Programa CUT").
2. **APIs e serviços → Tela de consentimento OAuth**: tipo **Externo**, nome do app, seu e-mail de suporte. Em **Usuários de teste**, adicione os três e-mails acima (enquanto o app estiver "Em teste", só eles entram, o que é o que queremos).
3. **Credenciais → Criar credenciais → ID do cliente OAuth → Aplicativo da Web**:
   - Origens JavaScript autorizadas: `https://SEU-DOMINIO.ngrok-free.app`
   - URIs de redirecionamento autorizados: `https://SEU-DOMINIO.ngrok-free.app/api/auth/callback`
4. Copie o **ID do cliente** e a **Chave secreta**.

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

## Passo 4 — e-mail dos lembretes pelo seu Gmail (uma vez)

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

## O que protege o conteúdo

- Entrada só por Conta Google de e-mail cadastrado; sessão de 12 horas; sem login de teste em produção.
- Toda tela de conteúdo leva **marca d'água** com nome, e-mail, data e hora de quem a abriu; cópia, arrastar, botão direito e impressão ficam bloqueados.
- Respostas com `no-store` e `noindex`; `robots.txt` bloqueia buscadores; o aplicativo não pode ser aberto dentro de outro site.
- Cada acesso fica registrado (`app.acesso_conteudo`); acima de 600 acessos por hora a mesma pessoa é bloqueada. Para ver: `SELECT * FROM app.vw_acessos_por_dia ORDER BY dia DESC;`
- O aplicativo instalável guarda só a "casca" no aparelho; o conteúdo nunca fica salvo offline.

Nada disso impede alguém de fotografar a tela, mas a marca d'água identifica a origem de qualquer cópia.
