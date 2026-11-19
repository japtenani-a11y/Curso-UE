import { useState } from 'react';
import { apiPost } from '../lib/api.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const LOGIN_TESTE = import.meta.env.VITE_LOGIN_TESTE === '1';

const ERROS: Record<string, string> = {
  nao_cadastrado: 'As inscrições estão fechadas e este e-mail não está cadastrado. Fale com a coordenação do curso.',
  email_nao_verificado: 'O Google não confirmou este e-mail. Entre com uma conta Google de e-mail confirmado.',
  google_nao_configurado: 'O login com Google ainda não foi configurado neste computador. No teste local, use o campo abaixo.',
  state_invalido: 'A entrada pelo Google demorou demais ou foi aberta em outra aba. Toque de novo em "Entrar com o Google".',
  parametros_ausentes: 'A entrada pelo Google foi interrompida. Toque de novo em "Entrar com o Google".',
  id_token_ausente: 'O Google não devolveu a identificação da conta. Tente de novo ou entre pelo e-mail.',
};

export function Login() {
  const params = new URLSearchParams(window.location.search);
  const erroUrl = params.get('erro');
  const [email, setEmail] = useState('');
  const [emailLink, setEmailLink] = useState('');
  const [enviado, setEnviado] = useState<string | null>(null);
  const [linkTeste, setLinkTeste] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);
  const [erro, setErro] = useState<string | null>(erroUrl ? (ERROS[erroUrl] ?? 'Não foi possível entrar. Tente de novo.') : null);

  async function entrarTeste(e: React.FormEvent) {
    e.preventDefault();
    try { await apiPost('/auth/login', { email }); window.location.href = '/'; }
    catch { setErro('Falha no login de teste.'); }
  }

  async function pedirLink(e: React.FormEvent) {
    e.preventDefault();
    setErro(null); setEnviando(true);
    try {
      const r = await apiPost<{ ok: boolean; link_teste?: string }>('/auth/email/pedir', { email: emailLink });
      setEnviado(emailLink.trim()); setLinkTeste(r.link_teste ?? null);
    } catch {
      setErro('Não foi possível enviar o link agora. Confira o e-mail digitado e tente de novo em alguns minutos.');
    } finally { setEnviando(false); }
  }

  return (
    <div className="login">
      <div className="cartao-app">
        <img src="/cut_vertical_claro.svg" alt="" className="login-logo" />
        <h1 className="so-leitor">CUT · Curso de Cirurgia Geral, Urgência e Trauma</h1>
        <p style={{ color: 'var(--texto-2)', marginTop: 0 }}>HCFMRP-USP</p>
        <a className="botao google" href={`${BASE}/auth/google`}>
          <svg viewBox="0 0 48 48" aria-hidden="true"><path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.8 2.4 30.3 0 24 0 14.6 0 6.6 5.4 2.7 13.3l7.9 6.1C12.5 13.6 17.8 9.5 24 9.5z"/><path fill="#4285F4" d="M46.1 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.4c-.5 2.9-2.2 5.3-4.6 6.9l7.4 5.7c4.3-4 6.9-9.9 6.9-17.1z"/><path fill="#FBBC05" d="M10.6 28.6c-.5-1.4-.8-3-.8-4.6s.3-3.2.8-4.6l-7.9-6.1C1 16.6 0 20.2 0 24s1 7.4 2.7 10.7l7.9-6.1z"/><path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.4-5.7c-2.1 1.4-4.8 2.2-8.5 2.2-6.2 0-11.5-4.1-13.4-9.9l-7.9 6.1C6.6 42.6 14.6 48 24 48z"/></svg>
          Entrar com o Google
        </a>
        {erro && <p className="faixa-erro" role="alert">{erro}</p>}

        <div style={{ marginTop: 16, borderTop: '1px solid var(--borda)', paddingTop: 12, textAlign: 'left' }}>
          {enviado ? (
            <p role="status">
              Se <strong>{enviado}</strong> puder entrar no CUT, o link chega em alguns minutos. Ele vale por 20 minutos.
              Não chegou? Veja a caixa de spam ou <button type="button" className="botao-link" onClick={() => { setEnviado(null); setLinkTeste(null); }}>peça de novo</button>.
              {linkTeste && <><br /><a href={linkTeste}>Teste local: abrir o link</a></>}
            </p>
          ) : (
            <form onSubmit={pedirLink}>
              <label className="rotulo" htmlFor="email-link">Sem conta Google? Entre pelo e-mail</label>
              <input id="email-link" type="email" autoComplete="email" inputMode="email" required value={emailLink}
                     onChange={(e) => setEmailLink(e.target.value)} placeholder="seu@email.com" />
              <button type="submit" className="botao secundario" style={{ width: '100%' }} disabled={enviando}>
                {enviando ? 'Enviando…' : 'Receber o link de entrada'}
              </button>
            </form>
          )}
        </div>

        <p style={{ fontSize: '.8rem', color: 'var(--texto-2)' }}>Primeira vez? Entre com o Google ou com o seu e-mail para se inscrever, e a coordenação aprova a inscrição. O acesso é só seu: não o compartilhe.</p>
        <p style={{ fontSize: '.8rem' }}><a href="/sobre">O curso</a> · <a href="/privacidade">Política de privacidade</a> · <a href="/termos">Termos de uso</a></p>
        {LOGIN_TESTE && (
          <form onSubmit={entrarTeste} style={{ marginTop: 16, borderTop: '1px solid var(--borda)', paddingTop: 12 }}>
            <p className="rotulo">Teste local</p>
            <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="e-mail de teste" aria-label="E-mail de teste" />
            <button type="submit" className="botao secundario" style={{ width: '100%' }}>Entrar sem Google</button>
          </form>
        )}
      </div>
    </div>
  );
}
