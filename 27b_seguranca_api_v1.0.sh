#!/usr/bin/env bash
# ============================================================
# 27b_seguranca_api_v1.0.sh
# Programa de Cirurgia de Urgencia e Trauma
# Correcoes de seguranca da API (aplicar depois do 07 e do 27 SQL).
#
# O QUE FAZ
#  - db/transaction.ts: grava pessoa e papel na sessao do banco
#    (app.pessoa_id, app.role) a cada transacao, para a RLS valer.
#  - middleware/sessao.ts: identifica a sessao por funcao do banco e
#    guarda o contexto; e REGISTRADO em main.ts (antes nao era).
#  - routes/auth.ts: login com Google (OAuth 2.0 com PKCE e state),
#    login de teste so em desenvolvimento.
#  - main.ts: CORS so para origens da lista CORS_ORIGINS; recusa
#    iniciar em producao com configuracao insegura.
#  - .env.example e package.json: variaveis e dependencia nova.
#
# USO: bash 27b_seguranca_api_v1.0.sh ./programa-cut
# DEPOIS: cd programa-cut/api && npm install
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
SRC="$RAIZ/api/src"
[ -f "$SRC/main.ts" ] || { echo "ERRO: $SRC/main.ts nao existe"; exit 1; }
echo "=== SEGURANCA API v1.0 ==="

cat > "$SRC/config.ts" <<'EOF'
const producao = process.env.NODE_ENV === 'production';

function exigir(nome: string): string {
  const v = process.env[nome];
  if (!v || v.startsWith('trocar') || v === 'preencher') {
    throw new Error(`Variavel de ambiente ausente ou com valor de exemplo: ${nome}`);
  }
  return v;
}

export const config = {
  producao,
  appUrl: process.env.APP_URL ?? 'http://localhost:5173',
  corsOrigens: (process.env.CORS_ORIGINS ?? 'http://localhost:5173')
    .split(',').map((s) => s.trim()).filter(Boolean),
  permitirLoginTeste: !producao && process.env.ALLOW_TEST_LOGIN === '1',
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID ?? '',
    clientSecret: process.env.GOOGLE_CLIENT_SECRET ?? '',
    redirectUri: process.env.GOOGLE_REDIRECT_URI ?? 'http://localhost:3000/auth/callback',
  },
};

export function validarConfig(): void {
  const url = process.env.DATABASE_URL ?? '';
  if (/^postgres(ql)?:\/\/postgres[:@]/.test(url)) {
    throw new Error('DATABASE_URL usa o superusuario postgres. Use api_rw: superusuario ignora a RLS.');
  }
  if (producao) {
    exigir('DATABASE_URL');
    exigir('GOOGLE_CLIENT_ID');
    exigir('GOOGLE_CLIENT_SECRET');
    exigir('GOOGLE_REDIRECT_URI');
    if (config.corsOrigens.some((o) => o === '*' || o.startsWith('http://'))) {
      throw new Error('CORS_ORIGINS em producao deve listar so origens https.');
    }
  }
}
EOF

cat > "$SRC/db/transaction.ts" <<'EOF'
import { AsyncLocalStorage } from 'node:async_hooks';
import type { PoolClient } from 'pg';
import { pool } from './pool.js';

export interface ContextoDb {
  pessoaId?: number;
  papel?: string;
  permitirTeste?: boolean;
}

// Contexto da requisicao atual (definido pelo middleware de sessao).
export const contextoDb = new AsyncLocalStorage<ContextoDb>();

// Executa fn numa transacao. Grava no banco quem esta chamando
// (app.pessoa_id e app.role, validos so dentro da transacao) para que as
// politicas de RLS decidam o que cada pessoa ve. O primeiro argumento pode
// trazer um contexto explicito; null usa o da requisicao.
export async function withMaestro<T>(
  ctx: unknown,
  fn: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const c: ContextoDb = (ctx as ContextoDb | null) ?? contextoDb.getStore() ?? {};
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `SELECT set_config('app.pessoa_id', $1, true),
              set_config('app.role', $2, true),
              set_config('app.permitir_teste', $3, true)`,
      [c.pessoaId ? String(c.pessoaId) : '', c.papel ?? 'anonimo', c.permitirTeste ? 'on' : 'off'],
    );
    const resultado = await fn(client);
    await client.query('COMMIT');
    return resultado;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
EOF

