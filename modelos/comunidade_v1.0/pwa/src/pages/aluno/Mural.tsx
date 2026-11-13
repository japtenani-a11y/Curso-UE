import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
export interface Pergunta { ordem: number; texto: string; tipo: 'texto' | 'unica' | 'multipla' | 'escala'; opcoes: string[] | null; obrigatoria: boolean }
export interface ItemMural { id: number; tipo: 'aviso' | 'questionario' | 'documento'; titulo: string; corpo: string | null; fixado: boolean; publico: string;
  publicado_em: string; expira_em: string | null; arquivo_nome: string | null; lido: boolean; respondido: boolean;
  minhas_respostas: Record<string, unknown> | null; n_respostas: number | null; perguntas: Pergunta[] | null;
  categoria?: string | null; tema?: string | null }

export function Questionario(props: { item: ItemMural; aoEnviar: () => void }) {
  const [r, setR] = useState<Record<string, unknown>>(props.item.minhas_respostas ?? {});
  const [msg, setMsg] = useState<string | null>(null);
  const fechado = props.item.expira_em !== null && new Date(props.item.expira_em) < new Date();
  async function enviar() {
    try {
      const res = await fetch(`${BASE}/com/mural/${props.item.id}/responder`, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ respostas: r }) });
      const j = await res.json() as { erro?: string; pergunta?: number };
      if (!res.ok) { setMsg(j.erro === 'pergunta_obrigatoria' ? `Responda a pergunta ${j.pergunta}.` : 'Não foi possível enviar.'); return; }
      setMsg('Respostas enviadas. Obrigado!'); props.aoEnviar();
    } catch { setMsg('Sem conexão.'); }
  }
  return (
    <div className="questionario">
      {(props.item.perguntas ?? []).map((p) => {
        const k = String(p.ordem);
        return (
          <fieldset key={k}>
            <legend>{p.ordem}. {p.texto}{p.obrigatoria && <span aria-label="obrigatória"> *</span>}</legend>
            {p.tipo === 'texto' && <textarea value={String(r[k] ?? '')} onChange={(e) => setR({ ...r, [k]: e.target.value })} disabled={fechado} />}
            {p.tipo === 'unica' && (p.opcoes ?? []).map((o) => <label key={o}><input type="radio" name={`q${props.item.id}-${k}`} checked={r[k] === o} onChange={() => setR({ ...r, [k]: o })} disabled={fechado} /> {o}</label>)}
            {p.tipo === 'multipla' && (p.opcoes ?? []).map((o) => {
              const sel = Array.isArray(r[k]) ? (r[k] as string[]) : [];
              return <label key={o}><input type="checkbox" checked={sel.includes(o)} onChange={(e) => setR({ ...r, [k]: e.target.checked ? [...sel, o] : sel.filter((x) => x !== o) })} disabled={fechado} /> {o}</label>;
            })}
            {p.tipo === 'escala' && <div className="opcoes">{[1, 2, 3, 4, 5].map((n) => <label key={n} className={`opcao${r[k] === n ? ' sel' : ''}`}><input type="radio" name={`q${props.item.id}-${k}`} checked={r[k] === n} onChange={() => setR({ ...r, [k]: n })} disabled={fechado} /> {n}</label>)}</div>}
          </fieldset>
        );
      })}
      {!fechado && <button type="button" className="botao" onClick={enviar}>{props.item.respondido ? 'Atualizar respostas' : 'Enviar respostas'}</button>}
      {fechado && <p className="faixa-aviso">Questionário encerrado.</p>}
      {msg && <span role="status" style={{ marginLeft: 8 }}>{msg}</span>}
    </div>
  );
}

// Mural do aluno: avisos, questionarios e documentos da coordenacao.
// Espaco fixo do mural: temas que acabaram de ser publicados no site.
function TemasNovos({ itens }: { itens: ItemMural[] }) {
  const [todos, setTodos] = useState(false);
  const lista = todos ? itens : itens.slice(0, 6);
  return (
    <article className="cartao-app temas-novos" aria-labelledby="temas-novos-t">
      <span className="rotulo">Espaço fixo</span>
      <h2 id="temas-novos-t">Temas novos no site</h2>
      {itens.length === 0 ? <p>Nenhum tema publicado ainda. Abra um tema em produção e clique em <strong>Avise-me</strong> para receber o aviso.</p> : (
        <ul className="lista-curta">
          {lista.map((i) => (
            <li key={i.id} className={!i.lido ? 'novo' : ''}>
              <a href={`/aluno/tema/${(i.tema ?? '').replace('-', '')}`}>{i.titulo.replace(/^Tema novo no site:\s*/, '')}</a>
              <small> · {new Date(i.publicado_em).toLocaleDateString('pt-BR')}{!i.lido ? ' · novo' : ''}</small>
            </li>
          ))}
        </ul>
      )}
      {itens.length > 6 && <button type="button" className="link" onClick={() => setTodos(!todos)}>{todos ? 'Mostrar menos' : `Ver todos (${itens.length})`}</button>}
    </article>
  );
}

export function Mural() {
  const [itens, setItens] = useState<ItemMural[] | null>(null);
  const carregar = () => apiGet<{ itens: ItemMural[] }>('/com/mural').then((d) => setItens(d.itens)).catch(() => setItens([]));
  useEffect(() => { carregar(); }, []);
  useEffect(() => { for (const i of itens ?? []) if (!i.lido && i.tipo !== 'questionario') apiPost(`/com/mural/${i.id}/ler`, {}).catch(() => undefined); }, [itens]);
  if (!itens) return <p className="carregando">Carregando…</p>;
  return (
    <section>
      <h1>Mural</h1>
      <p>Avisos, questionários e documentos da coordenação.</p>
      <TemasNovos itens={itens.filter((i) => i.categoria === 'novo_tema')} />
      {itens.length === 0 && <p>Nada publicado ainda.</p>}
      {itens.filter((i) => i.categoria !== 'novo_tema').map((i) => (
        <article key={i.id} className={`cartao-app mural-item${!i.lido ? ' novo' : ''}`}>
          <span className="rotulo">{i.fixado ? 'Fixado · ' : ''}{i.tipo === 'aviso' ? 'Aviso' : i.tipo === 'questionario' ? 'Questionário' : 'Documento'} · {new Date(i.publicado_em).toLocaleDateString('pt-BR')}
            {i.expira_em ? ` · até ${new Date(i.expira_em).toLocaleDateString('pt-BR')}` : ''}{i.tipo === 'questionario' && i.respondido ? ' · respondido' : ''}</span>
          <h2>{i.titulo}</h2>
          {i.corpo && <Markdown texto={i.corpo} />}
          {i.arquivo_nome && <p><a className="botao discreto" href={`${BASE}/com/mural/${i.id}/arquivo`}>Baixar: {i.arquivo_nome}</a></p>}
          {i.tipo === 'questionario' && <Questionario item={i} aoEnviar={carregar} />}
        </article>
      ))}
    </section>
  );
}
