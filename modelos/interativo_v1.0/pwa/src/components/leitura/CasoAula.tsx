import { useEffect, useRef, useState } from 'react';
import { Markdown } from '../../lib/md.js';
import { partesDoCaso } from './CasoInterativo.js';
import { SeletorVelocidade, useVelocidade } from './Velocidade.js';

// Caso da aula narrado, para acompanhar depois como se estivesse na reuniao. Mesma divisao do gerador de audio
// (gerar_podcast_audio_v1.0.py --caso): 1 abertura; para cada ponto de decisao, a pergunta (situacao, pergunta da
// turma e o convite a decidir) e a discussao; no fim, o desfecho. Audio: programa-cut/slides/<CODIGO>/caso_NN.mp3;
// sem ele, a voz do aparelho le o texto. Depois de cada pergunta o audio para: a discussao so toca quando o aluno
// pede, para ele decidir antes de ouvir a resposta. O passo em que parou fica guardado no aparelho.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const num2 = (n: number) => String(n).padStart(2, '0');
const semCodigos = (t: string) => t.replace(/\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]/g, '').trim();
const falavel = (t: string) => semCodigos(t).replace(/[*_`#>]/g, '').replace(/xABCDE/g, 'X, A, B, C, D, E').replace(/ABCDE/g, 'A, B, C, D, E').replace(/\s+/g, ' ').trim();

type Voz = 'PRECEPTOR' | 'RESIDENTE';
export interface PassoCaso { tipo: 'abertura' | 'pergunta' | 'discussao' | 'desfecho'; titulo: string; texto: string; falas: [Voz, string][] }

export function passosDoCaso(corpo: string): PassoCaso[] {
  const c = partesDoCaso(corpo);
  if (!c.pontos.length) return [];
  const p: PassoCaso[] = [{ tipo: 'abertura', titulo: 'O caso', texto: c.abertura, falas: [['PRECEPTOR', 'Caso da aula. ' + falavel(c.abertura)]] }];
  for (const pt of c.pontos) {
    const falas: [Voz, string][] = [['PRECEPTOR', falavel(`${pt.titulo}. ${pt.situacao}`)]];
    if (pt.dica) falas.push(['RESIDENTE', falavel('Uma pergunta da turma: ' + pt.dica)]);
    falas.push(['PRECEPTOR', 'Pause aqui e decida a sua conduta. Quando tiver decidido, siga para a discussão.']);
    p.push({ tipo: 'pergunta', titulo: pt.titulo, texto: pt.situacao + (pt.dica ? `\n\n**Pergunta da turma:** ${pt.dica}` : ''), falas });
    p.push({ tipo: 'discussao', titulo: `${pt.titulo}: discussão`, texto: pt.discussao, falas: [['PRECEPTOR', falavel('Discussão. ' + pt.discussao)]] });
  }
  if (c.desfecho) p.push({ tipo: 'desfecho', titulo: 'Desfecho', texto: c.desfecho, falas: [['PRECEPTOR', falavel('Desfecho. ' + c.desfecho)]] });
  return p;
}

function vozesPt(): SpeechSynthesisVoice[] {
  if (typeof speechSynthesis === 'undefined') return [];
  const v = speechSynthesis.getVoices();
  const br = v.filter((x) => x.lang?.toLowerCase().replace('_', '-').startsWith('pt-br'));
  return br.length ? br : v.filter((x) => x.lang?.toLowerCase().startsWith('pt'));
}
const CHAVE = (cod: string) => `cut_caso_aula_${cod}`;
function lerPasso(cod: string): number { try { return Number(localStorage.getItem(CHAVE(cod))) || 0; } catch { return 0; } }
function gravarPasso(cod: string, n: number) { try { localStorage.setItem(CHAVE(cod), String(n)); } catch { /* sem armazenamento */ } }

export function CasoAula(props: { codigo: string; corpo: string }) {
  const cod = props.codigo.replace(/-/g, '').toUpperCase();
  const passos = useRef(passosDoCaso(props.corpo)).current;
  const total = passos.length;
  const [idx, setIdx] = useState(() => Math.min(lerPasso(cod), Math.max(0, total - 1)));
  const [tocando, setTocando] = useState<'mp3' | 'voz' | null>(null);
  const [esperando, setEsperando] = useState(false);
  const [audios, setAudios] = useState<number[]>([]);
  const [vel, setVel] = useVelocidade();
  const audio = useRef<HTMLAudioElement>(null);
  const sessao = useRef(0);
  const topo = useRef<HTMLDivElement>(null);

  useEffect(() => {
    fetch(`${API_BASE}/leitura/slides/${cod}`, { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : {})).then((m: { caso?: number[] }) => setAudios(m.caso ?? [])).catch(() => undefined);
    return () => { sessao.current++; audio.current?.pause(); if (typeof speechSynthesis !== 'undefined') speechSynthesis.cancel(); };
  }, [cod]);
  useEffect(() => { if (audio.current) audio.current.playbackRate = vel; }, [vel]);

  function parar() {
    sessao.current++; audio.current?.pause();
    if (typeof speechSynthesis !== 'undefined') speechSynthesis.cancel();
    setTocando(null);
  }
  function ir(n: number) { parar(); setEsperando(false); const k = Math.min(Math.max(0, n), total - 1); setIdx(k); gravarPasso(cod, k); topo.current?.scrollIntoView({ block: 'nearest' }); }

  // ao terminar um passo: depois da pergunta, espera o aluno; nos outros, segue sozinho
  function terminou(k: number, minha: number) {
    if (minha !== sessao.current) return;
    setTocando(null);
    if (passos[k]?.tipo === 'pergunta') { setEsperando(true); return; }
    if (k < total - 1) { const n = k + 1; setIdx(n); gravarPasso(cod, n); tocar(n); }
  }
  function tocar(k: number) {
    parar(); setEsperando(false);
    const minha = ++sessao.current;
    const p = passos[k]; if (!p) return;
    const a = audio.current;
    if (audios.includes(k + 1) && a) {
      a.src = `${API_BASE}/leitura/slides/${cod}/caso_${num2(k + 1)}.mp3`;
      a.playbackRate = vel;
      a.onended = () => terminou(k, minha);
      setTocando('mp3');
      void a.play().catch(() => setTocando(null));
      return;
    }
    if (typeof speechSynthesis === 'undefined') return;
    const vs = vozesPt();
    p.falas.forEach(([quem, texto], j) => {
      const u = new SpeechSynthesisUtterance(texto);
      u.lang = 'pt-BR'; u.rate = vel;
      const v = quem === 'PRECEPTOR' ? vs[0] : vs[1] ?? vs[0];
      if (v) u.voice = v;
      if (vs.length < 2) u.pitch = quem === 'PRECEPTOR' ? 0.85 : 1.2;
      if (j === p.falas.length - 1) u.onend = () => terminou(k, minha);
      speechSynthesis.speak(u);
    });
    setTocando('voz');
  }

  if (!total) return null;
  const p = passos[idx]!;
  const temAudio = audios.includes(idx + 1);
  return (
    <details className="int-caso-aula">
      <summary>Acompanhar o caso como na aula (com áudio)</summary>
      <div ref={topo}>
        <small className="int-nota">
          O caso narrado em {total} passos: a situação, a pergunta da turma e, quando você pedir, a discussão. Decida a sua conduta antes de ouvir a discussão.
        </small>
        <div className="int-caso-aula-cartao">
          <small className="int-nota">Passo {idx + 1} de {total}</small>
          <h4>{p.titulo}</h4>
          <Markdown texto={p.texto} />
        </div>
        {esperando && (
          <div className="int-caso-aula-pausa">
            <strong>Sua vez: qual é a sua conduta?</strong>
            <button type="button" onClick={() => { const n = idx + 1; setIdx(n); gravarPasso(cod, n); tocar(n); }}>Já decidi: ouvir a discussão</button>
          </div>
        )}
        <div className="pod-voz">
          {!tocando && !esperando && <button type="button" className="pod-principal" onClick={() => tocar(idx)}>{idx === 0 ? 'Ouvir o caso' : 'Ouvir este passo'}</button>}
          {tocando && <button type="button" onClick={parar}>Parar</button>}
          <button type="button" onClick={() => ir(idx - 1)} disabled={idx === 0}>Anterior</button>
          <button type="button" onClick={() => ir(idx + 1)} disabled={idx >= total - 1}>Próximo</button>
        </div>
        {tocando && <small className="int-nota">{tocando === 'mp3' ? 'Tocando o áudio gravado deste passo.' : 'Lendo com a voz do aparelho (o áudio gravado deste passo ainda não existe).'}</small>}
        {!tocando && !temAudio && <small className="int-nota">Sem áudio gravado: a voz do seu aparelho lê o texto.</small>}
        <SeletorVelocidade valor={vel} mudar={setVel} />
        <audio ref={audio} preload="none" hidden />
      </div>
    </details>
  );
}
