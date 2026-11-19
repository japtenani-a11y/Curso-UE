#!/usr/bin/env bash
# ============================================================
# 109_simulado_filtros_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026): no simulado do estudo dirigido,
#  - filtros pelo historico do aluno (ineditas, repetidas, ja acertei, ja errei, errei da ultima vez, sempre acertei)
#    e pelo numero de vezes que ja respondeu; opcao "todas as questoes que passam nos filtros";
#  - contagem ao vivo das questoes disponiveis com os filtros escolhidos;
#  - no gabarito: vezes respondida no curso, por quantas pessoas, taxa de acerto e porcentagem de cada alternativa.
# Precisa do 109_simulado_filtros_v1.0.sql. Roda depois dos outros scripts *_app. Pode ser rodado mais de uma vez.
# USO: bash 109_simulado_filtros_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -f "$API/routes/estudo.ts" ] && [ -f "$PWA/pages/aluno/Estudo.tsx" ] || { echo "ERRO: codigo gerado nao encontrado em $RAIZ"; exit 1; }

python3 - "$API/routes/estudo.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if 'filtrosSimulado' not in s:
    velho = """    const b = (req.body ?? {}) as Record<string, unknown>;
    const p = { temas: Array.isArray(b.temas) ? b.temas.map(String).slice(0, 200) : [], grau_min: Number(b.grau_min) || 1,
      grau_max: Number(b.grau_max) || 6, quantidade: Number(b.quantidade) || 10,
      modo: ['revisao', 'misturado'].includes(String(b.modo)) ? String(b.modo) : undefined };
    res.json(await um('SELECT app.montar_simulado($1::jsonb) AS r', [JSON.stringify(p)]));"""
    assert velho in s, 'estudo.ts mudou'
    s = s.replace(velho, """    res.json(await um('SELECT app.montar_simulado($1::jsonb) AS r', [JSON.stringify(filtrosSimulado(req.body))]));""", 1)
    marca = "// ---------- simulados ----------\n"
    assert marca in s
    novo = marca + """const HISTORICOS = ['todas', 'ineditas', 'repetidas', 'ja_acertei', 'ja_errei', 'errei_ultima', 'sempre_acertei'];
function filtrosSimulado(corpo: unknown) {
  const b = (corpo ?? {}) as Record<string, unknown>;
  const vezes = (v: unknown) => (v === null || v === undefined || v === '' || !Number.isFinite(Number(v)) ? undefined : Math.max(0, Math.min(999, Math.round(Number(v)))));
  return { temas: Array.isArray(b.temas) ? b.temas.map(String).slice(0, 200) : [], grau_min: Number(b.grau_min) || 1,
    grau_max: Number(b.grau_max) || 6, quantidade: Number(b.quantidade) || 10, todas: b.todas === true,
    historico: HISTORICOS.includes(String(b.historico)) ? String(b.historico) : 'todas',
    vezes_min: vezes(b.vezes_min), vezes_max: vezes(b.vezes_max),
    modo: ['revisao', 'misturado'].includes(String(b.modo)) ? String(b.modo) : undefined };
}

// Quantas questoes passam nos filtros (para o aluno ver antes de montar).
estudoRouter.post('/simulados/contar', async (req, res, next) => {
  try { res.json({ disponiveis: await um('SELECT app.contar_simulado($1::jsonb) AS r', [JSON.stringify(filtrosSimulado(req.body))]) }); }
  catch (e) { erro(e, res, next); }
});

"""
    s = s.replace(marca, novo, 1)
    open(p, 'w').write(s)
EOF

python3 - "$PWA/pages/aluno/Estudo.tsx" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if 'HISTORICO_OPCOES' in s:
    print('Estudo.tsx ja tem os filtros'); sys.exit(0)
def troca(velho, novo):
    global s
    assert s.count(velho) == 1, ('Estudo.tsx mudou', velho[:60])
    s = s.replace(velho, novo, 1)

