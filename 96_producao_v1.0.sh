#!/usr/bin/env bash
# ============================================================
# 96_producao_v1.0.sh
# OBJETIVO: pôr o CUT no ar para os alunos, em modo produção, em qualquer uma das três opções de servidor
# (docs/producao_v1.0.md): máquina virtual no Google Cloud, servidor do HC/USP ou o seu computador.
#   navegador -> https://DOMINIO -> [Caddy | túnel Cloudflare | túnel ngrok] -> gateway :8080 -> aplicativo (pwa/dist)
#                                                                                         \-> /api/* -> API :3000
# Modo produção: sem login de teste (a função do banco é removida), cookies seguros, CORS só do domínio, cabeçalhos
# de segurança, limites de acesso. Ligados: API, gateway, enviador de e-mails e o acesso escolhido.
# Em servidor com systemd (Google Cloud, HC/USP), tudo vira serviço: volta sozinho depois de reiniciar a máquina.
# No WSL (seu computador), roda em segundo plano enquanto o WSL estiver aberto.
#
# PREPARO (uma vez; passo a passo em docs/producao_v1.0.md):
#   ~/.config/curso-ue/producao.env (permissão 600), fora do repositório:
#     DOMINIO=cut.exemplo.com.br            (sem https://)
#     ACESSO=caddy                          (caddy: servidor com IP público | cloudflare: túnel Cloudflare | ngrok |
#                                            local: outro servidor web da instituição repassa para a porta 8080)
#     GOOGLE_CLIENT_ID=....apps.googleusercontent.com
#     GOOGLE_CLIENT_SECRET=....
#     CLOUDFLARE_TOKEN=....                 (só com ACESSO=cloudflare)
#   E-mail (lembretes e link de entrada): ~/.config/curso-ue/email.env, pelo 52_configurar_email_v1.0.sh.
#
# USO (dentro de ~/Curso-UE, depois do subir_api_pwa_wsl_v1.0.sh, que gera e instala o código):
#   bash 96_producao_v1.0.sh SENHA_DO_BANCO         liga ou atualiza
#   bash 96_producao_v1.0.sh parar                  desliga
#   bash 96_producao_v1.0.sh conferir               confere o endereço público (saúde, cabeçalhos, login de teste)
# ============================================================
set -uo pipefail
ARG="${1:?uso: bash 96_producao_v1.0.sh <SENHA_DO_BANCO | parar | conferir> [RAIZ]}"
RAIZ="${2:-./programa-cut}"
AQUI="$(pwd)"
CONF="$HOME/.config/curso-ue/producao.env"
EM="$HOME/.config/curso-ue/email.env"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
falhar() { echo; echo "ERRO: $*"; exit 1; }
RABS="$(cd "$RAIZ" 2>/dev/null && pwd)" || falhar "pasta $RAIZ nao encontrada (rode antes o subir_api_pwa_wsl_v1.0.sh)"
mkdir -p "$RABS/logs"

# systemd de verdade (servidor) ou segundo plano (WSL)
if [ -d /run/systemd/system ] && ! grep -qi microsoft /proc/version 2>/dev/null; then SERVICOS=systemd; else SERVICOS=fundo; fi
UNIDADES="cut-api cut-notificador cut-gateway cut-tunel"

parar() {
  if [ "$SERVICOS" = systemd ]; then
    for u in $UNIDADES; do sudo systemctl disable --now "$u" >/dev/null 2>&1 && echo "parado: $u"; done
  fi
  for n in prod_api prod_gateway prod_notificador prod_tunel; do
    [ -f "$RABS/logs/$n.pid" ] && { kill -- "-$(cat "$RABS/logs/$n.pid")" 2>/dev/null || kill "$(cat "$RABS/logs/$n.pid")" 2>/dev/null; } && echo "parado: $n"
    rm -f "$RABS/logs/$n.pid"
  done
  true
}

ler_conf() {
  if [ ! -f "$CONF" ]; then
    mkdir -p "$(dirname "$CONF")"; chmod 700 "$(dirname "$CONF")"
    umask 077; printf 'DOMINIO=\nACESSO=caddy\nGOOGLE_CLIENT_ID=\nGOOGLE_CLIENT_SECRET=\nCLOUDFLARE_TOKEN=\n' > "$CONF"; chmod 600 "$CONF"
    falhar "criei $CONF vazio. Preencha (passo a passo em docs/producao_v1.0.md) e rode de novo."
  fi
  [ "$(stat -c %a "$CONF")" = "600" ] || chmod 600 "$CONF"
  set -a; . "$CONF"; set +a
  DOMINIO="${DOMINIO#https://}"; DOMINIO="${DOMINIO%/}"; ACESSO="${ACESSO:-caddy}"
  [ -n "${DOMINIO:-}" ] || falhar "preencha DOMINIO em $CONF"
  case "$ACESSO" in caddy|cloudflare|ngrok|local) ;; *) falhar "ACESSO em $CONF deve ser caddy, cloudflare, ngrok ou local";; esac
}

