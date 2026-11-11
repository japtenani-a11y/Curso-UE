#!/usr/bin/env bash
# ============================================================
# 23b_patch_arquivos_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: corrigir dois defeitos que exigem alteracao de
# arquivo, nao de banco:
#   D1: 02_verificar bloco A4 compara com 44 tabelas, mas o
#       banco tem 48. Ajuste para 48.
#   D2: 02_verificar bloco J usa pessoa_id 1, que pode nao
#       existir. Ajuste para buscar por e-mail.
#
# USO: bash 23b_patch_arquivos_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 02_verificar_v4.4, 17_scaffolding_executor_v1.0,
#                18_setup_skills_v4.4.
#
# IDEMPOTENTE: verifica se o patch ja foi aplicado antes de
# aplicar de novo.
# ============================================================

set -euo pipefail

RAIZ="${1:-./programa-cut}"

echo "=== PATCH ARQUIVOS v1.0 ==="

ARQ_VERIFICAR="$RAIZ/sql/02_verificar_v4.4.sql"

if [ ! -f "$ARQ_VERIFICAR" ]; then
  echo "ERRO: $ARQ_VERIFICAR nao existe. Rode a conversao dos CSVs primeiro."
  exit 1
fi

# D1: AJUSTAR A4 DE 44 PARA 48

if grep -q "esperado 44" "$ARQ_VERIFICAR"; then
  cp "$ARQ_VERIFICAR" "$ARQ_VERIFICAR.bak"
  sed -i 's/esperado 44/esperado 48/g' "$ARQ_VERIFICAR"
  echo "D1: A4 ajustado de 44 para 48"
else
  echo "D1: A4 ja ajustado ou valor diferente de 44"
fi

# D2: AJUSTAR BLOCO J PARA BUSCAR POR E-MAIL

if grep -q "pessoa_id = 1" "$ARQ_VERIFICAR"; then
  sed -i "s/pessoa_id = 1/pessoa_id = (SELECT pessoa_id FROM app.pessoa WHERE email_primario = 'r1.teste@setup.local')/g" "$ARQ_VERIFICAR"
  echo "D2: bloco J ajustado para buscar por e-mail"
else
  echo "D2: bloco J ja ajustado ou padrao diferente"
fi

# VERIFICAR SE O 17 TEM O PATCH DO 22b

ARQ_CICLO="$RAIZ/executor/src/maestro/ciclo.ts"

if [ -f "$ARQ_CICLO" ]; then
  if grep -q "skill_codigo" "$ARQ_CICLO"; then
    echo "17: ciclo.ts ja consome skill_codigo"
  else
    echo "AVISO: ciclo.ts nao consome skill_codigo. Rode 22b_patch_executor."
  fi
else
  echo "AVISO: $ARQ_CICLO nao existe. Rode 17_scaffolding_executor."
fi

# VERIFICAR SE O 18 TEM O CHECK DE FAMILIA

ARQ_SKILLS="$RAIZ/sql/18_setup_skills_v4.4.sql"

if [ -f "$ARQ_SKILLS" ]; then
  if grep -q "CHECK (familia IN" "$ARQ_SKILLS"; then
    echo "18: CHECK de familia presente"
  else
    echo "AVISO: 18 sem CHECK de familia. Rode 23_correcao_defeitos."
  fi
else
  echo "AVISO: $ARQ_SKILLS nao existe."
fi

# CONFERENCIA

echo "--- Conferencia ---"

echo -n "D1: A4 com 48: "
if grep -q "esperado 48" "$ARQ_VERIFICAR"; then echo "SIM"; else echo "NAO"; fi

echo -n "D2: bloco J por e-mail: "
if grep -q "r1.teste@setup.local" "$ARQ_VERIFICAR"; then echo "SIM"; else echo "NAO"; fi

echo -n "backup criado: "
if [ -f "$ARQ_VERIFICAR.bak" ]; then echo "SIM"; else echo "NAO (patch ja aplicado antes)"; fi

echo "=== PATCH ARQUIVOS CONCLUIDO ==="
