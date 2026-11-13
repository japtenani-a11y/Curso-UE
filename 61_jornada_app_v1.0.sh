#!/usr/bin/env bash
# ============================================================
# 61_jornada_app_v1.0.sh
# OBJETIVO: jornada do aluno e painel de dados no aplicativo e na API.
#  - Inicio do aluno com 3 entradas: Pendencias, Calendario de aulas e Temas por modulo.
#  - Tela do tema (/aluno/tema/T001): fases D-15 -> pre-aula -> D0 -> pos-aula, estado de cada teste e de cada peca,
#    agendamento do D0 nos temas opcionais e avaliacao geral do tema.
#  - Calendario de aulas (/aluno/calendario) e Pendencias (/aluno/pendencias: testes e avaliacoes que faltam).
#  - Leitura abre direto na peca pedida (?peca=aula) e inclui os simulados.
#  - Painel (/painel) para admin, curador, data_steward e pesquisador: graficos de evolucao por aluno, turma
#    (ano de entrada), especialidade e ano; NPS e satisfacao; tabelas de notas, avaliacoes, duvidas e uso; CSV.
#  - API: rotas /jornada e /painel.
# USO: bash 61_jornada_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 56 (script) e, no banco, 60_jornada_aluno_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 61_jornada_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/jornada_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/curadoria.ts" ] || { echo "ERRO: rode antes o 56_engajamento_app_v1.0.sh"; exit 1; }

cp "$M/api/src/routes/jornada.ts" "$M/api/src/routes/painel.ts" "$API/routes/"
mkdir -p "$PWA/pages/painel"
cp "$M/pwa/src/pages/aluno/Tema.tsx" "$M/pwa/src/pages/aluno/Calendario.tsx" "$M/pwa/src/pages/aluno/Pendencias.tsx" "$M/pwa/src/pages/aluno/Home.tsx" "$PWA/pages/aluno/"
cp "$M/pwa/src/pages/painel/Painel.tsx" "$PWA/pages/painel/"
grep -q "jornada (modulos, tema" "$PWA/estilo.css" || cat "$M/estilo_jornada.css" >> "$PWA/estilo.css"
echo "copiados: routes/jornada.ts, routes/painel.ts, Tema, Calendario, Pendencias, Home (aluno), Painel"

python3 - "$API" "$PWA" <<'PY'
import sys, re
api, pwa = sys.argv[1:3]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:70]}")
    open(p, "w").write(s.replace(a, b, 1))

# API: rotas
m = f"{api}/main.ts"
trocar(m, "import { curadoriaRouter } from './routes/curadoria.js';",
       "import { curadoriaRouter } from './routes/curadoria.js';\nimport { jornadaRouter } from './routes/jornada.js';\nimport { painelRouter } from './routes/painel.js';", "jornadaRouter }")
trocar(m, "app.use('/curadoria', limite('curadoria', 240, 60_000), curadoriaRouter);",
       "app.use('/curadoria', limite('curadoria', 240, 60_000), curadoriaRouter);\napp.use('/jornada', limite('jornada', 240, 60_000), jornadaRouter);\napp.use('/painel', limite('painel', 120, 60_000), painelRouter);", "app.use('/jornada'")

# API: leitura com simulados, na ordem pre-aula -> aula -> pos-aula
p = f"{api}/routes/leitura.ts"; s = open(p).read()
s2 = re.sub(r"const TIPOS = \[[^\]]*\];",
            "const TIPOS = ['objetivos', 'resumo_basico', 'podcast_roteiro', 'caso_base', 'aula', 'slides', 'caso', 'sintese_evidencia',\n  'resumo', 'mapa', 'flashcard', 'protocolo', 'checklist', 'simulado'];", s, count=1, flags=re.S)
if s2 == s and "'simulado']" not in s: sys.exit("ERRO: nao consegui ajustar a lista de pecas em leitura.ts")
open(p, "w").write(s2)

# PWA: rotas
a = f"{pwa}/App.tsx"
trocar(a, "import { Duvidas } from './pages/aluno/Duvidas.js';",
       "import { Duvidas } from './pages/aluno/Duvidas.js';\nimport { Tema } from './pages/aluno/Tema.js';\nimport { Calendario } from './pages/aluno/Calendario.js';\nimport { Pendencias } from './pages/aluno/Pendencias.js';\nimport { Painel } from './pages/painel/Painel.js';", "pages/aluno/Tema.js")
