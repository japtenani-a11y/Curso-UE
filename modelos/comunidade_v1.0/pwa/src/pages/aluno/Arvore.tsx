import { useEffect, useMemo, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface No { codigo: string; titulo: string; modulo: string | null; papel: string; nivel: number; orfao: boolean; concluido: boolean; iniciado: boolean; faltam: string[]; publicado?: boolean }
interface Aresta { de: string; para: string }

const LARG = 210, ALT = 46, GX = 70, GY = 10, MARGEM = 12;
function estado(n: No): string {
  if (n.concluido) return 'concluido';
  if (n.publicado === false) return 'producao';
  if (n.faltam.length) return 'bloqueado';
  if (n.iniciado) return 'andamento';
  return 'liberado';
}
const LEGENDA: [string, string][] = [['concluido', 'Concluído'], ['andamento', 'Em andamento'], ['liberado', 'Liberado'], ['bloqueado', 'Bloqueado (falta tema mãe)'], ['producao', 'Em produção']];

// Arvore dos temas: cada coluna e um nivel; setas vao do tema mae para o filho. Clique para ver o caminho.
export function Arvore() {
  const [dados, setDados] = useState<{ nos: No[]; arestas: Aresta[] } | null>(null);
  const [sel, setSel] = useState<string | null>(null);
  const [modulo, setModulo] = useState('');
  const [modo, setModo] = useState<'grafico' | 'lista'>(() => (window.innerWidth < 720 ? 'lista' : 'grafico'));
  useEffect(() => { apiGet<{ nos: No[]; arestas: Aresta[] }>('/jornada/arvore').then(setDados).catch(() => setDados({ nos: [], arestas: [] })); }, []);

  const modulos = useMemo(() => [...new Set((dados?.nos ?? []).map((n) => n.modulo ?? 'Outros'))].sort(), [dados]);
  const { pos, largura, altura, visiveis, ligados } = useMemo(() => {
    const nos = (dados?.nos ?? []).filter((n) => !n.orfao && (!modulo || n.modulo === modulo
      || (dados?.arestas ?? []).some((a) => (a.de === n.codigo || a.para === n.codigo) && (dados?.nos.find((x) => x.codigo === (a.de === n.codigo ? a.para : a.de))?.modulo === modulo))));
    const col = new Map<number, No[]>();
    for (const n of nos) col.set(n.nivel, [...(col.get(n.nivel) ?? []), n]);
    const pos = new Map<string, { x: number; y: number }>();
    let maxL = 0;
    for (const [nivel, lista] of col) {
      lista.sort((a, b) => (a.modulo ?? '').localeCompare(b.modulo ?? '') || a.codigo.localeCompare(b.codigo));
      lista.forEach((n, i) => pos.set(n.codigo, { x: MARGEM + nivel * (LARG + GX), y: MARGEM + i * (ALT + GY) }));
      maxL = Math.max(maxL, lista.length);
    }
    const nivelMax = Math.max(0, ...nos.map((n) => n.nivel));
    // caminho do selecionado: ancestrais e descendentes
    const ligados = new Set<string>();
    if (sel && dados) {
      const sobe = (c: string) => { for (const a of dados.arestas) if (a.para === c && !ligados.has(a.de)) { ligados.add(a.de); sobe(a.de); } };
      const desce = (c: string) => { for (const a of dados.arestas) if (a.de === c && !ligados.has(a.para)) { ligados.add(a.para); desce(a.para); } };
      ligados.add(sel); sobe(sel); desce(sel);
    }
    return { pos, largura: MARGEM * 2 + (nivelMax + 1) * (LARG + GX), altura: MARGEM * 2 + maxL * (ALT + GY), visiveis: nos, ligados };
  }, [dados, modulo, sel]);

  if (!dados) return <p className="carregando">Carregando…</p>;
  const noSel = dados.nos.find((n) => n.codigo === sel);
  const orfaos = dados.nos.filter((n) => n.orfao);
  const maes = (c: string) => dados.arestas.filter((a) => a.para === c).map((a) => a.de);
  const filhos = (c: string) => dados.arestas.filter((a) => a.de === c).map((a) => a.para);
  return (
    <section className="arvore">
      <h1>Árvore de temas</h1>
      <p>Um tema só abre quando todos os seus temas mãe estão concluídos (pós-teste D0 enviado). Clique em um tema para ver o caminho até ele e o que ele libera.</p>
      <div className="painel-barra">
        <label>Módulo <select value={modulo} onChange={(e) => { setModulo(e.target.value); setSel(null); }}><option value="">todos</option>{modulos.map((m) => <option key={m}>{m}</option>)}</select></label>
        <div className="etapas" role="tablist" style={{ margin: 0 }}>
          <button type="button" className={`etapa${modo === 'grafico' ? ' atual' : ''}`} onClick={() => setModo('grafico')}>Gráfico</button>
          <button type="button" className={`etapa${modo === 'lista' ? ' atual' : ''}`} onClick={() => setModo('lista')}>Lista</button>
        </div>
      </div>
      <div className="legenda">{LEGENDA.map(([k, r]) => <span key={k}><i className={`cor-${k}`} />{r}</span>)}</div>
      {noSel && (
        <div className="cartao-app arvore-sel" role="status">
          <strong>{noSel.codigo} — {noSel.titulo}</strong>
          <p>{noSel.publicado === false ? 'Conteúdo em produção. ' : ''}{noSel.faltam.length ? `Bloqueado: falta concluir ${noSel.faltam.join(', ')}.` : noSel.concluido ? 'Concluído.' : 'Liberado.'}
            {' '}Mães: {maes(noSel.codigo).join(', ') || 'nenhuma'} · Libera: {filhos(noSel.codigo).join(', ') || 'nenhum'}</p>
          <a className="botao discreto" href={`/aluno/tema/${noSel.codigo.replace('-', '')}`}>Abrir o tema</a>
        </div>
      )}
      {modo === 'grafico' ? (
        <div className="arvore-rolagem">
          <svg width={largura} height={altura} viewBox={`0 0 ${largura} ${altura}`} role="img" aria-label="Árvore de temas">
            <defs><marker id="seta" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#8a94a6" /></marker></defs>
            {dados.arestas.map((a) => {
              const p1 = pos.get(a.de), p2 = pos.get(a.para);
              if (!p1 || !p2) return null;
              const x1 = p1.x + LARG, y1 = p1.y + ALT / 2, x2 = p2.x - 2, y2 = p2.y + ALT / 2, mx = (x1 + x2) / 2;
              const on = !sel || (ligados.has(a.de) && ligados.has(a.para));
              return <path key={a.de + a.para} d={`M${x1},${y1} C${mx},${y1} ${mx},${y2} ${x2},${y2}`} fill="none" stroke={on && sel ? '#1f4e79' : '#b8c0cc'} strokeWidth={on && sel ? 2 : 1} opacity={on ? 1 : 0.15} markerEnd="url(#seta)" />;
            })}
            {visiveis.map((n) => {
              const p = pos.get(n.codigo); if (!p) return null;
              const on = !sel || ligados.has(n.codigo);
              return (
                <g key={n.codigo} transform={`translate(${p.x},${p.y})`} opacity={on ? 1 : 0.25} className={`no ${estado(n)}${n.codigo === sel ? ' sel' : ''}`}
                  role="button" tabIndex={0} aria-label={`${n.codigo} ${n.titulo}: ${LEGENDA.find((l) => l[0] === estado(n))?.[1]}`}
                  onClick={() => setSel(n.codigo === sel ? null : n.codigo)} onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); setSel(n.codigo === sel ? null : n.codigo); } }}>
                  <rect width={LARG} height={ALT} rx={8} />
                  <text x={8} y={17} className="no-cod">{n.codigo}{n.papel === 'nuclear' ? ' · principal' : ''}</text>
                  <text x={8} y={34} className="no-tit">{n.titulo.length > 30 ? `${n.titulo.slice(0, 29)}…` : n.titulo}</text>
                  <title>{`${n.codigo} — ${n.titulo}`}</title>
                </g>
              );
            })}
          </svg>
        </div>
      ) : (
        <ul className="arvore-lista">
          {visiveis.sort((a, b) => a.nivel - b.nivel || a.codigo.localeCompare(b.codigo)).map((n) => (
            <li key={n.codigo} className={estado(n)}>
              <a href={`/aluno/tema/${n.codigo.replace('-', '')}`}><strong>{n.codigo}</strong> {n.titulo}</a>
              <small>{maes(n.codigo).length ? `requer ${maes(n.codigo).join(', ')}` : 'tema de entrada'}{filhos(n.codigo).length ? ` · libera ${filhos(n.codigo).join(', ')}` : ''}{n.faltam.length ? ` · falta ${n.faltam.join(', ')}` : ''}</small>
            </li>
          ))}
        </ul>
      )}
      {orfaos.length > 0 && !modulo && (
        <article className="cartao-app" style={{ marginTop: 16 }}>
          <h2 style={{ marginTop: 0 }}>Temas avulsos</h2>
          <p>Não dependem de outros nem liberam outros: podem ser feitos a qualquer momento.</p>
          <ul className="lista-curta">{orfaos.map((n) => <li key={n.codigo}><a href={`/aluno/tema/${n.codigo.replace('-', '')}`}>{n.codigo} — {n.titulo}</a></li>)}</ul>
        </article>
      )}
    </section>
  );
}
