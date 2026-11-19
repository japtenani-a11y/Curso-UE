import { useState } from 'react';

// Mapa conceitual: o centro do tema no alto e cada ramo num cartao que abre e fecha.
// "Testar-me" esconde os detalhes de cada ramo: o aluno tenta lembrar e toca para conferir (pratica de recuperacao).
interface No { texto: string; filhos: No[] }

export function arvoreDoMapa(corpo: string, previa: boolean): No | null {
  const linhas = corpo.split('\n');
  const ini = linhas.findIndex((l) => l.trim() === 'mindmap');
  if (ini < 0) return null;
  const pilha: { recuo: number; no: No }[] = [];
  let raiz: No | null = null;
  for (const l of linhas.slice(ini + 1)) {
    if (l.startsWith('```')) break;
    if (!l.trim()) continue;
    const recuo = l.length - l.trimStart().length;
    let texto = l.trim().replace(/^root\(\((.*)\)\)$/, '$1').replace(/^\(\((.*)\)\)$/, '$1').replace(/^[[(](.*)[\])]$/, '$1');
    if (!previa) texto = texto.replace(/(\s+[ADPHG][1-9]\d*)+$/, '');
    const no: No = { texto, filhos: [] };
    while (pilha.length && pilha[pilha.length - 1]!.recuo >= recuo) pilha.pop();
    if (!pilha.length) { if (!raiz) raiz = no; else raiz.filhos.push(no); } else pilha[pilha.length - 1]!.no.filhos.push(no);
    pilha.push({ recuo, no });
  }
  return raiz;
}

function Folhas(props: { nos: No[]; testar: boolean; vistos: Set<string>; ver: (k: string) => void; base: string }) {
  return (
    <ul className="int-folhas">
      {props.nos.map((n, i) => {
        const k = `${props.base}.${i}`;
        const oculto = props.testar && !props.vistos.has(k);
        return (
          <li key={k}>
            {oculto
              ? <button type="button" className="int-oculto" onClick={() => props.ver(k)}>Toque para ver</button>
              : <span>{n.texto}</span>}
            {n.filhos.length > 0 && <Folhas nos={n.filhos} testar={props.testar} vistos={props.vistos} ver={props.ver} base={k} />}
          </li>
        );
      })}
    </ul>
  );
}

export function MapaConceitual(props: { corpo: string; previa: boolean }) {
  const raiz = arvoreDoMapa(props.corpo, props.previa);
  const ramos = raiz?.filhos ?? [];
  const [abertos, setAbertos] = useState<Set<number>>(() => new Set(ramos.map((_, i) => i)));
  const [testar, setTestar] = useState(false);
  const [vistos, setVistos] = useState<Set<string>>(new Set());
  if (!raiz) return null;
  const totalFolhas = (n: No[]): number => n.reduce((s, x) => s + 1 + totalFolhas(x.filhos), 0);
  const total = ramos.reduce((s, r) => s + totalFolhas(r.filhos), 0);
  const alternar = (i: number) => setAbertos((a) => { const b = new Set(a); if (b.has(i)) b.delete(i); else b.add(i); return b; });
  return (
    <div className="int-mapa">
      <div className="int-mapa-barra">
        <button type="button" className="int-btn" onClick={() => setAbertos(new Set(ramos.map((_, i) => i)))}>Abrir tudo</button>
        <button type="button" className="int-btn" onClick={() => setAbertos(new Set())}>Fechar tudo</button>
        <button type="button" className={`int-btn${testar ? ' prim' : ''}`} aria-pressed={testar}
          onClick={() => { setTestar(!testar); setVistos(new Set()); setAbertos(new Set(ramos.map((_, i) => i))); }}>
          {testar ? 'Sair do teste' : 'Testar-me'}
        </button>
        {testar && <span className="int-nota">Tente lembrar cada item antes de tocar. {vistos.size} de {total} conferidos.</span>}
      </div>
      <div className="int-mapa-centro">{raiz.texto}</div>
      <div className="int-ramos">
        {ramos.map((r, i) => (
          <section key={i} className={`int-ramo${abertos.has(i) ? ' aberto' : ''}`}>
            <h4>
              <button type="button" aria-expanded={abertos.has(i)} onClick={() => alternar(i)}>
                <span className="int-ramo-n">{i + 1}</span>{r.texto}
                <span className="int-ramo-conta">{totalFolhas(r.filhos)}</span>
              </button>
            </h4>
            {abertos.has(i) && r.filhos.length > 0 &&
              <Folhas nos={r.filhos} testar={testar} vistos={vistos} base={String(i)} ver={(k) => setVistos((v) => new Set(v).add(k))} />}
          </section>
        ))}
      </div>
    </div>
  );
}
