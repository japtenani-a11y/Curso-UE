import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { useSessao } from '../../lib/sessao.js';
import { Lembretes } from '../../components/Lembretes.js';

interface Teste { onda_id: number; teste_num: number; liberado: boolean; respondivel: boolean; submetida_em: string | null; data_abertura: string; data_fechamento: string }
interface Lista { tema: { codigo: string; titulo: string; etapa: number; perfil: string | null }; testes: Teste[] }

const ETAPAS = ['Pré-teste inicial', 'Material pré-reunião e pré-teste 2', 'Reunião e pós-teste D0', 'Pós-reunião e pós-testes'];
const NOMES = ['', 'Pré-teste inicial', 'Pré-teste 2', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90'];
const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });

export function AlunoHome() {
  const { sessao } = useSessao();
  const [d, setD] = useState<Lista | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  useEffect(() => { apiGet<Lista>('/teste/temas/T001').then(setD).catch(() => setErro('Não foi possível carregar o tema.')); }, []);

  const proximo = d?.testes.find((t) => t.liberado && t.respondivel && !t.submetida_em);
  return (
    <section>
      <h1>Olá, {sessao?.nome_completo.split(' ')[0]}</h1>
      <Lembretes />
      {erro && <p className="faixa-erro">{erro}</p>}
      {!d ? <p className="carregando">Carregando…</p> : (
        <div className="cartoes">
          <article className="cartao-app" style={{ gridColumn: '1 / -1' }}>
            <span className="rotulo">{d.tema.codigo}</span>
            <h2 style={{ marginTop: 4 }}>{d.tema.titulo}</h2>
            {!d.tema.perfil && <p className="faixa-aviso">Seu ano de formação ainda não está cadastrado. Fale com a coordenação para liberar os testes.</p>}
            <div className="etapas" aria-label="Etapas do tema">
              {ETAPAS.map((e, i) => (
                <div key={e} className={`etapa${i + 1 < d.tema.etapa ? ' feita' : i + 1 === d.tema.etapa ? ' atual' : ''}`}>{i + 1}. {e}</div>
              ))}
            </div>
            <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {proximo
                ? <a className="botao" href="/aluno/testes/T001">Responder: {NOMES[proximo.teste_num]}{proximo.teste_num === 2 ? ` (até ${quando(proximo.data_fechamento)})` : ''}</a>
                : <a className="botao secundario" href="/aluno/testes/T001">Ver testes e gabaritos</a>}
              <a className="botao discreto" href="/aluno/leitura/T001">Material do tema</a>
            </p>
          </article>
          <article className="cartao-app">
            <h3>Como funciona</h3>
            <p>O material abre por etapas: cada teste enviado libera a etapa seguinte. O gabarito comentado aparece logo depois do envio.</p>
          </article>
          <article className="cartao-app">
            <h3>Lembretes</h3>
            <p>Receba avisos por e-mail quando um teste estiver perto do prazo ou pendente.</p>
            <a className="botao discreto" href="/aluno/contato">Configurar lembretes</a>
          </article>
        </div>
      )}
    </section>
  );
}
