import { useEffect, useState } from 'react';
import { apiGet } from '../lib/api.js';
import { Markdown } from '../lib/md.js';

interface Termo { codigo: string; versao: string; titulo: string; resumo: string; texto: string; obrigatorio: boolean; desde: string }

function Casca(props: { children: React.ReactNode }) {
  return (
    <div className="publico">
      <header className="topo"><div className="topo-interno">
        <a className="marca" href="/sobre"><img src="/icone.svg" alt="" /><span>Cirurgia de Urgência e Trauma<small>HCFMRP-USP · Programa de reuniões</small></span></a>
        <nav className="nav" aria-label="Páginas públicas">
          <a href="/sobre">O programa</a><a href="/privacidade">Privacidade</a><a href="/termos">Termos de uso</a><a href="/login">Entrar</a>
        </nav>
      </div></header>
      <main className="conteudo publico-conteudo">{props.children}</main>
      <footer className="rodape">Programa de Cirurgia de Urgência e Trauma · <a href="/privacidade">Política de privacidade</a> · <a href="/termos">Termos de uso</a> · <a href="/pesquisa-tcle">TCLE da pesquisa</a></footer>
    </div>
  );
}

// Pagina inicial publica (usada tambem como "pagina inicial do aplicativo" no Google).
export function PaginaInicial() {
  return (
    <Casca>
      <section className="capa">
        <h1>Programa de Cirurgia de Urgência e Trauma</h1>
        <p className="capa-sub">Programa educacional para residentes e estudantes de medicina: reuniões semanais às quintas, 20h, pelo Google Meet, com material de estudo, casos e testes antes e depois de cada aula.</p>
        <p><a className="botao" href="/login">Entrar ou fazer inscrição com o Google</a></p>
      </section>
      <div className="cartoes">
        <article className="cartao-app"><h3>Como funciona</h3>
          <p>Cada tema abre 15 dias antes da aula com um pré-teste. Depois vêm o material pré-aula, a aula com caso clínico e os pós-testes em D0, D+15, D+45 e D+90, sempre com gabarito comentado.</p></article>
        <article className="cartao-app"><h3>Quem pode participar</h3>
          <p>Residentes de cirurgia geral, cirurgia de urgência e trauma, medicina de emergência e outras especialidades cirúrgicas, e estudantes do 7º ao 12º semestre. A inscrição é feita com a conta Google e aprovada pela coordenação.</p></article>
        <article className="cartao-app"><h3>Conteúdo e dados</h3>
          <p>O conteúdo é revisado por cirurgiões e de uso exclusivo dos participantes. Os dados são tratados conforme a LGPD; a participação em pesquisa é opcional. Veja a <a href="/privacidade">política de privacidade</a> e os <a href="/termos">termos de uso</a>.</p></article>
      </div>
    </Casca>
  );
}

// Pagina publica de um termo vigente: privacidade, termos de uso ou TCLE.
export function PaginaTermo(props: { codigo: 'privacidade' | 'uso' | 'pesquisa' | 'divulgacao' }) {
  const [t, setT] = useState<Termo | null | undefined>(undefined);
  useEffect(() => { apiGet<{ termos: Termo[] }>('/publico/termos').then((d) => setT(d.termos.find((x) => x.codigo === props.codigo) ?? null)).catch(() => setT(null)); }, [props.codigo]);
  return (
    <Casca>
      {t === undefined ? <p className="carregando">Carregando…</p> : t === null ? <p>Texto indisponível no momento.</p> : (
        <article className="cartao-app termo-publico">
          <h1 style={{ marginTop: 0 }}>{t.titulo}</h1>
          <p className="migalha">Versão {t.versao} · em vigor desde {new Date(t.desde).toLocaleDateString('pt-BR')}</p>
          <Markdown texto={t.texto} />
        </article>
      )}
    </Casca>
  );
}
