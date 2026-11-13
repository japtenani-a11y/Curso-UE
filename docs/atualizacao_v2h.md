# Atualização T001 v2h (passo a passo)

Tudo no WSL (Ubuntu), dentro de `~/Curso-UE`. Onde estiver `SUA_SENHA_DO_BANCO`, digite a senha real do banco (o texto `SUA_SENHA_DO_BANCO` é só um marcador).

## O que muda nesta versão

- **Visual**: o aplicativo fica sempre claro. O modo escuro do Windows deixava as abas da revisão brancas e ilegíveis.
- **Login do Google no teste local**: em vez de erro, aparece um aviso. O Google só funciona no servidor (passo 8), onde existe a credencial.
- **Dúvidas**: não há mais resposta por IA. Cada dúvida vai por e-mail para os curadores; a coordenação responde na tela **Dúvidas** do curador; o aluno vê a resposta no app (e por e-mail, se autorizou).
- **Publicação com 1 revisor**: botão **Aprovar e publicar** na tela de revisão.
- **Pesquisa**: o termo de consentimento sai da tela do aluno por enquanto; o banco continua coletando notas, avaliações, tempo de uso e mensagens.
- **Calendário**: lista das 39 aulas em `docs/calendario_aulas_2027_2028.md`.

## Passos

1. Baixe `T001_v2h.zip` para a pasta Downloads do Windows.
2. Descompacte por cima do projeto e apague o arquivo da IA, que não é mais usado:
   ```bash
   cd ~/Curso-UE
   unzip -o /mnt/c/Users/japt7/Downloads/T001_v2h.zip -d ~/Curso-UE
   rm -f 57_configurar_ia_v1.0.sh modelos/engajamento_v1.0/api/src/respondedor.ts
   ```
3. Gere, instale e teste (o script já aplica o `58_duvidas_publicacao_v1.0.sql` no banco):
   ```bash
   bash subir_api_pwa_wsl_v1.0.sh SUA_SENHA_DO_BANCO
   ```
   No passo 6 da saída devem aparecer, além dos de antes: **curador abrindo as dúvidas: 200 · publicar sem peça válida: 400 · aluno abrindo as dúvidas da curadoria: 403**.
4. Teste local em `http://localhost:5173/login`:
   - `r1.teste@setup.local` (aluno): envie uma dúvida no fim de uma peça;
   - `japtenani@gmail.com` (coordenador): menu **Dúvidas** → responda; menu **Revisão** → o botão "Aprovar e publicar" fica cinza até a peça estar toda revisada.

## Passo 6 — e-mail pelo Gmail (lembretes, avisos de dúvida e respostas)

1. Entre em **myaccount.google.com** com japtenani@gmail.com → **Segurança** → **Verificação em duas etapas** → ative (se ainda não estiver ativa).
2. Abra **myaccount.google.com/apppasswords** (se pedir, digite a senha da conta).
   - Nome do app: `Programa CUT` → **Criar**.
   - Aparece uma senha de **16 letras** em 4 blocos. Deixe a janela aberta.
   - Se a página disser que a opção não está disponível: a verificação em duas etapas não está ativa, ou a conta usa só chave de segurança/Proteção Avançada.
3. No WSL:
   ```bash
   cd ~/Curso-UE
   bash 52_configurar_email_v1.0.sh
   ```
   Cole a senha de app quando ele pedir (não aparece na tela; espaços são removidos). Ele grava em `~/.config/curso-ue/email.env` (só você lê) e manda um e-mail de teste para japtenani@gmail.com.
4. Confira a caixa de entrada (e o spam). Depois rode de novo o passo 3: a saída passa a dizer "e-mail pelo Gmail configurado".
5. Para trocar ou revogar: apague a senha em myaccount.google.com/apppasswords e rode o 52 de novo.

## Passo 7 — dúvidas pela coordenação

Nada a configurar além do passo 6. Cada dúvida nova gera e-mail para você, Aline e Jorge; a resposta é gravada por quem avaliou, na tela **Dúvidas** do curador.

## Passo 8 — servidor para os revisores (ngrok + Google)

Siga `docs/servidor_revisao_v1.0.md`, passos 1 a 3 (detalhados lá):
1. ngrok: conta, domínio fixo gratuito, `sudo apt install ngrok`, `ngrok config add-authtoken ...`.
2. Google Cloud: projeto, tela de consentimento **Externa, em teste**, os 3 e-mails como usuários de teste, cliente OAuth **Aplicativo da Web** com:
   - origem `https://SEU-DOMINIO.ngrok-free.app`
   - redirecionamento `https://SEU-DOMINIO.ngrok-free.app/api/auth/callback`
3. Arquivo `~/.config/curso-ue/servidor.env` com `DOMINIO`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` (`chmod 600`).

Depois:
```bash
cd ~/Curso-UE
bash 50_servidor_revisao_v1.0.sh SUA_SENHA_DO_BANCO     # coloca no ar
bash 50_servidor_revisao_v1.0.sh parar                  # tira do ar
```
Mande para Aline e Jorge só o endereço `https://SEU-DOMINIO.ngrok-free.app`. O computador precisa ficar ligado com o WSL aberto.

## Passo 9 — calendário das aulas

A lista das 39 datas está em `docs/calendario_aulas_2027_2028.md`. Para gravar no banco, **só quando for abrir para os alunos** (isso move os testes do T001 para 2027 e eles deixam de abrir no teste local):
```bash
psql "postgresql://postgres:SUA_SENHA_DO_BANCO@localhost:5432/programa" -f 48_agenda_aulas_v1.0.sql
```

Se algo falhar, envie `programa-cut/logs/gerar.log`, `banco.log`, `tipos_api.log` e `tipos_pwa.log`.
