import type { ReactNode } from 'react';

// Leitor de markdown do aplicativo: titulos, listas (com e sem numero, com subitens), tabelas,
// citacoes, blocos de codigo, negrito, italico, links e os codigos das afirmacoes
// ([H#] historico, [D#] livro-texto, [P#] protocolo, [A#] artigo, [G#] diretriz), clicaveis na revisao.
const CODIGO = /^[ADPHG][1-9]\d*$/;

function emLinha(texto: string, aoClicar?: (codigo: string) => void): ReactNode[] {
  const partes = texto.split(/(\*\*[^*]+\*\*|\*[^*\s][^*]*\*|\[[^\]]+\]\((?:https?:\/\/|\/)[^)\s]+\)|\b[ADPHG][1-9]\d*\b)/g);
  return partes.map((p, i) => {
    if (/^\*\*[^*]+\*\*$/.test(p)) return <strong key={i}>{p.slice(2, -2)}</strong>;
    if (/^\*[^*].*\*$/.test(p)) return <em key={i}>{p.slice(1, -1)}</em>;
    const link = p.match(/^\[([^\]]+)\]\(([^)\s]+)\)$/);
    if (link) return <a key={i} href={link[2]} target={link[2]?.startsWith('http') ? '_blank' : undefined} rel="noreferrer noopener">{link[1]}</a>;
    if (CODIGO.test(p) && aoClicar) {
      return <button key={i} type="button" className="chip" onClick={() => aoClicar(p)}>{p}</button>;
    }
    return <span key={i}>{p}</span>;
  });
}

type No = { texto: string; filhos: No[]; ordenada: boolean };

// Junta linhas de lista consecutivas em arvore, pela indentacao.
function lista(linhas: string[], ini: number): { nos: No[]; fim: number; ordenada: boolean } {
  const raiz: No[] = [];
  const primeira = (linhas[ini] ?? '').match(/^(\s*)(-|\d+\.)\s+/);
  const pilha: { ind: number; nos: No[]; ult: No | null }[] = [{ ind: (primeira?.[1] ?? '').length, nos: raiz, ult: null }];
  const ordenada = /\d/.test(primeira?.[2] ?? '');
  let i = ini;
  while (i < linhas.length) {
    const linha = linhas[i] ?? '';
    const m = linha.match(/^(\s*)(-|\d+\.)\s+(.*)$/);
    if (!m) {
      const topo = pilha[pilha.length - 1];
      if (/^\s{2,}\S/.test(linha) && topo?.ult) { topo.ult.texto += ' ' + linha.trim(); i += 1; continue; }
      break;
    }
    const ind = (m[1] ?? '').length;
    while (pilha.length > 1 && ind < (pilha[pilha.length - 1]?.ind ?? 0)) pilha.pop();
    let topo = pilha[pilha.length - 1]!;
    if (ind > topo.ind && topo.ult) { pilha.push({ ind, nos: topo.ult.filhos, ult: null }); topo = pilha[pilha.length - 1]!; }
    const no: No = { texto: m[3] ?? '', filhos: [], ordenada: /\d/.test(m[2] ?? '') };
    topo.nos.push(no); topo.ult = no;
    i += 1;
  }
  return { nos: raiz, fim: i, ordenada };
}

function desenhar(nos: No[], ordenada: boolean, aoClicar: ((c: string) => void) | undefined, chave: string): ReactNode {
  const itens = nos.map((n, a) => (
    <li key={`${chave}-${a}`}>{emLinha(n.texto, aoClicar)}{n.filhos.length > 0 && desenhar(n.filhos, n.filhos[0]?.ordenada ?? false, aoClicar, `${chave}-${a}`)}</li>
  ));
  return ordenada ? <ol key={chave}>{itens}</ol> : <ul key={chave}>{itens}</ul>;
}

export function Markdown(props: { texto: string; aoClicar?: (codigo: string) => void }) {
  const linhas = props.texto.split('\n');
  const saida: ReactNode[] = [];
  let i = 0; let k = 0;
  while (i < linhas.length) {
    const l = linhas[i] ?? '';
    if (l.startsWith('```')) {
      const bloco: string[] = []; i += 1;
      while (i < linhas.length && !(linhas[i] ?? '').startsWith('```')) { bloco.push(linhas[i] ?? ''); i += 1; }
      i += 1; saida.push(<pre key={k++}>{bloco.join('\n')}</pre>); continue;
    }
    if (l.startsWith('|')) {
      const tabela: string[][] = [];
      while (i < linhas.length && (linhas[i] ?? '').startsWith('|')) {
        const cel = (linhas[i] ?? '').split('|').slice(1, -1).map((c) => c.trim());
        if (!cel.every((c) => /^:?-+:?$/.test(c))) tabela.push(cel);
        i += 1;
      }
      saida.push(
        <table key={k++}><tbody>{tabela.map((lin, a) => (
          <tr key={a}>{lin.map((c, b) => (a === 0 ? <th key={b}>{emLinha(c, props.aoClicar)}</th> : <td key={b}>{emLinha(c, props.aoClicar)}</td>))}</tr>
        ))}</tbody></table>,
      );
      continue;
    }
    if (/^\s*(-|\d+\.)\s+/.test(l)) {
      const r = lista(linhas, i);
      saida.push(desenhar(r.nos, r.ordenada, props.aoClicar, `l${k++}`));
      i = r.fim; continue;
    }
    if (l.startsWith('#### ')) saida.push(<h5 key={k++}>{emLinha(l.slice(5), props.aoClicar)}</h5>);
    else if (l.startsWith('### ')) saida.push(<h4 key={k++}>{emLinha(l.slice(4), props.aoClicar)}</h4>);
    else if (l.startsWith('## ')) saida.push(<h3 key={k++}>{emLinha(l.slice(3), props.aoClicar)}</h3>);
    else if (l.startsWith('# ')) saida.push(<h2 key={k++}>{emLinha(l.slice(2), props.aoClicar)}</h2>);
    else if (l.startsWith('> ')) saida.push(<blockquote key={k++}>{emLinha(l.slice(2), props.aoClicar)}</blockquote>);
    else if (l.trim() === '---') saida.push(<hr key={k++} />);
    else if (l.trim() !== '') saida.push(<p key={k++}>{emLinha(l, props.aoClicar)}</p>);
    i += 1;
  }
  return <div className="md">{saida}</div>;
}
