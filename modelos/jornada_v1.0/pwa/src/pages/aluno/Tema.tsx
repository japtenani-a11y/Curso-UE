import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Avaliacao } from '../../components/Engajamento.js';

interface Teste { num: number; nome: string; abre: string | null; fecha: string | null; liberado: boolean; respondivel: boolean;
  feito: boolean; perdido: boolean; nota: number | null; avaliado: boolean }
interface Material { tipo: string; nome: string; etapa: number; liberado: boolean; publicado: boolean; usado: boolean; avaliado: boolean }
interface Jornada { codigo: string; titulo: string; modulo: string | null; papel: string; dificuldade: number; agendado: boolean;
  d0: string | null; pode_agendar: boolean; etapa: number; testes: Teste[]; materiais: Material[]; tema_avaliado: boolean }

const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
const dia = (s: string) => new Date(s).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' });
const ERROS: Record<string, string> = {
  data_invalida: 'Escolha uma data entre 2 horas e 400 dias a partir de agora.',
  tema_ja_iniciado: 'Você já começou este tema; a data não pode mais mudar.',
};

function codigoDaUrl(): string { return window.location.pathname.match(/tema\/([A-Za-z0-9-]+)/)?.[1] ?? 'T001'; }

// Etapas do tema, na ordem em que o aluno as percorre.
const FASES = [
  { etapa: 1, titulo: 'Abertura (D-15)', testes: [1], texto: 'O tema abre 15 dias antes da aula, com o pré-teste inicial.' },
  { etapa: 2, titulo: 'Pré-aula', testes: [2], texto: 'Liberado ao enviar o pré-teste inicial. O pré-teste 2 fecha 1 hora antes da aula.' },
  { etapa: 3, titulo: 'Aula (D0)', testes: [3], texto: 'Liberado na hora da aula, com o pré-teste inicial feito.' },
  { etapa: 4, titulo: 'Pós-aula', testes: [4, 5, 6], texto: 'Liberado ao enviar o pós-teste D0. Os pós-testes seguem em D+15, D+45 e D+90.' },
];

function estadoTeste(t: Teste): { rotulo: string; classe: string } {
  if (t.feito) return { rotulo: t.nota !== null ? `feito · ${Number(t.nota).toFixed(0)}%` : 'feito', classe: 'ok' };
  if (t.perdido) return { rotulo: 'prazo encerrado', classe: 'perdido' };
  if (t.respondivel) return { rotulo: 'disponível', classe: 'aberto' };
  if (t.abre && new Date(t.abre) > new Date()) return { rotulo: `abre em ${dia(t.abre)}`, classe: 'futuro' };
  return { rotulo: 'bloqueado', classe: 'bloqueado' };
}

