import type { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { apiPost } from '../lib/api.js';
import { REVISORES, useSessao } from '../lib/sessao.js';
import { Protecao } from './Protecao.js';

interface Item { href: string; rotulo: string }

function itensDoPapel(papel: string): Item[] {
  if (REVISORES.includes(papel)) {
    return [
      { href: '/curador/revisao/T001', rotulo: 'Revisão' },
      { href: '/curador/previa/T001', rotulo: 'Prévia do aluno' },
      { href: '/curador', rotulo: 'Painel' },
    ];
  }
  if (papel === 'pesquisador') return [{ href: '/pesquisa', rotulo: 'Pesquisa' }];
  if (papel === 'preceptor' || papel === 'docente') return [{ href: '/preceptor', rotulo: 'Meus alunos' }];
  return [
    { href: '/aluno', rotulo: 'Início' },
    { href: '/aluno/leitura/T001', rotulo: 'Material' },
    { href: '/aluno/testes/T001', rotulo: 'Testes' },
    { href: '/aluno/contato', rotulo: 'Lembretes' },
  ];
}

// Casca de todas as telas logadas: topo com navegacao do papel, exige sessao e, se pedido, papel.
export function Layout(props: { children: ReactNode; papeis?: string[]; proteger?: boolean }) {
  const { sessao, carregando } = useSessao();
  const local = useLocation();
  if (carregando) return <p className="carregando">Carregando…</p>;
  if (!sessao) return <Navigate to={`/login?volta=${encodeURIComponent(local.pathname)}`} replace />;
  if (props.papeis && !props.papeis.includes(sessao.papel)) return <Navigate to="/" replace />;

  async function sair() {
    try { await apiPost('/auth/logout', {}); } catch { /* segue */ }
    window.location.href = '/login';
  }
  const itens = itensDoPapel(sessao.papel);
  const miolo = props.proteger === false ? props.children : <Protecao>{props.children}</Protecao>;
  return (
    <>
      <header className="topo">
        <div className="topo-interno">
          <a className="marca" href="/"><img src="/icone.svg" alt="" /><span>Cirurgia de Urgência e Trauma<small>HCFMRP-USP · Programa de reuniões</small></span></a>
          <nav className="nav" aria-label="Principal">
            {itens.map((i) => (
              <a key={i.href} href={i.href} className={local.pathname === i.href || (i.href !== '/aluno' && i.href !== '/curador' && local.pathname.startsWith(i.href)) ? 'ativo' : ''}>{i.rotulo}</a>
            ))}
          </nav>
          <div className="usuario"><span>{sessao.nome_completo.split(' ')[0]}</span><button type="button" className="botao discreto" onClick={sair}>Sair</button></div>
        </div>
      </header>
      <main className="conteudo">{miolo}</main>
      <footer className="rodape">Material de uso exclusivo dos participantes do programa. Cada acesso é registrado e a tela leva a identificação de quem a abriu.</footer>
    </>
  );
}
