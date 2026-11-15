import { useEffect } from 'react';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

// Mede o tempo de leitura de uma peca: so conta com a aba visivel e manda ao trocar de peca, esconder a aba ou sair.
// Pausa depois de 3 minutos sem mexer (rolar, tocar, teclar) para nao contar tela esquecida aberta.
export function TempoLeitura(props: { tema: string; tipo: string }) {
  useEffect(() => {
    let acumulado = 0; let desde = document.visibilityState === 'visible' ? Date.now() : 0; let ultimoGesto = Date.now();
    const parar = () => { if (desde) { acumulado += Math.max(0, Math.min(Date.now(), ultimoGesto + 180_000) - desde); desde = 0; } };
    const enviar = () => {
      parar();
      const s = Math.round(acumulado / 1000); acumulado = 0;
      if (s < 3) return;
      fetch(`${BASE}/extra/leitura/tempo`, { method: 'POST', credentials: 'include', keepalive: true,
        headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ tema: props.tema, tipo: props.tipo, segundos: Math.min(s, 3600) }) }).catch(() => undefined);
    };
    const gesto = () => { const agora = Date.now(); if (desde && agora - ultimoGesto > 180_000) { parar(); desde = agora; } ultimoGesto = agora; if (!desde && document.visibilityState === 'visible') desde = agora; };
    const vis = () => { if (document.visibilityState === 'hidden') enviar(); else { desde = Date.now(); ultimoGesto = Date.now(); } };
    const eventos = ['scroll', 'pointerdown', 'keydown', 'touchstart'];
    eventos.forEach((e) => window.addEventListener(e, gesto, { passive: true }));
    document.addEventListener('visibilitychange', vis);
    window.addEventListener('pagehide', enviar);
    return () => { enviar(); eventos.forEach((e) => window.removeEventListener(e, gesto)); document.removeEventListener('visibilitychange', vis); window.removeEventListener('pagehide', enviar); };
  }, [props.tema, props.tipo]);
  return null;
}
