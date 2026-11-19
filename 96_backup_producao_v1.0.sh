#!/usr/bin/env bash
# ============================================================
# 96_backup_producao_v1.0.sh
# OBJETIVO: cópia de segurança diária do banco quando o CUT roda num servidor (Google Cloud ou HC/USP).
# Usa o mesmo 70_backup_drive_v1.0.sh (pg_dump criptografado com a sua frase-senha), com o destino no servidor,
# e traz as cópias para o seu computador, numa pasta que o Google Drive sincroniza (cópia fora do servidor).
#   No servidor:
#     bash 96_backup_producao_v1.0.sh configurar     pasta ~/cut_backups e frase-senha (uma vez)
#     bash 96_backup_producao_v1.0.sh agendar        agenda todo dia às 03:17 (cron do servidor)
#     bash 96_backup_producao_v1.0.sh testar         restaura a cópia mais recente num banco temporário e confere
#   No seu computador (WSL), para trazer as cópias:
#     bash 96_backup_producao_v1.0.sh baixar USUARIO@SERVIDOR /mnt/c/Users/SEU_USUARIO/CursoUE_backups
# Com o CUT no seu computador (opção 3), use direto o 70_backup_drive_v1.0.sh.
# ============================================================
set -euo pipefail
ACAO="${1:?uso: bash 96_backup_producao_v1.0.sh configurar|agendar|copiar|testar|baixar}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/curso-ue/backup.env"
case "$ACAO" in
  configurar)
    mkdir -p "$(dirname "$CFG")"; chmod 700 "$(dirname "$CFG")"
    read -r -s -p "Frase-senha da criptografia (12 caracteres ou mais; guarde num lugar seguro): " F1; echo
    read -r -s -p "Repita a frase-senha: " F2; echo
    [ "$F1" = "$F2" ] && [ ${#F1} -ge 12 ] || { echo "ERRO: frases diferentes ou com menos de 12 caracteres"; exit 1; }
    umask 077
    { echo "DESTINO='$HOME/cut_backups'"; echo "FRASE='$F1'"; echo "PGHOST=localhost"; echo "PGPORT=5432"; echo "PGDATABASE=programa"; echo "PGUSER=postgres"; echo "DIAS=14"; } > "$CFG"
    chmod 600 "$CFG"; mkdir -p "$HOME/cut_backups"
    [ -f "$HOME/.pgpass" ] || echo "Crie ~/.pgpass (chmod 600) com a linha  localhost:5432:*:postgres:SENHA_DO_BANCO  para a copia rodar sem pedir senha."
    echo "OK: copias em $HOME/cut_backups (as com mais de 14 dias sao apagadas; o seu computador guarda as antigas)."
    ;;
  agendar)
    L="17 3 * * * bash $AQUI/70_backup_drive_v1.0.sh >> $HOME/cut_backups/cron.log 2>&1"
    ( crontab -l 2>/dev/null | grep -v "70_backup_drive_v1.0.sh"; echo "$L" ) | crontab -
    echo "OK: agendado todo dia as 03:17 (horario do servidor: $(date +%Z)). Para conferir: crontab -l"
    ;;
  copiar|testar) bash "$AQUI/70_backup_drive_v1.0.sh" "$ACAO" ;;
  baixar)
    SRV="${2:?uso: bash 96_backup_producao_v1.0.sh baixar USUARIO@SERVIDOR PASTA_NO_WINDOWS}"
    DEST="${3:?falta a pasta de destino, ex.: /mnt/c/Users/SEU_USUARIO/CursoUE_backups}"
    mkdir -p "$DEST"
    # so arquivos ja terminados (.dump.gpg), nunca o .parcial em andamento
    scp -q "$SRV:cut_backups/programa_*.dump.gpg" "$DEST/" && echo "OK: copias do servidor em $DEST ($(ls -1 "$DEST"/programa_*.dump.gpg | wc -l) arquivos)."
    echo "Para trazer todo dia, agende no Windows (PowerShell, uma linha):"
    echo "schtasks /Create /SC DAILY /ST 07:47 /TN \"CUT baixar backup\" /TR \"wsl.exe -e bash -lc 'bash ~/Curso-UE/96_backup_producao_v1.0.sh baixar $SRV $DEST >> ~/backup.log 2>&1'\""
    ;;
  *) echo "uso: bash $0 configurar|agendar|copiar|testar|baixar"; exit 1 ;;
esac
