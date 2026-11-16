import { useEffect, useMemo, useRef, useState } from 'react';
import type { PointerEvent as RPointerEvent } from 'react';
import { apiGet } from '../../lib/api.js';

// Árvore dos temas (v2): três vistas sobre a mesma regra de liberação.
// Mapa: todos os temas em níveis, com arrastar e zoom. Foco: um tema no centro, o que ele exige e o que libera.
// Linha do curso: cada aula de quinta e os temas que abrem logo depois dela.
interface No {
  codigo: string; titulo: string; modulo: string | null; papel: string; nivel: number; orfao: boolean;
  concluido: boolean; iniciado: boolean; faltam: string[]; publicado?: boolean;
  ordem?: number | null; grau?: number | null; abre_apos?: number | null;
}
interface Aresta { de: string; para: string }
type Vista = 'mapa' | 'foco' | 'linha';
interface G {
  nos: No[]; arestas: Aresta[]; por: Map<string, No>; maes: Map<string, string[]>; filhos: Map<string, string[]>;
  grupos: Map<number, string[]>; nuc: No[]; ordem: string[]; cols: string[][]; xS: number; soltos: string[];
  pos: Map<string, { x: number; y: number }>; larg: number; alt: number;
}
type Estado = 'concluido' | 'andamento' | 'liberado' | 'bloqueado' | 'producao';

const W = 184, H = 58, PX = W + 90, PY = H + 14, TOPO = 46, MARG = 36;
const ROTULO: Record<Estado, string> = { concluido: 'Concluído', andamento: 'Em andamento', liberado: 'Liberado', bloqueado: 'Bloqueado', producao: 'Em produção' };
const ICONE: Record<Estado, string> = { concluido: '✓', andamento: '◐', liberado: '', bloqueado: '–', producao: '…' };
const PAPEL: Record<string, string> = { nuclear: 'Principal', complementar: 'Recomendado', eletivo: 'Opcional' };
const link = (c: string) => `/aluno/tema/${c.replace('-', '')}`;
function estado(n: No): Estado {
  if (n.concluido) return 'concluido';
  if (n.publicado === false) return 'producao';
  if (n.faltam.length) return 'bloqueado';
  if (n.iniciado) return 'andamento';
  return 'liberado';
}
function quebra(s: string, n: number): [string, string] {
  const l: [string, string] = ['', '']; let i = 0;
  for (const p of s.split(/\s+/)) {
    if (`${l[i]} ${p}`.trim().length > n) { if (i === 1) { l[1] = `${l[1]} ${p}`.trim(); break; } i = 1; }
    l[i] = `${l[i]} ${p}`.trim();
  }
  if (l[1].length > n || `${l[0]} ${l[1]}`.length < s.length) l[1] = `${l[1].slice(0, n - 1).trimEnd()}…`;
  return l;
}
function fecho(ini: string, mapa: Map<string, string[]>): Set<string> {
  const s = new Set<string>(); const p = [...(mapa.get(ini) ?? [])];
  while (p.length) { const x = p.pop()!; if (s.has(x)) continue; s.add(x); p.push(...(mapa.get(x) ?? [])); }
  return s;
}
function quando(n: No): string {
  if (n.papel === 'nuclear' && n.ordem) return `aula ${n.ordem}`;
  if (n.abre_apos) return `após aula ${n.abre_apos}`;
  return n.orfao ? 'avulso' : 'livre';
}

