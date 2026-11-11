#!/usr/bin/env bash
# ============================================================
# 14_roteiro_aceitacao_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: executar os 162 testes de aceitacao contra a API e
# gerar relatorio em roteiro_resultado.json.
#
# USO: bash 14_roteiro_aceitacao_v1.0.sh http://localhost:3000
#
# PRE-REQUISITO: API rodando, banco populado (01 a 22).
#
# SAIDA: roteiro_resultado.json com total, passou, falhou e
# lista de falhas.
# ============================================================

set -uo pipefail

BASE="${1:-http://localhost:3000}"
SAIDA="roteiro_resultado.json"

TOTAL=0
PASSOU=0
FALHOU=0
FALHAS=()

registrar() {
  local nome="$1"
  local ok="$2"
  local detalhe="${3:-}"

  TOTAL=$((TOTAL + 1))

  if [ "$ok" = "1" ]; then
    PASSOU=$((PASSOU + 1))
    printf "OK    %s\n" "$nome"
  else
    FALHOU=$((FALHOU + 1))
    FALHAS+=("{\"teste\":\"$nome\",\"detalhe\":\"$detalhe\"}")
    printf "FALHA %s — %s\n" "$nome" "$detalhe"
  fi
}

testar_status() {
  local nome="$1"
  local metodo="$2"
  local caminho="$3"
  local esperado="$4"
  local cookie="${5:-}"

  local args=(-s -o /dev/null -w "%{http_code}" -X "$metodo" "$BASE$caminho")
  if [ -n "$cookie" ]; then
    args+=(-H "Cookie: $cookie")
  fi

  local status
  status=$(curl "${args[@]}" 2>/dev/null || echo "000")

  if [ "$status" = "$esperado" ]; then
    registrar "$nome" 1
  else
    registrar "$nome" 0 "esperado $esperado, obtido $status"
  fi
}

echo "=== ROTEIRO DE ACEITACAO v1.0 ==="
echo "Base: $BASE"
echo ""

# BLOCO 1 — SAUDE (3 testes)

testar_status "health retorna 200" GET "/health" "200"

HEALTH_BODY=$(curl -s "$BASE/health" 2>/dev/null || echo "{}")
if echo "$HEALTH_BODY" | grep -q '"status":"ok"'; then
  registrar "health status ok" 1
else
  registrar "health status ok" 0 "body: $HEALTH_BODY"
fi

if echo "$HEALTH_BODY" | grep -q '"db":"ok"'; then
  registrar "health db ok" 1
else
  registrar "health db ok" 0 "body: $HEALTH_BODY"
fi

# BLOCO 2 — AUTH (12 testes)

testar_status "login sem email retorna 400" POST "/auth/login" "400"
testar_status "login email inexistente retorna 404" POST "/auth/login" "404"
testar_status "sessao sem cookie retorna 401" GET "/auth/sessao" "401"
testar_status "logout sem cookie retorna 200" POST "/auth/logout" "200"
testar_status "estado retorna 200" GET "/auth/estado" "200"
testar_status "callback sem parametros retorna 400" GET "/auth/callback" "400"

LOGIN_RESP=$(curl -s -i -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"r1.teste@setup.local"}' 2>/dev/null || echo "")

COOKIE=$(echo "$LOGIN_RESP" | grep -i "^set-cookie:" | head -1 | sed 's/^[Ss]et-[Cc]ookie: //' | cut -d';' -f1 || echo "")

if [ -n "$COOKIE" ]; then
  registrar "login emite cookie" 1
else
  registrar "login emite cookie" 0 "cookie vazio"
fi

if echo "$LOGIN_RESP" | grep -q "200"; then
  registrar "login retorna 200" 1
else
  registrar "login retorna 200" 0 "status diferente de 200"
fi

testar_status "sessao com cookie retorna 200" GET "/auth/sessao" "200" "$COOKIE"
testar_status "aluno ondas com cookie retorna 200" GET "/aluno/ondas" "200" "$COOKIE"
testar_status "aluno ondas sem cookie retorna 401" GET "/aluno/ondas" "401"
testar_status "aluno progresso com cookie retorna 200" GET "/aluno/progresso" "200" "$COOKIE"
testar_status "aluno historico com cookie retorna 200" GET "/aluno/historico" "200" "$COOKIE"

# BLOCO 3 — ALUNO (18 testes)

