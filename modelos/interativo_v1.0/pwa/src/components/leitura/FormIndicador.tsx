import { useState, type FormEvent } from 'react';

// Painel: a coordenacao digita o total do mes de cada indicador da pratica clinica, tirado do registro de trauma do
// servico (numerador e denominador). So numeros agregados: nunca nome, prontuario ou qualquer dado de paciente.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const INDICADORES: [string, string][] = [
  ['via_aerea_registrada', 'Via aérea avaliada e registrada na admissão'],
  ['temperatura_admissao', 'Temperatura medida na admissão'],
  ['aquecimento_iniciado', 'Aquecimento iniciado na sala de trauma'],
  ['terciaria_registrada', 'Avaliação terciária registrada'],
  ['lider_definido', 'Líder da equipe definido antes da chegada'],
  ['torniquete_horario', 'Horário do torniquete registrado'],
];
type Linha = Record<string, unknown>;

export function FormIndicador(props: { aoSalvar: (linhas: Linha[]) => void }) {
  const [ind, setInd] = useState(INDICADORES[0]![0]);
  const [mes, setMes] = useState(() => new Date().toISOString().slice(0, 7));
  const [num, setNum] = useState('');
  const [den, setDen] = useState('');
  const [fonte, setFonte] = useState('Registro de trauma do serviço');
  const [msg, setMsg] = useState<string | null>(null);
  async function salvar(e: FormEvent) {
    e.preventDefault(); setMsg(null);
    const n = Number(num), d = Number(den);
    if (!Number.isInteger(n) || !Number.isInteger(d) || d <= 0 || n < 0 || n > d) { setMsg('Confira os números: o total do mês precisa ser maior que zero e maior ou igual aos casos com o registro.'); return; }
    const r = await fetch(`${API_BASE}/painel/indicadores`, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ indicador: ind, mes: `${mes}-01`, numerador: n, denominador: d, fonte }) }).catch(() => null);
    if (!r || !r.ok) { setMsg(r?.status === 403 ? 'Só a coordenação pode registrar indicadores.' : 'Não foi possível salvar agora.'); return; }
    const j = await fetch(`${API_BASE}/painel/indicadores`, { credentials: 'include' }).then((x) => x.json()) as { linhas: Linha[] };
    props.aoSalvar(j.linhas); setNum(''); setDen(''); setMsg('Salvo.');
  }
  return (
    <form className="cartao-app int-ind" onSubmit={salvar}>
      <h2>Registrar indicador do mês</h2>
      <p className="int-nota">Use os totais do mês tirados do registro de trauma do serviço. Só números: nunca nome, prontuário ou data de paciente.
        Registrar meses antes e depois do curso permite comparar a prática na sala de trauma.</p>
      <label>Indicador <select value={ind} onChange={(e) => setInd(e.target.value)}>{INDICADORES.map(([k, n]) => <option key={k} value={k}>{n}</option>)}</select></label>
      <label>Mês <input type="month" value={mes} onChange={(e) => setMes(e.target.value)} required /></label>
      <label>Casos com o registro feito <input type="number" min={0} value={num} onChange={(e) => setNum(e.target.value)} required /></label>
      <label>Total de casos no mês <input type="number" min={1} value={den} onChange={(e) => setDen(e.target.value)} required /></label>
      <label>Fonte <input type="text" maxLength={200} value={fonte} onChange={(e) => setFonte(e.target.value)} /></label>
      <button type="submit" className="botao">Salvar</button>
      {msg && <p role="status">{msg}</p>}
    </form>
  );
}