troca("interface Questao { item_id: number; tema: string; enunciado: string; caso: string | null; grau: number; escolhida: number | null; alternativas: Alt[] }",
"""interface Estat { respostas: number; pessoas: number; acerto_pct: number | null; alternativas: Record<string, number> }
interface Questao { item_id: number; tema: string; enunciado: string; caso: string | null; grau: number; escolhida: number | null; alternativas: Alt[];
  estatistica?: Estat | null; minhas_vezes?: number | null }
const HISTORICO_OPCOES: [string, string][] = [
  ['todas', 'Todas as questões'], ['ineditas', 'Só as inéditas (nunca respondi)'], ['repetidas', 'Só as que já respondi'],
  ['ja_acertei', 'Só as que já acertei alguma vez'], ['ja_errei', 'Só as que já errei alguma vez'],
  ['errei_ultima', 'Só as que errei da última vez'], ['sempre_acertei', 'Só as que sempre acertei'],
];""")

troca("  const [qtd, setQtd] = useState(10);\n  const [sim, setSim] = useState<Simulado | null>(null);",
"""  const [qtd, setQtd] = useState(10);
  const [hist, setHist] = useState('todas');
  const [vMin, setVMin] = useState('');
  const [vMax, setVMax] = useState('');
  const [todas, setTodas] = useState(false);
  const [contagem, setContagem] = useState<number | null>(null);
  const [sim, setSim] = useState<Simulado | null>(null);""")

troca("""  const disponiveis = useMemo(() => op.temas.filter((t) => temas.length === 0 || temas.includes(t.codigo))
    .reduce((s, t) => s + Object.entries(t.por_grau).filter(([g]) => Number(g) >= Math.min(min, max) && Number(g) <= Math.max(min, max)).reduce((a, [, k]) => a + k, 0), 0), [op, temas, min, max]);""",
"""  const porGrau = useMemo(() => op.temas.filter((t) => temas.length === 0 || temas.includes(t.codigo))
    .reduce((s, t) => s + Object.entries(t.por_grau).filter(([g]) => Number(g) >= Math.min(min, max) && Number(g) <= Math.max(min, max)).reduce((a, [, k]) => a + k, 0), 0), [op, temas, min, max]);
  const filtros = { temas, grau_min: min, grau_max: max, historico: hist, vezes_min: vMin === '' ? null : Number(vMin), vezes_max: vMax === '' ? null : Number(vMax) };
  const chave = JSON.stringify(filtros);
  useEffect(() => {
    let vivo = true;
    const t = window.setTimeout(() => {
      apiPost<{ disponiveis: number }>('/estudo/simulados/contar', filtros).then((r) => { if (vivo) setContagem(r.disponiveis); }).catch(() => { if (vivo) setContagem(null); });
    }, 250);
    return () => { vivo = false; window.clearTimeout(t); };
  }, [chave]); // eslint-disable-line react-hooks/exhaustive-deps
  const disponiveis = contagem ?? porGrau;""")

troca("      const s = await apiPost<Simulado>('/estudo/simulados', { temas, grau_min: min, grau_max: max, quantidade: qtd });",
      "      const s = await apiPost<Simulado>('/estudo/simulados', { ...filtros, quantidade: qtd, todas });")

troca("""            {sim.concluido && q.escolhida === null && <p><small>Você deixou esta questão em branco.</small></p>}""",
"""            {sim.concluido && q.escolhida === null && <p><small>Você deixou esta questão em branco.</small></p>}
            {sim.concluido && q.estatistica && (
              <div className="estat-questao" style={{ marginTop: 8, fontSize: 14, color: 'var(--cut-text-muted)' }}>
                {q.estatistica.respostas > 0 ? (<>
                  <p style={{ margin: '4px 0' }}>No curso: respondida {q.estatistica.respostas} {q.estatistica.respostas === 1 ? 'vez' : 'vezes'} por {q.estatistica.pessoas} {q.estatistica.pessoas === 1 ? 'pessoa' : 'pessoas'} · acerto de {q.estatistica.acerto_pct ?? 0}%
                    {q.minhas_vezes ? ` · você já respondeu ${q.minhas_vezes} ${q.minhas_vezes === 1 ? 'vez' : 'vezes'}` : ''}</p>
                  <p style={{ margin: '4px 0' }}>Escolha de cada alternativa: {q.alternativas.map((a, k) => `${String.fromCharCode(65 + k)} ${q.estatistica?.alternativas[String(a.alternativa_id)] ?? 0}%`).join(' · ')}</p>
                </>) : <p style={{ margin: '4px 0' }}>Ainda sem respostas de outras pessoas a esta questão.</p>}
              </div>
            )}""")

