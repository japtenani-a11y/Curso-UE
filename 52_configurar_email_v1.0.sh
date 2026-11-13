#!/usr/bin/env bash
# ============================================================
# 52_configurar_email_v1.0.sh
# OBJETIVO: ligar o envio dos lembretes por e-mail usando a conta Gmail do coordenador
# (japtenani@gmail.com). WhatsApp fica desligado.
# A senha NAO e a senha normal do Gmail: e uma "senha de app" de 16 letras, criada em
#   https://myaccount.google.com/apppasswords  (exige verificacao em duas etapas ligada).
# A senha fica so em ~/.config/curso-ue/email.env (permissao 600), fora do repositorio.
# USO: bash 52_configurar_email_v1.0.sh [./programa-cut]
#      Pergunta a senha de app sem mostrar na tela e manda um e-mail de teste para voce mesmo.
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
CONTA="japtenani@gmail.com"
DIR="$HOME/.config/curso-ue"; ARQ="$DIR/email.env"
mkdir -p "$DIR"; chmod 700 "$DIR"
read -r -s -p "Senha de app do Gmail para $CONTA (16 letras, sem espacos): " SENHA; echo
SENHA="$(printf '%s' "$SENHA" | tr -d ' ')"
[ "${#SENHA}" -eq 16 ] || { echo "ERRO: a senha de app tem 16 letras. Crie em https://myaccount.google.com/apppasswords"; exit 1; }
umask 077
cat > "$ARQ" <<FIM
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_USER=$CONTA
SMTP_PASS=$SENHA
SMTP_FROM="Programa de Cirurgia de Urgência e Trauma <$CONTA>"
NOTIFICAR_MODO=enviar
FIM
chmod 600 "$ARQ"
unset SENHA
echo "gravado: $ARQ (so voce pode ler)"
if [ -d "$RAIZ/api/node_modules/nodemailer" ]; then
  ( set -a; . "$ARQ"; set +a; cd "$RAIZ/api" && npx tsx src/notificador.ts --teste-email "$CONTA" ) \
    && echo "Confira a caixa de entrada de $CONTA." \
    || echo "O teste falhou. Confira a senha de app e se a verificacao em duas etapas esta ligada."
else
  echo "Rode antes o subir_api_pwa_wsl_v1.0.sh (instala o pacote de e-mail) e depois este script de novo para o teste."
fi
