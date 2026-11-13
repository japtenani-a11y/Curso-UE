import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { apiPost } from '../lib/api.js';
import { REVISORES, useSessao } from '../lib/sessao.js';
import { Protecao } from './Protecao.js';
import { GuardaCadastro } from './GuardaCadastro.js';
import { PrimeiroAcesso } from './PrimeiroAcesso.js';

interface Item { href: string; rotulo: string; icone: string; barra?: boolean }

// Menus por papel. "barra": aparece na barra inferior do celular (as demais ficam em "Mais").
function itensDoPapel(papel: string): Item[] {
  if (REVISORES.includes(papel)) {
    return [
      { href: '/curador', rotulo: 'Início', icone: '⌂', barra: true },
      { href: '/curador/revisao/T001', rotulo: 'Revisão', icone: '✎', barra: true },
      { href: '/curador/duvidas', rotulo: 'Dúvidas', icone: '?', barra: true },
      { href: '/curador/inscricoes', rotulo: 'Inscrições', icone: '✚' },
      { href: '/curador/mural', rotulo: 'Mural', icone: '✉' },
      { href: '/curador/presenca', rotulo: 'Presença', icone: '✓' },
      { href: '/painel', rotulo: 'Dados', icone: '▤' },
      { href: '/curador/previa/T001', rotulo: 'Prévia', icone: '◎' },
      { href: '/ajuda', rotulo: 'Ajuda', icone: 'ℹ' },
    ];
  }
  if (papel === 'pesquisador') return [{ href: '/painel', rotulo: 'Dados e gráficos', icone: '▤', barra: true }, { href: '/pesquisa', rotulo: 'Pesquisa', icone: '⌕', barra: true }];
  if (papel === 'preceptor' || papel === 'docente') {
    return [{ href: '/preceptor', rotulo: 'Meus residentes', icone: '⌂', barra: true }, { href: '/aluno/calendario', rotulo: 'Calendário', icone: '▦', barra: true },
      { href: '/aluno/arvore', rotulo: 'Árvore de temas', icone: '⋔', barra: true }, { href: '/ajuda', rotulo: 'Ajuda', icone: 'ℹ' }];
  }
  return [
    { href: '/aluno', rotulo: 'Início', icone: '⌂', barra: true },
    { href: '/aluno/pendencias', rotulo: 'Pendências', icone: '!', barra: true },
    { href: '/aluno/calendario', rotulo: 'Calendário', icone: '▦', barra: true },
    { href: '/aluno/temas', rotulo: 'Temas', icone: '☰' },
    { href: '/aluno/arvore', rotulo: 'Árvore', icone: '⋔' },
    { href: '/aluno/mural', rotulo: 'Mural', icone: '✉' },
    { href: '/aluno/desempenho', rotulo: 'Desempenho', icone: '↗' },
    { href: '/aluno/aproveitamento', rotulo: 'Presença e certificado', icone: '✓' },
    { href: '/aluno/duvidas', rotulo: 'Dúvidas', icone: '?' },
    { href: '/cadastro', rotulo: 'Meus dados', icone: '☺' },
    { href: '/ajuda', rotulo: 'Ajuda', icone: 'ℹ' },
  ];
}

const TAMANHOS = [16, 18, 20];
function useTamanhoLetra(): [number, () => void] {
  const [i, setI] = useState(() => { try { return Number(localStorage.getItem('letra') ?? 0) || 0; } catch { return 0; } });
  useEffect(() => {
    document.documentElement.style.fontSize = `${TAMANHOS[i % TAMANHOS.length]}px`;
    try { localStorage.setItem('letra', String(i % TAMANHOS.length)); } catch { /* sem armazenamento */ }
  }, [i]);
  return [i % TAMANHOS.length, () => setI((x) => (x + 1) % TAMANHOS.length)];
}

// Casca de todas as telas logadas: topo, barra inferior no celular, acessibilidade, primeiro acesso e guarda do cadastro.
export function Layout(props: { children: ReactNode; papeis?: string[]; proteger?: boolean; semGuarda?: boolean }) {
  const { sessao, carregando } = useSessao();
  const local = useLocation();
  const [mais, setMais] = useState(false);
  const [letra, trocarLetra] = useTamanhoLetra();
  useEffect(() => setMais(false), [local.pathname]);
  if (carregando) return <p className="carregando">Carregando…</p>;
  if (!sessao) return <Navigate to={`/login?volta=${encodeURIComponent(local.pathname)}`} replace />;
  if (props.papeis && !props.papeis.includes(sessao.papel)) return <Navigate to="/" replace />;

  async function sair() {
    try { await apiPost('/auth/logout', {}); } catch { /* segue */ }
    window.location.href = '/login';
  }
  const itens = itensDoPapel(sessao.papel);
  const ativo = (h: string) => local.pathname === h || (!['/aluno', '/curador', '/preceptor'].includes(h) && local.pathname.startsWith(h));
  const aluno = sessao.papel === 'aluno';
  const miolo = props.proteger === false ? props.children : <Protecao>{props.children}</Protecao>;
  return (
    <>
      <a className="pular" href="#conteudo">Pular para o conteúdo</a>
      <header className="topo">
        <div className="topo-interno">
          <a className="marca" href="/"><img src="/icone.svg" alt="" /><span>Cirurgia de Urgência e Trauma<small>HCFMRP-USP · Programa de reuniões</small></span></a>
          <nav className="nav" aria-label="Principal">
            {itens.map((i) => <a key={i.href} href={i.href} className={ativo(i.href) ? 'ativo' : ''} aria-current={ativo(i.href) ? 'page' : undefined}>{i.rotulo}</a>)}
          </nav>
          <div className="usuario">
            <button type="button" className="botao discreto letra" onClick={trocarLetra} aria-label={`Tamanho da letra: ${['normal', 'grande', 'maior'][letra]}. Clique para mudar.`} title="Tamanho da letra">A{letra ? '+'.repeat(letra) : ''}</button>
            <span>{sessao.nome_completo.split(' ')[0]}</span>
            <button type="button" className="botao discreto" onClick={sair}>Sair</button>
          </div>
        </div>
      </header>
      <main className="conteudo" id="conteudo" tabIndex={-1}>
        <GuardaCadastro ativo={aluno && !props.semGuarda}>{miolo}{aluno && !props.semGuarda && <PrimeiroAcesso />}</GuardaCadastro>
      </main>
      <footer className="rodape">Material de uso exclusivo dos participantes do programa. Cada acesso é registrado e a tela leva a identificação de quem a abriu. · <a href="/privacidade">Privacidade</a> · <a href="/termos">Termos de uso</a></footer>
      <nav className="barra-inferior" aria-label="Atalhos">
        {itens.filter((i) => i.barra).map((i) => (
          <a key={i.href} href={i.href} className={ativo(i.href) ? 'ativo' : ''} aria-current={ativo(i.href) ? 'page' : undefined}><span aria-hidden="true">{i.icone}</span>{i.rotulo}</a>
        ))}
        {itens.some((i) => !i.barra) && <button type="button" aria-expanded={mais} onClick={() => setMais(!mais)}><span aria-hidden="true">⋯</span>Mais</button>}
      </nav>
      {mais && (
        <div className="folha-mais" role="dialog" aria-label="Mais opções">
          {itens.filter((i) => !i.barra).map((i) => <a key={i.href} href={i.href} className={ativo(i.href) ? 'ativo' : ''}><span aria-hidden="true">{i.icone}</span>{i.rotulo}</a>)}
          <button type="button" className="botao discreto" onClick={sair}>Sair</button>
        </div>
      )}
    </>
  );
}
