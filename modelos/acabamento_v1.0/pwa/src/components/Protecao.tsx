import { useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import { useSessao } from '../lib/sessao.js';

// Protege o conteudo contra copia casual e vazamento:
//  - marca d'agua com nome, e-mail e data de quem esta vendo (aparece em qualquer captura de tela);
//  - bloqueia selecao, copia, arrastar, menu do botao direito e impressao (CSS @media print).
// Nao impede quem quer fotografar a tela, mas identifica a origem de qualquer copia.
export function Protecao(props: { children: ReactNode }) {
  const { sessao } = useSessao();
  const [aviso, setAviso] = useState<string | null>(null);

  const fundo = useMemo(() => {
    const quem = sessao ? `${sessao.nome_completo} · ${sessao.email_primario}` : 'Programa CUT · HCFMRP';
    const quando = new Date().toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' });
    const esc = (s: string) => s.replace(/[<>&"']/g, (c) => `&#${c.charCodeAt(0)};`);
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="420" height="220"><text x="10" y="120" transform="rotate(-24 210 110)" font-family="sans-serif" font-size="15" fill="#14213d">${esc(quem)} · ${esc(quando)}</text></svg>`;
    return `url("data:image/svg+xml;utf8,${encodeURIComponent(svg)}")`;
  }, [sessao]);

  useEffect(() => {
    const bloquear = (e: Event) => { e.preventDefault(); setAviso('Conteúdo protegido: cópia e impressão não são permitidas.'); };
    const teclas = (e: KeyboardEvent) => {
      const k = e.key.toLowerCase();
      if ((e.ctrlKey || e.metaKey) && (k === 'p' || k === 's' || (k === 'c' && !(e.target instanceof HTMLTextAreaElement || e.target instanceof HTMLInputElement)))) bloquear(e);
    };
    document.addEventListener('copy', bloquear);
    document.addEventListener('cut', bloquear);
    document.addEventListener('keydown', teclas);
    return () => { document.removeEventListener('copy', bloquear); document.removeEventListener('cut', bloquear); document.removeEventListener('keydown', teclas); };
  }, []);

  useEffect(() => { if (!aviso) return; const t = setTimeout(() => setAviso(null), 2500); return () => clearTimeout(t); }, [aviso]);

  return (
    <div className="protegido" onContextMenu={(e) => e.preventDefault()} onDragStart={(e) => e.preventDefault()}>
      <div className="marca-dagua" style={{ backgroundImage: fundo }} aria-hidden="true" />
      {props.children}
      {aviso && <div className="toast" role="status">{aviso}</div>}
    </div>
  );
}
