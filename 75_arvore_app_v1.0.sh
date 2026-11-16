#!/usr/bin/env bash
# ============================================================
# 75_arvore_app_v1.0.sh
# OBJETIVO: nova tela da Arvore de temas no aplicativo do aluno (/aluno/arvore), com tres vistas:
#  - Mapa: todos os temas em niveis, arrastar e zoom (dedo ou mouse), caminho do tema escolhido destacado;
#  - Foco: um tema no centro, o que ele exige (antes) e o que libera (depois), com a ordem de estudo;
#  - Linha do curso: cada aula de quinta e os temas que abrem depois dela ("abre depois da aula N").
#  Acrescenta ao estilo.css o bloco de tema do Design System CUT (variaveis --cut-*), usado pela tela nova.
# USO: bash 75_arvore_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 67 (scripts) e, no banco, 65_arvore_temas_v1.0.sql desta versao. Pode ser rodado mais de uma vez.
# DESFAZER: rodar de novo o 67_comunidade_app_v1.0.sh (volta a tela antiga da arvore).
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 75_arvore_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/arvore_v1.0"
PWA="$RAIZ/pwa/src"
[ -f "$PWA/pages/aluno/Arvore.tsx" ] || { echo "ERRO: rode antes o 67_comunidade_app_v1.0.sh"; exit 1; }
cp "$M/pwa/src/pages/aluno/Arvore.tsx" "$PWA/pages/aluno/Arvore.tsx"
for par in "tema_cut.css|tema CUT (Design System)" "estilo_arvore.css|arvore v2 (mapa"; do
  arq="${par%%|*}"; marca="${par#*|}"
  python3 - "$PWA/estilo.css" "$M/$arq" "$marca" <<'PY'
import sys
css, novo, marca = sys.argv[1], open(sys.argv[2]).read(), sys.argv[3]
s = open(css).read()
i = s.find("/* ---------- " + marca)
if i < 0:
    s = s.rstrip("\n") + "\n" + novo
else:
    j = s.find("/* ---------- ", i + 10)
    s = s[:i].rstrip("\n") + "\n" + novo.lstrip("\n").rstrip("\n") + "\n" + ("\n" + s[j:] if j >= 0 else "")
open(css, "w").write(s)
PY
done
echo "arvore v2 instalada: pages/aluno/Arvore.tsx e estilo.css (tema CUT + arvore)"
