import { useState } from 'react';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const MSG: Record<string, string> = {
  codigo_invalido: 'Código não encontrado. Confira as 6 letras ou cole o link mostrado na aula.',
  codigo_expirado: 'Este código já expirou. Se você estava na aula, a presença ainda pode vir pelo relatório do Meet.',
};

// "Resgatar credito": o aluno cola o codigo ou o link mostrado na aula do Meet.
export function ResgatarPresenca(props: { inicial?: string }) {
  const [texto, setTexto] = useState(props.inicial ?? '');
  const [msg, setMsg] = useState<{ ok: boolean; t: string } | null>(null);
  async function enviar(ev: React.FormEvent) {
    ev.preventDefault();
    try {
      const r = await fetch(`${BASE}/com/presenca/resgatar`, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ texto }) });
      const j = await r.json() as { erro?: string; tema?: string };
      if (!r.ok) { setMsg({ ok: false, t: MSG[j.erro ?? ''] ?? 'Não foi possível registrar.' }); return; }
      setMsg({ ok: true, t: `Presença registrada: ${j.tema}.` }); setTexto('');
    } catch { setMsg({ ok: false, t: 'Sem conexão. Tente de novo.' }); }
  }
  return (
    <form className="resgatar" onSubmit={enviar}>
      <label htmlFor="resgate">Resgatar crédito de presença</label>
      <div className="resgatar-linha">
        <input id="resgate" value={texto} onChange={(e) => setTexto(e.target.value)} placeholder="código de 6 letras ou link mostrado na aula" autoComplete="off" />
        <button type="submit" className="botao" disabled={texto.trim().length < 6}>Resgatar</button>
      </div>
      {msg && <p className={msg.ok ? 'faixa-aviso' : 'faixa-erro'} role="status">{msg.t}</p>}
    </form>
  );
}
