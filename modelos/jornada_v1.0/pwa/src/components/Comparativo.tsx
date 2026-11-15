import { useEffect, useState } from 'react';
import { apiGet } from '../lib/api.js';

export interface LinhaComparativo { teste_num: number; nota: string | null; esperada: string | null; media_todos: string | null; n_todos: number;
  media_subgrupo: string | null; n_subgrupo: number; ano: string | null; especialidade: string | null }

const TESTES = ['Pré 1', 'Pré 2', 'D0', 'D+15', 'D+45', 'D+90'];
const NOMES = ['', 'pré-teste inicial', 'pré-teste 2', 'pós-teste D0', 'pós-teste D+15', 'pós-teste D+45', 'pós-teste D+90'];
export const SERIES = [
  { chave: 'nota', rotulo: 'Sua nota', cor: '#1f4e79', tracejado: false },
  { chave: 'esperada', rotulo: 'Nota esperada para o seu perfil', cor: '#b45309', tracejado: true },
  { chave: 'media_todos', rotulo: 'Média de todos', cor: '#6b7280', tracejado: false },
  { chave: 'media_subgrupo', rotulo: 'Média do seu subgrupo', cor: '#1d6b3a', tracejado: false },
] as const;
const num = (v: string | null | undefined) => (v === null || v === undefined ? null : Number(v));
const fmt = (v: number | null) => (v === null ? '—' : `${v.toFixed(0)}%`);

// Depois do gabarito: como foi este teste frente ao esperado e aos colegas.
export function ComparativoTeste(props: { tema: string; teste: number }) {
  const [l, setL] = useState<LinhaComparativo | null | undefined>(undefined);
  useEffect(() => {
    apiGet<{ linhas: LinhaComparativo[] }>(`/jornada/comparativo?tema=${props.tema.replace('-', '')}`)
      .then((d) => setL(d.linhas.find((x) => x.teste_num === props.teste) ?? null)).catch(() => setL(null));
  }, [props.tema, props.teste]);
  if (!l) return null;
  const nota = num(l.nota), esp = num(l.esperada);
  const dif = nota !== null && esp !== null ? nota - esp : null;
  const sub = [l.ano, l.especialidade].filter(Boolean).join(' · ');
  return (
    <div className="cartao-app comparativo">
      <h3 style={{ marginTop: 0 }}>Como foi o seu {NOMES[props.teste]}</h3>
      <div className="comparativo-barras">
        {SERIES.map((s) => {
          const v = num(l[s.chave]);
          const n = s.chave === 'media_todos' ? l.n_todos : s.chave === 'media_subgrupo' ? l.n_subgrupo : null;
          return (
            <div key={s.chave} className="cmp-linha">
              <span className="cmp-nome">{s.rotulo}{s.chave === 'media_subgrupo' && sub ? ` (${sub})` : ''}</span>
              <span className="barra-trilho"><span className="barra" style={{ left: 0, width: `${v ?? 0}%`, background: s.cor, opacity: s.tracejado ? 0.75 : 1 }} /></span>
              <span className="cmp-valor">{v === null && n !== null && n < 3 ? <small>aguardando 3 alunos</small> : fmt(v)}</span>
            </div>
          );
        })}
      </div>
      {dif !== null && (
        <p className={dif >= 0 ? 'cmp-msg ok' : 'cmp-msg'}>
          {dif >= 5 ? `Você ficou ${dif.toFixed(0)} pontos acima do esperado para o seu perfil.`
            : dif <= -5 ? `Você ficou ${Math.abs(dif).toFixed(0)} pontos abaixo do esperado para o seu perfil. Vale rever o gabarito comentado e o material indicado.`
            : 'Você ficou dentro do esperado para o seu perfil.'}
        </p>
      )}
      <p><small>A nota esperada vem do grau de dificuldade de cada questão ajustado ao seu ano (uma questão média para o R1 é fácil para o R2). Médias de grupo aparecem quando há pelo menos 3 alunos.</small></p>
    </div>
  );
}

