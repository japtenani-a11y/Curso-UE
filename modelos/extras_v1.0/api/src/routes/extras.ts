import { Router } from 'express';
import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Interesse em pesquisa, repeticao espacada, certificado por modulo e coleta (tempo de leitura, confianca, aplicabilidade).
export const extrasRouter = Router();
const pessoa = (req: Request) => (req as Request & { pessoaId?: number }).pessoaId ?? null;
const REVISORES = ['admin', 'curador', 'data_steward'];
extrasRouter.use((req, res, next) => {
  if (!pessoa(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
});
const CONHECIDOS = ['proibido', 'tema_nao_encontrado', 'modulo_incompleto', 'modulo_nao_encontrado'];
function erro(err: unknown, res: Response, next: NextFunction) {
  const m = (err as { message?: string }).message ?? '';
  const k = CONHECIDOS.find((e) => m.includes(e));
  if (k) { res.status(k === 'proibido' ? 403 : 422).json({ erro: k }); return; }
  next(err);
}
const um = async (sql: string, params: unknown[] = []) =>
  withMaestro(null, async (c) => ((await c.query(sql, params)).rows[0] as { r: unknown } | undefined)?.r ?? null);
const cod = (v: unknown) => String(v ?? '').slice(0, 12);
const num = (v: unknown) => (/^\d{1,15}$/.test(String(v)) ? String(v) : null);

// ---------- interesse em pesquisa ----------
extrasRouter.get('/pesquisa/:tema', async (req, res, next) => {
  try { res.json({ itens: await um('SELECT app.meus_interesses_pesquisa($1) AS r', [cod(req.params.tema)]) }); } catch (e) { erro(e, res, next); }
});
extrasRouter.post('/pesquisa', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const ideia = Number(b.ideia);
    if (!Number.isInteger(ideia) || ideia < 1 || ideia > 10) { res.status(422).json({ erro: 'ideia_invalida' }); return; }
    const p = { tema: cod(b.tema), ideia, texto: String(b.texto ?? '').slice(0, 1000), mensagem: String(b.mensagem ?? '').slice(0, 2000),
      autoriza: b.autoriza === true, cancelar: b.cancelar === true };
    await um('SELECT app.registrar_interesse_pesquisa($1::jsonb) AS r', [JSON.stringify(p)]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
extrasRouter.get('/coordenacao/pesquisa', requireRole(REVISORES), async (_req, res, next) => {
  try { res.json({ itens: await um('SELECT app.interesses_pesquisa() AS r') }); } catch (e) { erro(e, res, next); }
});
extrasRouter.post('/coordenacao/pesquisa/:id', requireRole(REVISORES), async (req, res, next) => {
  try {
    if (!num(req.params.id)) { res.status(404).json({ erro: 'nao_encontrado' }); return; }
    const b = (req.body ?? {}) as Record<string, unknown>;
    const status = ['novo', 'em_contato', 'encaminhado', 'em_andamento', 'encerrado'].includes(String(b.status)) ? String(b.status) : undefined;
    await um('SELECT app.atualizar_interesse_pesquisa($1, $2::jsonb) AS r', [req.params.id,
      JSON.stringify({ status, orientador: b.orientador === undefined ? undefined : String(b.orientador), nota: b.nota === undefined ? undefined : String(b.nota) })]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
extrasRouter.post('/coordenacao/relevancia', requireRole(REVISORES), async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as { tema?: string; relevancia?: number };
    await um('SELECT app.definir_relevancia($1, $2) AS r', [cod(b.tema), Math.round(Number(b.relevancia) || 3)]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});

// ---------- repeticao espacada ----------
extrasRouter.get('/flashcards/devidos', async (_req, res, next) => {
  try { res.json(await um('SELECT app.flashcards_devidos() AS r')); } catch (e) { erro(e, res, next); }
});

// ---------- certificado por modulo ----------
extrasRouter.get('/modulos', async (_req, res, next) => {
  try { res.json({ modulos: await um('SELECT app.meus_modulos() AS r') }); } catch (e) { erro(e, res, next); }
});
extrasRouter.post('/certificado/modulo', async (req, res, next) => {
  try { res.json(await um('SELECT app.emitir_certificado_modulo($1) AS r', [String((req.body as { modulo?: string })?.modulo ?? '').slice(0, 120)])); }
  catch (e) { erro(e, res, next); }
});

// ---------- coleta ----------
extrasRouter.post('/leitura/tempo', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as { tema?: string; tipo?: string; segundos?: number };
    const s = Math.round(Number(b.segundos) || 0);
    if (s >= 3 && /^[a-z_0-9]{2,40}$/.test(String(b.tipo))) await um('SELECT app.registrar_tempo_leitura($1, $2, $3) AS r', [cod(b.tema), b.tipo, Math.min(s, 3600)]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
extrasRouter.get('/confianca/:onda', async (req, res, next) => {
  try { res.json({ pct: num(req.params.onda) ? await um('SELECT app.confianca_da_onda($1) AS r', [req.params.onda]) : null }); } catch (e) { erro(e, res, next); }
});
extrasRouter.post('/confianca/:onda', async (req, res, next) => {
  try {
    const pct = Math.round(Number((req.body as { pct?: number })?.pct));
    if (!num(req.params.onda) || !(pct >= 0 && pct <= 100)) { res.status(422).json({ erro: 'dados_invalidos' }); return; }
    await um('SELECT app.registrar_confianca($1, $2) AS r', [req.params.onda, pct]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
extrasRouter.get('/aplicabilidade', async (_req, res, next) => {
  try { res.json({ pendentes: await um('SELECT app.aplicabilidade_pendente() AS r') }); } catch (e) { erro(e, res, next); }
});
extrasRouter.post('/aplicabilidade', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const n = (v: unknown, a: number, z: number) => (v === null || v === undefined || v === '' ? null : Math.min(z, Math.max(a, Math.round(Number(v)))));
    const p = { tema: cod(b.tema), usou: n(b.usou, 0, 4), mudou_conduta: typeof b.mudou_conduta === 'boolean' ? b.mudou_conduta : null,
      confianca: n(b.confianca, 1, 5), exemplo: String(b.exemplo ?? '').slice(0, 1500), barreira: String(b.barreira ?? '').slice(0, 1500), dispensado: b.dispensado === true };
    await um('SELECT app.salvar_aplicabilidade($1::jsonb) AS r', [JSON.stringify(p)]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
