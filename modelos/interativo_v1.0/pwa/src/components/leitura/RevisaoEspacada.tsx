import { useEffect, useState } from 'react';

// Estudo dirigido: revisao espacada das questoes ja vistas e simulado misturado com os temas ja estudados.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface Dia { questoes: number; cartoes: number; temas_concluidos: number }

export function RevisaoEspacada(props: { iniciar: (modo: 'revisao' | 'misturado') => void; ocupado: boolean; irFlashcards?: () => void }) {
  const [d, setD] = useState<Dia | null>(null);
  useEffect(() => {
    fetch(`${API_BASE}/estudo/revisao-do-dia`, { credentials: 'include' }).then((r) => (r.ok ? r.json() : null)).then(setD).catch(() => setD(null));
  }, []);
  if (!d) return null;
  return (
    <article className="cartao-app int-rev">
      <h2>Revisão do dia</h2>
      <p className="int-nota">
        Cada questão volta no tempo certo: a que você errou volta amanhã; a que acertou com certeza, só daqui a uma semana ou mais.
        Revisar um pouco todo dia fixa mais do que estudar muito de uma vez.
      </p>
      <div className="int-rev-acoes">
        <button type="button" className="botao" disabled={props.ocupado || d.questoes === 0} onClick={() => props.iniciar('revisao')}>
          {d.questoes > 0 ? `Revisar ${d.questoes} ${d.questoes === 1 ? 'questão' : 'questões'}` : 'Nenhuma questão para hoje'}
        </button>
        {props.irFlashcards && d.cartoes > 0 && (
          <button type="button" className="botao discreto" onClick={props.irFlashcards}>{d.cartoes} {d.cartoes === 1 ? 'cartão' : 'cartões'} para revisar</button>
        )}
      </div>
      {d.temas_concluidos >= 2 && (
        <p>
          <button type="button" className="botao discreto" disabled={props.ocupado} onClick={() => props.iniciar('misturado')}>
            Simulado misturado ({d.temas_concluidos} temas)
          </button>{' '}
          <small>As questões de temas diferentes vêm intercaladas: você treina reconhecer qual é o problema, como no plantão.</small>
        </p>
      )}
    </article>
  );
}
