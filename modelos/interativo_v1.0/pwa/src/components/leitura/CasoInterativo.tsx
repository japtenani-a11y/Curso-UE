import { useEffect, useRef, useState } from 'react';
import { Markdown } from '../../lib/md.js';
import { useEstado, TextoSituacao } from './progresso.js';
import { CasoAula } from './CasoAula.js';

// Caso da aula interativo. Em cada ponto de decisao: o aluno escreve a conduta e marca a certeza; so entao abre a
// discussao; depois compara a propria conduta com a discussao. A resposta de um ponto fica registrada (nao muda
// depois que a discussao foi aberta). No fim: desfecho e resumo, com destaque para conduta diferente marcada com certeza.
export interface Ponto { titulo: string; situacao: string; discussao: string; dica: string }
export interface CasoPartes { abertura: string; pontos: Ponto[]; desfecho: string }

export function partesDoCaso(corpo: string): CasoPartes {
  const blocos: { titulo: string; linhas: string[] }[] = [];
  const abertura: string[] = [];
  for (const l of corpo.split('\n')) {
    const m = l.match(/^\*\*((?:Ponto de decisão|Perguntas de fechamento|Desfecho)[^*]*)\*\*\s*(.*)$/);
    if (m) { blocos.push({ titulo: (m[1] ?? '').replace(/[.:]\s*$/, '').trim(), linhas: m[2] ? [m[2]] : [] }); continue; }
    if (blocos.length) blocos[blocos.length - 1]!.linhas.push(l);
    else if (!/^# /.test(l) && !/^Duração:/i.test(l.trim())) abertura.push(l);
  }
  const pontos: Ponto[] = []; let desfecho = '';
  for (const b of blocos) {
    const t = b.linhas.join('\n').trim();
    if (b.titulo.startsWith('Desfecho')) { desfecho = t; continue; }
    const i = t.indexOf('Discussão:');
    const antes = (i >= 0 ? t.slice(0, i) : t).split('\n');
    const dica = antes.filter((l) => /^Dica:/i.test(l.trim())).map((l) => l.trim().replace(/^Dica:\s*/i, '')).join(' ');
    pontos.push({
      titulo: b.titulo,
      situacao: antes.filter((l) => !/^Dica:/i.test(l.trim())).join('\n').replace(/^Situação:\s*/m, '').trim(),
      discussao: i >= 0 ? t.slice(i + 'Discussão:'.length).trim() : '',
      dica,
    });
  }
  return { abertura: abertura.join('\n').trim(), pontos, desfecho };
}

const CERTEZA = ['', 'Chutei', 'Acho que sim', 'Tenho certeza'];
const COMPARA: Record<string, string> = { parecida: 'Parecida', em_parte: 'Em parte', diferente: 'Diferente' };
interface Resp { conduta?: string; certeza?: number; revelado?: boolean; comparacao?: string; explicacao?: string; dica_vista?: boolean }
interface Tentativa { pontos?: Record<string, Resp>; concluida_em?: string }
interface EstadoCaso { atual?: number; pontos?: Record<string, Resp>; fim?: boolean; concluido?: boolean; anteriores?: Tentativa[]; refazer?: boolean; [k: string]: unknown }

// Dicas: so para quem esta no inicio (graduacao, R1 e R2); do R3 em diante o caso vai sem apoio.
const COM_DICA = ['graduacao', 'R1', 'R2'];

export function CasoInterativo(props: { codigo: string; corpo: string; perfil?: string | null }) {
  const caso = partesDoCaso(props.corpo);
  const { estado, atualizar, situacao } = useEstado<EstadoCaso>(props.codigo, 'caso');
  const topo = useRef<HTMLDivElement>(null);
  const [confirmar, setConfirmar] = useState(false);
  const total = caso.pontos.length;
  const atual = Math.min(estado?.atual ?? 0, Math.max(0, total - 1));
  const fim = !!estado?.fim;
  useEffect(() => { topo.current?.scrollIntoView({ block: 'nearest' }); }, [atual, fim]);
  if (total === 0) return <Markdown texto={props.corpo} />;
  if (!estado) return <p>Carregando…</p>;
  const resp = (i: number): Resp => estado.pontos?.[String(i)] ?? {};
  const mudar = (i: number, r: Partial<Resp>, imediato = false) =>
    atualizar((e) => ({ ...e, pontos: { ...(e.pontos ?? {}), [String(i)]: { ...(e.pontos?.[String(i)] ?? {}), ...r } } }), { imediato });
  const ir = (i: number) => atualizar((e) => ({ ...e, atual: i, fim: false, concluido: !!(e.concluido || e.fim) }), { imediato: true });
  const revelados = caso.pontos.filter((_, i) => resp(i).revelado).length;
  const anteriores = estado.anteriores ?? [];
  const tentativa = anteriores.length + 1;
  const antes = (i: number): Resp | null => anteriores.length ? anteriores[anteriores.length - 1]!.pontos?.[String(i)] ?? null : null;
  const refazer = () => {
    setConfirmar(false);
    atualizar((e) => ({ atual: 0, fim: false, concluido: false, pontos: {}, refazer: true,
      anteriores: [...(e.anteriores ?? []), { pontos: e.pontos ?? {}, concluida_em: new Date().toISOString() }] }), { imediato: true });
  };

  return (
    <div className="int-caso" ref={topo}>
      <CasoAula codigo={props.codigo} corpo={props.corpo} />
      <details className="int-paciente" open={atual === 0 && !fim}>
        <summary>O caso: dados do paciente</summary>
        <Markdown texto={caso.abertura} />
      </details>

      <nav className="int-pontos" aria-label="Pontos de decisão">
        {caso.pontos.map((p, i) => {
          const r = resp(i);
          const pode = i <= revelados;
          return (
            <button key={i} type="button" disabled={!pode} aria-current={!fim && i === atual ? 'step' : undefined}
              className={`int-ponto${r.revelado ? ' feito' : ''}`} onClick={() => ir(i)} title={p.titulo}>
              {i + 1}
            </button>
          );
        })}
        <button type="button" className={`int-ponto fim${fim ? ' atual' : ''}`} disabled={revelados < total}
          aria-current={fim ? 'step' : undefined} onClick={() => atualizar((e) => ({ ...e, fim: true, concluido: true }), { imediato: true })}>Fim</button>
        <TextoSituacao situacao={situacao} />
      </nav>

      {!fim && (() => {
        const p = caso.pontos[atual]!; const r = resp(atual);
        const pronto = (r.conduta ?? '').trim().length >= 3 && !!r.certeza;
        // na primeira passada, a explicacao e a comparacao sao obrigatorias; ao rever, nao travam
        const jaPassou = !!estado.concluido || (atual < total - 1 && !!resp(atual + 1).revelado);
        const trava = !r.comparacao || (!jaPassou && (r.explicacao ?? '').trim().length < 10);
        return (
          <article className="int-cartao">
            <span className="int-rot">Ponto {atual + 1} de {total}{tentativa > 1 ? ` · tentativa ${tentativa}` : ''}</span>
            <h3>{p.titulo.replace(/^Ponto de decisão \d+\s*[—-]\s*/, '')}</h3>
            <Markdown texto={p.situacao} />
            {!r.revelado ? (
              <div className="int-resposta">
                {p.dica && COM_DICA.includes(props.perfil ?? '') && (
                  r.dica_vista
                    ? <p className="int-dica"><strong>Dica.</strong> {p.dica}</p>
                    : <button type="button" className="int-btn" onClick={() => mudar(atual, { dica_vista: true })}>Ver uma dica</button>
                )}
                <label htmlFor={`cond${atual}`}><strong>O que você faz agora?</strong></label>
                <textarea id={`cond${atual}`} rows={3} value={r.conduta ?? ''} maxLength={1500}
                  placeholder="Escreva a sua conduta em uma ou duas frases."
                  onChange={(e) => mudar(atual, { conduta: e.target.value })} />
                <div className="int-certeza" role="radiogroup" aria-label="Quanta certeza você tem?">
                  <span>Quanta certeza você tem?</span>
                  {[1, 2, 3].map((c) => (
                    <button key={c} type="button" role="radio" aria-checked={r.certeza === c} onClick={() => mudar(atual, { certeza: c })}>{CERTEZA[c]}</button>
                  ))}
                </div>
                <button type="button" className="int-btn prim" disabled={!pronto} onClick={() => mudar(atual, { revelado: true }, true)}>
                  Ver a discussão
                </button>
                <small className="int-nota">Ao abrir a discussão, a sua resposta deste ponto fica registrada e não muda mais.</small>
              </div>
            ) : (
              <div className="int-revelado">
                <div className="int-minha"><span className="int-rot">A sua conduta · {CERTEZA[r.certeza ?? 0]}</span><p>{r.conduta}</p></div>
                <div className="int-discussao"><span className="int-rot">Discussão</span><Markdown texto={p.discussao} /></div>
                <div className="int-explica">
                  <label htmlFor={`exp${atual}`}><strong>Em uma frase: por que a conduta é essa?</strong></label>
                  <textarea id={`exp${atual}`} rows={2} maxLength={600} value={r.explicacao ?? ''} placeholder="Explique com as suas palavras."
                    onChange={(e) => mudar(atual, { explicacao: e.target.value })} />
                </div>
                <div className="int-certeza" role="radiogroup" aria-label="Comparando com a discussão, a sua conduta foi">
                  <span>Comparando com a discussão, a sua conduta foi:</span>
                  {Object.entries(COMPARA).map(([k, v]) => (
                    <button key={k} type="button" role="radio" aria-checked={r.comparacao === k} onClick={() => mudar(atual, { comparacao: k }, true)}>{v}</button>
                  ))}
                </div>
                {antes(atual)?.conduta && (
                  <div className="int-minha anterior"><span className="int-rot">Na tentativa anterior · {CERTEZA[antes(atual)!.certeza ?? 0]}{antes(atual)!.comparacao ? ` · ${COMPARA[antes(atual)!.comparacao!]}` : ''}</span><p>{antes(atual)!.conduta}</p></div>
                )}
                {r.comparacao === 'diferente' && r.certeza === 3 && (
                  <p className="int-alerta"><strong>Diferente, e você tinha certeza.</strong> É o tipo de erro que mais vale corrigir agora: releia a discussão e, se ficou dúvida, leve à reunião.</p>
                )}
                {trava && <small className="int-nota">Para seguir, escreva a explicação e marque a comparação.</small>}
                <div className="int-nav">
                  {atual > 0 && <button type="button" className="int-btn" onClick={() => ir(atual - 1)}>Ponto anterior</button>}
                  {atual < total - 1
                    ? <button type="button" className="int-btn prim" disabled={trava} onClick={() => ir(atual + 1)}>Próximo ponto</button>
                    : <button type="button" className="int-btn prim" disabled={trava} onClick={() => atualizar((e) => ({ ...e, fim: true, concluido: true }), { imediato: true })}>Ver o desfecho</button>}
                </div>
              </div>
            )}
          </article>
        );
      })()}

      {fim && (
        <article className="int-cartao">
          <span className="int-rot">Desfecho</span>
          <Markdown texto={caso.desfecho || 'Sem desfecho registrado neste caso.'} />
          <h3>As suas respostas</h3>
          <div className="int-tabela" role="table">
            {caso.pontos.map((p, i) => {
              const r = resp(i);
              const alerta = r.comparacao === 'diferente' && r.certeza === 3;
              return (
                <div key={i} role="row" className={`int-linha${alerta ? ' alerta' : ''}`}>
                  <span role="cell"><strong>{i + 1}.</strong> {p.titulo.replace(/^Ponto de decisão \d+\s*[—-]\s*/, '')}</span>
                  <span role="cell">{CERTEZA[r.certeza ?? 0] || '—'}</span>
                  <span role="cell">{r.comparacao ? COMPARA[r.comparacao] : '—'}{alerta ? ' · rever' : ''}</span>
                </div>
              );
            })}
          </div>
          {anteriores.length > 0 && (
            <details className="int-paciente">
              <summary>Tentativas anteriores ({anteriores.length})</summary>
              {anteriores.map((t, n) => (
                <div key={n} className="int-tabela">
                  <strong>Tentativa {n + 1}</strong>
                  {caso.pontos.map((_, i) => { const x = t.pontos?.[String(i)] ?? {}; return (
                    <div key={i} className={`int-linha${x.comparacao === 'diferente' && x.certeza === 3 ? ' alerta' : ''}`}>
                      <span><strong>{i + 1}.</strong> {x.conduta || '—'}</span><span>{CERTEZA[x.certeza ?? 0] || '—'}</span><span>{x.comparacao ? COMPARA[x.comparacao] : '—'}</span>
                    </div>); })}
                </div>
              ))}
            </details>
          )}
          <p className="int-nota">As suas respostas ficam guardadas aqui para você rever quando quiser. Se refizer o caso, esta tentativa continua guardada.</p>
          <div className="int-nav">
            <button type="button" className="int-btn" onClick={() => ir(0)}>Rever do início</button>
            {!confirmar
              ? <button type="button" className="int-btn" onClick={() => setConfirmar(true)}>Refazer o caso</button>
              : <span className="int-nav"><button type="button" className="int-btn prim" onClick={refazer}>Começar de novo</button><button type="button" className="int-btn" onClick={() => setConfirmar(false)}>Cancelar</button></span>}
          </div>
        </article>
      )}
    </div>
  );
}
