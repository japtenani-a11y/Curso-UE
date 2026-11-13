import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Inscricoes dos alunos: a coordenacao aprova ou recusa (o aluno recebe e-mail).
export const inscricoesRouter = Router();
inscricoesRouter.use(requireRole(['admin', 'curador', 'data_steward']));

inscricoesRouter.get('/', async (req, res, next) => {
  try {
    const status = ['pendente', 'aprovado', 'recusado', 'rascunho', 'todas'].includes(String(req.query.status)) ? String(req.query.status) : 'pendente';
    const lista = await withMaestro(null, async (c) => (await c.query('SELECT app.inscricoes($1) AS l', [status])).rows[0]?.l ?? []);
    res.json({ inscricoes: lista });
  } catch (err) { next(err); }
});

inscricoesRouter.post('/:id/decisao', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const b = (req.body ?? {}) as { aprovar?: boolean; motivo?: string };
    if (!Number.isInteger(id) || id <= 0 || typeof b.aprovar !== 'boolean') { res.status(400).json({ erro: 'parametros_invalidos' }); return; }
    const status = await withMaestro(null, async (c) => (await c.query(
      'SELECT app.decidir_inscricao($1, $2, $3) AS s', [id, b.aprovar, String(b.motivo ?? '').slice(0, 1000)])).rows[0]?.s);
    res.json({ ok: true, status });
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    if (m.includes('inscricao_nao_encontrada')) { res.status(404).json({ erro: 'inscricao_nao_encontrada' }); return; }
    next(err);
  }
});
