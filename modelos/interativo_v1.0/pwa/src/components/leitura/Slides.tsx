import { useCallback, useEffect, useRef, useState } from 'react';
import { useEstado } from './progresso.js';
import { SeletorVelocidade, useVelocidade } from './Velocidade.js';
import { partesDoCaso } from './CasoInterativo.js';

// Slides da aula e do caso clinico, com o roteiro de fala de cada slide (texto e audio).
//  - Imagem do slide: programa-cut/slides/<CODIGO>/slide_NN.png, se existir (o deck exportado em imagens);
//    sem imagem, o slide e desenhado a partir do texto da peca "Slides".
//  - Audio da fala: slide_NN.mp3, se existir; sem ele, a fala pode ser lida pela voz do aparelho.
//  - "Apresentar com áudio": toca a fala e passa sozinho para o proximo slide ao terminar, na velocidade escolhida.
//  - Guarda o slide e o ponto do audio em que o aluno parou.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
export interface Slide { secao: string; titulo: string; itens: string[]; rodape: string; fala: string; origem: 'aula' | 'caso' }

const semCodigos = (t: string) => t.replace(/\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]/g, '').trim();

export function slidesDaPeca(corpo: string, caso?: string): Slide[] {
  const saida: Slide[] = []; let secao = ''; let atual: Slide | null = null; let campo: 'fala' | 'nota' | null = null;
  const notas = new Map<Slide, { fala: string; nota: string }>();
  for (const bruta of corpo.split('\n')) {
    const l = bruta.trimEnd();
    const sec = l.match(/^##\s+(?:\d+\.\s*)?(.*)$/);
    const sl = l.match(/^###\s+Slide\s+\d+\.?\s*(.*)$/i);
    if (sl) { atual = { secao, titulo: sl[1]!.trim(), itens: [], rodape: '', fala: '', origem: 'aula' }; saida.push(atual); notas.set(atual, { fala: '', nota: '' }); campo = null; continue; }
    if (sec && !l.startsWith('###')) { secao = sec[1]!.replace(/:.*$/, '').trim(); atual = null; continue; }
    if (!atual) continue;
    const q = l.match(/^>\s?(.*)$/);
    if (q) {
      let t = q[1]!;
      const f = t.match(/^\*\*(Fala|Roteiro de fala|Nota do apresentador)\s*:?\*\*\s*:?\s*(.*)$/i);
      if (f) { campo = /nota/i.test(f[1]!) ? 'nota' : 'fala'; t = f[2]!; }
      if (campo) { const n = notas.get(atual)!; n[campo] = `${n[campo]} ${t}`.trim(); }
      continue;
    }
    campo = null;
    const it = l.match(/^\s*[-*]\s+(.*)$/);
    if (it) { atual.itens.push(semCodigos(it[1]!)); continue; }
    const rod = l.match(/^\*([^*].*)\*$/);
    if (rod && !/rascunho/i.test(rod[1]!)) atual.rodape = semCodigos(rod[1]!);
  }
  for (const s of saida) { const n = notas.get(s)!; s.fala = semCodigos(n.fala || n.nota); }
  // O caso clinico entra como slides no fim, se a peca de slides ainda nao trouxer o caso.
  if (caso && !saida.some((s) => s.origem === 'caso' || /caso/i.test(`${s.secao} ${s.titulo}`))) {
    const c = partesDoCaso(caso);
    if (c.pontos.length) {
      const ab = semCodigos(c.abertura.split('\n').filter((l) => l.trim() && !/^Duração/i.test(l)).join(' '));
      saida.push({ secao: 'Caso clínico', titulo: 'Caso da aula', itens: [ab], rodape: 'Caso fictício', fala: ab, origem: 'caso' });
      for (const p of c.pontos) {
        const t = p.titulo.replace(/^Ponto de decisão \d+\s*[—-]\s*/, '');
        saida.push({ secao: 'Caso clínico', titulo: t, itens: [semCodigos(p.situacao), `Discussão: ${semCodigos(p.discussao)}`], rodape: p.titulo.match(/^Ponto de decisão \d+/)?.[0] ?? '',
          fala: `${t}${/[?!.]$/.test(t) ? '' : '.'} ${semCodigos(p.situacao)} Pense na sua conduta. ${semCodigos(p.discussao)}`, origem: 'caso' });
      }
      if (c.desfecho) saida.push({ secao: 'Caso clínico', titulo: 'Desfecho', itens: [semCodigos(c.desfecho)], rodape: '', fala: semCodigos(c.desfecho), origem: 'caso' });
    }
  }
  return saida;
}

const destaque = (t: string) => t.length <= 16 && /\d|%|^[A-Ex](\s*e\s*[A-E])?$/.test(t);
const num2 = (n: number) => String(n).padStart(2, '0');

function SlideDesenhado(props: { s: Slide; n: number; total: number }) {
  const { s } = props;
  return (
    <div className={`int-slide-arte${s.origem === 'caso' ? ' caso' : ''}`}>
      <span className="int-slide-sec">{s.secao}</span>
      <h3>{s.titulo}</h3>
      <div className="int-slide-itens">
        {s.itens.map((t, i) => destaque(t) ? <strong key={i} className="int-slide-num">{t}</strong> : <p key={i}>{t}</p>)}
      </div>
      <span className="int-slide-rod">{s.rodape}<span>{props.n} / {props.total}</span></span>
    </div>
  );
}

interface EstadoSl { slide?: number; tempo?: number; [k: string]: unknown }

export function Slides(props: { codigo: string; corpo: string; caso?: string }) {
  const lista = slidesDaPeca(props.corpo, props.caso);
  const cod = props.codigo.replace(/-/g, '');
  const { estado, atualizar } = useEstado<EstadoSl>(props.codigo, 'slides');
  const [idx, setIdx] = useState(0);
  const [auto, setAuto] = useState(false);
  const [verFala, setVerFala] = useState(false);
  const [vel, setVel] = useVelocidade();
  const [midia, setMidia] = useState<{ imagens: number[]; audios: number[] }>({ imagens: [], audios: [] });
  const [falando, setFalando] = useState<'mp3' | 'voz' | 'tempo' | null>(null);
  const audio = useRef<HTMLAudioElement>(null);
  const caixa = useRef<HTMLDivElement>(null);
  const timer = useRef<number | undefined>(undefined);
  const restaurado = useRef(false);
  const tempoInicial = useRef(0);
  const total = lista.length;

  useEffect(() => {
    fetch(`${API_BASE}/leitura/slides/${cod}`, { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : { imagens: [], audios: [] })).then(setMidia).catch(() => undefined);
  }, [cod]);
  useEffect(() => {
    if (!estado || restaurado.current) return;
    restaurado.current = true;
    const s = Math.min(Math.max(0, estado.slide ?? 0), Math.max(0, total - 1));
    setIdx(s); tempoInicial.current = estado.tempo ?? 0;
  }, [estado, total]);

  const parar = useCallback(() => {
    window.clearTimeout(timer.current);
    audio.current?.pause();
    if (typeof speechSynthesis !== 'undefined') speechSynthesis.cancel();
    setFalando(null);
  }, []);

  const guardar = useCallback((slide: number, tempo = 0) => {
    atualizar((e) => ({ ...e, slide, tempo: Math.round(tempo) }), { espera: 2500 });
  }, [atualizar]);

  const ir = useCallback((i: number, continuar = auto) => {
    const n = Math.min(Math.max(0, i), total - 1);
    parar(); tempoInicial.current = 0; setIdx(n); guardar(n);
    if (!continuar) setAuto(false);
  }, [auto, total, parar, guardar]);

  // toca a fala do slide atual quando o modo automatico esta ligado
  useEffect(() => {
    if (!auto || !restaurado.current) return undefined;
    const s = lista[idx]; if (!s) return undefined;
    const proximo = () => { if (idx < total - 1) { tempoInicial.current = 0; setIdx(idx + 1); guardar(idx + 1); } else { setAuto(false); setFalando(null); } };
    const n = idx + 1;
    if (midia.audios.includes(n) && audio.current) {
      const a = audio.current;
      a.src = `${API_BASE}/leitura/slides/${cod}/slide_${num2(n)}.mp3`;
      a.playbackRate = vel;
      a.onended = () => { timer.current = window.setTimeout(proximo, 700); };
      a.onloadedmetadata = () => { if (tempoInicial.current > 1 && tempoInicial.current < a.duration - 1) a.currentTime = tempoInicial.current; tempoInicial.current = 0; a.playbackRate = vel; };
      setFalando('mp3');
      void a.play().catch(() => setAuto(false));
    } else if (s.fala && typeof speechSynthesis !== 'undefined') {
      const u = new SpeechSynthesisUtterance(s.fala);
      u.lang = 'pt-BR'; u.rate = vel;
      const voz = speechSynthesis.getVoices().find((v) => v.lang?.toLowerCase().startsWith('pt-br')) ?? speechSynthesis.getVoices().find((v) => v.lang?.toLowerCase().startsWith('pt'));
      if (voz) u.voice = voz;
      u.onend = () => { timer.current = window.setTimeout(proximo, 700); };
      setFalando('voz');
      speechSynthesis.cancel(); speechSynthesis.speak(u);
    } else {
      const seg = Math.max(5, (s.fala || s.itens.join(' ')).split(/\s+/).length / (2.5 * vel));
      setFalando('tempo');
      timer.current = window.setTimeout(proximo, seg * 1000);
    }
    return () => { window.clearTimeout(timer.current); };
  }, [auto, idx, midia.audios.join(','), vel]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => { if (audio.current) audio.current.playbackRate = vel; }, [vel]);
  useEffect(() => () => parar(), [parar]);
  useEffect(() => {
    const tecla = (e: KeyboardEvent) => {
      if ((e.target as HTMLElement)?.closest('input,textarea')) return;
      if (e.key === 'ArrowRight') ir(idx + 1); if (e.key === 'ArrowLeft') ir(idx - 1);
    };
    window.addEventListener('keydown', tecla);
    return () => window.removeEventListener('keydown', tecla);
  }, [idx, ir]);

  if (!total) return <p>Sem slides neste tema.</p>;
  const s = lista[idx]!; const n = idx + 1;
  const temImg = midia.imagens.includes(n);
  const fonte = midia.audios.includes(n) ? 'áudio gravado' : 'voz do aparelho';
  return (
    <div className="int-slides" ref={caixa}>
      <div className="int-slide" aria-live="polite">
        {temImg
          ? <img src={`${API_BASE}/leitura/slides/${cod}/slide_${num2(n)}.png`} alt={`${s.titulo}. ${s.itens.join('. ')}`} />
          : <SlideDesenhado s={s} n={n} total={total} />}
      </div>
      <div className="int-slide-barra">
        <button type="button" className="int-btn" onClick={() => ir(idx - 1)} disabled={idx === 0} aria-label="Slide anterior">‹ Anterior</button>
        <span className="int-slide-pos">Slide {n} de {total}</span>
        <button type="button" className="int-btn" onClick={() => ir(idx + 1)} disabled={idx === total - 1} aria-label="Próximo slide">Próximo ›</button>
      </div>
      <input type="range" className="int-slide-trilho" min={1} max={total} value={n} aria-label="Ir para o slide"
        onChange={(e) => ir(Number(e.target.value) - 1)} />
      <div className="int-slide-barra">
        <button type="button" className="int-btn prim" onClick={() => { if (auto) { parar(); setAuto(false); guardar(idx, audio.current?.currentTime ?? 0); } else setAuto(true); }}>
          {auto ? 'Pausar' : 'Apresentar com áudio'}
        </button>
        <button type="button" className="int-btn" aria-pressed={verFala} onClick={() => setVerFala(!verFala)}>{verFala ? 'Esconder a fala' : 'Ver a fala'}</button>
        <button type="button" className="int-btn" onClick={() => { const el = caixa.current; if (document.fullscreenElement) void document.exitFullscreen(); else void el?.requestFullscreen?.(); }}>Tela cheia</button>
      </div>
      <SeletorVelocidade valor={vel} mudar={setVel} />
      {falando && <small className="int-nota">{falando === 'mp3' ? 'Tocando o áudio gravado deste slide.' : falando === 'voz' ? 'Lendo a fala com a voz do aparelho (o áudio gravado deste slide ainda não existe).' : 'Este slide não tem fala; passa sozinho em alguns segundos.'} Ao terminar, segue para o próximo.</small>}
      {verFala && <div className="int-fala"><span className="int-rot">Roteiro de fala · {fonte}</span><p>{s.fala || 'Sem fala neste slide.'}</p></div>}
      <audio ref={audio} preload="none" hidden onPause={() => { if (falando === 'mp3') guardar(idx, audio.current?.currentTime ?? 0); }} />
    </div>
  );
}
