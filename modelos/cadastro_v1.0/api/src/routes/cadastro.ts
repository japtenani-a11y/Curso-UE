import { Router } from 'express';
import type { Request } from 'express';
import { withMaestro } from '../db/transaction.js';

// Ficha de inscricao e termos da pessoa logada. A validacao completa fica no banco (app.salvar_ficha).
export const cadastroRouter = Router();
const pessoa = (req: Request) => (req as Request & { pessoaId?: number }).pessoaId ?? null;

cadastroRouter.use((req, res, next) => {
  if (!pessoa(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
});

cadastroRouter.get('/situacao', async (_req, res, next) => {
  try {
    const f = await withMaestro(null, async (c) => (await c.query('SELECT app.minha_ficha() AS f')).rows[0]?.f);
    res.json({ ok: f?.cadastro_ok === true, precisa_ficha: f?.precisa_ficha === true, status: f?.ficha?.status ?? 'rascunho' });
  } catch (err) { next(err); }
});

cadastroRouter.get('/ficha', async (_req, res, next) => {
  try {
    const f = await withMaestro(null, async (c) => (await c.query('SELECT app.minha_ficha() AS f')).rows[0]?.f);
    res.json(f);
  } catch (err) { next(err); }
});

cadastroRouter.post('/ficha', async (req, res, next) => {
  try {
    const corpo = JSON.stringify(req.body ?? {});
    if (corpo.length > 20_000) { res.status(413).json({ erro: 'grande_demais' }); return; }
    const status = await withMaestro(null, async (c) => (await c.query(
      'SELECT app.salvar_ficha($1::jsonb, $2::inet, $3) AS s', [corpo, req.ip ?? null, req.get('user-agent') ?? ''])).rows[0]?.s);
    res.json({ ok: true, status });
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    const v = /^(campo|termo):([a-z_]+)$/.exec(m);
    if (v) { res.status(422).json({ erro: v[1] === 'campo' ? 'campo_invalido' : 'termo_obrigatorio', campo: v[2] }); return; }
    next(err);
  }
});

// Pedido do titular (LGPD): vai para a coordenacao como feedback registrado.
cadastroRouter.post('/solicitacao', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as { tipo?: string; texto?: string };
    const tipos: Record<string, string> = { copia: 'cópia dos meus dados', exclusao: 'exclusão dos meus dados', correcao: 'correção de dados', outro: 'outro pedido' };
    const tipo = tipos[String(b.tipo)] ?? tipos.outro;
    const texto = `[Solicitação LGPD: ${tipo}] ${String(b.texto ?? '').slice(0, 1500)}`.trim();
    await withMaestro(null, async (c) => {
      await c.query(`INSERT INTO app.mensagem_aluno (pessoa_id, tipo, texto) VALUES (app.pessoa_atual(), 'feedback', $1)`, [texto]);
    });
    res.json({ ok: true });
  } catch (err) { next(err); }
});
