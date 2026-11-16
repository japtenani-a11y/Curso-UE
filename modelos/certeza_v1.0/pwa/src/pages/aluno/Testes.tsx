import { useEffect, useRef, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Avaliacao, Pergunta } from '../../components/Engajamento.js';
import { ComparativoTeste } from '../../components/Comparativo.js';

// Testes do tema (v2, Design System CUT): uma questão por tela; em cada questão o residente escolhe a alternativa
// e marca a certeza (chutei / acho que sim / tenho certeza) antes de qualquer gabarito. Cada resposta é salva na hora,
// e o teste retoma de onde parou. Nenhum sinal de acerto até o envio. O gabarito mostra a resposta, a certeza marcada
// e destaca os erros com "tenho certeza".
interface Teste { onda_id: number; teste_num: number; liberado: boolean; respondivel: boolean; submetida_em: string | null; status: string; data_abertura: string; data_fechamento: string }
interface Lista { tema: { codigo: string; titulo: string; etapa: number; perfil: string | null }; testes: Teste[] }
interface Alt { alternativa_id: number; ordem: number; texto: string; correta?: boolean; categoria?: string | null; justificativa?: string | null }
interface Item { item_id: number; enunciado: string; fixa: boolean; alternativas: Alt[]; resposta?: number | null; certeza?: number | null; escolhida?: number; grau?: string; taxa_esperada?: string; ancora?: string }
interface Aberto { teste_num: number; caso: { titulo: string; texto: string } | null; itens: Item[]; tentativa: { submetida_em: string | null } }

