linha_sql
#!/usr/bin/env bash
# ============================================================
# 06_scaffolding_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: criar a estrutura de pastas e os arquivos base da
# API (Express + TypeScript) e do PWA (Vite + React + TS).
#
# USO: bash 06_scaffolding_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: Node.js 22 LTS instalado.
# ============================================================

set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== SCAFFOLDING v1.0 ==="""
"echo ""Raiz: $RAIZ"""

"mkdir -p ""$RAIZ""/api/src/{routes,middleware,db,tipos,servicos}"
"mkdir -p ""$RAIZ""/api/test/{unit,integration}"
"mkdir -p ""$RAIZ""/pwa/src/{pages,components,lib,tipos}"
"mkdir -p ""$RAIZ""/pwa/public"
"mkdir -p ""$RAIZ""/executor/src/{maestro,motor,tipos}"
"mkdir -p ""$RAIZ""/sql"
"mkdir -p ""$RAIZ""/docs"
"mkdir -p ""$RAIZ""/logs"

# ---------- API ----------

"cat > ""$RAIZ/api/package.json"" <<'EOF'"
{
"  ""name"": ""programa-cut-api"","
"  ""version"": ""1.0.0"","
"  ""type"": ""module"","
"  ""scripts"": {"
"    ""dev"": ""tsx watch src/main.ts"","
"    ""build"": ""tsc"","
"    ""start"": ""node dist/main.js"","
"    ""typecheck"": ""tsc --noEmit"","
"    ""test"": ""vitest run test/unit"","
"    ""test:integration"": ""vitest run test/integration"""
  },
"  ""dependencies"": {"
"    ""express"": ""^4.19.2"","
"    ""pg"": ""^8.12.0"","
"    ""zod"": ""^3.23.8"","
"    ""pino"": ""^9.3.2"","
"    ""pino-http"": ""^10.2.0"","
"    ""cookie-parser"": ""^1.4.6"","
"    ""helmet"": ""^7.1.0"","
"    ""cors"": ""^2.8.5"""
  },
"  ""devDependencies"": {"
"    ""@types/express"": ""^4.17.21"","
"    ""@types/node"": ""^22.5.0"","
"    ""@types/pg"": ""^8.11.6"","
"    ""@types/cookie-parser"": ""^1.4.7"","
"    ""@types/cors"": ""^2.8.17"","
"    ""tsx"": ""^4.19.0"","
"    ""typescript"": ""^5.5.4"","
"    ""vitest"": ""^2.0.5"","
"    ""supertest"": ""^7.0.0"","
"    ""@types/supertest"": ""^6.0.2"""
  }
}
EOF

"cat > ""$RAIZ/api/tsconfig.json"" <<'EOF'"
{
"  ""compilerOptions"": {"
"    ""target"": ""ES2022"","
"    ""module"": ""NodeNext"","
"    ""moduleResolution"": ""NodeNext"","
"    ""lib"": [""ES2022""],"
"    ""outDir"": ""dist"","
"    ""rootDir"": ""src"","
"    ""strict"": true,"
"    ""noUncheckedIndexedAccess"": true,"
"    ""noImplicitOverride"": true,"
"    ""esModuleInterop"": true,"
"    ""skipLibCheck"": true,"
"    ""forceConsistentCasingInFileNames"": true,"
"    ""resolveJsonModule"": true,"
"    ""declaration"": false,"
"    ""sourceMap"": true"
  },
"  ""include"": [""src/**/*.ts""],"
"  ""exclude"": [""node_modules"", ""dist"", ""test""]"
}
EOF

"cat > ""$RAIZ/api/.env.example"" <<'EOF'"
DATABASE_URL=postgres://postgres:trocar_em_producao@localhost:5432/programa_v44
PORT=3000
NODE_ENV=development
LOG_LEVEL=info
SESSION_SECRET=trocar_em_producao
EOF

"cat > ""$RAIZ/api/src/main.ts"" <<'EOF'"
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import pinoHttp from 'pino-http';
import { logger } from './db/logger.js';
import { pool } from './db/pool.js';
import { erroHandler } from './middleware/erro.js';
import { authRouter } from './routes/auth.js';
import { alunoRouter } from './routes/aluno.js';
import { preceptorRouter } from './routes/preceptor.js';
import { curadorRouter } from './routes/curador.js';
import { pesquisaRouter } from './routes/pesquisa.js';
import { conteudoRouter } from './routes/conteudo.js';
import { sistemaRouter } from './routes/sistema.js';