export function Tema() {
  const codigo = codigoDaUrl();
  const [j, setJ] = useState<Jornada | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [d0, setD0] = useState('');
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => apiGet<Jornada>(`/jornada/temas/${codigo}`).then(setJ).catch(() => setErro('Tema não encontrado.'));
  useEffect(() => { carregar(); }, []);

  async function agendar() {
    if (!d0) return;
    try {
      await apiPost(`/eng/temas/${codigo}/agendar`, { d0: new Date(d0).toISOString() });
      setMsg('Data registrada. O pré-teste inicial abre 15 dias antes (ou já, se faltar menos que isso).'); carregar();
    } catch (e) {
      const m = e instanceof Error ? e.message : '';
      setMsg(ERROS[Object.keys(ERROS).find((k) => m.includes(k)) ?? 'data_invalida'] ?? 'Não foi possível agendar.');
    }
  }

  if (erro) return <p role="alert">{erro}</p>;
  if (!j) return <p className="carregando">Carregando…</p>;
  const cod = j.codigo.replace('-', '');
  const temMaterial = j.materiais.some((m) => m.publicado);

  return (
    <section className="tema">
      <p className="migalha"><a href="/aluno/temas">Temas</a> › {j.modulo ?? 'Outros'}</p>
      <h1>{j.codigo} — {j.titulo}</h1>
      <p className="tema-info">
        <span className={`selo ${j.papel}`}>{j.papel === 'nuclear' ? 'principal' : j.papel === 'complementar' ? 'recomendado' : 'opcional'}</span>
        <span>Grau de dificuldade {j.dificuldade}</span>
        {j.d0 && <span><strong>Aula (D0):</strong> {quando(j.d0)}</span>}
      </p>
      {msg && <p className="faixa-aviso" role="status">{msg}</p>}

      {!j.agendado && j.papel === 'nuclear' && (
        <p className="faixa-aviso">Este tema ainda não abriu. {j.d0 ? `A aula é em ${quando(j.d0)}; o pré-teste inicial abre 15 dias antes e você recebe um aviso.` : 'A data da aula ainda será definida.'}</p>
      )}
      {j.pode_agendar && (
        <div className="cartao-app">
          <h3 style={{ marginTop: 0 }}>{j.agendado ? 'Mudar a minha data' : 'Agendar este tema'}</h3>
          <p>Escolha o dia e a hora em que você quer estudar a aula (D0). Todo o resto segue essa data:
            pré-teste inicial em D-15, pré-teste 2 até 1 hora antes, pós-testes em D0, D+15, D+45 e D+90.</p>
          <span className="agendar">
            <input type="datetime-local" aria-label="Data do D0" value={d0} onChange={(e) => setD0(e.target.value)} />
            <button type="button" className="botao" disabled={!d0} onClick={agendar}>{j.agendado ? 'Mudar data' : 'Agendar'}</button>
          </span>
        </div>
      )}

      <ol className="fases">
        {FASES.map((f) => {
          const atual = j.agendado && j.etapa === f.etapa;
          const feita = j.agendado && j.etapa > f.etapa;
          const mats = j.materiais.filter((m) => m.etapa === f.etapa);
          return (
            <li key={f.etapa} className={`fase${atual ? ' atual' : ''}${feita ? ' feita' : ''}`}>
              <h2>{f.titulo}</h2>
              <p className="fase-texto">{f.texto}</p>
              <ul className="itens">
                {f.testes.map((n) => {
                  const t = j.testes.find((x) => x.num === n);
                  if (!t) return null;
                  const e = estadoTeste(t);
                  return (
                    <li key={`t${n}`}>
                      <span className="item-nome">{t.nome}{t.fecha && n === 2 && !t.feito && !t.perdido ? <small> · até {quando(t.fecha)}</small> : null}</span>
                      <span className={`estado ${e.classe}`}>{e.rotulo}</span>
                      {t.respondivel && !t.feito && <a className="botao" href={`/aluno/testes/${cod}`}>Responder</a>}
                      {t.feito && <a className="botao discreto" href={`/aluno/testes/${cod}`}>Ver gabarito</a>}
                    </li>
                  );
                })}
                {mats.map((m) => (
                  <li key={m.tipo}>
                    <span className="item-nome">{m.nome}</span>
                    <span className={`estado ${!m.publicado ? 'futuro' : m.liberado ? (m.usado ? 'ok' : 'aberto') : 'bloqueado'}`}>
                      {!m.publicado ? 'em produção' : !m.liberado ? 'bloqueado' : m.usado ? 'lido' : 'liberado'}</span>
                    {m.publicado && m.liberado && <a className="botao discreto" href={`/aluno/leitura/${cod}?peca=${m.tipo}`}>Abrir</a>}
                  </li>
                ))}
              </ul>
            </li>
          );
        })}
      </ol>
      {!temMaterial && <p className="faixa-aviso">O material deste tema ainda está em revisão; os testes e o calendário já valem.</p>}
      {j.testes.find((t) => t.num === 3)?.feito && (
        <div style={{ marginTop: 16 }}>
          <Avaliacao tema={j.codigo} ferramenta="tema" titulo={`o tema ${j.codigo}`} modo="tema" aoSalvar={carregar} />
        </div>
      )}
    </section>
  );
}
