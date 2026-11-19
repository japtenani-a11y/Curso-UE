import { Markdown } from '../../lib/md.js';
import { useEstado, TextoSituacao } from './progresso.js';

// Caso base: o aluno responde no proprio site as perguntas do fim, antes da aula. As respostas ficam salvas e,
// a partir da hora da aula, so para leitura (o servidor trava); ao lado de cada uma, ele pode escrever o que
// responderia depois da aula, para comparar.
export function partesDoCasoBase(corpo: string): { texto: string; titulo: string; perguntas: string[] } {
  const linhas = corpo.split('\n');
  const ini = linhas.findIndex((l) => /^(\*\*|#{2,3}\s*)Perguntas/i.test(l.trim()));
  if (ini < 0) return { texto: corpo, titulo: '', perguntas: [] };
  const perguntas: string[] = []; let fimLista = linhas.length;
  for (let i = ini + 1; i < linhas.length; i++) {
    const m = linhas[i]!.match(/^\s*\d+[.)]\s+(.*)$/);
    if (m) perguntas.push(m[1]!.trim());
    else if (linhas[i]!.trim() && perguntas.length) { if (/^\s{2,}\S/.test(linhas[i]!)) perguntas[perguntas.length - 1] += ' ' + linhas[i]!.trim(); else { fimLista = i; break; } }
  }
  return {
    texto: [...linhas.slice(0, ini), ...linhas.slice(fimLista)].filter((l) => !/^# /.test(l)).join('\n').trim(),
    titulo: linhas[ini]!.replace(/\*\*|#/g, '').trim(),
    perguntas,
  };
}

interface EstadoBase { respostas?: Record<string, string>; depois?: Record<string, string>; travado_em?: string; [k: string]: unknown }

export function CasoBase(props: { codigo: string; corpo: string; etapa: number }) {
  const cb = partesDoCasoBase(props.corpo);
  const { estado, atualizar, situacao } = useEstado<EstadoBase>(props.codigo, 'caso_base');
  if (cb.perguntas.length === 0) return <Markdown texto={props.corpo} />;
  const depoisDaAula = props.etapa >= 3;
  const r = estado?.respostas ?? {}; const d = estado?.depois ?? {};
  const respondidas = cb.perguntas.filter((_, i) => (r[String(i + 1)] ?? '').trim()).length;
  return (
    <div className="int-cb">
      <Markdown texto={cb.texto} />
      <div className="int-cb-topo">
        <h3>{cb.titulo || 'Perguntas'}</h3>
        {estado && <TextoSituacao situacao={situacao} />}
      </div>
      <p className="int-nota">
        {depoisDaAula
          ? 'A aula já aconteceu: as respostas de antes ficam como você deixou. Ao lado de cada uma, escreva o que responderia agora.'
          : `Responda antes da aula. As respostas ficam salvas (${respondidas} de ${cb.perguntas.length}) e você pode mudar até a hora da aula. Depois, volte aqui para comparar com o que foi discutido.`}
      </p>
      {!estado ? <p>Carregando…</p> : (
        <ol className="int-perguntas">
          {cb.perguntas.map((p, i) => {
            const k = String(i + 1);
            return (
              <li key={k}>
                <label htmlFor={`cb${k}`} className="int-pergunta"><Markdown texto={p} /></label>
                {!depoisDaAula ? (
                  <textarea id={`cb${k}`} rows={3} maxLength={2000} value={r[k] ?? ''} placeholder="A sua resposta"
                    onChange={(e) => atualizar((x) => ({ ...x, respostas: { ...(x.respostas ?? {}), [k]: e.target.value } }))} />
                ) : (
                  <div className="int-cb-par">
                    <div className="int-minha"><span className="int-rot">Antes da aula</span><p>{(r[k] ?? '').trim() || 'Sem resposta.'}</p></div>
                    <div>
                      <label className="int-rot" htmlFor={`cbd${k}`}>Depois da aula</label>
                      <textarea id={`cbd${k}`} rows={3} maxLength={2000} value={d[k] ?? ''} placeholder="O que você responderia agora?"
                        onChange={(e) => atualizar((x) => ({ ...x, depois: { ...(x.depois ?? {}), [k]: e.target.value } }))} />
                    </div>
                  </div>
                )}
              </li>
            );
          })}
        </ol>
      )}
    </div>
  );
}
