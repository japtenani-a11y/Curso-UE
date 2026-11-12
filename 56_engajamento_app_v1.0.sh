#!/usr/bin/env bash
# ============================================================
# 56_engajamento_app_v1.0.sh
# OBJETIVO: instalar no aplicativo e na API:
#  - Temas: os 39 principais com a data da reuniao e os opcionais com D0 escolhido pelo residente
#  - Avaliacao (NPS 0-10 + satisfacao 1-5) no fim de cada peca, de cada gabarito e do curso
#  - Duvidas (respondidas por IA a partir do material do tema) e feedback, em cada peca e numa tela propria
#  - Desempenho: minhas notas e ranking (todos, especialidade, ano, ano + especialidade)
#  - Tempo de leitura de cada peca; termo de consentimento de pesquisa na pagina inicial
#  - API: rota /eng; respondedor de duvidas (npm run respondedor)
# USO: bash 56_engajamento_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 51 (script) e, no banco, 53, 54 e 55. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 56_engajamento_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/engajamento_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$PWA/components/Layout.tsx" ] || { echo "ERRO: rode antes o 51_acabamento_app_v1.0.sh"; exit 1; }

cp "$M/api/src/routes/engajamento.ts" "$API/routes/engajamento.ts"
cp "$M/api/src/respondedor.ts" "$API/respondedor.ts"
cp "$M/pwa/src/components/Engajamento.tsx" "$PWA/components/Engajamento.tsx"
cp "$M/pwa/src/pages/aluno/Temas.tsx" "$M/pwa/src/pages/aluno/Desempenho.tsx" "$M/pwa/src/pages/aluno/Duvidas.tsx" "$PWA/pages/aluno/"
grep -q "engajamento (avaliacao" "$PWA/estilo.css" || cat "$M/estilo_engajamento.css" >> "$PWA/estilo.css"
echo "copiados: routes/engajamento.ts, respondedor.ts, Engajamento.tsx, Temas, Desempenho, Duvidas"

python3 - "$API" "$PWA" "$RAIZ/api/package.json" <<'PY'
import sys, json
api, pwa, pkg = sys.argv[1:4]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:60]}")
    open(p, "w").write(s.replace(a, b, 1))

# API: rota /eng e script do respondedor
trocar(f"{api}/main.ts", "import { contatoRouter } from './routes/contato.js';",
       "import { contatoRouter } from './routes/contato.js';\nimport { engajamentoRouter } from './routes/engajamento.js';", "engajamentoRouter")
trocar(f"{api}/main.ts", "app.use('/contato', contatoRouter);",
       "app.use('/contato', contatoRouter);\napp.use('/eng', limite('eng', 240, 60_000), engajamentoRouter);", "app.use('/eng'")
j = json.load(open(pkg)); j.setdefault("scripts", {})["respondedor"] = "tsx src/respondedor.ts"; json.dump(j, open(pkg, "w"), indent=2); open(pkg, "a").write("\n")

# API: teste por pessoa (ondas pessoais dos temas opcionais)
p = f"{api}/routes/teste.ts"; s = open(p).read()
s = s.replace("FROM app.onda_instancia o WHERE o.tema_id = $1 ORDER BY o.teste_num`, [t.tema_id, p]);",
              "FROM app.onda_instancia o WHERE o.tema_id = $1 AND o.onda_id = app.onda_da_pessoa($2, o.tema_id, o.teste_num) ORDER BY o.teste_num`, [t.tema_id, p]);")
s = s.replace("FROM app.onda_instancia o WHERE o.onda_id = $1 AND o.tema_id IS NOT NULL`, [ondaId, p]);",
              "FROM app.onda_instancia o WHERE o.onda_id = $1 AND o.tema_id IS NOT NULL AND (o.pessoa_id IS NULL OR o.pessoa_id = $2)`, [ondaId, p]);")
open(p, "w").write(s)
if "app.onda_da_pessoa($2" not in s or "o.pessoa_id = $2)`, [ondaId, p]" not in s: sys.exit("ERRO: nao consegui ajustar teste.ts para as ondas pessoais")

# PWA: rotas e navegacao
trocar(f"{pwa}/App.tsx", "import { Contato } from './pages/aluno/Contato.js';",
       "import { Contato } from './pages/aluno/Contato.js';\nimport { Temas } from './pages/aluno/Temas.js';\nimport { Desempenho } from './pages/aluno/Desempenho.js';\nimport { Duvidas } from './pages/aluno/Duvidas.js';", "pages/aluno/Temas.js")
