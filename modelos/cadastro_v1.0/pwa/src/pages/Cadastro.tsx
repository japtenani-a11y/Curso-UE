import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';
import { Markdown } from '../lib/md.js';
import { FACULDADES, RESIDENCIAS } from '../lib/instituicoes.js';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

interface Termo { codigo: string; versao: string; titulo: string; resumo: string; texto: string; obrigatorio: boolean; aceito: boolean; aceito_em: string | null }
interface Ficha {
  status: 'rascunho' | 'pendente' | 'aprovado' | 'recusado'; motivo_status?: string | null; celular?: string | null; situacao?: string | null;
  semestre?: number | null; ano_formatura?: number | null; faculdade?: string | null; especialidade?: string | null; especialidade_outra?: string | null;
  instituicao_residencia?: string | null; ano_ingresso_residencia?: number | null; termino_previsto?: string | null;
}
interface Dados { nome: string; email: string; data_nascimento: string | null; ficha: Ficha; precisa_ficha: boolean; cadastro_ok: boolean; confirmar_ano?: boolean; termos: Termo[] }

const ESPECIALIDADES: [string, string][] = [
  ['cirurgia_geral', 'Cirurgia geral'], ['cirurgia_urgencia_trauma', 'Cirurgia de urgência e trauma'],
  ['medicina_emergencia', 'Medicina de emergência'], ['outra_cirurgica', 'Outra especialidade cirúrgica'],
];
const CAMPOS: Record<string, string> = {
  nome: 'Informe o nome completo (nome e sobrenome).', data_nascimento: 'Confira a data de nascimento.',
  celular: 'Informe o celular com DDD, por exemplo (16) 99999-0000.', situacao: 'Escolha a sua situação atual.',
  semestre: 'Escolha o semestre da graduação (7º a 12º).', ano_formatura: 'Informe o ano de formatura.',
  especialidade: 'Escolha a especialidade.', especialidade_outra: 'Diga qual é a outra especialidade cirúrgica.',
  ano_ingresso_residencia: 'Informe o ano de ingresso na residência.', faculdade: 'Informe a faculdade de medicina (escolha da lista ou digite).',
  instituicao_residencia: 'Informe o local da residência (escolha da lista ou digite).', termino_previsto: 'Informe a data prevista de término (depois do ingresso).',
};
const STATUS: Record<string, string> = {
  rascunho: 'Preencha a ficha, leia e aceite os termos e envie a inscrição.',
  pendente: 'Inscrição enviada. A coordenação vai analisar e você recebe um e-mail com a resposta. Enquanto isso, você pode corrigir a ficha.',
  aprovado: 'Inscrição aprovada. Mantenha seus dados atualizados.',
  recusado: 'Inscrição não aprovada.',
};

function celularE164(v: string): string {
  const d = v.replace(/\D/g, '');
  if (v.trim().startsWith('+')) return `+${d}`;
  if (d.length === 10 || d.length === 11) return `+55${d}`;
  if (d.startsWith('55') && (d.length === 12 || d.length === 13)) return `+${d}`;
  return v;
}
function celularBonito(v: string | null | undefined): string {
  const m = /^\+55(\d{2})(\d{4,5})(\d{4})$/.exec(v ?? '');
  return m ? `(${m[1]}) ${m[2]}-${m[3]}` : (v ?? '');
}
function baixar(t: Termo) {
  const blob = new Blob([`${t.titulo}\nVersão ${t.versao}\n\n${t.texto.replace(/\*\*/g, '')}`], { type: 'text/plain;charset=utf-8' });
  const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = `termo_${t.codigo}_${t.versao}.txt`; a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}