const app = express();

app.use(helmet());
app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '2mb' }));
app.use(cookieParser());
app.use(pinoHttp({ logger }));

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'ok' });
  } catch {
    res.status(503).json({ status: 'degraded', db: 'erro' });
  }
});

app.use('/auth', authRouter);
app.use('/aluno', alunoRouter);
app.use('/preceptor', preceptorRouter);
app.use('/curador', curadorRouter);
app.use('/pesquisa', pesquisaRouter);
app.use('/conteudo', conteudoRouter);
app.use('/sistema', sistemaRouter);

app.use(erroHandler);

const porta = Number(process.env.PORT ?? 3000);
app.listen(porta, () => {
  logger.info({ porta }, 'Server listening');
});
EOF

"cat > ""$RAIZ/api/src/db/logger.ts"" <<'EOF'"
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  transport: process.env.NODE_ENV === 'development'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined,
});
EOF

"cat > ""$RAIZ/api/src/db/pool.ts"" <<'EOF'"
import pg from 'pg';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on('error', (err) => {
  console.error('Erro inesperado no pool:', err);
});
EOF

"cat > ""$RAIZ/api/src/db/transaction.ts"" <<'EOF'"
import type { PoolClient } from 'pg';
import { pool } from './pool.js';

export async function withMaestro<T>(
  _ctx: unknown,
  fn: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
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

"cat > ""$RAIZ/api/src/middleware/erro.ts"" <<'EOF'"
import type { Request, Response, NextFunction } from 'express';
import { logger } from '../db/logger.js';

export function erroHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const e = err as { status?: number; code?: string; message?: string };

  if (e.code === '23505') {
    res.status(409).json({ erro: 'conflito', detalhe: e.message });
    return;
  }
  if (e.code === '23503') {
    res.status(422).json({ erro: 'referencia_invalida', detalhe: e.message });
    return;
  }
  if (e.code === '23514') {
    res.status(422).json({ erro: 'violacao_regra', detalhe: e.message });
    return;
  }
  if (e.code === '42501') {
    res.status(403).json({ erro: 'proibido', detalhe: e.message });
    return;
  }

  logger.error({ err }, 'erro nao tratado');
  res.status(e.status ?? 500).json({ erro: 'interno' });
}
EOF

"cat > ""$RAIZ/api/src/middleware/role.ts"" <<'EOF'"
import type { Request, Response, NextFunction } from 'express';

export function requireRole(papeis: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const papel = (req as Request & { papel?: string }).papel;
    if (!papel || !papeis.includes(papel)) {
      res.status(403).json({ erro: 'proibido', detalhe: 'papel insuficiente' });
      return;
    }
    next();
  };
}
EOF

"cat > ""$RAIZ/api/src/tipos/dominio.ts"" <<'EOF'"
export type Grau = 'R1' | 'R2' | 'R3' | 'R4' | 'R5' | 'preceptor' | 'docente';
export type StatusArtefato = 'rascunho' | 'revisao' | 'aprovado' | 'publicado' | 'arquivado';
export type StatusOnda = 'planejada' | 'aberta' | 'fechada' | 'cancelada';
export type StatusJob = 'pendente' | 'executando' | 'concluido' | 'falhou' | 'cancelado';
export type Severidade = 'info' | 'atencao' | 'critica';

export interface Pessoa {
  pessoa_id: number;
  nome_completo: string;
  email_primario: string;
}

export interface Tema {
  tema_id: number;
  ciclo_id: number;
  codigo: string;
  titulo: string;
  grau: Grau;
  carga_horaria: number;
  dificuldade: number;
}
EOF

# ---------- PWA ----------

"cat > ""$RAIZ/pwa/package.json"" <<'EOF'"
{
"  ""name"": ""programa-cut-pwa"","
"  ""version"": ""1.0.0"","
"  ""type"": ""module"","
"  ""scripts"": {"
"    ""dev"": ""vite"","
"    ""build"": ""tsc && vite build"","
"    ""preview"": ""vite preview"","
"    ""typecheck"": ""tsc --noEmit"","
"    ""test:e2e"": ""playwright test"""
  },
