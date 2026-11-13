import { useEffect, useMemo, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Tema { codigo: string; titulo: string; modulo: string | null; dificuldade: number; papel: string; ordem: number | null;
  data_d0: string | null; d0_proprio: boolean; etapa: number; testes_feitos: number; tem_conteudo: boolean }

const dia = (s: string) => new Date(s).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' });
const PAPEL: Record<string, string> = { nuclear: 'principal', complementar: 'recomendado', eletivo: 'opcional' };

function situacao(t: Tema): string {
  if (t.testes_feitos >= 6) return 'concluído';
  if (t.testes_feitos > 0) return `em andamento · ${t.testes_feitos}/6 testes`;
  if (t.data_d0 && (t.papel === 'nuclear' || t.d0_proprio)) return `aula em ${dia(t.data_d0)}`;
  return t.papel === 'nuclear' ? 'data a definir' : 'escolha a sua data';
}

// Entrada por modulo: o aluno escolhe o modulo e, dentro dele, o tema.
export function Temas() {
  const [temas, setTemas] = useState<Tema[] | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [filtro, setFiltro] = useState('');
  const [aberto, setAberto] = useState<string | null>(null);
  useEffect(() => { apiGet<{ temas: Tema[] }>('/eng/catalogo').then((d) => setTemas(d.temas)).catch(() => setErro('Não foi possível carregar os temas.')); }, []);

  const modulos = useMemo(() => {
    const m = new Map<string, Tema[]>();
    for (const t of temas ?? []) {
      if (filtro && !`${t.codigo} ${t.titulo} ${t.modulo}`.toLowerCase().includes(filtro.toLowerCase())) continue;
      const k = t.modulo ?? 'Outros';
      m.set(k, [...(m.get(k) ?? []), t]);
    }
    return [...m.entries()].sort((a, b) => a[0].localeCompare(b[0], 'pt-BR'));
  }, [temas, filtro]);

  if (!temas) return <p className="carregando">{erro ?? 'Carregando…'}</p>;
  return (
    <section>
      <h1>Temas por módulo</h1>
      <p>Escolha o módulo e depois o tema. Os <strong>principais</strong> têm data de aula do grupo (quintas, 20h).
        Nos <strong>opcionais</strong> você escolhe a sua data (D0) dentro do tema. Também dá para entrar pelo <a href="/aluno/calendario">calendário de aulas</a>.</p>
      <input className="busca" placeholder="Buscar tema ou módulo" value={filtro} onChange={(e) => setFiltro(e.target.value)} aria-label="Buscar tema" />
      <div className="modulos">
        {modulos.map(([mod, lista]) => {
          const ab = aberto === mod || filtro !== '';
          const principais = lista.filter((t) => t.papel === 'nuclear').length;
          return (
            <article key={mod} className="cartao-app modulo">
              <button type="button" className="modulo-cab" aria-expanded={ab} onClick={() => setAberto(ab && !filtro ? null : mod)}>
                <span><strong>{mod}</strong><small>{lista.length} temas{principais ? ` · ${principais} principais` : ''}</small></span>
                <span aria-hidden="true">{ab ? '▾' : '▸'}</span>
              </button>
              {ab && (
                <ul className="lista-temas">
                  {lista.map((t) => (
                    <li key={t.codigo}>
                      <a href={`/aluno/tema/${t.codigo.replace('-', '')}`}>
                        <span className="cod">{t.codigo}</span>
                        <span className="tit">{t.titulo}</span>
                        <span className={`selo ${t.papel}`}>{PAPEL[t.papel] ?? t.papel}</span>
                        <span className="sit">{situacao(t)}</span>
                      </a>
                    </li>
                  ))}
                </ul>
              )}
            </article>
          );
        })}
      </div>
    </section>
  );
}
