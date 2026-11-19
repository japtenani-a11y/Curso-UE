#!/usr/bin/env bash
# ============================================================
# 108_pdf_marca_dagua_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026):
#  - botoes "Baixar esta peça em PDF" e "Baixar o tema inteiro em PDF" na leitura do material;
#  - PDF com o desenho do curso (capa, cabecalho com a marca, rodape) e, em todas as paginas, a marca d'agua com
#    nome, codigo do aluno no curso, CRM/UF (se informado), data e hora do download e o codigo de verificacao;
#  - cartao "Registro profissional" (CRM e UF) em Meus dados.
# O PDF e gerado pelo navegador ("Salvar como PDF" na janela de impressao). Cada download fica registrado no banco.
# Precisa do 108_pdf_marca_dagua_v1.0.sql. Roda depois dos outros scripts *_app. Pode ser rodado mais de uma vez.
# USO: bash 108_pdf_marca_dagua_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -f "$API/routes/leitura.ts" ] && [ -f "$API/routes/cadastro.ts" ] && [ -f "$PWA/pages/aluno/Leitura.tsx" ] && [ -f "$PWA/pages/Cadastro.tsx" ] \
  || { echo "ERRO: codigo gerado nao encontrado em $RAIZ"; exit 1; }

# ---------- API: leitura (registrar download e verificar codigo) ----------
python3 - "$API/routes/leitura.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if "'/pdf'" not in s:
    marca = "leituraRouter.get('/podcast/:codigo',"
    assert marca in s, 'leitura.ts mudou'
    novo = """// PDF com marca d'agua: registra o download e devolve o texto das pecas ja liberadas e os dados da marca.
leituraRouter.post('/pdf', async (req, res, next) => {
  try {
    const r = req as { pessoaId?: number };
    if (!r.pessoaId) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const tema = String(req.body?.tema ?? '').slice(0, 20);
    const tipo = req.body?.tipo == null ? null : String(req.body.tipo).slice(0, 40);
    const d = await withMaestro(null, async (c) => (await c.query(
      'SELECT app.registrar_download_pdf($1, $2, $3::inet, $4) AS d', [tema, tipo, req.ip ?? null, req.get('user-agent') ?? ''])).rows[0]?.d);
    res.json(d);
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    if (m === 'limite_downloads') { res.status(429).json({ erro: m }); return; }
    if (['nada_liberado', 'tema_nao_encontrado', 'peca_invalida'].includes(m)) { res.status(404).json({ erro: m }); return; }
    next(err);
  }
});

// Coordenacao: quem baixou a copia com este codigo de verificacao.
leituraRouter.get('/pdf/verificar/:codigo', async (req, res, next) => {
  try {
    const d = await withMaestro(null, async (c) => (await c.query(
      'SELECT app.verificar_download_pdf($1) AS d', [String(req.params.codigo).slice(0, 12)])).rows[0]?.d);
    if (d?.erro === 'proibido') { res.status(403).json(d); return; }
    if (!d) { res.status(404).json({ erro: 'codigo_nao_encontrado' }); return; }
    res.json(d);
  } catch (err) { next(err); }
});

"""
    s = s.replace(marca, novo + marca, 1)
    open(p, 'w').write(s)
EOF

# ---------- API: cadastro (CRM e UF) ----------
python3 - "$API/routes/cadastro.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if "'/registro-profissional'" not in s:
    marca = "// Pedido do titular (LGPD)"
    assert marca in s, 'cadastro.ts mudou'
    novo = """// Registro profissional (CRM e UF): vai na marca d'agua dos PDFs baixados.
cadastroRouter.get('/registro-profissional', async (_req, res, next) => {
  try {
    res.json(await withMaestro(null, async (c) => (await c.query('SELECT app.meu_registro_profissional() AS r')).rows[0]?.r ?? {}));
  } catch (err) { next(err); }
});

cadastroRouter.post('/registro-profissional', async (req, res, next) => {
  try {
    const crm = req.body?.crm == null ? null : String(req.body.crm).slice(0, 20);
    const uf = req.body?.uf == null ? null : String(req.body.uf).slice(0, 2);
    res.json(await withMaestro(null, async (c) => (await c.query(
      'SELECT app.salvar_registro_profissional($1, $2) AS r', [crm, uf])).rows[0]?.r ?? {}));
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    const v = /^campo:([a-z_]+)$/.exec(m);
    if (v) { res.status(422).json({ erro: 'campo_invalido', campo: v[1] }); return; }
    next(err);
  }
});

"""
    s = s.replace(marca, novo + marca, 1)
    open(p, 'w').write(s)
