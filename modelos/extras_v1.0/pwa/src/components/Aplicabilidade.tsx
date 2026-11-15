import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

interface Pend { codigo: string; titulo: string; concluido_em: string }
const USO = ['Nenhuma vez', '1 vez', '2 a 3 vezes', '4 a 10 vezes', 'Mais de 10 vezes'];

function Formulario({ p, aoSalvar }: { p: Pend; aoSalvar: () => void }) {
  const [usou, setUsou] = useState<number | null>(null);
  const [mudou, setMudou] = useState<boolean | null>(null);
  const [conf, setConf] = useState<number | null>(null);
  const [exemplo, setExemplo] = useState('');
  const [barreira, setBarreira] = useState('');
  const [erro, setErro] = useState<string | null>(null);
  async function salvar(dispensado = false) {
    if (!dispensado && (usou === null || conf === null)) { setErro('Responda pelo menos o uso e a segurança.'); return; }
    await apiPost('/extra/aplicabilidade', { tema: p.codigo, usou, mudou_conduta: mudou, confianca: conf, exemplo, barreira, dispensado }).catch(() => undefined);
    aoSalvar();
  }
  return (
    <article className="cartao-app aplicabilidade">
      <span className="rotulo">30 dias depois · {p.codigo}</span>
      <h3>{p.titulo}</h3>
      <p><strong>No último mês, quantas vezes você usou o que aprendeu neste tema no plantão?</strong></p>
      <div className="chips">{USO.map((u, i) => <button key={u} type="button" className={`botao discreto${usou === i ? ' sel' : ''}`} aria-pressed={usou === i} onClick={() => setUsou(i)}>{u}</button>)}</div>
      <p><strong>Mudou alguma conduta sua?</strong></p>
      <div className="chips">{[['Sim', true], ['Não', false]].map(([r, v]) => <button key={String(r)} type="button" className={`botao discreto${mudou === v ? ' sel' : ''}`} aria-pressed={mudou === v} onClick={() => setMudou(v as boolean)}>{String(r)}</button>)}</div>
      <p><strong>Hoje, quão seguro você se sente para conduzir este tema sozinho no plantão?</strong> (1 = nada, 5 = totalmente)</p>
      <div className="chips">{[1, 2, 3, 4, 5].map((n) => <button key={n} type="button" className={`botao discreto${conf === n ? ' sel' : ''}`} aria-pressed={conf === n} onClick={() => setConf(n)}>{n}</button>)}</div>
      <label className="bloco">Um exemplo de caso em que usou (opcional, sem dados do paciente)<textarea value={exemplo} maxLength={1500} onChange={(e) => setExemplo(e.target.value)} /></label>
      <label className="bloco">O que dificultou aplicar? (opcional)<textarea value={barreira} maxLength={1500} onChange={(e) => setBarreira(e.target.value)} /></label>
      {erro && <p role="alert">{erro}</p>}
      <p><button type="button" className="botao" onClick={() => salvar(false)}>Enviar</button>{' '}
        <button type="button" className="botao discreto" onClick={() => salvar(true)}>Agora não</button></p>
    </article>
  );
}

// Aplicabilidade na pratica: aparece 30 dias depois do pos-teste D0 de cada tema.
export function Aplicabilidade() {
  const [lista, setLista] = useState<Pend[]>([]);
  const carregar = () => { apiGet<{ pendentes: Pend[] }>('/extra/aplicabilidade').then((d) => setLista(d.pendentes)).catch(() => undefined); };
  useEffect(carregar, []);
  if (lista.length === 0) return null;
  return (
    <section className="aplicabilidade-lista" aria-labelledby="aplic-t">
      <h2 id="aplic-t">Aplicabilidade na prática ({lista.length})</h2>
      <p><small>Leva 1 minuto. Mostra à coordenação o que o curso muda de fato no plantão.</small></p>
      {lista.map((p) => <Formulario key={p.codigo} p={p} aoSalvar={carregar} />)}
    </section>
  );
}