export function Arvore() {
  const [dados, setDados] = useState<{ nos: No[]; arestas: Aresta[] } | null>(null);
  const [vista, setVista] = useState<Vista>(() => (window.innerWidth < 760 ? 'linha' : 'mapa'));
  const [sel, setSel] = useState<string | null>(null);
  const [foco, setFoco] = useState<string | null>(null);
  const [hist, setHist] = useState<string[]>([]);
  useEffect(() => { apiGet<{ nos: No[]; arestas: Aresta[] }>('/jornada/arvore').then(setDados).catch(() => setDados({ nos: [], arestas: [] })); }, []);

  const g = useMemo<G>(() => {
    const nos = dados?.nos ?? [], arestas = dados?.arestas ?? [];
    const por = new Map(nos.map((n) => [n.codigo, n]));
    const maes = new Map<string, string[]>(), filhos = new Map<string, string[]>();
    nos.forEach((n) => { maes.set(n.codigo, []); filhos.set(n.codigo, []); });
    arestas.forEach((a) => { maes.get(a.para)?.push(a.de); filhos.get(a.de)?.push(a.para); });
    // ordem do curso: livres, depois cada aula seguida do que ela libera
    const nuc = nos.filter((n) => n.papel === 'nuclear').sort((a, b) => (a.ordem ?? 99) - (b.ordem ?? 99));
    const grupos = new Map<number, string[]>([[0, []]]); nuc.forEach((n) => grupos.set(n.ordem ?? 0, []));
    nos.filter((n) => n.papel !== 'nuclear').forEach((n) => { const k = n.abre_apos ?? 0; if (!grupos.has(k)) grupos.set(k, []); grupos.get(k)!.push(n.codigo); });
    grupos.forEach((l) => l.sort((a, b) => (por.get(a)!.papel === por.get(b)!.papel ? 0 : por.get(a)!.papel === 'complementar' ? -1 : 1) || a.localeCompare(b)));
    const ordem: string[] = [...(grupos.get(0) ?? [])]; nuc.forEach((n) => ordem.push(n.codigo, ...(grupos.get(n.ordem ?? 0) ?? [])));
    // layout do mapa: coluna = nível; ordem na coluna por baricentro (menos cruzamentos)
    const soltos = nos.filter((n) => n.orfao).map((n) => n.codigo);
    const cols: string[][] = [];
    nos.filter((n) => !n.orfao).forEach((n) => { (cols[n.nivel] ||= []).push(n.codigo); });
    cols.forEach((c) => c.sort((a, b) => ordem.indexOf(a) - ordem.indexOf(b)));
    const idx = new Map<string, number>(); const reidx = () => cols.forEach((c) => c.forEach((x, i) => idx.set(x, i))); reidx();
    const bari = (c: string, viz: Map<string, string[]>) => { const v = (viz.get(c) ?? []).filter((x) => idx.has(x)); return v.length ? v.reduce((s, x) => s + idx.get(x)!, 0) / v.length : idx.get(c)!; };
    for (let it = 0; it < 8; it++) {
      for (let i = 1; i < cols.length; i++) { cols[i]?.sort((a, b) => bari(a, maes) - bari(b, maes)); reidx(); }
      for (let i = cols.length - 2; i >= 0; i--) { cols[i]?.sort((a, b) => bari(a, filhos) - bari(b, filhos)); reidx(); }
    }
    const alt = Math.max(1, ...cols.map((c) => c?.length ?? 0), Math.ceil(soltos.length / 2));
    const pos = new Map<string, { x: number; y: number }>();
    cols.forEach((c, i) => { const d = (alt - (c?.length ?? 0)) * PY / 2; c?.forEach((x, j) => pos.set(x, { x: MARG + i * PX, y: TOPO + d + j * PY })); });
    const xS = MARG + cols.length * PX + 30;
    soltos.forEach((x, j) => pos.set(x, { x: xS + (j % 2) * (W + 14), y: TOPO + Math.floor(j / 2) * PY }));
    return { nos, arestas, por, maes, filhos, grupos, nuc, ordem, cols, xS, soltos, pos, larg: xS + 2 * W + 60, alt: TOPO + alt * PY + 30 };
  }, [dados]);

  function irFoco(c: string) { if (foco && foco !== c) setHist((h) => [...h.slice(-20), foco]); setFoco(c); setSel(c); setVista('foco'); }
  const total = g.nos.length, feitos = g.nos.filter((n) => n.concluido).length;

  if (!dados) return <p className="carregando">Carregando…</p>;
  if (!total) return <section className="arv2"><h1>Árvore de temas</h1><p>Não foi possível carregar a árvore agora. Tente de novo em instantes.</p></section>;
  const noSel = sel ? g.por.get(sel) : undefined;
  return (
    <section className="arv2">
      <header className="arv2-topo">
        <div>
          <h1>Árvore de temas</h1>
          <p>Um tema abre quando todos os seus temas mãe estão concluídos (pós-teste D0 enviado).</p>
        </div>
        <div className="arv2-progresso" aria-label={`${feitos} de ${total} temas concluídos`}>
          <strong>{feitos}</strong> de {total} concluídos
          <span className="arv2-barra" aria-hidden="true"><i style={{ width: `${(100 * feitos) / total}%` }} /></span>
        </div>
      </header>
      <div className="arv2-abas" role="tablist" aria-label="Vistas da árvore">
        {(['mapa', 'foco', 'linha'] as Vista[]).map((v) => (
          <button key={v} role="tab" type="button" aria-selected={vista === v}
            onClick={() => { if (v === 'foco' && !foco) setFoco(sel ?? g.ordem.find((c) => estado(g.por.get(c)!) === 'liberado' || estado(g.por.get(c)!) === 'andamento') ?? g.ordem[0] ?? null); setVista(v); }}>
            {v === 'mapa' ? 'Mapa' : v === 'foco' ? 'Foco' : 'Linha do curso'}
          </button>
        ))}
      </div>
      <Legenda />
      {vista === 'mapa' && <Mapa g={g} sel={sel} setSel={setSel} irFoco={irFoco} />}
      {vista === 'foco' && foco && <Foco g={g} c={foco} hist={hist} voltar={() => { const h = [...hist]; const c = h.pop(); setHist(h); if (c) { setFoco(c); setSel(c); } }} irFoco={irFoco} />}
      {vista === 'linha' && <Linha g={g} irFoco={irFoco} />}
      {vista === 'mapa' && noSel && <Detalhe n={noSel} g={g} irFoco={irFoco} fechar={() => setSel(null)} />}
    </section>
  );
}


