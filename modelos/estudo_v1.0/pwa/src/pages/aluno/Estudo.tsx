import { useEffect, useMemo, useRef, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const GRAUS = ['', 'Muito fácil', 'Fácil', 'Média', 'Difícil', 'Muito difícil', 'Especialista'];

interface TemaQ { codigo: string; titulo: string; questoes: number; por_grau: Record<string, number> }
interface TemaF { codigo: string; titulo: string; oficiais: number; meus: number; colegas: number }
interface Hist { id: number; criado_em: string; questoes: number; acertos: number | null; filtros: { temas?: string[] } }
interface Opcoes { temas: TemaQ[]; flashcards: TemaF[]; historico: Hist[]; assinatura: { nome: string; apelido: string | null } }
interface Alt { alternativa_id: number; texto: string; correta: boolean | null; justificativa: string | null }
interface Questao { item_id: number; tema: string; enunciado: string; caso: string | null; grau: number; escolhida: number | null; alternativas: Alt[] }
interface Simulado { id: number; concluido: boolean; acertos: number | null; questoes: Questao[] }
interface Card { chave: string; tema: string; frente: string; verso: string; origem: 'oficial' | 'meu' | 'colega'; autor: string | null; acertos: number; erros: number }
interface MeuCard { id: number; tema: string; frente: string; verso: string; compartilhado: boolean; oculto: boolean }

type Aba = 'simulado' | 'flashcards' | 'criar';

// Estudo dirigido: o aluno monta o proprio simulado e o proprio deck. Nada aqui conta para nota ou ranking.
export function Estudo() {
  const [op, setOp] = useState<Opcoes | null>(null);
  const [falha, setFalha] = useState(false);
  const inicial = (new URLSearchParams(window.location.search).get('aba') as Aba) || 'simulado';
  const [aba, setAba] = useState<Aba>(['simulado', 'flashcards', 'criar'].includes(inicial) ? inicial : 'simulado');
  const carregar = () => { apiGet<Opcoes>('/estudo/opcoes').then(setOp).catch(() => setFalha(true)); };
  useEffect(carregar, []);

  if (falha) return <section><h1>Estudo dirigido</h1><p role="alert">Não foi possível carregar agora. Tente de novo em instantes.</p></section>;
  if (!op) return <section><h1>Estudo dirigido</h1><p>Carregando…</p></section>;
  return (
    <section className="estudo">
      <h1>Estudo dirigido</h1>
      <p className="sub">Monte seu próprio treino com o que você já estudou. <strong>Não conta para nota nem para o ranking.</strong></p>
      <div className="abas" role="tablist" aria-label="Tipo de estudo">
        {([['simulado', 'Simulado'], ['flashcards', 'Flashcards'], ['criar', 'Criar flashcard']] as [Aba, string][]).map(([k, r]) => (
          <button key={k} type="button" role="tab" aria-selected={aba === k} className={aba === k ? 'sel' : ''} onClick={() => setAba(k)}>{r}</button>
        ))}
      </div>
      {aba === 'simulado' && <AbaSimulado op={op} recarregar={carregar} />}
      {aba === 'flashcards' && <AbaDeck op={op} irCriar={() => setAba('criar')} />}
      {aba === 'criar' && <AbaCriar op={op} recarregar={carregar} />}
    </section>
  );
}

function SeletorTemas(props: { temas: { codigo: string; titulo: string; n: number }[]; sel: string[]; mudar: (s: string[]) => void; rotulo: string }) {
  const { temas, sel, mudar } = props;
  const todos = sel.length === 0;
  return (
    <fieldset className="campo-estudo">
      <legend>{props.rotulo}</legend>
      <label className="marca"><input type="checkbox" checked={todos} onChange={() => mudar([])} /> Todos os liberados ({temas.length})</label>
      <div className="lista-temas">
        {temas.map((t) => (
          <label key={t.codigo} className="marca">
            <input type="checkbox" checked={sel.includes(t.codigo)}
              onChange={(e) => mudar(e.target.checked ? [...sel, t.codigo] : sel.filter((c) => c !== t.codigo))} />
            <span><strong>{t.codigo}</strong> {t.titulo} <small>({t.n})</small></span>
          </label>
        ))}
      </div>
    </fieldset>
  );
}

// ---------- simulado ----------
function AbaSimulado({ op, recarregar }: { op: Opcoes; recarregar: () => void }) {
  const [temas, setTemas] = useState<string[]>([]);
  const [min, setMin] = useState(1);
  const [max, setMax] = useState(6);
  const [qtd, setQtd] = useState(10);
  const [sim, setSim] = useState<Simulado | null>(null);
  const [resp, setResp] = useState<Record<number, number>>({});
  const [msg, setMsg] = useState<string | null>(null);
  const [ocupado, setOcupado] = useState(false);
  const inicio = useRef(Date.now());

  const disponiveis = useMemo(() => op.temas.filter((t) => temas.length === 0 || temas.includes(t.codigo))
    .reduce((s, t) => s + Object.entries(t.por_grau).filter(([g]) => Number(g) >= Math.min(min, max) && Number(g) <= Math.max(min, max)).reduce((a, [, k]) => a + k, 0), 0), [op, temas, min, max]);

  async function montar() {
    setOcupado(true); setMsg(null);
    try {
      const s = await apiPost<Simulado>('/estudo/simulados', { temas, grau_min: min, grau_max: max, quantidade: qtd });
      setSim(s); setResp({}); inicio.current = Date.now(); window.scrollTo(0, 0);
    } catch { setMsg('Não há questões com esses filtros. Amplie a dificuldade ou escolha mais temas.'); }
    setOcupado(false);
  }
  async function entregar() {
    if (!sim) return;
    const faltam = sim.questoes.length - Object.keys(resp).length;
    if (faltam > 0 && !window.confirm(`Faltam ${faltam} questão(ões) sem resposta. Entregar mesmo assim?`)) return;
    setOcupado(true);
    try {
      setSim(await apiPost<Simulado>(`/estudo/simulados/${sim.id}/entregar`, { respostas: resp, segundos: Math.round((Date.now() - inicio.current) / 1000) }));
      window.scrollTo(0, 0); recarregar();
    } catch { setMsg('Não foi possível entregar agora. Suas respostas continuam na tela; tente de novo.'); }
    setOcupado(false);
  }
  async function abrir(id: number) { setSim(await apiGet<Simulado>(`/estudo/simulados/${id}`)); setResp({}); window.scrollTo(0, 0); }

  if (sim) {
    return (
      <div>
        {sim.concluido
          ? <article className="cartao-app destaque" role="status"><h2 style={{ margin: 0 }}>Você acertou {sim.acertos} de {sim.questoes.length} ({Math.round(100 * (sim.acertos ?? 0) / sim.questoes.length)}%)</h2>
              <p>Veja abaixo o gabarito e a explicação de cada alternativa.</p>
              <button type="button" className="botao" onClick={() => setSim(null)}>Montar outro simulado</button></article>
          : <p className="sub">{sim.questoes.length} questões sorteadas · respondidas {Object.keys(resp).length}</p>}
        {sim.questoes.map((q, i) => (
          <article key={q.item_id} className="cartao-app questao-estudo">
            <p className="rotulo">Questão {i + 1} · {q.tema} · {GRAUS[q.grau] ?? ''}</p>
            {q.caso && <details><summary>Caso clínico</summary><p className="texto-q">{q.caso}</p></details>}
            <p className="texto-q"><strong>{q.enunciado}</strong></p>
            <div role="radiogroup" aria-label={`Alternativas da questão ${i + 1}`}>
              {q.alternativas.map((a, k) => {
                const marcada = sim.concluido ? q.escolhida === a.alternativa_id : resp[q.item_id] === a.alternativa_id;
                const cls = sim.concluido ? (a.correta ? 'certa' : marcada ? 'errada' : '') : marcada ? 'marcada' : '';
                return (
                  <label key={a.alternativa_id} className={`alt ${cls}`}>
                    <input type="radio" name={`q${q.item_id}`} checked={marcada} disabled={sim.concluido}
                      onChange={() => setResp({ ...resp, [q.item_id]: a.alternativa_id })} />
                    <span><strong>{String.fromCharCode(65 + k)}.</strong> {a.texto}
                      {sim.concluido && a.correta && <em> — correta</em>}
                      {sim.concluido && marcada && !a.correta && <em> — sua resposta</em>}
                      {sim.concluido && a.justificativa && <small className="just">{a.justificativa}</small>}</span>
                  </label>
                );
              })}
            </div>
            {sim.concluido && q.escolhida === null && <p><small>Você deixou esta questão em branco.</small></p>}
          </article>
        ))}
        {msg && <p role="alert">{msg}</p>}
        {!sim.concluido && <p className="acoes-fixas"><button type="button" className="botao" disabled={ocupado} onClick={entregar}>Entregar e ver o gabarito</button>{' '}
          <button type="button" className="botao discreto" onClick={() => { if (window.confirm('Sair sem entregar? As respostas serão perdidas.')) setSim(null); }}>Sair</button></p>}
      </div>
    );
  }

  if (op.temas.length === 0) {
    return <article className="cartao-app"><h2>Ainda não há questões para treinar</h2>
      <p>O simulado usa as questões dos testes que você <strong>já enviou</strong>. Assim que enviar o primeiro teste de um tema, ele aparece aqui.</p>
      <a className="botao" href="/aluno/pendencias">Ver minhas pendências</a></article>;
  }
  return (
    <div>
      <article className="cartao-app">
        <h2>Montar um simulado</h2>
        <SeletorTemas rotulo="1. Temas" temas={op.temas.map((t) => ({ codigo: t.codigo, titulo: t.titulo, n: t.questoes }))} sel={temas} mudar={setTemas} />
        <fieldset className="campo-estudo">
          <legend>2. Dificuldade (para o seu ano)</legend>
          <label>De <select value={min} onChange={(e) => setMin(Number(e.target.value))}>{GRAUS.slice(1).map((g, i) => <option key={g} value={i + 1}>{g}</option>)}</select></label>{' '}
          <label>até <select value={max} onChange={(e) => setMax(Number(e.target.value))}>{GRAUS.slice(1).map((g, i) => <option key={g} value={i + 1}>{g}</option>)}</select></label>
        </fieldset>
        <fieldset className="campo-estudo">
          <legend>3. Número de questões</legend>
          <div className="chips">{[5, 10, 20, 30].map((n) => <button key={n} type="button" className={`botao discreto ${qtd === n ? 'sel' : ''}`} aria-pressed={qtd === n} onClick={() => setQtd(n)}>{n}</button>)}
            <label className="outro">ou <input type="number" min={1} max={60} value={qtd} onChange={(e) => setQtd(Math.max(1, Math.min(60, Number(e.target.value) || 1)))} aria-label="Outro número de questões" /></label></div>
        </fieldset>
        <p><small>{disponiveis} questões disponíveis com esses filtros{disponiveis < qtd && disponiveis > 0 ? ` — o simulado terá ${disponiveis}.` : '.'} O sorteio é aleatório a cada vez.</small></p>
        {msg && <p role="alert">{msg}</p>}
        <button type="button" className="botao" disabled={ocupado || disponiveis === 0} onClick={montar}>Sortear e começar</button>
      </article>
      {op.historico.length > 0 && (
        <article className="cartao-app" style={{ marginTop: 16 }}>
          <h2>Simulados anteriores</h2>
          <ul className="lista-simples">
            {op.historico.map((h) => (
              <li key={h.id}><button type="button" className="link" onClick={() => abrir(h.id)}>
                {new Date(h.criado_em).toLocaleDateString('pt-BR')} · {h.questoes} questões · {h.acertos === null ? 'não entregue' : `${Math.round(100 * h.acertos / h.questoes)}% de acerto`}
                {h.filtros.temas && h.filtros.temas.length > 0 ? ` · ${h.filtros.temas.join(', ')}` : ' · todos os temas'}</button></li>
            ))}
          </ul>
        </article>
      )}
    </div>
  );
}

// ---------- deck de flashcards ----------
function AbaDeck({ op, irCriar }: { op: Opcoes; irCriar: () => void }) {
  const [temas, setTemas] = useState<string[]>([]);
  const [fontes, setFontes] = useState<string[]>(['oficiais', 'meus', 'colegas']);
  const [qtd, setQtd] = useState(20);
  const [dificeis, setDificeis] = useState(false);
  const [deck, setDeck] = useState<Card[] | null>(null);
  const [i, setI] = useState(0);
  const [virado, setVirado] = useState(false);
  const [placar, setPlacar] = useState({ sei: 0, nao: 0 });
  const [msg, setMsg] = useState<string | null>(null);

  const [devidos, setDevidos] = useState<{ vencidos: number; novos: number } | null>(null);
  useEffect(() => { apiGet<{ vencidos: number; novos: number }>('/extra/flashcards/devidos').then(setDevidos).catch(() => undefined); }, [deck]);
  async function montar(modo?: 'devidos') {
    setMsg(null);
    const r = await apiPost<{ cards: Card[] }>('/estudo/deck', modo ? { modo, quantidade: 40 } : { temas, fontes, quantidade: qtd, so_dificeis: dificeis }).catch(() => null);
    if (!r || r.cards.length === 0) { setMsg(modo ? 'Nada para revisar agora. Volte amanhã!' : dificeis ? 'Nenhum card marcado como difícil com esses filtros.' : 'Nenhum card com esses filtros.'); return; }
    setDeck(r.cards); setI(0); setVirado(false); setPlacar({ sei: 0, nao: 0 });
    setTimeout(() => document.querySelector('.estudo progress')?.scrollIntoView({ block: 'start', behavior: 'smooth' }), 60);
  }
  function responder(acertou: boolean) {
    const c = deck![i]!;
    apiPost('/estudo/revisao', { chave: c.chave, acertou }).catch(() => undefined);
    setPlacar({ sei: placar.sei + (acertou ? 1 : 0), nao: placar.nao + (acertou ? 0 : 1) });
    setVirado(false); setI(i + 1);
  }
  useEffect(() => {
    if (!deck) return undefined;
    const tecla = (e: KeyboardEvent) => {
      if ((e.target as HTMLElement).tagName === 'INPUT' || i >= deck.length) return;
      if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); setVirado((v) => !v); }
      if (virado && e.key === '1') responder(false);
      if (virado && e.key === '2') responder(true);
    };
    window.addEventListener('keydown', tecla);
    return () => window.removeEventListener('keydown', tecla);
  });

  if (deck) {
    if (i >= deck.length) {
      return <article className="cartao-app destaque" role="status"><h2>Deck concluído</h2>
        <p>Sabia: <strong>{placar.sei}</strong> · Preciso rever: <strong>{placar.nao}</strong></p>
        <button type="button" className="botao" onClick={() => setDeck(null)}>Montar outro deck</button>{' '}
        {placar.nao > 0 && <button type="button" className="botao discreto" onClick={() => { setDificeis(true); setDeck(null); }}>Rever só os difíceis</button>}</article>;
    }
    const c = deck[i]!;
    return (
      <div>
        <p className="sub" aria-live="polite">Card {i + 1} de {deck.length} · {c.tema}</p>
        <progress max={deck.length} value={i} aria-label="Progresso do deck" />
        <button type="button" className={`flash ${virado ? 'virado' : ''}`} onClick={() => setVirado(!virado)} aria-label={virado ? 'Resposta. Toque para voltar à pergunta' : 'Pergunta. Toque para ver a resposta'}>
          <span className={`selo ${c.origem}`}>{c.origem === 'oficial' ? 'Card do curso' : `Feito por aluno · ${c.autor ?? ''}${c.origem === 'meu' ? ' (você)' : ''}`}</span>
          <span className="texto-flash">{virado ? c.verso : c.frente}</span>
          <span className="dica">{virado ? 'Resposta' : 'Toque para ver a resposta'}</span>
        </button>
        {virado
          ? <p className="acoes-flash"><button type="button" className="botao discreto" onClick={() => responder(false)}>Preciso rever</button>
              <button type="button" className="botao" onClick={() => responder(true)}>Eu sabia</button></p>
          : <p className="acoes-flash"><button type="button" className="botao" onClick={() => setVirado(true)}>Ver a resposta</button></p>}
        <p><button type="button" className="link" onClick={() => setDeck(null)}>Encerrar o deck</button> <small className="so-desktop">· Teclado: espaço vira, 1 = rever, 2 = sabia</small></p>
      </div>
    );
  }

  if (op.flashcards.length === 0) {
    return <article className="cartao-app"><h2>Ainda não há flashcards liberados</h2>
      <p>Os flashcards de um tema ficam disponíveis <strong>depois da aula</strong> (quando você envia o pós-teste). A partir daí você também pode criar os seus.</p></article>;
  }
  const marca = (f: string) => setFontes(fontes.includes(f) ? fontes.filter((x) => x !== f) : [...fontes, f]);
  const tot = (k: 'oficiais' | 'meus' | 'colegas') => op.flashcards.filter((t) => temas.length === 0 || temas.includes(t.codigo)).reduce((s, t) => s + t[k], 0);
  return (
    <>
    <article className="cartao-app destaque revisao-dia">
      <h2>Revisão do dia</h2>
      <p>Repetição espaçada: cada card volta no momento certo. Acertou, o intervalo cresce (1 dia, 3 dias, depois cada vez mais); errou, ele volta ainda hoje.</p>
      <p><strong>{devidos ? `${devidos.vencidos} para revisar · ${devidos.novos} novos` : '…'}</strong></p>
      <button type="button" className="botao" disabled={!devidos || devidos.vencidos + devidos.novos === 0} onClick={() => montar('devidos')}>Começar a revisão do dia</button>
    </article>
    <article className="cartao-app" style={{ marginTop: 16 }}>
      <h2>Montar um deck</h2>
      <SeletorTemas rotulo="1. Temas" temas={op.flashcards.map((t) => ({ codigo: t.codigo, titulo: t.titulo, n: t.oficiais + t.meus + t.colegas }))} sel={temas} mudar={setTemas} />
      <fieldset className="campo-estudo">
        <legend>2. Quais cards</legend>
        <label className="marca"><input type="checkbox" checked={fontes.includes('oficiais')} onChange={() => marca('oficiais')} /> Cards do curso ({tot('oficiais')})</label>
        <label className="marca"><input type="checkbox" checked={fontes.includes('meus')} onChange={() => marca('meus')} /> Meus cards ({tot('meus')})</label>
        <label className="marca"><input type="checkbox" checked={fontes.includes('colegas')} onChange={() => marca('colegas')} /> Feitos por colegas ({tot('colegas')})</label>
        <label className="marca"><input type="checkbox" checked={dificeis} onChange={(e) => setDificeis(e.target.checked)} /> Só os que eu mais erro</label>
      </fieldset>
      <fieldset className="campo-estudo">
        <legend>3. Número de cards</legend>
        <div className="chips">{[10, 20, 40, 80].map((n) => <button key={n} type="button" className={`botao discreto ${qtd === n ? 'sel' : ''}`} aria-pressed={qtd === n} onClick={() => setQtd(n)}>{n}</button>)}</div>
      </fieldset>
      {msg && <p role="alert">{msg}</p>}
      <button type="button" className="botao" disabled={fontes.length === 0} onClick={() => montar()}>Embaralhar e começar</button>{' '}
      <button type="button" className="botao discreto" onClick={irCriar}>Criar um card</button>
    </article>
    </>
  );
}

