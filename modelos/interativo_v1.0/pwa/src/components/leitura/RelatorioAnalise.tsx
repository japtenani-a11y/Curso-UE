// Painel: relatorio de analise (Python) gerado na hora a partir da base atual, conforme o plano de analise.
// Abre numa aba nova: o relatorio e uma pagina inteira, com graficos, que pode ser salva ou impressa.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

export function RelatorioAnalise() {
  return (
    <article className="cartao-app int-relatorio">
      <h2>Relatório de análise</h2>
      <p className="int-nota">
        Gerado agora, com os dados atuais, pelo plano de análise: qualidade dos dados, curva por onda, ganho e retenção,
        calibração da certeza, modelo principal (H1 a H5) e questões. Pode levar até um minuto. Quem tem perfil de pesquisador
        recebe só quem consentiu, identificado por código.
      </p>
      <p className="int-rev-acoes">
        <a className="botao" href={`${API_BASE}/painel/relatorio`} target="_blank" rel="noopener">Gerar com os dados válidos</a>
        <a className="botao discreto" href={`${API_BASE}/painel/relatorio?simulados=1`} target="_blank" rel="noopener">Ensaio com os dados simulados</a>
      </p>
    </article>
  );
}
