import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';
import { logger } from '../db/logger.js';

// Limite simples por chave (IP ou pessoa) numa janela de tempo, sem dependencias.
const baldes = new Map<string, { n: number; ate: number }>();
export function limite(nome: string, max: number, janelaMs: number) {
  return (req: Request, res: Response, next: NextFunction) => {
    const quem = (req as Request & { pessoaId?: number }).pessoaId ?? req.ip ?? 'anon';
    const chave = `${nome}:${quem}`;
    const agora = Date.now();
    const b = baldes.get(chave);
    if (!b || b.ate < agora) baldes.set(chave, { n: 1, ate: agora + janelaMs });
    else if (++b.n > max) {
      res.setHeader('Retry-After', String(Math.ceil((b.ate - agora) / 1000)));
      res.status(429).json({ erro: 'muitas_requisicoes' });
      return;
    }
    next();
  };
}
setInterval(() => { const agora = Date.now(); for (const [k, b] of baldes) if (b.ate < agora) baldes.delete(k); }, 60_000).unref();

// Conteudo protegido: nao guardar em cache, nao indexar, e registrar quem acessou.
// Acima de 600 acessos por hora para a mesma pessoa, bloqueia (raspagem automatizada).
export function conteudoProtegido(req: Request, res: Response, next: NextFunction) {
  res.setHeader('Cache-Control', 'no-store, private, max-age=0');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('X-Robots-Tag', 'noindex, nofollow, noarchive');
  const pessoaId = (req as Request & { pessoaId?: number }).pessoaId;
  if (!pessoaId || req.method !== 'GET') { next(); return; }
  withMaestro(null, async (c) => {
    const { rows } = await c.query('SELECT app.registrar_acesso($1, $2::inet, $3) AS n',
      [req.baseUrl + req.path, req.ip ?? null, req.get('user-agent') ?? '']);
    return Number(rows[0]?.n ?? 0);
  }).then((n) => {
    if (n > 600) {
      logger.warn({ pessoaId, n }, 'acesso excessivo a conteudo protegido');
      res.status(429).json({ erro: 'acesso_excessivo' });
      return;
    }
    next();
  }).catch((err) => { logger.error({ err }, 'falha ao registrar acesso'); next(); });
}
