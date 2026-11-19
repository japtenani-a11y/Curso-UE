import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';
import { inicioDoPapel, useSessao } from '../lib/sessao.js';

// Meu perfil: escolher com qual perfil usar o aplicativo (ao entrar, quando ha mais de um, e depois, a qualquer
// momento) e, para o administrador, atribuir ou encerrar funcoes de outras pessoas.
export const NOME_PAPEL: Record<string, string> = {
  admin: 'Administrador', curador: 'Curador', docente: 'Preceptor', preceptor: 'Preceptor',
  pesquisador: 'Pesquisador', data_steward: 'Responsável pelos dados', aluno: 'Aluno',
};
const DESCRICAO: Record<string, string> = {
  admin: 'Telas da coordenação e as funções da equipe.',
  curador: 'Revisão e publicação do material, dúvidas, inscrições, mural e presença.',
  docente: 'Acompanhamento dos seus residentes, calendário e árvore de temas.',
  pesquisador: 'Dados e gráficos para pesquisa.',
  data_steward: 'Telas da coordenação, com a guarda dos dados pessoais (LGPD).',
  aluno: 'O aplicativo como o residente vê: temas, testes, estudo e desempenho.',
};
const ATRIBUIVEIS = ['curador', 'docente', 'pesquisador', 'data_steward', 'admin'];
interface Funcao { designacao_id: number; pessoa_id: number; nome: string; email: string; papel: string; desde: string; atribuido_por: string | null }
interface Pessoa { pessoa_id: number; nome: string; email: string; papeis: string[] }
const ERROS: Record<string, string> = {
  so_administrador: 'Só o administrador, usando o perfil de Administrador, pode mudar funções.',
  ultimo_administrador: 'Não é possível encerrar: o curso ficaria sem nenhum administrador.',
  papel_nao_atribuido: 'Você não tem essa função.',
  pessoa_nao_encontrada: 'Pessoa não encontrada. Ela precisa ter entrado no aplicativo ao menos uma vez.',
};
async function postar(caminho: string, corpo: unknown): Promise<string | null> {
  try { await apiPost(caminho, corpo); return null; } catch (e) { const m = String((e as Error).message); return m.includes('403') ? 'so_administrador' : m.includes('422') ? 'erro_regra' : 'sem_conexao'; }
}

export function Perfil(props: { escolha?: boolean }) {
  const { sessao } = useSessao();
  const [papeis, setPapeis] = useState<string[]>([]);
  const [escolhido, setEscolhido] = useState<string>('');
  const [msg, setMsg] = useState<string | null>(null);
  useEffect(() => {
    apiGet<{ papeis: string[]; ativo: string }>('/perfil/papeis').then((r) => { setPapeis(r.papeis); setEscolhido(r.ativo); }).catch(() => setMsg('Não foi possível carregar seus perfis.'));
  }, []);
  async function usar(p: string) {
    const e = await postar('/perfil/papel', { papel: p });
    if (e) { setMsg(ERROS[e] ?? 'Não foi possível trocar de perfil agora.'); return; }
    window.location.href = inicioDoPapel(p);
  }
  if (!sessao) return null;
  return (
    <section className="perfil-cut">
      <header>
        <span className="perfil-rot">{props.escolha ? 'Bem-vindo' : 'Meu perfil'}</span>
        <h1>{props.escolha ? `Com qual perfil você quer entrar, ${sessao.nome_completo.split(' ')[0]}?` : sessao.nome_completo}</h1>
        {!props.escolha && <p className="perfil-meta">{sessao.email_primario} · usando agora como <b>{NOME_PAPEL[sessao.papel] ?? sessao.papel}</b></p>}
        {props.escolha && <p className="perfil-meta">Você pode trocar depois, a qualquer momento, em Meu perfil (no seu nome, no alto da tela).</p>}
      </header>
      {msg && <p className="perfil-aviso" role="alert">{msg}</p>}
      {papeis.length > 1 && (
        <div className="perfil-bloco">
          {!props.escolha && <h2>Ver o aplicativo como</h2>}
          <div className="perfil-opcoes" role="radiogroup" aria-label="Perfil">
            {papeis.map((p) => (
              <button key={p} type="button" role="radio" aria-checked={escolhido === p} className="perfil-opcao" onClick={() => setEscolhido(p)}>
                <strong>{NOME_PAPEL[p] ?? p}{sessao.papel === p && !props.escolha ? ' · atual' : ''}</strong>
                <span>{DESCRICAO[p] ?? ''}</span>
                {p === 'aluno' && papeis.length > 1 && <small>Você responde os testes como qualquer aluno; sem ano de residência no cadastro, as questões são as de R+.</small>}
              </button>
            ))}
          </div>
          <button type="button" className="perfil-btn prim" disabled={!escolhido || (!props.escolha && escolhido === sessao.papel)} onClick={() => usar(escolhido)}>
            {props.escolha ? 'Entrar' : `Usar como ${NOME_PAPEL[escolhido] ?? ''}`}
          </button>
        </div>
      )}
      {papeis.length === 1 && !props.escolha && <p className="perfil-meta">Você tem um perfil só: {NOME_PAPEL[papeis[0]!] ?? papeis[0]}.</p>}
      {!props.escolha && sessao.papel === 'admin' && <FuncoesEquipe />}
    </section>
  );
}

