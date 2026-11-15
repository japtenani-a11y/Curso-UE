import { useEffect, useRef, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

// Escalas do questionario (1 a 5). O 3 das escalas "de dosagem" significa adequado.
interface Escala { chave: string; rotulo: string; baixo: string; alto: string; meio?: string }
const QUALIDADE: Escala[] = [
  { chave: 'conteudo', rotulo: 'Qualidade do material', baixo: 'ruim', alto: 'ótima' },
  { chave: 'apresentacao', rotulo: 'Apresentação', baixo: 'ruim', alto: 'ótima' },
  { chave: 'clareza', rotulo: 'Clareza', baixo: 'confuso', alto: 'claro' },
  { chave: 'objetividade', rotulo: 'Objetividade', baixo: 'pouca', alto: 'muita' },
  { chave: 'adequacao', rotulo: 'Adequação ao seu nível', baixo: 'inadequado', alto: 'muito adequado' },
  { chave: 'importancia', rotulo: 'Importância para a sua prática', baixo: 'nenhuma', alto: 'muita' },
];
const DOSAGEM: Escala[] = [
  { chave: 'dificuldade', rotulo: 'Grau de dificuldade', baixo: 'muito fácil', alto: 'muito difícil', meio: 'adequado' },
  { chave: 'complexidade', rotulo: 'Profundidade', baixo: 'superficial', alto: 'aprofundado demais', meio: 'adequada' },
  { chave: 'tempo_gasto', rotulo: 'Tempo exigido', baixo: 'pouco', alto: 'excessivo', meio: 'adequado' },
];
const FREQUENCIA: Escala = { chave: 'frequencia_testes', rotulo: 'Frequência dos testes', baixo: 'poucos', alto: 'excessivos', meio: 'adequada' };
const MATERIAIS: [string, string][] = [
  ['objetivos', 'Objetivos'], ['resumo_basico', 'Resumo básico'], ['podcast_roteiro', 'Podcast'], ['caso_base', 'Caso base'],
  ['aula', 'Aula'], ['slides', 'Slides'], ['caso', 'Caso da aula'], ['sintese_evidencia', 'Síntese de evidência'],
  ['resumo', 'Resumo executivo'], ['mapa', 'Mapa conceitual'], ['flashcard', 'Flashcards'], ['protocolo', 'Protocolo'],
  ['checklist', 'Checklists'], ['simulado', 'Simulados'], ['testes', 'Testes e gabaritos'],
];
export type ModoAvaliacao = 'peca' | 'teste' | 'tema' | 'curso';

type Valores = Record<string, number | string | null>;

// Registra quanto tempo a peca ficou aberta (so tempo com a aba visivel).
export function useTempoDeUso(tema: string, tipo: string) {
  const inicio = useRef(Date.now());
  const acumulado = useRef(0);
  useEffect(() => {
    inicio.current = Date.now(); acumulado.current = 0;
    const vis = () => {
      if (document.hidden) acumulado.current += Date.now() - inicio.current;
      else inicio.current = Date.now();
    };
    document.addEventListener('visibilitychange', vis);
    return () => {
      document.removeEventListener('visibilitychange', vis);
      const s = Math.round((acumulado.current + (document.hidden ? 0 : Date.now() - inicio.current)) / 1000);
      if (s >= 5) {
        fetch(`${BASE}/eng/uso`, { method: 'POST', credentials: 'include', keepalive: true,
          headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ tema, tipo, segundos: Math.min(s, 7200) }) }).catch(() => undefined);
      }
    };
  }, [tema, tipo]);
}

