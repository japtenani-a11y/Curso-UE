import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { apiPost } from '../lib/api.js';
import { REVISORES, useSessao } from '../lib/sessao.js';
import { Protecao } from './Protecao.js';
import { GuardaCadastro } from './GuardaCadastro.js';
import { PrimeiroAcesso } from './PrimeiroAcesso.js';

interface Item { href: string; rotulo: string; icone: string; barra?: boolean; topo?: boolean }

// Menus por papel.
//  topo:  aparece direto no menu do computador (o resto fica em "Mais ▾", para o menu caber numa linha).
//  barra: aparece na barra inferior do celular (o resto fica em "Mais").
function itensDoPapel(papel: string): Item[] {
  if (REVISORES.includes(papel)) {
    return [
      { href: '/curador', rotulo: 'Início', icone: '⌂', barra: true, topo: true },
      { href: '/curador/revisao/T001', rotulo: 'Revisão', icone: '✎', barra: true, topo: true },
      { href: '/curador/duvidas', rotulo: 'Dúvidas', icone: '?', barra: true, topo: true },
      { href: '/curador/inscricoes', rotulo: 'Inscrições', icone: '✚', topo: true },
      { href: '/curador/mural', rotulo: 'Mural', icone: '✉', topo: true },
      { href: '/curador/presenca', rotulo: 'Presença', icone: '✓', topo: true },
      { href: '/painel', rotulo: 'Dados e gráficos', icone: '▤' },
      { href: '/curador/flashcards', rotulo: 'Flashcards dos alunos', icone: '✦' },
      { href: '/curador/pesquisa', rotulo: 'Interesse em pesquisa', icone: '⚗' },
      { href: '/curador/previa/T001', rotulo: 'Prévia do aluno', icone: '◎' },
      { href: '/aluno/arvore', rotulo: 'Árvore de temas', icone: '⋔' },
      { href: '/ajuda', rotulo: 'Ajuda', icone: 'ℹ' },
    ];
  }
  if (papel === 'pesquisador') {
    return [{ href: '/painel', rotulo: 'Dados e gráficos', icone: '▤', barra: true, topo: true },
      { href: '/pesquisa', rotulo: 'Pesquisa', icone: '⌕', barra: true, topo: true },
      { href: '/ajuda', rotulo: 'Ajuda', icone: 'ℹ', barra: true, topo: true }];
  }
  if (papel === 'preceptor' || papel === 'docente') {
    return [{ href: '/preceptor', rotulo: 'Meus residentes', icone: '⌂', barra: true, topo: true },
      { href: '/aluno/calendario', rotulo: 'Calendário', icone: '▦', barra: true, topo: true },
      { href: '/aluno/arvore', rotulo: 'Árvore de temas', icone: '⋔', barra: true, topo: true },
      { href: '/aluno/mural', rotulo: 'Mural', icone: '✉', topo: true },
      { href: '/ajuda', rotulo: 'Ajuda', icone: 'ℹ', topo: true }];
  }
  return [
    { href: '/aluno', rotulo: 'Início', icone: '⌂', barra: true, topo: true },
    { href: '/aluno/pendencias', rotulo: 'Pendências', icone: '!', barra: true, topo: true },
    { href: '/aluno/calendario', rotulo: 'Calendário', icone: '▦', barra: true, topo: true },
    { href: '/aluno/temas', rotulo: 'Temas', icone: '☰', topo: true },
    { href: '/aluno/estudo', rotulo: 'Estudo dirigido', icone: '✦', topo: true },
    { href: '/aluno/desempenho', rotulo: 'Desempenho', icone: '↗', topo: true },
    { href: '/aluno/arvore', rotulo: 'Árvore de temas', icone: '⋔' },
    { href: '/aluno/mural', rotulo: 'Mural', icone: '✉' },
    { href: '/aluno/aproveitamento', rotulo: 'Presença e certificado', icone: '✓' },
    { href: '/aluno/duvidas', rotulo: 'Dúvidas', icone: '?' },
    { href: '/cadastro', rotulo: 'Meus dados', icone: '☺' },
    { href: '/aluno/contato', rotulo: 'Lembretes por e-mail', icone: '⏰' },
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
  const [maisTopo, setMaisTopo] = useState(false);
  const [letra, trocarLetra] = useTamanhoLetra();
  useEffect(() => { setMais(false); setMaisTopo(false); }, [local.pathname]);
  useEffect(() => {
    if (!maisTopo && !mais) return undefined;
    const fechar = (e: KeyboardEvent) => { if (e.key === 'Escape') { setMaisTopo(false); setMais(false); } };
    const fora = (e: MouseEvent) => { if (!(e.target as HTMLElement).closest('.mais-topo, .folha-mais, .barra-inferior')) { setMaisTopo(false); setMais(false); } };
    window.addEventListener('keydown', fechar); window.addEventListener('mousedown', fora);
    return () => { window.removeEventListener('keydown', fechar); window.removeEventListener('mousedown', fora); };
  }, [maisTopo, mais]);
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
            {itens.filter((i) => i.topo).map((i) => <a key={i.href} href={i.href} className={ativo(i.href) ? 'ativo' : ''} aria-current={ativo(i.href) ? 'page' : undefined}>{i.rotulo}</a>)}
            {itens.some((i) => !i.topo) && (
              <div className="mais-topo">
                <button type="button" className={itens.some((i) => !i.topo && ativo(i.href)) ? 'ativo' : ''} aria-expanded={maisTopo} aria-haspopup="true" onClick={() => setMaisTopo(!maisTopo)}>Mais ▾</button>
                {maisTopo && (
                  <div className="menu-mais" role="menu">
                    {itens.filter((i) => !i.topo).map((i) => <a key={i.href} role="menuitem" href={i.href} className={ativo(i.href) ? 'ativo' : ''}><span aria-hidden="true">{i.icone}</span>{i.rotulo}</a>)}
                  </div>
                )}
              </div>
            )}
          </nav>
          <div className="usuario">
            <button type="button" className="botao discreto letra" onClick={trocarLetra} aria-label={`Tamanho da letra: ${['normal', 'grande', 'maior'][letra]}. Clique para mudar.`} title="Tamanho da letra">A{letra ? '+'.repeat(letra) : ''}</button>
            <span>{sessao.nome_completo.split(' ')[0]}</span>
            <button type="button" className="botao discreto sair-topo" onClick={sair}>Sair</button>
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
