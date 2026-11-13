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
  useEffect(() => { apiGet<{ aulas: Aula[] }>('/jornada/calendario').then((d) => setAulas(d.aulas)).catch(() => setAulas([])); }, []);
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