export function Avaliacao(props: { tema: string | null; ferramenta: string; titulo: string; curso?: boolean; modo?: ModoAvaliacao;
  aberto?: boolean; aoSalvar?: () => void }) {
  const modo: ModoAvaliacao = props.modo ?? (props.curso ? 'curso' : props.ferramenta.startsWith('teste_') ? 'teste' : 'peca');
  const [aberto, setAberto] = useState(props.aberto ?? false);
  const [v, setV] = useState<Valores>({});
  const [mats, setMats] = useState<string[]>([]);
  const [salvo, setSalvo] = useState<string | null>(null);
  useEffect(() => {
    if (!aberto) return;
    apiGet<{ avaliacoes: (Valores & { materiais_usados?: string[] | null })[] }>(`/eng/avaliacoes?tema=${props.tema ?? ''}`)
      .then((d) => {
        const a = d.avaliacoes.find((x) => x.ferramenta === props.ferramenta);
        if (a) { const { materiais_usados: m, ...resto } = a; setV(resto as Valores); setMats(m ?? []); }
      })
      .catch(() => undefined);
  }, [aberto, props.tema, props.ferramenta]);

  async function salvar() {
    try {
      await apiPost('/eng/avaliacoes', { ...v, materiais_usados: modo === 'tema' || modo === 'curso' ? mats : null, tema: props.tema, ferramenta: props.ferramenta });
      setSalvo('Avaliação salva. Obrigado!'); props.aoSalvar?.();
    } catch { setSalvo('Não foi possível salvar agora.'); }
  }
  const escalas = [...QUALIDADE, ...DOSAGEM, ...(modo === 'peca' ? [] : [FREQUENCIA])];
  const alvo = modo === 'curso' ? 'este curso' : modo === 'tema' ? 'este tema' : modo === 'teste' ? 'este teste' : 'esta peça';
  if (!aberto) return <button type="button" className="botao discreto" onClick={() => setAberto(true)}>Avaliar {alvo}</button>;
  const escala = (e: Escala) => (
    <div key={e.chave} className="escala">
      <span>{e.rotulo}</span>
      <div role="radiogroup" aria-label={e.rotulo}>
        {[1, 2, 3, 4, 5].map((n) => (
          <button key={n} type="button" role="radio" aria-checked={v[e.chave] === n} className={v[e.chave] === n ? 'sel' : ''}
            title={n === 1 ? e.baixo : n === 5 ? e.alto : n === 3 && e.meio ? e.meio : ''}
            onClick={() => setV({ ...v, [e.chave]: n })}>{n}</button>
        ))}
      </div>
      <small>1 = {e.baixo}{e.meio ? ` · 3 = ${e.meio}` : ''} · 5 = {e.alto}</small>
    </div>
  );
  return (
    <div className="cartao-app avaliacao">
      <h3 style={{ marginTop: 0 }}>Avaliação: {props.titulo}</h3>
      <p className="nota-escala">De 0 a 10, quanto você recomendaria {alvo} a um colega?</p>
      <div className="nps" role="radiogroup" aria-label="Nota de 0 a 10">
        {Array.from({ length: 11 }, (_, n) => (
          <button key={n} type="button" role="radio" aria-checked={v.nps === n} className={v.nps === n ? 'sel' : ''} onClick={() => setV({ ...v, nps: n })}>{n}</button>
        ))}
      </div>
      <div className="escala">
        <span>{modo === 'teste' ? 'O teste e o gabarito foram úteis?' : 'Foi útil para você?'}</span>
        <div role="radiogroup" aria-label="Utilidade">
          {([[1, 'Sim'], [2, 'Em parte'], [3, 'Não']] as [number, string][]).map(([n, r]) => (
            <button key={n} type="button" role="radio" aria-checked={v.utilidade === n} className={v.utilidade === n ? 'sel' : ''}
              style={{ width: 'auto', padding: '0 12px' }} onClick={() => setV({ ...v, utilidade: n })}>{r}</button>
          ))}
        </div>
      </div>
      {escalas.map(escala)}
      {(modo === 'tema' || modo === 'curso') && (
        <fieldset className="materiais">
          <legend>Quais materiais você usou?</legend>
          {MATERIAIS.map(([k, r]) => (
            <label key={k}><input type="checkbox" checked={mats.includes(k)}
              onChange={(ev) => setMats(ev.target.checked ? [...mats, k] : mats.filter((x) => x !== k))} /> {r}</label>
          ))}
        </fieldset>
      )}
      <label className="escala"><span>{modo === 'teste' ? 'Minutos que levou para resolver' : 'Minutos que você gastou'}</span>
        <input type="number" min={0} max={600} value={(v.minutos_gastos as number | null) ?? ''} onChange={(ev) => setV({ ...v, minutos_gastos: ev.target.value === '' ? null : Number(ev.target.value) })} />
      </label>
      <textarea placeholder="Comentário (opcional)" value={(v.comentario as string | null) ?? ''} onChange={(ev) => setV({ ...v, comentario: ev.target.value })} />
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 8 }}>
        <button type="button" className="botao" onClick={salvar}>Salvar avaliação</button>
        {props.aberto === undefined && <button type="button" className="botao discreto" onClick={() => setAberto(false)}>Fechar</button>}
        {salvo && <span role="status">{salvo}</span>}
      </div>
    </div>
  );
}