function Legenda() {
  return (
    <div className="arv2-legenda" aria-hidden="true">
      {(Object.keys(ROTULO) as Estado[]).map((e) => <span key={e}><i className={`e-${e}`}>{ICONE[e]}</i>{ROTULO[e]}</span>)}
      <span><b>AULA N</b> tema principal</span>
    </div>
  );
}

function Mapa({ g, sel, setSel, irFoco }: { g: G; sel: string | null; setSel: (c: string | null) => void; irFoco: (c: string) => void }) {
  const palco = useRef<HTMLDivElement>(null);
  const [v, setV] = useState({ x: 0, y: 0, k: 1 });
  const [hover, setHover] = useState<string | null>(null);
  const ptrs = useRef(new Map<number, { x: number; y: number }>());
  const arr = useRef<{ x: number; y: number; vx: number; vy: number; alvo: string | null; moveu: boolean; pinca?: { d: number; k: number } } | null>(null);
  const ajustar = () => { const r = palco.current?.getBoundingClientRect(); if (!r) return; const k = Math.max(0.12, Math.min(1, Math.min(r.width / g.larg, r.height / g.alt))); setV({ k, x: (r.width - g.larg * k) / 2, y: (r.height - g.alt * k) / 2 }); };
  useEffect(ajustar, [g]);
  useEffect(() => {
    const el = palco.current; if (!el) return;
    const roda = (e: WheelEvent) => { e.preventDefault(); const r = el.getBoundingClientRect(); zoom(e.deltaY < 0 ? 1.15 : 1 / 1.15, e.clientX - r.left, e.clientY - r.top); };
    el.addEventListener('wheel', roda, { passive: false }); return () => el.removeEventListener('wheel', roda);
  });
  function zoom(f: number, cx?: number, cy?: number) {
    const r = palco.current!.getBoundingClientRect(); const x0 = cx ?? r.width / 2, y0 = cy ?? r.height / 2;
    setV((v0) => { const k = Math.max(0.12, Math.min(2.4, v0.k * f)); return { k, x: x0 - (x0 - v0.x) * (k / v0.k), y: y0 - (y0 - v0.y) * (k / v0.k) }; });
  }
  function centrar(c: string) { const p = g.pos.get(c), r = palco.current?.getBoundingClientRect(); if (!p || !r) return; const k = Math.max(v.k, 0.85); setV({ k, x: r.width / 2 - (p.x + W / 2) * k, y: r.height / 2 - (p.y + H / 2) * k }); }
  const down = (e: RPointerEvent<HTMLDivElement>) => {
    if ((e.target as Element).closest('.arv2-zoom')) return;
    e.currentTarget.setPointerCapture(e.pointerId); ptrs.current.set(e.pointerId, { x: e.clientX, y: e.clientY });
    const alvo = (e.target as Element).closest('[data-c]')?.getAttribute('data-c') ?? null;
    if (ptrs.current.size === 1) arr.current = { x: e.clientX, y: e.clientY, vx: v.x, vy: v.y, alvo, moveu: false };
    if (ptrs.current.size === 2 && arr.current) { const [a, b] = [...ptrs.current.values()] as [{ x: number; y: number }, { x: number; y: number }]; arr.current.pinca = { d: Math.hypot(a.x - b.x, a.y - b.y), k: v.k }; arr.current.moveu = true; }
  };
  const move = (e: RPointerEvent<HTMLDivElement>) => {
    if (!ptrs.current.has(e.pointerId) || !arr.current) return;
    ptrs.current.set(e.pointerId, { x: e.clientX, y: e.clientY });
    const a0 = arr.current;
    if (a0.pinca && ptrs.current.size === 2) { const [a, b] = [...ptrs.current.values()] as [{ x: number; y: number }, { x: number; y: number }]; const r = palco.current!.getBoundingClientRect(); const alvo = a0.pinca.k * Math.hypot(a.x - b.x, a.y - b.y) / a0.pinca.d; zoom(alvo / v.k, (a.x + b.x) / 2 - r.left, (a.y + b.y) / 2 - r.top); return; }
    const dx = e.clientX - a0.x, dy = e.clientY - a0.y; if (Math.abs(dx) + Math.abs(dy) > 4) a0.moveu = true;
    if (a0.moveu) setV((v0) => ({ ...v0, x: a0.vx + dx, y: a0.vy + dy }));
  };
  const up = () => { const a0 = arr.current; ptrs.current.clear(); arr.current = null; if (a0 && !a0.moveu) setSel(a0.alvo && a0.alvo !== sel ? a0.alvo : null); };

  const foco = sel ?? hover;
  const anc = foco ? fecho(foco, g.maes) : null, des = foco ? fecho(foco, g.filhos) : null;
  const papel = (c: string) => (!foco ? '' : c === foco ? ' sel' : anc!.has(c) ? ' anc' : des!.has(c) ? ' desc' : ' apagado');
  return (
    <div className={`arv2-palco${v.k < 0.5 ? ' longe' : ''}`} ref={palco} onPointerDown={down} onPointerMove={move} onPointerUp={up} onPointerCancel={up} onPointerLeave={() => setHover(null)}>
      <svg width="100%" height="100%" role="img" aria-label="Mapa dos temas: cada seta vai do tema mãe ao tema que ele libera">
        <defs>
          {[['s', 'var(--cut-line-strong)'], ['sa', 'var(--cut-correct)'], ['sd', 'var(--cut-incorrect)']].map(([id, cor]) => (
            <marker key={id} id={`arv2-${id}`} viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill={cor} /></marker>
          ))}
        </defs>
        <g transform={`translate(${v.x},${v.y}) scale(${v.k})`}>
          {g.cols.map((c, i) => (
            <g key={i}>
              {i % 2 === 1 && <rect x={MARG + i * PX - 22} y={0} width={W + 44} height={g.alt} rx={14} className="arv2-banda" />}
              <text x={MARG + i * PX} y={26} className="arv2-faixa">{i === 0 ? 'ENTRADA' : `NÍVEL ${i}`} · {c?.length ?? 0}</text>
            </g>
          ))}
          {g.soltos.length > 0 && <text x={g.xS} y={26} className="arv2-faixa">AVULSOS · {g.soltos.length}</text>}
          {g.arestas.map((a) => {
            const p1 = g.pos.get(a.de), p2 = g.pos.get(a.para); if (!p1 || !p2) return null;
            const x1 = p1.x + W, y1 = p1.y + H / 2, x2 = p2.x - 3, y2 = p2.y + H / 2, mx = (x1 + x2) / 2;
            let cls = 'arv2-aresta', mk = 's';
            if (foco) {
              if (anc!.has(a.de) && (anc!.has(a.para) || a.para === foco)) { cls += ' anc'; mk = 'sa'; }
              else if (des!.has(a.para) && (des!.has(a.de) || a.de === foco)) { cls += ' desc'; mk = 'sd'; }
              else cls += ' apagado';
            }
            return <path key={a.de + a.para} d={`M${x1},${y1} C${mx},${y1} ${mx},${y2} ${x2},${y2}`} className={cls} markerEnd={`url(#arv2-${mk})`} />;
          })}
          {g.nos.map((n) => {
            const p = g.pos.get(n.codigo); if (!p) return null;
            const e = estado(n), [l1, l2] = quebra(n.titulo, 29);
            return (
              <g key={n.codigo} data-c={n.codigo} transform={`translate(${p.x},${p.y})`} className={`arv2-no e-${e}${n.papel === 'nuclear' ? ' p' : ''}${papel(n.codigo)}`}
                role="button" tabIndex={0} aria-label={`${n.codigo} ${n.titulo}: ${ROTULO[e]}, ${quando(n)}`}
                onPointerEnter={(ev) => { if (ev.pointerType === 'mouse') setHover(n.codigo); }} onPointerLeave={() => setHover(null)}
                onKeyDown={(ev) => { if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); setSel(n.codigo === sel ? null : n.codigo); } }}
                onDoubleClick={() => irFoco(n.codigo)}>
                <rect width={W} height={H} rx={9} />
                <text x={11} y={18} className="cod">{n.codigo}</text>
                <text x={56} y={18} className="qd">{n.papel === 'nuclear' && n.ordem ? `AULA ${n.ordem}` : n.abre_apos ? `após aula ${n.abre_apos}` : ''}</text>
                {ICONE[e] && <text x={W - 12} y={18} textAnchor="middle" className="ic">{ICONE[e]}</text>}
                <text x={11} y={35} className="tit">{l1}</text>
                <text x={11} y={49} className="tit">{l2}</text>
                <text x={W / 2} y={H / 2 + 9} textAnchor="middle" className="grande">{n.codigo.replace('T-', '')}</text>
              </g>
            );
          })}
        </g>
      </svg>
      <div className="arv2-zoom">
        <button type="button" aria-label="Aproximar" onClick={() => zoom(1.3)}>+</button>
        <button type="button" aria-label="Afastar" onClick={() => zoom(1 / 1.3)}>−</button>
        <button type="button" aria-label="Ver o mapa inteiro" onClick={ajustar}>⤢</button>
        {sel && <button type="button" aria-label="Centralizar o tema escolhido" onClick={() => centrar(sel)}>◎</button>}
      </div>
    </div>
  );
}

