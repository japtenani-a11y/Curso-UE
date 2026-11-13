import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

interface Card { id: number; tema: string; frente: string; verso: string; autor: string; nome: string; oculto: boolean; criado_em: string }

// Cards feitos por alunos e compartilhados: publicam na hora, sem revisao. Aqui a coordenacao acompanha e,
// se houver erro grave, oculta o card (o autor ve que foi ocultado).
export function CuradorFlashcards() {
  const [cards, setCards] = useState<Card[] | null>(null);
  const [tema, setTema] = useState('');
  const carregar = () => { apiGet<{ cards: Card[] }>('/estudo/compartilhados').then((d) => setCards(d.cards)).catch(() => setCards([])); };
  useEffect(carregar, []);
  async function alternar(c: Card) { await apiPost(`/estudo/compartilhados/${c.id}/ocultar`, { oculto: !c.oculto }); carregar(); }
  if (!cards) return <section><h1>Flashcards dos alunos</h1><p>Carregando…</p></section>;
  const temas = [...new Set(cards.map((c) => c.tema))].sort();
  const lista = cards.filter((c) => !tema || c.tema === tema);
  return (
    <section>
      <h1>Flashcards dos alunos</h1>
      <p className="sub">Compartilhados com os participantes do tema. Não precisam de aprovação; aparecem como “feito por aluno” com o nome ou apelido. Oculte só se houver erro.</p>
      <label>Tema <select value={tema} onChange={(e) => setTema(e.target.value)}><option value="">Todos ({cards.length})</option>{temas.map((t) => <option key={t}>{t}</option>)}</select></label>
      {lista.length === 0 ? <p>Nenhum card compartilhado ainda.</p> : (
        <ul className="lista-cards">
          {lista.map((c) => (
            <li key={c.id} className={`cartao-app ${c.oculto ? 'ocultado' : ''}`}>
              <p className="rotulo">{c.tema} · {c.autor}{c.autor !== c.nome ? ` (${c.nome})` : ''} · {new Date(c.criado_em).toLocaleDateString('pt-BR')}{c.oculto ? ' · OCULTO' : ''}</p>
              <p><strong>{c.frente}</strong></p><p>{c.verso}</p>
              <button type="button" className="botao discreto" onClick={() => alternar(c)}>{c.oculto ? 'Mostrar de novo' : 'Ocultar'}</button>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
