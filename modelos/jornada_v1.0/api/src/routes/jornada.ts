import { Router } from 'express';
import type { Request } from 'express';
import { withMaestro } from '../db/transaction.js';

// Jornada do aluno: tela do tema (etapas, testes, material), calendario de aulas e pendencias.
export const jornadaRouter = Router();
const pessoa = (req: Request) => (req as Request & { pessoaId?: number }).pessoaId ?? null;

jornadaRouter.use((req, res, next) => {
  if (!pessoa(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
});

jornadaRouter.get('/temas/:codigo', async (req, res, next) => {
  try {
    const codigo = String(req.params.codigo).slice(0, 12);
    const tema = await withMaestro(null, async (c) =>
      (await c.query('SELECT app.jornada_tema($1) AS j', [codigo])).rows[0]?.j ?? null);
    if (!tema) { res.status(404).json({ erro: 'tema_nao_encontrado' }); return; }
    res.json(tema);
  } catch (err) { next(err); }
});

jornadaRouter.get('/calendario', async (_req, res, next) => {
  try {
    const aulas = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.calendario_aulas()')).rows);
    res.json({ aulas });
  } catch (err) { next(err); }
});

jornadaRouter.get('/pendencias', async (_req, res, next) => {
  try {
    const pendencias = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.pendencias()')).rows);
    res.json({ pendencias });
  } catch (err) { next(err); }
});