EOF

# ---------- PWA: botoes e documento para impressao ----------
cat > "$PWA/components/leitura/BaixarPdf.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { apiPost } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';

interface Peca { tipo: string; versao: number; titulo: string; corpo: string }
interface Pacote {
  codigo_verificacao: string; baixado_em: string; nome: string; codigo_aluno: string; crm: string | null;
  tema: { codigo: string; titulo: string }; inteiro: boolean; pecas: Peca[];
}

const NOME: Record<string, string> = {
  objetivos: 'Objetivos', resumo_basico: 'Resumo básico', podcast_roteiro: 'Roteiro do podcast', caso_base: 'Caso base',
  sintese_evidencia: 'Síntese da evidência', mapa: 'Mapa conceitual', aula: 'Aula', slides: 'Slides', caso: 'Caso da aula',
  resumo: 'Resumo executivo', protocolo: 'Guia de atendimento (proposta)', checklist: 'Checklist', flashcard: 'Flashcards', simulado: 'Simulado',
};

// Mesmo texto que o aluno le: sem a faixa de rascunho e sem os codigos das afirmacoes.
function limpar(corpo: string): string {
  return corpo.split('\n').filter((l) => !l.startsWith('> RASCUNHO'))
    .map((l) => l.replace(/\s*Rascunho sujeito à revisão[^.]*\./, '')).join('\n')
    .replace(/\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]/g, '');
}

const CSS = `
@media screen { #impressao-cut { display: none; } }
@media print {
  @page { size: A4 portrait; margin: 12mm 16mm; }
  body > *:not(#impressao-cut) { display: none !important; }
  #impressao-cut, #impressao-cut * { visibility: visible !important; }
  body::after { content: none !important; display: none !important; }
  html, body { background: #fff !important; }
  #impressao-cut { display: block; font-family: var(--cut-font); color: var(--cut-text); font-size: 10.5pt; line-height: 1.5;
    -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  #impressao-cut table.pg { width: 100%; border-collapse: collapse; }
  #impressao-cut table.pg > thead td { padding: 0 0 3mm; border-bottom: 1px solid var(--cut-line); }
  #impressao-cut table.pg > tfoot td { padding: 2mm 0 0; border-top: 1px solid var(--cut-line); font-size: 7.5pt; color: var(--cut-text-muted); }
  #impressao-cut .cab { display: flex; align-items: center; justify-content: space-between; gap: 8mm; font-size: 8pt; color: var(--cut-text-muted); }
  #impressao-cut .cab img { height: 8mm; }
  #impressao-cut .rod strong { color: var(--cut-text); }
  #impressao-cut .dagua { position: fixed; top: 46%; left: 0; right: 0; text-align: center; transform: rotate(-30deg);
    font-size: 22pt; font-weight: 700; color: var(--cut-brand); opacity: .07; white-space: nowrap; pointer-events: none; }
  #impressao-cut .capa { break-after: page; padding-top: 30mm; }
  #impressao-cut .capa .barra { width: 18mm; height: 2mm; background: var(--cut-incision); margin: 0 0 8mm; }
  #impressao-cut .capa .rotulo { font-size: 8.5pt; letter-spacing: .14em; text-transform: uppercase; color: var(--cut-text-muted); }
  #impressao-cut .capa h1 { font-size: 26pt; line-height: 1.15; margin: 4mm 0 2mm; font-family: var(--cut-font); font-weight: 800; }
  #impressao-cut .capa .cod { color: var(--cut-incision); font-weight: 800; }
  #impressao-cut .capa ol { margin: 10mm 0 0; padding-left: 5mm; }
  #impressao-cut .capa .quem { margin-top: 16mm; border: 1px solid var(--cut-line); border-radius: var(--cut-r-md); padding: 5mm 6mm; font-size: 9pt; }
  #impressao-cut section.peca { break-before: page; }
  #impressao-cut section.peca:first-of-type { break-before: auto; }
  #impressao-cut section.peca > h2.titulo-peca { font-family: var(--cut-font); font-size: 17pt; font-weight: 800; margin: 0 0 4mm;
    padding-bottom: 2mm; border-bottom: 2px solid var(--cut-incision); }
  #impressao-cut h1, #impressao-cut h2, #impressao-cut h3 { break-after: avoid; }
  #impressao-cut table { break-inside: auto; } #impressao-cut tr, #impressao-cut blockquote, #impressao-cut pre { break-inside: avoid; }
  #impressao-cut .md table { border-collapse: collapse; width: 100%; font-size: 8.5pt; }
  #impressao-cut .md th, #impressao-cut .md td { border-bottom: 1px solid var(--cut-line); padding: 1.5mm 2mm; text-align: left; vertical-align: top; }
  #impressao-cut a { color: inherit; text-decoration: none; }
}`;

