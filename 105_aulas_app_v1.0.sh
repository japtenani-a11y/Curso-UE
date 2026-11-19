#!/usr/bin/env bash
# ============================================================
# 105_aulas_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026): acesso direto aos temas liberados ("Aulas").
#  - Pagina /aluno/aulas: os TEMAS liberados (com material publicado, como o T001), um cartao por tema, com a
#    situacao da pessoa, quantas pecas ja viu e o acesso direto ao tema, ao material e a aula.
#    Usa /jornada/temas-liberados (105_temas_liberados_v1.0.sql).
#  - Inicio do aluno: cartao "Aulas" no topo, com o numero de temas liberados.
#  - Menu: item "Aulas" para o aluno (depois de Inicio) e para coordenador e curadores (depois de Revisao);
#    cartao "Aulas" no Inicio da coordenacao.
# Roda depois do 104_meu_material_app. Pode ser rodado mais de uma vez.
# USO: bash 105_aulas_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -f "$PWA/components/MeuMaterial.tsx" ] || { echo "ERRO: rode antes o 104_meu_material_app_v1.0.sh"; exit 1; }

# ---------------- API ----------------
python3 - "$API/routes/jornada.ts" <<'PYAPI'
import sys
p = sys.argv[1]; s = open(p).read()
if "'/temas-liberados'" not in s:
    marca = "jornadaRouter.get('/pendencias',"
    assert marca in s, 'jornada.ts mudou'
    novo = (
        "jornadaRouter.get('/temas-liberados', async (_req, res, next) => {\n"
        "  try {\n"
        "    const temas = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.temas_liberados()')).rows);\n"
        "    res.json({ temas });\n"
        "  } catch (err) { next(err); }\n"
        "});\n\n")
    s = s.replace(marca, novo + marca, 1)
    open(p, 'w').write(s)
PYAPI

# ---------------- PWA: pagina Aulas ----------------
cat > "$PWA/pages/aluno/Aulas.tsx" <<'TSX'
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Tema { codigo: string; titulo: string; modulo: string | null; papel: string; etapa: number; pecas: number; vistas: number; aula_aberta: boolean }

const SITUACAO = ['Bloqueado: conclua antes os temas anteriores', 'Comece pelo pré-teste 1', 'Material de antes da aula liberado',
  'Aula liberada', 'Tudo liberado'];

// Temas liberados (com material publicado), um cartao por tema, com acesso direto ao tema, ao material e a aula.
export function Aulas() {
  const [temas, setTemas] = useState<Tema[] | null>(null);
  useEffect(() => { apiGet<{ temas: Tema[] }>('/jornada/temas-liberados').then((d) => setTemas(d.temas)).catch(() => setTemas([])); }, []);
  return (
    <section>
      <h1>Aulas</h1>
      <p>Todos os temas já liberados no curso. Abra o tema para ver o que fazer agora, ou vá direto ao material e à aula. As datas das próximas aulas estão no <a href="/aluno/calendario">calendário</a>.</p>
      {temas === null ? <p className="carregando">Carregando…</p>
        : temas.length === 0 ? <p>Nenhum tema liberado ainda.</p>
        : (
          <div className="grade-inicio duas">
            {temas.map((t) => (
              <article key={t.codigo} className="cartao-app">
                <span className="rotulo">{t.codigo}{t.modulo ? ` · ${t.modulo}` : ''}</span>
                <h2 style={{ marginTop: 4 }}><a href={`/aluno/tema/${t.codigo}`}>{t.titulo}</a></h2>
                <p><small>{SITUACAO[Math.max(0, Math.min(4, Number(t.etapa)))]} · {t.vistas} de {t.pecas} {t.pecas === 1 ? 'peça vista' : 'peças vistas'}</small></p>
                <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                  <a className="botao" href={`/aluno/tema/${t.codigo}`}>Abrir o tema</a>
                  {Number(t.etapa) >= 2 && <a className="botao discreto" href={`/aluno/leitura/${t.codigo}`}>Material</a>}
                  {t.aula_aberta && <a className="botao discreto" href={`/aluno/leitura/${t.codigo}?peca=aula`}>Aula</a>}
                </p>
              </article>
            ))}
          </div>
        )}
    </section>
  );
}
TSX

cat > "$PWA/components/AulasDisponiveis.tsx" <<'TSX'
import { useEffect, useState } from 'react';
import { apiGet } from '../lib/api.js';