// ---------- criar flashcards ----------
function AbaCriar({ op, recarregar }: { op: Opcoes; recarregar: () => void }) {
  const [meus, setMeus] = useState<MeuCard[]>([]);
  const [editando, setEditando] = useState<number | null>(null);
  const [tema, setTema] = useState(op.flashcards[0]?.codigo ?? '');
  const [frente, setFrente] = useState('');
  const [verso, setVerso] = useState('');
  const [compartilhar, setCompartilhar] = useState(false);
  const [apelido, setApelido] = useState(op.assinatura.apelido ?? '');
  const [usarApelido, setUsarApelido] = useState(Boolean(op.assinatura.apelido));
  const [msg, setMsg] = useState<string | null>(null);
  const listar = () => { apiGet<{ cards: MeuCard[] }>('/estudo/flashcards').then((d) => setMeus(d.cards)).catch(() => undefined); };
  useEffect(listar, []);

  const assinatura = usarApelido && apelido.trim().length >= 2 ? apelido.trim() : op.assinatura.nome;
  async function salvar(outro: boolean) {
    setMsg(null);
    if (frente.trim().length < 3 || verso.trim().length < 1) { setMsg('Escreva a pergunta (frente) e a resposta (verso).'); return; }
    if (compartilhar && usarApelido && apelido.trim().length < 2) { setMsg('O apelido precisa ter pelo menos 2 letras.'); return; }
    try {
      if (compartilhar) await apiPost('/estudo/apelido', { apelido: usarApelido ? apelido.trim() : '' });
      await apiPost('/estudo/flashcards', { id: editando, tema, frente, verso, compartilhar });
      setMsg(compartilhar ? `Card salvo e compartilhado com quem faz o tema ${tema}, assinado como “${assinatura}”.` : 'Card salvo só para você.');
      setFrente(''); setVerso(''); setEditando(null); if (!outro) setCompartilhar(false);
      listar(); recarregar();
    } catch { setMsg('Não foi possível salvar. Confira o tamanho do texto (frente até 500 e verso até 1500 caracteres).'); }
  }
  function editar(c: MeuCard) { setEditando(c.id); setTema(c.tema); setFrente(c.frente); setVerso(c.verso); setCompartilhar(c.compartilhado); window.scrollTo(0, 0); }
  async function apagar(c: MeuCard) {
    if (!window.confirm('Apagar este card? Se estiver compartilhado, ele some para todos.')) return;
    await fetch(`${BASE}/estudo/flashcards/${c.id}`, { method: 'DELETE', credentials: 'include' });
    listar(); recarregar();
  }

  if (op.flashcards.length === 0) {
    return <article className="cartao-app"><h2>Criar flashcards</h2><p>Você pode criar cards dos temas em que já fez a aula (pós-teste enviado). Nenhum tema chegou a essa fase ainda.</p></article>;
  }
  return (
    <div>
      <article className="cartao-app">
        <h2>{editando ? 'Editar card' : 'Novo flashcard'}</h2>
        <label className="campo-estudo">Tema
          <select value={tema} onChange={(e) => setTema(e.target.value)}>{op.flashcards.map((t) => <option key={t.codigo} value={t.codigo}>{t.codigo} — {t.titulo}</option>)}</select></label>
        <label className="campo-estudo">Frente (pergunta) <small>{frente.length}/500</small>
          <textarea value={frente} maxLength={500} onChange={(e) => setFrente(e.target.value)} placeholder="Ex.: Qual a tríade letal do trauma?" /></label>
        <label className="campo-estudo">Verso (resposta) <small>{verso.length}/1500</small>
          <textarea value={verso} maxLength={1500} onChange={(e) => setVerso(e.target.value)} placeholder="Resposta curta e direta." /></label>
        <p><small>Não escreva dados de pacientes reais (nome, registro, data, leito).</small></p>
        <fieldset className="campo-estudo compartilhar">
          <legend>Compartilhar</legend>
          <label className="marca"><input type="checkbox" checked={compartilhar} onChange={(e) => setCompartilhar(e.target.checked)} />
            <span>Autorizo distribuir este card a <strong>todos os participantes do tema {tema}</strong>. Ele aparece marcado como “feito por aluno”, com a minha assinatura.</span></label>
          {compartilhar && (
            <div className="assinatura">
              <label className="marca"><input type="radio" name="ass" checked={!usarApelido} onChange={() => setUsarApelido(false)} /> Assinar com meu nome: <strong>{op.assinatura.nome}</strong></label>
              <label className="marca"><input type="radio" name="ass" checked={usarApelido} onChange={() => setUsarApelido(true)} /> Assinar com um apelido:
                <input type="text" value={apelido} maxLength={40} onFocus={() => setUsarApelido(true)} onChange={(e) => setApelido(e.target.value)} aria-label="Apelido" placeholder="apelido" /></label>
              <small>A assinatura vale para todos os seus cards compartilhados. O card é publicado na hora, sem passar por revisor.</small>
            </div>
          )}
        </fieldset>
        {msg && <p role="status">{msg}</p>}
        <button type="button" className="botao" onClick={() => salvar(false)}>{editando ? 'Salvar alterações' : 'Salvar card'}</button>{' '}
        {!editando && <button type="button" className="botao discreto" onClick={() => salvar(true)}>Salvar e criar outro</button>}
        {editando && <button type="button" className="botao discreto" onClick={() => { setEditando(null); setFrente(''); setVerso(''); }}>Cancelar</button>}
      </article>
      <h2>Meus cards ({meus.length})</h2>
      {meus.length === 0 ? <p>Você ainda não criou nenhum card.</p> : (
        <ul className="lista-cards">
          {meus.map((c) => (
            <li key={c.id} className="cartao-app">
              <p className="rotulo">{c.tema} · {c.oculto ? 'ocultado pela coordenação' : c.compartilhado ? 'compartilhado com o tema' : 'só para mim'}</p>
              <p><strong>{c.frente}</strong></p><p>{c.verso}</p>
              <button type="button" className="link" onClick={() => editar(c)}>Editar</button> · <button type="button" className="link" onClick={() => apagar(c)}>Apagar</button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
