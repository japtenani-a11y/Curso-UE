#!/usr/bin/env bash
# ============================================================
# 77_tema_cut_app_v1.0.sh
# OBJETIVO: passar todas as telas do aplicativo para as cores e a fonte do Design System CUT.
#  - estilo.css: bloco "ponte CUT" que liga as variaveis antigas (--primaria, --borda, --ok, --erro...) as --cut-*;
#  - troca as cores fixas que sobraram nas telas (azul antigo, cinzas, verde/vermelho, ambar) pelas variaveis --cut-*;
#    acerto passa a azul e erro/alerta a laranja, como no Design System; graficos com varias series mantem as cores proprias;
#  - carrega a fonte Inter e ajusta a cor da barra do navegador.
# USO: bash 77_tema_cut_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 75 (bloco "tema CUT" no estilo.css). Rodar por ultimo, depois de todos os scripts de telas.
# Pode ser rodado mais de uma vez. DESFAZER: rodar de novo a cadeia de scripts de telas (32 a 76) sem o 77.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 77_tema_cut_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/tema_cut_v1.0"
PWA="$RAIZ/pwa"
grep -q -- "--cut-surface" "$PWA/src/estilo.css" || { echo "ERRO: rode antes o 75_arvore_app_v1.0.sh (tema CUT)"; exit 1; }
python3 - "$PWA" "$M/ponte_cut.css" <<'PY'
import sys, re, os, glob
pwa, ponte = sys.argv[1], open(sys.argv[2]).read()
MAPA = {
  '#1f4e79': 'var(--cut-action)', '#1e3a5f': 'var(--cut-action)',
  '#14213d': 'var(--cut-text)', '#0e1726': 'var(--cut-text)', '#1c2430': 'var(--cut-text)', '#1f1f1f': 'var(--cut-text)', '#424242': 'var(--cut-text)',
  '#4a5568': 'var(--cut-text-muted)', '#5b6675': 'var(--cut-text-muted)', '#6b7280': 'var(--cut-text-muted)', '#5b6473': 'var(--cut-text-muted)', '#747775': 'var(--cut-text-muted)',
  '#dde2e9': 'var(--cut-line)', '#dde1e7': 'var(--cut-line)', '#c5ccd6': 'var(--cut-line)', '#cbd2dc': 'var(--cut-line)',
  '#9aa5b4': 'var(--cut-line-strong)', '#9ca3af': 'var(--cut-line-strong)', '#8aa4bf': 'var(--cut-line-strong)', '#7c8594': 'var(--cut-line-strong)',
  '#f3f5f8': 'var(--cut-surface-sunken)', '#f3f4f6': 'var(--cut-surface-sunken)', '#eef1f5': 'var(--cut-surface-sunken)', '#f4f5f7': 'var(--cut-surface-sunken)', '#f6f7f4': 'var(--cut-surface-sunken)',
  '#e3ecf6': 'var(--cut-surface-sunken)', '#eaf1f8': 'var(--cut-surface-sunken)',
  '#1d6b3a': 'var(--cut-correct)', '#1b7f3b': 'var(--cut-correct)', '#e6f4ea': 'var(--cut-correct-bg)', '#e8f1fb': 'var(--cut-correct-bg)',
  '#a32020': 'var(--cut-incorrect)', '#b3261e': 'var(--cut-incorrect)', '#b45309': 'var(--cut-incorrect)', '#fdecea': 'var(--cut-incorrect-bg)',
  '#d9a400': 'var(--cut-incorrect)', '#d6b35c': 'var(--cut-line-strong)', '#e3c56b': 'var(--cut-incorrect)', '#c8963e': 'var(--cut-line-strong)',
  '#fff3cd': 'var(--cut-incorrect-bg)', '#fff8e1': 'var(--cut-incorrect-bg)', '#fffaf0': 'var(--cut-surface-sunken)', '#fff4d6': 'var(--cut-incorrect-bg)',
  '#fff6dd': 'var(--cut-incorrect-bg)', '#fdf3e7': 'var(--cut-incorrect-bg)', '#f3dd9a': 'var(--cut-incorrect-bg)',
  '#8a6400': 'var(--cut-text)', '#5c4300': 'var(--cut-text)', '#6b5a26': 'var(--cut-text)', '#3d3214': 'var(--cut-text)', '#2a2414': 'var(--cut-text)',
}
HEX = re.compile(r'#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b(?![0-9a-fA-F])')
def trocar_hex(txt):
    return HEX.sub(lambda m: MAPA.get(m.group(0).lower(), m.group(0)), txt)
# 1) estilo.css: troca fora do bloco "tema CUT" e acrescenta/atualiza a ponte
css = os.path.join(pwa, 'src', 'estilo.css'); s = open(css).read()
blocos = re.split(r'(?=/\* ---------- )', s)
saida = []
for b in blocos:
    if b.startswith('/* ---------- tema CUT') or b.startswith('/* ---------- ponte CUT'):
        if b.startswith('/* ---------- tema CUT'): saida.append(b)
        continue
    saida.append(trocar_hex(b))
s = ''.join(saida).rstrip('\n') + '\n' + ponte
open(css, 'w').write(s)
# 2) telas (.tsx): cores fixas; graficos com varias series ficam com as cores proprias
casos = {
  'components/Comparativo.tsx': [("cor: '#b45309', tracejado: true", "cor: 'var(--cut-text-muted)', tracejado: true"),
                                 ("cor: '#6b7280', tracejado: false", "cor: 'var(--cut-line-strong)', tracejado: false")],
  'pages/painel/Painel.tsx': [("const CORES = ['#1f4e79',", "const CORES = ['var(--cut-action)',"),
                              ("cor: '#b45309', tracejado: true }]", "cor: 'var(--cut-text-muted)', tracejado: true }]")],
}
n = 0
for f in glob.glob(os.path.join(pwa, 'src', '**', '*.tsx'), recursive=True):
    t = open(f).read(); orig = t
    for a, b in casos.get(os.path.relpath(f, os.path.join(pwa, 'src')), []): t = t.replace(a, b)
    linhas = [l if ('const CORES' in l or 'fill="#EA4335"' in l or '#4285F4' in l or '#34A853' in l or '#FBBC05' in l) else trocar_hex(l) for l in t.split('\n')]
    t = '\n'.join(linhas)
    if t != orig: open(f, 'w').write(t); n += 1
# 3) index.html: fonte Inter e cor da barra do navegador
ih = os.path.join(pwa, 'index.html'); h = open(ih).read()
h = h.replace('<meta name="theme-color" content="#1f4e79" />', '<meta name="theme-color" content="#0E1726" />')
if 'family=Inter' not in h:
    h = h.replace('  </head>', '    <link rel="preconnect" href="https://fonts.googleapis.com" />\n    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" />\n  </head>', 1)
open(ih, 'w').write(h)
print(f"tema CUT aplicado: estilo.css (ponte), {n} telas com cores fixas trocadas, index.html (Inter)")
PY
