import { useCallback, useEffect, useRef, useState } from 'react';

// Estado do aluno em cada peca (respostas, checklist, onde parou). Grava primeiro no aparelho e depois no servidor;
// sem internet, fica pendente no aparelho e vai assim que a conexao voltar (ou na proxima vez que o site abrir).
// Vale o registro mais recente pela hora do aparelho; o servidor aplica as travas (82_interativo_v1.0.sql).
const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
export type Estado = Record<string, unknown>;
interface Registro { estado: Estado; em: string; pendente?: boolean }
const PREFIXO = 'cut_estado_';
const chave = (cod: string, peca: string) => `${PREFIXO}${cod}_${peca}`;
const limpo = (c: string) => c.replace(/[^A-Za-z0-9]/g, '').toUpperCase();

function lerLocal(cod: string, peca: string): Registro | null {
  try { const s = localStorage.getItem(chave(cod, peca)); return s ? (JSON.parse(s) as Registro) : null; } catch { return null; }
}
function gravarLocal(cod: string, peca: string, r: Registro): void {
  try { localStorage.setItem(chave(cod, peca), JSON.stringify(r)); } catch { /* aparelho sem espaco ou modo privado */ }
}

// Envia um registro. Devolve o estado gravado, 'descartar' (peca nao liberada etc.) ou lanca erro (sem internet).
async function enviar(cod: string, peca: string, r: Registro, keepalive = false): Promise<Estado | 'descartar'> {
  const resp = await fetch(`${BASE}/leitura/estado/${cod}/${peca}`, {
    method: 'PUT', credentials: 'include', keepalive,
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ estado: r.estado, em: r.em }),
  });
  if ([400, 403, 404].includes(resp.status)) return 'descartar';
  if (!resp.ok) throw new Error(String(resp.status));
  return ((await resp.json()) as { estado: Estado }).estado;
}

const avisos = new Set<() => void>();
function avisar(): void { avisos.forEach((f) => f()); }

export async function enviarPendentes(): Promise<void> {
  let chaves: string[] = [];
  try { chaves = Object.keys(localStorage).filter((k) => k.startsWith(PREFIXO)); } catch { return; }
  for (const k of chaves) {
    const [cod, ...resto] = k.slice(PREFIXO.length).split('_');
    const peca = resto.join('_');
    const r = (() => { try { return JSON.parse(localStorage.getItem(k) ?? 'null') as Registro | null; } catch { return null; } })();
    if (!r?.pendente || !cod || !peca) continue;
    try {
      const g = await enviar(cod, peca, r);
      const atual = lerLocal(cod, peca);
      if (atual && atual.em === r.em) gravarLocal(cod, peca, { estado: g === 'descartar' ? r.estado : g, em: r.em, pendente: false });
    } catch { break; }
  }
  avisar();
}

let iniciado = false;
function iniciar(): void {
  if (iniciado || typeof window === 'undefined') return;
  iniciado = true;
  window.addEventListener('online', () => { void enviarPendentes(); });
  // ao fechar ou trocar de aba, tenta mandar o que ficou pendente
  window.addEventListener('pagehide', () => {
    try {
      Object.keys(localStorage).filter((k) => k.startsWith(PREFIXO)).forEach((k) => {
        const r = JSON.parse(localStorage.getItem(k) ?? 'null') as Registro | null;
        const [cod, ...resto] = k.slice(PREFIXO.length).split('_');
        if (r?.pendente && cod) void enviar(cod, resto.join('_'), r, true).catch(() => undefined);
      });
    } catch { /* sem acesso ao armazenamento */ }
  });
  void enviarPendentes();
}

const doServidor = new Map<string, Promise<Record<string, { estado: Estado; em: string }>>>();
function estadoServidor(cod: string): Promise<Record<string, { estado: Estado; em: string }>> {
  if (!doServidor.has(cod)) {
    doServidor.set(cod, fetch(`${BASE}/leitura/estado/${cod}`, { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : { estado: {} })).then((j: { estado: Record<string, { estado: Estado; em: string }> }) => j.estado ?? {})
      .catch(() => ({})));
  }
  return doServidor.get(cod)!;
}

export type Situacao = 'salvo' | 'pendente' | 'salvando';

// useEstado(codigo, peca): estado (null enquanto carrega), atualizar(f) e a situacao do salvamento.
export function useEstado<T extends Estado>(codigoTema: string, peca: string, ativo = true) {
  const cod = limpo(codigoTema);
  const [estado, setEstado] = useState<T | null>(null);
  const [situacao, setSituacao] = useState<Situacao>('salvo');
  const atualRef = useRef<T | null>(null);
  const timer = useRef<number | undefined>(undefined);

  useEffect(() => {
    if (!ativo) return undefined;
    iniciar();
    let vivo = true;
    const local = lerLocal(cod, peca);
    void estadoServidor(cod).then((srv) => {
      if (!vivo) return;
      const s = srv[peca];
      const usarLocal = local && (!s || Date.parse(local.em) >= Date.parse(s.em));
      const e = (usarLocal ? local!.estado : s?.estado ?? {}) as T;
      atualRef.current = e; setEstado(e);
      if (usarLocal && local!.pendente) { setSituacao('pendente'); void enviarPendentes(); }
      else if (!usarLocal && s) gravarLocal(cod, peca, { estado: s.estado, em: s.em, pendente: false });
    });
    const f = () => { const l = lerLocal(cod, peca); setSituacao(l?.pendente ? 'pendente' : 'salvo'); };
    avisos.add(f);
    return () => { vivo = false; avisos.delete(f); };
  }, [cod, peca, ativo]);

  const mandar = useCallback(async () => {
    const r = lerLocal(cod, peca);
    if (!r?.pendente) return;
    setSituacao('salvando');
    try {
      const g = await enviar(cod, peca, r);
      const agora = lerLocal(cod, peca);
      if (agora && agora.em === r.em) {
        const final = (g === 'descartar' ? r.estado : g) as T;
        gravarLocal(cod, peca, { estado: final, em: r.em, pendente: false });
        if (JSON.stringify(final) !== JSON.stringify(atualRef.current)) { atualRef.current = final; setEstado(final); }
      }
      setSituacao(lerLocal(cod, peca)?.pendente ? 'pendente' : 'salvo');
    } catch { setSituacao('pendente'); }
  }, [cod, peca]);

  const atualizar = useCallback((f: (e: T) => T, opcoes?: { imediato?: boolean; espera?: number }) => {
    const novo = f((atualRef.current ?? {}) as T);
    atualRef.current = novo; setEstado(novo);
    gravarLocal(cod, peca, { estado: novo, em: new Date().toISOString(), pendente: true });
    setSituacao('pendente');
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => { void mandar(); }, opcoes?.imediato ? 0 : opcoes?.espera ?? 1500);
  }, [cod, peca, mandar]);

  useEffect(() => () => { window.clearTimeout(timer.current); void mandar(); }, [mandar]);

  return { estado, atualizar, situacao };
}

export function TextoSituacao(props: { situacao: Situacao }) {
  const t = props.situacao === 'salvo' ? 'Salvo' : props.situacao === 'salvando' ? 'Salvando…'
    : (typeof navigator !== 'undefined' && !navigator.onLine) ? 'Sem internet: salvo no aparelho, vai assim que a conexão voltar' : 'Salvando…';
  return <span className={`int-salvo ${props.situacao}`} role="status" aria-live="polite">{t}</span>;
}