trocar(f"{pwa}/App.tsx", '<Route path="/aluno/contato"',
       '<Route path="/aluno/temas" element={<Layout proteger={false}><Temas /></Layout>} />\n        <Route path="/aluno/desempenho" element={<Layout proteger={false}><Desempenho /></Layout>} />\n        <Route path="/aluno/duvidas" element={<Layout><Duvidas /></Layout>} />\n        <Route path="/aluno/contato"', 'path="/aluno/temas"')
trocar(f"{pwa}/components/Layout.tsx", "    { href: '/aluno/leitura/T001', rotulo: 'Material' },",
       "    { href: '/aluno/temas', rotulo: 'Temas' },\n    { href: '/aluno/leitura/T001', rotulo: 'Material' },", "'/aluno/temas'")
trocar(f"{pwa}/components/Layout.tsx", "    { href: '/aluno/contato', rotulo: 'Lembretes' },",
       "    { href: '/aluno/desempenho', rotulo: 'Desempenho' },\n    { href: '/aluno/duvidas', rotulo: 'Dúvidas' },\n    { href: '/aluno/contato', rotulo: 'Lembretes' },", "'/aluno/desempenho'")

# Leitura: avaliacao, duvida e tempo de uso no fim de cada peca (so para o aluno)
p = f"{pwa}/pages/aluno/Leitura.tsx"
trocar(p, "import { Markdown } from '../../lib/md.js';",
       "import { Markdown } from '../../lib/md.js';\nimport { Engajamento } from '../../components/Engajamento.js';", "components/Engajamento.js")
trocar(p, "            <Markdown texto={limpar(art.corpo, dados.previa)} />\n          )}\n        </div>",
       "            <Markdown texto={limpar(art.corpo, dados.previa)} />\n          )}\n          {!dados.previa && <Engajamento key={art.tipo} tema={dados.tema.codigo} ferramenta={art.tipo} titulo={art.titulo} />}\n        </div>", "<Engajamento key={art.tipo}")

# Testes: avaliacao e duvida depois de cada gabarito
p = f"{pwa}/pages/aluno/Testes.tsx"
trocar(p, "import { apiGet, apiPost } from '../../lib/api.js';",
       "import { apiGet, apiPost } from '../../lib/api.js';\nimport { Avaliacao, Pergunta } from '../../components/Engajamento.js';", "components/Engajamento.js")
trocar(p, "          <button type=\"button\" className=\"sec\" onClick={() => setGab(null)}>Voltar aos testes</button>",
       "          <div className=\"engajamento\">\n            <Avaliacao tema={lista.tema.codigo} ferramenta={`teste_${lista.testes.find((t) => t.onda_id === gab.ondaId)?.teste_num ?? 0}`} titulo=\"este teste\" />\n            <Pergunta tema={lista.tema.codigo} ferramenta={`teste_${lista.testes.find((t) => t.onda_id === gab.ondaId)?.teste_num ?? 0}`} />\n          </div>\n          <button type=\"button\" className=\"sec\" onClick={() => setGab(null)}>Voltar aos testes</button>", "<Avaliacao tema={lista.tema.codigo}")

# Inicio do aluno: termo de pesquisa e atalhos
p = f"{pwa}/pages/aluno/Home.tsx"
trocar(p, "import { Lembretes } from '../../components/Lembretes.js';",
       "import { Lembretes } from '../../components/Lembretes.js';\nimport { ConsentimentoPesquisa } from '../../components/Engajamento.js';", "ConsentimentoPesquisa }")
trocar(p, "        <div className=\"cartoes\">\n", "        <div className=\"cartoes\">\n          <ConsentimentoPesquisa />\n", "<ConsentimentoPesquisa />")
trocar(p, "            <h3>Lembretes</h3>",
       "            <h3>Desempenho e ranking</h3>\n            <p>Suas notas e sua posição entre todos, na sua especialidade, no seu ano e no seu subgrupo.</p>\n            <a className=\"botao discreto\" href=\"/aluno/desempenho\">Ver desempenho</a>\n          </article>\n          <article className=\"cartao-app\">\n            <h3>Lembretes</h3>", "Ver desempenho")
PY
echo "atualizados: main.ts (/eng), teste.ts (ondas pessoais), App, Layout, Leitura, Testes, Home"
echo "=== engajamento instalado ==="