function quando(iso: string): string {
  return new Date(iso).toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo', dateStyle: 'short', timeStyle: 'short' });
}

function Documento({ d }: { d: Pacote }) {
  const id = [d.nome, d.codigo_aluno, d.crm].filter(Boolean).join(' · ');
  return (
    <div id="impressao-cut" aria-hidden="true">
      <div className="dagua">{id} · {d.codigo_verificacao}</div>
      <table className="pg">
        <thead><tr><td>
          <div className="cab"><img src="/cut_horizontal_claro.svg" alt="CUT" /><span>{d.tema.codigo} · {d.tema.titulo}</span></div>
        </td></tr></thead>
        <tfoot><tr><td>
          <div className="rod">Uso pessoal e intransferível. Baixado por <strong>{id}</strong> em {quando(d.baixado_em)} ·
            código de verificação <strong>{d.codigo_verificacao}</strong>. Reprodução e distribuição proibidas.</div>
        </td></tr></tfoot>
        <tbody><tr><td>
          {d.inteiro && (
            <div className="capa">
              <div className="barra" />
              <div className="rotulo">CUT · Curso de Cirurgia Geral, Urgência e Trauma · material do tema</div>
              <h1><span className="cod">{d.tema.codigo}</span> {d.tema.titulo}</h1>
              <ol>{d.pecas.map((p) => <li key={p.tipo}>{NOME[p.tipo] ?? p.tipo}</li>)}</ol>
              <div className="quem">Cópia de uso pessoal de <strong>{id}</strong>, baixada em {quando(d.baixado_em)}.<br />
                Código de verificação: <strong>{d.codigo_verificacao}</strong>. O download fica registrado no curso.</div>
            </div>
          )}
          {d.pecas.map((p) => (
            <section className="peca" key={p.tipo}>
              <h2 className="titulo-peca">{NOME[p.tipo] ?? p.tipo}</h2>
              <Markdown texto={limpar(p.corpo).replace(/^\s*# [^\n]*\n/, '')} />
            </section>
          ))}
        </td></tr></tbody>
      </table>
    </div>
  );
}

// Botoes da leitura: baixa a peca aberta ou o tema inteiro (so o que ja esta liberado para a pessoa).
export function BaixarPdf({ tema, tipo }: { tema: string; tipo: string }) {
  const [doc, setDoc] = useState<Pacote | null>(null);
  const [ocupado, setOcupado] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    const fim = () => setDoc(null);
    window.addEventListener('afterprint', fim);
    return () => window.removeEventListener('afterprint', fim);
  }, []);
  useEffect(() => {
    if (!doc) return;
    const t = window.setTimeout(() => window.print(), 600);
    return () => window.clearTimeout(t);
  }, [doc]);

  async function baixar(inteiro: boolean) {
    setErro(null); setOcupado(true);
    try {
      setDoc(await apiPost<Pacote>('/leitura/pdf', { tema: tema.replace(/-/g, ''), tipo: inteiro ? null : tipo }));
    } catch (e) {
      const m = String((e as Error).message ?? '');
      setErro(m.endsWith('429') ? 'Você atingiu o limite de 30 downloads em 24 horas. Tente amanhã.'
        : m.endsWith('404') ? 'Ainda não há material liberado para baixar.'
        : 'Não foi possível preparar o PDF. Tente de novo.');
    } finally { setOcupado(false); }
  }

  return (
    <div className="baixar-pdf" style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center', margin: '18px 0 6px' }}>
      <style>{CSS}</style>
      <button type="button" className="botao discreto" disabled={ocupado} onClick={() => baixar(false)}>Baixar esta peça em PDF</button>
      <button type="button" className="botao discreto" disabled={ocupado} onClick={() => baixar(true)}>Baixar o tema inteiro em PDF</button>
      <small style={{ flexBasis: '100%', color: 'var(--cut-text-muted)' }}>
        Na janela que abrir, escolha “Salvar como PDF”. Todas as páginas levam seu nome, seu código no curso, seu CRM
        (se informado em <a href="/cadastro">Meus dados</a>), a data e a hora do download.
      </small>
      {erro && <p role="alert" className="faixa-erro" style={{ flexBasis: '100%' }}>{erro}</p>}
      {doc && createPortal(<Documento d={doc} />, document.body)}
    </div>
  );
}
EOF

