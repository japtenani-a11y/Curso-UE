# CUT em produção: as três opções de servidor (16/11/2026)

O servidor de produção põe o CUT num endereço `https://` que qualquer aluno abre no celular, com login pelo
Google, entrada por link no e-mail e os lembretes por e-mail. O mesmo kit serve para as três opções; muda só
onde o programa roda e como o endereço chega até ele.

| | 1. Google Cloud (São Paulo) | 2. Servidor do HC/USP | 3. Seu computador |
|---|---|---|---|
| Custo | cerca de US$ 25 a 50 por mês (ver abaixo) | sem custo direto | sem custo (luz e internet) |
| Fica no ar | 24 horas, com reinício automático | 24 horas, depende da informática | só com o computador ligado e o WSL aberto |
| Trabalho para montar | 1 a 2 horas, uma vez | depende do pedido à informática (dias a semanas) | 30 minutos |
| Manutenção | atualizações do Ubuntu (automáticas) e cópia diária | a da informática | a do seu computador |
| Dados (LGPD) | Google, região São Paulo; contrato padrão do Google Cloud | dentro da instituição | no seu computador |
| Acesso público | IP fixo + Caddy (certificado automático) | IP público + Caddy, ou túnel se a rede só permitir saída | túnel (ngrok ou Cloudflare) |
| Risco principal | esquecer a cobrança ou a cópia | prazo e regras da informática | queda de energia, suspensão do Windows, atualização do Windows reiniciando |

Para o teste de uso com 2 ou 3 residentes, a opção 3 basta. Para a turma, as opções 1 ou 2.

Custo da opção 1 (preço sob demanda, sem desconto, conferido em 16/11/2026): a máquina e2-medium (2 processadores,
4 GB) custa cerca de US$ 39 por mês em São Paulo; a e2-small (2 GB), cerca de metade. Some disco de 30 GB e o IP
fixo, alguns dólares por mês. A e2-small dá conta de uma turma pequena se tiver memória de troca (passo 2 abaixo).
Confira na calculadora do Google antes de criar: https://cloud.google.com/products/calculator

## Endereço provisório (enquanto o domínio não é decidido)

O endereço fica num só lugar: `DOMINIO=` em `~/.config/curso-ue/producao.env`. Trocar depois é mudar essa linha,
rodar `bash 96_producao_v1.0.sh SENHA` e atualizar o endereço no Google (seção "Google", abaixo).

- Opções 1 e 2 (servidor com IP público): use o IP escrito com traços seguido de `.sslip.io`. Exemplo: IP
  `34.95.10.20` vira `DOMINIO=34-95-10-20.sslip.io`. Esse nome aponta sozinho para o IP, sem cadastro, e o Caddy
  consegue o certificado https para ele.
- Opção 3 (seu computador): o domínio gratuito do ngrok que já usamos no servidor de revisão.

Limite do endereço provisório: o Google só publica o app (tirar do modo "Em teste") com um domínio seu,
confirmado no Search Console. Até lá, entram pelo Google só as pessoas da lista de usuários de teste (até 100).
A entrada por link no e-mail funciona para todos, sem essa limitação.

Domínio definitivo, quando decidir: um subdomínio do HC/USP pedido à informática (ex.: `cut.hcrp.usp.br`) ou um
domínio comprado (registro.br, cerca de R$ 40 por ano para `.com.br`).

## O arquivo de configuração (as três opções)

`~/.config/curso-ue/producao.env`, permissão 600, fora do repositório. O script cria um vazio na primeira vez.

```
DOMINIO=34-95-10-20.sslip.io
ACESSO=caddy
GOOGLE_CLIENT_ID=....apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=....
CLOUDFLARE_TOKEN=
```

`ACESSO`: `caddy` no servidor com IP público (opções 1 e 2), `cloudflare` ou `ngrok` atrás de firewall ou no seu
computador. O e-mail vem de `~/.config/curso-ue/email.env` (52_configurar_email_v1.0.sh). Nenhuma senha vai no
repositório nem nesta conversa.

O que o `96_producao_v1.0.sh` faz, nesta ordem: aplica os scripts do banco, remove a função do login de teste,
gera o aplicativo, liga a API, o gateway e o enviador de e-mails em modo produção, abre o acesso e confere de fora
(saúde da API, login de teste desligado, cabeçalhos de segurança, redirecionamento para o Google). Em servidor,
cada parte vira um serviço do sistema e volta sozinha quando a máquina reinicia.

