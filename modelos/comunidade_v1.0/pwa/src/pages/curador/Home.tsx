import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Resumo { inscricoes_pendentes: number; alunos_ativos: number; duvidas_pendentes: number; rascunhos: number; publicados: number;
  questoes_alerta?: number; flashcards_novos?: number; respostas_mural?: number; sem_acesso_14d?: number;
  proximas_aulas: { codigo: string; titulo: string; data_hora: string }[] }
interface Producao { publicados: number; em_revisao: number; nao_iniciados: number; esperando: number;
  proximos: { codigo: string; titulo: string; status: string; papel: string; aula_em: string | null; interessados: number }[] | null }
const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });

// Inicio da coordenacao e dos revisores: o que precisa de atencao, proximas aulas e atalhos.
export function CuradorHome() {
  const [r, setR] = useState<Resumo | null>(null);
  const [meet, setMeet] = useState<string | null>(null);
  const [prod, setProd] = useState<Producao | null>(null);
  useEffect(() => {
    apiGet<Resumo>('/com/coordenacao/resumo').then(setR).catch(() => setR(null));
    apiGet<{ meet: string }>('/com/agenda/link').then((d) => setMeet(d.meet)).catch(() => undefined);
    apiGet<Producao>('/com/producao/resumo').then(setProd).catch(() => undefined);
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
          {cartao('Sem acesso', r.sem_acesso_14d ?? 0, '/painel', 'alunos sem entrar há 14 dias', (r.sem_acesso_14d ?? 0) > 0)}
          {cartao('Questões', r.questoes_alerta ?? 0, '/painel', 'com alerta na análise de itens', (r.questoes_alerta ?? 0) > 0)}
          {cartao('Flashcards dos alunos', r.flashcards_novos ?? 0, '/curador/flashcards', 'compartilhados nos últimos 7 dias')}
          {cartao('Mural', r.respostas_mural ?? 0, '/curador/mural', 'respostas a questionários em 7 dias')}
        </div>
        <div className="grade-inicio duas" style={{ marginTop: 16 }}>
          <article className="cartao-app">
            <span className="rotulo">Próximas aulas</span>
            {r.proximas_aulas.length === 0 ? <p>A agenda das aulas ainda não foi gravada no sistema (script 48, na abertura do curso).</p> : (
              <ul className="lista-temas">{r.proximas_aulas.map((a) => (
                <li key={a.codigo}><a href={`/curador/presenca/${a.codigo.replace('-', '')}`}><span className="cod">{quando(a.data_hora)}</span><span className="tit">{a.codigo} {a.titulo}</span><span className="selo nuclear">presença</span><span className="sit" /></a></li>))}</ul>
            )}
            {meet && <p><a className="botao" href={meet} target="_blank" rel="noopener noreferrer">Abrir a sala do Meet</a> <small>{meet}</small></p>}
          </article>
          {prod && (
            <article className="cartao-app">
              <span className="rotulo">Produção de temas</span>
              <h2 style={{ marginTop: 4 }}>{prod.publicados} de {prod.publicados + prod.em_revisao + prod.nao_iniciados} publicados</h2>
              <p><small>{prod.em_revisao} em revisão · {prod.nao_iniciados} não iniciados{prod.esperando ? ` · ${prod.esperando} pedidos de "Avise-me"` : ''}</small></p>
              <ol className="lista-curta">{(prod.proximos ?? []).map((p) => (
                <li key={p.codigo}><strong>{p.codigo}</strong> {p.titulo}<small> · {p.status === 'em_revisao' ? 'em revisão' : 'não iniciado'}{p.aula_em ? ` · aula ${new Date(p.aula_em).toLocaleDateString('pt-BR')}` : ''}{p.interessados ? ` · ${p.interessados} esperando` : ''}</small></li>))}</ol>
              <p><a href="/painel">Ver a fila completa (Dados → Fila de produção)</a></p>
            </article>
          )}
          <article className="cartao-app">
            <span className="rotulo">Atalhos</span>
            <ul className="lista-curta">
              <li><a href="/curador/mural">Publicar aviso, questionário ou documento</a></li>
              <li><a href="/curador/presenca">Código de presença e relatório do Meet</a></li>
              <li><a href="/curador/flashcards">Flashcards feitos pelos alunos</a></li>
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