function FuncoesEquipe() {
  const [funcoes, setFuncoes] = useState<Funcao[]>([]);
  const [q, setQ] = useState('');
  const [achados, setAchados] = useState<Pessoa[]>([]);
  const [pessoa, setPessoa] = useState<Pessoa | null>(null);
  const [papel, setPapel] = useState('curador');
  const [confirmar, setConfirmar] = useState<number | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => apiGet<{ funcoes: Funcao[] }>('/perfil/funcoes').then((r) => setFuncoes(r.funcoes)).catch(() => setMsg(ERROS.so_administrador!));
  useEffect(() => { void carregar(); }, []);
  useEffect(() => {
    if (q.trim().length < 2) { setAchados([]); return undefined; }
    const t = setTimeout(() => { apiGet<{ pessoas: Pessoa[] }>(`/perfil/pessoas?q=${encodeURIComponent(q.trim())}`).then((r) => setAchados(r.pessoas)).catch(() => setAchados([])); }, 250);
    return () => clearTimeout(t);
  }, [q]);
  async function atribuir() {
    if (!pessoa) return;
    const e = await postar('/perfil/funcoes', { pessoa_id: pessoa.pessoa_id, papel });
    setMsg(e ? (ERROS[e] ?? 'Não foi possível atribuir agora.') : `${NOME_PAPEL[papel]} atribuído a ${pessoa.nome}. Já vale: ela pode escolher esse perfil em Meu perfil.`);
    if (!e) { setPessoa(null); setQ(''); void carregar(); }
  }
  async function encerrar(id: number) {
    const e = await postar(`/perfil/funcoes/${id}/encerrar`, {});
    setConfirmar(null);
    setMsg(e ? (e === 'erro_regra' ? ERROS.ultimo_administrador! : ERROS[e] ?? 'Não foi possível encerrar agora.') : 'Função encerrada. Ela continua no histórico.');
    if (!e) void carregar();
  }
  const porPessoa = funcoes.reduce<Record<string, Funcao[]>>((a, f) => { (a[f.pessoa_id] ||= []).push(f); return a; }, {});
  return (
    <div className="perfil-bloco">
      <h2>Funções da equipe</h2>
      <p className="perfil-meta">Quem não tem função entra como aluno. A pessoa precisa ter entrado no aplicativo ao menos uma vez para aparecer na busca.</p>
      {msg && <p className="perfil-aviso" role="status">{msg}</p>}
      <div className="perfil-atribuir">
        <label className="perfil-campo">Pessoa (nome ou e-mail)
          <input type="search" value={pessoa ? `${pessoa.nome} · ${pessoa.email}` : q} onChange={(e) => { setPessoa(null); setQ(e.target.value); }} placeholder="Digite ao menos 2 letras" autoComplete="off" />
        </label>
        {!pessoa && achados.length > 0 && (
          <ul className="perfil-achados">
            {achados.map((p) => <li key={p.pessoa_id}><button type="button" onClick={() => { setPessoa(p); setAchados([]); }}>{p.nome} <small>{p.email} · {p.papeis.filter((x) => x !== 'aluno').map((x) => NOME_PAPEL[x]).join(', ') || 'aluno'}</small></button></li>)}
          </ul>
        )}
        <label className="perfil-campo">Função
          <select value={papel} onChange={(e) => setPapel(e.target.value)}>{ATRIBUIVEIS.map((p) => <option key={p} value={p}>{NOME_PAPEL[p]}</option>)}</select>
        </label>
        <button type="button" className="perfil-btn prim" disabled={!pessoa} onClick={atribuir}>Atribuir função</button>
      </div>
      <div className="perfil-lista">
        {Object.values(porPessoa).map((fs) => (
          <div key={fs[0]!.pessoa_id} className="perfil-pessoa">
            <div><strong>{fs[0]!.nome}</strong><span className="perfil-meta">{fs[0]!.email}</span></div>
            <div className="perfil-chips">
              {fs.map((f) => (
                <span key={f.designacao_id} className="perfil-chip" title={`Desde ${new Date(f.desde).toLocaleDateString('pt-BR')}${f.atribuido_por ? ` · por ${f.atribuido_por}` : ''}`}>
                  {NOME_PAPEL[f.papel] ?? f.papel}
                  {confirmar === f.designacao_id
                    ? <><button type="button" className="perfil-x conf" onClick={() => encerrar(f.designacao_id)}>Confirmar</button><button type="button" className="perfil-x" onClick={() => setConfirmar(null)}>Cancelar</button></>
                    : <button type="button" className="perfil-x" aria-label={`Encerrar ${NOME_PAPEL[f.papel]} de ${f.nome}`} onClick={() => setConfirmar(f.designacao_id)}>Encerrar</button>}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
