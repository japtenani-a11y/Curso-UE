import { Markdown } from '../../lib/md.js';
import { useEstado, TextoSituacao } from './progresso.js';

// Checklist clicavel: cada item "- [ ]" vira uma caixa de marcar; as marcacoes ficam salvas.
interface Item { k: string; texto: string }
interface Grupo { titulo: string; itens: Item[] }

export function gruposDoChecklist(corpo: string): { intro: string; grupos: Grupo[] } {
  const grupos: Grupo[] = []; const intro: string[] = []; let n = 0;
  for (const l of corpo.split('\n')) {
    const item = l.match(/^\s*[-*]\s+\[[ xX]\]\s+(.*)$/);
    const tit = l.match(/^\s*(?:\*\*(.+?)\*\*|#{2,4}\s+(.+))\s*(.*)$/);
    if (item) {
      if (!grupos.length) grupos.push({ titulo: '', itens: [] });
      grupos[grupos.length - 1]!.itens.push({ k: String(++n), texto: item[1]!.trim() });
    } else if (tit && !/^# /.test(l)) {
      grupos.push({ titulo: `${tit[1] ?? tit[2] ?? ''} ${tit[3] ?? ''}`.trim(), itens: [] });
    } else if (!grupos.length && !/^# /.test(l)) intro.push(l);
  }
  return { intro: intro.join('\n').trim(), grupos: grupos.filter((g) => g.itens.length) };
}

interface EstadoCk { marcados?: Record<string, boolean>; [k: string]: unknown }

export function Checklist(props: { codigo: string; corpo: string }) {
  const { intro, grupos } = gruposDoChecklist(props.corpo);
  const { estado, atualizar, situacao } = useEstado<EstadoCk>(props.codigo, 'checklist');
  if (!grupos.length) return <Markdown texto={props.corpo} />;
  const m = estado?.marcados ?? {};
  const total = grupos.reduce((s, g) => s + g.itens.length, 0);
  const feitos = grupos.reduce((s, g) => s + g.itens.filter((i) => m[i.k]).length, 0);
  return (
    <div className="int-ck">
      {intro && <Markdown texto={intro} />}
      <div className="int-ck-topo">
        <span><strong>{feitos} de {total}</strong> itens marcados</span>
        <span className="int-barra" aria-hidden="true"><i style={{ width: `${total ? (100 * feitos) / total : 0}%` }} /></span>
        {estado && <TextoSituacao situacao={situacao} />}
        <button type="button" className="int-btn" disabled={!feitos} onClick={() => atualizar((e) => ({ ...e, marcados: {} }), { imediato: true })}>Desmarcar tudo</button>
      </div>
      {grupos.map((g) => (
        <fieldset key={g.titulo + g.itens[0]!.k} className="int-ck-grupo">
          {g.titulo && <legend>{g.titulo}</legend>}
          {g.itens.map((i) => (
            <label key={i.k} className={`int-ck-item${m[i.k] ? ' marcado' : ''}`}>
              <input type="checkbox" checked={!!m[i.k]} disabled={!estado}
                onChange={(e) => atualizar((x) => ({ ...x, marcados: { ...(x.marcados ?? {}), [i.k]: e.target.checked } }), { espera: 600 })} />
              <span><Markdown texto={i.texto} /></span>
            </label>
          ))}
        </fieldset>
      ))}
    </div>
  );
}