conferir() {
  local base="https://$DOMINIO"; [ "$ACESSO" = local ] && base="http://127.0.0.1:8080"
  echo "Conferindo $base ..."
  local s; s=$(curl -s --max-time 15 "$base/api/health"); echo "  saude da API: ${s:-sem resposta}"
  echo "$s" | grep -q '"db":"ok"' || return 1
  local t; t=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 -H "Content-Type: application/json" -d '{"email":"x@y.z"}' "$base/api/auth/login")
  echo "  login de teste: $t (esperado 404: desligado)"; [ "$t" = "404" ] || return 1
  local h; h=$(curl -s -D - -o /dev/null --max-time 15 "$base/login" | tr -d '\r')
  for c in Content-Security-Policy Strict-Transport-Security X-Frame-Options X-Robots-Tag; do
    echo "$h" | grep -qi "^$c:" && echo "  cabecalho $c: ok" || { echo "  cabecalho $c: FALTA"; return 1; }
  done
  local g; g=$(curl -s -o /dev/null -w "%{http_code} %{redirect_url}" --max-time 15 "$base/api/auth/google")
  echo "  entrada pelo Google: $g"
  echo "$g" | grep -q "accounts.google.com" || { echo "  (o Google nao esta configurado: confira GOOGLE_CLIENT_ID e GOOGLE_CLIENT_SECRET)"; return 1; }
  return 0
}

if [ "$ARG" = parar ]; then parar; exit 0; fi
ler_conf
if [ "$ARG" = conferir ]; then conferir && echo "OK" || falhar "a conferencia falhou (veja acima)"; exit 0; fi
PW="$ARG"
[ -n "${GOOGLE_CLIENT_ID:-}" ] && [ -n "${GOOGLE_CLIENT_SECRET:-}" ] || falhar "preencha GOOGLE_CLIENT_ID e GOOGLE_CLIENT_SECRET em $CONF"
[ -d "$RABS/api/node_modules" ] && [ -d "$RABS/pwa/node_modules" ] || falhar "rode antes o subir_api_pwa_wsl_v1.0.sh (gera o codigo e instala os pacotes)."
[ -f "$RABS/servidor/gateway.mjs" ] || falhar "falta servidor/gateway.mjs: rode o subir_api_pwa_wsl_v1.0.sh atualizado."
case "$ACESSO" in
  caddy) [ "$SERVICOS" = systemd ] || falhar "ACESSO=caddy e para servidor com IP publico (Google Cloud ou HC/USP). No seu computador, use cloudflare ou ngrok."
         command -v caddy >/dev/null || falhar "Caddy nao instalado. Veja docs/producao_v1.0.md (servidor, passo 3).";;
  cloudflare) [ -n "${CLOUDFLARE_TOKEN:-}" ] || falhar "preencha CLOUDFLARE_TOKEN em $CONF"
         command -v cloudflared >/dev/null || falhar "cloudflared nao instalado. Veja docs/producao_v1.0.md (tunel Cloudflare).";;
  ngrok) command -v ngrok >/dev/null || falhar "ngrok nao instalado. Veja docs/servidor_revisao_v1.0.md (passo 1).";;
esac

SQL="psql postgresql://postgres:$PW@$HOST:$PORTA/programa -v ON_ERROR_STOP=1 -q"
echo "[1/6] Atualizando o banco..."
for f in 49_revisores_v1.0.sql 53_temas_programa_v1.0.sql 54_temas_opcionais_v1.0.sql 55_avaliacao_ranking_v1.0.sql 58_duvidas_publicacao_v1.0.sql 59_aviso_revisao_v1.0.sql 60_jornada_aluno_v1.0.sql 62_cadastro_aluno_v1.0.sql 64_nota_esperada_v1.0.sql 65_arvore_temas_v1.0.sql 66_mural_presenca_v1.0.sql 68_estudo_dirigido_v1.0.sql 71_temas_producao_v1.0.sql 72_sintese_pesquisa_v1.0.sql 73_extras_v1.0.sql 76_certeza_questao_v1.0.sql 78_perfis_v1.0.sql 79_aluno_para_todos_v1.0.sql 81_sequencia_material_v1.0.sql 82_interativo_v1.0.sql 83_ajustes_v2p_v1.0.sql 84_falas_slides_T001_v1.0.sql 85_estudo_pesquisa_v1.0.sql 86_dicas_caso_T001_v1.0.sql 88_formato_tempo_v1.0.sql 89_coordenacao_agentes_v1.0.sql 92_prazos_producao_v1.0.sql 95_entrada_por_email_v1.0.sql; do
  $SQL -f "$f" >> "$RABS/logs/prod_banco.log" 2>&1 || falhar "$f falhou; veja $RAIZ/logs/prod_banco.log"
