import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Residente { nome: string; email: string; ano: string | null; especialidade: string | null; testes: number; media: number | null; esperada: number | null;
  ultimo_acesso: string | null; pendentes: number; aproveitamento: { temas_concluidos: number; presenca_pct: number | null };
  evolucao: { teste: number; nota: number; esperada: number | null }[] | null }

function Mini(props: { pontos: { teste: number; nota: number; esperada: number | null }[] | null }) {
  const p = props.pontos ?? [];
  if (!p.length) return <span>—</span>;
  const x = (t: number) => 4 + (t - 1) * 18, y = (v: number) => 34 - v * 0.3;
  const linha = (k: 'nota' | 'esperada') => p.filter((q) => q[k] !== null).map((q, i) => `${i ? 'L' : 'M'}${x(q.teste)},${y(Number(q[k]))}`).join('');
  return <svg width="100" height="38" aria-label="Evolução por teste"><path d={linha('esperada')} fill="none" stroke="#b45309" strokeDasharray="3 2" /><path d={linha('nota')} fill="none" stroke="#1f4e79" strokeWidth="2" /></svg>;
}

// Preceptor: seus residentes com pendencias, evolucao, presenca e ultimo acesso (sem dados de pesquisa).
export function PreceptorHome() {
  const [lista, setLista] = useState<Residente[] | null>(null);
  useEffect(() => { apiGet<{ residentes: Residente[] }>('/com/preceptor/residentes').then((d) => setLista(d.residentes)).catch(() => setLista([])); }, []);
  return (
    <section>
      <h1>Meus residentes</h1>
      {lista && lista.length > 0 && (() => {
        const abaixo = lista.filter((r) => r.media !== null && r.esperada !== null && r.media < r.esperada - 10).length;
        const atrasados = lista.filter((r) => r.pendentes > 2).length;
        const sumidos = lista.filter((r) => !r.ultimo_acesso || Date.now() - new Date(r.ultimo_acesso).getTime() > 14 * 86400_000).length;
        return (
          <div className="cartoes entradas">
            <div className="cartao-app entrada"><span className="rotulo">Residentes</span><strong>{lista.length}</strong><span>vinculados a você</span></div>
            <div className={`cartao-app entrada${abaixo ? ' alerta' : ''}`}><span className="rotulo">Abaixo do esperado</span><strong>{abaixo}</strong><span>média 10 pontos ou mais abaixo</span></div>
            <div className={`cartao-app entrada${atrasados ? ' alerta' : ''}`}><span className="rotulo">Com pendências</span><strong>{atrasados}</strong><span>mais de 2 testes ou avaliações</span></div>
            <div className={`cartao-app entrada${sumidos ? ' alerta' : ''}`}><span className="rotulo">Sem acesso</span><strong>{sumidos}</strong><span>há mais de 14 dias</span></div>
          </div>
        );
      })()}
      <p>Residentes vinculados a você pela coordenação. Linhas em destaque pedem atenção. No gráfico, linha azul = nota por teste; tracejada = nota esperada para o perfil.</p>
      {!lista ? <p className="carregando">Carregando…</p> : lista.length === 0 ? <p className="faixa-aviso">Nenhum residente vinculado ainda. A coordenação faz o vínculo na tela de Inscrições.</p> : (
        <div className="tabela-rolavel"><table className="tabela">
          <thead><tr><th>Residente</th><th>Ano</th><th>Testes</th><th>Média / esperada</th><th>Evolução</th><th>Temas concluídos</th><th>Presença</th><th>Pendentes</th><th>Último acesso</th></tr></thead>
          <tbody>{lista.map((r) => (
            <tr key={r.email} className={r.pendentes > 2 || (r.media !== null && r.esperada !== null && r.media < r.esperada - 10) ? 'alerta' : ''}>
              <td>{r.nome}<br /><small>{r.especialidade ?? ''}</small></td><td>{r.ano ?? '—'}</td><td>{r.testes}</td>
              <td>{r.media ?? '—'}% / {r.esperada ?? '—'}%</td><td><Mini pontos={r.evolucao} /></td>
              <td>{r.aproveitamento?.temas_concluidos ?? 0}</td><td>{r.aproveitamento?.presenca_pct ?? '—'}{r.aproveitamento?.presenca_pct !== null ? '%' : ''}</td>
              <td>{r.pendentes}</td><td>{r.ultimo_acesso ? new Date(r.ultimo_acesso).toLocaleDateString('pt-BR') : 'nunca'}</td>
            </tr>))}</tbody>
        </table></div>
      )}
      <p><a href="/aluno/calendario">Calendário das aulas</a> · <a href="/aluno/arvore">Árvore de temas</a> · <a href="/aluno/mural">Mural</a> · <a href="/ajuda">Ajuda</a></p>
    </section>
  );
}
