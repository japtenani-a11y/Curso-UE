#!/usr/bin/env bash
# ============================================================
# importar_tema_v1.0.sh
# OBJETIVO: carregar um tema inteiro no banco, a partir da pasta conteudo/<TEMA> no formato de docs/producao_de_tema.md:
#   pecas (rascunho), afirmacoes com o trecho da fonte, fontes com texto integral (PDFs), casos dos testes e questoes
#   (com as ancoras). Os testes e gabaritos sao gerados a partir de questoes.json.
#   Primeiro CONFERE (nada e gravado). So grava com --aplicar, e so se nao houver erro.
# USO:  bash importar_tema_v1.0.sh T002 SENHA            (confere)
#       bash importar_tema_v1.0.sh T002 SENHA --aplicar  (grava)
#       bash importar_tema_v1.0.sh T002 SENHA --producao            (confere a pasta que o agente produtor montou em
#                                                                 C:\Users\<voce>\CUT_coordenacao\producao\T002)
#       bash importar_tema_v1.0.sh T002 SENHA --producao --aplicar  (grava tudo, inclusive questoes, casos e ondas)
# PRE-REQUISITO: banco instalado pelo subir (88 e 89 incluidos) e pdftotext (sudo apt install -y poppler-utils).
# Pode ser rodado mais de uma vez: peca igual nao vira versao nova; questao ja respondida por aluno nao e alterada.
# ============================================================
set -uo pipefail
TEMA="$(echo "${1:?uso: bash importar_tema_v1.0.sh T002 SENHA [--aplicar]}" | tr -d '-' | tr 'a-z' 'A-Z')"
PW="${2:?informe a senha do banco}"; MODO=""; DE_PRODUCAO=""
for x in "${@:3}"; do case "$x" in --aplicar) MODO="--aplicar" ;; --producao) DE_PRODUCAO=1 ;; *) echo "ERRO: opcao desconhecida $x"; exit 1 ;; esac; done
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
AQUI="$(cd "$(dirname "$0")" && pwd)"; PASTA="$AQUI/conteudo/$TEMA"
if [ -n "$DE_PRODUCAO" ]; then
  if [ -z "${COORD_DIR:-}" ]; then
    WINHOME="$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')"
    if [ -n "$WINHOME" ] && command -v wslpath >/dev/null; then COORD_DIR="$(wslpath "$WINHOME")/CUT_coordenacao"; else COORD_DIR="$HOME/CUT_coordenacao"; fi
  fi
  PASTA="$COORD_DIR/producao/$TEMA"
fi
[ -d "$PASTA" ] || { echo "ERRO: nao achei a pasta $PASTA"; exit 1; }
mkdir -p "$AQUI/logs"; SAIDA="$AQUI/logs/importar_${TEMA}.sql"
echo "[1/2] Conferindo a pasta $PASTA..."
python3 -I "$AQUI/ferramentas/importar_tema.py" "$PASTA" "$SAIDA" || { echo; echo "Corrija os erros acima e rode de novo. Nada foi gravado."; exit 1; }
if [ "$MODO" = "--aplicar" ]; then FIM="COMMIT;"; else FIM="ROLLBACK;"; fi
printf '%s\n' "$FIM" >> "$SAIDA"
echo "[2/2] Conferindo no banco (formato das pecas) $( [ "$MODO" = "--aplicar" ] && echo 'e gravando' )..."
if PGPASSWORD="$PW" psql -h "$HOST" -p "$PORTA" -U postgres -d programa -v ON_ERROR_STOP=1 -q -f "$SAIDA"; then
  if [ "$MODO" = "--aplicar" ]; then
    echo; echo "PRONTO: $TEMA gravado em rascunho. Proximo passo: revisao (painel > Para revisar e tela Revisao)."
  else
    echo; echo "CONFERIDO: nenhum erro. Para gravar: bash importar_tema_v1.0.sh $TEMA SENHA --aplicar"
  fi
else
  echo; echo "ERRO no banco (detalhe acima). Nada foi gravado."; exit 1
fi
