import { useEffect, useState } from 'react';

// "fecha em 2 dias e 4 horas" (destaque nas ultimas 24 horas).
export function Contagem(props: { ate: string | null; prefixo?: string }) {
  const [agora, setAgora] = useState(Date.now());
  useEffect(() => { const t = setInterval(() => setAgora(Date.now()), 60_000); return () => clearInterval(t); }, []);
  if (!props.ate) return null;
  const ms = new Date(props.ate).getTime() - agora;
  if (ms <= 0) return <span className="contagem vencida">prazo encerrado</span>;
  const min = Math.floor(ms / 60_000), h = Math.floor(min / 60), d = Math.floor(h / 24);
  const txt = d >= 1 ? `${d} ${d === 1 ? 'dia' : 'dias'}${h % 24 ? ` e ${h % 24} h` : ''}` : h >= 1 ? `${h} h e ${min % 60} min` : `${min} min`;
  return <span className={`contagem${ms < 86_400_000 ? ' urgente' : ''}`}>{props.prefixo ?? 'fecha em'} {txt}</span>;
}
