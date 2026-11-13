import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';

interface Duvida {
  mensagem_id: number; aluno: string; ano: string | null; tema: string | null; ferramenta: string | null;
  texto: string; criado_em: string; resposta: string | null; respondida_em: string | null;
  respondida_por: string | null; util: boolean | null;
}

const data = (s: string) => new Date(s).toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' });

// Duvidas enviadas pelos alunos: cada curador recebe um e-mail a cada nova duvida e responde aqui.
export function CuradorDuvidas() {
  const [todas, setTodas] = useState(false);
  const [lista, setLista] = useState<Duvida[] | null>(null);
  const [texto, setTexto] = useState<Record<number, string>>({});
  const [aviso, setAviso] = useState<string | null>(null);

  const carregar = () => apiGet<{ duvidas: Duvida[] }>(`/curadoria/duvidas${todas ? '?todas=1' : ''}`)
    .then((d) => setLista(d.duvidas)).catch(() => setLista([]));
  useEffect(() => { setLista(null); carregar(); }, [todas]);

  async function responder(id: number) {
    const r = (texto[id] ?? '').trim();
    if (r.length < 3) { setAviso('Escreva a resposta antes de enviar.'); return; }
    try {
      await apiPost(`/curadoria/duvidas/${id}/resposta`, { resposta: r });
      setAviso('Resposta gravada. O aluno vê na tela de dúvidas e recebe por e-mail, se autorizou.');
      setTexto({ ...texto, [id]: '' });
      carregar();
    } catch { setAviso('Não foi possível gravar a resposta.'); }
  }

  return (
    <section>
      <h1>Dúvidas dos alunos</h1>
      <p>Cada dúvida nova chega por e-mail para os curadores. Avalie e responda aqui; a resposta vai para o aluno em nome da coordenação.</p>
      <div className="etapas" role="radiogroup" aria-label="Filtro">
        <button type="button" className={`etapa${!todas ? ' atual' : ''}`} onClick={() => setTodas(false)}>Aguardando resposta</button>
        <button type="button" className={`etapa${todas ? ' atual' : ''}`} onClick={() => setTodas(true)}>Todas</button>
      </div>
      {aviso && <p className="faixa-aviso" role="status">{aviso}</p>}
      {!lista ? <p className="carregando">Carregando…</p> : lista.length === 0 ? <p>Nenhuma dúvida {todas ? 'registrada' : 'aguardando resposta'}.</p> : lista.map((d) => (
        <article key={d.mensagem_id} className="cartao-app" style={{ margin: '12px 0' }}>
          <span className="rotulo">{d.tema ?? 'Sem tema'}{d.ferramenta ? ` · ${d.ferramenta}` : ''} · {d.aluno}{d.ano ? ` (${d.ano})` : ''} · {data(d.criado_em)}</span>
          <p style={{ whiteSpace: 'pre-wrap' }}>{d.texto}</p>
          {d.resposta && (
            <div className="resposta">
              <span className="rotulo">Resposta{d.respondida_por ? ` de ${d.respondida_por}` : ''}{d.respondida_em ? ` · ${data(d.respondida_em)}` : ''}</span>
              <Markdown texto={d.resposta} />
              {d.util !== null && <p>O aluno marcou como {d.util ? 'útil' : 'não útil'}.</p>}
            </div>
          )}
          <textarea
            aria-label="Resposta"
            placeholder={d.resposta ? 'Corrigir ou complementar a resposta' : 'Resposta da coordenação'}
            value={texto[d.mensagem_id] ?? ''}
            onChange={(e) => setTexto({ ...texto, [d.mensagem_id]: e.target.value })}
            style={{ width: '100%', minHeight: 90, marginTop: 8, font: 'inherit', padding: 8, borderRadius: 8, border: '1px solid var(--borda)' }}
          />
          <button type="button" className="botao" style={{ marginTop: 8 }} onClick={() => responder(d.mensagem_id)}>
            {d.resposta ? 'Atualizar resposta' : 'Enviar resposta'}
          </button>
        </article>
      ))}
    </section>
  );
}