export function Pergunta(props: { tema: string | null; ferramenta: string | null }) {
  const [aberto, setAberto] = useState(false);
  const [tipo, setTipo] = useState<'duvida' | 'feedback'>('duvida');
  const [texto, setTexto] = useState('');
  const [msg, setMsg] = useState<string | null>(null);
  async function enviar() {
    try {
      await apiPost('/eng/mensagens', { tema: props.tema, ferramenta: props.ferramenta, tipo, texto });
      setTexto('');
      setMsg(tipo === 'duvida' ? 'Dúvida enviada à coordenação. A resposta aparece em "Dúvidas" e, se você autorizou, chega por e-mail.' : 'Feedback registrado. Obrigado!');
    } catch { setMsg('Escreva pelo menos algumas palavras.'); }
  }
  if (!aberto) return <button type="button" className="botao discreto" onClick={() => setAberto(true)}>Enviar dúvida ou feedback</button>;
  return (
    <div className="cartao-app">
      <div className="etapas" role="radiogroup" aria-label="Tipo">
        <button type="button" className={`etapa${tipo === 'duvida' ? ' atual' : ''}`} onClick={() => setTipo('duvida')}>Dúvida para a coordenação</button>
        <button type="button" className={`etapa${tipo === 'feedback' ? ' atual' : ''}`} onClick={() => setTipo('feedback')}>Feedback para a coordenação</button>
      </div>
      <textarea value={texto} onChange={(e) => setTexto(e.target.value)} placeholder={tipo === 'duvida' ? 'Qual é a sua dúvida sobre este material?' : 'O que funcionou, o que mudaria?'} />
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 8 }}>
        <button type="button" className="botao" onClick={enviar}>Enviar</button>
        <button type="button" className="botao discreto" onClick={() => setAberto(false)}>Fechar</button>
        {msg && <span role="status">{msg}</span>}
      </div>
    </div>
  );
}

// Rodape de cada peca: avaliar, perguntar e registrar o tempo de leitura.
export function Engajamento(props: { tema: string; ferramenta: string; titulo: string }) {
  useTempoDeUso(props.tema, props.ferramenta);
  return (
    <div className="engajamento">
      <Avaliacao tema={props.tema} ferramenta={props.ferramenta} titulo={props.titulo} />
      <Pergunta tema={props.tema} ferramenta={props.ferramenta} />
    </div>
  );
}

// Termo de consentimento para uso dos dados em pesquisa (TCLE). Texto final depende do CEP.
export function ConsentimentoPesquisa() {
  const [estado, setEstado] = useState<{ consentimento: { aceito: boolean } | null; versao_atual: string } | null>(null);
  useEffect(() => { apiGet<{ consentimento: { aceito: boolean } | null; versao_atual: string }>('/eng/consentimento').then(setEstado).catch(() => undefined); }, []);
  async function responder(aceito: boolean) {
    try { await apiPost('/eng/consentimento', { aceito }); setEstado(estado ? { ...estado, consentimento: { aceito } } : null); } catch { /* segue */ }
  }
  if (!estado || estado.consentimento) return null;
  return (
    <article className="cartao-app" style={{ gridColumn: '1 / -1' }}>
      <span className="rotulo">Pesquisa</span>
      <h3>Uso dos seus dados em pesquisa</h3>
      <p>Este programa faz parte de um estudo sobre o método de ensino. Se você concordar, suas notas, o tempo de estudo, as avaliações e as dúvidas entram na análise <strong>sem o seu nome</strong> (com um código). Você pode participar do curso normalmente sem concordar, e pode mudar de ideia a qualquer momento. Termo {estado.versao_atual}.</p>
      <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        <button type="button" className="botao" onClick={() => responder(true)}>Concordo em participar</button>
        <button type="button" className="botao discreto" onClick={() => responder(false)}>Não concordo</button>
      </p>
    </article>
  );
}
