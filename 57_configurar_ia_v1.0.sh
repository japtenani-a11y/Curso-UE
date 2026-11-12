#!/usr/bin/env bash
# ============================================================
# 57_configurar_ia_v1.0.sh
# OBJETIVO: ligar as respostas das duvidas dos alunos por IA (Claude, pela API da Anthropic).
# Use uma chave NOVA (as antigas foram revogadas), criada em console.anthropic.com > API Keys.
# A chave fica so em ~/.config/curso-ue/ia.env (permissao 600), fora do repositorio. Nunca a cole no chat.
# USO: bash 57_configurar_ia_v1.0.sh
# ============================================================
set -euo pipefail
DIR="$HOME/.config/curso-ue"; ARQ="$DIR/ia.env"
mkdir -p "$DIR"; chmod 700 "$DIR"
read -r -s -p "Chave da API da Anthropic (comeca com sk-ant-): " CHAVE; echo
case "$CHAVE" in sk-ant-*) ;; *) echo "ERRO: a chave deve comecar com sk-ant-"; exit 1;; esac
umask 077
printf 'ANTHROPIC_API_KEY=%s\nANTHROPIC_MODEL=claude-sonnet-5-5\n' "$CHAVE" > "$ARQ"
chmod 600 "$ARQ"; unset CHAVE
echo "gravado: $ARQ (so voce pode ler). O respondedor liga junto com o subir_api_pwa_wsl e com o 50_servidor_revisao."
