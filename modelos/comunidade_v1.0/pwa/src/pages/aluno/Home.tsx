import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { useSessao } from '../../lib/sessao.js';
import { Lembretes } from '../../components/Lembretes.js';
import { Contagem } from '../../components/Contagem.js';
import { ResgatarPresenca } from '../../components/ResgatarPresenca.js';

interface Aula { data_hora: string; codigo: string; titulo: string; papel: string; proprio: boolean; testes_feitos: number; etapa: number }
interface Pendencia { codigo: string; titulo: string; tipo: string; nome: string; prazo: string | null }
interface Mural { id: number; titulo: string; tipo: string; lido: boolean; respondido: boolean; fixado: boolean }

const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });

// Inicio do aluno: proxima aula com Meet e contagem, pendencias, mural, calendario (principais e opcionais) e entradas.
export function AlunoHome() {
  const { sessao } = useSessao();
  const [aulas, setAulas] = useState<Aula[] | null>(null);
  const [pend, setPend] = useState<Pendencia[] | null>(null);
  const [mural, setMural] = useState<Mural[]>([]);
  const [meet, setMeet] = useState<string | null>(null);
  useEffect(() => {
    apiGet<{ aulas: Aula[] }>('/jornada/calendario').then((d) => setAulas(d.aulas)).catch(() => setAulas([]));
    apiGet<{ pendencias: Pendencia[] }>('/jornada/pendencias').then((d) => setPend(d.pendencias)).catch(() => setPend([]));
    apiGet<{ itens: Mural[] }>('/com/mural').then((d) => setMural(d.itens)).catch(() => undefined);
    apiGet<{ meet: string }>('/com/agenda/link').then((d) => setMeet(d.meet)).catch(() => undefined);
  }, []);
  const agora = Date.now() - 2 * 3600_000;
  const futuras = (aulas ?? []).filter((a) => new Date(a.data_hora).getTime() >= agora);
  const prox = futuras[0];
  const principais = futuras.filter((a) => !a.proprio).slice(0, 4);
  const opcionais = futuras.filter((a) => a.proprio).slice(0, 4);
  const testes = (pend ?? []).filter((p) => p.tipo === 'teste').sort((a, b) => (a.prazo ?? '9').localeCompare(b.prazo ?? '9'));
  const avals = (pend ?? []).length - testes.length;
  const naoLidos = mural.filter((m) => !m.lido || (m.tipo === 'questionario' && !m.respondido));
  const aoVivo = prox && Math.abs(new Date(prox.data_hora).getTime() - Date.now()) < 2 * 3600_000;
  return (
    <section className="inicio-aluno">
      <h1>Olá, {sessao?.nome_completo.split(' ')[0]}</h1>
      <Lembretes />
      <div className="grade-inicio">
        <article className="cartao-app destaque">
          <span className="rotulo">{aoVivo ? 'Aula agora' : 'Próxima aula'}</span>
          {prox ? (<>
            <h2><a href={`/aluno/tema/${prox.codigo.replace('-', '')}`}>{prox.codigo} — {prox.titulo}</a></h2>
            <p>{quando(prox.data_hora)} · <Contagem ate={prox.data_hora} prefixo="começa em" /></p>
            <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {meet && !prox.proprio && <a className="botao" href={meet} target="_blank" rel="noopener noreferrer">Entrar no Google Meet</a>}
              <a className="botao discreto" href={`/aluno/tema/${prox.codigo.replace('-', '')}`}>Abrir o tema</a>
            </p>
          </>) : <p>Nenhuma aula agendada. Veja o <a href="/aluno/calendario">calendário</a>.</p>}
          <ResgatarPresenca />
        </article>

        <article className="cartao-app">
          <span className="rotulo">Pendências</span>
          <h2><a href="/aluno/pendencias">{pend === null ? '…' : testes.length + avals === 0 ? 'Nada pendente' : `${testes.length} ${testes.length === 1 ? 'teste' : 'testes'} · ${avals} ${avals === 1 ? 'avaliação' : 'avaliações'}`}</a></h2>
          <ul className="lista-curta">
            {testes.slice(0, 3).map((t) => (
              <li key={t.codigo + t.nome}><a href={`/aluno/testes/${t.codigo.replace('-', '')}`}>{t.codigo} · {t.nome}</a> <Contagem ate={t.prazo} /></li>
            ))}
          </ul>
        </article>

        <article className="cartao-app">
          <span className="rotulo">Mural</span>
          <h2><a href="/aluno/mural">{naoLidos.length ? `${naoLidos.length} ${naoLidos.length === 1 ? 'novidade' : 'novidades'}` : 'Tudo lido'}</a></h2>
          <ul className="lista-curta">{naoLidos.slice(0, 3).map((m) => <li key={m.id}><a href="/aluno/mural">{m.tipo === 'questionario' ? 'Questionário: ' : m.tipo === 'documento' ? 'Documento: ' : ''}{m.titulo}</a></li>)}</ul>
        </article>
      </div>

      <div className="grade-inicio duas">
        <article className="cartao-app">
          <span className="rotulo">Calendário · temas principais</span>
          <ul className="lista-temas">
            {principais.map((a) => (
              <li key={a.codigo}><a href={`/aluno/tema/${a.codigo.replace('-', '')}`}><span className="cod">{quando(a.data_hora)}</span><span className="tit">{a.codigo} {a.titulo}</span>
                <span className={`selo ${a.etapa === 0 ? 'bloqueado' : 'nuclear'}`}>{a.etapa === 0 ? 'bloqueado' : 'grupo'}</span><span className="sit" /></a></li>
            ))}
          </ul>
          <p><a href="/aluno/calendario">Ver o calendário completo</a></p>
        </article>
        <article className="cartao-app">
          <span className="rotulo">Calendário · meus opcionais</span>
          {opcionais.length === 0 ? <p>Você ainda não agendou temas opcionais. Escolha em <a href="/aluno/temas">Temas</a> ou na <a href="/aluno/arvore">árvore</a>.</p> : (
            <ul className="lista-temas">{opcionais.map((a) => (
              <li key={a.codigo} className="proprio"><a href={`/aluno/tema/${a.codigo.replace('-', '')}`}><span className="cod">{quando(a.data_hora)}</span><span className="tit">{a.codigo} {a.titulo}</span>
                <span className="selo eletivo">minha data</span><span className="sit" /></a></li>))}</ul>
          )}
        </article>
      </div>

      <nav className="cartoes entradas" aria-label="Entradas do curso">
        <a className="cartao-app entrada" href="/aluno/temas"><span className="rotulo">Temas por módulo</span><strong>Todos os temas</strong><span>Escolha o módulo e depois o tema.</span></a>
        <a className="cartao-app entrada" href="/aluno/arvore"><span className="rotulo">Árvore de temas</span><strong>Progressão</strong><span>Cada tema concluído libera os seguintes.</span></a>
        <a className="cartao-app entrada" href="/aluno/desempenho"><span className="rotulo">Desempenho</span><strong>Notas e ranking</strong><span>Sua nota, a esperada e a dos colegas.</span></a>
        <a className="cartao-app entrada" href="/aluno/aproveitamento"><span className="rotulo">Presença e certificado</span><strong>Aproveitamento</strong><span>Presença nas aulas e certificado.</span></a>
      </nav>
      <p><a href="/ajuda">Ajuda: como o curso funciona e como instalar no celular</a> · <a href="/aluno/contato">Configurar lembretes por e-mail</a></p>
    </section>
  );
}
