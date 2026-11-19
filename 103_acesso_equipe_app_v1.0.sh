#!/usr/bin/env bash
# ============================================================
# 103_acesso_equipe_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026): para coordenador e curadores, nos testes, o botao "Responder" vira
# "Visualizar". Visualizar mostra o caso e todas as questoes do teste (de todos os perfis), com a alternativa correta,
# a justificativa de cada alternativa e a fonte, sem gravar resposta. O desbloqueio do material e da arvore fica no
# 103_acesso_equipe_v1.0.sql.
# Roda depois dos outros scripts *_app. Pode ser rodado mais de uma vez.
# USO: bash 103_acesso_equipe_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -f "$API/routes/teste.ts" ] && [ -f "$PWA/pages/aluno/Testes.tsx" ] || { echo "ERRO: codigo gerado nao encontrado em $RAIZ"; exit 1; }

# ---------------- API ----------------
python3 - "$API/routes/teste.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if '/visualizar' not in s:
    # a lista de testes do tema diz se a pessoa e da equipe
    a = "app.etapa_liberada($2, tema_id) AS etapa, app.perfil_da_pessoa($2) AS perfil"
    assert a in s, 'teste.ts mudou (lista do tema)'
    s = s.replace(a, a + ", app.e_equipe($2) AS equipe", 1)
    novo = """
// Equipe (coordenacao e curadoria): o teste inteiro, com gabarito, sem gravar resposta.
testeRouter.get('/equipe', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const r = await withMaestro(null, (client) => client.query('SELECT app.e_equipe($1) AS equipe', [p]));
    res.json({ equipe: Boolean(r.rows[0]?.equipe) });
  } catch (err) { next(err); }
});

testeRouter.get('/ondas/:ondaId/visualizar', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const ondaId = Number(req.params.ondaId);
    const dados = await withMaestro(null, async (client) => {
      const e = await client.query('SELECT app.e_equipe($1) AS equipe', [p]);
      if (!e.rows[0]?.equipe) return { erro: 'so_equipe', status: 403 };
      const o = await client.query('SELECT onda_id, tema_id, teste_num FROM app.onda_instancia WHERE onda_id = $1 AND tema_id IS NOT NULL', [ondaId]);
      const onda = o.rows[0];
      if (!onda) return { erro: 'onda_nao_encontrada', status: 404 };
      const caso = await client.query('SELECT titulo, texto FROM app.caso_teste WHERE tema_id = $1 AND teste_num = $2', [onda.tema_id, onda.teste_num]);
      const itens = await client.query(
        `SELECT i.item_id, i.enunciado, i.fixa, i.perfil, i.dificuldade, i.ancora,
                json_agg(json_build_object('alternativa_id', a.alternativa_id, 'ordem', a.ordem, 'texto', a.texto,
                         'correta', a.eh_correta, 'categoria', a.categoria_distrator, 'justificativa', a.justificativa) ORDER BY a.ordem) AS alternativas
           FROM app.item_selecionado s
           JOIN app.item i ON i.item_id = s.item_id
           JOIN app.alternativa a ON a.item_id = i.item_id
          WHERE s.onda_id = $1
          GROUP BY i.item_id, i.enunciado, i.fixa, i.perfil, i.dificuldade, i.ancora, s.ordem_apresentada
          ORDER BY i.fixa DESC, i.perfil, s.ordem_apresentada`, [ondaId]);
      return { teste_num: onda.teste_num, caso: caso.rows[0] ?? null, itens: itens.rows };
    });
    if ('erro' in dados) { res.status(dados.status ?? 400).json({ erro: dados.erro }); return; }
    const itens = dados.itens.map((i: { dificuldade: number }) => ({ ...i, grau: GRAUS[i.dificuldade - 1] ?? null, taxa_esperada: TAXAS[i.dificuldade - 1] ?? null }));
    res.json({ ...dados, itens });
  } catch (err) { next(err); }
});
"""
    marca = "testeRouter.get('/ondas/:ondaId/gabarito',"
    assert marca in s, 'teste.ts mudou (gabarito)'
    s = s.replace(marca, novo.lstrip('\n') + '\n' + marca, 1)
    assert 'GRAUS' in s and 'TAXAS' in s, 'teste.ts mudou (GRAUS/TAXAS)'
    open(p, 'w').write(s)
EOF

