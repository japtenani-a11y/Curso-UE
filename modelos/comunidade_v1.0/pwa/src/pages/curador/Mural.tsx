import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';
import type { ItemMural, Pergunta } from '../aluno/Mural.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
type NovaPergunta = { texto: string; tipo: Pergunta['tipo']; opcoes: string; obrigatoria: boolean };
const VAZIO = { id: null as number | null, tipo: 'aviso' as ItemMural['tipo'], titulo: '', corpo: '', publico: 'alunos', fixado: false, expira_em: '', avisar_email: false };

function csv(linhas: Record<string, unknown>[]) {
  const cols = linhas[0] ? Object.keys(linhas[0]) : [];
  const cel = (v: unknown) => { const s = v === null || v === undefined ? '' : typeof v === 'object' ? JSON.stringify(v) : String(v); return /[";\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s; };
  return '﻿' + [cols.join(';'), ...linhas.map((l) => cols.map((c) => cel(l[c])).join(';'))].join('\r\n');
}

// Mural da coordenacao: publicar avisos, questionarios (com perguntas) e documentos; ver respostas.
export function CuradorMural() {
  const [itens, setItens] = useState<ItemMural[] | null>(null);
  const [f, setF] = useState(VAZIO);
  const [perg, setPerg] = useState<NovaPergunta[]>([]);
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [resp, setResp] = useState<{ id: number; linhas: Record<string, unknown>[] } | null>(null);
  const carregar = () => apiGet<{ itens: ItemMural[] }>('/com/mural').then((d) => setItens(d.itens)).catch(() => setItens([]));
  useEffect(() => { carregar(); }, []);

  async function salvar() {
    setMsg(null);
    if (f.titulo.trim().length < 3) { setMsg('Escreva um título.'); return; }
    if (f.tipo === 'questionario' && perg.filter((p) => p.texto.trim()).length === 0) { setMsg('Inclua ao menos uma pergunta.'); return; }
    if (arquivo && arquivo.size > 10 * 1024 * 1024) { setMsg('O arquivo passa de 10 MB.'); return; }
    try {
      const r = await apiPost<{ id: number }>('/com/mural', {
        ...f, id: f.id ?? undefined, expira_em: f.expira_em ? new Date(f.expira_em).toISOString() : '',
        perguntas: perg.filter((p) => p.texto.trim()).map((p) => ({ texto: p.texto.trim(), tipo: p.tipo, obrigatoria: p.obrigatoria,
          ...(p.tipo === 'unica' || p.tipo === 'multipla' ? { opcoes: p.opcoes.split('\n').map((x) => x.trim()).filter(Boolean) } : {}) })),
      });
      if (arquivo) {
        const up = await fetch(`${BASE}/com/mural/${r.id}/arquivo?nome=${encodeURIComponent(arquivo.name)}`, { method: 'POST', credentials: 'include',
          headers: { 'Content-Type': arquivo.type || 'application/octet-stream' }, body: arquivo });
        if (!up.ok) { setMsg('Publicado, mas o arquivo não foi enviado.'); carregar(); return; }
      }
      setMsg(f.id ? 'Alterações salvas.' : 'Publicado no mural.'); setF(VAZIO); setPerg([]); setArquivo(null); carregar();
    } catch { setMsg('Não foi possível salvar.'); }
  }
  async function verRespostas(id: number) {
    try { const d = await apiGet<{ respostas: Record<string, unknown>[] }>(`/com/mural/${id}/respostas`); setResp({ id, linhas: d.respostas }); } catch { setMsg('Sem acesso às respostas.'); }
  }
  function baixar(id: number, linhas: Record<string, unknown>[]) {
    const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([csv(linhas)], { type: 'text/csv;charset=utf-8' })); a.download = `respostas_mural_${id}.csv`; a.click();
  }
  return (
    <section>
      <h1>Mural da coordenação</h1>
      <article className="cartao-app ficha">
        <h2 style={{ marginTop: 0 }}>{f.id ? 'Editar publicação' : 'Nova publicação'}</h2>
        <div className="opcoes" role="radiogroup" aria-label="Tipo">
          {([['aviso', 'Aviso'], ['questionario', 'Questionário'], ['documento', 'Documento']] as [ItemMural['tipo'], string][]).map(([k, r]) => (
            <label key={k} className={`opcao${f.tipo === k ? ' sel' : ''}`}><input type="radio" checked={f.tipo === k} onChange={() => setF({ ...f, tipo: k })} /> {r}</label>))}
        </div>
        <label>Título<input value={f.titulo} onChange={(e) => setF({ ...f, titulo: e.target.value })} /></label>
        <label>Texto (aceita **negrito**, listas e links)<textarea rows={5} value={f.corpo} onChange={(e) => setF({ ...f, corpo: e.target.value })} /></label>
        {f.tipo === 'questionario' && (
          <fieldset className="perguntas"><legend>Perguntas</legend>
            {perg.map((p, i) => (
              <div key={i} className="pergunta-edit">
                <input placeholder={`Pergunta ${i + 1}`} value={p.texto} onChange={(e) => setPerg(perg.map((x, j) => j === i ? { ...x, texto: e.target.value } : x))} />
                <select value={p.tipo} onChange={(e) => setPerg(perg.map((x, j) => j === i ? { ...x, tipo: e.target.value as Pergunta['tipo'] } : x))}>
                  <option value="texto">Resposta livre</option><option value="unica">Escolha única</option><option value="multipla">Múltipla escolha</option><option value="escala">Escala 1 a 5</option></select>
                {(p.tipo === 'unica' || p.tipo === 'multipla') && <textarea rows={3} placeholder="Uma opção por linha" value={p.opcoes} onChange={(e) => setPerg(perg.map((x, j) => j === i ? { ...x, opcoes: e.target.value } : x))} />}
                <label className="aceite"><input type="checkbox" checked={p.obrigatoria} onChange={(e) => setPerg(perg.map((x, j) => j === i ? { ...x, obrigatoria: e.target.checked } : x))} /> obrigatória</label>
                <button type="button" className="botao discreto" onClick={() => setPerg(perg.filter((_, j) => j !== i))}>Remover</button>
              </div>))}
            <button type="button" className="botao discreto" onClick={() => setPerg([...perg, { texto: '', tipo: 'unica', opcoes: '', obrigatoria: false }])}>+ Pergunta</button>
          </fieldset>
        )}
        <label>Anexo (PDF, imagem, planilha; até 10 MB, opcional)<input type="file" onChange={(e) => setArquivo(e.target.files?.[0] ?? null)} /></label>
        <label>Para quem<select value={f.publico} onChange={(e) => setF({ ...f, publico: e.target.value })}><option value="alunos">Alunos</option><option value="todos">Todos (alunos e equipe)</option><option value="revisores">Só a equipe</option></select></label>
        <label>Visível até (opcional)<input type="date" value={f.expira_em} onChange={(e) => setF({ ...f, expira_em: e.target.value })} /></label>
        <label className="aceite"><input type="checkbox" checked={f.fixado} onChange={(e) => setF({ ...f, fixado: e.target.checked })} /> Fixar no topo</label>
        {!f.id && <label className="aceite"><input type="checkbox" checked={f.avisar_email} onChange={(e) => setF({ ...f, avisar_email: e.target.checked })} /> Avisar por e-mail os alunos que autorizaram</label>}
        <p style={{ display: 'flex', gap: 8 }}><button type="button" className="botao" onClick={salvar}>{f.id ? 'Salvar' : 'Publicar'}</button>
          {f.id && <button type="button" className="botao discreto" onClick={() => { setF(VAZIO); setPerg([]); }}>Cancelar</button>}</p>
        {msg && <p className="faixa-aviso" role="status">{msg}</p>}
      </article>

      <h2>Publicado</h2>
      {!itens ? <p className="carregando">Carregando…</p> : itens.map((i) => (
        <article key={i.id} className="cartao-app mural-item">
          <span className="rotulo">{i.tipo} · {i.publico} · {new Date(i.publicado_em).toLocaleDateString('pt-BR')}{i.fixado ? ' · fixado' : ''}{i.n_respostas !== null && i.tipo === 'questionario' ? ` · ${i.n_respostas} respostas` : ''}</span>
          <h3>{i.titulo}</h3>
          {i.corpo && <Markdown texto={i.corpo} />}
          {i.arquivo_nome && <p><a href={`${BASE}/com/mural/${i.id}/arquivo`}>{i.arquivo_nome}</a></p>}
          <p style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <button type="button" className="botao discreto" onClick={() => { setF({ id: i.id, tipo: i.tipo, titulo: i.titulo, corpo: i.corpo ?? '', publico: i.publico, fixado: i.fixado, expira_em: i.expira_em?.slice(0, 10) ?? '', avisar_email: false });
              setPerg((i.perguntas ?? []).map((p) => ({ texto: p.texto, tipo: p.tipo, opcoes: (p.opcoes ?? []).join('\n'), obrigatoria: p.obrigatoria }))); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>Editar</button>
            <button type="button" className="botao discreto" onClick={async () => { await apiPost('/com/mural', { id: i.id, tipo: i.tipo, titulo: i.titulo, corpo: i.corpo, publico: i.publico, arquivado: true }); carregar(); }}>Arquivar</button>
            {i.tipo === 'questionario' && <button type="button" className="botao discreto" onClick={() => verRespostas(i.id)}>Ver respostas</button>}
          </p>
          {resp?.id === i.id && (
            <div>
              <button type="button" className="botao discreto" onClick={() => baixar(i.id, resp.linhas)}>Baixar CSV</button>
              <div className="tabela-rolavel"><table className="tabela compacta"><thead><tr><th>Aluno</th><th>Ano</th><th>Especialidade</th>{(i.perguntas ?? []).map((p) => <th key={p.ordem}>{p.ordem}. {p.texto}</th>)}</tr></thead>
                <tbody>{resp.linhas.map((l, k) => { const r = (l.respostas ?? {}) as Record<string, unknown>; return (
                  <tr key={k}><td>{String(l.aluno)}</td><td>{String(l.ano ?? '—')}</td><td>{String(l.especialidade ?? '—')}</td>{(i.perguntas ?? []).map((p) => <td key={p.ordem}>{Array.isArray(r[p.ordem]) ? (r[p.ordem] as string[]).join(', ') : String(r[p.ordem] ?? '')}</td>)}</tr>); })}</tbody></table></div>
            </div>
          )}
        </article>
      ))}
    </section>
  );
}
