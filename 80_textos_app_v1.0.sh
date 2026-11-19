#!/usr/bin/env bash
# ============================================================
# 80_textos_app_v1.0.sh
# OBJETIVO: aplicar a revisao dos textos das telas (linguagem mais simples), a partir da tabela
#           modelos/textos_v1.0/textos.json (arquivo, texto antigo, texto novo).
#  - Texto antigo nao encontrado e texto novo ja presente: nada a fazer (ja aplicado).
#  - Texto antigo nao encontrado e novo ausente: so avisa (a tela pode ter mudado); nao interrompe.
# USO: bash 80_textos_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: todos os scripts de telas (32 a 78). Rodar depois do 78 e antes do 81.
# Pode ser rodado mais de uma vez. DESFAZER: rodar de novo a cadeia de scripts de telas sem o 80.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 80_textos_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
python3 - "$RAIZ" "$AQUI/modelos/textos_v1.0/textos.json" <<'PY'
import sys, json, os
raiz, tabela = sys.argv[1], json.load(open(sys.argv[2], encoding='utf-8'))
aplicados = ja = avisos = 0
cache = {}
for e in tabela:
    p = os.path.join(raiz, e['arquivo'])
    if not os.path.exists(p):
        print(f"aviso: arquivo nao existe: {e['arquivo']}"); avisos += 1; continue
    s = cache.setdefault(p, open(p, encoding='utf-8').read())
    if e['antigo'] in s:
        cache[p] = s.replace(e['antigo'], e['novo']); aplicados += 1
    elif e['novo'] in s:
        ja += 1
    else:
        print(f"aviso: texto nao encontrado em {e['arquivo']}: {e['antigo'][:70]}..."); avisos += 1
for p, s in cache.items():
    open(p, 'w', encoding='utf-8').write(s)
print(f"textos: {aplicados} trocados, {ja} ja estavam, {avisos} avisos")
PY
