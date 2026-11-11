#!/usr/bin/env bash
# ============================================================
# 28_executor_modelo_verificadores_v1.0.sh
# Executor chama o modelo (API Anthropic) e o gate de evidencia aplica 3 verificadores:
#   1) citacao literal na fonte  2) numero presente no trecho citado  3) PMID/DOI existe, confere e nao foi retratado
# Reprovado => nada e gravado e o job tenta de novo (limite do ciclo). Aprovado => artefato 'rascunho'.
# USO: bash 28_executor_modelo_verificadores_v1.0.sh ./programa-cut
# PRE-REQUISITOS: 22b_patch_executor_v1.1, 28_texto_integral_fontes_v1.0.sql
# ENV do executor: ANTHROPIC_API_KEY, ANTHROPIC_MODEL
# Payload do job: {"tipo":"<tipo do artefato>","titulo":"..."}; fontes com texto_integral no tema.
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
[ -d "$RAIZ/executor/src/maestro" ] || { echo "ERRO: rode 17 e 22b antes"; exit 1; }
M="$RAIZ/executor/src/maestro"; mkdir -p "$RAIZ/executor/test"
cat > "$M/verificadores.ts" <<'EOF_verificadores'
// Verificadores deterministicos. Sem dependencias externas; a rede entra por injecao (Buscador).

export interface Resultado {
  ok: boolean;
  motivo?: string;
}

export function normalizar(t: string): string {
  return t
    .normalize('NFKC')
    .replace(/[­​]/g, '')
    .replace(/-\s*\n\s*/g, '')
    .replace(/[‘’‚]/g, "'")
    .replace(/[“”„]/g, '"')
    .replace(/[‐-―−]/g, '-')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}

// 1) Citacao literal: o trecho deve existir, apos normalizacao, no texto da fonte.
export function verificarCitacaoLiteral(trecho: string, fonte: string, minimo = 25): Resultado {
  const t = normalizar(trecho).replace(/^\.\.\.|\.\.\.$|^…|…$/g, '').trim();
  if (t.length < minimo) return { ok: false, motivo: `trecho curto demais (${t.length} < ${minimo})` };
  if (!normalizar(fonte).includes(t)) return { ok: false, motivo: 'trecho nao encontrado na fonte' };
  return { ok: true };
}

// 2) Numeros: todo numero da afirmacao deve aparecer no trecho citado (ou na fonte, se fornecida).
const RE_NUM = /(?<![\w.,])\d+(?:[.,]\d+)?(?![\w])/g;

export function extrairNumeros(t: string): string[] {
  const n = normalizar(t).replace(/\b(?:19|20)\d{2}\b/g, ' ');
  return [...new Set((n.match(RE_NUM) ?? []).map(canonico))];
}

function canonico(n: string): string {
  const v = n.replace(',', '.');
  return v.includes('.') ? v.replace(/0+$/, '').replace(/\.$/, '') : v;
}

export function verificarNumerosNaFonte(afirmacao: string, texto: string): Resultado {
  const faltando = extrairNumeros(afirmacao).filter((n) => !extrairNumeros(texto).includes(n));
  return faltando.length ? { ok: false, motivo: `numeros ausentes da fonte: ${faltando.join(', ')}` } : { ok: true };
}

// 3) PMID/DOI: existe, bate com o titulo e nao foi retratado.
export interface RegistroBib {
  existe: boolean;
  titulo?: string;
  retratado?: boolean;
}
export type Buscador = (id: { pmid?: string; doi?: string }) => Promise<RegistroBib>;