"  ""dependencies"": {"
"    ""react"": ""^18.3.1"","
"    ""react-dom"": ""^18.3.1"","
"    ""react-router-dom"": ""^6.26.0"""
  },
"  ""devDependencies"": {"
"    ""@types/react"": ""^18.3.3"","
"    ""@types/react-dom"": ""^18.3.0"","
"    ""@vitejs/plugin-react"": ""^4.3.1"","
"    ""typescript"": ""^5.5.4"","
"    ""vite"": ""^5.4.0"","
"    ""@playwright/test"": ""^1.46.0"""
  }
}
EOF

"cat > ""$RAIZ/pwa/tsconfig.json"" <<'EOF'"
{
"  ""compilerOptions"": {"
"    ""target"": ""ES2022"","
"    ""lib"": [""ES2022"", ""DOM"", ""DOM.Iterable""],"
"    ""module"": ""ESNext"","
"    ""moduleResolution"": ""bundler"","
"    ""jsx"": ""react-jsx"","
"    ""strict"": true,"
"    ""noUncheckedIndexedAccess"": true,"
"    ""esModuleInterop"": true,"
"    ""skipLibCheck"": true,"
"    ""resolveJsonModule"": true,"
"    ""isolatedModules"": true,"
"    ""noEmit"": true"
  },
"  ""include"": [""src""]"
}
EOF

"cat > ""$RAIZ/pwa/vite.config.ts"" <<'EOF'"
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        rewrite: (p) => p.replace(/^\/api/, ''),
      },
    },
  },
});
EOF

"cat > ""$RAIZ/pwa/.env.example"" <<'EOF'"
VITE_API_URL=http://localhost:3000
EOF

"cat > ""$RAIZ/pwa/index.html"" <<'EOF'"
<!doctype html>
"<html lang=""pt-BR"">"
  <head>
"    <meta charset=""UTF-8"" />"
"    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />"
    <title>Programa de Cirurgia de Urgencia e Trauma</title>
  </head>
  <body>
"    <div id=""root""></div>"
"    <script type=""module"" src=""/src/main.tsx""></script>"
  </body>
</html>
EOF

"cat > ""$RAIZ/pwa/src/main.tsx"" <<'EOF'"
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { App } from './App.js';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
);
EOF

"cat > ""$RAIZ/pwa/src/App.tsx"" <<'EOF'"
import { Routes, Route, Navigate } from 'react-router-dom';
import { Login } from './pages/Login.js';
import { AlunoHome } from './pages/aluno/Home.js';
import { PreceptorHome } from './pages/preceptor/Home.js';
import { CuradorHome } from './pages/curador/Home.js';
import { PesquisaHome } from './pages/pesquisa/Home.js';

export function App() {
  return (
    <Routes>
"      <Route path=""/"" element={<Navigate to=""/login"" replace />} />"
"      <Route path=""/login"" element={<Login />} />"
"      <Route path=""/aluno/*"" element={<AlunoHome />} />"
"      <Route path=""/preceptor/*"" element={<PreceptorHome />} />"
"      <Route path=""/curador/*"" element={<CuradorHome />} />"
"      <Route path=""/pesquisa/*"" element={<PesquisaHome />} />"
    </Routes>
  );
}
EOF

"cat > ""$RAIZ/pwa/src/lib/api.ts"" <<'EOF'"
const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

export async function apiGet<T>(caminho: string): Promise<T> {
  const r = await fetch(`${BASE}${caminho}`, { credentials: 'include' });
  if (!r.ok) throw new Error(`GET ${caminho}: ${r.status}`);
  return r.json() as Promise<T>;
}

export async function apiPost<T>(caminho: string, corpo: unknown): Promise<T> {
  const r = await fetch(`${BASE}${caminho}`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(corpo),
  });
  if (!r.ok) throw new Error(`POST ${caminho}: ${r.status}`);
  return r.json() as Promise<T>;
}
EOF

"cat > ""$RAIZ/pwa/src/pages/Login.tsx"" <<'EOF'"
import { useState } from 'react';
import { apiPost } from '../lib/api.js';

export function Login() {
  const [email, setEmail] = useState('');
  const [erro, setErro] = useState<string | null>(null);

  async function entrar(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiPost('/auth/login', { email });
      window.location.href = '/aluno';
    } catch {
      setErro('Falha no login');
    }
  }

  return (
    <form onSubmit={entrar}>
      <h1>Entrar</h1>
"      <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder=""E-mail"" />"
"      <button type=""submit"">Entrar</button>"
"      {erro && <p role=""alert"">{erro}</p>}"
    </form>
  );
}
EOF

