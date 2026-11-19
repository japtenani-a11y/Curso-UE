#!/usr/bin/env bash
# ============================================================
# 105_aulas_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026): acesso direto a todas as aulas disponiveis.
#  - Pagina nova /aluno/aulas: um bloco por tema com a aula liberada, com botoes para Aula, Slides e Caso da aula
#    (marca o que ja foi visto). Usa /jornada/meu-material (104).
#  - Inicio do aluno: cartao "Aulas disponiveis" no topo, com o numero de aulas e o link para a pagina.
#  - Menu do aluno: item "Aulas" logo depois de "Inicio" (no computador e na barra do celular).
# Roda depois do 104_meu_material_app. Pode ser rodado mais de uma vez.
# USO: bash 105_aulas_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"
[ -f "$PWA/components/MeuMaterial.tsx" ] || { echo "ERRO: rode antes o 104_meu_material_app_v1.0.sh"; exit 1; }

cat > "$PWA/pages/aluno/Aulas.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Peca { codigo: string; titulo: string; tipo: string; publicado_em: string | null; visto: boolean; ultimo_acesso: string | null }
interface Tema { codigo: string; titulo: string; pecas: Peca[] }
const TIPOS: [string, string][] = [['aula', 'Aula'], ['slides', 'Slides'], ['caso', 'Caso da aula']];

// Todas as aulas ja liberadas para a pessoa, um bloco por tema, com acesso direto a aula, aos slides e ao caso.
export function Aulas() {
  const [temas, setTemas] = useState<Tema[] | null>(null);
  useEffect(() => {
    apiGet<{ itens: Peca[] }>('/jornada/meu-material').then((d) => {
      const m = new Map<string, Tema>();
      for (const p of d.itens) {
        if (!TIPOS.some(([t]) => t === p.tipo)) continue;
        const t = m.get(p.codigo) ?? { codigo: p.codigo, titulo: p.titulo, pecas: [] };
        t.pecas.push(p); m.set(p.codigo, t);
      }
      setTemas([...m.values()].sort((a, b) => a.codigo.localeCompare(b.codigo)));
    }).catch(() => setTemas([]));
  }, []);
  return (
    <section>
      <h1>Aulas disponíveis</h1>
      <p>Todas as aulas já liberadas para você, de todos os temas. A aula de cada tema abre no dia da aula (D0). Veja as datas das próximas no <a href="/aluno/calendario">calendário</a>.</p>
      {temas === null ? <p className="carregando">Carregando…</p>
        : temas.length === 0 ? <p>Nenhuma aula liberada ainda. Elas aparecem aqui no dia da aula de cada tema.</p>
        : (
          <div className="grade-inicio duas">
            {temas.map((t) => {
              const vistas = t.pecas.filter((p) => p.visto).length;
              return (
                <article key={t.codigo} className="cartao-app">
                  <span className="rotulo">{t.codigo}{vistas === t.pecas.length ? ' · já vista' : vistas ? ' · em andamento' : ' · nova'}</span>
                  <h2 style={{ marginTop: 4 }}><a href={`/aluno/tema/${t.codigo}`}>{t.titulo}</a></h2>
                  <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                    {TIPOS.map(([tipo, nome]) => {
                      const p = t.pecas.find((x) => x.tipo === tipo);
                      return p ? <a key={tipo} className={`botao${tipo === 'aula' ? '' : ' discreto'}`} href={`/aluno/leitura/${t.codigo}?peca=${tipo}`}>{nome}{p.visto ? ' ✓' : ''}</a> : null;
                    })}
                  </p>
                </article>
              );
            })}
          </div>
        )}
    </section>
  );
}
EOF

cat > "$PWA/components/AulasDisponiveis.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet } from '../lib/api.js';

// Cartao do Inicio: atalho para todas as aulas liberadas.
export function AulasDisponiveis() {
  const [n, setN] = useState<{ total: number; novas: number } | null>(null);
  useEffect(() => {
    apiGet<{ itens: { codigo: string; tipo: string; visto: boolean }[] }>('/jornada/meu-material').then((d) => {
      const aulas = d.itens.filter((i) => i.tipo === 'aula');
      setN({ total: aulas.length, novas: aulas.filter((i) => !i.visto).length });
    }).catch(() => setN({ total: 0, novas: 0 }));
  }, []);
  return (
    <a className="cartao-app entrada destaque" href="/aluno/aulas" style={{ display: 'block', margin: '12px 0' }}>
      <span className="rotulo">Aulas</span>
      <strong>{n === null ? 'Aulas disponíveis' : n.total === 0 ? 'Nenhuma aula liberada ainda' : `${n.total} ${n.total === 1 ? 'aula disponível' : 'aulas disponíveis'}`}</strong>
      <span>{n && n.novas > 0 ? `${n.novas} ${n.novas === 1 ? 'nova' : 'novas'} · ` : ''}Abra aqui todas as aulas, slides e casos de uma vez.</span>
    </a>
  );
}
EOF

python3 - "$PWA" <<'EOF'
import sys
d = sys.argv[1]
def editar(arq, velho, novo, marca):
    p = f'{d}/{arq}'; s = open(p).read()
    if marca in s: return
    assert velho in s, f'{arq} mudou: {velho[:50]}'
    open(p, 'w').write(s.replace(velho, novo, 1))
# Inicio: cartao no topo
editar('pages/aluno/Home.tsx', "import { MeuMaterial } from '../../components/MeuMaterial.js';\n",
       "import { MeuMaterial } from '../../components/MeuMaterial.js';\nimport { AulasDisponiveis } from '../../components/AulasDisponiveis.js';\n", 'AulasDisponiveis }')
editar('pages/aluno/Home.tsx', "      <MeuMaterial />\n", "      <AulasDisponiveis />\n      <MeuMaterial />\n", '<AulasDisponiveis />')
# rota
editar('App.tsx', "import { AlunoHome } from './pages/aluno/Home.js';\n",
       "import { AlunoHome } from './pages/aluno/Home.js';\nimport { Aulas } from './pages/aluno/Aulas.js';\n", "import { Aulas }")
p = f'{d}/App.tsx'; s = open(p).read()
if 'path="/aluno/aulas"' not in s:
    i = s.index('<Route path="/aluno/*"'); ini = s.rfind('\n', 0, i) + 1
    s = s[:ini] + s[ini:i] + '<Route path="/aluno/aulas" element={<Layout proteger={false}><Aulas /></Layout>} />\n' + s[ini:]
    open(p, 'w').write(s)
# menu do aluno
editar('components/Layout.tsx',
       "    { href: '/aluno', rotulo: 'Início', icone: '⌂', barra: true, topo: true },\n",
       "    { href: '/aluno', rotulo: 'Início', icone: '⌂', barra: true, topo: true },\n    { href: '/aluno/aulas', rotulo: 'Aulas', icone: '▶', barra: true, topo: true },\n",
       "href: '/aluno/aulas'")
EOF
echo "aulas disponiveis (pagina, cartao no Inicio e menu): pronto"
