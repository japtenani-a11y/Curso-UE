import { Navigate } from 'react-router-dom';
import { inicioDoPapel, useSessao } from '../lib/sessao.js';

// "/" leva cada pessoa para a tela do seu papel (ou para o login).
export function Inicio() {
  const { sessao, carregando } = useSessao();
  if (carregando) return <p className="carregando">Carregando…</p>;
  if (!sessao) return <Navigate to="/login" replace />;
  const volta = new URLSearchParams(window.location.search).get('volta');
  return <Navigate to={volta && volta.startsWith('/') && !volta.startsWith('//') ? volta : inicioDoPapel(sessao.papel)} replace />;
}
