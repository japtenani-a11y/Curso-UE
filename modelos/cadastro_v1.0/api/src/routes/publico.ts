import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

// Paginas publicas (sem login): textos vigentes da politica de privacidade e dos termos.
export const publicoRouter = Router();

publicoRouter.get('/termos', async (_req, res, next) => {
  try {
    const termos = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.termos_publicos()')).rows);
    res.setHeader('Cache-Control', 'public, max-age=300');
    res.json({ termos });
  } catch (err) { next(err); }
});
