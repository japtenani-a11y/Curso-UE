import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';
import { chavePublica, pushConfigurado } from '../push_envio.js';

// Avisos no celular: chave publica, inscrever e cancelar um aparelho, e os textos pendentes (o aparelho busca ao
// receber o sinal).
export const pushRouter = Router();
const sessao = (req: unknown) => (req as { pessoaId?: number }).pessoaId;

pushRouter.get('/chave', (_req, res) => { res.json({ chave: pushConfigurado() ? chavePublica() : null }); });

pushRouter.post('/inscrever', async (req, res, next) => {
  try {
    if (!sessao(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const b = (req.body ?? {}) as { endpoint?: string; aparelho?: string };
    if (typeof b.endpoint !== 'string' || !/^https:\/\/\S{10,990}$/.test(b.endpoint)) { res.status(400).json({ erro: 'endpoint_invalido' }); return; }
    await withMaestro(null, async (c) => { await c.query('SELECT app.push_inscrever($1, $2)', [b.endpoint, String(b.aparelho ?? '').slice(0, 200)]); });
    res.json({ ok: true });
  } catch (e) { next(e); }
});

pushRouter.post('/cancelar', async (req, res, next) => {
  try {
    if (!sessao(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const b = (req.body ?? {}) as { endpoint?: string };
    await withMaestro(null, async (c) => { await c.query('SELECT app.push_cancelar($1)', [String(b.endpoint ?? '')]); });
    res.json({ ok: true });
  } catch (e) { next(e); }
});

pushRouter.get('/pendentes', async (req, res, next) => {
  try {
    if (!sessao(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const avisos = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.push_pendentes()')).rows);
    res.setHeader('Cache-Control', 'no-store');
    res.json({ avisos });
  } catch (e) { next(e); }
});
