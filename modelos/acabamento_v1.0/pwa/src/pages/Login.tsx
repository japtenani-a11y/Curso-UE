import { useState } from 'react';
import { apiPost } from '../lib/api.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
const LOGIN_TESTE = import.meta.env.VITE_LOGIN_TESTE === '1';

const ERROS: Record<string, string> = {
  nao_cadastrado: 'As inscrições estão fechadas no momento e este e-mail não está cadastrado. Fale com a coordenação.',
  email_nao_verificado: 'O Google não confirmou este e-mail.',
  google_nao_configurado: 'O login com Google ainda não foi configurado neste computador. Ele funciona no servidor de revisão (passo 8). No teste local, use o campo abaixo.',
};

export function Login() {
  const params = new URLSearchParams(window.location.search);
  const erroUrl = params.get('erro');
  const [email, setEmail] = useState('');
  const [erro, setErro] = useState<string | null>(erroUrl ? (ERROS[erroUrl] ?? 'Não foi possível entrar.') : null);

  async function entrarTeste(e: React.FormEvent) {
    e.preventDefault();
    try { await apiPost('/auth/login', { email }); window.location.href = '/'; }
    catch { setErro('Falha no login de teste.'); }
  }

  return (
    <div className="login">
      <div className="cartao-app">
        <img src="/icone.svg" alt="" />
        <h1>Cirurgia de Urgência e Trauma</h1>
        <p style={{ color: 'var(--texto-2)', marginTop: 0 }}>Programa de reuniões · HCFMRP-USP</p>
        <a className="botao google" href={`${BASE}/auth/google`}>
          <svg viewBox="0 0 48 48" aria-hidden="true"><path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.8 2.4 30.3 0 24 0 14.6 0 6.6 5.4 2.7 13.3l7.9 6.1C12.5 13.6 17.8 9.5 24 9.5z"/><path fill="#4285F4" d="M46.1 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.4c-.5 2.9-2.2 5.3-4.6 6.9l7.4 5.7c4.3-4 6.9-9.9 6.9-17.1z"/><path fill="#FBBC05" d="M10.6 28.6c-.5-1.4-.8-3-.8-4.6s.3-3.2.8-4.6l-7.9-6.1C1 16.6 0 20.2 0 24s1 7.4 2.7 10.7l7.9-6.1z"/><path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.4-5.7c-2.1 1.4-4.8 2.2-8.5 2.2-6.2 0-11.5-4.1-13.4-9.9l-7.9 6.1C6.6 42.6 14.6 48 24 48z"/></svg>
          Entrar com o Google
        </a>
        {erro && <p className="faixa-erro" role="alert">{erro}</p>}
        <p style={{ fontSize: '.8rem', color: 'var(--texto-2)' }}>Primeiro acesso? Entre com a sua conta Google para fazer a inscrição; a coordenação aprova o acesso. O acesso é pessoal e intransferível.</p>
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
