import { Router } from 'express';
import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Estudo dirigido: simulados sob medida e flashcards (oficiais, proprios e compartilhados por colegas).
// Nada aqui entra em nota ou ranking. As permissoes e os filtros de liberacao ficam no banco.
export const estudoRouter = Router();
const pessoa = (req: Request) => (req as Request & { pessoaId?: number }).pessoaId ?? null;
const REVISORES = ['admin', 'curador', 'data_steward'];

estudoRouter.use((req, res, next) => {
  if (!pessoa(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
});

const CONHECIDOS = ['proibido', 'sem_questoes', 'simulado_nao_encontrado', 'tema_nao_encontrado', 'tema_nao_liberado'];
function erro(err: unknown, res: Response, next: NextFunction) {
  const m = (err as { message?: string }).message ?? '';
  const k = CONHECIDOS.find((e) => m.includes(e));
  if (k) { res.status(k === 'proibido' ? 403 : 422).json({ erro: k }); return; }
  if (/flashcard_aluno_(frente|verso)_check|estudo_assinatura_apelido_check/.test(m)) { res.status(422).json({ erro: 'tamanho_invalido' }); return; }
  next(err);
}
const um = async (sql: string, params: unknown[] = []) =>
  withMaestro(null, async (c) => ((await c.query(sql, params)).rows[0] as { r: unknown } | undefined)?.r ?? null);
const id = (v: unknown) => (/^\d{1,15}$/.test(String(v)) ? String(v) : null);

estudoRouter.get('/opcoes', async (_req, res, next) => {
  try { res.json(await um('SELECT app.opcoes_estudo() AS r')); } catch (e) { erro(e, res, next); }
});

// ---------- simulados ----------
estudoRouter.post('/simulados', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const p = { temas: Array.isArray(b.temas) ? b.temas.map(String).slice(0, 200) : [], grau_min: Number(b.grau_min) || 1,
      grau_max: Number(b.grau_max) || 6, quantidade: Number(b.quantidade) || 10 };
    res.json(await um('SELECT app.montar_simulado($1::jsonb) AS r', [JSON.stringify(p)]));
  } catch (e) { erro(e, res, next); }
});
estudoRouter.get('/simulados/:id', async (req, res, next) => {
  try {
    const s = id(req.params.id) && await um('SELECT app.simulado_ver($1) AS r', [req.params.id]);
    if (!s) { res.status(404).json({ erro: 'simulado_nao_encontrado' }); return; }
    res.json(s);
  } catch (e) { erro(e, res, next); }
});
estudoRouter.post('/simulados/:id/entregar', async (req, res, next) => {
  try {
    if (!id(req.params.id)) { res.status(404).json({ erro: 'simulado_nao_encontrado' }); return; }
    const b = (req.body ?? {}) as { respostas?: Record<string, unknown>; segundos?: number };
    const limpas: Record<string, string> = {};
    for (const [k, v] of Object.entries(b.respostas ?? {})) if (id(k) && id(v)) limpas[k] = String(v);
    res.json(await um('SELECT app.entregar_simulado($1, $2::jsonb, $3) AS r', [req.params.id, JSON.stringify(limpas), Math.round(Number(b.segundos) || 0)]));
  } catch (e) { erro(e, res, next); }
});

// ---------- flashcards ----------
estudoRouter.post('/deck', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const p = { temas: Array.isArray(b.temas) ? b.temas.map(String).slice(0, 200) : [],
      fontes: Array.isArray(b.fontes) ? b.fontes.map(String).filter((f) => ['oficiais', 'meus', 'colegas'].includes(f)) : ['oficiais', 'meus', 'colegas'],
      quantidade: Number(b.quantidade) || 20, so_dificeis: b.so_dificeis === true };
    res.json({ cards: await um('SELECT app.montar_deck($1::jsonb) AS r', [JSON.stringify(p)]) });
  } catch (e) { erro(e, res, next); }
});
estudoRouter.post('/revisao', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as { chave?: string; acertou?: boolean };
    if (!/^(oficial:T-?\d{3}:\d{1,4}|aluno:\d{1,15})$/.test(String(b.chave))) { res.status(422).json({ erro: 'chave_invalida' }); return; }
    await um('SELECT app.revisar_card($1, $2) AS r', [b.chave, b.acertou === true]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
estudoRouter.get('/flashcards', async (_req, res, next) => {
  try { res.json({ cards: await um('SELECT app.meus_flashcards() AS r') }); } catch (e) { erro(e, res, next); }
});
estudoRouter.post('/flashcards', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const p = { id: b.id ? id(b.id) : null, tema: String(b.tema ?? ''), frente: String(b.frente ?? ''), verso: String(b.verso ?? ''), compartilhar: b.compartilhar === true };
    if (p.frente.trim().length < 3 || p.verso.trim().length < 1) { res.status(422).json({ erro: 'tamanho_invalido' }); return; }
    res.json({ ok: true, id: await um('SELECT app.salvar_flashcard($1::jsonb) AS r', [JSON.stringify(p)]) });
  } catch (e) { erro(e, res, next); }
});
estudoRouter.delete('/flashcards/:id', async (req, res, next) => {
  try { if (id(req.params.id)) await um('SELECT app.apagar_flashcard($1) AS r', [req.params.id]); res.json({ ok: true }); } catch (e) { erro(e, res, next); }
});
estudoRouter.post('/apelido', async (req, res, next) => {
  try { await um('SELECT app.salvar_apelido($1) AS r', [String((req.body as { apelido?: string })?.apelido ?? '').slice(0, 60)]); res.json({ ok: true }); } catch (e) { erro(e, res, next); }
});

// ---------- coordenacao: cards compartilhados (publicam sem revisao; aqui so da para ocultar depois) ----------
estudoRouter.get('/compartilhados', requireRole(REVISORES), async (_req, res, next) => {
  try { res.json({ cards: await um('SELECT app.flashcards_compartilhados() AS r') }); } catch (e) { erro(e, res, next); }
});
estudoRouter.post('/compartilhados/:id/ocultar', requireRole(REVISORES), async (req, res, next) => {
  try {
    if (!id(req.params.id)) { res.status(404).json({ erro: 'nao_encontrado' }); return; }
    await um('SELECT app.ocultar_flashcard($1, $2) AS r', [req.params.id, (req.body as { oculto?: boolean })?.oculto !== false]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
