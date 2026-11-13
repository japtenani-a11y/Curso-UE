import { useEffect, useState } from 'react';
import { apiGet } from '../lib/api.js';

interface Cert { codigo: string; emitido_em: string; nome: string; temas_concluidos: number; horas: number; presenca_pct: number | null;
  aulas_presentes: number; aulas_realizadas: number; lista_temas: string[]; perfil?: { ano: string | null; especialidade: string | null } }

// Certificado (publico, para verificacao): /certificado/CODIGO. Imprimir ou salvar como PDF pelo navegador.
export function Certificado() {
  const cod = decodeURIComponent(window.location.pathname.split('/').pop() ?? '');
  const [c, setC] = useState<Cert | null | undefined>(undefined);
  useEffect(() => { apiGet<Cert>(`/publico/certificado/${cod}`).then(setC).catch(() => setC(null)); }, [cod]);
  if (c === undefined) return <p className="carregando">Carregando…</p>;
  if (c === null) return <div className="certificado-pagina"><p className="faixa-erro">Certificado {cod} não encontrado.</p></div>;
  const url = `${window.location.origin}/certificado/${c.codigo}`;
  return (
    <div className="certificado-pagina">
      <p className="sem-impressao"><button type="button" className="botao" onClick={() => window.print()}>Imprimir ou salvar em PDF</button> <a href="/aluno/aproveitamento">Voltar</a></p>
      <article className="certificado">
        <img src="/icone.svg" alt="" className="cert-icone" />
        <p className="cert-instituicao">Programa de Cirurgia de Urgência e Trauma · HCFMRP-USP</p>
        <h1>Certificado de participação</h1>
        <p className="cert-texto">Certificamos que <strong>{c.nome}</strong>{c.perfil?.ano ? ` (${c.perfil.ano}${c.perfil.especialidade ? `, ${c.perfil.especialidade}` : ''})` : ''} participou do Programa de Cirurgia de Urgência e Trauma,
          concluindo <strong>{c.temas_concluidos} {c.temas_concluidos === 1 ? 'tema' : 'temas'}</strong>, com carga horária de <strong>{c.horas} horas</strong>
          {c.presenca_pct !== null ? <> e <strong>{c.presenca_pct}% de presença</strong> nas aulas ao vivo ({c.aulas_presentes} de {c.aulas_realizadas})</> : null}.</p>
        <details className="cert-temas" open={c.lista_temas.length <= 12}><summary>Temas concluídos</summary><ol>{c.lista_temas.map((t) => <li key={t}>{t}</li>)}</ol></details>
        <div className="cert-assinatura"><span>Coordenação do Programa de Cirurgia de Urgência e Trauma</span></div>
        <p className="cert-verif">Emitido em {new Date(c.emitido_em).toLocaleDateString('pt-BR')} · Código de verificação <strong>{c.codigo}</strong> · {url}</p>
      </article>
    </div>
  );
}