export function extrairIds(t: string): { pmids: string[]; dois: string[] } {
  const dois = [...new Set((t.match(/10\.\d{4,9}\/[^\s"<>]+/g) ?? []).map((d) => d.replace(/[.,;)\]]+$/, '').toLowerCase()))];
  const pmids = [...new Set([...t.matchAll(/pmid[:\s]*([0-9]{5,9})/gi)].map((m) => m[1]!))];
  return { pmids, dois };
}

function palavras(t: string): Set<string> {
  return new Set(normalizar(t).split(/[^a-z0-9]+/).filter((w) => w.length > 3));
}

export async function verificarPmidDoi(
  ref: { pmid?: string; doi?: string; titulo?: string },
  buscar: Buscador,
): Promise<Resultado> {
  if (!ref.pmid && !ref.doi) return { ok: false, motivo: 'sem PMID nem DOI' };
  const r = await buscar({ pmid: ref.pmid, doi: ref.doi });
  if (!r.existe) return { ok: false, motivo: 'PMID/DOI nao encontrado' };
  if (r.retratado) return { ok: false, motivo: 'artigo retratado' };
  if (ref.titulo && r.titulo) {
    const a = palavras(ref.titulo);
    const b = palavras(r.titulo);
    const comuns = [...a].filter((w) => b.has(w)).length;
    if (a.size && comuns / a.size < 0.5) return { ok: false, motivo: 'titulo nao confere com o registro' };
  }
  return { ok: true };
}

// Buscador real (NCBI esummary + Crossref). Exige rede; usado so no executor.
export const buscadorReal: Buscador = async ({ pmid, doi }) => {
  if (pmid) {
    const res = await fetch(`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=${pmid}&retmode=json`);
    if (!res.ok) throw new Error(`NCBI HTTP ${res.status}`);
    const j: any = await res.json();
    const d = j?.result?.[pmid];
    if (!d || d.error) return { existe: false };
    const tipos: string[] = (d.pubtype ?? []).map((x: string) => x.toLowerCase());
    return { existe: true, titulo: d.title, retratado: tipos.some((x) => x.includes('retracted')) };
  }
  const res = await fetch(`https://api.crossref.org/works/${encodeURIComponent(doi!)}`);
  if (res.status === 404) return { existe: false };
  if (!res.ok) throw new Error(`Crossref HTTP ${res.status}`);
  const m: any = (await res.json()).message;
  const upd = JSON.stringify(m?.relation ?? {}) + JSON.stringify(m?.['update-to'] ?? []);
  return { existe: true, titulo: (m?.title ?? [])[0], retratado: /retract/i.test(upd) };
};
EOF_verificadores
cat > "$M/modelo.ts" <<'EOF_modelo'
export interface RespostaModelo {
  texto: string;
  modelo: string;
  tokensEntrada: number;
  tokensSaida: number;
}

export async function chamarModelo(p: {
  system: string;
  user: string;
  maxTokens?: number;
  temperatura?: number; // ignorado: modelos recentes nao aceitam temperature
}): Promise<RespostaModelo> {
  const chave = process.env.ANTHROPIC_API_KEY;
  const modelo = process.env.ANTHROPIC_MODEL;
  if (!chave || !modelo) throw new Error('ANTHROPIC_API_KEY e ANTHROPIC_MODEL precisam estar definidos');
  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-api-key': chave, 'anthropic-version': '2023-06-01' },
    body: JSON.stringify({
      model: modelo,
      max_tokens: p.maxTokens ?? 4096,
      system: p.system,
      messages: [{ role: 'user', content: p.user }],
    }),
  });
  if (!res.ok) throw new Error(`API do modelo HTTP ${res.status}: ${(await res.text()).slice(0, 300)}`);
  const j: any = await res.json();
  const texto = (j.content ?? []).filter((b: any) => b.type === 'text').map((b: any) => b.text).join('');
  return { texto, modelo: j.model ?? modelo, tokensEntrada: j.usage?.input_tokens ?? 0, tokensSaida: j.usage?.output_tokens ?? 0 };
}
EOF_modelo
cat > "$M/avaliar.ts" <<'EOF_avaliar'
import { verificarCitacaoLiteral, verificarNumerosNaFonte, verificarPmidDoi, type Buscador } from './verificadores.js';

export interface FonteDB { fonte_id: number; titulo: string; doi: string | null; pmid: string | null; texto_integral: string | null; }
export interface Afirmacao { texto: string; fonte_id: number; trecho_literal: string; }
export interface Falha { indice: number; verificador: 'citacao' | 'numero' | 'pmid_doi' | 'fonte'; motivo: string; critico: boolean; }

// Extrai o JSON de saida do modelo ({corpo, afirmacoes:[...]}), tolerando cerca ```json.
export function lerSaida(txt: string): { corpo: string; afirmacoes: Afirmacao[] } {
  const m = txt.match(/\{[\s\S]*\}/);
  if (!m) throw new Error('saida do modelo sem JSON');
  const j = JSON.parse(m[0]);
  if (typeof j.corpo !== 'string' || !Array.isArray(j.afirmacoes)) throw new Error('JSON sem corpo/afirmacoes');
  return j;
}

export async function avaliarAfirmacoes(afs: Afirmacao[], fontes: FonteDB[], buscar: Buscador) {
  const falhas: Falha[] = [];
  const porId = new Map(fontes.map((f) => [f.fonte_id, f]));
  const biblio = new Map<number, Awaited<ReturnType<typeof verificarPmidDoi>>>();
  for (const [i, a] of afs.entries()) {
    const f = porId.get(a.fonte_id);
    if (!f || !f.texto_integral) { falhas.push({ indice: i, verificador: 'fonte', motivo: 'fonte inexistente ou sem texto', critico: true }); continue; }
    const c = verificarCitacaoLiteral(a.trecho_literal, f.texto_integral);
    if (!c.ok) falhas.push({ indice: i, verificador: 'citacao', motivo: c.motivo!, critico: true });
    const n = verificarNumerosNaFonte(a.texto, a.trecho_literal);
    if (!n.ok) falhas.push({ indice: i, verificador: 'numero', motivo: n.motivo!, critico: true });
    if (!biblio.has(f.fonte_id)) biblio.set(f.fonte_id, await verificarPmidDoi({ pmid: f.pmid ?? undefined, doi: f.doi ?? undefined, titulo: f.titulo }, buscar));
    const b = biblio.get(f.fonte_id)!;
    if (!b.ok) falhas.push({ indice: i, verificador: 'pmid_doi', motivo: b.motivo!, critico: false });
  }
  return { aprovado: falhas.length === 0 && afs.length > 0, total: afs.length, falhas };
}
EOF_avaliar
cat > "$M/motor.ts" <<'EOF_motor'
import { pool } from './pool.js';
import { logger } from './logger.js';
import { chamarModelo } from './modelo.js';
import { avaliarGates } from './gate.js';
import { lerSaida } from './avaliar.js';

interface Job {
  job_id: number;
  tema_id: number | null;
  fase: string;
  skill_codigo: string;
  payload: unknown;
}

export async function executarJob(job: Job): Promise<void> {
  const inicio = Date.now();
  if (job.tema_id == null) throw new Error('job sem tema_id');
  const payload = (job.payload ?? {}) as { tipo?: string; titulo?: string };
  if (!payload.tipo) throw new Error('payload.tipo ausente (tipo do artefato a gerar)');

  const { rows: pr } = await pool.query(
    `SELECT conteudo, max_tokens, temperatura FROM conteudo.prompt WHERE skill_codigo = $1 ORDER BY prompt_id LIMIT 1`,
    [job.skill_codigo],
  );
  const prompt = pr[0];
  if (!prompt) throw new Error(`prompt nao encontrado para a skill ${job.skill_codigo}`);

  const { rows: fontes } = await pool.query(
    `SELECT fonte_id, titulo, doi, pmid, texto_integral FROM conteudo.fonte WHERE tema_id = $1 AND texto_integral IS NOT NULL ORDER BY fonte_id`,
    [job.tema_id],
  );
  if (fontes.length === 0) throw new Error('tema sem fontes com texto integral (conteudo.fonte.texto_integral)');

  const contrato =
    'Responda SOMENTE com JSON: {"corpo": "<texto do artefato>", "afirmacoes": [{"texto": "<afirmacao clinica ou numero usado>", ' +
    '"fonte_id": <id>, "trecho_literal": "<trecho copiado sem alteracao da fonte que sustenta a afirmacao>"}]}. ' +
    'Toda afirmacao clinica e todo numero do corpo deve constar em afirmacoes. Use apenas as fontes fornecidas. Sem trecho literal, nao afirme.';
  const user =
    `FONTES:\n` + fontes.map((f: any) => `[fonte_id=${f.fonte_id}] ${f.titulo}\n${f.texto_integral}`).join('\n\n---\n\n') +
    `\n\nTAREFA (${payload.tipo}):\n${JSON.stringify(job.payload)}`;

  const r = await chamarModelo({
    system: prompt.conteudo + '\n\n' + contrato,
    user,
    maxTokens: prompt.max_tokens ?? 8000,
    temperatura: prompt.temperatura ?? 0.2,
  });

  await pool.query(
    `INSERT INTO maestro.execucao_motor (job_id, tema_id, fase, skill_codigo, modelo, tokens_entrada, tokens_saida, duracao_ms)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
    [job.job_id, job.tema_id, job.fase, job.skill_codigo, r.modelo, r.tokensEntrada, r.tokensSaida, Date.now() - inicio],
  );

  const saida = lerSaida(r.texto);
  const aprovado = await avaliarGates(job, saida.afirmacoes, fontes);
  if (!aprovado) throw new Error('gate de evidencia reprovou o artefato; nada foi gravado');

  await pool.query(
    `INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
     SELECT $1, $2, COALESCE(MAX(versao),0)+1, 'rascunho', $3, $4, true FROM conteudo.artefato WHERE tema_id=$1 AND tipo=$2`,
    [job.tema_id, payload.tipo, payload.titulo ?? payload.tipo, saida.corpo],
  );
  logger.info({ job_id: job.job_id, afirmacoes: saida.afirmacoes.length }, 'artefato gerado como rascunho');
}
EOF_motor
cat > "$M/gate.ts" <<'EOF_gate'
import { pool } from './pool.js';
import { logger } from './logger.js';
import { avaliarAfirmacoes, type Afirmacao, type FonteDB } from './avaliar.js';
import { buscadorReal } from './verificadores.js';

interface Job { job_id: number; skill_codigo: string; }

// Gate de evidencia: citacao literal + numero na fonte + PMID/DOI. Retorna true se aprovado.
export async function avaliarGates(job: Job, afirmacoes: Afirmacao[], fontes: FonteDB[]): Promise<boolean> {
  let r;
  try {
    r = await avaliarAfirmacoes(afirmacoes, fontes, buscadorReal);
  } catch (err) {
    // rede indisponivel nao pode aprovar nem reprovar: registra e deixa o job tentar de novo
    await pool.query(
      `INSERT INTO maestro.gate_resultado (job_id, gate_codigo, estado, detalhe) VALUES ($1,'G_EVIDENCIA','ignorado',$2)`,
      [job.job_id, `verificacao indisponivel: ${err instanceof Error ? err.message : String(err)}`],
    );
    throw err;
  }
  await pool.query(
    `INSERT INTO maestro.gate_resultado (job_id, gate_codigo, estado, detalhe) VALUES ($1,'G_EVIDENCIA',$2,$3)`,
    [job.job_id, r.aprovado ? 'aprovado' : 'reprovado', JSON.stringify({ total: r.total, falhas: r.falhas })],
  );
  logger.info({ job_id: job.job_id, aprovado: r.aprovado, falhas: r.falhas.length }, 'gate de evidencia');
  return r.aprovado;
}
EOF_gate
cat > "$RAIZ/executor/test/verificadores.test.ts" <<'EOF_t'
import test from 'node:test';
import assert from 'node:assert/strict';
import { verificarCitacaoLiteral, verificarNumerosNaFonte, verificarPmidDoi, extrairIds, extrairNumeros } from '../src/maestro/verificadores.js';
import { avaliarAfirmacoes, lerSaida } from '../src/maestro/avaliar.js';

const FONTE = 'Patients with hypotension\n(systolic blood pressure <90 mmHg) received 1:1:1 ratio, mortality 12.7% vs 17.0% (p=0.03). Hemor-\nrhage control was key.';

test('citacao literal aceita variacao de espaco/hifenizacao/caixa', () => {
  assert.ok(verificarCitacaoLiteral('HEMORRHAGE control was key.', FONTE, 10).ok);
  assert.ok(verificarCitacaoLiteral('mortality 12.7% vs 17.0% (p=0.03)', FONTE).ok);
});
test('citacao inventada ou curta reprova', () => {
  assert.equal(verificarCitacaoLiteral('mortality 9.0% vs 17.0% (p=0.03)', FONTE).ok, false);
  assert.equal(verificarCitacaoLiteral('key', FONTE).ok, false);
});
test('numeros: virgula decimal e anos ignorados', () => {
  assert.deepEqual(extrairNumeros('queda de 12,7% em 2015'), ['12.7']);
  assert.ok(verificarNumerosNaFonte('mortalidade 12,7% vs 17%', 'mortality 12.7% vs 17.0%').ok);
});
test('numero ausente reprova', () => {
  const r = verificarNumerosNaFonte('mortalidade 15%', 'mortality 12.7% vs 17.0%');
  assert.equal(r.ok, false); assert.match(r.motivo!, /15/);
});
test('ids extraidos', () => {
  const r = extrairIds('doi:10.1001/jama.2015.2.  PMID: 25647203');
  assert.deepEqual(r.dois, ['10.1001/jama.2015.2']); assert.deepEqual(r.pmids, ['25647203']);
});
test('pmid/doi: inexistente, retratado, titulo trocado, ok, sem id', async () => {
  const mk = (x: any) => async () => x;
  assert.equal((await verificarPmidDoi({ pmid: '1' }, mk({ existe: false }))).ok, false);
  assert.match((await verificarPmidDoi({ pmid: '1' }, mk({ existe: true, retratado: true }))).motivo!, /retratado/);
  assert.match((await verificarPmidDoi({ pmid: '1', titulo: 'Transfusion ratios in trauma' }, mk({ existe: true, titulo: 'Cardiac surgery outcomes' }))).motivo!, /titulo/);
  assert.ok((await verificarPmidDoi({ pmid: '1', titulo: 'Transfusion ratios in trauma' }, mk({ existe: true, titulo: 'Transfusion ratios in severe trauma' }))).ok);
  assert.equal((await verificarPmidDoi({}, mk({ existe: true }))).ok, false);
});
test('avaliacao ponta a ponta', async () => {
  const fontes = [{ fonte_id: 1, titulo: 'Transfusion ratios in trauma', doi: null, pmid: '1', texto_integral: FONTE }];
  const buscar = async () => ({ existe: true, titulo: 'Transfusion ratios in trauma' });
  const bom = await avaliarAfirmacoes([{ texto: 'Mortalidade 12,7% vs 17,0%', fonte_id: 1, trecho_literal: 'mortality 12.7% vs 17.0% (p=0.03)' }], fontes, buscar);
  assert.ok(bom.aprovado);
  const ruim = await avaliarAfirmacoes([{ texto: 'Mortalidade 11%', fonte_id: 1, trecho_literal: 'mortality 12.7% vs 17.0% (p=0.03)' }, { texto: 'x', fonte_id: 9, trecho_literal: 'y' }], fontes, buscar);
  assert.equal(ruim.aprovado, false); assert.equal(ruim.falhas.length, 2);
  assert.equal((await avaliarAfirmacoes([], fontes, buscar)).aprovado, false);
});
test('lerSaida tolera cerca de codigo', () => {
  assert.equal(lerSaida('```json\n{"corpo":"a","afirmacoes":[]}\n```').corpo, 'a');
  assert.throws(() => lerSaida('sem json'));
});
EOF_t
echo "OK. Teste: cd $RAIZ/executor && npx tsc && node --test dist/test/"
