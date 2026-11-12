#!/usr/bin/env bash
# instalar_banco_wsl_v1.0.sh — cria o banco "programa", instala o esquema e gera o executor. Rode UMA vez.
# USO (dentro da pasta do projeto, no Ubuntu/WSL):  bash instalar_banco_wsl_v1.0.sh SENHA_DO_BANCO ./programa-cut
# A SENHA vale para o usuario postgres e para os papeis api_rw, maestro_rw e metabase_ro (banco local de teste). Use letras e numeros.
set -euo pipefail
PW="${1:?informe a senha do banco}"; RAIZ="${2:-./programa-cut}"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
if [ -z "${SEM_SUDO:-}" ]; then
  sudo service postgresql start >/dev/null 2>&1 || true
  sudo -u postgres createdb programa 2>/dev/null || echo "(banco 'programa' ja existia)"
  sudo -u postgres psql -qc "ALTER USER postgres PASSWORD '$PW'"
fi
export PGPASSWORD="$PW"
U="postgresql://postgres@$HOST:$PORTA/programa"
rodar() { echo ">> $*"; psql "$U" -v ON_ERROR_STOP=1 -q "$@"; }
for f in 01_instalar_v4.4_linhas 03_setup_minimo_v4.3_linhas 04_setup_resposta_e_pesquisa_v4.3.sql 05_setup_preceptor_e_curador_v4.4.sql 12_setup_conteudo_minimo_v4.4.sql 13_setup_pesquisador_v4.4.sql 16_setup_prompts_fase_v4.4.sql 18_setup_skills_v4.4.sql 19_setup_design_tokens_v4.4.sql 20_agendador_gatilhos_v4.4.sql 22_correcao_maestro_job_e_role_v4.5.sql 23_correcao_defeitos_v4.6.sql; do
  rodar -f "$f"
done
rodar -v api_pw="$PW" -v maestro_pw="$PW" -v metabase_pw="$PW" -f 27_correcoes_seguranca_v1.0.sql
rodar -f 28_texto_integral_fontes_v1.0.sql
rodar -f 29_carga_fontes_v1.0.sql
bash 06_scaffolding_v1.0.sh "$RAIZ" >/dev/null
bash 17_scaffolding_executor_v1.0.sh "$RAIZ" >/dev/null
bash 22b_patch_executor_v1.1.sh "$RAIZ" >/dev/null
echo
echo "PRONTO. Proximo passo: defina as variaveis e rode o rodar_T001 (veja o guia, passo 5):"
echo "  export MAESTRO_DATABASE_URL=\"postgresql://maestro_rw:$PW@$HOST:$PORTA/programa\""
echo "  export DATABASE_URL=\"postgresql://postgres:$PW@$HOST:$PORTA/programa\""
