import { useEffect, useMemo, useState } from 'react';
import { apiGet } from '../../lib/api.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
type Linha = Record<string, string | number | boolean | null>;
type Conjunto = 'notas' | 'avaliacoes' | 'mensagens' | 'uso' | 'questoes' | 'presenca' | 'estudo' | 'producao' | 'coleta' | 'leitura';
const ABAS: { id: 'graficos' | Conjunto; rotulo: string }[] = [
  { id: 'graficos', rotulo: 'Desempenho e evolução' }, { id: 'avaliacoes', rotulo: 'Avaliações (NPS)' },
  { id: 'notas', rotulo: 'Notas' }, { id: 'questoes', rotulo: 'Análise das questões' }, { id: 'presenca', rotulo: 'Presença' }, { id: 'estudo', rotulo: 'Estudo dirigido' }, { id: 'producao', rotulo: 'Fila de produção' }, { id: 'coleta', rotulo: 'Calibração e aplicabilidade' }, { id: 'leitura', rotulo: 'Tempo de leitura' },
  { id: 'mensagens', rotulo: 'Dúvidas e feedback' }, { id: 'uso', rotulo: 'Uso do material' },
];
const GRUPOS: { id: string; rotulo: string }[] = [
  { id: 'turma', rotulo: 'Turma (ano de entrada)' }, { id: 'especialidade', rotulo: 'Especialidade' },
  { id: 'ano', rotulo: 'Ano de residência' }, { id: 'aluno', rotulo: 'Aluno a aluno' },
];
const TESTES = ['Pré 1', 'Pré 2', 'D0', 'D+15', 'D+45', 'D+90'];
const CORES = ['#1f4e79', '#b45309', '#1d6b3a', '#7c3aed', '#a32020', '#0e7490', '#6b7280', '#be185d'];
const ESCALAS = ['conteudo', 'apresentacao', 'clareza', 'objetividade', 'adequacao', 'importancia', 'dificuldade', 'complexidade', 'tempo_gasto', 'frequencia_testes'];
const NOME_ESCALA: Record<string, string> = { conteudo: 'Qualidade', apresentacao: 'Apresentação', clareza: 'Clareza', objetividade: 'Objetividade',
  adequacao: 'Adequação', importancia: 'Importância', dificuldade: 'Dificuldade*', complexidade: 'Profundidade*', tempo_gasto: 'Tempo*', frequencia_testes: 'Freq. testes*' };

const NOME_ITEM: Record<string, string> = { tema: 'Tema (geral)', curso: 'Curso', objetivos: 'Objetivos', resumo_basico: 'Resumo básico',
  podcast_roteiro: 'Podcast', caso_base: 'Caso base', aula: 'Aula', slides: 'Slides', caso: 'Caso da aula', sintese_evidencia: 'Síntese de evidência',
  resumo: 'Resumo executivo', mapa: 'Mapa conceitual', flashcard: 'Flashcards', protocolo: 'Protocolo', checklist: 'Checklists', simulado: 'Simulados',
  teste_1: 'Pré-teste inicial', teste_2: 'Pré-teste 2', teste_3: 'Pós-teste D0', teste_4: 'Pós-teste D+15', teste_5: 'Pós-teste D+45', teste_6: 'Pós-teste D+90' };
const media = (xs: number[]) => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : null);
const fmt = (v: number | null, casas = 0) => (v === null ? '—' : v.toFixed(casas));
const rotuloGrupo = (l: Linha, g: string) => String(l[g] ?? 'não informado');

