import { useEffect, useState } from 'react';
import { CuradorRevisao } from './Revisao.js';
import { ParaRevisar } from '../../components/leitura/ParaRevisar.js';

// Menu "Revisão": as propostas dos agentes (Para revisar) e os rascunhos do tema, na mesma tela.
// Abre em "Para revisar"; o link "abrir a peça" das propostas abre direto nos rascunhos (?aba=rascunhos).
const API = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

export function RevisaoCoordenacao() {
  const inicial = new URLSearchParams(window.location.search).get('aba') === 'rascunhos' ? 'rascunhos' : 'propostas';
  const [aba, setAba] = useState<'propostas' | 'rascunhos'>(inicial);
  const [n, setN] = useState<number | null>(null);
  const tema = (window.location.pathname.match(/revisao\/([A-Za-z0-9-]+)/)?.[1] ?? 'T001').toUpperCase();

  useEffect(() => {
    fetch(`${API}/coordenacao/propostas?status=aguardando`, { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : null))
      .then((j) => setN(j ? (j.propostas as unknown[]).length : null))
      .catch(() => setN(null));
  }, [aba]);

  function trocar(a: 'propostas' | 'rascunhos') {
    setAba(a);
    const u = new URL(window.location.href);
    if (a === 'rascunhos') u.searchParams.set('aba', 'rascunhos'); else u.searchParams.delete('aba');
    window.history.replaceState(null, '', u.toString());
  }

  return (
    <>
      <div className="rv-troca" role="tablist" aria-label="Revisão">
        <button type="button" role="tab" aria-selected={aba === 'propostas'} className={`botao discreto${aba === 'propostas' ? ' sel' : ''}`} onClick={() => trocar('propostas')}>
          Para revisar{n !== null ? ` (${n})` : ''}
        </button>
        <button type="button" role="tab" aria-selected={aba === 'rascunhos'} className={`botao discreto${aba === 'rascunhos' ? ' sel' : ''}`} onClick={() => trocar('rascunhos')}>
          Rascunhos do {tema}
        </button>
      </div>
      {aba === 'propostas' ? <div className="rv-propostas"><h1>Para revisar</h1><ParaRevisar /></div> : <CuradorRevisao />}
    </>
  );
}
