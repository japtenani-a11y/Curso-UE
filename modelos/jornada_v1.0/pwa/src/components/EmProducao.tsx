import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

interface Situacao { codigo: string; publicado: boolean; em_revisao: boolean; avisar: boolean; interessados: number }

// Tela mostrada quando o residente abre um tema que ainda nao tem material publicado.
export function EmProducao(props: { codigo: string; titulo: string; maes?: { codigo: string; titulo: string; concluido: boolean }[] }) {
  const [s, setS] = useState<Situacao | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const cod = props.codigo.replace('-', '');
  const carregar = () => { apiGet<Situacao>(`/jornada/temas/${cod}/producao`).then(setS).catch(() => undefined); };
  useEffect(carregar, [cod]);
  async function alternar() {
    if (!s) return;
    try {
      await apiPost(`/jornada/temas/${cod}/avisar`, { ativo: !s.avisar });
      setMsg(s.avisar ? 'Pronto, você não será mais avisado sobre este tema.' : 'Combinado! Você recebe um e-mail e um aviso no mural assim que o tema for publicado.');
      carregar();
    } catch { setMsg('Não foi possível registrar agora. Tente de novo em instantes.'); }
  }
  return (
    <div className="em-producao" role="status">
      <div className="em-producao-icone" aria-hidden="true">🛠</div>
      <h2>Conteúdo em produção</h2>
      <p>O material de <strong>{props.codigo} — {props.titulo}</strong> ainda está sendo preparado pela equipe
        {s?.em_revisao ? ' e já está na fase de revisão pelos cirurgiões' : ''}. Assim que for publicado, ele aparece aqui,
        com as peças, os testes e o agendamento.</p>
      <p>Todo tema novo é anunciado no espaço <a href="/aluno/mural">Temas novos no site</a>, no mural.</p>
      {s && (
        <p>
          <button type="button" className={`botao${s.avisar ? ' discreto' : ''}`} aria-pressed={s.avisar} onClick={alternar}>
            {s.avisar ? '✓ Você será avisado (cancelar)' : 'Avise-me quando publicar'}
          </button>
          {s.interessados > 1 && <small> {s.interessados} residentes estão esperando este tema.</small>}
        </p>
      )}
      {msg && <p className="faixa-aviso">{msg}</p>}
      {props.maes && props.maes.length > 0 && (
        <p><small>Enquanto isso, adiante os temas que ele exige: {props.maes.map((m, i) => (
          <span key={m.codigo}>{i ? ', ' : ''}<a href={`/aluno/tema/${m.codigo.replace('-', '')}`}>{m.codigo}</a>{m.concluido ? ' ✓' : ''}</span>))}.</small></p>
      )}
      <p><a className="botao discreto" href="/aluno/temas">Ver outros temas</a> <a className="botao discreto" href="/aluno/estudo">Estudo dirigido</a></p>
    </div>
  );
}