interface Serie { nome: string; valores: (number | null)[]; cor?: string; tracejado?: boolean }
function GraficoLinhas(props: { series: Serie[] }) {
  const W = 640, H = 280, E = 44, D = 16, T = 16, B = 34;
  const x = (i: number) => E + (i * (W - E - D)) / (TESTES.length - 1);
  const y = (v: number) => T + ((100 - v) * (H - T - B)) / 100;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} className="grafico" role="img" aria-label="Média de acertos por teste">
      {[0, 25, 50, 75, 100].map((v) => (
        <g key={v}><line x1={E} x2={W - D} y1={y(v)} y2={y(v)} stroke="#dde2e9" /><text x={E - 8} y={y(v) + 4} textAnchor="end" fontSize="11" fill="#4a5568">{v}%</text></g>
      ))}
      {TESTES.map((t, i) => <text key={t} x={x(i)} y={H - 12} textAnchor="middle" fontSize="11" fill="#4a5568">{t}</text>)}
      {props.series.map((s, k) => {
        const pts = s.valores.map((v, i) => (v === null ? null : [x(i), y(v)] as const));
        const d = pts.filter((p): p is readonly [number, number] => p !== null).map((p, i) => `${i ? 'L' : 'M'}${p[0]},${p[1]}`).join('');
        const cor = s.cor ?? CORES[k % CORES.length];
        return (
          <g key={s.nome}>
            <path d={d} fill="none" stroke={cor} strokeWidth={s.tracejado ? 2 : 2.5} strokeDasharray={s.tracejado ? '6 4' : undefined} />
            {pts.map((p, i) => p && <circle key={i} cx={p[0]} cy={p[1]} r={4} fill={cor}><title>{`${s.nome} · ${TESTES[i]}: ${fmt(s.valores[i] ?? null, 1)}%`}</title></circle>)}
          </g>
        );
      })}
    </svg>
  );
}

function Barras(props: { dados: { nome: string; valor: number; n: number }[]; min: number; max: number; sufixo?: string; casas?: number }) {
  const amplitude = props.max - props.min;
  return (
    <div className="barras">
      {props.dados.map((d) => {
        const zero = ((0 - props.min) / amplitude) * 100;
        const pos = ((d.valor - props.min) / amplitude) * 100;
        const esq = Math.min(zero, pos), larg = Math.abs(pos - zero);
        return (
          <div key={d.nome} className="barra-linha">
            <span className="barra-nome">{d.nome}</span>
            <span className="barra-trilho"><span className={`barra ${d.valor < 0 ? 'neg' : ''}`} style={{ left: `${esq}%`, width: `${Math.max(larg, 0.8)}%` }} /></span>
            <span className="barra-valor">{d.valor.toFixed(props.casas ?? 0)}{props.sufixo ?? ''} <small>n={d.n}</small></span>
          </div>
        );
      })}
    </div>
  );
}

function Tabela(props: { linhas: Linha[]; conjunto: Conjunto }) {
  const [busca, setBusca] = useState('');
  const cols = props.linhas[0] ? Object.keys(props.linhas[0]) : [];
  const vis = props.linhas.filter((l) => !busca || Object.values(l).some((v) => String(v ?? '').toLowerCase().includes(busca.toLowerCase())));
  return (
    <div>
      <div className="painel-barra">
        <input className="busca" placeholder="Filtrar" value={busca} onChange={(e) => setBusca(e.target.value)} aria-label="Filtrar linhas" />
        <a className="botao discreto" href={`${BASE}/painel/${props.conjunto}?formato=csv`}>Baixar CSV (planilha)</a>
        <span>{vis.length} de {props.linhas.length} linhas</span>
      </div>
      <div className="tabela-rolavel"><table className="tabela compacta">
        <thead><tr>{cols.map((c) => <th key={c}>{c}</th>)}</tr></thead>
        <tbody>{vis.slice(0, 500).map((l, i) => (
          <tr key={i}>{cols.map((c) => {
            const v = l[c];
            const s = v === null ? '' : typeof v === 'boolean' ? (v ? 'sim' : 'não') : /_em$|^primeiro$|^ultimo$/.test(c) && v ? new Date(String(v)).toLocaleString('pt-BR') : String(v);
            return <td key={c} title={s.length > 60 ? s : undefined}>{s.length > 120 ? `${s.slice(0, 120)}…` : s}</td>;
          })}</tr>))}</tbody>
      </table></div>
      {vis.length > 500 && <p>Mostrando 500 linhas; baixe o CSV para ver todas.</p>}
    </div>
  );
}

