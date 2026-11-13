import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Resumo { inscricoes_pendentes: number; alunos_ativos: number; duvidas_pendentes: number; rascunhos: number; publicados: number;
  proximas_aulas: { codigo: string; titulo: string; data_hora: string }[] }
const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });

// Inicio da coordenacao e dos revisores: o que precisa de atencao, proximas aulas e atalhos.
export function CuradorHome() {
  const [r, setR] = useState<Resumo | null>(null);
  const [meet, setMeet] = useState<string | null>(null);
  useEffect(() => {
    apiGet<Resumo>('/com/coordenacao/resumo').then(setR).catch(() => setR(null));
    apiGet<{ meet: string }>('/com/agenda/link').then((d) => setMeet(d.meet)).catch(() => undefined);
  }, []);
  const cartao = (rotulo: string, valor: number | string, href: string, texto: string, alerta = false) => (
    <a className={`cartao-app entrada${alerta ? ' alerta' : ''}`} href={href}><span className="rotulo">{rotulo}</span><strong>{valor}</strong><span>{texto}</span></a>
  );
  return (
    <section>
      <h1>Coordenação</h1>
      {!r ? <p className="carregando">Carregando…</p> : (<>
        <div className="cartoes entradas">
          {cartao('Inscrições', r.inscricoes_pendentes, '/curador/inscricoes', 'aguardando aprovação', r.inscricoes_pendentes > 0)}
          {cartao('Dúvidas', r.duvidas_pendentes, '/curador/duvidas', 'sem resposta', r.duvidas_pendentes > 0)}
          {cartao('Revisão', `${r.rascunhos} rascunhos`, '/curador/revisao/T001', `${r.publicados} peças publicadas`)}
          {cartao('Alunos', r.alunos_ativos, '/painel', 'inscritos aprovados · ver dados')}
        </div>
        <div className="grade-inicio duas" style={{ marginTop: 16 }}>
          <article className="cartao-app">
            <span className="rotulo">Próximas aulas</span>
            {r.proximas_aulas.length === 0 ? <p>A agenda ainda não foi gravada (rode o 48 quando for abrir o curso).</p> : (
              <ul className="lista-temas">{r.proximas_aulas.map((a) => (
                <li key={a.codigo}><a href={`/curador/presenca/${a.codigo.replace('-', '')}`}><span className="cod">{quando(a.data_hora)}</span><span className="tit">{a.codigo} {a.titulo}</span><span className="selo nuclear">presença</span><span className="sit" /></a></li>))}</ul>
            )}
            {meet && <p><a className="botao" href={meet} target="_blank" rel="noopener noreferrer">Abrir a sala do Meet</a> <small>{meet}</small></p>}
          </article>
          <article className="cartao-app">
            <span className="rotulo">Atalhos</span>
            <ul className="lista-curta">
              <li><a href="/curador/mural">Publicar aviso, questionário ou documento</a></li>
              <li><a href="/curador/presenca">Código de presença e relatório do Meet</a></li>
              <li><a href="/curador/inscricoes">Regras de aprovação automática e preceptores</a></li>
              <li><a href="/painel">Dados, gráficos e análise das questões</a></li>
              <li><a href="/aluno/arvore">Árvore de temas</a> · <a href="/aluno/calendario">Calendário</a></li>
              <li><a href="/curador/previa/T001">Prévia do material como o aluno vê</a></li>
            </ul>
          </article>
        </div>
      </>)}
    </section>
  );
}