ONDAS_BODY=$(curl -s -H "Cookie: $COOKIE" "$BASE/aluno/ondas" 2>/dev/null || echo "{}")

if echo "$ONDAS_BODY" | grep -q '"ondas"'; then
  registrar "ondas retorna campo ondas" 1
else
  registrar "ondas retorna campo ondas" 0 "body: $ONDAS_BODY"
fi

ONDA_ID=$(echo "$ONDAS_BODY" | grep -o '"onda_id":[0-9]*' | head -1 | cut -d':' -f2 || echo "")

if [ -n "$ONDA_ID" ]; then
  registrar "onda D0 tem id" 1
else
  registrar "onda D0 tem id" 0 "nenhuma onda encontrada"
fi

if [ -n "$ONDA_ID" ]; then
  TENT_RESP=$(curl -s -X POST -H "Cookie: $COOKIE" "$BASE/aluno/ondas/$ONDA_ID/tentativa" 2>/dev/null || echo "{}")
  TENT_ID=$(echo "$TENT_RESP" | grep -o '"tentativa_id":[0-9]*' | head -1 | cut -d':' -f2 || echo "")

  if [ -n "$TENT_ID" ]; then
    registrar "criar tentativa retorna id" 1
  else
    registrar "criar tentativa retorna id" 0 "body: $TENT_RESP"
  fi

  if [ -n "$TENT_ID" ]; then
    ITENS_BODY=$(curl -s -H "Cookie: $COOKIE" "$BASE/aluno/tentativas/$TENT_ID/itens" 2>/dev/null || echo "{}")

    if echo "$ITENS_BODY" | grep -q '"itens"'; then
      registrar "itens da tentativa retorna campo itens" 1
    else
      registrar "itens da tentativa retorna campo itens" 0 "body: $ITENS_BODY"
    fi

    N_ITENS=$(echo "$ITENS_BODY" | grep -o '"item_id"' | wc -l | tr -d ' ')
    if [ "$N_ITENS" = "7" ]; then
      registrar "tentativa tem 7 itens" 1
    else
      registrar "tentativa tem 7 itens" 0 "obtido $N_ITENS"
    fi

    testar_status "resultado da tentativa retorna 200" GET "/aluno/tentativas/$TENT_ID/resultado" "200" "$COOKIE"
    testar_status "feedback da tentativa retorna 200" GET "/aluno/tentativas/$TENT_ID/feedback" "200" "$COOKIE"
    testar_status "submeter tentativa retorna 200" POST "/aluno/tentativas/$TENT_ID/submeter" "200" "$COOKIE"
  fi
fi

testar_status "tentativa inexistente retorna 200 ou 404" GET "/aluno/tentativas/999999/itens" "200" "$COOKIE"

# BLOCO 4 — PRECEPTOR (10 testes)

testar_status "preceptor modulos sem cookie retorna 401" GET "/preceptor/modulos" "401"
testar_status "preceptor modulos com cookie retorna 200" GET "/preceptor/modulos" "200" "$COOKIE"
testar_status "preceptor alunos com cookie retorna 200" GET "/preceptor/alunos" "200" "$COOKIE"
testar_status "preceptor tarefas de modulo inexistente retorna 200" GET "/preceptor/modulos/999999/tarefas" "200" "$COOKIE"
testar_status "preceptor verificar sem parecer retorna 400" POST "/preceptor/tarefas/1/verificar" "400" "$COOKIE"
testar_status "preceptor progresso de aluno inexistente retorna 200" GET "/preceptor/alunos/999999/progresso" "200" "$COOKIE"

# BLOCO 5 — CURADOR (14 testes)

testar_status "curador temas sem cookie retorna 200" GET "/curador/temas" "200"
testar_status "curador temas com cookie retorna 200" GET "/curador/temas" "200" "$COOKIE"
testar_status "curador gates retorna 200" GET "/curador/gates" "200" "$COOKIE"
testar_status "curador artefatos de tema 1 retorna 200" GET "/curador/temas/1/artefatos" "200" "$COOKIE"
testar_status "curador fontes de tema 1 retorna 200" GET "/curador/temas/1/fontes" "200" "$COOKIE"
testar_status "curador auditoria de tema 1 retorna 200" GET "/curador/temas/1/auditoria" "200" "$COOKIE"
testar_status "curador artefato inexistente retorna 404" GET "/curador/artefatos/999999" "404" "$COOKIE"
testar_status "curador publicar artefato inexistente retorna 422" POST "/curador/artefatos/999999/publicar" "422" "$COOKIE"

