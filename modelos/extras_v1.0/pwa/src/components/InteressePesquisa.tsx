import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

interface Meu { ideia: number; status: string; orientador: string | null; mensagem: string | null; autoriza: boolean }
const STATUS: Record<string, string> = { novo: 'recebido pela coordenação', em_contato: 'coordenação em contato', encaminhado: 'encaminhado a orientador',
  em_andamento: 'projeto em andamento', encerrado: 'encerrado' };

// Le as ideias numeradas da secao "Sugestoes de temas para trabalho cientifico/artigos" da sintese de evidencia.
export function ideiasDePesquisa(corpo: string): { n: number; texto: string }[] {
  const i = corpo.indexOf('Sugestões de temas para trabalho científico');
  if (i < 0) return [];
  const resto = corpo.slice(i).split('\n## ')[0] ?? '';
  return resto.split('\n').map((l) => /^(\d+)\.\s+(.+)$/.exec(l.trim())).filter((m): m is RegExpExecArray => !!m)
    .map((m) => ({ n: Number(m[1]), texto: (m[2] ?? '').replace(/\*\*/g, '').replace(/\s*\[[ADPHG]\d+(?:,\s*[ADPHG]\d+)*\]/g, '') }));
}

// "Tenho interesse em pesquisar este tema": o residente escolhe a ideia e a coordenacao faz a ponte com um orientador.
export function InteressePesquisa(props: { tema: string; corpo: string }) {
  const ideias = ideiasDePesquisa(props.corpo);
  const [meus, setMeus] = useState<Meu[]>([]);
  const [ideia, setIdeia] = useState<number | null>(null);
  const [mensagem, setMensagem] = useState('');
  const [autoriza, setAutoriza] = useState(true);
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => { apiGet<{ itens: Meu[] }>(`/extra/pesquisa/${props.tema.replace('-', '')}`).then((d) => setMeus(d.itens)).catch(() => undefined); };
  useEffect(carregar, [props.tema]);
  if (ideias.length === 0) return null;
  async function enviar() {
    if (!ideia) { setMsg('Escolha uma das ideias.'); return; }
    try {
      await apiPost('/extra/pesquisa', { tema: props.tema, ideia, texto: ideias.find((x) => x.n === ideia)?.texto ?? '', mensagem, autoriza });
      setMsg('Interesse registrado! A coordenação recebe o aviso e entra em contato para apresentar um possível orientador.');
      setIdeia(null); setMensagem(''); carregar();
    } catch { setMsg('Não foi possível registrar agora.'); }
  }
  async function cancelar(n: number) { await apiPost('/extra/pesquisa', { tema: props.tema, ideia: n, cancelar: true }).catch(() => undefined); carregar(); }
  return (
    <div className="interesse-pesquisa">
      <h3>Tenho interesse em pesquisar este tema</h3>
      {meus.length > 0 && (
        <ul className="lista-curta">{meus.map((m) => (
          <li key={m.ideia}>Ideia {m.ideia}: <strong>{STATUS[m.status] ?? m.status}</strong>{m.orientador ? ` · orientador: ${m.orientador}` : ''}
            {m.status === 'novo' && <> · <button type="button" className="link" onClick={() => cancelar(m.ideia)}>retirar</button></>}</li>))}</ul>
      )}
      <fieldset>
        <legend>Qual ideia você gostaria de desenvolver?</legend>
        {ideias.map((x) => (
          <label key={x.n} className="marca"><input type="radio" name="ideia" checked={ideia === x.n} onChange={() => setIdeia(x.n)} />
            <span><strong>{x.n}.</strong> {x.texto}</span></label>
        ))}
      </fieldset>
      <label className="bloco">Conte um pouco (opcional): já tem orientador em mente? Quanto tempo pode dedicar?
        <textarea value={mensagem} maxLength={2000} onChange={(e) => setMensagem(e.target.value)} /></label>
      <label className="marca"><input type="checkbox" checked={autoriza} onChange={(e) => setAutoriza(e.target.checked)} />
        <span>Autorizo a coordenação a compartilhar meu nome e e-mail com possíveis orientadores.</span></label>
      {msg && <p role="status" className="faixa-aviso">{msg}</p>}
      <button type="button" className="botao" onClick={enviar}>Registrar interesse</button>
    </div>
  );
}
