import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

interface Inscricao {
  pessoa_id: number; nome: string; email: string; data_nascimento: string | null; grau: string; especialidade_rotulo: string | null;
  decidido_por_nome: string | null; termos: Record<string, boolean>;
  ficha: { status: string; celular: string | null; situacao: string | null; semestre: number | null; ano_formatura: number | null; faculdade: string | null;
    instituicao_residencia: string | null; ano_ingresso_residencia: number | null; termino_previsto: string | null; enviado_em: string | null;
    decidido_em: string | null; motivo_status: string | null };
}
const FILTROS: [string, string][] = [['pendente', 'Aguardando'], ['aprovado', 'Aprovadas'], ['recusado', 'Recusadas'], ['todas', 'Todas']];
// Datas sem hora (AAAA-MM-DD) sao lidas como data local, para nao voltar um dia pelo fuso.
const data = (s: string) => (/^\d{4}-\d{2}-\d{2}$/.test(s) ? new Date(`${s}T12:00:00`) : new Date(s));
const dia = (s: string | null) => (s ? data(s).toLocaleDateString('pt-BR') : '—');
const idade = (s: string | null) => (s ? Math.floor((Date.now() - data(s).getTime()) / 31_557_600_000) : null);
const TERMOS: [string, string][] = [['uso', 'Uso e segurança'], ['privacidade', 'Privacidade'], ['pesquisa', 'Pesquisa (TCLE)'], ['divulgacao', 'Divulgação']];
const fone = (v: string | null) => { const m = /^\+55(\d{2})(\d{4,5})(\d{4})$/.exec(v ?? ''); return m ? `(${m[1]}) ${m[2]}-${m[3]}` : (v ?? '—'); };
const SIT: Record<string, string> = { graduacao: 'Graduação', residencia: 'Residência', formado: 'Médico formado' };

// Inscricoes dos alunos: aprovar ou recusar (o aluno recebe e-mail).
export function CuradorInscricoes() {
  const [filtro, setFiltro] = useState('pendente');
  const [lista, setLista] = useState<Inscricao[] | null>(null);
  const [motivo, setMotivo] = useState<Record<number, string>>({});
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => apiGet<{ inscricoes: Inscricao[] }>(`/inscricoes?status=${filtro}`).then((d) => setLista(d.inscricoes)).catch(() => setLista([]));
  useEffect(() => { setLista(null); carregar(); }, [filtro]);

  async function decidir(i: Inscricao, aprovar: boolean) {
    if (!aprovar && !(motivo[i.pessoa_id] ?? '').trim()) { setMsg('Escreva o motivo da recusa (o aluno recebe por e-mail).'); return; }
    try { await apiPost(`/inscricoes/${i.pessoa_id}/decisao`, { aprovar, motivo: motivo[i.pessoa_id] ?? '' }); setMsg(`${i.nome}: inscrição ${aprovar ? 'aprovada' : 'recusada'}.`); carregar(); }
    catch { setMsg('Não foi possível registrar a decisão.'); }
  }

  return (
    <section>
      <h1>Inscrições</h1>
      <p>Cada inscrição nova chega por e-mail para os curadores. A aprovação libera o curso; o ano de residência, a especialidade e a turma passam a valer para testes, ranking e painel.</p>
      <div className="etapas" role="tablist">{FILTROS.map(([k, r]) => <button key={k} type="button" className={`etapa${filtro === k ? ' atual' : ''}`} onClick={() => setFiltro(k)}>{r}</button>)}</div>
      {msg && <p className="faixa-aviso" role="status">{msg}</p>}
      {!lista ? <p className="carregando">Carregando…</p> : lista.length === 0 ? <p>Nenhuma inscrição aqui.</p> : lista.map((i) => (
        <article key={i.pessoa_id} className="cartao-app" style={{ margin: '12px 0' }}>
          <span className="rotulo">{i.ficha.status} · enviada em {dia(i.ficha.enviado_em)}{i.decidido_por_nome ? ` · decidida por ${i.decidido_por_nome} em ${dia(i.ficha.decidido_em)}` : ''}</span>
          <h2 style={{ margin: '4px 0' }}>{i.nome}</h2>
          <dl className="ficha-resumo">
            <dt>E-mail</dt><dd>{i.email}</dd>
            <dt>Celular</dt><dd>{fone(i.ficha.celular)}</dd>
            <dt>Nascimento</dt><dd>{dia(i.data_nascimento)}{idade(i.data_nascimento) !== null ? ` (${idade(i.data_nascimento)} anos)` : ''}</dd>
            <dt>Situação</dt><dd>{SIT[i.ficha.situacao ?? ''] ?? '—'}{i.ficha.semestre ? ` · ${i.ficha.semestre}º semestre` : ''}{i.ficha.ano_formatura ? ` · formado em ${i.ficha.ano_formatura}` : ''}</dd>
            <dt>Faculdade</dt><dd>{i.ficha.faculdade ?? '—'}</dd>
            {i.ficha.situacao !== 'graduacao' && <><dt>Especialidade</dt><dd>{i.especialidade_rotulo ?? '—'}</dd></>}
            {i.ficha.situacao === 'residencia' && <><dt>Residência</dt><dd>{i.ficha.instituicao_residencia ?? '—'} · ingresso {i.ficha.ano_ingresso_residencia} · término {dia(i.ficha.termino_previsto)} · <strong>{i.grau}</strong></dd></>}
            <dt>Termos</dt><dd>{TERMOS.map(([k, r]) => `${r}: ${i.termos?.[k] ? 'sim' : 'não'}`).join(' · ')}</dd>
            {i.ficha.motivo_status && <><dt>Motivo</dt><dd>{i.ficha.motivo_status}</dd></>}
          </dl>
          {i.ficha.status !== 'rascunho' && (
            <div className="decisao">
              <input className="busca" placeholder="Motivo (obrigatório para recusar)" value={motivo[i.pessoa_id] ?? ''} onChange={(e) => setMotivo({ ...motivo, [i.pessoa_id]: e.target.value })} />
              {i.ficha.status !== 'aprovado' && <button type="button" className="botao" onClick={() => decidir(i, true)}>Aprovar</button>}
              {i.ficha.status !== 'recusado' && <button type="button" className="botao discreto" onClick={() => decidir(i, false)}>{i.ficha.status === 'aprovado' ? 'Suspender acesso' : 'Recusar'}</button>}
            </div>
          )}
        </article>
      ))}
    </section>
  );
}