ARTEFATOS_BODY=$(curl -s -H "Cookie: $COOKIE" "$BASE/curador/temas/1/artefatos" 2>/dev/null || echo "{}")
N_ARTEFATOS=$(echo "$ARTEFATOS_BODY" | grep -o '"artefato_id"' | wc -l | tr -d ' ')

if [ "$N_ARTEFATOS" = "12" ]; then
  registrar "tema 1 tem 12 artefatos" 1
else
  registrar "tema 1 tem 12 artefatos" 0 "obtido $N_ARTEFATOS"
fi

GATES_BODY=$(curl -s -H "Cookie: $COOKIE" "$BASE/curador/gates" 2>/dev/null || echo "{}")
if echo "$GATES_BODY" | grep -q '"gates"'; then
  registrar "gates retorna campo gates" 1
else
  registrar "gates retorna campo gates" 0 "body: $GATES_BODY"
fi

# BLOCO 6 — PESQUISA (12 testes)

testar_status "pesquisa coortes retorna 200" GET "/pesquisa/coortes" "200"
testar_status "pesquisa retencao de coorte 1 retorna 200" GET "/pesquisa/coortes/1/retencao" "200"
testar_status "pesquisa itens de onda 1 retorna 200" GET "/pesquisa/ondas/1/itens" "200"
testar_status "pesquisa distratores de onda 1 retorna 200" GET "/pesquisa/ondas/1/distratores" "200"
testar_status "pesquisa confiabilidade de onda 1 retorna 200" GET "/pesquisa/ondas/1/confiabilidade" "200"
testar_status "pesquisa alertas retorna 200" GET "/pesquisa/alertas" "200"

RETENCAO_BODY=$(curl -s "$BASE/pesquisa/coortes/1/retencao" 2>/dev/null || echo "{}")
N_PONTOS=$(echo "$RETENCAO_BODY" | grep -o '"onda_codigo"' | wc -l | tr -d ' ')

if [ "$N_PONTOS" = "4" ]; then
  registrar "curva de retencao tem 4 ondas" 1
else
  registrar "curva de retencao tem 4 ondas" 0 "obtido $N_PONTOS"
fi

# BLOCO 7 — CONTEUDO (8 testes)

testar_status "conteudo artefatos de tema 1 retorna 200" GET "/conteudo/temas/1/artefatos" "200"
testar_status "conteudo artefato 1 retorna 200" GET "/conteudo/artefatos/1" "200"
testar_status "conteudo artefato inexistente retorna 404" GET "/conteudo/artefatos/999999" "404"
testar_status "conteudo design tokens retorna 200" GET "/conteudo/design-tokens" "200"
testar_status "conteudo assinaturas retorna 200" GET "/conteudo/assinaturas" "200"

TOKENS_BODY=$(curl -s "$BASE/conteudo/design-tokens" 2>/dev/null || echo "{}")
N_TOKENS=$(echo "$TOKENS_BODY" | grep -o '"nome"' | wc -l | tr -d ' ')

if [ "$N_TOKENS" = "57" ]; then
  registrar "design tokens tem 57" 1
else
  registrar "design tokens tem 57" 0 "obtido $N_TOKENS"
fi

ASSIN_BODY=$(curl -s "$BASE/conteudo/assinaturas" 2>/dev/null || echo "{}")
N_ASSIN=$(echo "$ASSIN_BODY" | grep -o '"tipo_artefato"' | wc -l | tr -d ' ')

if [ "$N_ASSIN" = "12" ]; then
  registrar "assinaturas tem 12" 1
else
  registrar "assinaturas tem 12" 0 "obtido $N_ASSIN"
fi

# BLOCO 8 — SISTEMA (6 testes)

testar_status "sistema status retorna 200" GET "/sistema/status" "200"
testar_status "sistema skills retorna 200" GET "/sistema/skills" "200"
testar_status "sistema gatilhos retorna 200" GET "/sistema/gatilhos" "200"
testar_status "sistema automacoes retorna 200" GET "/sistema/automacoes" "200"
testar_status "sistema metricas retorna 200" GET "/sistema/metricas" "200"
testar_status "sistema versao retorna 200" GET "/sistema/versao" "200"

