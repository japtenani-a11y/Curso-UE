import { useState } from 'react';

// Velocidade do audio (podcast e slides), de 1x a 2x; a escolha fica guardada no aparelho.
export const VELOCIDADES = [1, 1.25, 1.5, 1.75, 2];
const CHAVE = 'cut_velocidade';
export function velocidadeSalva(): number {
  try { const v = Number(localStorage.getItem(CHAVE)); return VELOCIDADES.includes(v) ? v : 1; } catch { return 1; }
}
export function useVelocidade(): [number, (v: number) => void] {
  const [v, setV] = useState(velocidadeSalva);
  return [v, (n: number) => { setV(n); try { localStorage.setItem(CHAVE, String(n)); } catch { /* sem armazenamento */ } }];
}
export function SeletorVelocidade(props: { valor: number; mudar: (v: number) => void }) {
  return (
    <div className="int-vel" role="radiogroup" aria-label="Velocidade do áudio">
      <span>Velocidade</span>
      {VELOCIDADES.map((v) => (
        <button key={v} type="button" role="radio" aria-checked={props.valor === v} onClick={() => props.mudar(v)}>
          {String(v).replace('.', ',')}×
        </button>
      ))}
    </div>
  );
}
