import { useEffect, useRef, useState } from 'react';
import { useEstado } from './progresso.js';
import { mmss } from './PodcastPlayer.js';

// Cartao do Inicio: "Continuar de onde parou".
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface Linha { codigo: string; titulo: string; peca: string; nome: string; estado: Record<string, unknown> }

function detalhe(l: Linha): string {
  const e = l.estado ?? {};
  if (l.peca === 'slides' && typeof e.slide === 'number') return `slide ${e.slide + 1}`;
  if (l.peca === 'podcast_roteiro' && typeof e.tempo === 'number' && e.tempo > 0) return `em ${mmss(e.tempo)}`;
  if (l.peca === 'caso' && e.fim) return 'no desfecho';
  if (l.peca === 'caso' && typeof e.atual === 'number') return `ponto ${e.atual + 1}`;
  return '';
}

export function Continuar() {
  const [l, setL] = useState<Linha | null>(null);
  useEffect(() => {
    fetch(`${API_BASE}/leitura/continuar`, { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : { continuar: null })).then((j: { continuar: Linha | null }) => setL(j.continuar)).catch(() => undefined);
  }, []);
  if (!l) return null;
  const cod = l.codigo.replace(/-/g, '');
  const d = detalhe(l);
  return (
    <a className="int-continuar" href={`/aluno/leitura/${cod}?peca=${l.peca}`}>
      <span className="int-rot">Continuar de onde parou</span>
      <strong>{l.codigo} · {l.nome}{d ? `, ${d}` : ''}</strong>
      <small>{l.titulo}</small>
    </a>
  );
}

// Memoria do tema (registro '_tema'): a ultima peca aberta e a posicao do texto em cada peca.
// aoRestaurar(peca) e chamado uma vez, ao carregar, se a pagina foi aberta sem ?peca=.
interface EstadoTema { peca?: string; rolagem?: Record<string, number>; [k: string]: unknown }
export function useMemoriaTema(codigo: string, peca: string | null, aoRestaurar: (peca: string) => void, ativo = true) {
  const { estado, atualizar } = useEstado<EstadoTema>(codigo, '_tema', ativo);
  const restaurou = useRef(false);
  const rolou = useRef<string | null>(null);
  const pular = useRef(false);
  useEffect(() => {
    if (!estado || restaurou.current || !peca) return;
    restaurou.current = true;
    if (!new URLSearchParams(window.location.search).get('peca') && estado.peca && estado.peca !== peca) { pular.current = true; aoRestaurar(estado.peca); }
  }, [estado, peca]); // eslint-disable-line react-hooks/exhaustive-deps
  // ao trocar de peca: grava qual e, poe na barra de endereco e volta a posicao do texto dessa peca
  useEffect(() => {
    if (!estado || !restaurou.current || !peca) return;
    if (pular.current) { pular.current = false; return; }
    const u = new URL(window.location.href); u.searchParams.set('peca', peca); window.history.replaceState(null, '', u.toString());
    if (estado.peca !== peca) atualizar((e) => ({ ...e, peca }), { imediato: true });
    if (rolou.current !== peca) {
      rolou.current = peca;
      const f = estado.rolagem?.[peca] ?? 0;
      window.setTimeout(() => window.scrollTo({ top: f > 0.03 ? f * (document.documentElement.scrollHeight - window.innerHeight) : 0 }), 350);
    }
  }, [peca, estado]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => {
    if (!peca) return undefined;
    let ult = -1;
    const ao = () => {
      if (rolou.current !== peca) return;
      const alt = document.documentElement.scrollHeight - window.innerHeight;
      if (alt < 200) return;
      const f = Math.round((window.scrollY / alt) * 100) / 100;
      if (Math.abs(f - ult) < 0.05) return;
      ult = f;
      atualizar((e) => ({ ...e, peca, rolagem: { ...(e.rolagem ?? {}), [peca]: f } }), { espera: 4000 });
    };
    window.addEventListener('scroll', ao, { passive: true });
    return () => window.removeEventListener('scroll', ao);
  }, [peca, atualizar]);
}
