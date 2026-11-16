import { useEffect, useState } from 'react';

// Revisao > Para revisar: o que os agentes da coordenacao prepararam. Nada chega ao aluno sem uma decisao aqui.
// Aprovar executa como veio; Alterar aplica o que voce editou; Vetar exige o motivo, que o agente le na proxima rodada.
const API = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

type J = Record<string, unknown>;
interface Proposta {
  proposta_id: number; agente: string; tipo: string; titulo: string; proposta: J; justificativa: string | null;
  fontes: unknown[]; confianca: string | null; criado_em: string; status: string; motivo: string | null;
  decisao: J | null; decidido_em: string | null; contexto: J | null;
}
interface Agente {
  agente: string; aguardando: number; mais_antiga_horas: number | null; decididas_60d: number; aprovadas_como_vieram: number;
  alteradas: number; vetadas: number; aprovadas_sem_alteracao_pct: number | null; duvidas_sem_resposta_24h: number | null;
}

const NOME: Record<string, string> = {
  duvidas: 'Dúvidas dos alunos', conteudo: 'Revisor de conteúdo', pecas: 'Pré-revisão das peças', fontes: 'Triador de fontes',
  atrasados: 'Alunos atrasados', indicadores: 'Indicadores clínicos',
};
const SUGESTAO: Record<string, string> = { aprovar: 'Sugere aprovar', conferir: 'Sugere conferir melhor', reprovar: 'Sugere reprovar' };
const DECISAO: [string, string][] = [['correto', 'Correto'], ['erro_leve', 'Erro leve'], ['erro_critico', 'Erro crítico']];
const VEREDITO: Record<string, string> = { pronta: 'Pronta para a revisão de conteúdo', ajustar: 'Ajustar antes', refazer: 'Refazer' };

// mesma regra do banco (app.proposta_sugere_liberar, 97): o agente sugere liberar
const sugereLiberar = (p: Proposta) => p.status === 'aguardando' && (
  (p.tipo === 'parecer' && p.proposta.sugestao === 'aprovar' && (!p.proposta.decisao || p.proposta.decisao === 'correto'))
  || (p.tipo === 'pre_revisao' && p.proposta.veredito === 'pronta'));