# ---------------- PWA: tela de testes ----------------
python3 - "$PWA/pages/aluno/Testes.tsx" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if 'function Visualizacao' not in s:
    def trocar(velho, novo):
        global s
        assert velho in s, 'Testes.tsx mudou: ' + velho[:60]
        s = s.replace(velho, novo, 1)
    trocar("interface Lista { tema: { codigo: string; titulo: string; etapa: number; perfil: string | null };",
           "interface Lista { tema: { codigo: string; titulo: string; etapa: number; perfil: string | null; equipe?: boolean };")
    trocar("const [gab, setGab] = useState<{ ondaId: number; itens: Item[] } | null>(null);",
           "const [gab, setGab] = useState<{ ondaId: number; itens: Item[] } | null>(null);\n"
           "  const [vis, setVis] = useState<{ teste_num: number; caso: { titulo: string; texto: string } | null; itens: (Item & { perfil?: string | null })[] } | null>(null);")
    trocar("  async function verGabarito(ondaId: number) {",
           "  async function visualizar(ondaId: number) {\n"
           "    setErro(null); setGab(null); setAberto(null);\n"
           "    const r = await pedir<{ teste_num: number; caso: { titulo: string; texto: string } | null; itens: (Item & { perfil?: string | null })[] }>('GET', `/teste/ondas/${ondaId}/visualizar`);\n"
           "    if (r.ok) { setVis(r.dados); topo.current?.scrollIntoView(); } else setErro(msg(r.erro, 'Não foi possível abrir o teste agora.'));\n"
           "  }\n"
           "  async function verGabarito(ondaId: number) {")
    trocar("      {!aberto && !gab && (",
           "      {vis && (\n"
           "        <>\n"
           "          <p><button type=\"button\" className=\"tst2-btn\" onClick={() => setVis(null)}>Voltar à lista de testes</button></p>\n"
           "          <Visualizacao dados={vis} />\n"
           "        </>\n"
           "      )}\n"
           "      {!aberto && !gab && !vis && (")
    trocar("              {t.submetida_em\n                ? <button",
           "              {lista.tema.equipe\n"
           "                ? <button type=\"button\" className=\"tst2-btn prim\" onClick={() => visualizar(t.onda_id)}>Visualizar</button>\n"
           "                : t.submetida_em\n                ? <button")
    s += '''
// Modo da equipe: o teste inteiro, como o aluno veria no gabarito, sem resposta gravada.
function Visualizacao({ dados }: { dados: { teste_num: number; caso: { titulo: string; texto: string } | null; itens: (Item & { perfil?: string | null })[] } }) {
  const grupos = new Map<string, (Item & { perfil?: string | null })[]>();
  for (const i of dados.itens) { const k = i.fixa ? 'Âncoras (todos os perfis)' : `Perfil ${i.perfil ?? '—'}`; grupos.set(k, [...(grupos.get(k) ?? []), i]); }
  return (
    <div className="tst2-gab">
      <h2>{NOMES[dados.teste_num]}: visualização da equipe</h2>
      <p className="tst2-meta">Modo de conferência: nada é gravado como resposta. Cada aluno recebe as âncoras e as questões do próprio perfil.</p>
      {dados.caso && (<details className="tst2-caso" open><summary>Caso clínico: {dados.caso.titulo}</summary><p>{dados.caso.texto}</p></details>)}
      {[...grupos.entries()].map(([g, itens]) => (
        <section key={g}>
          <h3>{g} · {itens.length} {itens.length === 1 ? 'questão' : 'questões'}</h3>
          {itens.map((i, n) => (
            <article key={i.item_id} className="tst2-bloco">
              <p className="tst2-vinheta"><b>{n + 1}.</b> {i.enunciado}</p>
              <p className="tst2-meta">Grau: {i.grau ?? '—'} · acerto esperado: {i.taxa_esperada ?? '—'} · fonte: {i.ancora ?? '—'}</p>
              {i.alternativas.map((a, k) => (
                <div key={a.alternativa_id} className={`tst2-galt${a.correta ? ' correta' : ''}`}>
                  <p><span className="letra">{LETRAS[k]}</span> {a.texto}{a.correta && <em> ✓ correta</em>}</p>
                  {a.justificativa && <p className="just">{a.correta ? '' : `${CAT[a.categoria ?? ''] ?? ''}: `}{a.justificativa}</p>}
                </div>
              ))}
            </article>
          ))}
        </section>
      ))}
    </div>
  );
}
'''
    open(p, 'w').write(s)
EOF

# ---------------- PWA: tela do tema (linha do tempo) ----------------
python3 - "$PWA/pages/aluno/Tema.tsx" <<'EOF'
import sys, re
p = sys.argv[1]; s = open(p).read()
if 'equipeTeste' not in s:
    a = "{t.respondivel && !t.feito && <a className=\"botao\" href={`/aluno/testes/${cod}`}>Responder</a>}"
    b = "{t.feito && <a className=\"botao discreto\" href={`/aluno/testes/${cod}`}>Ver gabarito</a>}"
    assert a in s and b in s, 'Tema.tsx mudou'
    s = s.replace(a, "{equipeTeste ? <a className=\"botao\" href={`/aluno/testes/${cod}`}>Visualizar</a> : t.respondivel && !t.feito && <a className=\"botao\" href={`/aluno/testes/${cod}`}>Responder</a>}", 1)
    s = s.replace(b, "{!equipeTeste && t.feito && <a className=\"botao discreto\" href={`/aluno/testes/${cod}`}>Ver gabarito</a>}", 1)
    # flag da equipe, lida uma vez da API
    m = re.search(r'\nexport function (\w+)\([^)]*\)\s*\{\n', s)
    assert m, 'Tema.tsx: funcao principal nao encontrada'
    ini = m.end()
    s = s[:ini] + "  const [equipeTeste, setEquipeTeste] = useState(false);\n  useEffect(() => { apiGet<{ equipe: boolean }>('/teste/equipe').then((d) => setEquipeTeste(d.equipe)).catch(() => undefined); }, []);\n" + s[ini:]
    if 'apiGet' not in s.split('export function')[0]:
        s = "import { apiGet } from '../../lib/api.js';\n" + s
    head = s.split('export function')[0]
    if 'useEffect' not in head or 'useState' not in head:
        s = "import { useEffect as useEffect, useState as useState } from 'react';\n" + s if 'from \'react\'' not in head else s
    open(p, 'w').write(s)
EOF
echo "acesso da equipe (Visualizar nos testes): pronto"