function Detalhe({ n, g, irFoco, fechar }: { n: No; g: G; irFoco: (c: string) => void; fechar: () => void }) {
  const e = estado(n);
  return (
    <div className="arv2-detalhe" role="status">
      <div className="arv2-detalhe-t">
        <span className="arv2-rot">{n.modulo ?? ''}</span>
        <strong>{n.codigo} — {n.titulo}</strong>
        <span className="arv2-meta">{PAPEL[n.papel] ?? n.papel} · {quando(n)} · {ROTULO[e]}{n.faltam.length ? `: falta concluir ${n.faltam.join(', ')}` : ''}</span>
        <span className="arv2-meta">Precisa antes: {(g.maes.get(n.codigo) ?? []).join(', ') || 'nada'} · Libera: {fecho(n.codigo, g.filhos).size} temas</span>
      </div>
      <div className="arv2-botoes">
        <a className="arv2-btn prim" href={link(n.codigo)}>Abrir o tema</a>
        <button type="button" className="arv2-btn" onClick={() => irFoco(n.codigo)}>Ver em foco</button>
        <button type="button" className="arv2-btn" onClick={fechar}>Fechar</button>
      </div>
    </div>
  );
}

function Cartao({ n, lado, onClick }: { n: No; lado?: 'anc' | 'desc'; onClick: () => void }) {
  const e = estado(n);
  return (
    <button type="button" className={`arv2-cartao e-${e}${n.papel === 'nuclear' ? ' p' : ''}${lado ? ` ${lado}` : ''}`} onClick={onClick} title={`${n.codigo} — ${n.titulo}`}>
      <span className="cc">{n.codigo} <small>{quando(n)}</small>{ICONE[e] && <i aria-hidden="true">{ICONE[e]}</i>}</span>
      <span className="ct">{n.titulo}</span>
      <span className="cm">{PAPEL[n.papel] ?? n.papel} · {ROTULO[e]}</span>
    </button>
  );
}

