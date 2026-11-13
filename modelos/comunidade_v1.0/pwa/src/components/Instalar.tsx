import { useEffect, useState } from 'react';

interface EventoInstalar extends Event { prompt: () => Promise<void>; userChoice: Promise<{ outcome: string }> }

export function plataforma(): 'iphone' | 'android' | 'computador' {
  const ua = navigator.userAgent;
  if (/iPhone|iPad|iPod/i.test(ua) || (/Macintosh/.test(ua) && navigator.maxTouchPoints > 1)) return 'iphone';
  if (/Android/i.test(ua)) return 'android';
  return 'computador';
}
export function jaInstalado(): boolean {
  return window.matchMedia?.('(display-mode: standalone)').matches || (navigator as Navigator & { standalone?: boolean }).standalone === true;
}

// Botao "Instalar" quando o navegador oferece (Chrome/Edge no Android e no computador).
export function BotaoInstalar() {
  const [ev, setEv] = useState<EventoInstalar | null>(null);
  useEffect(() => {
    const h = (e: Event) => { e.preventDefault(); setEv(e as EventoInstalar); };
    window.addEventListener('beforeinstallprompt', h);
    return () => window.removeEventListener('beforeinstallprompt', h);
  }, []);
  if (!ev || jaInstalado()) return null;
  return <button type="button" className="botao" onClick={async () => { await ev.prompt(); setEv(null); }}>Instalar o aplicativo agora</button>;
}

export function PassosInstalar(props: { qual?: 'iphone' | 'android' | 'computador' }) {
  const [qual, setQual] = useState(props.qual ?? plataforma());
  if (jaInstalado()) return <p className="faixa-aviso">O aplicativo já está instalado neste aparelho. 👍</p>;
  return (
    <div className="instalar">
      <div className="etapas" role="tablist" aria-label="Aparelho">
        {([['android', 'Android'], ['iphone', 'iPhone / iPad'], ['computador', 'Computador']] as const).map(([k, r]) => (
          <button key={k} type="button" role="tab" aria-selected={qual === k} className={`etapa${qual === k ? ' atual' : ''}`} onClick={() => setQual(k)}>{r}</button>))}
      </div>
      {qual === 'android' && (
        <ol className="passos">
          <li>Abra este site no <strong>Google Chrome</strong> (o navegador com o ícone colorido redondo).</li>
          <li>Toque nos <strong>três pontinhos ⋮</strong> no canto de cima, à direita.</li>
          <li>Toque em <strong>“Instalar app”</strong> (em alguns celulares aparece “Adicionar à tela inicial”).</li>
          <li>Confirme em <strong>“Instalar”</strong>. Pronto: o ícone do curso aparece junto com os outros aplicativos.</li>
          <li>Na primeira vez que abrir pelo ícone, entre com a sua conta Google. Depois, ele lembra de você por 12 horas.</li>
        </ol>
      )}
      {qual === 'iphone' && (
        <ol className="passos">
          <li>Abra este site no <strong>Safari</strong> (a bússola azul). No iPhone, só o Safari instala aplicativos da internet.</li>
          <li>Toque no botão <strong>Compartilhar</strong>: o quadrado com uma seta para cima <span aria-hidden="true">⬆︎</span>, embaixo, no meio da tela.</li>
          <li>Role a lista para baixo e toque em <strong>“Adicionar à Tela de Início”</strong>.</li>
          <li>Toque em <strong>“Adicionar”</strong>, no canto de cima, à direita. O ícone do curso aparece na tela do iPhone.</li>
          <li>Abra pelo ícone e entre com a sua conta Google.</li>
        </ol>
      )}
      {qual === 'computador' && (
        <ol className="passos">
          <li>Abra o site no <strong>Chrome</strong> ou no <strong>Edge</strong>.</li>
          <li>Na barra de endereço, à direita, clique no ícone de <strong>instalar</strong> (um monitor com uma seta) ou no menu ⋮ → <strong>“Instalar Programa de Cirurgia…”</strong>.</li>
          <li>Confirme. O curso abre numa janela própria e ganha um atalho na área de trabalho.</li>
        </ol>
      )}
      <BotaoInstalar />
      <p><small>Instalar não ocupa quase nada de espaço e não pede acesso a fotos, contatos ou localização. O material continua só na internet (nada fica salvo no aparelho), então é preciso conexão para estudar.</small></p>
    </div>
  );
}