cat > "$PWA/components/RegistroProfissional.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

const UFS = ['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'];
interface Reg { codigo_aluno?: string; crm?: string | null; crm_uf?: string | null }

// Meus dados: CRM e UF, que entram na marca d'agua dos PDFs baixados. Graduando deixa em branco.
export function RegistroProfissional() {
  const [r, setR] = useState<Reg | null>(null);
  const [crm, setCrm] = useState(''); const [uf, setUf] = useState('');
  const [msg, setMsg] = useState<{ ok: boolean; texto: string } | null>(null);
  useEffect(() => {
    apiGet<Reg>('/cadastro/registro-profissional').then((d) => { setR(d); setCrm(d.crm ?? ''); setUf(d.crm_uf ?? ''); }).catch(() => setR({}));
  }, []);
  async function salvar(e: FormEvent) {
    e.preventDefault(); setMsg(null);
    try {
      const d = await apiPost<Reg>('/cadastro/registro-profissional', { crm: crm || null, uf: uf || null });
      setR(d); setMsg({ ok: true, texto: d.crm ? 'Registro salvo.' : 'Registro apagado.' });
    } catch { setMsg({ ok: false, texto: 'Confira o número do CRM (só números) e escolha a UF. Para apagar, deixe os dois em branco.' }); }
  }
  if (!r) return null;
  return (
    <form className="cartao-app ficha" style={{ marginTop: 20 }} onSubmit={salvar} noValidate>
      <h2 style={{ marginTop: 0 }}>Registro profissional</h2>
      <p>Seu código no curso é <strong>{r.codigo_aluno ?? '—'}</strong>. Informe o CRM e a UF: eles saem, com o seu nome, em todas as
        páginas do material que você baixar em PDF. Quem ainda está na graduação deixa em branco.</p>
      <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <label>Número do CRM<input inputMode="numeric" autoComplete="off" maxLength={10} value={crm}
          onChange={(e) => setCrm(e.target.value.replace(/[^0-9]/g, ''))} /></label>
        <label>UF<select value={uf} onChange={(e) => setUf(e.target.value)}>
          <option value="">—</option>{UFS.map((u) => <option key={u} value={u}>{u}</option>)}</select></label>
        <button type="submit" className="botao">Salvar registro</button>
      </div>
      {msg && <p className={msg.ok ? 'faixa-neutra' : 'faixa-erro'} role={msg.ok ? 'status' : 'alert'}>{msg.texto}</p>}
    </form>
  );
}
EOF

python3 - "$PWA/pages/aluno/Leitura.tsx" "$PWA/pages/Cadastro.tsx" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if 'BaixarPdf' not in s:
    a = "import { FormatoPeca } from '../../components/leitura/FormatoPeca.js';\n"
    b = "          {!dados.previa && <TempoLeitura "
    assert a in s and b in s, 'Leitura.tsx mudou'
    s = s.replace(a, a + "import { BaixarPdf } from '../../components/leitura/BaixarPdf.js';\n", 1)
    s = s.replace(b, "          {!dados.previa && <BaixarPdf tema={dados.tema.codigo} tipo={art.tipo} />}\n" + b, 1)
    open(p, 'w').write(s)
p = sys.argv[2]; s = open(p).read()
if 'RegistroProfissional' not in s:
    a = "import { FACULDADES, RESIDENCIAS } from '../lib/instituicoes.js';\n"
    b = "      </form>\n"
    assert a in s and s.count(b) == 1, 'Cadastro.tsx mudou'
    s = s.replace(a, a + "import { RegistroProfissional } from '../components/RegistroProfissional.js';\n", 1)
    s = s.replace(b, b + "      {st !== 'rascunho' && <RegistroProfissional />}\n", 1)
    open(p, 'w').write(s)
EOF
echo "PDF com marca d'agua e registro profissional: pronto"