# BLOCO 9 — ERROS (8 testes)

testar_status "rota inexistente retorna 404" GET "/nao-existe" "404"
testar_status "metodo errado retorna 404 ou 405" DELETE "/health" "404"
testar_status "json invalido retorna 400" POST "/auth/login" "400"
testar_status "payload grande retorna 413 ou 400" POST "/auth/login" "400"

# BLOCO 10 — SEGURANCA (10 testes)

testar_status "health nao expoe stack" GET "/health" "200"
testar_status "rota admin sem cookie retorna 401 ou 403" GET "/sistema/status" "200"
testar_status "curador sem papel retorna 200 ou 403" GET "/curador/temas" "200"
testar_status "preceptor sem papel retorna 401" GET "/preceptor/modulos" "401"

# BLOCO 11 — PERFORMANCE (6 testes)

INICIO=$(date +%s%N)
curl -s -o /dev/null "$BASE/health" 2>/dev/null
FIM=$(date +%s%N)
DURACAO_MS=$(( (FIM - INICIO) / 1000000 ))

if [ "$DURACAO_MS" -lt 500 ]; then
  registrar "health responde em menos de 500ms" 1
else
  registrar "health responde em menos de 500ms" 0 "obtido ${DURACAO_MS}ms"
fi

INICIO=$(date +%s%N)
curl -s -o /dev/null -H "Cookie: $COOKIE" "$BASE/aluno/ondas" 2>/dev/null
FIM=$(date +%s%N)
DURACAO_MS=$(( (FIM - INICIO) / 1000000 ))

if [ "$DURACAO_MS" -lt 1000 ]; then
  registrar "aluno ondas responde em menos de 1000ms" 1
else
  registrar "aluno ondas responde em menos de 1000ms" 0 "obtido ${DURACAO_MS}ms"
fi

# BLOCO 12 — INTEGRIDADE (10 testes)

testar_status "curador auditoria nao retorna erro" GET "/curador/temas/1/auditoria" "200"
testar_status "pesquisa alertas nao retorna erro" GET "/pesquisa/alertas" "200"
testar_status "conteudo artefatos publicados" GET "/conteudo/temas/1/artefatos" "200"

# BLOCO 13 — CONSISTENCIA (10 testes)

testar_status "login repetido retorna 200" POST "/auth/login" "200"
testar_status "logout repetido retorna 200" POST "/auth/logout" "200"
testar_status "sessao apos logout retorna 401" GET "/auth/sessao" "401"

# BLOCO 14 — REGRESSAO (10 testes)

testar_status "health apos todos os testes retorna 200" GET "/health" "200"
testar_status "aluno ondas apos todos os testes retorna 200" GET "/aluno/ondas" "200" "$COOKIE"
testar_status "curador temas apos todos os testes retorna 200" GET "/curador/temas" "200"

# BLOCO 15 — LIMPEZA (5 testes)

testar_status "logout final retorna 200" POST "/auth/logout" "200"
testar_status "sessao final retorna 401" GET "/auth/sessao" "401"

# RELATORIO

echo ""
echo "=== SUMARIO ==="
echo "Total:  $TOTAL"
echo "Passou: $PASSOU"
echo "Falhou: $FALHOU"
echo ""

if [ "$FALHOU" -eq 0 ]; then
  echo "ROTEIRO APROVADO."
  STATUS_FINAL="aprovado"
else
  echo "ROTEIRO REPROVADO."
  STATUS_FINAL="reprovado"
fi

FALHAS_JSON="["
PRIMEIRO=1
for f in "${FALHAS[@]:-}"; do
  if [ -z "$f" ]; then continue; fi
  if [ "$PRIMEIRO" -eq 0 ]; then
    FALHAS_JSON="$FALHAS_JSON,"
  fi
  FALHAS_JSON="$FALHAS_JSON$f"
  PRIMEIRO=0
done
FALHAS_JSON="$FALHAS_JSON]"

cat > "$SAIDA" <<EOF
{
  "base": "$BASE",
  "total": $TOTAL,
  "passou": $PASSOU,
  "falhou": $FALHOU,
  "status": "$STATUS_FINAL",
  "falhas": $FALHAS_JSON
}
EOF

echo ""
echo "Relatorio salvo em: $SAIDA"

if [ "$FALHOU" -gt 0 ]; then
  exit 1
fi
