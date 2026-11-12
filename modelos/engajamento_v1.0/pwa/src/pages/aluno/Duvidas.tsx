import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';
import { Pergunta } from '../../components/Engajamento.js';

interface Msg { mensagem_id: number; tema: string | null; ferramenta: string | null; tipo: string; texto: string; status: string;
  resposta_ia: string | null; util: boolean | null; revisao_preceptor: string | null; criado_em: string }

export function Duvidas() {
  const [lista, setLista] = useState<Msg[] | null>(null);
  const [temas, setTemas] = useState<{ codigo: string; titulo: string }[]>([]);
  const [tema, setTema] = useState('T-001');
  useEffect(() => { apiGet<{ temas: { codigo: string; titulo: string; papel: string }[] }>('/eng/catalogo').then((d) => setTemas(d.temas)).catch(() => undefined); }, []);
  const carregar = () => apiGet<{ mensagens: Msg[] }>('/eng/mensagens').then((d) => setLista(d.mensagens)).catch(() => setLista([]));
  useEffect(() => { carregar(); const t = setInterval(carregar, 30_000); return () => clearInterval(t); }, []);
  async function util(id: number, v: boolean) { try { await apiPost(`/eng/mensagens/${id}/util`, { util: v }); carregar(); } catch { /* segue */ } }
  return (
    <section>
      <h1>Dúvidas e feedback</h1>
      <p>As dúvidas são respondidas por IA com base no material do tema, em poucos minutos, e podem ser revistas pelo preceptor. O feedback vai para a coordenação.</p>
      <label className="escala" style={{ maxWidth: 720 }}><span>Tema da dúvida</span>
        <select className="busca" value={tema} onChange={(e) => setTema(e.target.value)}>
          {(temas.length ? temas : [{ codigo: 'T-001', titulo: 'Avaliação inicial do traumatizado' }]).map((t) => <option key={t.codigo} value={t.codigo}>{t.codigo} {t.titulo}</option>)}
        </select>
      </label>
      <Pergunta tema={tema} ferramenta={null} />
      {!lista ? <p className="carregando">Carregando…</p> : lista.length === 0 ? <p>Você ainda não enviou nada.</p> : lista.map((m) => (
        <article key={m.mensagem_id} className="cartao-app" style={{ margin: '12px 0' }}>
          <span className="rotulo">{m.tipo === 'duvida' ? 'Dúvida' : 'Feedback'}{m.tema ? ` · ${m.tema}` : ''}{m.ferramenta ? ` · ${m.ferramenta}` : ''}</span>
          <p style={{ whiteSpace: 'pre-wrap' }}>{m.texto}</p>
          {m.tipo === 'duvida' && (m.resposta_ia
            ? <div className="resposta"><Markdown texto={m.resposta_ia} />
                <p>Esta resposta ajudou?{' '}
                  <button type="button" className={`botao discreto${m.util === true ? ' sel' : ''}`} onClick={() => util(m.mensagem_id, true)}>Sim</button>{' '}
                  <button type="button" className={`botao discreto${m.util === false ? ' sel' : ''}`} onClick={() => util(m.mensagem_id, false)}>Não</button></p></div>
            : <p className="carregando" style={{ padding: 0 }}>{m.status === 'erro' ? 'Não foi possível responder agora; tentaremos de novo.' : 'Aguardando resposta…'}</p>)}
          {m.revisao_preceptor && <blockquote>Preceptor: {m.revisao_preceptor}</blockquote>}
        </article>
      ))}
    </section>
  );
}
