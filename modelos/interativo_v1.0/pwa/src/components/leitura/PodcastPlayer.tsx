import { useEffect, useRef, useState } from 'react';
import { useEstado } from './progresso.js';
import { SeletorVelocidade, useVelocidade } from './Velocidade.js';

// Podcast: player do audio (rota protegida da API), com velocidade de 1x a 2x e retomada do ponto em que parou.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface EstadoPod { tempo?: number; [k: string]: unknown }
export const mmss = (s: number) => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, '0')}`;

export function PodcastPlayer(props: { codigo: string }) {
  const [ok, setOk] = useState(true);
  const [vel, setVel] = useVelocidade();
  const audio = useRef<HTMLAudioElement>(null);
  const { estado, atualizar } = useEstado<EstadoPod>(props.codigo, 'podcast_roteiro');
  const restaurado = useRef(false);
  const ultimo = useRef(0);

  useEffect(() => { if (audio.current) audio.current.playbackRate = vel; }, [vel, ok]);
  // volta ao ponto salvo quando o estado e o audio estiverem prontos
  useEffect(() => {
    const a = audio.current;
    if (!a || !estado || restaurado.current) return;
    const ir = () => { if (!restaurado.current && (estado.tempo ?? 0) > 3 && a.duration && estado.tempo! < a.duration - 3) a.currentTime = estado.tempo!; restaurado.current = true; };
    if (a.readyState >= 1) ir(); else a.addEventListener('loadedmetadata', ir, { once: true });
  }, [estado]);
  function guardar(forcar = false) {
    const a = audio.current; if (!a || !restaurado.current) return;
    if (!forcar && Math.abs(a.currentTime - ultimo.current) < 10) return;
    ultimo.current = a.currentTime;
    atualizar((e) => ({ ...e, tempo: Math.round(a.currentTime) }), { espera: forcar ? 0 : 3000 });
  }
  if (!ok) return <p className="pod-sem">O áudio deste episódio ainda não está pronto. Por enquanto, leia o roteiro abaixo.</p>;
  return (
    <div className="pod">
      <strong>Ouvir o episódio</strong>
      {(estado?.tempo ?? 0) > 3 && <small className="int-nota">Você parou em {mmss(estado!.tempo!)}; o áudio continua daí.</small>}
      <audio ref={audio} controls preload="metadata" src={`${API_BASE}/leitura/podcast/${props.codigo.replace(/-/g, '')}`}
        onError={() => setOk(false)} onTimeUpdate={() => guardar()} onPause={() => guardar(true)}
        onRateChange={(e) => { const r = (e.target as HTMLAudioElement).playbackRate; if (r !== vel && r >= 1 && r <= 2) setVel(r); }}
        onEnded={() => atualizar((e) => ({ ...e, tempo: 0 }), { imediato: true })} />
      <SeletorVelocidade valor={vel} mudar={setVel} />
    </div>
  );
}
