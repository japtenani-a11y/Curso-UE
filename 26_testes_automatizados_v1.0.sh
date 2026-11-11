#!/usr/bin/env bash
# ============================================================
# 26_testes_automatizados_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: criar os testes automatizados: 3 unitarios, 3 de
# integracao e 4 specs e2e.
#
# USO: bash 26_testes_automatizados_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0, 08b, 09, 10, 11.
# ============================================================
set -euo pipefail

RAIZ="${1:-./programa-cut}"

echo "=== TESTES AUTOMATIZADOS v1.0 ==="

mkdir -p "$RAIZ"/api/test/{unit,integration}
mkdir -p "$RAIZ"/pwa/tests

cat > "$RAIZ/api/test/unit/erro.test.ts" <<'EOF'
import { describe, it, expect } from 'vitest';
import { erroHandler } from '../../src/middleware/erro.js';

function mockRes() {
  const res = {
    statusCode: 0,
    body: null as unknown,
    status(c: number) {
      this.statusCode = c;
      return this;
    },
    json(b: unknown) {
      this.body = b;
      return this;
    },
  };
  return res;
}

describe('erroHandler', () => {
  it('mapeia 23505 para 409', () => {
    const res = mockRes();
    erroHandler({ code: '23505', message: 'duplicado' }, {} as never, res as never, (() => {}) as never);
    expect(res.statusCode).toBe(409);
  });

  it('mapeia 23503 para 422', () => {
    const res = mockRes();
    erroHandler({ code: '23503', message: 'fk' }, {} as never, res as never, (() => {}) as never);
    expect(res.statusCode).toBe(422);
  });

  it('mapeia 23514 para 422', () => {
    const res = mockRes();
    erroHandler({ code: '23514', message: 'check' }, {} as never, res as never, (() => {}) as never);
    expect(res.statusCode).toBe(422);
  });

  it('mapeia 42501 para 403', () => {
    const res = mockRes();
    erroHandler({ code: '42501', message: 'rls' }, {} as never, res as never, (() => {}) as never);
    expect(res.statusCode).toBe(403);
  });

  it('mapeia erro desconhecido para 500', () => {
    const res = mockRes();
    erroHandler(new Error('x'), {} as never, res as never, (() => {}) as never);
    expect(res.statusCode).toBe(500);
  });
});
EOF

cat > "$RAIZ/api/test/unit/role.test.ts" <<'EOF'
import { describe, it, expect } from 'vitest';
import { requireRole } from '../../src/middleware/role.js';

function mockRes() {
  const res = {
    statusCode: 0,
    body: null as unknown,
    status(c: number) {
      this.statusCode = c;
      return this;
    },
    json(b: unknown) {
      this.body = b;
      return this;
    },
  };
  return res;
}

describe('requireRole', () => {
  it('permite papel autorizado', () => {
    const mw = requireRole(['curador']);
    const req = { papel: 'curador' };
    const res = mockRes();
    let chamouNext = false;
    mw(req as never, res as never, (() => { chamouNext = true; }) as never);
    expect(chamouNext).toBe(true);
    expect(res.statusCode).toBe(0);
  });

  it('bloqueia papel nao autorizado com 403', () => {
    const mw = requireRole(['curador']);
    const req = { papel: 'aluno' };
    const res = mockRes();
    let chamouNext = false;
    mw(req as never, res as never, (() => { chamouNext = true; }) as never);
    expect(chamouNext).toBe(false);
    expect(res.statusCode).toBe(403);
  });

  it('bloqueia ausencia de papel com 403', () => {
    const mw = requireRole(['curador']);
    const req = {};
    const res = mockRes();
    mw(req as never, res as never, (() => {}) as never);
    expect(res.statusCode).toBe(403);
  });
});
EOF

cat > "$RAIZ/api/test/unit/ic.test.ts" <<'EOF'
import { describe, it, expect } from 'vitest';

function ic95(p: number, n: number): { inferior: number; superior: number } {
  if (n <= 0) return { inferior: p, superior: p };
  const erro = 1.96 * Math.sqrt((p * (1 - p)) / n);
  return {
    inferior: Math.max(0, p - erro),
    superior: Math.min(1, p + erro),
  };
}

describe('intervalo de confianca 95%', () => {
  it('retorna o proprio p quando n = 0', () => {
    const r = ic95(0.5, 0);
    expect(r.inferior).toBe(0.5);
    expect(r.superior).toBe(0.5);
  });

  it('limita inferior a 0', () => {
    const r = ic95(0.02, 10);
    expect(r.inferior).toBeGreaterThanOrEqual(0);
  });

  it('limita superior a 1', () => {
    const r = ic95(0.98, 10);
    expect(r.superior).toBeLessThanOrEqual(1);
  });

  it('contem o p central', () => {
    const r = ic95(0.7, 40);
    expect(r.inferior).toBeLessThan(0.7);
    expect(r.superior).toBeGreaterThan(0.7);
  });
});
EOF