const s = (v: unknown) => (v === null || v === undefined ? '' : String(v));
const data = (v: string | null) => (v ? new Date(v).toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' }) : '');

// Campos que a coordenacao pode editar em cada tipo de proposta
const EDITAVEIS: Record<string, string[]> = {
  resposta: ['texto'], parecer: ['decisao', 'comentario'], lembrete: ['assunto', 'texto'],
  lancamento: ['numerador', 'denominador', 'fonte'], pre_revisao: ['resumo'], fonte: ['temas_texto', 'camada'], relatorio: ['texto'], pendencia: ['texto'], alerta: ['texto'],
};

function Fontes(props: { fontes: unknown[] }) {
  if (!props.fontes?.length) return null;
  return (
    <details className="pr-fontes"><summary>Fontes usadas ({props.fontes.length})</summary>
      <ul>{props.fontes.map((f, i) => {
        const o = (typeof f === 'object' && f ? f : { texto: f }) as J;
        const url = s(o.url) || (o.pmid ? `https://pubmed.ncbi.nlm.nih.gov/${s(o.pmid)}/` : o.doi ? `https://doi.org/${s(o.doi)}` : '');
        return <li key={i}>{s(o.titulo || o.texto || o.referencia)}{o.trecho ? <q> {s(o.trecho)}</q> : null}{url && <> · <a href={url} target="_blank" rel="noreferrer">abrir</a></>}</li>;
      })}</ul>
    </details>
  );
}

function Cartao(props: { p: Proposta; decidido: () => void }) {
  const { p } = props;
  const campos = EDITAVEIS[p.tipo] ?? [];
  // fonte: os temas viram uma lista editavel ("T-004, T-005")
  const base: J = p.tipo === 'fonte'
    ? { ...p.proposta, temas_texto: Array.isArray(p.proposta.temas) ? (p.proposta.temas as J[]).map((t) => s(t.tema)).join(', ') : '' }
    : p.proposta;
  const [ed, setEd] = useState<J>(() => Object.fromEntries(campos.map((c) => [c, base[c] ?? ''])));
  const [motivo, setMotivo] = useState('');
  const [vetando, setVetando] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);
  const mudou = campos.some((c) => s(ed[c]) !== s(base[c] ?? ''));
  const ctx = p.contexto ?? {};
  const aberta = p.status === 'aguardando';

  async function decidir(decisao: 'aprovar' | 'alterar' | 'vetar') {
    setMsg(null);
    if (decisao === 'vetar' && motivo.trim().length < 5) { setMsg('Escreva o motivo do veto: o agente usa isso para não repetir o erro.'); return; }
    const final: J = {};
    if (decisao === 'alterar') for (const c of campos) final[c] = ['numerador', 'denominador', 'camada'].includes(c) ? Number(ed[c]) : ed[c];
    setEnviando(true);
    const r = await fetch(`${API}/coordenacao/propostas/${p.proposta_id}/decidir`, {
      method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ decisao, final: decisao === 'alterar' ? final : undefined, motivo: motivo || undefined }),
    }).catch(() => null);
    setEnviando(false);
    if (r?.ok) { props.decidido(); return; }
    const e = r ? ((await r.json().catch(() => ({}))) as J).erro : null;
    setMsg(e === 'escolha_a_decisao' ? 'Escolha a decisão (correto, erro leve ou erro crítico) antes de aprovar.'
      : e === 'proposta_ja_decidida' ? 'Esta proposta já foi decidida por outra pessoa da coordenação.'
      : e === 'so_coordenacao' ? 'Só a coordenação decide as propostas.'
      : e === 'resposta_curta' || e === 'lembrete_sem_texto' ? 'O texto está curto demais.'
      : e === 'fonte_nao_encontrada' ? 'O arquivo desta fonte ainda não chegou ao sistema. Tente de novo em 10 minutos.'
      : 'Não foi possível registrar agora. Tente de novo.');
  }

  const campoTexto = (c: string, rotulo: string, linhas = 5) => (
    <label className="pr-campo">{rotulo}
      {aberta ? <textarea rows={linhas} value={s(ed[c])} onChange={(e) => setEd({ ...ed, [c]: e.target.value })} />
              : <p className="pr-texto">{s((p.decisao ?? p.proposta)[c])}</p>}
    </label>
  );

  return (
    <article className={`pr-cartao ${p.status}`}>
      <header className="pr-cab">
        <span className="pr-agente">{NOME[p.agente] ?? p.agente}</span>
        <h3>{p.titulo}</h3>
        <span className="pr-meta">{data(p.criado_em)}{p.confianca ? ` · confiança ${p.confianca}` : ''}</span>
      </header>

      {p.tipo === 'resposta' && (<>
        <p className="pr-contexto"><strong>{s(ctx.aluno)}</strong> ({s(ctx.ano)}){ctx.tema ? ` · ${s(ctx.tema)}` : ''} · esperando há {s(ctx.horas_esperando)} h
          {Number(ctx.horas_esperando) >= 24 && <span className="pr-alerta"> · passou de 24 h</span>}</p>
        <blockquote className="pr-pergunta">{s(ctx.pergunta)}</blockquote>
        {campoTexto('texto', 'Resposta que o aluno vai receber', 7)}
      </>)}

      {p.tipo === 'parecer' && (<>
        <p className="pr-contexto">{s(ctx.tema)} · {s(ctx.peca)} (versão {s(ctx.versao)}) · fonte {s(ctx.fonte_arquivo)}</p>
        <blockquote className="pr-pergunta">{s(ctx.afirmacao)}</blockquote>
        {ctx.trecho_literal ? <p className="pr-trecho"><span>Trecho citado:</span> <q>{s(ctx.trecho_literal)}</q></p> : null}
        <p className={`pr-sugestao ${s(p.proposta.sugestao)}`}>{SUGESTAO[s(p.proposta.sugestao)] ?? s(p.proposta.sugestao)}</p>
        {aberta ? (
          <fieldset className="pr-decisao"><legend>Seu parecer</legend>
            {DECISAO.map(([v, r]) => (
              <label key={v}><input type="radio" name={`d${p.proposta_id}`} checked={ed.decisao === v} onChange={() => setEd({ ...ed, decisao: v })} /> {r}</label>
            ))}
            <label><input type="radio" name={`d${p.proposta_id}`} checked={!ed.decisao} onChange={() => setEd({ ...ed, decisao: '' })} /> Ainda não: vou conferir</label>
          </fieldset>
        ) : <p>Decisão: {s((p.decisao ?? p.proposta).decisao) || 'anotado para conferir'}</p>}
        {campoTexto('comentario', 'Comentário do parecer', 3)}
      </>)}

      {p.tipo === 'pre_revisao' && (<>
        <p className="pr-contexto">{s(ctx.tema)} · {s(ctx.peca)} (versão {s(ctx.versao)}) · <a href={`${s(ctx.revisao)}?aba=rascunhos`}>abrir a peça</a></p>
        <p className={`pr-sugestao ${s(p.proposta.veredito)}`}>{VEREDITO[s(p.proposta.veredito)] ?? s(p.proposta.veredito)}</p>
        {Array.isArray(p.proposta.itens) && (
          <ol className="pr-itens">{(p.proposta.itens as J[]).map((it, i) => (
            <li key={i}><span className="pr-tipo">{s(it.tipo)}</span> {it.trecho ? <q>{s(it.trecho)}</q> : null} {s(it.problema)}
              {it.correcao ? <><br /><span className="pr-corr">Correção proposta:</span> {s(it.correcao)}</> : null}</li>
          ))}</ol>
        )}
        {campoTexto('resumo', 'Resumo para quem revisa o conteúdo', 3)}
      </>)}

      {p.tipo === 'lembrete' && (<>
        <p className="pr-contexto"><strong>{s(ctx.aluno)}</strong> ({s(ctx.ano)})</p>
        {Array.isArray(p.proposta.pendencias) && <ul className="pr-itens">{(p.proposta.pendencias as J[]).map((x, i) => <li key={i}>{s(x.tema)} · {s(x.teste)} · {s(x.situacao)}</li>)}</ul>}
        {campoTexto('assunto', 'Assunto', 1)}
        {campoTexto('texto', 'Mensagem (e-mail e aviso no celular, se o aluno autorizou)', 5)}
      </>)}

      {p.tipo === 'lancamento' && (
        <div className="pr-lanc">
          <p className="pr-contexto">{s(p.proposta.nome) || s((p as unknown as J).titulo)}</p>
          {(['numerador', 'denominador'] as const).map((c) => (
            <label key={c} className="pr-campo">{c === 'numerador' ? 'Casos com o registro' : 'Total do mês'}
              {aberta ? <input type="number" min={0} value={s(ed[c])} onChange={(e) => setEd({ ...ed, [c]: e.target.value })} /> : <span> {s((p.decisao ?? p.proposta)[c])}</span>}
            </label>
          ))}
          {campoTexto('fonte', 'Fonte', 1)}
        </div>
      )}

      {p.tipo === 'fonte' && (() => {
        const q = p.proposta;
        const link = q.pmid ? `https://pubmed.ncbi.nlm.nih.gov/${s(q.pmid)}/` : q.doi ? `https://doi.org/${s(q.doi)}` : '';
        return (<>
          <p className="pr-contexto">Arquivo: {s(ctx.arquivo)} · código {s(ctx.ref)} · {s(ctx.caracteres)} caracteres de texto
            {Array.isArray(ctx.ja_no_banco_em) && (ctx.ja_no_banco_em as string[]).length > 0 ? ` · já está como fonte em ${(ctx.ja_no_banco_em as string[]).join(', ')}` : ''}</p>
          {q.recusar ? <p className="pr-sugestao reprovar">Sugere recusar: {s(q.motivo_recusa)}</p> : <>
            <blockquote className="pr-pergunta">{s(q.titulo)}{q.autores ? ` · ${s(q.autores)}` : ''}{q.ano ? ` · ${s(q.ano)}` : ''}
              {link && <> · <a href={link} target="_blank" rel="noreferrer">{q.pmid ? `PMID ${s(q.pmid)}` : 'DOI'}</a></>}</blockquote>
            <p className="pr-contexto">{s(q.tipo_de_fonte)}{q.desenho ? ` · ${s(q.desenho)}` : ''} · camada sugerida {s(q.camada)}</p>
            {q.resumo ? <p className="pr-texto">{s(q.resumo)}</p> : null}
            {Array.isArray(q.temas) && <ul className="pr-itens">{(q.temas as J[]).map((t, i) => (
              <li key={i}><strong>{s(t.tema)}</strong> <span className="pr-tipo">{s(t.relevancia)}</span> {s(t.motivo)}</li>))}</ul>}
            {aberta ? (<>
              <label className="pr-campo">Temas em que a fonte fica guardada (separe por vírgula)
                <input value={s(ed.temas_texto)} onChange={(e) => setEd({ ...ed, temas_texto: e.target.value })} /></label>
              <label className="pr-campo">Camada (1 histórico, 2 livro-texto, 3 protocolo, 4 literatura, 5 diretriz)
                <input type="number" min={1} max={5} value={s(ed.camada)} onChange={(e) => setEd({ ...ed, camada: e.target.value })} /></label>
            </>) : <p>Guardada em: {s((p.decisao ?? base).temas_texto) || (Array.isArray(q.temas) ? (q.temas as J[]).map((t) => s(t.tema)).join(', ') : '')}</p>}
          </>}
        </>);
      })()}

      {['relatorio', 'pendencia', 'alerta'].includes(p.tipo) && (<>
        {ctx.pergunta ? <blockquote className="pr-pergunta">{s(ctx.pergunta)}</blockquote> : null}
        {campoTexto('texto', p.tipo === 'relatorio' ? 'Relatório' : 'Texto', 10)}
      </>)}

      {p.justificativa && <details className="pr-just"><summary>Por que o agente propõe isso</summary><p className="pr-texto">{p.justificativa}</p></details>}
      <Fontes fontes={p.fontes} />

      {aberta ? (
        <div className="pr-acoes">
          <button type="button" className="botao" disabled={enviando || mudou} onClick={() => decidir('aprovar')}
            title={mudou ? 'Você editou: use "Aprovar com a alteração"' : undefined}>Aprovar</button>
          <button type="button" className="botao discreto" disabled={enviando || !mudou} onClick={() => decidir('alterar')}>Aprovar com a alteração</button>
          {!vetando
            ? <button type="button" className="botao discreto pr-vetar" disabled={enviando} onClick={() => setVetando(true)}>Vetar</button>
            : <span className="pr-veto">
                <label className="pr-campo">Motivo do veto (o agente lê na próxima rodada)
                  <textarea rows={2} value={motivo} onChange={(e) => setMotivo(e.target.value)} /></label>
                <button type="button" className="botao pr-vetar" disabled={enviando} onClick={() => decidir('vetar')}>Confirmar veto</button>
                <button type="button" className="botao discreto" onClick={() => { setVetando(false); setMotivo(''); }}>Cancelar</button>
              </span>}
        </div>
      ) : (
        <p className="pr-meta">{p.status === 'vetada' ? 'Vetada' : p.status === 'alterada' ? 'Aprovada com alteração' : 'Aprovada'} em {data(p.decidido_em)}{p.motivo ? ` · motivo: ${p.motivo}` : ''}</p>
      )}
      {msg && <p role="alert" className="pr-msg">{msg}</p>}
    </article>
  );
}

