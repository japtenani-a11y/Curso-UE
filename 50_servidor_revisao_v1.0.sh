#!/usr/bin/env bash
# ============================================================
# 50_servidor_revisao_v1.0.sh
# OBJETIVO: colocar o aplicativo na internet, a partir do seu computador (WSL), para os revisores
# entrarem com o login do Google. Tudo passa por uma porta unica (gateway) e um tunel HTTPS do ngrok.
#   navegador -> https://SEU-DOMINIO.ngrok-free.app -> ngrok -> gateway :8080 -> aplicativo (pwa/dist)
#                                                                         \-> /api/* -> API :3000
# Quem entra: so os e-mails cadastrados no 49_revisores_v1.0.sql (japtenani, Aline, Jorge).
# Modo producao: sem login de teste, cookies seguros, CORS so do dominio, limites de acesso.
#
# PREPARO (uma vez so; ver docs/servidor_revisao_v1.0.md):
#  1. ngrok: conta gratuita, "Static Domain" gratuito e o authtoken (ngrok config add-authtoken ...).
#  2. Google Cloud: credencial OAuth "Aplicativo da Web" com
#       origem autorizada:       https://SEU-DOMINIO
#       URI de redirecionamento: https://SEU-DOMINIO/api/auth/callback
#  3. Arquivo ~/.config/curso-ue/servidor.env (permissao 600), fora do repositorio:
#       DOMINIO=seu-dominio.ngrok-free.app
#       GOOGLE_CLIENT_ID=...
#       GOOGLE_CLIENT_SECRET=...
#
# USO:   bash 50_servidor_revisao_v1.0.sh <SENHA_DO_BANCO> [RAIZ]
#        bash 50_servidor_revisao_v1.0.sh parar [RAIZ]
# PRE-REQUISITO: ter rodado o subir_api_pwa_wsl_v1.0.sh pelo menos uma vez (gera o codigo e instala pacotes).
# ============================================================
set -uo pipefail
PW="${1:?uso: bash 50_servidor_revisao_v1.0.sh <SENHA_DO_BANCO> [RAIZ]}"
RAIZ="${2:-./programa-cut}"
RABS="$(cd "$RAIZ" 2>/dev/null && pwd)" || { echo "ERRO: pasta $RAIZ nao encontrada"; exit 1; }
CONF="$HOME/.config/curso-ue/servidor.env"
EM="$HOME/.config/curso-ue/email.env"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
falhar() { echo; echo "ERRO: $*"; exit 1; }

parar() {
  for n in srv_api srv_gateway srv_ngrok srv_notificador srv_respondedor; do
    [ -f "$RABS/logs/$n.pid" ] && kill "$(cat "$RABS/logs/$n.pid")" 2>/dev/null && echo "parado: $n"
    rm -f "$RABS/logs/$n.pid"
  done
  pkill -f "servidor/gateway.mjs" 2>/dev/null; pkill -f "ngrok http" 2>/dev/null; true
}
if [ "$PW" = "parar" ]; then parar; exit 0; fi

# ---------- conferencias ----------
mkdir -p "$RABS/logs"
if [ ! -f "$CONF" ]; then
  mkdir -p "$(dirname "$CONF")"; chmod 700 "$(dirname "$CONF")"
  umask 077; printf 'DOMINIO=\nGOOGLE_CLIENT_ID=\nGOOGLE_CLIENT_SECRET=\n' > "$CONF"; chmod 600 "$CONF"
  falhar "criei $CONF vazio. Preencha DOMINIO, GOOGLE_CLIENT_ID e GOOGLE_CLIENT_SECRET (passo a passo em docs/servidor_revisao_v1.0.md) e rode de novo."
fi
[ "$(stat -c %a "$CONF")" = "600" ] || chmod 600 "$CONF"
set -a; . "$CONF"; set +a
[ -n "${DOMINIO:-}" ] && [ -n "${GOOGLE_CLIENT_ID:-}" ] && [ -n "${GOOGLE_CLIENT_SECRET:-}" ] || falhar "preencha DOMINIO, GOOGLE_CLIENT_ID e GOOGLE_CLIENT_SECRET em $CONF"
DOMINIO="${DOMINIO#https://}"; DOMINIO="${DOMINIO%/}"
command -v ngrok >/dev/null || falhar "ngrok nao instalado. Veja docs/servidor_revisao_v1.0.md (passo 1)."
[ -d "$RABS/api/node_modules" ] && [ -d "$RABS/pwa/node_modules" ] || falhar "rode antes o subir_api_pwa_wsl_v1.0.sh (instala os pacotes)."
[ -f "$RABS/servidor/gateway.mjs" ] || falhar "falta servidor/gateway.mjs: rode o subir_api_pwa_wsl_v1.0.sh atualizado (ele aplica o 51)."

