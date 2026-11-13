#!/usr/bin/env bash
# ============================================================
# 63_cadastro_app_v1.0.sh
# OBJETIVO: inscricao do aluno no aplicativo e na API.
#  - Login com Google de e-mail novo cria a inscricao (app.fn_sessao_google_inscricao, do 62).
#  - Tela /cadastro ("Meus dados"): ficha (nome, nascimento, e-mail, celular, graduacao/semestre ou formatura,
#    faculdade, especialidade, residencia: instituicao, ingresso e termino previsto), termos com texto completo
#    e copia para baixar, aceite obrigatorio (uso/seguranca e privacidade) e opcional (pesquisa e divulgacao),
#    e pedidos LGPD (copia, correcao, exclusao).
#  - Aluno sem inscricao aprovada nao abre material, testes, temas nem avaliacoes (tela e API).
#  - Tela /curador/inscricoes: aprovar, recusar (com motivo) ou suspender; e-mail ao aluno.
# USO: bash 63_cadastro_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 61 (script) e, no banco, 62_cadastro_aluno_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 63_cadastro_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/cadastro_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/jornada.ts" ] || { echo "ERRO: rode antes o 61_jornada_app_v1.0.sh"; exit 1; }

cp "$M/api/src/routes/cadastro.ts" "$M/api/src/routes/inscricoes.ts" "$API/routes/"
cp "$M/api/src/middleware/cadastro.ts" "$API/middleware/cadastro.ts"
cp "$M/pwa/src/pages/Cadastro.tsx" "$PWA/pages/Cadastro.tsx"
cp "$M/pwa/src/pages/curador/Inscricoes.tsx" "$PWA/pages/curador/Inscricoes.tsx"
cp "$M/pwa/src/components/GuardaCadastro.tsx" "$PWA/components/GuardaCadastro.tsx"
cp "$M/pwa/src/lib/instituicoes.ts" "$PWA/lib/instituicoes.ts"
grep -q "cadastro (ficha, termos" "$PWA/estilo.css" || cat "$M/estilo_cadastro.css" >> "$PWA/estilo.css"
echo "copiados: routes/cadastro.ts, routes/inscricoes.ts, middleware/cadastro.ts, Cadastro, Inscricoes, GuardaCadastro"

python3 - "$API" "$PWA" <<'PY'
import sys
api, pwa = sys.argv[1:3]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:70]}")
    open(p, "w").write(s.replace(a, b, 1))

m = f"{api}/main.ts"
trocar(m, "import { painelRouter } from './routes/painel.js';",
       "import { painelRouter } from './routes/painel.js';\nimport { cadastroRouter } from './routes/cadastro.js';\nimport { inscricoesRouter } from './routes/inscricoes.js';\nimport { exigirCadastro } from './middleware/cadastro.js';", "cadastroRouter }")
trocar(m, "app.use('/painel', limite('painel', 120, 60_000), painelRouter);",
       "app.use('/painel', limite('painel', 120, 60_000), painelRouter);\napp.use('/cadastro', limite('cadastro', 60, 60_000), cadastroRouter);\napp.use('/inscricoes', limite('inscricoes', 120, 60_000), inscricoesRouter);", "app.use('/cadastro'")
for r, de, para in [
    ("leitura", "app.use('/leitura', limite('leitura', 240, 60_000), conteudoProtegido, leituraRouter);", "app.use('/leitura', limite('leitura', 240, 60_000), exigirCadastro, conteudoProtegido, leituraRouter);"),
    ("teste", "app.use('/teste', limite('teste', 240, 60_000), conteudoProtegido, testeRouter);", "app.use('/teste', limite('teste', 240, 60_000), exigirCadastro, conteudoProtegido, testeRouter);"),
    ("eng", "app.use('/eng', limite('eng', 240, 60_000), engajamentoRouter);", "app.use('/eng', limite('eng', 240, 60_000), exigirCadastro, engajamentoRouter);"),
    ("jornada", "app.use('/jornada', limite('jornada', 240, 60_000), jornadaRouter);", "app.use('/jornada', limite('jornada', 240, 60_000), exigirCadastro, jornadaRouter);")]:
    trocar(m, de, para, para)

# Login com Google: e-mail novo vira inscricao
p = f"{api}/routes/auth.ts"
trocar(p, "'SELECT app.fn_sessao_google($1, $2::inet, $3) AS token',\n        [dados.email, req.ip ?? null, req.get('user-agent') ?? ''],",
       "'SELECT app.fn_sessao_google_inscricao($1, $2, $3::inet, $4) AS token',\n        [dados.email, dados.name ?? '', req.ip ?? null, req.get('user-agent') ?? ''],", "fn_sessao_google_inscricao")

# PWA: rotas, guarda e menus
a = f"{pwa}/App.tsx"
trocar(a, "import { Painel } from './pages/painel/Painel.js';",
       "import { Painel } from './pages/painel/Painel.js';\nimport { Cadastro } from './pages/Cadastro.js';\nimport { CuradorInscricoes } from './pages/curador/Inscricoes.js';", "pages/Cadastro.js")
trocar(a, '<Route path="/aluno/tema/*"',
       '<Route path="/cadastro" element={<Layout proteger={false} semGuarda><Cadastro /></Layout>} />\n        <Route path="/curador/inscricoes" element={<Layout papeis={REVISORES} proteger={false}><CuradorInscricoes /></Layout>} />\n        <Route path="/aluno/tema/*"', 'path="/cadastro"')
l = f"{pwa}/components/Layout.tsx"
trocar(l, "import { Protecao } from './Protecao.js';", "import { Protecao } from './Protecao.js';\nimport { GuardaCadastro } from './GuardaCadastro.js';", "GuardaCadastro }")
trocar(l, "export function Layout(props: { children: ReactNode; papeis?: string[]; proteger?: boolean }) {",
       "export function Layout(props: { children: ReactNode; papeis?: string[]; proteger?: boolean; semGuarda?: boolean }) {", "semGuarda?: boolean")
trocar(l, "      <main className=\"conteudo\">{miolo}</main>",
       "      <main className=\"conteudo\"><GuardaCadastro ativo={sessao.papel === 'aluno' && !props.semGuarda}>{miolo}</GuardaCadastro></main>", "<GuardaCadastro ativo")
trocar(l, "    { href: '/aluno/contato', rotulo: 'Lembretes' },\n", "    { href: '/cadastro', rotulo: 'Meus dados' },\n", "'/cadastro'")  # lembretes ficam dentro de Meus dados
trocar(l, "      { href: '/curador/duvidas', rotulo: 'Dúvidas' },\n", "      { href: '/curador/duvidas', rotulo: 'Dúvidas' },\n      { href: '/curador/inscricoes', rotulo: 'Inscrições' },\n", "'/curador/inscricoes'")
PY
echo "atualizados: main.ts (/cadastro, /inscricoes, bloqueio sem inscricao), auth.ts (inscricao pelo Google), App, Layout"
echo "=== cadastro do aluno instalado ==="
