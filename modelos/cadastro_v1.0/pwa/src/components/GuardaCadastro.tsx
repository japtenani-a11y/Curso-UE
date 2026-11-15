import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { apiGet } from '../lib/api.js';

// Aluno sem inscricao aprovada (ou com termo obrigatorio pendente) vai para a ficha de inscricao.
export function GuardaCadastro(props: { ativo: boolean; children: ReactNode }) {
  const [ok, setOk] = useState<boolean | null>(props.ativo ? null : true);
  useEffect(() => {
    if (!props.ativo) return;
    apiGet<{ ok: boolean }>('/cadastro/situacao').then((s) => setOk(s.ok)).catch(() => setOk(false));
  }, [props.ativo]);
  if (!props.ativo) return <>{props.children}</>;
  if (ok === null) return <p className="carregando">Carregando…</p>;
  if (!ok) return <Navigate to="/cadastro" replace />;
  return <>{props.children}</>;
}
