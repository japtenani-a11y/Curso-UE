import { useEffect, useMemo, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { Avaliacao } from '../../components/Engajamento.js';
import { Contagem } from '../../components/Contagem.js';

interface Pendencia { codigo: string; titulo: string; tipo: 'teste' | 'avaliacao'; item: string; nome: string; prazo: string | null; d0: string | null }

const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });

// Pendencias: testes liberados que faltam e avaliacoes (NPS e satisfacao) do tema, de cada peca e de cada teste.
export function Pendencias() {
  const [lista, setLista] = useState<Pendencia[] | null>(null);
  const [abrir, setAbrir] = useState<string | null>(null);
  const carregar = () => apiGet<{ pendencias: Pendencia[] }>('/jornada/pendencias').then((d) => setLista(d.pendencias)).catch(() => setLista([]));
  useEffect(() => { carregar(); }, []);
  const porTema = useMemo(() => {
    const m = new Map<string, Pendencia[]>();
    for (const p of lista ?? []) m.set(p.codigo, [...(m.get(p.codigo) ?? []), p]);
    return [...m.entries()];
  }, [lista]);
  if (!lista) return <p className="carregando">Carregando…</p>;
  const nTestes = lista.filter((p) => p.tipo === 'teste').length;
  return (
    <section>
      <h1>Pendências</h1>
      <p>{nTestes} {nTestes === 1 ? 'teste' : 'testes'} e {lista.length - nTestes} {lista.length - nTestes === 1 ? 'avaliação' : 'avaliações'} esperando por você.</p>
      {porTema.length === 0 && <p className="faixa-aviso">Nada pendente. Bom trabalho!</p>}
      {porTema.map(([cod, itens]) => (
        <article key={cod} className="cartao-app" style={{ margin: '12px 0' }}>
          <h2 style={{ marginTop: 0 }}><a href={`/aluno/tema/${cod.replace('-', '')}`}>{cod} — {itens[0]?.titulo}</a></h2>
          {itens.some((p) => p.tipo === 'teste') && <h3>Testes</h3>}
          <ul className="itens">
            {itens.filter((p) => p.tipo === 'teste').map((p) => (
              <li key={p.item}>
                <span className="item-nome">{p.nome}{p.prazo && <small> · até {quando(p.prazo)}</small>}</span>
                <Contagem ate={p.prazo} />
                <a className="botao" href={`/aluno/testes/${cod.replace('-', '')}`}>Responder</a>
              </li>
            ))}
          </ul>
          {itens.some((p) => p.tipo === 'avaliacao') && <h3>Avaliações</h3>}
          <ul className="itens">
            {itens.filter((p) => p.tipo === 'avaliacao').map((p) => {
              const k = `${cod}:${p.item}`;
              return (
                <li key={p.item} className="avaliar">
                  {abrir !== k && <span className="item-nome">{p.nome}</span>}
                  {abrir === k
                    ? <Avaliacao tema={cod} ferramenta={p.item} titulo={p.nome.replace(/^Avaliação:?\s*/, '')} aberto
                        modo={p.item === 'tema' ? 'tema' : p.item.startsWith('teste_') ? 'teste' : 'peca'} aoSalvar={() => { setAbrir(null); carregar(); }} />
                    : <button type="button" className="botao discreto" onClick={() => setAbrir(k)}>Avaliar</button>}
                </li>
              );
            })}
          </ul>
        </article>
      ))}
    </section>
  );
}