# ---------- EXECUTOR ----------

"cat > ""$RAIZ/executor/package.json"" <<'EOF'"
{
"  ""name"": ""programa-cut-executor"","
"  ""version"": ""1.0.0"","
"  ""type"": ""module"","
"  ""scripts"": {"
"    ""dev"": ""tsx watch src/main.ts"","
"    ""build"": ""tsc"","
"    ""start"": ""node dist/main.js"","
"    ""typecheck"": ""tsc --noEmit"""
  },
"  ""dependencies"": {"
"    ""pg"": ""^8.12.0"","
"    ""pino"": ""^9.3.2"""
  },
"  ""devDependencies"": {"
"    ""@types/node"": ""^22.5.0"","
"    ""@types/pg"": ""^8.11.6"","
"    ""tsx"": ""^4.19.0"","
"    ""typescript"": ""^5.5.4"""
  }
}
EOF

"cat > ""$RAIZ/executor/tsconfig.json"" <<'EOF'"
{
"  ""compilerOptions"": {"
"    ""target"": ""ES2022"","
"    ""module"": ""NodeNext"","
"    ""moduleResolution"": ""NodeNext"","
"    ""lib"": [""ES2022""],"
"    ""outDir"": ""dist"","
"    ""rootDir"": ""src"","
"    ""strict"": true,"
"    ""esModuleInterop"": true,"
"    ""skipLibCheck"": true"
  },
"  ""include"": [""src/**/*.ts""]"
}
EOF

"cat > ""$RAIZ/executor/.env.example"" <<'EOF'"
MAESTRO_DATABASE_URL=postgres://maestro_rw:trocar_em_producao@localhost:5432/programa_v44
ANTHROPIC_API_KEY=preencher
INTERVALO_POLL_MS=5000
EOF

"cat > ""$RAIZ/executor/src/main.ts"" <<'EOF'"
import { logger } from './maestro/logger.js';
import { ciclo } from './maestro/ciclo.js';

logger.info('executor iniciado');

const intervalo = Number(process.env.INTERVALO_POLL_MS ?? 5000);

setInterval(async () => {
  try {
    await ciclo();
  } catch (err) {
    logger.error({ err }, 'erro no ciclo');
  }
}, intervalo);
EOF

"cat > ""$RAIZ/executor/src/maestro/logger.ts"" <<'EOF'"
import pino from 'pino';

export const logger = pino({ level: process.env.LOG_LEVEL ?? 'info' });
EOF

"cat > ""$RAIZ/executor/src/maestro/pool.ts"" <<'EOF'"
import pg from 'pg';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.MAESTRO_DATABASE_URL,
  max: 5,
});
EOF

"cat > ""$RAIZ/executor/src/maestro/ciclo.ts"" <<'EOF'"
import { pool } from './pool.js';
import { logger } from './logger.js';

export async function ciclo(): Promise<void> {
  const { rows } = await pool.query<{ job_id: number; skill_codigo: string }>(
    `SELECT job_id, skill_codigo
       FROM maestro.job
      WHERE estado = 'pendente'
      ORDER BY prioridade, criado_em
      LIMIT 1
      FOR UPDATE SKIP LOCKED`,
  );

  if (rows.length === 0) {
    logger.debug({ estado: 'sem_job' }, 'nenhum job pendente');
    return;
  }

  const job = rows[0]!;
  logger.info({ job_id: job.job_id, skill_codigo: job.skill_codigo }, 'job encontrado');
}
EOF

"cat > ""$RAIZ/executor/src/tipos/job.ts"" <<'EOF'"
export interface Job {
  job_id: number;
  tema_id: number | null;
  fase: string;
  skill_codigo: string;
  estado: 'pendente' | 'executando' | 'concluido' | 'falhou' | 'cancelado';
  prioridade: number;
  payload: unknown;
}
EOF

"echo ""=== SCAFFOLDING CONCLUIDO ==="""
"echo ""Verifique:"""
"echo ""  ls $RAIZ/api/package.json"""
"echo ""  ls $RAIZ/pwa/package.json"""
"echo ""  ls $RAIZ/executor/package.json"""