function Foco({ g, c, hist, voltar, irFoco }: { g: G; c: string; hist: string[]; voltar: () => void; irFoco: (c: string) => void }) {
  const n = g.por.get(c); if (!n) return null;
  const dist = (mapa: Map<string, string[]>) => { const d = new Map<string, number>(); let fr = [c], k = 0; while (fr.length && k < 2) { k++; const nx: string[] = []; fr.forEach((x) => (mapa.get(x) ?? []).forEach((y) => { if (!d.has(y) && y !== c) { d.set(y, k); nx.push(y); } })); fr = nx; } return d; };
  const up = dist(g.maes), dn = dist(g.filhos);
  const ord = (a: string, b: string) => g.ordem.indexOf(a) - g.ordem.indexOf(b);
  const col = (d: Map<string, number>, k: number) => [...d].filter(([, v]) => v === k).map(([x]) => x).sort(ord);
  const anc = fecho(c, g.maes), e = estado(n);
  const coluna = (titulo: string, lista: string[], lado: 'anc' | 'desc', vazio: string) => (
    <div className="arv2-fcol"><span className="arv2-rot">{titulo}</span>
      {lista.length ? lista.map((x) => <Cartao key={x} n={g.por.get(x)!} lado={lado} onClick={() => irFoco(x)} />) : <p className="arv2-vazio">{vazio}</p>}
    </div>
  );
  return (
    <div className="arv2-foco">
      <div className="arv2-foco-barra">
        <button type="button" className="arv2-btn" onClick={voltar} disabled={!hist.length}>← Voltar</button>
        <span className="arv2-meta">{hist.slice(-4).join(' › ')}{hist.length ? ' › ' : ''}<b>{c}</b></span>
      </div>
      <div className="arv2-foco-grade">
        {col(up, 2).length > 0 && coluna('2 passos antes', col(up, 2), 'anc', '')}
        {coluna('Precisa antes', col(up, 1), 'anc', 'Nenhum tema mãe: abre livre.')}
        <div className="arv2-fcol centro">
          <article className={`arv2-alvo e-${e}`}>
            <span className="arv2-rot">{n.modulo ?? ''}</span>
            <h2>{n.codigo} — {n.titulo}</h2>
            <p className="arv2-meta">{PAPEL[n.papel] ?? n.papel} · {quando(n)} · <b>{ROTULO[e]}</b>{n.faltam.length ? ` — falta concluir ${n.faltam.join(', ')}` : ''}</p>
            <div className="arv2-num">
              <div><b>{anc.size}</b><span>temas antes</span></div>
              <div><b>{fecho(c, g.filhos).size}</b><span>libera</span></div>
              <div><b>{n.grau ?? '—'}</b><span>grau</span></div>
            </div>
            {anc.size > 0 && (
              <details><summary>Ordem de estudo até aqui ({anc.size})</summary>
                <ol>{[...anc].sort(ord).map((x) => <li key={x}><button type="button" onClick={() => irFoco(x)}>{x} — {g.por.get(x)?.titulo}</button> {g.por.get(x)?.concluido ? '✓' : ''}</li>)}</ol>
              </details>
            )}
            <a className="arv2-btn prim" href={link(c)}>Abrir o tema</a>
          </article>
        </div>
        {coluna('Libera', col(dn, 1), 'desc', 'Não libera outros temas.')}
        {col(dn, 2).length > 0 && coluna('2 passos depois', col(dn, 2), 'desc', '')}
      </div>
    </div>
  );
}

