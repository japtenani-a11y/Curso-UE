import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { ResgatarPresenca } from '../../components/ResgatarPresenca.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface Aprov { temas_concluidos: number; horas: number; aulas_realizadas: number; aulas_presentes: number; presenca_pct: number | null;
  lista_temas: string[]; certificados: { codigo: string; emitido_em: string }[] }
interface Pres { tema: string; titulo: string; aula_em: string; por_codigo: boolean; minutos_meet: number | null; presente: boolean }

// Presenca nas aulas ao vivo, aproveitamento e certificado.
export function Aproveitamento() {
  const [a, setA] = useState<Aprov | null>(null);
  const [p, setP] = useState<Pres[]>([]);
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => {
    apiGet<Aprov>('/com/aproveitamento').then(setA).catch(() => setA(null));
    apiGet<{ presencas: Pres[] }>('/com/presenca/minhas').then((d) => setP(d.presencas)).catch(() => undefined);
  };
  useEffect(carregar, []);
  async function emitir() {
    const r = await fetch(`${BASE}/com/certificado`, { method: 'POST', credentials: 'include' });
    const j = await r.json() as { codigo?: string; erro?: string };
    if (!r.ok) { setMsg(j.erro === 'sem_temas_concluidos' ? 'O certificado sai a partir do primeiro tema concluído (pós-teste D0 enviado).' : 'Não foi possível emitir agora.'); return; }
    window.location.href = `/certificado/${j.codigo}`;
  }
  return (
    <section>
      <h1>Presença e certificado</h1>
      <article className="cartao-app"><ResgatarPresenca /></article>
      {a && (
        <div className="cartoes" style={{ marginTop: 16 }}>
          <article className="cartao-app numero"><span className="rotulo">Temas concluídos</span><strong>{a.temas_concluidos}</strong><span>{a.horas} horas</span></article>
          <article className="cartao-app numero"><span className="rotulo">Presença nas aulas</span><strong>{a.presenca_pct === null ? '—' : `${a.presenca_pct}%`}</strong><span>{a.aulas_presentes} de {a.aulas_realizadas} aulas</span></article>
          <article className="cartao-app numero"><span className="rotulo">Certificado</span>
            <button type="button" className="botao" onClick={emitir}>Emitir certificado</button>
            {msg && <span role="status">{msg}</span>}</article>
        </div>
      )}
      <p><small>Presença: código resgatado na aula, ou pelo menos 50% da aula no relatório do Google Meet enviado pela coordenação.</small></p>
      <h2>Minhas presenças</h2>
      {p.length === 0 ? <p>Nenhuma presença registrada ainda.</p> : (
        <div className="tabela-rolavel"><table className="tabela">
          <thead><tr><th>Aula</th><th>Data</th><th>Código</th><th>Tempo no Meet</th><th>Situação</th></tr></thead>
          <tbody>{p.map((x) => <tr key={x.tema}><td>{x.tema} {x.titulo}</td><td>{new Date(x.aula_em).toLocaleDateString('pt-BR')}</td><td>{x.por_codigo ? 'sim' : '—'}</td>
            <td>{x.minutos_meet !== null ? `${Math.round(x.minutos_meet)} min` : '—'}</td><td>{x.presente ? 'presente' : 'tempo insuficiente'}</td></tr>)}</tbody>
        </table></div>
      )}
      {a && a.certificados.length > 0 && (<>
        <h2>Certificados emitidos</h2>
        <ul>{a.certificados.map((c) => <li key={c.codigo}><a href={`/certificado/${c.codigo}`}>{c.codigo}</a> · {new Date(c.emitido_em).toLocaleDateString('pt-BR')}</li>)}</ul>
      </>)}
    </section>
  );
}

// Link de presenca aberto pelo aluno logado (/presenca/CODIGO): registra direto.
export function PresencaPorLink() {
  const cod = window.location.pathname.split('/').pop() ?? '';
  return (
    <section>
      <h1>Resgatar crédito de presença</h1>
      <article className="cartao-app"><ResgatarPresenca inicial={cod} /></article>
      <p><a href="/aluno">Voltar ao início</a></p>
    </section>
  );
}
