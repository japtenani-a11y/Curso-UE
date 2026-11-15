#!/usr/bin/env bash
# ============================================================
# 70_backup_drive_v1.0.sh
# OBJETIVO: copia de seguranca diaria do banco, CRIPTOGRAFADA, numa pasta do Windows que o
#           "Google Drive para computador" sincroniza. O Google so ve um arquivo cifrado.
# USO:
#   bash 70_backup_drive_v1.0.sh configurar   # cria ~/.config/curso-ue/backup.env (pede a frase-senha)
#   bash 70_backup_drive_v1.0.sh              # faz a copia agora (e apaga as com mais de 30 dias)
#   bash 70_backup_drive_v1.0.sh testar       # restaura a copia mais recente num banco temporario e confere
#   bash 70_backup_drive_v1.0.sh agendar      # mostra o comando para agendar todo dia no Windows
# Nenhuma senha fica no script nem no repositorio: tudo em ~/.config/curso-ue/backup.env (chmod 600).
# ============================================================
set -euo pipefail
CFG="$HOME/.config/curso-ue/backup.env"
ACAO="${1:-copiar}"

if [ "$ACAO" = "configurar" ]; then
  mkdir -p "$(dirname "$CFG")"; chmod 700 "$(dirname "$CFG")"
  read -r -p "Pasta de destino no Windows [/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r' || echo SEU_USUARIO)/CursoUE_backups]: " DEST
  DEST="${DEST:-/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')/CursoUE_backups}"
  case "$DEST" in /*) ;; *) echo "ERRO: use o caminho completo, ex.: /mnt/c/Users/SEU_USUARIO/CursoUE_backups"; exit 1 ;; esac
  read -r -s -p "Frase-senha da criptografia (guarde num lugar seguro; sem ela a copia nao abre): " F1; echo
  read -r -s -p "Repita a frase-senha: " F2; echo
  [ "$F1" = "$F2" ] && [ ${#F1} -ge 12 ] || { echo "ERRO: frases diferentes ou com menos de 12 caracteres"; exit 1; }
  umask 077
  { echo "DESTINO='$DEST'"; echo "FRASE='$F1'"; echo "PGHOST=localhost"; echo "PGPORT=5432"; echo "PGDATABASE=programa"; echo "PGUSER=postgres"; echo "DIAS=30"; } > "$CFG"
  chmod 600 "$CFG"; mkdir -p "$DEST"
  echo "OK: configuracao salva em $CFG"
  echo "Se o usuario postgres pedir senha, crie ~/.pgpass (chmod 600) com: localhost:5432:*:postgres:SUA_SENHA"
  echo "Agora, no Google Drive para computador: Preferencias > Meu computador > Adicionar pasta > escolha $DEST"
  exit 0
fi

[ -f "$CFG" ] || { echo "ERRO: rode antes: bash $0 configurar"; exit 1; }
# shellcheck disable=SC1090
. "$CFG"; export PGHOST PGPORT PGDATABASE PGUSER
case "$DESTINO" in /*) ;; *) echo "ERRO: DESTINO em $CFG precisa ser um caminho completo (ex.: /mnt/c/Users/SEU_USUARIO/CursoUE_backups)"; exit 1 ;; esac
[ -f "$HOME/.pgpass" ] || echo "AVISO: sem ~/.pgpass o banco vai pedir senha varias vezes (veja docs/atualizacao_v2l.md)"
export PGPASSFILE="$HOME/.pgpass"
command -v gpg >/dev/null || { echo "ERRO: instale o gpg: sudo apt install -y gnupg"; exit 1; }

case "$ACAO" in
  copiar)
    mkdir -p "$DESTINO"
    ARQ="$DESTINO/programa_$(date +%Y%m%d_%H%M).dump.gpg"
    pg_dump -Fc "$PGDATABASE" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 3 --symmetric --cipher-algo AES256 -o "$ARQ.parcial" 3<<<"$FRASE"
    mv "$ARQ.parcial" "$ARQ"
    find "$DESTINO" -maxdepth 1 -name 'programa_*.dump.gpg' -mtime +"${DIAS:-30}" -delete
    echo "$(date '+%F %T') copia ok: $ARQ ($(du -h "$ARQ" | cut -f1))" | tee -a "$DESTINO/registro.txt"
    ;;
  testar)
    ULT=$(ls -1t "$DESTINO"/programa_*.dump.gpg 2>/dev/null | head -1)
    [ -n "$ULT" ] || { echo "ERRO: nenhuma copia em $DESTINO"; exit 1; }
    T="teste_restauracao_$$"
    createdb "$T"
    trap 'dropdb --if-exists "$T"' EXIT
    gpg --batch --pinentry-mode loopback --passphrase-fd 3 -d "$ULT" 3<<<"$FRASE" 2>/dev/null | pg_restore -d "$T" --no-owner 2>/dev/null || true
    N=$(psql -d "$T" -Atc "SELECT count(*) FROM app.pessoa" 2>/dev/null || echo 0)
    TM=$(psql -d "$T" -Atc "SELECT count(*) FROM app.tema" 2>/dev/null || echo 0)
    if [ "$TM" -gt 0 ]; then echo "OK: $ULT restaurou ($N pessoas, $TM temas)"; else echo "FALHA: a copia nao restaurou"; exit 1; fi
    ;;
  agendar)
    echo "No Windows, abra o PowerShell (nao precisa ser administrador) e cole UMA linha:"
    echo "schtasks /Create /SC DAILY /ST 03:17 /TN \"CursoUE backup\" /TR \"wsl.exe -e bash -lc 'bash ~/Curso-UE/70_backup_drive_v1.0.sh >> ~/backup.log 2>&1'\""
    echo "O computador precisa estar ligado no horario. Para conferir: schtasks /Query /TN \"CursoUE backup\""
    ;;
  *) echo "uso: bash $0 [configurar|copiar|testar|agendar]"; exit 1 ;;
esac