troca("""                      {sim.concluido && a.correta && <em> — correta</em>}""",
"""                      {sim.concluido && a.correta && <em> — correta</em>}
                      {sim.concluido && q.estatistica && q.estatistica.respostas > 0 && <small> ({q.estatistica.alternativas[String(a.alternativa_id)] ?? 0}% escolheram)</small>}""")

troca("""        <fieldset className="campo-estudo">
          <legend>3. Número de questões</legend>""",
"""        <fieldset className="campo-estudo">
          <legend>3. Seu histórico nas questões</legend>
          <label>Quais questões <select value={hist} onChange={(e) => setHist(e.target.value)}>
            {HISTORICO_OPCOES.map(([v, t]) => <option key={v} value={v}>{t}</option>)}</select></label>
          <p style={{ margin: '8px 0 0' }}>Já respondi
            {' '}<label>de <input type="number" min={0} max={99} value={vMin} style={{ width: 64 }} onChange={(e) => setVMin(e.target.value)} aria-label="Respondida pelo menos" /></label>
            {' '}<label>até <input type="number" min={0} max={99} value={vMax} style={{ width: 64 }} onChange={(e) => setVMax(e.target.value)} aria-label="Respondida no máximo" /></label> vezes
            <small> (deixe em branco para não filtrar)</small></p>
        </fieldset>
        <fieldset className="campo-estudo">
          <legend>4. Número de questões</legend>
          <label style={{ display: 'block', marginBottom: 8 }}><input type="checkbox" checked={todas} onChange={(e) => setTodas(e.target.checked)} /> Todas as questões que passam nos filtros</label>""")

troca("""          <div className="chips">{[5, 10, 20, 30].map((n) => <button key={n} type="button" className={`botao discreto ${qtd === n ? 'sel' : ''}`} aria-pressed={qtd === n} onClick={() => setQtd(n)}>{n}</button>)}
            <label className="outro">ou <input type="number" min={1} max={60} value={qtd} onChange={(e) => setQtd(Math.max(1, Math.min(60, Number(e.target.value) || 1)))} aria-label="Outro número de questões" /></label></div>""",
"""          {!todas && <div className="chips">{[5, 10, 20, 30, 50].map((n) => <button key={n} type="button" className={`botao discreto ${qtd === n ? 'sel' : ''}`} aria-pressed={qtd === n} onClick={() => setQtd(n)}>{n}</button>)}
            <label className="outro">ou <input type="number" min={1} max={500} value={qtd} onChange={(e) => setQtd(Math.max(1, Math.min(500, Number(e.target.value) || 1)))} aria-label="Outro número de questões" /></label></div>}""")

troca("""        <p><small>{disponiveis} questões disponíveis com esses filtros{disponiveis < qtd && disponiveis > 0 ? ` — o simulado terá ${disponiveis}.` : '.'} O sorteio é aleatório a cada vez.</small></p>""",
"""        <p><small>{disponiveis} questões disponíveis com esses filtros{todas ? (disponiveis > 0 ? ` — o simulado terá todas${disponiveis > 1000 ? ' (até 1000)' : ''}.` : '.') : (disponiveis < qtd && disponiveis > 0 ? ` — o simulado terá ${disponiveis}.` : '.')} A ordem é sorteada a cada vez. Entram as questões e os casos das ondas que você já enviou; depois do D+90, o tema inteiro.</small></p>""")
open(p, 'w').write(s)
EOF
echo "simulado com filtros e estatistica: pronto"