done
# producao: a funcao do login de teste deixa de existir no banco
$SQL -c "DROP FUNCTION IF EXISTS app.fn_sessao_teste(TEXT);" >> "$RABS/logs/prod_banco.log" 2>&1 || falhar "nao consegui remover o login de teste do banco"
echo "      ok (login de teste removido do banco)"

echo "[2/6] Gerando o aplicativo para producao (pwa/dist)..."
parar >/dev/null 2>&1
( cd "$AQUI" && bash subir_api_pwa_wsl_v1.0.sh parar "$RAIZ" >/dev/null 2>&1 ) || true
bash 50_servidor_revisao_v1.0.sh parar "$RAIZ" >/dev/null 2>&1 || true
( cd "$RABS/pwa" && VITE_API_URL=/api npx vite build > "$RABS/logs/prod_build.log" 2>&1 ) || falhar "o build do aplicativo falhou; veja $RAIZ/logs/prod_build.log"
echo "      ok"

echo "[3/6] Montando a configuracao dos servicos..."
AMB="$RABS/logs/.prod_ambiente"; umask 077
{
  echo "DATABASE_URL=postgresql://api_rw:$PW@$HOST:$PORTA/programa"
  echo "PORT=3000"; echo "NODE_ENV=production"; echo "LOG_LEVEL=info"
  echo "APP_URL=https://$DOMINIO"; echo "CORS_ORIGINS=https://$DOMINIO"
  echo "GOOGLE_REDIRECT_URI=https://$DOMINIO/api/auth/callback"
  echo "GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID"; echo "GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET"
  [ -f "$EM" ] && grep -E '^(SMTP_HOST|SMTP_PORT|SMTP_USER|SMTP_PASS|SMTP_FROM|NOTIFICAR_MODO)=' "$EM"
  [ "$ACESSO" = cloudflare ] && echo "TUNNEL_TOKEN=$CLOUDFLARE_TOKEN"   # o cloudflared le o token daqui, fora da linha de comando
  [ -f "$HOME/.config/curso-ue/push.env" ] && grep -vE '^\s*(#|$)' "$HOME/.config/curso-ue/push.env"
} > "$AMB"
chmod 600 "$AMB"
[ -f "$EM" ] && echo "      e-mail: conta configurada (lembretes e link de entrada)" || echo "      e-mail: SEM conta configurada; a entrada por e-mail responde 'nao configurado' (rode 52_configurar_email_v1.0.sh)"
NODE="$(command -v node)"; NPX="$(command -v npx)"

if [ "$SERVICOS" = systemd ]; then
  sudo install -d -m 700 /etc/cut
  sudo install -m 600 "$AMB" /etc/cut/producao.env
  unidade() {  # nome, pasta de trabalho, comando
    sudo tee "/etc/systemd/system/$1.service" >/dev/null <<UNIT
[Unit]
Description=CUT $1
After=network-online.target postgresql.service
Wants=network-online.target

[Service]
User=$(id -un)
WorkingDirectory=$2
EnvironmentFile=/etc/cut/producao.env
ExecStart=$3
Restart=always
RestartSec=5
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
UNIT
  }
  unidade cut-api "$RABS/api" "$NPX tsx src/main.ts"
  unidade cut-notificador "$RABS/api" "$NPX tsx src/notificador.ts"
  unidade cut-gateway "$RABS" "$NODE $RABS/servidor/gateway.mjs $RABS/pwa/dist 8080 http://127.0.0.1:3000"
  case "$ACESSO" in
    cloudflare) unidade cut-tunel "$RABS" "$(command -v cloudflared) tunnel --no-autoupdate run";;
    ngrok) unidade cut-tunel "$RABS" "$(command -v ngrok) http --url=$DOMINIO 8080 --log stdout";;
    *) sudo rm -f /etc/systemd/system/cut-tunel.service;;
  esac
  sudo systemctl daemon-reload
fi
echo "      ok ($SERVICOS)"

echo "[4/6] Ligando a API, o gateway e o enviador de e-mails..."
if [ "$SERVICOS" = systemd ]; then
  sudo systemctl enable --now cut-api cut-notificador cut-gateway >/dev/null 2>&1 || falhar "os servicos nao ligaram: sudo journalctl -u cut-api -n 50"
  sudo systemctl restart cut-api cut-notificador cut-gateway
