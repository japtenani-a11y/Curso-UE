import { useEffect, useRef, useState } from 'react';
import { useEstado } from './progresso.js';
import { SeletorVelocidade, useVelocidade } from './Velocidade.js';

// Podcast: player do audio (rota protegida da API), com velocidade de 1x a 2x e retomada do ponto em que parou.
// Sem o arquivo de audio, o roteiro pode ser lido pela voz do aparelho (como nos slides), com duas vozes quando o
// aparelho tiver mais de uma em portugues, e retoma da fala em que parou.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface EstadoPod { tempo?: number; fala?: number; [k: string]: unknown }
export const mmss = (s: number) => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, '0')}`;

interface Fala { quem: 'PRECEPTOR' | 'RESIDENTE'; texto: string }

// Mesma limpeza do gerador de audio (gerar_podcast_audio_v1.0.py): sem codigos de fonte e sem marcas de formatacao.
function paraFalar(t: string): string {
  return t.replace(/\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]/g, '')
    .replace(/[*_`#>]/g, '')
    .replace(/xABCDE/g, 'X, A, B, C, D, E').replace(/ABCDE/g, 'A, B, C, D, E')
    .replace(/\s+/g, ' ').trim();
}

export function falasDoRoteiro(corpo: string): Fala[] {
  const out: Fala[] = [];
  for (const l of corpo.split('\n')) {
    const m = l.match(/^\s*\*\*(PRECEPTOR|RESIDENTE):\*\*\s*(.+)$/);
    if (m && m[1] && m[2]) { const texto = paraFalar(m[2]); if (texto) out.push({ quem: m[1] as Fala['quem'], texto }); }
  }
  return out;
}

// Frases de ate ~220 caracteres: alguns navegadores cortam falas longas no meio.
function pedacos(t: string): string[] {
  const frases = t.match(/[^.!?…]+[.!?…]*\s*/g) ?? [t];
  const out: string[] = []; let atual = '';
  for (const f of frases) {
    if ((atual + f).length > 220 && atual) { out.push(atual.trim()); atual = ''; }
    atual += f;
  }
  if (atual.trim()) out.push(atual.trim());
  return out;
}

function vozesPt(): SpeechSynthesisVoice[] {
  if (typeof speechSynthesis === 'undefined') return [];
  const v = speechSynthesis.getVoices();
  const br = v.filter((x) => x.lang?.toLowerCase().replace('_', '-').startsWith('pt-br'));
  return br.length ? br : v.filter((x) => x.lang?.toLowerCase().startsWith('pt'));
}

function VozDoAparelho(props: { codigo: string; roteiro: string; vel: number }) {
  const falas = useRef<Fala[]>(falasDoRoteiro(props.roteiro));
  const vel = props.vel;
  const { estado, atualizar } = useEstado<EstadoPod>(props.codigo, 'podcast_roteiro');
  const [estadoVoz, setEstadoVoz] = useState<'parado' | 'falando' | 'pausado'>('parado');
  const [atual, setAtual] = useState(0);
  const [, setVozes] = useState(0);
  const sessao = useRef(0);
  const total = falas.current.length;

  // as vozes chegam depois em alguns navegadores
  useEffect(() => {
    if (typeof speechSynthesis === 'undefined') return;
    const f = () => setVozes((n) => n + 1);
    speechSynthesis.addEventListener?.('voiceschanged', f);
    return () => { speechSynthesis.removeEventListener?.('voiceschanged', f); speechSynthesis.cancel(); sessao.current++; };
  }, []);
  useEffect(() => { if (estadoVoz === 'parado' && (estado?.fala ?? 0) > 0 && (estado?.fala ?? 0) < total) setAtual(estado!.fala!); }, [estado, total, estadoVoz]);

  function guardar(i: number) { atualizar((e) => ({ ...e, fala: i >= total ? 0 : i }), { espera: 2000 }); }

  function falarDesde(i: number) {
    if (typeof speechSynthesis === 'undefined') return;
    speechSynthesis.cancel();
    const minha = ++sessao.current;
    const vs = vozesPt();
    const vozDe = (q: Fala['quem']) => (q === 'PRECEPTOR' ? vs[0] : vs[1] ?? vs[0]);
    const tom = (q: Fala['quem']) => (vs.length > 1 ? 1 : q === 'PRECEPTOR' ? 0.85 : 1.2);
    const seguir = (k: number) => {
      if (minha !== sessao.current) return;
      if (k >= total) { setEstadoVoz('parado'); setAtual(0); guardar(total); return; }
      setAtual(k); guardar(k);
      const f = falas.current[k];
      if (!f) { setEstadoVoz('parado'); return; }
      const partes = pedacos(f.texto);
      partes.forEach((p, j) => {
        const u = new SpeechSynthesisUtterance(p);
        u.lang = 'pt-BR'; u.rate = vel; u.pitch = tom(f.quem);
        const v = vozDe(f.quem); if (v) u.voice = v;
        if (j === partes.length - 1) u.onend = () => seguir(k + 1);
        speechSynthesis.speak(u);
      });
    };
    setEstadoVoz('falando');
    seguir(i);
  }
  function pausar() { speechSynthesis.pause(); setEstadoVoz('pausado'); }
  function continuar() { speechSynthesis.resume(); setEstadoVoz('falando'); }
  function parar() { sessao.current++; speechSynthesis.cancel(); setEstadoVoz('parado'); guardar(atual); }

  if (typeof speechSynthesis === 'undefined' || total === 0)
    return <p className="pod-sem">O áudio deste episódio ainda não está pronto. Por enquanto, leia o roteiro abaixo.</p>;
  return (
    <div className="pod">
      <strong>Ouvir o episódio</strong>
      <small className="int-nota">O áudio gravado deste episódio ainda não existe. O aplicativo lê o roteiro com a voz do seu aparelho, que pode soar artificial.</small>
      <div className="pod-voz">
        {estadoVoz === 'parado' && <button type="button" onClick={() => falarDesde(atual)}>{atual > 0 ? `Continuar da fala ${atual + 1} de ${total}` : 'Ouvir com a voz do aparelho'}</button>}
        {estadoVoz === 'parado' && atual > 0 && <button type="button" onClick={() => falarDesde(0)}>Ouvir do começo</button>}
        {estadoVoz === 'falando' && <button type="button" onClick={pausar}>Pausar</button>}
        {estadoVoz === 'pausado' && <button type="button" onClick={continuar}>Continuar</button>}
        {estadoVoz !== 'parado' && <button type="button" onClick={parar}>Parar</button>}
      </div>
      {estadoVoz !== 'parado' && <small className="int-nota">Fala {atual + 1} de {total}: {falas.current[atual]?.quem === 'PRECEPTOR' ? 'preceptor' : 'residente'}.</small>}
      <small className="int-nota">A velocidade escolhida vale a partir da próxima fala.</small>
    </div>
  );
}

export function PodcastPlayer(props: { codigo: string; roteiro?: string }) {
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
  if (!ok) return props.roteiro
    ? <><VozDoAparelho codigo={props.codigo} roteiro={props.roteiro} vel={vel} /><SeletorVelocidade valor={vel} mudar={setVel} /></>
    : <p className="pod-sem">O áudio deste episódio ainda não está pronto. Por enquanto, leia o roteiro abaixo.</p>;
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