// Grafico de evolucao do aluno: as quatro linhas ao longo dos 6 testes, de um tema ou de todos.
export function EvolucaoAluno(props: { tema?: string; comSeletor?: boolean }) {
  const [temas, setTemas] = useState<string[]>([]);
  const [tema, setTema] = useState(props.tema ?? '');
  const [linhas, setLinhas] = useState<LinhaComparativo[] | null>(null);
  useEffect(() => {
    if (!props.comSeletor) return;
    apiGet<{ notas: { tema: string }[] }>('/eng/notas').then((d) => setTemas([...new Set(d.notas.map((n) => n.tema))].sort())).catch(() => undefined);
  }, [props.comSeletor]);
  useEffect(() => {
    apiGet<{ linhas: LinhaComparativo[] }>(`/jornada/comparativo${tema ? `?tema=${tema.replace('-', '')}` : ''}`)
      .then((d) => setLinhas(d.linhas)).catch(() => setLinhas([]));
  }, [tema]);
  if (!linhas) return <p className="carregando">Carregando…</p>;
  const W = 640, H = 260, E = 44, D = 16, T = 14, B = 30;
  const x = (i: number) => E + (i * (W - E - D)) / 5;
  const y = (v: number) => T + ((100 - v) * (H - T - B)) / 100;
  const valores = (k: string) => [1, 2, 3, 4, 5, 6].map((n) => num((linhas.find((l) => l.teste_num === n) as Record<string, unknown> | undefined)?.[k] as string | null));
  return (
    <article className="cartao-app">
      <h2 style={{ marginTop: 0 }}>Evolução da sua nota</h2>
      {props.comSeletor && (
        <p className="painel-barra"><label>Tema <select value={tema} onChange={(e) => setTema(e.target.value)}>
          <option value="">média dos temas que você fez</option>{temas.map((t) => <option key={t}>{t}</option>)}</select></label></p>
      )}
      {linhas.length === 0 ? <p>Responda o primeiro teste para ver a sua evolução.</p> : (<>
        <svg viewBox={`0 0 ${W} ${H}`} className="grafico" role="img" aria-label="Evolução da nota por teste">
          {[0, 25, 50, 75, 100].map((v) => <g key={v}><line x1={E} x2={W - D} y1={y(v)} y2={y(v)} stroke="#dde2e9" /><text x={E - 8} y={y(v) + 4} textAnchor="end" fontSize="11" fill="#4a5568">{v}%</text></g>)}
          {TESTES.map((t, i) => <text key={t} x={x(i)} y={H - 10} textAnchor="middle" fontSize="11" fill="#4a5568">{t}</text>)}
          {SERIES.map((s) => {
            const vs = valores(s.chave);
            const d = vs.map((v, i) => (v === null ? null : `${x(i)},${y(v)}`)).filter(Boolean).map((p, i) => `${i ? 'L' : 'M'}${p}`).join('');
            return (
              <g key={s.chave}>
                <path d={d} fill="none" stroke={s.cor} strokeWidth={s.chave === 'nota' ? 3 : 2} strokeDasharray={s.tracejado ? '6 4' : undefined} />
                {vs.map((v, i) => v !== null && <circle key={i} cx={x(i)} cy={y(v)} r={s.chave === 'nota' ? 5 : 3.5} fill={s.cor}><title>{`${s.rotulo} · ${TESTES[i]}: ${v.toFixed(0)}%`}</title></circle>)}
              </g>
            );
          })}
        </svg>
        <div className="legenda">{SERIES.map((s) => <span key={s.chave}><i style={{ background: s.cor }} />{s.rotulo}</span>)}</div>
        <div className="tabela-rolavel"><table className="tabela compacta">
          <thead><tr><th>Teste</th>{SERIES.map((s) => <th key={s.chave}>{s.rotulo}</th>)}</tr></thead>
          <tbody>{linhas.map((l) => <tr key={l.teste_num}><td>{TESTES[l.teste_num - 1]}</td>{SERIES.map((s) => <td key={s.chave}>{fmt(num(l[s.chave]))}</td>)}</tr>)}</tbody>
        </table></div>
        <p><small>Subgrupo: mesmo ano de residência e mesma especialidade{linhas[0]?.ano ? ` (${[linhas[0].ano, linhas[0].especialidade].filter(Boolean).join(' · ')})` : ''}. Médias de grupo aparecem com pelo menos 3 alunos.</small></p>
      </>)}
    </article>
  );
}