else
  # cada parte numa sessao propria (setsid): o numero guardado no .pid e o do grupo inteiro, que o "parar" encerra
  ( set -a; . "$AMB"; set +a; cd "$RABS/api" || exit 1; nohup setsid npx tsx src/main.ts > "$RABS/logs/prod_api.log" 2>&1 < /dev/null & echo $! > "$RABS/logs/prod_api.pid" )
  ( set -a; . "$AMB"; set +a; cd "$RABS/api" || exit 1; nohup setsid npx tsx src/notificador.ts > "$RABS/logs/prod_notificador.log" 2>&1 < /dev/null & echo $! > "$RABS/logs/prod_notificador.pid" )
  ( nohup setsid node "$RABS/servidor/gateway.mjs" "$RABS/pwa/dist" 8080 http://127.0.0.1:3000 > "$RABS/logs/prod_gateway.log" 2>&1 < /dev/null & echo $! > "$RABS/logs/prod_gateway.pid" )
fi
OK=""; for i in $(seq 1 40); do sleep 1; curl -s http://127.0.0.1:8080/api/health | grep -q '"db":"ok"' && { OK=1; break; }; done
[ -n "$OK" ] || falhar "a API nao respondeu pelo gateway. Veja: $( [ "$SERVICOS" = systemd ] && echo 'sudo journalctl -u cut-api -n 50' || echo "$RAIZ/logs/prod_api.log")"
L=$(curl -s -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" -d '{"email":"x@y.z"}' http://127.0.0.1:8080/api/auth/login)
[ "$L" = "404" ] || falhar "o login de teste ainda responde ($L); a API nao esta em modo producao."
echo "      ok (login de teste desligado)"

echo "[5/6] Abrindo o acesso ($ACESSO) em https://$DOMINIO ..."
case "$ACESSO" in
  caddy)
    sudo tee /etc/caddy/Caddyfile >/dev/null <<CADDY
# CUT (96_producao_v1.0.sh): certificado HTTPS automatico (Let's Encrypt) e repasse ao gateway
$DOMINIO {
	encode zstd gzip
	reverse_proxy 127.0.0.1:8080
}
CADDY
    sudo systemctl enable --now caddy >/dev/null 2>&1; sudo systemctl reload caddy || falhar "o Caddy nao recarregou: sudo journalctl -u caddy -n 50";;
  cloudflare|ngrok)
    if [ "$SERVICOS" = systemd ]; then sudo systemctl enable --now cut-tunel >/dev/null 2>&1; sudo systemctl restart cut-tunel
    elif [ "$ACESSO" = cloudflare ]; then ( export TUNNEL_TOKEN="$CLOUDFLARE_TOKEN"; nohup setsid cloudflared tunnel --no-autoupdate run > "$RABS/logs/prod_tunel.log" 2>&1 < /dev/null & echo $! > "$RABS/logs/prod_tunel.pid" )
    else ( nohup setsid ngrok http --url="$DOMINIO" 8080 --log stdout > "$RABS/logs/prod_tunel.log" 2>&1 < /dev/null & echo $! > "$RABS/logs/prod_tunel.pid" ); fi;;
  local) echo "      (ACESSO=local: o servidor web da instituicao repassa o dominio para a porta 8080; o CUT nao abre acesso proprio)";;
esac

echo "[6/6] Conferindo o endereco publico..."
OK=""; for i in $(seq 1 12); do conferir > "$RABS/logs/prod_conferencia.log" 2>&1 && { OK=1; break; }; sleep 5; done
cat "$RABS/logs/prod_conferencia.log" | sed 's/^/      /'
[ -n "$OK" ] || falhar "o endereco publico nao passou na conferencia (veja acima). O certificado do Caddy pode levar 1 a 2 minutos na primeira vez: rode 'bash 96_producao_v1.0.sh conferir' daqui a pouco."

cat <<FIM

=== CUT NO AR (producao) ===
Endereco:   https://$DOMINIO
Servicos:   $( [ "$SERVICOS" = systemd ] && echo "systemd (voltam sozinhos depois de reiniciar o servidor)" || echo "segundo plano no WSL (o computador precisa ficar ligado)")
Desligar:   bash 96_producao_v1.0.sh parar
Conferir:   bash 96_producao_v1.0.sh conferir
Copia diaria do banco: $( [ "$SERVICOS" = systemd ] && echo "bash 96_backup_producao_v1.0.sh configurar  e depois  agendar" || echo "bash 70_backup_drive_v1.0.sh agendar")
FIM
