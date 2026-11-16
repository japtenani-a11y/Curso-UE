import { useEffect, useState } from 'react';

// Pecas do tema agrupadas na ordem da liberacao (antes da aula, aula, depois da aula), com a situacao de cada uma:
// "feito" (caso respondido, checklist marcado...), "visto" (aberto ao menos uma vez) ou "novo".
// O grupo da peca aberta fica expandido; os outros mostram so o resumo e abrem com um toque.
export const ETAPA_PECA: Record<string, number> = {
  objetivos: 2, resumo_basico: 2, podcast_roteiro: 2, caso_base: 2, sintese_evidencia: 2, mapa: 2,
  aula: 3, slides: 3, caso: 3, resumo: 4, protocolo: 4, checklist: 4, flashcard: 4, simulado: 4,
};
export const NOME_PECA: Record<string, string> = {
  objetivos: 'Objetivos', resumo_basico: 'Resumo básico', podcast_roteiro: 'Podcast', caso_base: 'Caso base',
  sintese_evidencia: 'Síntese de evidência', mapa: 'Mapa conceitual', aula: 'Aula', slides: 'Slides', caso: 'Caso da aula',
  resumo: 'Resumo executivo', protocolo: 'Protocolo', checklist: 'Checklist', flashcard: 'Flashcards', simulado: 'Banco de questões',
};
const GRUPOS = [
  { etapa: 2, titulo: 'Antes da aula', fechado: '' },
  { etapa: 3, titulo: 'Aula', fechado: 'Abre na hora da aula, com o pré-teste 2 enviado.' },
  { etapa: 4, titulo: 'Depois da aula', fechado: 'Abre quando você envia o pós-teste D0.' },
];
const SINAL: Record<string, { marca: string; texto: string }> = {
  feito: { marca: '✓', texto: 'feito' }, visto: { marca: '•', texto: 'visto' }, novo: { marca: '', texto: 'novo' },
};
interface Peca { tipo: string; titulo: string }

export function AbasPorEtapa(props: { pecas: Peca[]; ativo: number; mudar: (i: number) => void; situacao: Record<string, string>; etapa: number; previa: boolean }) {
  const atual = props.pecas[props.ativo]?.tipo ?? '';
  const grupoAtual = ETAPA_PECA[atual] ?? 2;
  const [abertos, setAbertos] = useState<Set<number>>(() => new Set([grupoAtual]));
  useEffect(() => { setAbertos((a) => new Set(a).add(grupoAtual)); }, [grupoAtual]);
  const sit = (t: string) => (t === atual && !props.situacao[t] ? 'visto' : props.situacao[t] ?? 'novo');
  return (
    <nav className="lei-grupos" aria-label="Material do tema">
      {GRUPOS.map((g) => {
        const lista = props.pecas.map((p, i) => ({ ...p, i })).filter((p) => (ETAPA_PECA[p.tipo] ?? 4) === g.etapa);
        const aberto = abertos.has(g.etapa);
        const vistas = lista.filter((p) => sit(p.tipo) !== 'novo').length;
        if (!lista.length) {
          if (props.previa || props.etapa >= g.etapa) return null;
          return (
            <div key={g.etapa} className="lei-grupo fechado">
              <span className="lei-grupo-tit">{g.titulo}</span><span className="lei-grupo-resumo">{g.fechado}</span>
            </div>
          );
        }
        return (
          <div key={g.etapa} className={`lei-grupo${aberto ? ' aberto' : ''}`}>
            <button type="button" className="lei-grupo-cab" aria-expanded={aberto}
              onClick={() => setAbertos((a) => { const b = new Set(a); if (b.has(g.etapa)) b.delete(g.etapa); else b.add(g.etapa); return b; })}>
              <span className="lei-grupo-tit">{g.titulo}</span>
              <span className="lei-grupo-resumo">{vistas} de {lista.length} {lista.length === 1 ? 'vista' : 'vistas'}</span>
              <span aria-hidden="true">{aberto ? '−' : '+'}</span>
            </button>
            {aberto && (
              <div className="lei-pecas">
                {lista.map((p) => {
                  const s = SINAL[sit(p.tipo)]!;
                  return (
                    <button key={p.tipo} type="button" className={`lei-peca ${sit(p.tipo)}${p.i === props.ativo ? ' ativa' : ''}`}
                      aria-current={p.i === props.ativo ? 'page' : undefined} onClick={() => props.mudar(p.i)}>
                      <span className="lei-peca-marca" aria-hidden="true">{s.marca}</span>
                      <span>{NOME_PECA[p.tipo] ?? p.titulo}</span>
                      <span className="so-leitor">, {s.texto}</span>
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        );
      })}
    </nav>
  );
}
