import { useState } from 'react';
import { apiPost } from '../lib/api.js';

// Tela aberta pelo link enviado ao e-mail. O link so vale depois do toque em "Entrar": o leitor de links do
// e-mail abre o endereco para conferir e, sem o toque, nao gasta o link.
export function Entrar() {
  const token = new URLSearchParams(window.location.search).get('t') ?? '';
  const [estado, setEstado] = useState<'pronto' | 'entrando' | 'erro'>(/^[0-9a-f]{64}$/.test(token) ? 'pronto' : 'erro');

  async function entrar() {
    setEstado('entrando');
    try { await apiPost('/auth/email/entrar', { token }); window.location.href = '/'; }
    catch { setEstado('erro'); }
  }

  return (
    <div className="login">
      <div className="cartao-app">
        <img src="/cut_vertical_claro.svg" alt="" className="login-logo" />
        <h1 className="so-leitor">CUT · Curso de Cirurgia Geral, Urgência e Trauma</h1>
        {estado === 'erro' ? (<>
          <p className="faixa-erro" role="alert">Este link venceu ou já foi usado. Peça um novo na tela de entrada.</p>
          <a className="botao" href="/login">Voltar para a entrada</a>
        </>) : (<>
          <p>Toque em "Entrar" para abrir o CUT neste aparelho.</p>
          <button type="button" className="botao" style={{ width: '100%' }} onClick={entrar} disabled={estado === 'entrando'}>
            {estado === 'entrando' ? 'Entrando…' : 'Entrar'}
          </button>
        </>)}
      </div>
    </div>
  );
}
