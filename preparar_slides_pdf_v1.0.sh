#!/usr/bin/env bash
# ============================================================
# preparar_slides_pdf_v1.0.sh
# OBJETIVO: pôr no aplicativo as imagens do deck de slides de um tema (aula e caso clínico).
#   Recebe o PDF do deck (no PowerPoint ou no Google Slides: Arquivo > Salvar como / Baixar > PDF) e grava cada
#   página como imagem em programa-cut/slides/<CODIGO>/slide_01.png, slide_02.png...
#   O aplicativo mostra a imagem no lugar do slide desenhado a partir do texto, com o mesmo número.
#   A ordem das páginas deve ser a mesma da tela: os slides da aula e, depois, os do caso clínico.
# USO (no WSL, dentro de ~/Curso-UE):
#   bash preparar_slides_pdf_v1.0.sh T001 /mnt/c/Users/japt7/Downloads/T001_slides.pdf
# PRE-REQUISITO: pdftoppm (instalar uma vez com: sudo apt install -y poppler-utils)
# Pode ser rodado de novo: troca as imagens antigas do tema. Os áudios (slide_NN.mp3) não são tocados.
# ============================================================
set -euo pipefail
COD="$(echo "${1:?uso: bash preparar_slides_pdf_v1.0.sh <CODIGO> <arquivo.pdf>}" | tr -d '-' | tr '[:lower:]' '[:upper:]')"
PDF="${2:?informe o arquivo PDF do deck}"
[ -f "$PDF" ] || { echo "ERRO: não achei o arquivo $PDF"; exit 1; }
command -v pdftoppm >/dev/null || { echo "ERRO: falta o pdftoppm. Rode: sudo apt install -y poppler-utils"; exit 1; }
AQUI="$(cd "$(dirname "$0")" && pwd)"
DEST="$AQUI/programa-cut/slides/$COD"
mkdir -p "$DEST"
TMP="$(mktemp -d)"
pdftoppm -png -scale-to-x 1600 -scale-to-y -1 "$PDF" "$TMP/p"
rm -f "$DEST"/slide_*.png
n=0
for f in $(ls "$TMP"/p-*.png | sort -V); do
  n=$((n + 1)); cp "$f" "$DEST/$(printf 'slide_%02d.png' "$n")"
done
rm -rf "$TMP"
echo "$COD: $n imagens gravadas em $DEST"
echo "Confira no aplicativo (peça 'Slides da aula'): a tela mostra quantos slides existem no texto; se o número"
echo "de páginas do PDF for diferente, as imagens e as falas ficam desencontradas."