trocar(a, '<Route path="/aluno/temas"',
       '<Route path="/aluno/tema/*" element={<Layout proteger={false}><Tema /></Layout>} />\n        <Route path="/aluno/calendario" element={<Layout proteger={false}><Calendario /></Layout>} />\n        <Route path="/aluno/pendencias" element={<Layout proteger={false}><Pendencias /></Layout>} />\n        <Route path="/painel" element={<Layout papeis={[...REVISORES, \'pesquisador\']} proteger={false}><Painel /></Layout>} />\n        <Route path="/aluno/temas"', 'path="/aluno/tema/*"')

# PWA: navegacao
l = f"{pwa}/components/Layout.tsx"; s = open(l).read()
ini = s.find("  return [\n    { href: '/aluno', rotulo: 'Início' },")
if "'/aluno/pendencias'" not in s:
    if ini < 0: sys.exit("ERRO: nao encontrei o menu do aluno em Layout.tsx")
    fim = s.index("  ];\n}", ini)
    s = s[:ini] + """  return [
    { href: '/aluno', rotulo: 'Início' },
    { href: '/aluno/pendencias', rotulo: 'Pendências' },
    { href: '/aluno/calendario', rotulo: 'Calendário' },
    { href: '/aluno/temas', rotulo: 'Temas' },
    { href: '/aluno/desempenho', rotulo: 'Desempenho' },
    { href: '/aluno/duvidas', rotulo: 'Dúvidas' },
    { href: '/aluno/contato', rotulo: 'Lembretes' },
""" + s[fim:]
s = s.replace("      { href: '/curador', rotulo: 'Painel' },\n", "      { href: '/painel', rotulo: 'Dados e gráficos' },\n      { href: '/curador', rotulo: 'Início' },\n", 1)
s = s.replace("if (papel === 'pesquisador') return [{ href: '/pesquisa', rotulo: 'Pesquisa' }];",
              "if (papel === 'pesquisador') return [{ href: '/painel', rotulo: 'Dados e gráficos' }, { href: '/pesquisa', rotulo: 'Pesquisa' }];", 1)
open(l, "w").write(s)
for x in ("'/aluno/pendencias'", "href: '/painel', rotulo: 'Dados e gráficos' },\n      { href: '/curador'"):
    if x not in s: sys.exit(f"ERRO: nao consegui ajustar o menu ({x[:30]})")

# Leitura: abrir direto na peca pedida (?peca=tipo)
p = f"{pwa}/pages/aluno/Leitura.tsx"
trocar(p, "      .then(setDados)\n", "      .then((d) => {\n        setDados(d);\n        const peca = new URLSearchParams(window.location.search).get('peca');\n        const k = peca ? d.artefatos.findIndex((a) => a.tipo === peca) : -1;\n        if (k >= 0) setAtivo(k);\n      })\n", "get('peca')")
trocar(p, "<h1>{dados.tema.codigo} — {dados.tema.titulo}</h1>",
       "{!dados.previa && <p className=\"migalha\"><a href={`/aluno/tema/${dados.tema.codigo.replace('-', '')}`}>← Voltar ao tema</a></p>}\n      <h1>{dados.tema.codigo} — {dados.tema.titulo}</h1>", "Voltar ao tema")

# Lembretes na tela: aviso de abertura (dias_apos = 0) e link para a tela do tema
p = f"{pwa}/components/Lembretes.tsx"
trocar(p, "            : `${NOMES[l.teste_num]} de ${l.tema} pendente há ${l.dias_apos} dias.`}{' '}\n          <a href={`/aluno/testes/${l.tema.replace('-', '')}`}>Responder agora</a>{' '}",
       "            : l.dias_apos === 0\n              ? `${l.tema}: ${NOMES[l.teste_num]} disponível${l.teste_num === 3 ? ' — material da aula liberado' : l.teste_num === 1 ? ' — tema aberto' : ''}.`\n              : `${NOMES[l.teste_num]} de ${l.tema} pendente há ${l.dias_apos} dias.`}{' '}\n          <a href={`/aluno/tema/${l.tema.replace('-', '')}`}>{l.dias_apos === 0 ? 'Abrir o tema' : 'Responder agora'}</a>{' '}", "l.dias_apos === 0")
PY
echo "atualizados: main.ts (/jornada, /painel), leitura.ts (simulados), App, Layout (menus), Leitura (?peca=)"
echo "=== jornada do aluno e painel instalados ==="