## Opção 1: Google Cloud, região São Paulo

1. **Criar a máquina.** console.cloud.google.com → projeto "Programa CUT" → Compute Engine → Instâncias de VM →
   Criar instância. Nome `cut`; região `southamerica-east1` (São Paulo); tipo `e2-medium` (ou `e2-small`); disco de
   inicialização: Ubuntu 24.04 LTS, 30 GB, "Disco permanente equilibrado"; Firewall: marque "Permitir tráfego HTTP"
   e "Permitir tráfego HTTPS". Criar. Em Rede VPC → Endereços IP, promova o IP externo da máquina a **estático**
   (senão ele muda ao reiniciar).
   Ative um alerta de orçamento: Faturamento → Orçamentos e alertas → US$ 60.
2. **Entrar na máquina** pelo botão SSH da própria página (abre um terminal no navegador) e preparar:
   ```
   sudo apt update && sudo apt -y upgrade
   sudo apt -y install postgresql postgresql-contrib gnupg unzip curl git unattended-upgrades
   curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash - && sudo apt -y install nodejs
   sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```
3. **Instalar o Caddy** (o programa que pede e renova o certificado https sozinho):
   ```
   sudo apt -y install debian-keyring debian-archive-keyring apt-transport-https
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt update && sudo apt -y install caddy
   ```
4. **Levar o CUT.** Pelo botão de engrenagem do terminal SSH → "Fazer upload de arquivo", envie o zip do CUT. Depois:
   ```
   mkdir -p ~/Curso-UE && unzip -o ~/CUT_*.zip -d ~/Curso-UE && cd ~/Curso-UE
   bash instalar_banco_wsl_v1.0.sh SENHA_NOVA ./programa-cut
   bash subir_api_pwa_wsl_v1.0.sh SENHA_NOVA     (gera o código; depois pare com: bash subir_api_pwa_wsl_v1.0.sh parar)
   ```
   Use uma senha nova do banco, que nunca apareceu em registro nem em conversa.
5. **Levar o banco** do seu computador (seção abaixo).
6. **Configurar e ligar:** preencha `~/.config/curso-ue/producao.env` (DOMINIO com o IP em `.sslip.io`,
   `ACESSO=caddy`), copie o `email.env` (ou rode `bash 52_configurar_email_v1.0.sh` no servidor) e rode
   `bash 96_producao_v1.0.sh SENHA_NOVA`.
7. **Cópia diária:** `bash 96_backup_producao_v1.0.sh configurar` e `bash 96_backup_producao_v1.0.sh agendar`.
   No seu computador, para trazer as cópias para a pasta do Drive: `bash 96_backup_producao_v1.0.sh baixar ...`
   (exige a chave SSH do servidor no WSL: `gcloud compute config-ssh` cria).

## Opção 2: servidor do HC/USP

O que pedir à informática (pode copiar):

> Máquina virtual Ubuntu Server 24.04 LTS, 2 vCPU, 4 GB de memória, 40 GB de disco, com acesso SSH para mim (usuário
> com sudo). Um nome no DNS da instituição apontando para ela (sugestão: cut.hcrp.usp.br) e as portas 80 e 443
> abertas para a internet. Se as portas não puderem ser abertas, basta saída para a internet na porta 443, que uso
> um túnel. O sistema guarda dados de residentes (cadastro e desempenho acadêmico), sem dados de pacientes; as
> cópias de segurança são criptografadas.

Com a máquina pronta, os passos são os da opção 1, a partir do passo 2. Diferenças:

- Com portas 80/443 abertas: `ACESSO=caddy`, `DOMINIO=` o nome que a informática criou.
- Só com saída: `ACESSO=cloudflare` (túnel, seção abaixo). Não precisa de porta aberta nem de IP público.
- Se a informática já tiver um servidor web na frente, com o certificado da instituição: peça que ele repasse o
  domínio para a porta 8080 da máquina e use `ACESSO=local` (o CUT não abre acesso próprio; os cabeçalhos de
  segurança já saem do gateway).

## Opção 3: seu computador

1. Windows: Configurações → Sistema → Energia → "Quando conectado, suspender após: Nunca". Deixe o WSL aberto.
   Atualizações do Windows: defina "Horário ativo" para não reiniciar no horário das aulas.
