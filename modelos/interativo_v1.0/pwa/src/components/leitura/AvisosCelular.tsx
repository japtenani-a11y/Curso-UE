import { useEffect, useState } from 'react';

// Avisos no celular (web push). O aparelho recebe so um sinal; ao receber, o aplicativo busca o texto do aviso
// no servidor. Assim o conteudo nao passa pelo servico de push. No iPhone, so funciona com o aplicativo instalado
// na tela de inicio (iOS 16.4 ou mais novo).
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const DISPENSA = 'cut_push_dispensado';

function chaveBytes(b64: string): ArrayBuffer {
  const pad = '='.repeat((4 - (b64.length % 4)) % 4);
  const s = atob((b64 + pad).replace(/-/g, '+').replace(/_/g, '/'));
  const buf = new ArrayBuffer(s.length); const v = new Uint8Array(buf);
  for (let i = 0; i < s.length; i++) v[i] = s.charCodeAt(i);
  return buf;
}
function suportado(): boolean {
  return typeof window !== 'undefined' && 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window;
}

export function AvisosCelular(props: { compacto?: boolean }) {
  const [estado, setEstado] = useState<'carregando' | 'ativo' | 'inativo' | 'negado' | 'sem_suporte' | 'sem_chave' | 'dispensado' | 'sem_sw'>('carregando');
  const [msg, setMsg] = useState<string | null>(null);

  useEffect(() => {
    if (!suportado()) { setEstado('sem_suporte'); return; }
    if (Notification.permission === 'denied') { setEstado('negado'); return; }
    void (async () => {
      const reg = await navigator.serviceWorker.getRegistration();
      if (!reg) { setEstado('sem_sw'); return; }
      const sub = await reg.pushManager.getSubscription();
      let disp = false; try { disp = localStorage.getItem(DISPENSA) === '1'; } catch { /* sem armazenamento */ }
      setEstado(sub ? 'ativo' : props.compacto && disp ? 'dispensado' : 'inativo');
    })().catch(() => setEstado('inativo'));
  }, [props.compacto]);

  async function ativar() {
    setMsg(null);
    try {
      const k = await fetch(`${API_BASE}/push/chave`, { credentials: 'include' }).then((r) => (r.ok ? r.json() : null)) as { chave?: string } | null;
      if (!k?.chave) { setEstado('sem_chave'); return; }
      if (await Notification.requestPermission() !== 'granted') { setEstado('negado'); return; }
      const reg = await navigator.serviceWorker.ready;
      // o aplicativo guarda o endereco da API para o service worker buscar o texto dos avisos
      try { const c = await caches.open('cut-config'); await c.put('/__api', new Response(API_BASE)); } catch { /* sem cache */ }
      const s = await reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: chaveBytes(k.chave) });
      const r = await fetch(`${API_BASE}/push/inscrever`, {
        method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ endpoint: s.endpoint, aparelho: navigator.userAgent.slice(0, 200) }),
      });
      if (!r.ok) throw new Error(String(r.status));
      setEstado('ativo');
    } catch { setMsg('Não foi possível ativar agora. Tente de novo; no iPhone, instale o aplicativo na tela de início antes.'); }
  }
  async function desativar() {
    const reg = await navigator.serviceWorker.ready; const s = await reg.pushManager.getSubscription();
    if (s) {
      await fetch(`${API_BASE}/push/cancelar`, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ endpoint: s.endpoint }) }).catch(() => undefined);
      await s.unsubscribe().catch(() => undefined);
    }
    setEstado('inativo');
  }

  if (props.compacto) {
    if (estado !== 'inativo') return null;
    return (
      <div className="int-push-convite">
        <span>Receba no celular o aviso de quando um tema abre e de quando um prazo vai fechar.</span>
        <button type="button" className="int-btn prim" onClick={ativar}>Ativar avisos</button>
        <button type="button" className="int-btn" onClick={() => { try { localStorage.setItem(DISPENSA, '1'); } catch { /* */ } setEstado('dispensado'); }}>Agora não</button>
        {msg && <small role="alert">{msg}</small>}
      </div>
    );
  }
  return (
    <section className="cartao-app int-push">
      <h2>Avisos no celular</h2>
      {estado === 'carregando' && <p>Verificando…</p>}
      {estado === 'sem_suporte' && <p>Este navegador não recebe avisos. No iPhone, instale o aplicativo na tela de início (veja Ajuda › Instalar) e abra por ele.</p>}
      {estado === 'negado' && <p>Os avisos estão bloqueados para este site. Libere nas configurações do navegador (permissões do site › notificações) e volte aqui.</p>}
      {estado === 'sem_sw' && <p>Os avisos funcionam no aplicativo publicado (com endereço https), não no modo de teste do computador.</p>}
      {estado === 'sem_chave' && <p>Os avisos no celular ainda não foram ligados pela coordenação.</p>}
      {(estado === 'inativo' || estado === 'dispensado') && <><p>Receba neste aparelho o aviso de quando um tema abre e de quando um prazo vai fechar. O texto do aviso só aparece no seu aparelho.</p>
        <button type="button" className="botao" onClick={ativar}>Ativar avisos neste aparelho</button></>}
      {estado === 'ativo' && <><p>Avisos ligados neste aparelho.</p><button type="button" className="botao discreto" onClick={desativar}>Desligar neste aparelho</button></>}
      {msg && <p role="alert">{msg}</p>}
    </section>
  );
}
