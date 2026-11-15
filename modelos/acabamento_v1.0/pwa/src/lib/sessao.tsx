import { createContext, useContext, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { apiGet } from './api.js';

export interface Sessao { pessoa_id: string; nome_completo: string; email_primario: string; papel: string }
interface Estado { sessao: Sessao | null; carregando: boolean }

const Ctx = createContext<Estado>({ sessao: null, carregando: true });

export function SessaoProvider(props: { children: ReactNode }) {
  const [estado, setEstado] = useState<Estado>({ sessao: null, carregando: true });
  useEffect(() => {
    apiGet<Sessao>('/auth/sessao')
      .then((s) => setEstado({ sessao: s, carregando: false }))
      .catch(() => setEstado({ sessao: null, carregando: false }));
  }, []);
  return <Ctx.Provider value={estado}>{props.children}</Ctx.Provider>;
}

export function useSessao(): Estado { return useContext(Ctx); }

export const REVISORES = ['admin', 'data_steward', 'curador'];

// Pagina inicial de cada papel.
export function inicioDoPapel(papel: string): string {
  if (REVISORES.includes(papel)) return '/curador/revisao/T001';
  if (papel === 'preceptor' || papel === 'docente') return '/preceptor';
  if (papel === 'pesquisador') return '/pesquisa';
  return '/aluno';
}
