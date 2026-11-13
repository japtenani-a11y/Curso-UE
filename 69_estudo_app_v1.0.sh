#!/usr/bin/env bash
# ============================================================
# 69_estudo_app_v1.0.sh
# OBJETIVO: area de Estudo dirigido no aplicativo e na API (/estudo).
#  - Simulado sob medida: temas ja feitos, faixa de dificuldade e numero de questoes; sorteio aleatorio; gabarito
#    com justificativas na entrega. Nao conta para nota nem ranking.
#  - Flashcards: deck com cards do curso, meus e de colegas; "eu sabia / preciso rever" fica registrado.
#  - Criar flashcard: com a caixa de compartilhar marcada, o card vai direto (sem revisor) para todos do tema,
#    marcado como "feito por aluno" com o nome ou o apelido escolhido.
#  - Coordenacao: /curador/flashcards para acompanhar e, se preciso, ocultar.
# USO: bash 69_estudo_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 67 (script) e, no banco, 68_estudo_dirigido_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 69_estudo_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/estudo_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/comunidade.ts" ] || { echo "ERRO: rode antes o 67_comunidade_app_v1.0.sh"; exit 1; }
cp "$M/api/src/routes/estudo.ts" "$API/routes/"
cp "$M/pwa/src/pages/aluno/Estudo.tsx" "$PWA/pages/aluno/"
cp "$M/pwa/src/pages/curador/Flashcards.tsx" "$PWA/pages/curador/"
grep -q "estudo dirigido (simulados e flashcards)" "$PWA/estilo.css" || cat "$M/estilo_estudo.css" >> "$PWA/estilo.css"
echo "copiados: routes/estudo.ts, Estudo (aluno), Flashcards (curador)"

python3 - "$API" "$PWA" <<'PY'
import sys
api, pwa = sys.argv[1:3]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:70]}")
    open(p, "w").write(s.replace(a, b, 1))
m = f"{api}/main.ts"
trocar(m, "import { comunidadeRouter } from './routes/comunidade.js';",
       "import { comunidadeRouter } from './routes/comunidade.js';\nimport { estudoRouter } from './routes/estudo.js';", "estudoRouter }")
trocar(m, "app.use('/com', limite('com', 240, 60_000), exigirCadastro, comunidadeRouter);",
       "app.use('/com', limite('com', 240, 60_000), exigirCadastro, comunidadeRouter);\napp.use('/estudo', limite('estudo', 300, 60_000), exigirCadastro, estudoRouter);", "app.use('/estudo'")
a = f"{pwa}/App.tsx"
trocar(a, "import { CuradorMural } from './pages/curador/Mural.js';",
       "import { CuradorMural } from './pages/curador/Mural.js';\nimport { Estudo } from './pages/aluno/Estudo.js';\nimport { CuradorFlashcards } from './pages/curador/Flashcards.js';", "pages/aluno/Estudo.js")
trocar(a, '<Route path="/aluno/mural"',
       '<Route path="/aluno/estudo" element={<Layout proteger={false}><Estudo /></Layout>} />\n'
       '        <Route path="/curador/flashcards" element={<Layout papeis={REVISORES} proteger={false}><CuradorFlashcards /></Layout>} />\n'
       '        <Route path="/aluno/mural"', 'path="/aluno/estudo"')
l = f"{pwa}/components/Layout.tsx"
trocar(l, "    { href: '/aluno/arvore', rotulo: 'Árvore', icone: '⋔' },",
       "    { href: '/aluno/estudo', rotulo: 'Estudo dirigido', icone: '✦' },\n    { href: '/aluno/arvore', rotulo: 'Árvore', icone: '⋔' },", "'/aluno/estudo'")
trocar(l, "      { href: '/curador/mural', rotulo: 'Mural', icone: '✉' },",
       "      { href: '/curador/mural', rotulo: 'Mural', icone: '✉' },\n      { href: '/curador/flashcards', rotulo: 'Flashcards dos alunos', icone: '✦' },", "'/curador/flashcards'")
h = f"{pwa}/pages/aluno/Home.tsx"
trocar(h, '        <a className="cartao-app entrada" href="/aluno/arvore">',
       '        <a className="cartao-app entrada" href="/aluno/estudo"><span className="rotulo">Estudo dirigido</span><strong>Simulados e flashcards</strong><span>Monte seu treino com o que já estudou.</span></a>\n        <a className="cartao-app entrada" href="/aluno/arvore">', 'href="/aluno/estudo"')
PY
echo "atualizados: main.ts (/estudo), App (rotas), Layout (menu), Inicio do aluno (entrada)"
echo "=== estudo dirigido instalado ==="