const NOMES = ['', 'Pré-teste inicial', 'Pré-teste após o conhecimento básico', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90'];
const LETRAS = 'ABCDE';
const CERTEZAS: [number, string][] = [[1, 'Chutei'], [2, 'Acho que sim'], [3, 'Tenho certeza']];
const NOME_CERTEZA: Record<number, string> = { 1: 'Chutei', 2: 'Acho que sim', 3: 'Tenho certeza' };
const CAT: Record<string, string> = { erro_conceitual: 'erro conceitual', erro_conduta: 'erro de conduta', erro_indicacao: 'erro de indicação', erro_tecnico: 'erro técnico', erro_calculo: 'erro de cálculo' };
const dataHora = (s: string) => new Date(s).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
function situacao(t: Teste): string {
  if (t.submetida_em) return 'Respondido';
  if (!t.liberado) return 'Bloqueado: responda o teste anterior';
  if (!t.respondivel) return new Date(t.data_fechamento) <= new Date() ? 'Prazo encerrado' : `Abre em ${dataHora(t.data_abertura)}`;
  return t.teste_num === 2 ? `Liberado · prazo: até ${dataHora(t.data_fechamento)} (1 hora antes da aula)` : 'Liberado';
}
function codigoDoTema(): string {
  const m = window.location.pathname.match(/testes\/([A-Za-z0-9-]+)/);
  return m?.[1] ?? 'T001';
}
// o banco devolve alguns codigos como texto e outros como numero: comparar sempre como numero
const mesmo = (a: unknown, b: unknown) => a != null && b != null && Number(a) === Number(b);
const acertou = (i: Item) => i.alternativas.some((a) => a.correta && mesmo(a.alternativa_id, i.escolhida));

export function Testes() {
  const [lista, setLista] = useState<Lista | null>(null);
  const [aberto, setAberto] = useState<{ ondaId: number; dados: Aberto } | null>(null);
  const [gab, setGab] = useState<{ ondaId: number; itens: Item[] } | null>(null);
  const [marcadas, setMarcadas] = useState<Record<number, number>>({});
  const [certezas, setCertezas] = useState<Record<number, number>>({});
  const [idx, setIdx] = useState(0);
  const [revisar, setRevisar] = useState(false);
  const [salvo, setSalvo] = useState<'' | 'salvando' | 'salvo' | 'falhou'>('');
  const [erro, setErro] = useState<string | null>(null);
  const entrouEm = useRef<number>(Date.now());
  const tempos = useRef<Record<number, number>>({});
  const topo = useRef<HTMLElement>(null);

  function carregar() {
    apiGet<Lista>(`/teste/temas/${codigoDoTema()}`).then(setLista).catch(() => setErro('Não foi possível carregar os testes.'));
  }
  useEffect(carregar, []);
  useEffect(() => { entrouEm.current = Date.now(); topo.current?.scrollIntoView({ block: 'start' }); }, [idx, revisar]);

  async function abrir(ondaId: number) {
    setErro(null); setGab(null); setRevisar(false); setSalvo('');
    try {
      const d = await apiGet<Aberto>(`/teste/ondas/${ondaId}`);
      const m: Record<number, number> = {}, c: Record<number, number> = {};
      d.itens.forEach((i) => { if (i.resposta) m[i.item_id] = Number(i.resposta); if (i.certeza) c[i.item_id] = Number(i.certeza); });
      setMarcadas(m); setCertezas(c); tempos.current = {};
      const primeira = d.itens.findIndex((i) => !m[i.item_id] || !c[i.item_id]);
      setIdx(primeira < 0 ? 0 : primeira); setRevisar(primeira < 0 && d.itens.length > 0);
      setAberto({ ondaId, dados: d });
    } catch { setErro('Este teste não está disponível agora (ainda não liberado, fora do prazo) ou seu perfil (grau) não está cadastrado.'); }
  }

  async function verGabarito(ondaId: number) {
    setErro(null); setAberto(null);
    try { const g = await apiGet<{ itens: Item[] }>(`/teste/ondas/${ondaId}/gabarito`); setGab({ ondaId, itens: g.itens }); }
    catch { setErro('O gabarito só é liberado depois que você envia o teste.'); }
  }

  function tempoDe(itemId: number): number {
    const t = (tempos.current[itemId] ?? 0) + (Date.now() - entrouEm.current);
    tempos.current[itemId] = t; entrouEm.current = Date.now(); return Math.round(t);
  }
  async function salvar(itemId: number, alt: number | undefined, cert: number | undefined) {
    if (!aberto || !alt) return;
    setSalvo('salvando');
    try {
      await apiPost(`/teste/ondas/${aberto.ondaId}/respostas`, { respostas: [{ item_id: itemId, alternativa_id: alt, certeza: cert ?? null, tempo_resposta_ms: tempoDe(itemId) }], submeter: false });
      setSalvo('salvo');
    } catch { setSalvo('falhou'); }
  }
  function escolher(itemId: number, alt: number) { setMarcadas((m) => ({ ...m, [itemId]: alt })); void salvar(itemId, alt, certezas[itemId]); }
  function marcarCerteza(itemId: number, c: number) { setCertezas((x) => ({ ...x, [itemId]: c })); void salvar(itemId, marcadas[itemId], c); }

  async function enviar() {
    if (!aberto) return;
    const faltam = aberto.dados.itens.filter((i) => !marcadas[i.item_id] || !certezas[i.item_id]).length;
    if (faltam > 0) { setErro(`Faltam ${faltam} questão(ões) com alternativa ou certeza.`); return; }
    try {
      await apiPost(`/teste/ondas/${aberto.ondaId}/respostas`, {
        respostas: aberto.dados.itens.map((i) => ({ item_id: i.item_id, alternativa_id: marcadas[i.item_id], certeza: certezas[i.item_id], tempo_resposta_ms: tempos.current[i.item_id] ?? null })),
        submeter: true,
      });
      const ondaId = aberto.ondaId;
      setAberto(null); carregar(); await verGabarito(ondaId);
    } catch { setErro('Falha ao enviar as respostas. Verifique a conexão; se o prazo do teste terminou, ele não aceita mais respostas.'); }
  }

  if (!lista) return <p className="carregando">{erro ?? 'Carregando…'}</p>;
  const tnum = (ondaId: number) => lista.testes.find((t) => t.onda_id === ondaId)?.teste_num ?? 0;

  return (
    <section className="tst2" ref={topo}>
      <header className="tst2-cab">
        <span className="tst2-rot">{lista.tema.codigo} · testes do tema</span>
        <h1>{lista.tema.titulo}</h1>
        <a href={`/aluno/leitura/${lista.tema.codigo.replace('-', '')}`}>Material do tema</a>
      </header>
      {erro && <p className="tst2-aviso" role="alert">{erro}</p>}

      {!aberto && !gab && (
        <div className="tst2-lista">
          {lista.testes.map((t) => (
            <div key={t.onda_id} className="tst2-linha">
              <div><strong>{NOMES[t.teste_num]}</strong><span className="tst2-meta">{situacao(t)}</span></div>
              {t.submetida_em
                ? <button type="button" className="tst2-btn" onClick={() => verGabarito(t.onda_id)}>Ver gabarito</button>
                : <button type="button" className="tst2-btn prim" disabled={!t.liberado || !t.respondivel} onClick={() => abrir(t.onda_id)}>Responder</button>}
            </div>
          ))}
        </div>
      )}

      {aberto && !revisar && (() => {
        const itens = aberto.dados.itens, i = itens[idx];
        if (!i) return null;
        const prontas = itens.filter((x) => marcadas[x.item_id] && certezas[x.item_id]).length;
        return (
          <div className="tst2-questao">
            <div className="tst2-progresso">
              <span><b>{NOMES[aberto.dados.teste_num]}</b> · questão {idx + 1} de {itens.length}</span>
              <span className="tst2-meta" aria-live="polite">{salvo === 'salvando' ? 'Salvando…' : salvo === 'salvo' ? 'Resposta salva' : salvo === 'falhou' ? 'Não salvou: verifique a conexão' : `${prontas} de ${itens.length} respondidas`}</span>
              <span className="tst2-barra" aria-hidden="true"><i style={{ width: `${(100 * prontas) / itens.length}%` }} /></span>
            </div>
            {idx >= 1 && aberto.dados.caso && (
              <details className="tst2-caso" open>
                <summary>Caso clínico: {aberto.dados.caso.titulo}</summary>
                <p>{aberto.dados.caso.texto}</p>
              </details>
            )}
            <article className="tst2-cartao">
              <p className="tst2-vinheta">{i.enunciado}</p>
              <div className="tst2-alts" role="radiogroup" aria-label={`Alternativas da questão ${idx + 1}`}>
                {i.alternativas.map((a, k) => (
                  <button key={a.alternativa_id} type="button" role="radio" aria-checked={mesmo(marcadas[i.item_id], a.alternativa_id)}
                    className="tst2-alt" onClick={() => escolher(i.item_id, Number(a.alternativa_id))}>
                    <span className="letra">{LETRAS[k]}</span><span>{a.texto}</span>
                  </button>
                ))}
              </div>
              <fieldset className="tst2-certeza" disabled={!marcadas[i.item_id]}>
                <legend>Qual a sua certeza nesta resposta?</legend>
                <div className="opcoes">
                  {CERTEZAS.map(([v, r]) => (
                    <button key={v} type="button" aria-pressed={certezas[i.item_id] === v} onClick={() => marcarCerteza(i.item_id, v)}>{r}</button>
                  ))}
                </div>
                {!marcadas[i.item_id] && <span className="tst2-meta">Escolha uma alternativa primeiro.</span>}
              </fieldset>
            </article>
            <div className="tst2-nav">
              <button type="button" className="tst2-btn" disabled={idx === 0} onClick={() => setIdx(idx - 1)}>← Anterior</button>
              {idx < itens.length - 1
                ? <button type="button" className="tst2-btn prim" onClick={() => setIdx(idx + 1)}>Próxima →</button>
                : <button type="button" className="tst2-btn prim" onClick={() => setRevisar(true)}>Revisar e enviar</button>}
            </div>
            <button type="button" className="tst2-link" onClick={() => { setAberto(null); carregar(); }}>Sair e continuar depois</button>
          </div>
        );
      })()}

      {aberto && revisar && (() => {
        const itens = aberto.dados.itens;
        const falta = itens.filter((x) => !marcadas[x.item_id] || !certezas[x.item_id]);
        return (
          <div className="tst2-revisao">
            <h2>Revisar antes de enviar</h2>
            <p className="tst2-meta">Toque num número para voltar à questão. Depois de enviar, as respostas não mudam e o gabarito comentado é liberado.</p>
            <div className="tst2-grade">
              {itens.map((x, n) => {
                const ok = marcadas[x.item_id] && certezas[x.item_id];
                return (
                  <button key={x.item_id} type="button" className={ok ? 'feita' : 'falta'} onClick={() => { setIdx(n); setRevisar(false); }}
                    aria-label={`Questão ${n + 1}: ${ok ? `respondida, ${NOME_CERTEZA[certezas[x.item_id]!]}` : 'falta responder'}`}>
                    <b>{n + 1}</b><small>{ok ? NOME_CERTEZA[certezas[x.item_id]!] : marcadas[x.item_id] ? 'falta certeza' : 'em branco'}</small>
                  </button>
                );
              })}
            </div>
            {falta.length > 0 && <p className="tst2-aviso">Faltam {falta.length} questão(ões) com alternativa ou certeza.</p>}
            <div className="tst2-nav">
              <button type="button" className="tst2-btn" onClick={() => setRevisar(false)}>← Voltar às questões</button>
              <button type="button" className="tst2-btn prim" disabled={falta.length > 0} onClick={enviar}>Enviar respostas</button>
            </div>
          </div>
        );
      })()}

      {gab && <Gabarito itens={gab.itens} />}
      {gab && (
        <>
          <ComparativoTeste tema={lista.tema.codigo} teste={tnum(gab.ondaId)} />
          <div className="engajamento">
            <Avaliacao tema={lista.tema.codigo} ferramenta={`teste_${tnum(gab.ondaId)}`} titulo="este teste" />
            <Pergunta tema={lista.tema.codigo} ferramenta={`teste_${tnum(gab.ondaId)}`} />
          </div>
          <button type="button" className="tst2-btn" onClick={() => setGab(null)}>Voltar aos testes</button>
        </>
      )}
    </section>
  );
}

function Gabarito({ itens }: { itens: Item[] }) {
  const acertos = itens.filter(acertou).length;
  const altaCerteza = itens.map((i, n) => ({ i, n })).filter(({ i }) => !acertou(i) && Number(i.certeza) === 3);
  const porNivel = CERTEZAS.map(([v, r]) => { const l = itens.filter((i) => Number(i.certeza) === v); return { r, n: l.length, ok: l.filter(acertou).length }; });
  return (
    <div className="tst2-gab">
      <h2>Gabarito comentado</h2>
      <div className="tst2-resumo">
        <div><b>{acertos} de {itens.length}</b><span>acertos</span></div>
        {porNivel.map((p) => <div key={p.r}><b>{p.n ? `${p.ok} de ${p.n}` : '—'}</b><span>{p.r}</span></div>)}
      </div>
      {altaCerteza.length > 0 && (
        <div className="tst2-alerta" role="note">
          <strong>! {altaCerteza.length === 1 ? '1 erro' : `${altaCerteza.length} erros`} com "tenho certeza"</strong>
          <span>São os pontos que mais valem a releitura: a ideia errada estava firme. Questões {altaCerteza.map(({ n }) => n + 1).join(', ')}.</span>
        </div>
      )}
      {itens.map((i, n) => {
        const ok = acertou(i), alta = !ok && Number(i.certeza) === 3;
        return (
          <article key={i.item_id} id={`q${n + 1}`} className={`tst2-bloco ${ok ? 'certo' : 'errado'}${alta ? ' alta' : ''}`}>
            <div className="tst2-status">
              <span className="sinal">{ok ? '✓ Você acertou' : '✕ Você errou'}</span>
              <span className="tst2-meta">Sua certeza: {i.certeza ? NOME_CERTEZA[Number(i.certeza)] : 'não registrada'}</span>
              {alta && <span className="tst2-selo">Erro com alta certeza</span>}
            </div>
            <p className="tst2-vinheta"><b>{n + 1}.</b> {i.enunciado}</p>
            <p className="tst2-meta">Grau: {i.grau} · acerto esperado para o seu perfil: {i.taxa_esperada} · fonte: {i.ancora}</p>
            {i.alternativas.map((a, k) => {
              const minha = mesmo(a.alternativa_id, i.escolhida);
              return (
                <div key={a.alternativa_id} className={`tst2-galt${a.correta ? ' correta' : minha ? ' minha' : ''}`}>
                  <p><span className="letra">{LETRAS[k]}</span> {a.texto}
                    {a.correta && <em> ✓ correta</em>}{minha && !a.correta && <em> ✕ sua resposta</em>}{minha && a.correta && <em> (sua resposta)</em>}</p>
                  {a.justificativa && <p className="just">{a.correta ? '' : `${CAT[a.categoria ?? ''] ?? ''}: `}{a.justificativa}</p>}
                </div>
              );
            })}
          </article>
        );
      })}
    </div>
  );
}
