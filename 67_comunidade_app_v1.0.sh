#!/usr/bin/env bash
# ============================================================
# 67_comunidade_app_v1.0.sh
# OBJETIVO: telas e rotas da v2l:
#  - Inicio do aluno (proxima aula com Meet e contagem, resgate de presenca, pendencias, mural, calendario
#    principais/opcionais, entradas); inicio da coordenacao; tela do preceptor (residentes vinculados).
#  - Arvore de temas mae/filho; mural (avisos, questionarios, documentos); presenca (codigo/link e relatorio do Meet);
#    presenca e certificado do aluno; certificado publico com verificacao; ajuda (inclui instalar no celular).
#  - Casca nova: barra inferior no celular, "Mais", tamanho da letra, pular para o conteudo, primeiro acesso guiado.
#  - API: /com (mural, presenca, certificado, agenda, coordenacao, preceptor, regras) e /publico (certificado, agenda .ics).
# USO: bash 67_comunidade_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 63 (script) e, no banco, 65 e 66. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 67_comunidade_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/comunidade_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/cadastro.ts" ] || { echo "ERRO: rode antes o 63_cadastro_app_v1.0.sh"; exit 1; }

cp "$M/api/src/routes/comunidade.ts" "$M/api/src/routes/publico_extra.ts" "$API/routes/"
mkdir -p "$PWA/pages/aluno" "$PWA/pages/curador" "$PWA/pages/preceptor" "$PWA/lib"
cp "$M/pwa/src/components/"*.tsx "$PWA/components/"
cp "$M/pwa/src/lib/meetCsv.ts" "$PWA/lib/"
cp "$M/pwa/src/pages/aluno/"*.tsx "$PWA/pages/aluno/"
cp "$M/pwa/src/pages/curador/"*.tsx "$PWA/pages/curador/"
cp "$M/pwa/src/pages/preceptor/Home.tsx" "$PWA/pages/preceptor/Home.tsx"
cp "$M/pwa/src/pages/Ajuda.tsx" "$M/pwa/src/pages/Certificado.tsx" "$PWA/pages/"
python3 - "$PWA/estilo.css" "$M/estilo_comunidade.css" "comunidade (inicios, mural" <<'PY'
# troca o bloco de estilo desta parte pela versao nova (em vez de so acrescentar uma vez)
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
echo "copiados: rotas /com e /publico extra, Layout, PrimeiroAcesso, Instalar, ResgatarPresenca, inicios, mural, presenca, arvore, ajuda, certificado"

python3 - "$API" "$PWA" <<'PY'
import sys
api, pwa = sys.argv[1:3]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:70]}")
    open(p, "w").write(s.replace(a, b, 1))

m = f"{api}/main.ts"
trocar(m, "import { publicoRouter } from './routes/publico.js';",
       "import { publicoRouter } from './routes/publico.js';\nimport { comunidadeRouter } from './routes/comunidade.js';\nimport { publicoExtraRouter } from './routes/publico_extra.js';", "comunidadeRouter }")
trocar(m, "app.use('/publico', limite('publico', 120, 60_000), publicoRouter);",
       "app.use('/publico', limite('publico', 120, 60_000), publicoRouter);\napp.use('/publico', limite('publico2', 120, 60_000), publicoExtraRouter);\napp.use('/com', limite('com', 240, 60_000), exigirCadastro, comunidadeRouter);", "app.use('/com'")

a = f"{pwa}/App.tsx"
trocar(a, "import { PaginaInicial, PaginaTermo } from './pages/Publico.js';",
       "import { PaginaInicial, PaginaTermo } from './pages/Publico.js';\nimport { Ajuda } from './pages/Ajuda.js';\nimport { Certificado } from './pages/Certificado.js';\n"
       "import { Mural } from './pages/aluno/Mural.js';\nimport { Arvore } from './pages/aluno/Arvore.js';\nimport { Aproveitamento, PresencaPorLink } from './pages/aluno/Aproveitamento.js';\n"
       "import { CuradorMural } from './pages/curador/Mural.js';\nimport { CuradorPresenca } from './pages/curador/Presenca.js';", "pages/Ajuda.js")
trocar(a, '<Route path="/sobre"',
       '<Route path="/ajuda" element={<Layout proteger={false} semGuarda><Ajuda /></Layout>} />\n'
       '        <Route path="/certificado/*" element={<Certificado />} />\n'
       '        <Route path="/presenca/*" element={<Layout proteger={false}><PresencaPorLink /></Layout>} />\n'
       '        <Route path="/aluno/mural" element={<Layout proteger={false}><Mural /></Layout>} />\n'
       '        <Route path="/aluno/arvore" element={<Layout proteger={false}><Arvore /></Layout>} />\n'
       '        <Route path="/aluno/aproveitamento" element={<Layout proteger={false}><Aproveitamento /></Layout>} />\n'
       '        <Route path="/curador/mural" element={<Layout papeis={REVISORES} proteger={false}><CuradorMural /></Layout>} />\n'
       '        <Route path="/curador/presenca/*" element={<Layout papeis={REVISORES} proteger={false}><CuradorPresenca /></Layout>} />\n'
       '        <Route path="/curador/presenca" element={<Layout papeis={REVISORES} proteger={false}><CuradorPresenca /></Layout>} />\n'
       '        <Route path="/sobre"', 'path="/ajuda"')
# tela do preceptor: casca padrao (sem protecao de conteudo)
s = open(a).read()
if '<Route path="/preceptor/*" element={<Layout proteger={false}><PreceptorHome /></Layout>} />' not in s:
    s = s.replace('<Route path="/preceptor/*" element={<PreceptorHome />} />', '<Route path="/preceptor/*" element={<Layout proteger={false}><PreceptorHome /></Layout>} />')
    open(a, "w").write(s)
PY
echo "atualizados: main.ts (/com, /publico), App (rotas novas)"
echo "=== comunidade instalada ==="