// Cartao do Inicio: atalho para os temas liberados (pagina Aulas).
export function AulasDisponiveis() {
  const [n, setN] = useState<number | null>(null);
  useEffect(() => { apiGet<{ temas: unknown[] }>('/jornada/temas-liberados').then((d) => setN(d.temas.length)).catch(() => setN(0)); }, []);
  return (
    <a className="cartao-app entrada destaque" href="/aluno/aulas" style={{ display: 'block', margin: '12px 0' }}>
      <span className="rotulo">Aulas</span>
      <strong>{n === null ? 'Temas liberados' : n === 0 ? 'Nenhum tema liberado ainda' : `${n} ${n === 1 ? 'tema liberado' : 'temas liberados'}`}</strong>
      <span>Abra aqui todos os temas já liberados, com o material e a aula de cada um.</span>
    </a>
  );
}
TSX

# ---------------- PWA: Inicio, rota e menus ----------------
python3 - "$PWA" <<'PYPWA'
import sys
d = sys.argv[1]
def editar(arq, velho, novo, marca):
    p = f'{d}/{arq}'; s = open(p).read()
    if marca in s: return
    assert velho in s, f'{arq} mudou: {velho[:50]}'
    open(p, 'w').write(s.replace(velho, novo, 1))
editar('pages/aluno/Home.tsx', "import { MeuMaterial } from '../../components/MeuMaterial.js';\n",
       "import { MeuMaterial } from '../../components/MeuMaterial.js';\nimport { AulasDisponiveis } from '../../components/AulasDisponiveis.js';\n", 'AulasDisponiveis }')
editar('pages/aluno/Home.tsx', "      <MeuMaterial />\n", "      <AulasDisponiveis />\n      <MeuMaterial />\n", '<AulasDisponiveis />')
editar('App.tsx', "import { AlunoHome } from './pages/aluno/Home.js';\n",
       "import { AlunoHome } from './pages/aluno/Home.js';\nimport { Aulas } from './pages/aluno/Aulas.js';\n", "import { Aulas }")
p = f'{d}/App.tsx'; s = open(p).read()
if 'path="/aluno/aulas"' not in s:
    i = s.index('<Route path="/aluno/*"'); ini = s.rfind('\n', 0, i) + 1
    s = s[:ini] + s[ini:i] + '<Route path="/aluno/aulas" element={<Layout proteger={false}><Aulas /></Layout>} />\n' + s[ini:]
    open(p, 'w').write(s)
editar('components/Layout.tsx',
       "    { href: '/aluno', rotulo: 'Início', icone: '⌂', barra: true, topo: true },\n",
       "    { href: '/aluno', rotulo: 'Início', icone: '⌂', barra: true, topo: true },\n    { href: '/aluno/aulas', rotulo: 'Aulas', icone: '▶', barra: true, topo: true },\n",
       "href: '/aluno/aulas', rotulo: 'Aulas', icone: '▶', barra: true, topo: true },\n    { href: '/aluno/pendencias'")
editar('components/Layout.tsx',
       "      { href: '/curador/revisao', rotulo: 'Revisão', icone: '✎', barra: true, topo: true },\n",
       "      { href: '/curador/revisao', rotulo: 'Revisão', icone: '✎', barra: true, topo: true },\n      { href: '/aluno/aulas', rotulo: 'Aulas', icone: '▶', barra: true, topo: true },\n",
       "      { href: '/aluno/aulas', rotulo: 'Aulas'")
# cartao no Inicio da coordenacao (troca o texto da versao anterior, se houver)
p = f'{d}/pages/curador/Home.tsx'; s = open(p).read()
s = s.replace("{cartao('Aulas', 'Aulas publicadas', '/aluno/aulas', 'aula, slides e caso de cada tema, como o aluno vê')}",
              "{cartao('Aulas', 'Temas liberados', '/aluno/aulas', 'todos os temas publicados, como o aluno vê')}")
open(p, 'w').write(s)
editar('pages/curador/Home.tsx',
       "          {cartao('Revisão', `${r.rascunhos} rascunhos`, '/curador/revisao', `${r.publicados} peças publicadas`)}\n",
       "          {cartao('Revisão', `${r.rascunhos} rascunhos`, '/curador/revisao', `${r.publicados} peças publicadas`)}\n"
       "          {cartao('Aulas', 'Temas liberados', '/aluno/aulas', 'todos os temas publicados, como o aluno vê')}\n",
       "cartao('Aulas',")
PYPWA
echo "aulas (temas liberados: pagina, cartao no Inicio e menus): pronto"