cat > "$SRC/middleware/sessao.ts" <<'EOF'
import type { Request, Response, NextFunction } from 'express';
import { withMaestro, contextoDb } from '../db/transaction.js';

type ReqSessao = Request & { pessoaId?: number; papel?: string };

// Identifica a sessao pelo cookie e guarda pessoa e papel no contexto da
// requisicao. Sem cookie valido, segue como anonimo (as rotas exigem papel).
export async function carregarSessao(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  const token = req.cookies?.sessao as string | undefined;
  if (!token) {
    next();
    return;
  }
  try {
    const dados = await withMaestro({}, async (client) => {
      const { rows } = await client.query<{ pessoa_id: string; papel: string }>(
        'SELECT pessoa_id, papel FROM app.fn_identificar_sessao($1)',
        [token],
      );
      return rows[0] ?? null;
    });
    if (!dados) {
      next();
      return;
    }
    const pessoaId = Number(dados.pessoa_id);
    (req as ReqSessao).pessoaId = pessoaId;
    (req as ReqSessao).papel = dados.papel;
    contextoDb.run({ pessoaId, papel: dados.papel }, () => next());
  } catch {
    next();
  }
}
EOF

cat > "$SRC/routes/auth.ts" <<'EOF'
import { Router } from 'express';
import type { Request, Response, NextFunction } from 'express';
import { randomBytes, createHash } from 'node:crypto';
import { OAuth2Client } from 'google-auth-library';
import { withMaestro } from '../db/transaction.js';
import { logger } from '../db/logger.js';
import { config } from '../config.js';

export const authRouter = Router();

const TX_TTL_MS = 10 * 60 * 1000;
const SESSAO_TTL_MS = 12 * 60 * 60 * 1000;

const opcoesCookie = {
  httpOnly: true,
  sameSite: 'lax' as const,
  secure: config.producao,
  path: '/',
};

function clienteGoogle(): OAuth2Client {
  return new OAuth2Client(
    config.google.clientId,
    config.google.clientSecret,
    config.google.redirectUri,
  );
}

function base64url(buf: Buffer): string {
  return buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

// 1. Inicia o login: gera state e verificador PKCE, guarda num cookie
//    curto e redireciona para o Google.
authRouter.get('/google', (_req: Request, res: Response) => {
  if (!config.google.clientId) {
    res.status(503).json({ erro: 'google_nao_configurado' });
    return;
  }
  const state = base64url(randomBytes(32));
  const verificador = base64url(randomBytes(32));
  const desafio = base64url(createHash('sha256').update(verificador).digest());
  res.cookie('oauth_tx', JSON.stringify({ state, verificador }), {
    ...opcoesCookie,
    maxAge: TX_TTL_MS,
  });
  const url = clienteGoogle().generateAuthUrl({
    scope: ['openid', 'email', 'profile'],
    state,
    code_challenge: desafio,
    code_challenge_method: 'S256' as never,
    prompt: 'select_account',
  });
  res.redirect(url);
});

// 2. Retorno do Google: confere o state, troca o codigo, verifica o
//    id_token (assinatura, destinatario, e-mail confirmado) e abre a sessao
//    so se o e-mail ja estiver cadastrado em app.pessoa.
authRouter.get('/callback', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { code, state } = req.query as { code?: string; state?: string };
    if (!code || !state) {
      res.status(400).json({ erro: 'parametros_ausentes' });
      return;
    }
    let tx: { state: string; verificador: string } | null = null;
    try {
      tx = JSON.parse((req.cookies?.oauth_tx as string | undefined) ?? 'null');
    } catch {
      tx = null;
    }
    res.clearCookie('oauth_tx', opcoesCookie);
    if (!tx || tx.state !== state) {
      res.status(400).json({ erro: 'state_invalido' });
      return;
    }

    const cliente = clienteGoogle();
    const { tokens } = await cliente.getToken({ code, codeVerifier: tx.verificador });
    if (!tokens.id_token) {
      res.status(400).json({ erro: 'id_token_ausente' });
      return;
    }
    const ticket = await cliente.verifyIdToken({
      idToken: tokens.id_token,
      audience: config.google.clientId,
    });
    const dados = ticket.getPayload();
    if (!dados?.email || dados.email_verified !== true) {
      res.status(403).json({ erro: 'email_nao_verificado' });
      return;
    }

    const token = await withMaestro({}, async (client) => {
      const { rows } = await client.query<{ token: string | null }>(
        'SELECT app.fn_sessao_google($1, $2::inet, $3) AS token',
        [dados.email, req.ip ?? null, req.get('user-agent') ?? ''],
      );
      return rows[0]?.token ?? null;
    });

    if (!token) {
      logger.warn('login google recusado: e-mail nao cadastrado');
      res.redirect(`${config.appUrl}/login?erro=nao_cadastrado`);
      return;
    }
    res.cookie('sessao', token, { ...opcoesCookie, maxAge: SESSAO_TTL_MS });
    res.redirect(`${config.appUrl}/`);
  } catch (err) {
    next(err);
  }
});

