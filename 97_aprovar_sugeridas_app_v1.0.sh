#!/usr/bin/env bash
# ============================================================
# 97_aprovar_sugeridas_app_v1.0.sh
# OBJETIVO: "Para revisar" passa do Painel para o menu "Revisão" (ao lado dos rascunhos do tema) e ganha o botão
# "Aprovar o que os agentes sugerem aprovar" (regra no SQL 97). O subir roda sozinho, depois do 88.
# USO: bash 97_aprovar_sugeridas_app_v1.0.sh ./programa-cut
# Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 97_aprovar_sugeridas_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
cp "$AQUI/modelos/aprovar_sugeridas_v1.0/pwa/src/pages/curador/RevisaoCoordenacao.tsx" "$RAIZ/pwa/src/pages/curador/"
cp "$AQUI/modelos/interativo_v1.0/pwa/src/components/leitura/ParaRevisar.tsx" "$RAIZ/pwa/src/components/leitura/"
cp "$AQUI/modelos/interativo_v1.0/api/src/routes/coordenacao.ts" "$RAIZ/api/src/routes/"
python3 - "$RAIZ" <<'PY'
import sys, os
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
# Painel: sai a aba "Para revisar"
p = os.path.join(raiz, 'pwa/src/pages/painel/Painel.tsx'); s = ler(p)
s = s.replace("{ id: 'revisar', rotulo: 'Para revisar' }, ", "")
gravar(p, s)
# Menu "Revisao": a tela nova (propostas + rascunhos)
p = os.path.join(raiz, 'pwa/src/App.tsx'); s = ler(p)
if 'RevisaoCoordenacao' not in s:
    a = "import { CuradorRevisao } from './pages/curador/Revisao.js';"
    b = '<Layout papeis={REVISORES}><CuradorRevisao /></Layout>'
    if a not in s or b not in s: sys.exit('ERRO: nao encontrei a rota da Revisao em App.tsx')
    s = s.replace(a, a + "\nimport { RevisaoCoordenacao } from './pages/curador/RevisaoCoordenacao.js';", 1)
    s = s.replace(b, '<Layout papeis={REVISORES}><RevisaoCoordenacao /></Layout>', 1)
gravar(p, s)
print('Para revisar no menu Revisao, com aprovacao em lote (97): pronto')
PY
