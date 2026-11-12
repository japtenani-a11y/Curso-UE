// Responde as duvidas dos alunos com IA, usando so o material do tema como base.
// Uso: npm run respondedor   (fica rodando; a cada minuto pega ate 5 duvidas novas)
// Precisa de ANTHROPIC_API_KEY no ambiente (nunca em arquivo do repositorio). Sem a chave, as duvidas
// ficam na fila ate a chave ser configurada. Modelo: ANTHROPIC_MODEL (padrao claude-sonnet-5-5).
import { withMaestro } from './db/transaction.js';
import { logger } from './db/logger.js';

interface Duvida { mensagem_id: number; texto: string; ferramenta: string | null; tema: string | null; titulo: string | null; material: string | null }

const CHAVE = process.env.ANTHROPIC_API_KEY ?? '';
const MODELO = process.env.ANTHROPIC_MODEL ?? 'claude-sonnet-5-5';

const SISTEMA = `Você é o tutor do Programa de Cirurgia de Urgência e Trauma do HCFMRP-USP. Responda em português do Brasil,
de forma direta e didática, em até 250 palavras, a dúvida de um aluno (graduação ou residência) sobre o tema indicado.
Use SOMENTE o material do tema fornecido. Cite entre colchetes os códigos das afirmações que sustentam a resposta
(por exemplo [D2], [A13], [P6], [G5]). Se a resposta não estiver no material, diga isso claramente e sugira levar a
pergunta ao preceptor na reunião. Não oriente conduta para paciente real identificado; se a pergunta for sobre um caso
real em andamento, diga que deve ser discutido com o preceptor de plantão. Não invente números, doses ou referências.`;

async function responder(d: Duvida): Promise<string> {
  const material = (d.material ?? '').slice(0, 120_000) || '(sem material disponível para este tema)';
  const r = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: { 'x-api-key': CHAVE, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
    body: JSON.stringify({
      model: MODELO, max_tokens: 900, system: SISTEMA,
      messages: [{ role: 'user', content: `Tema: ${d.tema ?? 'não informado'} — ${d.titulo ?? ''}\nPeça em que surgiu a dúvida: ${d.ferramenta ?? 'não informada'}\n\n<material>\n${material}\n</material>\n\nDúvida do aluno:\n${d.texto}` }],
    }),
  });
  if (!r.ok) throw new Error(`API respondeu ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const j = await r.json() as { content?: { type: string; text?: string }[] };
  const texto = (j.content ?? []).filter((c) => c.type === 'text').map((c) => c.text ?? '').join('\n').trim();
  if (!texto) throw new Error('resposta vazia');
  return `${texto}\n\n— Resposta gerada por IA com base no material do tema; confira com o preceptor.`;
}

async function rodada(): Promise<number> {
  if (!CHAVE) return 0;
  const lista = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.duvidas_reservar(5)')).rows as Duvida[]);
  for (const d of lista) {
    let ok = true; let texto = '';
    try { texto = await responder(d); } catch (e) { ok = false; logger.warn({ mensagem: d.mensagem_id, erro: e instanceof Error ? e.message : String(e) }, 'falha ao responder duvida'); }
    await withMaestro(null, async (c) => { await c.query('SELECT app.duvida_responder($1, $2, $3, $4)', [d.mensagem_id, texto, MODELO, ok]); });
  }
  return lista.length;
}

async function principal(): Promise<void> {
  logger.info({ modelo: MODELO, chave_configurada: Boolean(CHAVE) }, 'respondedor de duvidas iniciado');
  const umaVez = process.argv.includes('--uma-vez');
  for (;;) {
    try { const n = await rodada(); if (n) logger.info({ respondidas: n }, 'rodada de duvidas'); }
    catch (e) { logger.error({ erro: e instanceof Error ? e.message : String(e) }, 'rodada de duvidas falhou'); }
    if (umaVez) break;
    await new Promise((r) => setTimeout(r, 60_000));
  }
  process.exit(0);
}
principal();
