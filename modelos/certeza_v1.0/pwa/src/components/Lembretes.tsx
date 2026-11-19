import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

// Testes pendentes no alto do Inicio (padrao CUT): o mais urgente primeiro, com botao direto para responder.
// Prazo perto do fim aparece com aviso; laranja so para alerta, nunca para decoracao.
interface Lembrete { lembrete_id: number; dias_apos: number; teste_num: number; tema: string; titulo: string; data_fechamento: string }
const NOMES = ['', 'Pré-teste inicial', 'Pré-teste 2', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90'];
const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });

export function Lembretes() {
  const [lista, setLista] = useState<Lembrete[]>([]);
  useEffect(() => {
    apiGet<{ lembretes: Lembrete[] }>('/teste/lembretes').then((d) => setLista(d.lembretes)).catch(() => setLista([]));
  }, []);
  async function dispensar(id: number) {
    try { await apiPost(`/teste/lembretes/${id}/lido`, {}); } catch { /* segue */ }
    setLista(lista.filter((l) => l.lembrete_id !== id));
  }
  if (lista.length === 0) return null;
  return (
    <section className="pend-cut" aria-label="Testes pendentes">
      <span className="pend-rot">{lista.length === 1 ? 'Teste pendente' : `${lista.length} testes pendentes`}</span>
      {lista.map((l) => {
        const urgente = l.dias_apos === -1;
        return (
          <div key={l.lembrete_id} className={`pend-item${urgente ? ' urgente' : ''}`}>
            <div className="pend-txt">
              <strong>{NOMES[l.teste_num]} · {l.tema}</strong>
              <span>{l.titulo}</span>
              <small>{urgente ? `! Prazo até ${quando(l.data_fechamento)} (1 hora antes da aula)`
                : l.dias_apos === 0 ? (l.teste_num === 3 ? 'Disponível agora. O material da aula foi liberado.' : 'Disponível agora.')
                : `Pendente há ${l.dias_apos} dias.`}</small>
            </div>
            <div className="pend-acoes">
              <a className="pend-btn" href={`/aluno/testes/${l.tema.replace('-', '')}`}>Responder agora</a>
              <button type="button" className="pend-dispensar" onClick={() => dispensar(l.lembrete_id)} aria-label={`Dispensar o aviso de ${NOMES[l.teste_num]} de ${l.tema}`}>Dispensar</button>
            </div>
          </div>
        );
      })}
    </section>
  );
}
