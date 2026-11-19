import { Router } from 'express';
import type { Request, Response, NextFunction } from 'express';
import nodemailer from 'nodemailer';
import { withMaestro } from '../db/transaction.js';
import { logger } from '../db/logger.js';
import { config } from '../config.js';

// Entrada e inscricao sem conta Google: link de uso unico enviado ao e-mail (SQL 95).
//   POST /auth/email/pedir   {email}  -> sempre {ok:true} (nao revela quem esta cadastrado)
//   POST /auth/email/entrar  {token}  -> abre a sessao (cookie) ou 400 link_invalido
// O link leva a tela /entrar do aplicativo, que pede um toque em "Entrar": assim, o leitor de links do e-mail
// (que abre os enderecos para conferir) nao gasta o link.
export const entradaEmailRouter = Router();

const SESSAO_TTL_MS = 12 * 60 * 60 * 1000;
const opcoesCookie = { httpOnly: true, sameSite: 'lax' as const, secure: config.producao, path: '/' };
const env = process.env;
const transporte = env.SMTP_HOST && env.SMTP_FROM ? nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: Number(env.SMTP_PORT ?? 587),
  secure: Number(env.SMTP_PORT ?? 587) === 465,
  auth: env.SMTP_USER ? { user: env.SMTP_USER, pass: env.SMTP_PASS ?? '' } : undefined,
}) : null;

entradaEmailRouter.post('/pedir', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const email = String((req.body as { email?: unknown })?.email ?? '').trim().toLowerCase().slice(0, 254);
    if (!email.includes('@')) { res.status(422).json({ erro: 'email_invalido' }); return; }
    if (!transporte && config.producao) { res.status(503).json({ erro: 'email_nao_configurado' }); return; }
    const token = await withMaestro({}, async (c) =>
      (await c.query<{ t: string | null }>('SELECT app.fn_pedir_link_entrada($1, $2::inet) AS t', [email, req.ip ?? null])).rows[0]?.t ?? null);
    if (!token) { res.json({ ok: true }); return; }
    const link = `${config.appUrl.replace(/\/$/, '')}/entrar?t=${token}`;
    if (transporte) {
      await transporte.sendMail({
        from: env.SMTP_FROM, to: email, subject: 'Seu link de entrada no CUT',
        text: `Para entrar no CUT (Curso de Cirurgia Geral, Urgência e Trauma), abra o link abaixo e toque em "Entrar".\n\n${link}\n\n`
          + 'O link vale por 20 minutos e só pode ser usado uma vez. Se não foi você que pediu, ignore este e-mail.',
      });
      res.json({ ok: true });
      return;
    }
    // teste local sem e-mail configurado: o link aparece no registro da API e, com o login de teste ligado, na tela
    logger.warn({ link }, 'entrada por e-mail sem SMTP configurado: link so no registro');
    res.json(config.permitirLoginTeste ? { ok: true, link_teste: link } : { ok: true });
  } catch (err) { next(err); }
});

entradaEmailRouter.post('/entrar', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const t = String((req.body as { token?: unknown })?.token ?? '');
    if (!/^[0-9a-f]{64}$/.test(t)) { res.status(400).json({ erro: 'link_invalido' }); return; }
    const sessao = await withMaestro({}, async (c) =>
      (await c.query<{ s: string | null }>('SELECT app.fn_sessao_link_entrada($1, $2::inet, $3) AS s', [t, req.ip ?? null, req.get('user-agent') ?? ''])).rows[0]?.s ?? null);
    if (!sessao) { res.status(400).json({ erro: 'link_invalido' }); return; }
    res.cookie('sessao', sessao, { ...opcoesCookie, maxAge: SESSAO_TTL_MS });
    res.json({ ok: true });
  } catch (err) { next(err); }
});
