import { useEffect, useMemo, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Aula { data_hora: string; codigo: string; titulo: string; modulo: string | null; papel: string; proprio: boolean; etapa: number; testes_feitos: number }

const mes = (s: string) => new Date(s).toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
const diaSemana = (s: string) => new Date(s).toLocaleDateString('pt-BR', { weekday: 'short', day: '2-digit' });
const hora = (s: string) => new Date(s).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });

// Entrada pelo calendario: aulas do grupo e os D0 que o aluno escolheu.
export function Calendario() {
  const [aulas, setAulas] = useState<Aula[] | null>(null);
  const [passadas, setPassadas] = useState(false);
  const [agenda, setAgenda] = useState<{ token: string; meet: string } | null>(null);
  useEffect(() => {
    apiGet<{ aulas: Aula[] }>('/jornada/calendario').then((d) => setAulas(d.aulas)).catch(() => setAulas([]));
    apiGet<{ token: string; meet: string }>('/com/agenda/link').then(setAgenda).catch(() => undefined);
  }, []);
  const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
  const urlIcs = agenda ? new URL(`${BASE}/publico/agenda/${agenda.token}.ics`, window.location.origin).toString() : null;
  const meses = useMemo(() => {
    const agora = Date.now() - 6 * 3600_000;
    const m = new Map<string, Aula[]>();
    for (const a of aulas ?? []) {
      if (!passadas && new Date(a.data_hora).getTime() < agora) continue;
      const k = mes(a.data_hora); m.set(k, [...(m.get(k) ?? []), a]);
    }
    return [...m.entries()];
  }, [aulas, passadas]);
  if (!aulas) return <p className="carregando">Carregando…</p>;
  return (
    <section>
      <h1>Calendário de aulas</h1>
      <p>Reuniões às quintas, 20h, pelo Google Meet. Em destaque, os temas opcionais que você agendou. Clique no tema para abrir.</p>
      {agenda && (
        <div className="cartao-app agenda-acoes">
          <p><strong>Sala fixa das aulas:</strong> <a href={agenda.meet} target="_blank" rel="noopener noreferrer">{agenda.meet}</a></p>
          <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {urlIcs && <a className="botao" href={`https://calendar.google.com/calendar/r?cid=${encodeURIComponent(urlIcs.replace(/^https?:/, 'webcal:'))}`} target="_blank" rel="noopener noreferrer">Adicionar ao Google Agenda</a>}
            {urlIcs && <a className="botao discreto" href={urlIcs.replace(/^https?:/, 'webcal:')}>Adicionar ao iPhone/Outlook</a>}
            {urlIcs && <a className="botao discreto" href={urlIcs} download="programa-cut.ics">Baixar arquivo .ics</a>}
          </p>
          <small>A agenda se atualiza sozinha quando você agenda um tema opcional. O link é pessoal: não compartilhe.</small>
        </div>
      )}
      <label style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
        <input type="checkbox" checked={passadas} onChange={(e) => setPassadas(e.target.checked)} /> Mostrar aulas que já passaram
      </label>
      {meses.length === 0 && <p>Nenhuma aula {passadas ? 'cadastrada' : 'futura cadastrada'} ainda.</p>}
      {meses.map(([m, lista]) => (
        <article key={m} className="cartao-app mes">
          <h2>{m}</h2>
          <ul className="lista-temas">
            {lista.map((a) => (
              <li key={`${a.codigo}-${a.data_hora}`} className={a.proprio ? 'proprio' : ''}>
                <a href={`/aluno/tema/${a.codigo.replace('-', '')}`}>
                  <span className="cod">{diaSemana(a.data_hora)} · {hora(a.data_hora)}</span>
                  <span className="tit">{a.codigo} {a.titulo}</span>
                  <span className={`selo ${a.proprio ? 'eletivo' : 'nuclear'}`}>{a.proprio ? 'minha data' : 'grupo'}</span>
                  <span className="sit">{a.testes_feitos >= 6 ? 'concluído' : a.testes_feitos > 0 ? `${a.testes_feitos}/6 testes` : ''}</span>
                </a>
              </li>
            ))}
          </ul>
        </article>
      ))}
    </section>
  );
}