SQL="psql postgresql://postgres:$PW@$HOST:$PORTA/programa -v ON_ERROR_STOP=1 -q"
echo "[1/5] Cadastrando revisores e registro de acesso..."
for f in 49_revisores_v1.0.sql 53_temas_programa_v1.0.sql 54_temas_opcionais_v1.0.sql 55_avaliacao_ranking_v1.0.sql 58_duvidas_publicacao_v1.0.sql 59_aviso_revisao_v1.0.sql 60_jornada_aluno_v1.0.sql 62_cadastro_aluno_v1.0.sql 64_nota_esperada_v1.0.sql; do
  $SQL -f $f >> "$RABS/logs/srv_banco.log" 2>&1 || falhar "$f falhou; veja $RAIZ/logs/srv_banco.log"
done
grep -E "@" "$RABS/logs/srv_banco.log" | sed 's/^/      /'

echo "[2/5] Gerando o aplicativo para producao (pwa/dist)..."
parar >/dev/null 2>&1
bash subir_api_pwa_wsl_v1.0.sh parar >/dev/null 2>&1 || true
( cd "$RABS/pwa" && VITE_API_URL=/api npx vite build > "$RABS/logs/srv_build.log" 2>&1 ) || falhar "o build do aplicativo falhou; veja $RAIZ/logs/srv_build.log"
echo "      ok"

echo "[3/5] Ligando a API em modo producao (porta 3000)..."
( cd "$RABS/api" && DATABASE_URL="postgresql://api_rw:$PW@$HOST:$PORTA/programa" PORT=3000 NODE_ENV=production \
  APP_URL="https://$DOMINIO" CORS_ORIGINS="https://$DOMINIO" GOOGLE_REDIRECT_URI="https://$DOMINIO/api/auth/callback" \
  GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" LOG_LEVEL=info \
  nohup setsid npx tsx src/main.ts > "$RABS/logs/srv_api.log" 2>&1 & echo $! > "$RABS/logs/srv_api.pid" )
OK=""; for i in $(seq 1 30); do sleep 1; curl -s http://127.0.0.1:3000/health | grep -q '"db":"ok"' && { OK=1; break; }; done
[ -n "$OK" ] || { tail -20 "$RABS/logs/srv_api.log"; falhar "a API nao respondeu (veja acima)."; }
L=$(curl -s -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" -d '{"email":"curador.teste@setup.local"}' http://127.0.0.1:3000/auth/login)
[ "$L" = "404" ] || falhar "o login de teste ainda responde ($L); a API nao esta em modo producao."
echo "      ok (login de teste desligado)"

echo "[4/5] Ligando o gateway (porta 8080) e o enviador de e-mails (lembretes, duvidas e respostas)..."
( nohup setsid node "$RABS/servidor/gateway.mjs" "$RABS/pwa/dist" 8080 http://127.0.0.1:3000 > "$RABS/logs/srv_gateway.log" 2>&1 & echo $! > "$RABS/logs/srv_gateway.pid" )
sleep 1; curl -s http://127.0.0.1:8080/api/health | grep -q ok || falhar "o gateway nao respondeu; veja $RAIZ/logs/srv_gateway.log"
( set -a; [ -f "$EM" ] && . "$EM"; set +a; cd "$RABS/api" && DATABASE_URL="postgresql://api_rw:$PW@$HOST:$PORTA/programa" NODE_ENV=production \
  NOTIFICAR_MODO="${NOTIFICAR_MODO:-simular}" APP_URL="https://$DOMINIO" GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" \
  GOOGLE_REDIRECT_URI="https://$DOMINIO/api/auth/callback" CORS_ORIGINS="https://$DOMINIO" LOG_LEVEL=info \
  nohup setsid npx tsx src/notificador.ts > "$RABS/logs/srv_notificador.log" 2>&1 & echo $! > "$RABS/logs/srv_notificador.pid" )
echo "      ok"

echo "[5/5] Abrindo o tunel HTTPS (ngrok) em https://$DOMINIO ..."
( nohup setsid ngrok http --url="$DOMINIO" 8080 --log stdout > "$RABS/logs/srv_ngrok.log" 2>&1 & echo $! > "$RABS/logs/srv_ngrok.pid" )
OK=""; for i in $(seq 1 20); do sleep 1; curl -s "https://$DOMINIO/api/health" | grep -q ok && { OK=1; break; }; done
[ -n "$OK" ] || { tail -15 "$RABS/logs/srv_ngrok.log"; falhar "o tunel nao respondeu (veja acima). Confira o authtoken e o dominio do ngrok."; }

cat <<FIM

=== SERVIDOR DE REVISAO NO AR ===
Endereco para os revisores:  https://$DOMINIO
Quem entra (login do Google): japtenani@gmail.com, aline@sardow.com, jorge.carnesecca@hotmail.com
O computador precisa ficar ligado e conectado enquanto os revisores trabalham.
Na primeira visita o ngrok mostra uma pagina de aviso: basta clicar em "Visit Site".

Para desligar:  bash 50_servidor_revisao_v1.0.sh parar
Registros:      $RAIZ/logs/srv_*.log
FIM