// Painel de acompanhamento e pesquisa (coordenacao, curadores e pesquisadores).
export function Painel() {
  const [aba, setAba] = useState<'graficos' | Conjunto>('graficos');
  const [dados, setDados] = useState<Partial<Record<Conjunto, Linha[]>>>({});
  const [papel, setPapel] = useState<string | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [grupo, setGrupo] = useState('turma');
  const [tema, setTema] = useState('');

  useEffect(() => {
    const precisa: Conjunto[] = aba === 'graficos' ? ['notas', 'avaliacoes'] : [aba];
    for (const c of precisa) {
      if (dados[c]) continue;
      apiGet<{ papel: string; linhas: Linha[] }>(`/painel/${c}`)
        .then((d) => { setPapel(d.papel); setDados((x) => ({ ...x, [c]: d.linhas })); })
        .catch(() => setErro('Sem acesso ao painel ou falha ao carregar.'));
    }
  }, [aba]);

  const notas = dados.notas ?? [];
  const avals = dados.avaliacoes ?? [];
  const temas = useMemo(() => [...new Set(notas.map((n) => String(n.tema)))].sort(), [notas]);

  const evolucao = useMemo(() => {
    const filtradas = notas.filter((n) => !tema || n.tema === tema);
    const g = new Map<string, number[][]>();
    for (const n of filtradas) {
      const k = rotuloGrupo(n, grupo);
      const arr = g.get(k) ?? [[], [], [], [], [], []];
      arr[Number(n.teste_num) - 1]?.push(Number(n.pct));
      g.set(k, arr);
    }
    return [...g.entries()].sort((a, b) => a[0].localeCompare(b[0], 'pt-BR'))
      .map(([nome, arr]) => ({ nome, valores: arr.map(media), n: Math.max(...arr.map((a) => a.length)) }));
  }, [notas, grupo, tema]);

  const nps = useMemo(() => {
    const g = new Map<string, number[]>();
    for (const a of avals) {
      if (a.nps === null || (tema && a.tema !== tema)) continue;
      const f = String(a.ferramenta); g.set(f, [...(g.get(f) ?? []), Number(a.nps)]);
    }
    return [...g.entries()].map(([nome, xs]) => ({
      nome: NOME_ITEM[nome] ?? nome, n: xs.length, valor: (100 * (xs.filter((x) => x >= 9).length - xs.filter((x) => x <= 6).length)) / xs.length,
    })).sort((a, b) => b.valor - a.valor);
  }, [avals, tema]);

  const escalas = useMemo(() => ESCALAS.map((k) => {
    const xs = avals.filter((a) => (!tema || a.tema === tema) && a[k] !== null).map((a) => Number(a[k]));
    return { nome: NOME_ESCALA[k] ?? k, valor: media(xs) ?? 0, n: xs.length };
  }).filter((e) => e.n > 0), [avals, tema]);

  const referencias = useMemo(() => {
    const f = notas.filter((n) => !tema || n.tema === tema);
    const por = (k: string) => [1, 2, 3, 4, 5, 6].map((t) => media(f.filter((n) => Number(n.teste_num) === t && n[k] !== null).map((n) => Number(n[k]))));
    return [{ nome: 'Média de todos', valores: por('pct'), cor: '#9ca3af', tracejado: true },
            { nome: 'Nota esperada (média)', valores: por('esperado'), cor: '#b45309', tracejado: true }];
  }, [notas, tema]);

  if (erro) return <p role="alert">{erro}</p>;
  const mostrar = evolucao.slice(0, grupo === 'aluno' ? 8 : 12);
  return (
    <section className="painel">
      <h1>Painel de acompanhamento e pesquisa</h1>
      {papel === 'pesquisador' && <p className="faixa-aviso">Você vê os alunos pelo código de participante (sem nome).</p>}
      <div className="etapas" role="tablist">
        {ABAS.map((a) => <button key={a.id} type="button" role="tab" aria-selected={aba === a.id} className={`etapa${aba === a.id ? ' atual' : ''}`} onClick={() => setAba(a.id)}>{a.rotulo}</button>)}
      </div>
      {aba === 'graficos' && (
        <div>
          <div className="painel-barra">
            <label>Agrupar por <select value={grupo} onChange={(e) => setGrupo(e.target.value)}>{GRUPOS.map((g) => <option key={g.id} value={g.id}>{g.rotulo}</option>)}</select></label>
            <label>Tema <select value={tema} onChange={(e) => setTema(e.target.value)}><option value="">todos</option>{temas.map((t) => <option key={t}>{t}</option>)}</select></label>
          </div>
          {!dados.notas ? <p className="carregando">Carregando…</p> : notas.length === 0 ? <p>Ainda não há testes respondidos.</p> : (
            <article className="cartao-app">
              <h2 style={{ marginTop: 0 }}>Evolução da média de acertos: pré-testes → pós-testes</h2>
              <GraficoLinhas series={[...mostrar, ...referencias]} />
              <div className="legenda">{mostrar.map((s, k) => <span key={s.nome}><i style={{ background: CORES[k % CORES.length] }} />{s.nome}</span>)}
                {referencias.map((r) => <span key={r.nome}><i style={{ background: r.cor, opacity: 0.7 }} />{r.nome} (tracejada)</span>)}</div>
              {evolucao.length > mostrar.length && <p><small>O gráfico mostra os {mostrar.length} primeiros grupos; a tabela abaixo tem todos.</small></p>}
              <div className="tabela-rolavel"><table className="tabela compacta">
                <thead><tr><th>{GRUPOS.find((g) => g.id === grupo)?.rotulo}</th><th>n</th>{TESTES.map((t) => <th key={t}>{t}</th>)}<th title="D0 menos pré-teste inicial">Ganho</th><th title="D+90 menos D0">Retenção</th></tr></thead>
                <tbody>{evolucao.map((s) => {
                  const [p1, , d0, , , d90] = s.valores;
                  return (<tr key={s.nome}><td>{s.nome}</td><td>{s.n}</td>{s.valores.map((v, i) => <td key={i}>{fmt(v)}</td>)}
                    <td>{p1 !== null && p1 !== undefined && d0 !== null && d0 !== undefined ? fmt(d0 - p1) : '—'}</td>
                    <td>{d0 !== null && d0 !== undefined && d90 !== null && d90 !== undefined ? fmt(d90 - d0) : '—'}</td></tr>);
                })}</tbody>
              </table></div>
            </article>
          )}
          {dados.avaliacoes && (
            <div className="cartoes" style={{ marginTop: 16 }}>
              <article className="cartao-app"><h2 style={{ marginTop: 0 }}>NPS por peça e teste</h2>
                <p><small>% de notas 9–10 menos % de notas 0–6 (de −100 a +100).</small></p>
                {nps.length ? <Barras dados={nps} min={-100} max={100} /> : <p>Sem avaliações ainda.</p>}</article>
              <article className="cartao-app"><h2 style={{ marginTop: 0 }}>Satisfação (média de 1 a 5)</h2>
                <p><small>* escalas de dosagem: 3 = adequado.</small></p>
                {escalas.length ? <Barras dados={escalas} min={0} max={5} casas={1} /> : <p>Sem avaliações ainda.</p>}</article>
            </div>
          )}
        </div>
      )}
      {aba !== 'graficos' && (dados[aba] ? <Tabela linhas={dados[aba] ?? []} conjunto={aba} /> : <p className="carregando">Carregando…</p>)}
    </section>
  );
}
