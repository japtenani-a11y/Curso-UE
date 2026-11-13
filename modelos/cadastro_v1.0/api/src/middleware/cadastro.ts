import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';

// Aluno so usa o curso com inscricao aprovada e termos obrigatorios aceitos (conferido no banco).
export async function exigirCadastro(req: Request, res: Response, next: NextFunction): Promise<void> {
  const r = req as Request & { pessoaId?: number; papel?: string };
  if (!r.pessoaId || r.papel !== 'aluno') { next(); return; }
  try {
    const ok = await withMaestro(null, async (c) => (await c.query('SELECT app.cadastro_ok() AS ok')).rows[0]?.ok === true);
    if (!ok) { res.status(403).json({ erro: 'cadastro_pendente' }); return; }
    next();
  } catch (err) { next(err); }
}