cat > "$RAIZ/api/test/integration/health.test.ts" <<'EOF'
import { describe, it, expect } from 'vitest';

const BASE = process.env.TEST_API_URL ?? 'http://localhost:3000';

describe('GET /health', () => {
  it('retorna status ok', async () => {
    const r = await fetch(`${BASE}/health`);
    expect(r.status).toBe(200);
    const body = (await r.json()) as { status: string; db: string };
    expect(body.status).toBe('ok');
    expect(body.db).toBe('ok');
  });
});
EOF

cat > "$RAIZ/api/test/integration/auth.test.ts" <<'EOF'
import { describe, it, expect } from 'vitest';

const BASE = process.env.TEST_API_URL ?? 'http://localhost:3000';

describe('POST /auth/login', () => {
  it('rejeita email ausente com 400', async () => {
    const r = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    });
    expect(r.status).toBe(400);
  });

  it('rejeita email inexistente com 404', async () => {
    const r = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'nao.existe@setup.local' }),
    });
    expect(r.status).toBe(404);
  });

  it('aceita email cadastrado e emite cookie', async () => {
    const r = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'r1.teste@setup.local' }),
    });
    expect(r.status).toBe(200);
    const cookie = r.headers.get('set-cookie');
    expect(cookie).toContain('sessao=');
  });
});
EOF

cat > "$RAIZ/api/test/integration/aluno.test.ts" <<'EOF'
import { describe, it, expect } from 'vitest';

const BASE = process.env.TEST_API_URL ?? 'http://localhost:3000';

async function login(): Promise<string> {
  const r = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'r1.teste@setup.local' }),
  });
  const cookie = r.headers.get('set-cookie') ?? '';
  return cookie.split(';')[0] ?? '';
}

describe('GET /aluno/ondas', () => {
  it('rejeita sem sessao com 401', async () => {
    const r = await fetch(`${BASE}/aluno/ondas`);
    expect(r.status).toBe(401);
  });

  it('retorna ondas com sessao valida', async () => {
    const cookie = await login();
    const r = await fetch(`${BASE}/aluno/ondas`, { headers: { Cookie: cookie } });
    expect(r.status).toBe(200);
    const body = (await r.json()) as { ondas: unknown[] };
    expect(Array.isArray(body.ondas)).toBe(true);
  });
});
EOF

cat > "$RAIZ/pwa/tests/login.spec.ts" <<'EOF'
import { test, expect } from '@playwright/test';

test('tela de login carrega', async ({ page }) => {
  await page.goto('/login');
  await expect(page.getByRole('heading', { name: 'Entrar' })).toBeVisible();
});

test('login com email invalido mostra erro', async ({ page }) => {
  await page.goto('/login');
  await page.getByPlaceholder('E-mail').fill('nao.existe@setup.local');
  await page.getByRole('button', { name: 'Entrar' }).click();
  await expect(page.getByRole('alert')).toBeVisible();
});
EOF

cat > "$RAIZ/pwa/tests/aluno.spec.ts" <<'EOF'
import { test, expect } from '@playwright/test';

test('aluno ve lista de ondas', async ({ page }) => {
  await page.goto('/aluno');
  await expect(page.getByRole('heading', { name: 'Minhas ondas' })).toBeVisible();
});
EOF

cat > "$RAIZ/pwa/tests/curador.spec.ts" <<'EOF'
import { test, expect } from '@playwright/test';

test('curador ve painel com temas e gates', async ({ page }) => {
  await page.goto('/curador');
  await expect(page.getByRole('heading', { name: 'Painel do curador' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Temas' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Gates' })).toBeVisible();
});
EOF

cat > "$RAIZ/pwa/tests/pesquisa.spec.ts" <<'EOF'
import { test, expect } from '@playwright/test';

test('pesquisa ve grafico de retencao', async ({ page }) => {
  await page.goto('/pesquisa');
  await expect(page.getByRole('heading', { name: 'Pesquisa' })).toBeVisible();
  await expect(page.getByRole('img', { name: 'Curva de retencao por onda' })).toBeVisible();
});
EOF

cat > "$RAIZ/pwa/playwright.config.ts" <<'EOF'
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  use: {
    baseURL: 'http://localhost:5173',
    headless: true,
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: true,
  },
});
EOF

echo "=== TESTES AUTOMATIZADOS CONCLUIDOS ==="
echo "Verifique:"
echo "  ls $RAIZ/api/test/unit/"
echo "  ls $RAIZ/api/test/integration/"
echo "  ls $RAIZ/pwa/tests/"
