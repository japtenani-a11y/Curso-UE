import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Duvidas dos alunos para a coordenacao: o curador le, avalia e grava a resposta.
// O aluno recebe a resposta na tela "Duvidas" e, se autorizou, por e-mail (fila do notificador).
export const curadoriaRouter = Router();
curadoriaRouter.use(requireRole(['admin', 'curador', 'data_steward']));

curadoriaRouter.get('/duvidas', async (req, res, next) => {
  try {
    const soPendentes = req.query.todas !== '1';
    const duvidas = await withMaestro(null, async (c) =>
      (await c.query('SELECT * FROM app.duvidas_para_curadoria($1)', [soPendentes])).rows);
    res.json({ duvidas });
  } catch (err) { next(err); }
});

curadoriaRouter.post('/duvidas/:id/resposta', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const texto = String((req.body as { resposta?: string } | undefined)?.resposta ?? '').trim().slice(0, 8000);
    if (!Number.isInteger(id) || id <= 0) { res.status(400).json({ erro: 'parametros_invalidos' }); return; }
    if (texto.length < 3) { res.status(422).json({ erro: 'resposta_curta' }); return; }
    await withMaestro(null, async (c) => { await c.query('SELECT app.responder_duvida($1, $2)', [id, texto]); });
    res.json({ ok: true });
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    if (m.includes('duvida_nao_encontrada')) { res.status(404).json({ erro: 'duvida_nao_encontrada' }); return; }
    next(err);
  }
});
