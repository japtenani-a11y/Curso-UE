import { Router } from 'express';
import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';

// Perfil da sessao (trocar entre as funcoes que a pessoa tem) e funcoes da equipe (so administrador).
export const perfilRouter = Router();
type Req = Request & { pessoaId?: number; papel?: string };
const token = (req: Request) => req.cookies?.sessao as string | undefined;
function exigirSessao(req: Request, res: Response, next: NextFunction) {
  if (!(req as Req).pessoaId || !token(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
}
// Erros de regra do banco (sem acesso, funcao invalida, ultimo administrador) vao como 403/422 com o codigo.
function erroDoBanco(err: unknown, res: Response, next: NextFunction) {
  const m = String((err as { message?: string }).message ?? '');
  const cod = ['so_administrador', 'papel_nao_atribuido', 'sessao_invalida', 'funcao_invalida', 'pessoa_nao_encontrada', 'funcao_nao_encontrada', 'ultimo_administrador'].find((c) => m.includes(c));
  if (cod) { res.status(['so_administrador', 'papel_nao_atribuido', 'sessao_invalida'].includes(cod) ? 403 : 422).json({ erro: cod }); return; }
  next(err);
}

perfilRouter.get('/papeis', exigirSessao, async (req, res, next) => {
  try {
    const r = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.fn_papeis_sessao($1)', [token(req)])).rows[0]);
    res.json({ papeis: r?.papeis ?? ['aluno'], ativo: (req as Req).papel, escolher: Boolean(r?.escolher) });
  } catch (err) { next(err); }
});

perfilRouter.post('/papel', exigirSessao, async (req, res, next) => {
  try {
    const papel = String((req.body as { papel?: string })?.papel ?? '');
    const r = await withMaestro(null, async (c) => (await c.query('SELECT app.trocar_papel($1, $2) AS papel', [token(req), papel])).rows[0]);
    res.json({ papel: r?.papel });
  } catch (err) { erroDoBanco(err, res, next); }
});

perfilRouter.get('/funcoes', exigirSessao, async (_req, res, next) => {
  try { res.json({ funcoes: await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.funcoes_equipe()')).rows) }); }
  catch (err) { erroDoBanco(err, res, next); }
});

perfilRouter.get('/pessoas', exigirSessao, async (req, res, next) => {
  try {
    const q = String(req.query.q ?? '').slice(0, 80);
    res.json({ pessoas: await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.buscar_pessoas($1)', [q])).rows) });
  } catch (err) { erroDoBanco(err, res, next); }
});

perfilRouter.post('/funcoes', exigirSessao, async (req, res, next) => {
  try {
    const b = req.body as { pessoa_id?: number; papel?: string };
    const id = await withMaestro(null, async (c) => (await c.query('SELECT app.atribuir_funcao($1, $2) AS id', [Number(b.pessoa_id), String(b.papel ?? '')])).rows[0]?.id);
    res.json({ ok: true, designacao_id: id });
  } catch (err) { erroDoBanco(err, res, next); }
});

perfilRouter.post('/funcoes/:id/encerrar', exigirSessao, async (req, res, next) => {
  try {
    await withMaestro(null, async (c) => c.query('SELECT app.encerrar_funcao($1)', [Number(req.params.id)]));
    res.json({ ok: true });
  } catch (err) { erroDoBanco(err, res, next); }
});
