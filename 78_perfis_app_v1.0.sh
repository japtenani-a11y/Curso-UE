#!/usr/bin/env bash
# ============================================================
# 78_perfis_app_v1.0.sh
# OBJETIVO: escolha de perfil e funcoes da equipe no aplicativo.
#  - Ao entrar, quem tem mais de um perfil escolhe com qual quer usar o aplicativo (tela /escolher-perfil).
#  - "Meu perfil" (/perfil; acesso pelo perfil atual, ao lado do nome no alto): trocar de perfil a qualquer momento.
#  - Administrador: atribuir e encerrar funcoes de outras pessoas (curador, preceptor, pesquisador,
#    responsavel pelos dados, administrador).
#  - API /perfil e /auth/sessao com os perfis da pessoa.
# USO: bash 78_perfis_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 51, 67, 77 (scripts) e, no banco, 78_perfis_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 78_perfis_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/perfis_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
grep -q -- "--cut-surface" "$PWA/estilo.css" || { echo "ERRO: rode antes o 75 e o 77 (tema CUT)"; exit 1; }
cp "$M/api/src/routes/perfil.ts" "$API/routes/perfil.ts"
cp "$M/pwa/src/pages/Perfil.tsx" "$PWA/pages/Perfil.tsx"
python3 - "$PWA/estilo.css" "$M/estilo_perfil.css" "perfis (meu perfil" <<'PY'
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
python3 - "$API" "$PWA" <<'PY'
import sys
api, pwa = sys.argv[1:3]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:80]}")
    open(p, "w").write(s.replace(a, b, 1))
m = f"{api}/main.ts"
trocar(m, "import { extrasRouter } from './routes/extras.js';",
       "import { extrasRouter } from './routes/extras.js';\nimport { perfilRouter } from './routes/perfil.js';", "perfilRouter }")
trocar(m, "app.use('/auth', limite('auth', 120, 60_000), authRouter);",
       "app.use('/auth', limite('auth', 120, 60_000), authRouter);\napp.use('/perfil', limite('perfil', 120, 60_000), perfilRouter);", "app.use('/perfil'")
# /auth/sessao devolve tambem os perfis e se falta escolher
trocar(f"{api}/routes/auth.ts",
       "      res.status(401).json({ erro: 'sessao_invalida' });\n      return;\n    }\n    res.json(pessoa);",
       "      res.status(401).json({ erro: 'sessao_invalida' });\n      return;\n    }\n"
       "    const perfis = await withMaestro({}, async (client) => (await client.query('SELECT papeis, escolher FROM app.fn_papeis_sessao($1)', [token])).rows[0]);\n"
       "    res.json({ ...pessoa, papeis: perfis?.papeis ?? [pessoa.papel], escolher: Boolean(perfis?.escolher) });", "app.fn_papeis_sessao($1)")
# sessao no aplicativo
trocar(f"{pwa}/lib/sessao.tsx", "export interface Sessao { pessoa_id: string; nome_completo: string; email_primario: string; papel: string }",
       "export interface Sessao { pessoa_id: string; nome_completo: string; email_primario: string; papel: string; papeis?: string[]; escolher?: boolean }", "papeis?: string[]")
# rotas
a = f"{pwa}/App.tsx"
trocar(a, "import { Layout } from './components/Layout.js';",
       "import { Layout } from './components/Layout.js';\nimport { Perfil } from './pages/Perfil.js';", "import { Perfil }")
trocar(a, '        <Route path="/ajuda" element={<Layout proteger={false} semGuarda><Ajuda /></Layout>} />',
       '        <Route path="/ajuda" element={<Layout proteger={false} semGuarda><Ajuda /></Layout>} />\n'
       '        <Route path="/perfil" element={<Layout proteger={false} semGuarda><Perfil /></Layout>} />\n'
       '        <Route path="/escolher-perfil" element={<Layout proteger={false} semGuarda><Perfil escolha /></Layout>} />', 'path="/perfil"')
# Layout: escolha ao entrar, perfil atual ao lado do nome, Meu perfil no menu do celular
l = f"{pwa}/components/Layout.tsx"
trocar(l, "import { PrimeiroAcesso } from './PrimeiroAcesso.js';",
       "import { PrimeiroAcesso } from './PrimeiroAcesso.js';\nimport { NOME_PAPEL } from '../pages/Perfil.js';", "NOME_PAPEL }")
trocar(l, "  if (props.papeis && !props.papeis.includes(sessao.papel)) return <Navigate to=\"/\" replace />;",
       "  if (sessao.escolher && local.pathname !== '/escolher-perfil') return <Navigate to=\"/escolher-perfil\" replace />;\n"
       "  if (props.papeis && !props.papeis.includes(sessao.papel)) return <Navigate to=\"/\" replace />;", "local.pathname !== '/escolher-perfil'")
trocar(l, "            <span>{sessao.nome_completo.split(' ')[0]}</span>",
       "            <span>{sessao.nome_completo.split(' ')[0]}</span>\n"
       "            <a className=\"papel-chip\" href=\"/perfil\" title=\"Meu perfil: trocar de perfil\">{NOME_PAPEL[sessao.papel] ?? sessao.papel}{(sessao.papeis?.length ?? 0) > 1 ? ' ▾' : ''}</a>", 'className="papel-chip"')
trocar(l, "          <button type=\"button\" className=\"botao discreto\" onClick={sair}>Sair</button>\n        </div>",
       "          <a href=\"/perfil\"><span aria-hidden=\"true\">☺</span>Meu perfil ({NOME_PAPEL[sessao.papel] ?? sessao.papel})</a>\n"
       "          <button type=\"button\" className=\"botao discreto\" onClick={sair}>Sair</button>\n        </div>", "Meu perfil (")
PY
echo "perfis instalados: /perfil, /escolher-perfil, API /perfil, /auth/sessao com perfis, Layout"
