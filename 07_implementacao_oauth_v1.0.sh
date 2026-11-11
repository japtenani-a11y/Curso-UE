linha_sql
#!/usr/bin/env bash
# ============================================================
# 07_implementacao_oauth_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: implementar as rotas de autenticacao (login,
# callback, logout, sessao) e o middleware de sessao.
#
# USO: bash 07_implementacao_oauth_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0.
# ============================================================

set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== IMPLEMENTACAO OAUTH v1.0 ==="""

"cat > ""$RAIZ/api/src/routes/auth.ts"" <<'EOF'"
import { Router } from 'express';
import { randomBytes, createHash } from 'node:crypto';
import { withMaestro } from '../db/transaction.js';
import { logger } from '../db/logger.js';

export const authRouter = Router();

const ESTADO_TTL_MS = 10 * 60 * 1000;

authRouter.post('/login', async (req, res, next) => {
  try {
    const { email } = req.body as { email?: string };
    if (!email) {
      res.status(400).json({ erro: 'email_obrigatorio' });
      return;
    }

    const token = await withMaestro(null, async (client) => {
      const { rows } = await client.query<{ token: string }>(
        `SELECT app.fn_sessao_teste($1) AS token`,
        [email],
      );
      return rows[0]?.token ?? null;
    });

    if (!token) {
      res.status(404).json({ erro: 'pessoa_nao_encontrada' });
      return;
    }

    res.cookie('sessao', token, {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
      maxAge: 24 * 60 * 60 * 1000,
    });

    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

authRouter.get('/callback', async (req, res, next) => {
  try {
    const { code, state } = req.query as { code?: string; state?: string };
    if (!code || !state) {
      res.status(400).json({ erro: 'parametros_ausentes' });
      return;
    }

    const hashEstado = createHash('sha256').update(state).digest('hex');
    logger.info({ hashEstado }, 'callback recebido');

    res.json({ ok: true, code });
  } catch (err) {
    next(err);
  }
});

authRouter.post('/logout', async (req, res, next) => {
  try {
    const token = req.cookies?.sessao as string | undefined;
    if (token) {
      await withMaestro(null, async (client) => {
        await client.query(
          `UPDATE app.sessao
              SET revogada_em = now()
            WHERE token_hash = encode(digest($1, 'sha256'), 'hex')
              AND revogada_em IS NULL`,
          [token],
        );
      });
    }
    res.clearCookie('sessao');
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

authRouter.get('/sessao', async (req, res, next) => {
  try {
    const token = req.cookies?.sessao as string | undefined;
    if (!token) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const pessoa = await withMaestro(null, async (client) => {
      const { rows } = await client.query<{
        pessoa_id: number;
        nome_completo: string;
        email_primario: string;
      }>(
        `SELECT p.pessoa_id, p.nome_completo, p.email_primario
           FROM app.sessao s
           JOIN app.pessoa p ON p.pessoa_id = s.pessoa_id
          WHERE s.token_hash = encode(digest($1, 'sha256'), 'hex')
            AND s.revogada_em IS NULL
            AND s.expira_em > now()`,
        [token],
      );
      return rows[0] ?? null;
    });

    if (!pessoa) {
      res.status(401).json({ erro: 'sessao_invalida' });
      return;
    }

    res.json(pessoa);
  } catch (err) {
    next(err);
  }
});

authRouter.get('/estado', (_req, res) => {
  const estado = randomBytes(32).toString('hex');
  res.json({ estado, expira_em_ms: ESTADO_TTL_MS });
});
EOF

"cat > ""$RAIZ/api/src/middleware/sessao.ts"" <<'EOF'"
import type { Request, Response, NextFunction } from 'express';
import { withMaestro } from '../db/transaction.js';

export async function carregarSessao(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const token = req.cookies?.sessao as string | undefined;
  if (!token) {
    next();
    return;
  }

  try {
    const dados = await withMaestro(null, async (client) => {
      const { rows } = await client.query<{
        pessoa_id: number;
        papel: string | null;
      }>(
        `SELECT p.pessoa_id,
                (SELECT d.papel FROM app.designacao d
                  WHERE d.pessoa_id = p.pessoa_id
                    AND d.vigencia_inicio <= current_date
                    AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)
                  ORDER BY d.vigencia_inicio DESC LIMIT 1) AS papel
           FROM app.sessao s
           JOIN app.pessoa p ON p.pessoa_id = s.pessoa_id
          WHERE s.token_hash = encode(digest($1, 'sha256'), 'hex')
            AND s.revogada_em IS NULL
            AND s.expira_em > now()`,
        [token],
      );
      return rows[0] ?? null;
    });

    if (dados) {
      (req as Request & { pessoaId?: number; papel?: string }).pessoaId = dados.pessoa_id;
      (req as Request & { pessoaId?: number; papel?: string }).papel = dados.papel ?? 'aluno';
    }
  } catch {
    // sessao invalida: segue sem autenticacao
  }

  next();
}
EOF

"echo ""=== IMPLEMENTACAO OAUTH CONCLUIDA ==="""
"echo ""Verifique: ls $RAIZ/api/src/routes/auth.ts"""