// Ficha de inscricao do aluno, termos e direitos sobre os dados ("Meus dados").
export function Cadastro() {
  const [d, setD] = useState<Dados | null>(null);
  const [f, setF] = useState<Record<string, string>>({});
  const [aceites, setAceites] = useState<Record<string, boolean | null>>({});
  const [aberto, setAberto] = useState<string | null>(null);
  const [erro, setErro] = useState<{ campo?: string; texto: string } | null>(null);
  const [ok, setOk] = useState<string | null>(null);
  const [pedido, setPedido] = useState({ tipo: 'copia', texto: '' });

  function carregar() {
    apiGet<Dados>('/cadastro/ficha').then((x) => {
      setD(x);
      const fi = x.ficha;
      setF({
        nome: x.nome ?? '', data_nascimento: x.data_nascimento ?? '', celular: celularBonito(fi.celular), situacao: fi.situacao ?? '',
        semestre: fi.semestre ? String(fi.semestre) : '', ano_formatura: fi.ano_formatura ? String(fi.ano_formatura) : '',
        faculdade: fi.faculdade ?? '', especialidade: fi.especialidade ?? '', especialidade_outra: fi.especialidade_outra ?? '',
        instituicao_residencia: fi.instituicao_residencia ?? '', ano_ingresso_residencia: fi.ano_ingresso_residencia ? String(fi.ano_ingresso_residencia) : '',
        termino_previsto: fi.termino_previsto ?? '',
      });
      setAceites(Object.fromEntries(x.termos.map((t) => [t.codigo, t.aceito ? true : (t.aceito_em === null && fi.status === 'rascunho' ? null : false)])));
    }).catch(() => setErro({ texto: 'Não foi possível carregar a ficha. Entre de novo.' }));
  }
  useEffect(carregar, []);

  const campo = (k: string) => ({ value: f[k] ?? '', onChange: (e: { target: { value: string } }) => setF({ ...f, [k]: e.target.value }), 'aria-invalid': erro?.campo === k });

  async function enviar(ev: React.FormEvent) {
    ev.preventDefault(); setErro(null); setOk(null);
    const faltando = (d?.termos ?? []).find((t) => t.obrigatorio && aceites[t.codigo] !== true);
    if (faltando) { setErro({ campo: faltando.codigo, texto: `Para participar, é preciso aceitar: ${faltando.titulo}.` }); return; }
    try {
      const r = await fetch(`${BASE}/cadastro/ficha`, {
        method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...f, celular: celularE164(f.celular ?? ''), aceites: Object.fromEntries(Object.entries(aceites).filter(([, v]) => v !== null)) }),
      });
      const j = await r.json() as { ok?: boolean; status?: string; erro?: string; campo?: string };
      if (!r.ok) {
        setErro(j.campo ? { campo: j.campo, texto: CAMPOS[j.campo] ?? `Confira o campo ${j.campo}.` } : { texto: 'Não foi possível salvar. Tente de novo.' });
        return;
      }
      setOk(j.status === 'aprovado' ? 'Dados atualizados.' : 'Inscrição enviada! Você recebe um e-mail quando a coordenação responder.');
      carregar(); window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch { setErro({ texto: 'Sem conexão. Tente de novo.' }); }
  }

  async function solicitar() {
    try { await apiPost('/cadastro/solicitacao', pedido); setOk('Pedido enviado à coordenação. A resposta chega pelo seu e-mail.'); setPedido({ tipo: 'copia', texto: '' }); }
    catch { setErro({ texto: 'Não foi possível enviar o pedido.' }); }
  }

  if (!d) return <p className="carregando">{erro?.texto ?? 'Carregando…'}</p>;
  const st = d.ficha.status;
  const sit = f.situacao;
  return (
    <section className="cadastro">
      <h1>{st === 'aprovado' ? 'Meus dados' : 'Inscrição no curso'}</h1>
      <p className={st === 'recusado' ? 'faixa-erro' : 'faixa-aviso'} role="status">
        {STATUS[st]}{st === 'recusado' && d.ficha.motivo_status ? ` Motivo: ${d.ficha.motivo_status}. Corrija e envie de novo.` : ''}
      </p>
      {st === 'aprovado' && d.confirmar_ano && <p className="faixa-erro">Confirmação anual: confira o seu ano de residência, a especialidade e os demais dados e clique em “Salvar alterações” para continuar usando o curso.</p>}
      {st === 'aprovado' && !d.cadastro_ok && !d.confirmar_ano && <p className="faixa-erro">Há termo obrigatório novo ou revogado: aceite-o abaixo para continuar usando o curso.</p>}
      {ok && <p className="faixa-aviso" role="status">{ok}</p>}
      {erro && <p className="faixa-erro" role="alert">{erro.texto}</p>}
      {st === 'aprovado' && d.cadastro_ok && <p><a className="botao" href="/aluno">Ir para o curso</a></p>}

      <form onSubmit={enviar} noValidate>
        <fieldset className="cartao-app ficha">
          <legend>Dados pessoais</legend>
          <label>Nome completo<input required autoComplete="name" {...campo('nome')} /></label>
          <label>E-mail (da sua conta Google)<input value={d.email} readOnly /></label>
          <label>Data de nascimento (usamos também para lembrar o seu aniversário)<input type="date" required {...campo('data_nascimento')} /></label>
          <label>Celular para contato<input type="tel" inputMode="tel" placeholder="(16) 99999-0000" required autoComplete="tel" {...campo('celular')} /></label>
        </fieldset>

        <fieldset className="cartao-app ficha">
          <legend>Formação</legend>
          <div className="opcoes" role="radiogroup" aria-label="Situação atual" aria-invalid={erro?.campo === 'situacao'}>
            {([['graduacao', 'Estudante de graduação'], ['residencia', 'Médico residente'], ['formado', 'Médico formado (fora da residência)']] as [string, string][]).map(([k, r]) => (
              <label key={k} className={`opcao${sit === k ? ' sel' : ''}`}><input type="radio" name="situacao" checked={sit === k} onChange={() => setF({ ...f, situacao: k })} /> {r}</label>
            ))}
          </div>
          {sit && <label>{sit === 'graduacao' ? 'Onde você faz a faculdade' : 'Onde você se formou (faculdade)'}
            <input list="lista-faculdades" placeholder="digite para buscar: FMRP, FAMERP, FAMEMA, UNESP…" {...campo('faculdade')} />
            <small className="dica">Escolha da lista ou digite o nome, se não encontrar.</small></label>}
          {sit === 'graduacao' && (
            <label>Semestre da graduação<select {...campo('semestre')}><option value="">escolha</option>{[7, 8, 9, 10, 11, 12].map((s) => <option key={s} value={s}>{s}º semestre</option>)}</select></label>
          )}
          {(sit === 'residencia' || sit === 'formado') && (<>
            <label>Ano de formatura na faculdade<input type="number" min={1960} max={new Date().getFullYear()} {...campo('ano_formatura')} /></label>
            <label>Especialidade<select {...campo('especialidade')}><option value="">escolha</option>{ESPECIALIDADES.map(([k, r]) => <option key={k} value={k}>{r}</option>)}</select></label>
            {f.especialidade === 'outra_cirurgica' && <label>Qual especialidade?<input {...campo('especialidade_outra')} /></label>}
          </>)}
          {sit === 'formado' && (
            <label>Onde você fez a residência (se fez)<input list="lista-residencias" placeholder="deixe em branco se não fez residência" {...campo('instituicao_residencia')} /></label>
          )}
          <datalist id="lista-faculdades">{FACULDADES.map((x) => <option key={x} value={x} />)}</datalist>
          <datalist id="lista-residencias">{RESIDENCIAS.map((x) => <option key={x} value={x} />)}</datalist>
          {sit === 'residencia' && (<>
            <label>Onde você faz a residência<input list="lista-residencias" placeholder="digite para buscar: HCFMRP, Hospital de Base, UNICAMP…" {...campo('instituicao_residencia')} />
              <small className="dica">Escolha da lista ou digite o nome do hospital/instituição.</small></label>
            <label>Ano de ingresso na residência<input type="number" min={1990} max={new Date().getFullYear() + 1} {...campo('ano_ingresso_residencia')} /></label>
            <label>Data prevista de término da residência<input type="date" {...campo('termino_previsto')} /></label>
          </>)}
        </fieldset>

        <fieldset className="cartao-app ficha termos">
          <legend>Termos</legend>
          <p>Os dois primeiros são obrigatórios para participar. A pesquisa e a divulgação são <strong>opcionais</strong>: recusar não muda em nada a sua participação, e você pode mudar de ideia a qualquer momento nesta tela.</p>
          {d.termos.map((t) => (
            <div key={t.codigo} className={`termo${erro?.campo === t.codigo ? ' invalido' : ''}`}>
              <h3>{t.titulo} {t.obrigatorio ? <span className="selo nuclear">obrigatório</span> : <span className="selo eletivo">opcional</span>}</h3>
              <p>{t.resumo}</p>
              <p className="termo-acoes">
                <button type="button" className="botao discreto" aria-expanded={aberto === t.codigo} onClick={() => setAberto(aberto === t.codigo ? null : t.codigo)}>{aberto === t.codigo ? 'Fechar texto' : 'Ler o termo completo'}</button>
                <button type="button" className="botao discreto" onClick={() => baixar(t)}>Baixar cópia</button>
                {t.aceito_em && <small>Aceito em {new Date(t.aceito_em).toLocaleString('pt-BR')} (versão {t.versao})</small>}
              </p>
              {aberto === t.codigo && <div className="termo-texto" tabIndex={0}><Markdown texto={t.texto} /></div>}
              {t.obrigatorio ? (
                <label className="aceite"><input type="checkbox" checked={aceites[t.codigo] === true} onChange={(e) => setAceites({ ...aceites, [t.codigo]: e.target.checked })} /> Li e aceito</label>
              ) : (
                <div className="opcoes" role="radiogroup" aria-label={t.titulo}>
                  <label className={`opcao${aceites[t.codigo] === true ? ' sel' : ''}`}><input type="radio" name={t.codigo} checked={aceites[t.codigo] === true} onChange={() => setAceites({ ...aceites, [t.codigo]: true })} /> Aceito</label>
                  <label className={`opcao${aceites[t.codigo] === false ? ' sel' : ''}`}><input type="radio" name={t.codigo} checked={aceites[t.codigo] === false} onChange={() => setAceites({ ...aceites, [t.codigo]: false })} /> Não aceito</label>
                </div>
              )}
            </div>
          ))}
        </fieldset>
        <button type="submit" className="botao">{st === 'aprovado' ? 'Salvar alterações' : st === 'pendente' ? 'Atualizar inscrição' : 'Enviar inscrição'}</button>
      </form>

      {st === 'aprovado' && (
        <article className="cartao-app" style={{ marginTop: 20 }}>
          <h2 style={{ marginTop: 0 }}>Lembretes por e-mail</h2>
          <p>Escolha se quer receber avisos de abertura do tema, prazos e testes pendentes.</p>
          <a className="botao discreto" href="/aluno/contato">Configurar lembretes</a>
        </article>
      )}
      {st !== 'rascunho' && (
        <article className="cartao-app" style={{ marginTop: 20 }}>
          <h2 style={{ marginTop: 0 }}>Seus direitos sobre os dados (LGPD)</h2>
          <p>Peça uma cópia, a correção ou a exclusão dos seus dados, ou tire dúvidas sobre o uso deles. O pedido vai para a coordenação.</p>
          <div className="ficha">
            <label>Pedido<select value={pedido.tipo} onChange={(e) => setPedido({ ...pedido, tipo: e.target.value })}>
              <option value="copia">Cópia dos meus dados</option><option value="correcao">Correção de dados</option>
              <option value="exclusao">Exclusão dos meus dados</option><option value="outro">Outro pedido</option></select></label>
            <label>Detalhes (opcional)<textarea value={pedido.texto} onChange={(e) => setPedido({ ...pedido, texto: e.target.value })} /></label>
          </div>
          <button type="button" className="botao discreto" onClick={solicitar}>Enviar pedido</button>
        </article>
      )}
    </section>
  );
}
