import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

interface Item { id: number; tema: string; titulo_tema: string; ideia: number; texto: string; mensagem: string | null; autoriza: boolean; status: string;
  orientador: string | null; nota: string | null; criado_em: string; nome: string; email: string | null; ano: string | null; especialidade: string | null }
const STATUS: [string, string][] = [['novo', 'Novo'], ['em_contato', 'Em contato'], ['encaminhado', 'Encaminhado a orientador'], ['em_andamento', 'Projeto em andamento'], ['encerrado', 'Encerrado']];

function Linha({ i, aoMudar }: { i: Item; aoMudar: () => void }) {
  const [orientador, setOrientador] = useState(i.orientador ?? '');
  const [nota, setNota] = useState(i.nota ?? '');
  const salvar = (status?: string) => apiPost(`/extra/coordenacao/pesquisa/${i.id}`, { status, orientador, nota }).then(aoMudar).catch(() => undefined);
  return (
    <article className={`cartao-app interesse-item ${i.status}`}>
      <span className="rotulo">{i.tema} · ideia {i.ideia} · {new Date(i.criado_em).toLocaleDateString('pt-BR')}</span>
      <h3>{i.nome} <small>{[i.ano, i.especialidade].filter(Boolean).join(' · ')}</small></h3>
      <p>{i.texto}</p>
      {i.mensagem && <p className="citacao">“{i.mensagem}”</p>}
      <p><small>{i.autoriza ? <>Autorizou compartilhar o contato: <a href={`mailto:${i.email}`}>{i.email}</a></> : 'Não autorizou compartilhar o contato com orientadores (fale primeiro com o residente).'}</small></p>
      <div className="grade-form">
        <label>Situação<select value={i.status} onChange={(e) => salvar(e.target.value)}>{STATUS.map(([k, r]) => <option key={k} value={k}>{r}</option>)}</select></label>
        <label>Orientador<input value={orientador} maxLength={200} onChange={(e) => setOrientador(e.target.value)} onBlur={() => salvar()} placeholder="nome do orientador" /></label>
        <label>Anotações da coordenação<input value={nota} maxLength={2000} onChange={(e) => setNota(e.target.value)} onBlur={() => salvar()} /></label>
      </div>
    </article>
  );
}

// Coordenacao: residentes interessados em pesquisar as ideias da sintese de evidencia.
export function InteressesPesquisa() {
  const [itens, setItens] = useState<Item[] | null>(null);
  const [filtro, setFiltro] = useState('abertos');
  const carregar = () => { apiGet<{ itens: Item[] }>('/extra/coordenacao/pesquisa').then((d) => setItens(d.itens)).catch(() => setItens([])); };
  useEffect(carregar, []);
  function csv() {
    const linhas = [['tema', 'ideia', 'residente', 'ano', 'especialidade', 'email', 'situacao', 'orientador', 'texto', 'mensagem'],
      ...(itens ?? []).map((i) => [i.tema, String(i.ideia), i.nome, i.ano ?? '', i.especialidade ?? '', i.email ?? '', i.status, i.orientador ?? '', i.texto, i.mensagem ?? ''])];
    const s = linhas.map((l) => l.map((c) => `"${c.replace(/"/g, '""')}"`).join(';')).join('\n');
    const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob(['﻿' + s], { type: 'text/csv' })); a.download = 'interesse_pesquisa.csv'; a.click();
  }
  if (!itens) return <section><h1>Interesse em pesquisa</h1><p>Carregando…</p></section>;
  const lista = itens.filter((i) => filtro === 'todos' || (filtro === 'abertos' ? i.status !== 'encerrado' : i.status === filtro));
  return (
    <section>
      <h1>Interesse em pesquisa</h1>
      <p className="sub">Residentes que querem desenvolver uma das ideias da síntese de evidência. Faça a ponte com um orientador e registre aqui o andamento; o residente vê a situação na própria síntese.</p>
      <p><label>Mostrar <select value={filtro} onChange={(e) => setFiltro(e.target.value)}><option value="abertos">Em aberto</option><option value="todos">Todos</option>
        {STATUS.map(([k, r]) => <option key={k} value={k}>{r}</option>)}</select></label>{' '}
        <button type="button" className="botao discreto" onClick={csv}>Baixar CSV</button></p>
      {lista.length === 0 ? <p>Nenhum interesse registrado ainda.</p> : lista.map((i) => <Linha key={i.id} i={i} aoMudar={carregar} />)}
    </section>
  );
}