// Login de teste: so existe em desenvolvimento com ALLOW_TEST_LOGIN=1.
authRouter.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!config.permitirLoginTeste) {
      res.status(404).json({ erro: 'nao_encontrado' });
      return;
    }
    const { email } = req.body as { email?: string };
    if (!email) {
      res.status(400).json({ erro: 'email_obrigatorio' });
      return;
    }
    const token = await withMaestro({ permitirTeste: true }, async (client) => {
      const { rows } = await client.query<{ token: string }>(
        'SELECT app.fn_sessao_teste($1) AS token',
        [email],
      );
      return rows[0]?.token ?? null;
    });
    if (!token) {
      res.status(404).json({ erro: 'pessoa_nao_encontrada' });
      return;
    }
    res.cookie('sessao', token, { ...opcoesCookie, maxAge: 24 * 60 * 60 * 1000 });
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

authRouter.post('/logout', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.cookies?.sessao as string | undefined;
    if (token) {
      await withMaestro({}, async (client) => {
        await client.query('SELECT app.fn_revogar_sessao($1)', [token]);
      });
    }
    res.clearCookie('sessao', opcoesCookie);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

authRouter.get('/sessao', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.cookies?.sessao as string | undefined;
    if (!token) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }
    const pessoa = await withMaestro({}, async (client) => {
      const { rows } = await client.query<{
        pessoa_id: string;
        nome_completo: string;
        email_primario: string;
        papel: string;
      }>('SELECT * FROM app.fn_identificar_sessao($1)', [token]);
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
EOF

# main.ts: CORS restrito, validacao de configuracao, sessao registrada
python3 - "$SRC/main.ts" <<'PY'
import sys,re
p=sys.argv[1]
s=open(p,encoding='utf8').read()
if "validarConfig" not in s:
    s=s.replace("import { logger } from './db/logger.js';",
      "import { logger } from './db/logger.js';\nimport { config, validarConfig } from './config.js';\nimport { carregarSessao } from './middleware/sessao.js';",1)
    s=s.replace("const app = express();","validarConfig();\n\nconst app = express();",1)
    s=s.replace("app.use(cors({ origin: true, credentials: true }));",
      "app.use(cors({\n  origin: (origem, cb) => cb(null, !origem || config.corsOrigens.includes(origem)),\n  credentials: true,\n}));",1)
    s=s.replace("app.use(pinoHttp({ logger }));","app.use(pinoHttp({ logger }));\napp.use(carregarSessao);",1)
    open(p,'w',encoding='utf8').write(s)
    print("main.ts atualizado")
else:
    print("main.ts ja atualizado")
PY

# .env.example e package.json
cat > "$RAIZ/api/.env.example" <<'EOF'
# A API conecta como api_rw (NUNCA como postgres: superusuario ignora a RLS).
DATABASE_URL=postgres://api_rw:TROCAR@localhost:5432/programa_v44
PORT=3000
NODE_ENV=development
LOG_LEVEL=info
APP_URL=http://localhost:5173
CORS_ORIGINS=http://localhost:5173
# Login de teste (so funciona fora de producao):
ALLOW_TEST_LOGIN=0
# Login com Google (console.cloud.google.com > APIs e servicos > Credenciais):
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:3000/auth/callback
EOF

python3 - "$RAIZ/api/package.json" <<'PY'
import json,sys
p=sys.argv[1]
d=json.load(open(p,encoding='utf8'))
d.setdefault('dependencies',{})['google-auth-library']='^9.14.0'
json.dump(d,open(p,'w',encoding='utf8'),indent=2,ensure_ascii=False)
print("package.json: google-auth-library adicionado")
PY

echo "=== SEGURANCA API CONCLUIDA ==="
echo "Proximo: cd $RAIZ/api && npm install"
