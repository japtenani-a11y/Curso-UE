import { useEffect, useState } from 'react';
import { Continuar } from './Continuar.js';
import { AvisosCelular } from './AvisosCelular.js';

// Inicio: a proxima acao em destaque (uma so), escolhida no servidor pela ordem:
// aula agora > teste com prazo em ate 3 dias > continuar o que estudou > outro teste > revisao do dia > proxima aula.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface Acao { tipo: string; texto: string; botao: string; link: string; titulo?: string; prazo?: string; quando?: string; urgente?: boolean }

function falta(iso: string): string {
  const ms = new Date(iso).getTime() - Date.now();
  if (ms <= 0) return 'prazo encerrado';
  const h = Math.round(ms / 3_600_000);
  return h < 24 ? `fecha em ${h} ${h === 1 ? 'hora' : 'horas'}` : `fecha em ${Math.round(h / 24)} dias`;
}

export function ProximaAcao() {
  const [a, setA] = useState<Acao | null | undefined>(undefined);
  useEffect(() => {
    fetch(`${API_BASE}/leitura/proxima-acao`, { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : { acao: null })).then((j: { acao: Acao | null }) => setA(j.acao)).catch(() => setA(null));
  }, []);
  if (a === undefined) return null;
  return (
    <>
      {a && (
        <a className={`int-proxima${a.urgente ? ' urgente' : ''}`} href={a.link}>
          <span className="int-rot">O que fazer agora</span>
          <strong>{a.texto}</strong>
          {a.titulo && <small>{a.titulo}</small>}
          {a.prazo && a.urgente && <small className="int-prazo">{falta(a.prazo)}</small>}
          <span className="int-btn prim">{a.botao}</span>
        </a>
      )}
      {a?.tipo !== 'continuar' && <Continuar />}
      <AvisosCelular compacto />
    </>
  );
}
