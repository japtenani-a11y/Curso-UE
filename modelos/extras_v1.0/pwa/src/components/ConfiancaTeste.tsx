import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

// Antes de abrir as questoes: "quanto voce acha que vai acertar?". Serve para medir a calibracao (confianca x nota).
export function ConfiancaTeste(props: { ondaId: number; aoConfirmar: () => void }) {
  const [pct, setPct] = useState(50);
  const [pronto, setPronto] = useState(false);
  useEffect(() => {
    apiGet<{ pct: number | null }>(`/extra/confianca/${props.ondaId}`)
      .then((d) => { if (d.pct !== null) props.aoConfirmar(); else setPronto(true); })
      .catch(() => props.aoConfirmar());
  }, [props.ondaId]);
  if (!pronto) return <p className="carregando">Carregando…</p>;
  async function confirmar() { await apiPost(`/extra/confianca/${props.ondaId}`, { pct }).catch(() => undefined); props.aoConfirmar(); }
  return (
    <div className="confianca">
      <h2>Antes de começar</h2>
      <p>Sem olhar as questões: <strong>quanto deste teste você acha que vai acertar?</strong></p>
      <p className="confianca-valor" aria-live="polite">{pct}%</p>
      <input type="range" min={0} max={100} step={10} value={pct} onChange={(e) => setPct(Number(e.target.value))} aria-label="Acertos esperados, em porcentagem" />
      <div className="confianca-escala"><span>0%</span><span>50%</span><span>100%</span></div>
      <p><small>Não conta para nota. Comparar o que você espera com o que acerta mostra se a sua segurança acompanha o seu conhecimento (calibração).</small></p>
      <button type="button" className="botao" onClick={confirmar}>Confirmar e abrir o teste</button>
    </div>
  );
}
