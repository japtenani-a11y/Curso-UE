import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { useSessao } from '../../lib/sessao.js';
import { Lembretes } from '../../components/Lembretes.js';

interface Aula { data_hora: string; codigo: string; titulo: string; proprio: boolean; testes_feitos: number }
interface Pendencia { codigo: string; tipo: string }

const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'long', day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });

// Pagina inicial do aluno: tres entradas (modulo, calendario, pendencias) e a proxima aula.
export function AlunoHome() {
  const { sessao } = useSessao();
  const [aulas, setAulas] = useState<Aula[] | null>(null);
  const [pend, setPend] = useState<Pendencia[] | null>(null);
  useEffect(() => {
    apiGet<{ aulas: Aula[] }>('/jornada/calendario').then((d) => setAulas(d.aulas)).catch(() => setAulas([]));
    apiGet<{ pendencias: Pendencia[] }>('/jornada/pendencias').then((d) => setPend(d.pendencias)).catch(() => setPend([]));
  }, []);
  const agora = Date.now() - 3 * 3600_000;
  const proximas = (aulas ?? []).filter((a) => new Date(a.data_hora).getTime() >= agora).slice(0, 3);
  const testes = (pend ?? []).filter((p) => p.tipo === 'teste').length;
  const avals = (pend ?? []).length - testes;
  return (
    <section>
      <h1>Olá, {sessao?.nome_completo.split(' ')[0]}</h1>
      <Lembretes />
      <div className="cartoes entradas">
        <a className="cartao-app entrada" href="/aluno/pendencias">
          <span className="rotulo">Pendências</span>
          <strong>{pend === null ? '…' : testes + avals === 0 ? 'Nada pendente' : `${testes} ${testes === 1 ? 'teste' : 'testes'} · ${avals} ${avals === 1 ? 'avaliação' : 'avaliações'}`}</strong>
          <span>Testes liberados e avaliações que faltam, por tema.</span>
        </a>
        <a className="cartao-app entrada" href="/aluno/calendario">
          <span className="rotulo">Calendário de aulas</span>
          <strong>{proximas[0] ? `${proximas[0].codigo} · ${quando(proximas[0].data_hora)}` : 'Ver datas'}</strong>
          <span>Quintas, 20h, Google Meet. Escolha o tema pela data.</span>
        </a>
        <a className="cartao-app entrada" href="/aluno/temas">
          <span className="rotulo">Temas por módulo</span>
          <strong>Todos os temas, por módulo</strong>
          <span>39 principais com data do grupo; nos opcionais você escolhe a sua data.</span>
        </a>
      </div>
      {proximas.length > 0 && (
        <article className="cartao-app" style={{ marginTop: 16 }}>
          <h2 style={{ marginTop: 0 }}>Próximas aulas</h2>
          <ul className="lista-temas">
            {proximas.map((a) => (
              <li key={`${a.codigo}${a.data_hora}`}><a href={`/aluno/tema/${a.codigo.replace('-', '')}`}>
                <span className="cod">{quando(a.data_hora)}</span><span className="tit">{a.codigo} {a.titulo}</span>
                <span className={`selo ${a.proprio ? 'eletivo' : 'nuclear'}`}>{a.proprio ? 'minha data' : 'grupo'}</span><span className="sit" />
              </a></li>
            ))}
          </ul>
        </article>
      )}
      <article className="cartao-app" style={{ marginTop: 16 }}>
        <h3 style={{ marginTop: 0 }}>Como cada tema funciona</h3>
        <ol>
          <li><strong>D-15:</strong> o tema abre com o pré-teste inicial (você recebe um aviso).</li>
          <li><strong>Pré-aula:</strong> ao enviar o pré-teste inicial, chegam o material pré-aula e o pré-teste 2 (até 1 hora antes da aula).</li>
          <li><strong>D0:</strong> na hora da aula, abrem o material da aula (aula e caso) e o pós-teste D0.</li>
          <li><strong>Pós-aula:</strong> ao enviar o pós-teste D0, chegam síntese, resumo executivo, mapa, flashcards, protocolo, checklists e simulados; os pós-testes voltam em D+15, D+45 e D+90.</li>
        </ol>
        <p>O gabarito comentado de cada teste aparece logo depois que você o envia.</p>
      </article>
    </section>
  );
}