2. Escolha o túnel:
   - **ngrok** (o que já usamos no servidor de revisão): `ACESSO=ngrok`, `DOMINIO=` o domínio gratuito do ngrok.
   - **Cloudflare**, se tiver um domínio seu na Cloudflare: `ACESSO=cloudflare` e o token do túnel (abaixo).
3. `bash 96_producao_v1.0.sh SENHA_DO_BANCO`. Para desligar: `bash 96_producao_v1.0.sh parar`.
4. Cópia diária: a mesma de sempre (`bash 70_backup_drive_v1.0.sh agendar`).

Não é preciso migrar o banco: é o mesmo.

## Túnel Cloudflare (opções 2 e 3, quando não há porta aberta)

Precisa de um domínio seu cadastrado na Cloudflare (gratuito). Em one.dash.cloudflare.com → Networks → Tunnels →
Criar túnel (tipo Cloudflared), nome `cut`. Na tela de instalação, copie só o **token** (o texto longo depois de
`--token`) para `CLOUDFLARE_TOKEN=` no producao.env. Em "Public Hostname": o seu `DOMINIO`, serviço
`HTTP` → `localhost:8080`. Instalar o programa no Ubuntu:
```
curl -L -o /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i /tmp/cloudflared.deb
```

## Levar o banco (opções 1 e 2)

No seu computador (WSL): `bash 96_migrar_banco_v1.0.sh exportar SENHA_DO_BANCO`. Ele pede uma frase-senha e gera
`~/cut_migracao_DATA.dump.gpg`, criptografado. Envie o arquivo ao servidor (botão de upload do SSH do Google, ou
`scp`). No servidor: `bash 96_migrar_banco_v1.0.sh importar SENHA_NOVA ~/cut_migracao_DATA.dump.gpg`. O banco que
já estava no servidor fica guardado com outro nome; nada é apagado. Faça isso com o seu computador já sem uso
(pare a API local), para não haver respostas gravadas nos dois lugares.

## Google (login) para o endereço novo

console.cloud.google.com → "Programa CUT" → Google Auth Platform:
1. **Clientes** → o cliente "Aplicativo da Web" → Origens JavaScript autorizadas: `https://DOMINIO`;
   URIs de redirecionamento autorizados: `https://DOMINIO/api/auth/callback`. Salvar. Pode manter o do ngrok junto.
2. **Branding** → links do app com o novo endereço (`/`, `/privacidade`, `/termos`) e o domínio autorizado.
3. Com domínio próprio confirmado no Search Console: **Público-alvo → Publicar aplicativo** (docs/google_cloud_cut.md).
O ID e a chave secreta do cliente vão em `producao.env`, nunca em outro arquivo.

## E-mail

A conta Gmail com senha de app (52_configurar_email_v1.0.sh) envia até cerca de 500 mensagens por dia. Para uma
turma, é suficiente. Os e-mails podem cair no spam enquanto o endereço é novo: peça aos alunos para marcar
"não é spam" no primeiro. Se a turma crescer, troque por um serviço de envio (as mesmas linhas SMTP_ no email.env).

## Agentes de coordenação com o banco no servidor

A ponte (ponte_coordenacao_v1.0.sh) roda no seu computador e precisa falar com o banco. Com o banco no servidor,
abra um túnel SSH antes e aponte a ponte para ele:
```
ssh -N -L 5433:localhost:5432 USUARIO@SERVIDOR &
DATABASE_URL=postgresql://api_rw:SENHA_NOVA@localhost:5433/programa bash ponte_coordenacao_v1.0.sh --uma-vez
```
O banco nunca fica aberto para a internet; só passa pelo túnel SSH.

## Atualizar uma versão nova

Seu computador: o de sempre (`unzip` + `subir_api_pwa_wsl_v1.0.sh`). Servidor: envie o zip, `unzip -o`,
`bash subir_api_pwa_wsl_v1.0.sh SENHA` (gera o código), `bash subir_api_pwa_wsl_v1.0.sh parar` e
`bash 96_producao_v1.0.sh SENHA`. Os alunos ficam alguns minutos sem acesso: faça fora do horário de uso.

## Conferir que está no ar

`bash 96_producao_v1.0.sh conferir` (de qualquer lugar com o kit). Para ser avisado se cair, cadastre
`https://DOMINIO/api/health` num monitor gratuito (UptimeRobot, a cada 5 minutos, aviso por e-mail).
Registros: no servidor, `sudo journalctl -u cut-api -n 100`; no seu computador, `programa-cut/logs/prod_api.log`.
