#!/usr/bin/env bash
# ============================================================
# 74_extras_app_v1.0.sh
# OBJETIVO: no aplicativo e na API (/extra):
#  - "Tenho interesse em pesquisar este tema" na sintese de evidencia + tela da coordenacao (/curador/pesquisa).
#  - Revisao do dia (repeticao espacada) no Estudo dirigido; certificado por modulo em Presenca e certificado.
#  - Coleta: tempo de leitura por peca, confianca antes de cada teste e aplicabilidade 30 dias depois (em Pendencias).
# USO: bash 74_extras_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 61, 67, 69 (scripts) e, no banco, 73_extras_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 74_extras_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/extras_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/estudo.ts" ] || { echo "ERRO: rode antes o 69_estudo_app_v1.0.sh"; exit 1; }
cp "$M/api/src/routes/extras.ts" "$API/routes/"
cp "$M/pwa/src/components/"*.tsx "$PWA/components/"
cp "$M/pwa/src/pages/curador/InteressesPesquisa.tsx" "$PWA/pages/curador/"
python3 - "$PWA/estilo.css" "$M/estilo_extras.css" "extras (confianca" <<'PY'
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
echo "copiados: routes/extras.ts, TempoLeitura, ConfiancaTeste, InteressePesquisa, Aplicabilidade, InteressesPesquisa (curador)"

python3 - "$API" "$PWA" <<'PY'
import sys
api, pwa = sys.argv[1:3]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:70]}")
    open(p, "w").write(s.replace(a, b, 1))
m = f"{api}/main.ts"
trocar(m, "import { estudoRouter } from './routes/estudo.js';",
       "import { estudoRouter } from './routes/estudo.js';\nimport { extrasRouter } from './routes/extras.js';", "extrasRouter }")
trocar(m, "app.use('/estudo', limite('estudo', 300, 60_000), exigirCadastro, estudoRouter);",
       "app.use('/estudo', limite('estudo', 300, 60_000), exigirCadastro, estudoRouter);\napp.use('/extra', limite('extra', 300, 60_000), exigirCadastro, extrasRouter);", "app.use('/extra'")
a = f"{pwa}/App.tsx"
trocar(a, "import { CuradorFlashcards } from './pages/curador/Flashcards.js';",
       "import { CuradorFlashcards } from './pages/curador/Flashcards.js';\nimport { InteressesPesquisa } from './pages/curador/InteressesPesquisa.js';", "InteressesPesquisa }")
trocar(a, '<Route path="/curador/flashcards"',
       '<Route path="/curador/pesquisa" element={<Layout papeis={REVISORES} proteger={false}><InteressesPesquisa /></Layout>} />\n        <Route path="/curador/flashcards"', 'path="/curador/pesquisa"')
# Leitura: tempo de leitura e interesse em pesquisa
p = f"{pwa}/pages/aluno/Leitura.tsx"
trocar(p, "import { Markdown } from '../../lib/md.js';",
       "import { Markdown } from '../../lib/md.js';\nimport { TempoLeitura } from '../../components/TempoLeitura.js';\nimport { InteressePesquisa } from '../../components/InteressePesquisa.js';", "TempoLeitura }")
trocar(p, "          {!dados.previa && <Engajamento key={art.tipo}",
       "          {!dados.previa && <TempoLeitura key={`t${art.tipo}`} tema={dados.tema.codigo} tipo={art.tipo} />}\n"
       "          {!dados.previa && art.tipo === 'sintese_evidencia' && <InteressePesquisa tema={dados.tema.codigo} corpo={art.corpo} />}\n"
       "          {!dados.previa && <Engajamento key={art.tipo}", "<TempoLeitura key")
# Testes: confianca antes de abrir as questoes
p = f"{pwa}/pages/aluno/Testes.tsx"
trocar(p, "import { ComparativoTeste } from '../../components/Comparativo.js';",
       "import { ComparativoTeste } from '../../components/Comparativo.js';\nimport { ConfiancaTeste } from '../../components/ConfiancaTeste.js';", "ConfiancaTeste }")
trocar(p, "  async function abrir(ondaId: number) {",
       "  const [confOk, setConfOk] = useState(false);\n  async function abrir(ondaId: number) {\n    setConfOk(false);", "setConfOk(false)")
trocar(p, "      {aberto && (\n        <div>\n          <h2>{NOMES[aberto.dados.teste_num]}</h2>",
       "      {aberto && !confOk && <ConfiancaTeste ondaId={aberto.ondaId} aoConfirmar={() => setConfOk(true)} />}\n"
       "      {aberto && confOk && (\n        <div>\n          <h2>{NOMES[aberto.dados.teste_num]}</h2>", "aberto && confOk &&")
PY
echo "atualizados: main.ts (/extra), App (/curador/pesquisa), Leitura (tempo, interesse em pesquisa), Testes (confianca)"
echo "=== extras instalados ==="
