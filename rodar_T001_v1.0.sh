#!/usr/bin/env bash
# ============================================================
# rodar_T001_v1.0.sh — gera os 12 artefatos do T001 com o executor e resume o resultado.
# USO:
#   export ANTHROPIC_API_KEY=...            (chave NOVA; nunca em arquivo)
#   export ANTHROPIC_MODEL=claude-sonnet-5-5
#   export NCBI_API_KEY=...                 (opcional)
#   export MAESTRO_DATABASE_URL=postgres://...   (o do executor)
#   export DATABASE_URL=$MAESTRO_DATABASE_URL    (usado na carga e no SQL; use o papel com permissao de escrita)
#   bash rodar_T001_v1.0.sh ./programa-cut <pasta_que_contem_T001/> [minutos_max]
# PRE-REQUISITOS: 06, 17 e 22b ja aplicados em <RAIZ>; 28_texto_integral_fontes e 29_carga_fontes_v1.0.sql aplicados no banco;
#   fontes/catalogo_T001.csv deste repositorio; zip T001_fontes.zip descompactado.
# ============================================================
set -euo pipefail
RAIZ="${1:?pasta do projeto (ex.: ./programa-cut)}"; PASTA="${2:?pasta que contem a pasta T001/}"; MAXMIN="${3:-45}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
for v in ANTHROPIC_API_KEY ANTHROPIC_MODEL MAESTRO_DATABASE_URL DATABASE_URL; do [ -n "${!v:-}" ] || { echo "ERRO: defina $v"; exit 1; }; done
for c in psql node npm pdftotext python3; do command -v $c >/dev/null || { echo "ERRO: $c ausente"; exit 1; }; done
[ -d "$PASTA/T001" ] || { echo "ERRO: $PASTA/T001 nao existe (descompacte T001_fontes.zip em $PASTA)"; exit 1; }
[ -d "$RAIZ/executor/src/maestro" ] || { echo "ERRO: rode 06, 17 e 22b antes (executor ausente em $RAIZ)"; exit 1; }

echo "== 1/6 gerar executor (modelo + verificadores + selecao de fontes)"
bash "$AQUI/28_executor_modelo_verificadores_v1.0.sh" "$RAIZ" >/dev/null
echo "== 2/6 compilar e testar"
(
  cd "$RAIZ/executor"
  npm install --no-audit --no-fund >/dev/null 2>&1
  npx tsc
  LOGT="$(mktemp)"
  if node --test dist/test/*.test.js >"$LOGT" 2>&1; then
    echo "   testes do executor: OK ($(ls dist/test/*.test.js | wc -l) arquivos)"
  else
    echo "ERRO nos testes do executor:"; tail -40 "$LOGT"; exit 1
  fi
)
echo "== 3/6 carregar as 75 fontes do T001 (confira carga_fontes_pendentes.txt)"
( cd "$AQUI" && bash 29_carga_fontes_v1.0.sh fontes/catalogo_T001.csv "$PASTA" --aplicar 2>&1 | tail -5 )
echo "== 4/6 enfileirar os 12 jobs"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -q -f "$AQUI/30_enfileirar_T001_v1.0.sql"
echo "== 5/6 executar (maximo ${MAXMIN} min; Ctrl+C interrompe, os jobs pendentes ficam na fila)"
LOG="$(mktemp)"; ( cd "$RAIZ/executor" && node dist/main.js >"$LOG" 2>&1 ) & PID=$!
trap 'kill $PID 2>/dev/null || true' EXIT
FIM=$(( $(date +%s) + MAXMIN*60 ))
Q="SELECT count(*) FROM maestro.job j JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' AND j.estado IN ('pendente','executando')"
while [ "$(date +%s)" -lt "$FIM" ]; do
  N=$(psql "$DATABASE_URL" -Atc "$Q"); [ "$N" = "0" ] && break
  echo "   jobs restantes: $N"; sleep 20
done
kill $PID 2>/dev/null || true
echo "== 6/6 resumo"
psql "$DATABASE_URL" -c "SELECT j.payload->>'tipo' AS artefato, j.estado, j.tentativas FROM maestro.job j JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' ORDER BY j.prioridade, j.job_id"
psql "$DATABASE_URL" -c "SELECT skill_codigo, modelo, count(*) execucoes, sum(tokens_entrada) tok_in, sum(tokens_saida) tok_out FROM maestro.execucao_motor m JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' GROUP BY 1,2 ORDER BY 1"
psql "$DATABASE_URL" -c "SELECT tipo, versao, status, length(corpo) chars FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' ORDER BY tipo, versao"
echo "Log do executor (erros e reprovacoes do gate): $LOG"; grep -E "reprovou|erro|verificacao indisponivel|gate de evidencia" "$LOG" | tail -20 || true
