import express, { Router } from 'express';
import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Mural (avisos, questionarios, documentos), presenca, certificado, agenda, preceptor, regras de aprovacao
// e resumo da coordenacao. As permissoes sao conferidas no banco (app.eh_revisor e afins).
export const comunidadeRouter = Router();
const pessoa = (req: Request) => (req as Request & { pessoaId?: number }).pessoaId ?? null;
const REVISORES = ['admin', 'curador', 'data_steward'];

comunidadeRouter.use((req, res, next) => {
  if (!pessoa(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
});

const ERROS_CONHECIDOS = ['proibido', 'questionario_fechado', 'codigo_invalido', 'codigo_expirado', 'sem_temas_concluidos', 'tema_nao_encontrado', 'respostas_grandes'];
function erro(err: unknown, res: Response, next: NextFunction) {
  const m = (err as { message?: string }).message ?? '';
  const p = /^pergunta:(\d+)$/.exec(m);
  if (p) { res.status(422).json({ erro: 'pergunta_obrigatoria', pergunta: Number(p[1]) }); return; }
  const k = ERROS_CONHECIDOS.find((e) => m.includes(e));
  if (k) { res.status(k === 'proibido' ? 403 : 422).json({ erro: k }); return; }
  next(err);
}
const q = async <T = Record<string, unknown>>(sql: string, params: unknown[] = []) =>
  withMaestro(null, async (c) => (await c.query(sql, params)).rows as T[]);

// ---------- mural ----------
comunidadeRouter.get('/mural', async (_req, res, next) => {
  try { res.json({ itens: (await q<{ l: unknown }>('SELECT app.mural_lista() AS l'))[0]?.l ?? [] }); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/mural', requireRole(REVISORES), async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    if (!['aviso', 'questionario', 'documento'].includes(String(b.tipo)) || String(b.titulo ?? '').trim().length < 3) {
      res.status(422).json({ erro: 'dados_invalidos' }); return;
    }
    const id = (await q<{ id: string }>('SELECT app.mural_salvar($1::jsonb) AS id', [JSON.stringify(b)]))[0]?.id;
    res.json({ ok: true, id });
  } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/mural/:id/arquivo', requireRole(REVISORES), express.raw({ type: () => true, limit: '10mb' }), async (req, res, next) => {
  try {
    const nome = String(req.query.nome ?? 'documento').replace(/[^\p{L}\p{N} ._()-]/gu, '').slice(0, 150) || 'documento';
    const tipo = String(req.get('content-type') ?? 'application/octet-stream').slice(0, 100);
    if (!Buffer.isBuffer(req.body) || req.body.length === 0) { res.status(422).json({ erro: 'arquivo_vazio' }); return; }
    await q('SELECT app.mural_arquivo($1, $2, $3, $4)', [Number(req.params.id), nome, tipo, req.body]);
    res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/mural/:id/arquivo', async (req, res, next) => {
  try {
    const a = (await q<{ nome: string; tipo: string; dados: Buffer | null }>('SELECT * FROM app.mural_baixar($1)', [Number(req.params.id)]))[0];
    if (!a?.dados) { res.status(404).json({ erro: 'sem_arquivo' }); return; }
    res.setHeader('Content-Type', a.tipo || 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename*=UTF-8''${encodeURIComponent(a.nome || 'documento')}`);
    res.setHeader('Cache-Control', 'private, no-store');
    res.send(a.dados);
  } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/mural/:id/ler', async (req, res, next) => {
  try { await q('SELECT app.mural_ler($1)', [Number(req.params.id)]); res.json({ ok: true }); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/mural/:id/responder', async (req, res, next) => {
  try { await q('SELECT app.mural_responder($1, $2::jsonb)', [Number(req.params.id), JSON.stringify(req.body?.respostas ?? {})]); res.json({ ok: true }); }
  catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/mural/:id/respostas', requireRole(REVISORES), async (req, res, next) => {
  try { res.json({ respostas: await q('SELECT * FROM app.mural_respostas($1)', [Number(req.params.id)]) }); } catch (e) { erro(e, res, next); }
});

// ---------- presenca ----------
comunidadeRouter.post('/presenca/codigo', requireRole(REVISORES), async (req, res, next) => {
  try { res.json((await q<{ c: unknown }>('SELECT app.gerar_codigo_presenca($1) AS c', [String(req.body?.tema ?? '')]))[0]?.c); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/presenca/resgatar', async (req, res, next) => {
  try { res.json({ ok: true, ...((await q<{ r: object }>('SELECT app.resgatar_presenca($1) AS r', [String(req.body?.texto ?? '').slice(0, 300)]))[0]?.r ?? {}) }); }
  catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/presenca/meet', requireRole(REVISORES), async (req, res, next) => {
  try {
    const linhas = Array.isArray(req.body?.linhas) ? (req.body.linhas as unknown[]).slice(0, 2000) : [];
    res.json((await q<{ r: unknown }>('SELECT app.importar_presenca_meet($1, $2::jsonb) AS r', [String(req.body?.tema ?? ''), JSON.stringify(linhas)]))[0]?.r);
  } catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/presenca/minhas', async (_req, res, next) => {
  try { res.json({ presencas: (await q<{ p: unknown }>('SELECT app.minhas_presencas() AS p'))[0]?.p ?? [] }); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/presenca/tema/:tema', requireRole(REVISORES), async (req, res, next) => {
  try { res.json((await q<{ l: unknown }>('SELECT app.lista_presenca($1) AS l', [String(req.params.tema)]))[0]?.l ?? {}); } catch (e) { erro(e, res, next); }
});

// ---------- aproveitamento e certificado ----------
comunidadeRouter.get('/aproveitamento', async (_req, res, next) => {
  try { res.json((await q<{ a: unknown }>('SELECT app.meu_aproveitamento() AS a'))[0]?.a ?? {}); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/certificado', async (_req, res, next) => {
  try { res.json((await q<{ c: unknown }>('SELECT app.emitir_certificado() AS c'))[0]?.c); } catch (e) { erro(e, res, next); }
});

// ---------- agenda (.ics) ----------
comunidadeRouter.get('/agenda/link', async (_req, res, next) => {
  try {
    const token = (await q<{ t: string }>('SELECT app.meu_token_agenda() AS t'))[0]?.t;
    const meet = (await q<{ m: string }>("SELECT app.config('link_meet') AS m"))[0]?.m;
    res.json({ token, meet });
  } catch (e) { erro(e, res, next); }
});

// ---------- coordenacao ----------
comunidadeRouter.get('/coordenacao/resumo', requireRole(REVISORES), async (_req, res, next) => {
  try { res.json((await q<{ r: unknown }>('SELECT app.resumo_coordenacao() AS r'))[0]?.r ?? {}); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/regras', requireRole(REVISORES), async (_req, res, next) => {
  try { res.json({ regras: (await q<{ r: unknown }>('SELECT app.regras_aprovacao() AS r'))[0]?.r ?? [] }); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/regras', requireRole(REVISORES), async (req, res, next) => {
  try {
    const lista = (v: unknown) => String(v ?? '').split(/[\s,;]+/).map((x) => x.trim()).filter(Boolean).slice(0, 5000);
    const n = (await q<{ n: number }>('SELECT app.salvar_regras_aprovacao($1::text[], $2::text[]) AS n', [lista(req.body?.dominios), lista(req.body?.emails)]))[0]?.n;
    res.json({ ok: true, regras: n });
  } catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/preceptores', requireRole(REVISORES), async (_req, res, next) => {
  try { res.json({ preceptores: (await q<{ p: unknown }>('SELECT app.preceptores() AS p'))[0]?.p ?? [] }); } catch (e) { erro(e, res, next); }
});
comunidadeRouter.post('/preceptores/vinculo', requireRole(REVISORES), async (req, res, next) => {
  try {
    const aluno = Number(req.body?.aluno); const prec = req.body?.preceptor ? Number(req.body.preceptor) : null;
    if (!Number.isInteger(aluno)) { res.status(400).json({ erro: 'parametros_invalidos' }); return; }
    await q('SELECT app.definir_preceptor($1, $2)', [aluno, prec]); res.json({ ok: true });
  } catch (e) { erro(e, res, next); }
});
comunidadeRouter.get('/preceptor/residentes', requireRole(['docente', 'preceptor', 'admin']), async (_req, res, next) => {
  try { res.json({ residentes: (await q<{ r: unknown }>('SELECT app.meus_residentes() AS r'))[0]?.r ?? [] }); } catch (e) { erro(e, res, next); }
});
