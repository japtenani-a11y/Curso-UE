import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { lerCsvMeet } from '../../lib/meetCsv.js';

interface Aula { data_hora: string; codigo: string; titulo: string; proprio: boolean }
interface Lista { tema: string; presencas: { nome: string; email: string; por_codigo: boolean; minutos_meet: number | null; entrada: string | null; saida: string | null; presente: boolean }[];
  nao_identificados: { nome: string | null; email: string | null; minutos: number }[]; codigos: { codigo: string; valido_ate: string }[] }
const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
const hora = (s: string | null) => (s ? new Date(s).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) : '—');

// Presenca das aulas: codigo/link para o aluno resgatar e importacao do relatorio de presenca do Google Meet.
export function CuradorPresenca() {
  const tema = window.location.pathname.match(/presenca\/([A-Za-z0-9-]+)/)?.[1] ?? null;
  const [aulas, setAulas] = useState<Aula[]>([]);
  const [lista, setLista] = useState<Lista | null>(null);
  const [cod, setCod] = useState<{ codigo: string; valido_ate: string } | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => { if (tema) apiGet<Lista>(`/com/presenca/tema/${tema}`).then(setLista).catch(() => setMsg('Sem acesso.')); };
  useEffect(() => { if (!tema) apiGet<{ aulas: Aula[] }>('/jornada/calendario').then((d) => setAulas(d.aulas.filter((a) => !a.proprio))).catch(() => undefined); else carregar(); }, [tema]);

  async function gerar() {
    try { const c = await apiPost<{ codigo: string; valido_ate: string }>('/com/presenca/codigo', { tema }); setCod(c); carregar(); } catch { setMsg('Não foi possível gerar o código.'); }
  }
  async function importar(arq: File | undefined) {
    if (!arq) return;
    const { linhas, aviso } = lerCsvMeet(await arq.text());
    if (!linhas.length) { setMsg(aviso ?? 'Arquivo sem participantes.'); return; }
    try {
      const r = await apiPost<{ identificados: number; presentes_pelo_tempo: number; nao_identificados: number; minimo_minutos: number }>('/com/presenca/meet', { tema, linhas });
      setMsg(`${linhas.length} linhas lidas: ${r.identificados} alunos identificados, ${r.presentes_pelo_tempo} com pelo menos ${Math.round(r.minimo_minutos)} min (presença), ${r.nao_identificados} sem correspondência.${aviso ? ` ${aviso}` : ''}`);
      carregar();
    } catch { setMsg('Não foi possível importar.'); }
  }

  if (!tema) {
    const agora = Date.now();
    return (
      <section>
        <h1>Presença nas aulas</h1>
        <p>Escolha a aula para gerar o código de presença ou enviar o relatório do Google Meet.</p>
        <ul className="lista-temas cartao-app" style={{ padding: 0 }}>
          {aulas.map((a) => <li key={a.codigo}><a href={`/curador/presenca/${a.codigo.replace('-', '')}`}><span className="cod">{quando(a.data_hora)}</span><span className="tit">{a.codigo} {a.titulo}</span>
            <span className={`selo ${new Date(a.data_hora).getTime() < agora ? 'eletivo' : 'nuclear'}`}>{new Date(a.data_hora).getTime() < agora ? 'realizada' : 'futura'}</span><span className="sit" /></a></li>)}
        </ul>
      </section>
    );
  }
  const link = cod ? `${window.location.origin}/presenca/${cod.codigo}` : null;
  return (
    <section>
      <p className="migalha"><a href="/curador/presenca">Presença</a> › {lista?.tema ?? tema}</p>
      <h1>Presença — {lista?.tema ?? tema}</h1>
      {msg && <p className="faixa-aviso" role="status">{msg}</p>}
      <div className="grade-inicio duas">
        <article className="cartao-app">
          <h2 style={{ marginTop: 0 }}>1. Código para a aula</h2>
          <p>Gere durante a aula e mostre na tela ou cole no chat do Meet. O aluno digita o código ou abre o link em “Resgatar crédito”. Vale até 30 minutos depois do fim previsto da aula.</p>
          <button type="button" className="botao" onClick={gerar}>Gerar código</button>
          {cod && link && (<div className="codigo-presenca"><strong>{cod.codigo}</strong><span>{link}</span>
            <button type="button" className="botao discreto" onClick={() => navigator.clipboard?.writeText(`Presença da aula: ${link} (código ${cod.codigo})`)}>Copiar para o chat</button>
            <small>válido até {hora(cod.valido_ate)}</small></div>)}
          {lista && lista.codigos.length > 0 && <p><small>Códigos desta aula: {lista.codigos.map((c) => `${c.codigo} (até ${hora(c.valido_ate)})`).join(', ')}</small></p>}
        </article>
        <article className="cartao-app">
          <h2 style={{ marginTop: 0 }}>2. Relatório do Google Meet</h2>
          <p>Depois da aula, baixe o relatório de presença (CSV, com entrada e saída) e envie aqui. Quem ficou pelo menos 50% da aula ganha presença, mesmo sem o código.</p>
          <input type="file" accept=".csv,text/csv" onChange={(e) => importar(e.target.files?.[0])} aria-label="Relatório de presença do Meet (CSV)" />
        </article>
      </div>
      <h2>Lista de presença</h2>
      {!lista ? <p className="carregando">Carregando…</p> : (<>
        <div className="tabela-rolavel"><table className="tabela">
          <thead><tr><th>Aluno</th><th>Código</th><th>Entrada</th><th>Saída</th><th>Tempo no Meet</th><th>Situação</th></tr></thead>
          <tbody>{lista.presencas.map((p) => <tr key={p.email}><td>{p.nome}</td><td>{p.por_codigo ? 'sim' : '—'}</td><td>{hora(p.entrada)}</td><td>{hora(p.saida)}</td>
            <td>{p.minutos_meet !== null ? `${Math.round(p.minutos_meet)} min` : '—'}</td><td>{p.presente ? 'presente' : 'tempo insuficiente'}</td></tr>)}</tbody>
        </table></div>
        {lista.nao_identificados.length > 0 && (<>
          <h3>No relatório, sem cadastro correspondente</h3>
          <p><small>Provavelmente entraram com outro e-mail. Peça para resgatarem o código ou cadastrarem esse e-mail em Lembretes.</small></p>
          <ul>{lista.nao_identificados.map((n, i) => <li key={i}>{n.nome ?? '—'} · {n.email ?? 'sem e-mail'} · {Math.round(n.minutos)} min</li>)}</ul>
        </>)}
      </>)}
    </section>
  );
}
