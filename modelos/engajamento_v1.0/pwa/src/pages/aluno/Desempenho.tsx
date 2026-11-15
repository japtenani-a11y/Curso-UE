import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { Avaliacao } from '../../components/Engajamento.js';

interface Nota { tema: string; titulo: string; teste_num: number; acertos: number; total: number; pct: string; nota_ponderada: string; submetida_em: string }
interface Linha { posicao: number; participantes: number; nome: string | null; ano: string | null; especialidade: string | null; media: string | null; testes: number | null; eu: boolean }
const NOMES = ['', 'Pré-teste inicial', 'Pré-teste 2', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90'];
const FILTROS: [string, string][] = [['geral', 'Todos'], ['especialidade', 'Minha especialidade'], ['ano', 'Meu ano (todas as especialidades)'], ['subgrupo', 'Meu ano e especialidade']];

export function Desempenho() {
  const [notas, setNotas] = useState<Nota[] | null>(null);
  const [filtro, setFiltro] = useState('geral');
  const [linhas, setLinhas] = useState<Linha[]>([]);
  useEffect(() => { apiGet<{ notas: Nota[] }>('/eng/notas').then((d) => setNotas(d.notas)).catch(() => setNotas([])); }, []);
  useEffect(() => { apiGet<{ linhas: Linha[] }>(`/eng/ranking?filtro=${filtro}`).then((d) => setLinhas(d.linhas)).catch(() => setLinhas([])); }, [filtro]);
  const eu = linhas.find((l) => l.eu);
  return (
    <section>
      <h1>Meu desempenho</h1>
      <h2>Ranking</h2>
      <div className="etapas" role="tablist">
        {FILTROS.map(([k, r]) => <button key={k} type="button" role="tab" aria-selected={filtro === k} className={`etapa${filtro === k ? ' atual' : ''}`} onClick={() => setFiltro(k)}>{r}</button>)}
      </div>
      <p>{eu ? <strong>Você está em {eu.posicao}º de {eu.participantes} · média {eu.media}</strong> : 'Você entra no ranking ao enviar o primeiro teste.'}
        {' '}A nota de cada teste pondera as questões pela dificuldade; o ranking usa a média de todos os testes enviados. Dos colegas aparecem só a posição, o ano e a especialidade.</p>
      <div className="tabela-rolavel"><table className="tabela">
        <thead><tr><th>Posição</th><th>Participante</th><th>Ano</th><th>Especialidade</th></tr></thead>
        <tbody>{linhas.slice(0, 50).map((l, i) => (
          <tr key={i} className={l.eu ? 'eu' : ''}><td>{l.posicao}º</td><td>{l.eu ? `Você · média ${l.media} em ${l.testes} testes` : 'Colega'}</td><td>{l.ano ?? '—'}</td><td>{l.especialidade ?? '—'}</td></tr>))}</tbody>
      </table></div>
      <h2>Minhas notas</h2>
      {!notas ? <p className="carregando">Carregando…</p> : notas.length === 0 ? <p>Nenhum teste enviado ainda.</p> : (
        <div className="tabela-rolavel"><table className="tabela">
          <thead><tr><th>Tema</th><th>Teste</th><th>Acertos</th><th>%</th><th>Nota ponderada</th><th>Enviado</th></tr></thead>
          <tbody>{notas.map((n, i) => (
            <tr key={i}><td>{n.tema}</td><td>{NOMES[n.teste_num]}</td><td>{n.acertos}/{n.total}</td><td>{n.pct}</td><td>{n.nota_ponderada}</td><td>{new Date(n.submetida_em).toLocaleDateString('pt-BR')}</td></tr>))}</tbody>
        </table></div>)}
      <h2>Avaliação do curso</h2>
      <p>Sua opinião sobre a metodologia como um todo: apresentação, complexidade, conteúdo, objetividade, clareza, tempo exigido e frequência dos testes.</p>
      <Avaliacao tema={null} ferramenta="curso" titulo="Programa de reuniões e testes" curso />
    </section>
  );
}
