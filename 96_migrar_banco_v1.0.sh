#!/usr/bin/env bash
# ============================================================
# 96_migrar_banco_v1.0.sh
# OBJETIVO: levar o banco do CUT do seu computador (WSL) para o servidor de produção, sem perder nada:
# temas, questões, pareceres, inscrições, respostas. O arquivo viaja CRIPTOGRAFADO (frase-senha sua).
#   No seu computador:  bash 96_migrar_banco_v1.0.sh exportar SENHA_DO_BANCO
#        -> gera ~/cut_migracao_AAAAMMDD_HHMM.dump.gpg (pede uma frase-senha; guarde-a)
#   Leve o arquivo ao servidor (passo a passo em docs/producao_v1.0.md, "Levar o banco"):
#        scp ~/cut_migracao_*.dump.gpg USUARIO@SERVIDOR:~/
#   No servidor (depois do instalar_banco_wsl_v1.0.sh, que cria os usuarios do banco):
#        bash 96_migrar_banco_v1.0.sh importar SENHA_DO_BANCO ~/cut_migracao_AAAAMMDD_HHMM.dump.gpg
#        -> o banco que estava no servidor fica guardado como programa_antes_AAAAMMDD_HHMM (nada e apagado)
# Se o seu computador continuar no ar (opcao 3), nao e preciso migrar.
# ============================================================
set -uo pipefail
ACAO="${1:?uso: bash 96_migrar_banco_v1.0.sh exportar|importar SENHA_DO_BANCO [ARQUIVO]}"
PW="${2:?falta a senha do banco}"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
URL() { echo "postgresql://postgres:$PW@$HOST:$PORTA/$1"; }
falhar() { echo; echo "ERRO: $*"; exit 1; }
command -v gpg >/dev/null || falhar "instale o gpg: sudo apt install -y gnupg"
frase() {
  if [ -n "${FRASE_MIGRACAO:-}" ]; then FR="$FRASE_MIGRACAO"; return; fi
  read -r -s -p "Frase-senha da criptografia (12 caracteres ou mais): " FR; echo
  [ ${#FR} -ge 12 ] || falhar "frase com menos de 12 caracteres"
  if [ "$1" = nova ]; then read -r -s -p "Repita a frase-senha: " F2; echo; [ "$FR" = "$F2" ] || falhar "as frases nao conferem"; fi
}
contar() { psql "$(URL "$1")" -Atc "SELECT (SELECT count(*) FROM app.tema)||' temas, '||(SELECT count(*) FROM app.pessoa)||' pessoas, '||(SELECT count(*) FROM app.item)||' questoes'" 2>/dev/null; }

case "$ACAO" in
  exportar)
    psql "$(URL programa)" -Atc "SELECT 1" >/dev/null 2>&1 || falhar "nao consegui entrar no banco (senha ou banco desligado)"
    echo "Banco atual: $(contar programa)"
    frase nova
    ARQ="$HOME/cut_migracao_$(date +%Y%m%d_%H%M).dump.gpg"; umask 077
    pg_dump -Fc "$(URL programa)" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 3 --symmetric --cipher-algo AES256 -o "$ARQ.parcial" 3<<<"$FR" \
      || falhar "a exportacao falhou"
    mv "$ARQ.parcial" "$ARQ"
    echo "OK: $ARQ ($(du -h "$ARQ" | cut -f1)), criptografado."
    echo "Proximo passo: leve este arquivo ao servidor (docs/producao_v1.0.md, 'Levar o banco')."
    ;;
  importar)
    ARQ="${3:?falta o arquivo .dump.gpg}"; [ -f "$ARQ" ] || falhar "arquivo $ARQ nao encontrado"
    psql "$(URL postgres)" -Atc "SELECT 1 FROM pg_roles WHERE rolname='api_rw'" 2>/dev/null | grep -q 1 \
      || falhar "o servidor ainda nao tem os usuarios do banco: rode antes  bash instalar_banco_wsl_v1.0.sh SENHA ./programa-cut"
    frase confere
    TMP="$(mktemp -d)"; trap 'rm -rf "${TMP:?}"' EXIT
    gpg --batch --pinentry-mode loopback --passphrase-fd 3 -d -o "$TMP/b.dump" "$ARQ" 3<<<"$FR" 2>/dev/null || falhar "nao abriu: frase-senha errada ou arquivo incompleto"
    pg_restore -l "$TMP/b.dump" >/dev/null 2>&1 || falhar "o arquivo nao e uma copia valida do banco"
    for s in cut-api cut-notificador; do sudo -n systemctl stop "$s" 2>/dev/null || true; done
    GUARDA="programa_antes_$(date +%Y%m%d_%H%M%S)"
    if psql "$(URL postgres)" -Atc "SELECT 1 FROM pg_database WHERE datname='programa'" | grep -q 1; then
      psql "$(URL postgres)" -qc "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='programa' AND pid<>pg_backend_pid();" >/dev/null
      psql "$(URL postgres)" -qc "ALTER DATABASE programa RENAME TO $GUARDA;" || falhar "nao consegui guardar o banco atual"
      echo "Banco que estava no servidor guardado como $GUARDA"
    fi
    psql "$(URL postgres)" -qc "CREATE DATABASE programa;" || falhar "nao consegui criar o banco"
    pg_restore -d "$(URL programa)" "$TMP/b.dump" > "$TMP/erros.txt" 2>&1
    NERR=$(grep -c "^pg_restore: error" "$TMP/erros.txt" || true)
    # os usuarios do banco (e as senhas deles) sao os do servidor, criados pelo instalar_banco; a copia so traz os dados
    echo "Banco restaurado: $(contar programa)"
    if [ "${NERR:-0}" -gt 0 ]; then echo "AVISO: $NERR erros na restauracao (os primeiros):"; grep "^pg_restore: error" "$TMP/erros.txt" | head -5 | sed 's/^/  /'; fi
    for s in cut-api cut-notificador; do sudo -n systemctl start "$s" 2>/dev/null || true; done
    echo "Proximo passo: bash 96_producao_v1.0.sh SENHA_DO_BANCO   (aplica as atualizacoes e liga tudo)"
    echo "Quando tudo estiver conferido, o banco guardado pode ser apagado:  psql ... -c 'DROP DATABASE $GUARDA'"
    ;;
  *) falhar "uso: bash 96_migrar_banco_v1.0.sh exportar|importar SENHA_DO_BANCO [ARQUIVO]";;
esac