export function ParaRevisar() {
  const [modo, setModo] = useState<'aguardando' | 'decididas'>('aguardando');
  const [filtro, setFiltro] = useState<string>('');
  const [d, setD] = useState<{ propostas: Proposta[]; agentes: Agente[] } | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [confirmando, setConfirmando] = useState(false);
  const [lote, setLote] = useState<{ enviando: boolean; msg: string | null }>({ enviando: false, msg: null });
  const carregar = () => {
    fetch(`${API}/coordenacao/propostas?status=${modo}`, { credentials: 'include' })
      .then((r) => { if (!r.ok) throw new Error(String(r.status)); return r.json(); })
      .then((j) => { setD(j); setErro(null); })
      .catch((e) => setErro(String(e.message) === '403' ? 'Só a coordenação vê as propostas dos agentes.' : 'Não foi possível carregar as propostas.'));
  };
  useEffect(carregar, [modo]);
  if (erro) return <p role="alert">{erro}</p>;
  if (!d) return <p className="carregando">Carregando…</p>;
  const lista = d.propostas.filter((p) => !filtro || p.agente === filtro);
  const sugeridas = modo === 'aguardando' ? lista.filter(sugereLiberar) : [];
  const nPar = sugeridas.filter((p) => p.tipo === 'parecer').length;
  const nPec = sugeridas.length - nPar;
  async function aprovarLote() {
    setLote({ enviando: true, msg: null });
    const r = await fetch(`${API}/coordenacao/propostas/aprovar-sugeridas`, {
      method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ agente: filtro || undefined }),
    }).catch(() => null);
    setConfirmando(false);
    if (!r?.ok) { setLote({ enviando: false, msg: 'Não foi possível aprovar agora. Nada foi alterado; tente de novo.' }); return; }
    const j = (await r.json()) as { aprovadas: number; com_erro: number; ficaram: number };
    setLote({ enviando: false, msg: `${j.aprovadas} aprovada(s) como o agente sugeriu.${j.com_erro ? ` ${j.com_erro} não entrou(aram) e continua(m) na lista.` : ''} Ficaram ${j.ficaram} para você conferir.` });
    carregar();
  }
  return (
    <section className="pr">
      <p className="pr-intro">O que os agentes da coordenação prepararam. Nada chega ao aluno nem entra na revisão sem a sua decisão.</p>
      <table className="pr-agentes">
        <thead><tr><th>Agente</th><th>Aguardando</th><th>Mais antiga</th><th>Aprovadas como vieram (60 dias)</th><th>Alteradas</th><th>Vetadas</th></tr></thead>
        <tbody>{d.agentes.map((a) => (
          <tr key={a.agente}>
            <th scope="row"><button type="button" className={`pr-filtro${filtro === a.agente ? ' sel' : ''}`} aria-pressed={filtro === a.agente}
              onClick={() => setFiltro(filtro === a.agente ? '' : a.agente)}>{NOME[a.agente] ?? a.agente}</button></th>
            <td>{a.aguardando}</td>
            <td>{a.mais_antiga_horas !== null ? `${a.mais_antiga_horas} h` : '—'}{a.duvidas_sem_resposta_24h ? <span className="pr-alerta"> · {a.duvidas_sem_resposta_24h} dúvida(s) sem resposta há mais de 24 h</span> : null}</td>
            <td>{a.decididas_60d ? `${a.aprovadas_sem_alteracao_pct ?? 0}% (${a.aprovadas_como_vieram} de ${a.decididas_60d})` : '—'}</td>
            <td>{a.alteradas}</td><td>{a.vetadas}</td>
          </tr>
        ))}</tbody>
      </table>
      <div className="pr-modo" role="tablist">
        <button type="button" role="tab" aria-selected={modo === 'aguardando'} className={`botao discreto${modo === 'aguardando' ? ' sel' : ''}`} onClick={() => setModo('aguardando')}>Aguardando sua decisão</button>
        <button type="button" role="tab" aria-selected={modo === 'decididas'} className={`botao discreto${modo === 'decididas' ? ' sel' : ''}`} onClick={() => setModo('decididas')}>Já decididas</button>
      </div>
      {modo === 'aguardando' && sugeridas.length > 0 && (
        <div className="pr-lote">
          {!confirmando
            ? <button type="button" className="botao" onClick={() => setConfirmando(true)}>Aprovar o que os agentes sugerem aprovar ({sugeridas.length})</button>
            : <>
                <p>Vou aprovar como vieram {nPar ? `${nPar} parecer(es) de conteúdo com sugestão "aprovar" (entram como correto)` : ''}{nPar && nPec ? ' e ' : ''}{nPec ? `${nPec} peça(s) com veredito "pronta"` : ''}{filtro ? `, só de ${NOME[filtro] ?? filtro}` : ''}.
                  Continuam aqui para você conferir: "conferir melhor", "reprovar", peças "ajustar" ou "refazer", respostas a dúvidas, lembretes e lançamentos.</p>
                <button type="button" className="botao" disabled={lote.enviando} onClick={aprovarLote}>{lote.enviando ? 'Aprovando…' : 'Confirmar'}</button>
                <button type="button" className="botao discreto" disabled={lote.enviando} onClick={() => setConfirmando(false)}>Cancelar</button>
              </>}
        </div>
      )}
      {lote.msg && <p role="status" className="pr-msg">{lote.msg}</p>}
      {lista.length === 0
        ? <p className="pr-vazio">{modo === 'aguardando' ? 'Nada aguardando revisão.' : 'Nenhuma decisão registrada ainda.'}</p>
        : lista.map((p) => <Cartao key={p.proposta_id} p={p} decidido={carregar} />)}
    </section>
  );
}