function Linha({ g, irFoco }: { g: G; irFoco: (c: string) => void }) {
  const passos = [{ n: 0, c: null as string | null }, ...g.nuc.map((x) => ({ n: x.ordem ?? 0, c: x.codigo }))];
  const mx = Math.max(1, ...[...g.grupos.values()].map((l) => l.length));
  const ir = (n: number) => document.getElementById(`arv2-aula-${n}`)?.scrollIntoView({ behavior: 'smooth', inline: 'start', block: 'nearest' });
  return (
    <div className="arv2-linha">
      <div className="arv2-barras" aria-label="Quantos temas cada aula libera">
        {passos.map(({ n, c }) => {
          const l = g.grupos.get(n) ?? [], feita = c ? g.por.get(c)?.concluido : true;
          return <button key={n} type="button" title={`${n ? `Aula ${n}` : 'Desde o início'}: libera ${l.length}`} onClick={() => ir(n)} className={feita ? 'feita' : ''}>
            <i style={{ height: `${4 + (36 * l.length) / mx}px` }} /><small>{n || '•'}</small></button>;
        })}
      </div>
      <div className="arv2-trilho">
        {passos.map(({ n, c }) => {
          const l = g.grupos.get(n) ?? [];
          if (n && !l.length && !c) return null;
          return (
            <section key={n} id={`arv2-aula-${n}`} className={`arv2-aula${n && !l.length ? ' so' : ''}`}>
              <header><b>{n ? `Aula ${n}` : 'Desde o início'}</b><span>{l.length ? `+${l.length} temas` : ''}</span></header>
              {c && <Cartao n={g.por.get(c)!} onClick={() => irFoco(c)} />}
              {l.length > 0 && <span className="arv2-sep">{n ? 'Abre depois desta aula' : 'Livres para começar'}</span>}
              {l.map((x) => <Cartao key={x} n={g.por.get(x)!} onClick={() => irFoco(x)} />)}
            </section>
          );
        })}
      </div>
    </div>
  );
}
