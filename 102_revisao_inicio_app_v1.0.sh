#!/usr/bin/env bash
# ============================================================
# 102_revisao_inicio_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026):
#  1. A pagina de entrada do coordenador e dos revisores passa a ser o Inicio (/curador), e nao a revisao do T001.
#  2. "Revisao" (menu e cartao do Inicio) abre a lista dos temas que ainda tem rascunho (/curador/revisao).
#     Tema publicado sai da lista; tema em producao (ex.: T002) aparece com o numero de rascunhos.
#  3. Seguranca: as rotas antigas /curador/* da API passam a exigir login de revisor (antes nao exigiam).
# Roda depois dos outros scripts *_app (o subir chama este por ultimo). Pode ser rodado mais de uma vez.
# USO: bash 102_revisao_inicio_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -d "$PWA" ] && [ -d "$API" ] || { echo "ERRO: codigo gerado nao encontrado em $RAIZ"; exit 1; }

# ---- API: lista dos temas com rascunho, dentro da rota /revisao (que ja exige revisor) ----
python3 - "$API/routes/revisao.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if "revisaoRouter.get('/temas'," not in s:
    novo = """revisaoRouter.use(requireRole(REVISORES));

// Temas que ainda tem rascunho (versao mais recente de cada tipo). Tema publicado nao aparece.
revisaoRouter.get('/temas', async (_req, res, next) => {
  try {
    const temas = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT replace(t.codigo, '-', '') AS codigo, t.titulo,
                count(*) FILTER (WHERE a.status = 'rascunho')::int AS rascunhos,
                count(*) FILTER (WHERE a.status = 'publicado')::int AS publicados
           FROM app.tema t JOIN conteudo.artefato a ON a.tema_id = t.tema_id
          GROUP BY t.codigo, t.titulo
         HAVING count(*) FILTER (WHERE a.status = 'rascunho') > 0
          ORDER BY t.codigo`);
      return rows;
    });
    res.json({ temas });
  } catch (err) {
    next(err);
  }
});
"""
    assert "revisaoRouter.use(requireRole(REVISORES));\n" in s, "revisao.ts mudou: nao achei o requireRole"
    s = s.replace("revisaoRouter.use(requireRole(REVISORES));\n", novo, 1)
    open(p, 'w').write(s)
EOF

# ---- API: /curador/* so para revisores ----
python3 - "$API/routes/curador.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if "requireRole" not in s:
    s = s.replace("import { withMaestro } from '../db/transaction.js';\n",
                  "import { withMaestro } from '../db/transaction.js';\nimport { requireRole } from '../middleware/role.js';\n", 1)
    s = s.replace("export const curadorRouter = Router();\n",
                  "export const curadorRouter = Router();\ncuradorRouter.use(requireRole(['admin', 'data_steward', 'curador']));\n", 1)
    assert "curadorRouter.use(requireRole" in s, "curador.ts mudou"
    open(p, 'w').write(s)
EOF

# ---- PWA: pagina com a lista ----
cat > "$PWA/pages/curador/RevisaoLista.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface TemaRascunho { codigo: string; titulo: string; rascunhos: number; publicados: number }

// Temas que ainda tem rascunho para revisar. Tema publicado sai desta lista.
export function RevisaoLista() {
  const [temas, setTemas] = useState<TemaRascunho[] | null>(null);
  const [erro, setErro] = useState(false);
  useEffect(() => { apiGet<{ temas: TemaRascunho[] }>('/revisao/temas').then((d) => setTemas(d.temas)).catch(() => setErro(true)); }, []);
  return (
    <section>
      <h1>Revisão</h1>
      <p>Temas com peças em rascunho. Quando um tema é publicado, ele sai desta lista.</p>
      {erro ? <p className="erro">Não foi possível carregar a lista. Tente de novo em instantes.</p>
        : !temas ? <p className="carregando">Carregando…</p>
        : temas.length === 0 ? <p>Nenhum tema tem rascunho para revisar agora.</p>
        : (
          <ul className="lista-temas">{temas.map((t) => (
            <li key={t.codigo}><a href={`/curador/revisao/${t.codigo}`}>
              <span className="cod">{t.codigo}</span><span className="tit">{t.titulo}</span>
              <span className="selo">{t.rascunhos} {t.rascunhos === 1 ? 'rascunho' : 'rascunhos'}</span><span className="sit" />
            </a></li>))}</ul>
        )}
    </section>
  );
}
EOF

python3 - "$PWA" <<'EOF'
import sys
d = sys.argv[1]
def trocar(arq, velho, novo, marca):
    p = f'{d}/{arq}'; s = open(p).read()
    if marca in s: return
    assert velho in s, f'{arq}: trecho nao encontrado'
    open(p, 'w').write(s.replace(velho, novo))
# entrada do coordenador e dos revisores: o Inicio
trocar('lib/sessao.tsx', "if (REVISORES.includes(papel)) return '/curador/revisao/T001';",
       "if (REVISORES.includes(papel)) return '/curador';", "return '/curador';")
# menu e cartao: a lista de temas com rascunho
p = f'{d}/components/Layout.tsx'; s = open(p).read(); open(p, 'w').write(s.replace("href: '/curador/revisao/T001'", "href: '/curador/revisao'"))
p = f'{d}/pages/curador/Home.tsx'; s = open(p).read(); open(p, 'w').write(s.replace("'/curador/revisao/T001'", "'/curador/revisao'"))
# rota exata da lista, antes da rota do tema
trocar('App.tsx', "import { RevisaoCoordenacao } from './pages/curador/RevisaoCoordenacao.js';\n",
       "import { RevisaoCoordenacao } from './pages/curador/RevisaoCoordenacao.js';\nimport { RevisaoLista } from './pages/curador/RevisaoLista.js';\n",
       "import { RevisaoLista }")
p = f'{d}/App.tsx'; s = open(p).read()
if 'path="/curador/revisao" ' not in s:
    i = s.index('<Route path="/curador/revisao/*"')
    ini = s.rfind('\n', 0, i) + 1
    rec = s[ini:i]
    s = s[:ini] + rec + '<Route path="/curador/revisao" element={<Layout papeis={REVISORES}><RevisaoLista /></Layout>} />\n' + s[ini:]
    open(p, 'w').write(s)
for arq in ('lib/sessao.tsx', 'components/Layout.tsx', 'pages/curador/Home.tsx'):
    assert '/curador/revisao/T001' not in open(f'{d}/{arq}').read(), arq
EOF
echo "revisao: entrada no Inicio e lista de temas com rascunho: pronto"
