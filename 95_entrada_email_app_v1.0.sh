#!/usr/bin/env bash
# ============================================================
# 95_entrada_email_app_v1.0.sh
# OBJETIVO: tela e rota da entrada por e-mail (SQL 95), ao lado do "Entrar com o Google".
#  - API: POST /auth/email/pedir e POST /auth/email/entrar (rotas/entrada_email.ts). O e-mail sai pela mesma conta
#    configurada no 52_configurar_email (Gmail com senha de app). Sem e-mail configurado, no teste local, o link
#    aparece na tela e no registro da API.
#  - PWA: campo "Sem conta Google? Entre pelo e-mail" na tela de entrada e a tela /entrar, aberta pelo link.
# USO: bash 95_entrada_email_app_v1.0.sh ./programa-cut      (o subir roda sozinho)
# Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 95_entrada_email_app_v1.0.sh <pasta programa-cut>}"
M="$(cd "$(dirname "$0")" && pwd)/modelos/entrada_email_v1.0"
cp "$M/api/src/routes/entrada_email.ts" "$RAIZ/api/src/routes/"
cp "$M/pwa/src/pages/Login.tsx" "$M/pwa/src/pages/Entrar.tsx" "$RAIZ/pwa/src/pages/"
python3 - "$RAIZ" <<'PY'
import sys, os
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:70]}")
    return s.replace(a, b, 1)
p = os.path.join(raiz, 'api/src/main.ts'); s = ler(p)
s = trocar(s, "import { authRouter } from './routes/auth.js';",
  "import { authRouter } from './routes/auth.js';\nimport { entradaEmailRouter } from './routes/entrada_email.js';", 'entradaEmailRouter }', 'main.ts')
s = trocar(s, "app.use('/auth', limite('auth', 120, 60_000), authRouter);",
  "app.use('/auth/email', limite('auth_email', 10, 60_000), entradaEmailRouter);\napp.use('/auth', limite('auth', 120, 60_000), authRouter);",
  "'/auth/email'", 'main.ts')
gravar(p, s)
# Google: erro no retorno vira a tela de entrada com a explicacao, em vez de uma pagina com codigo
p = os.path.join(raiz, 'api/src/routes/auth.ts'); s = ler(p)
for cod, st in (('parametros_ausentes', 400), ('state_invalido', 400), ('id_token_ausente', 400), ('email_nao_verificado', 403)):
    s = trocar(s, f"res.status({st}).json({{ erro: '{cod}' }});",
               f"res.redirect(`${{config.appUrl}}/login?erro={cod}`);", f"login?erro={cod}", 'auth.ts')
gravar(p, s)
p = os.path.join(raiz, 'pwa/src/App.tsx'); s = ler(p)
s = trocar(s, "import { Login } from './pages/Login.js';",
  "import { Login } from './pages/Login.js';\nimport { Entrar } from './pages/Entrar.js';", "import { Entrar }", 'App.tsx')
s = trocar(s, '        <Route path="/login" element={<Login />} />',
  '        <Route path="/login" element={<Login />} />\n        <Route path="/entrar" element={<Entrar />} />', 'path="/entrar"', 'App.tsx')
gravar(p, s)
p = os.path.join(raiz, 'pwa/src/pages/Cadastro.tsx'); s = ler(p)
s = trocar(s, '<label>E-mail (da sua conta Google)<input value={d.email} readOnly /></label>',
  '<label>E-mail de acesso<input value={d.email} readOnly /></label>', 'E-mail de acesso', 'Cadastro.tsx')
gravar(p, s)
p = os.path.join(raiz, 'pwa/src/estilo.css'); s = ler(p)
if '.botao-link' not in s:
    s += "\n/* entrada por e-mail (95) */\n.botao-link { background: none; border: 0; padding: 0; font: inherit; color: var(--cut-action, var(--acento)); text-decoration: underline; cursor: pointer; }\n.login label.rotulo { display: block; margin-top: 4px; }\n"
gravar(p, s)
print('entrada por e-mail (95): telas e rotas instaladas')
PY
