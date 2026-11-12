#!/usr/bin/env bash
# ============================================================
# 51_acabamento_app_v1.0.sh
# OBJETIVO: acabamento do aplicativo e da API antes da revisao externa.
#  - Visual: casca unica (topo com navegacao por papel, rodape), paleta dos slides, modo escuro,
#    telas responsivas (celular), pagina inicial do aluno com as etapas do tema, login com Google.
#  - Fluidez: "/" leva cada papel a sua tela; aplicativo instalavel (manifest + service worker que
#    guarda so a casca, nunca o conteudo).
#  - Protecao do conteudo: marca d'agua com nome, e-mail e data de quem abriu; bloqueio de copia,
#    arrastar, menu do botao direito e impressao; cabecalhos no-store/noindex; registro de cada
#    acesso (app.acesso_conteudo) e bloqueio de raspagem (mais de 600 acessos/hora).
#  - Seguranca: limite de tentativas no login, proxy confiavel no servidor, rotas protegidas por papel.
#  - Leitor de markdown: listas numeradas e com subitens, links, italico e os codigos de todas as camadas.
#  - Revisao: abas na ordem pedagogica das pecas.
# USO: bash 51_acabamento_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 32, 34, 40, 44 e 46 (scripts) e, no banco, 49_revisores_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 51_acabamento_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/acabamento_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa"
[ -d "$M" ] || { echo "ERRO: pasta $M nao encontrada"; exit 1; }
[ -f "$API/routes/contato.ts" ] || { echo "ERRO: rode antes o 46_notificacoes_app_v1.0.sh"; exit 1; }

# ---------- PWA: arquivos novos ou substituidos ----------
mkdir -p "$PWA/public" "$PWA/src/lib" "$PWA/src/components" "$PWA/src/pages/aluno"
cp "$M/pwa/index.html" "$PWA/index.html"
cp "$M/pwa/public/"* "$PWA/public/"
cp "$M/pwa/src/estilo.css" "$M/pwa/src/main.tsx" "$M/pwa/src/App.tsx" "$PWA/src/"
cp "$M/pwa/src/lib/sessao.tsx" "$M/pwa/src/lib/md.tsx" "$PWA/src/lib/"
cp "$M/pwa/src/components/Layout.tsx" "$M/pwa/src/components/Protecao.tsx" "$PWA/src/components/"
cp "$M/pwa/src/pages/Login.tsx" "$M/pwa/src/pages/Inicio.tsx" "$PWA/src/pages/"
cp "$M/pwa/src/pages/aluno/Home.tsx" "$PWA/src/pages/aluno/Home.tsx"
echo "atualizados: index.html, public/, estilo.css, main.tsx, App.tsx, lib/sessao.tsx, lib/md.tsx, Layout, Protecao, Login, Inicio, aluno/Home"

python3 - "$PWA/src" <<'PY'
import sys, re
src = sys.argv[1]
# Leitura do aluno: tira os codigos de todas as camadas ([H1], [D2, A3], [G5]...) do texto do aluno.
p = f"{src}/pages/aluno/Leitura.tsx"; s = open(p).read()
s = s.replace(r".replace(/\s*\[A\d+(?:,\s*A\d+)*\]/g, '')", r".replace(/\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]/g, '')")
s = s.replace(r"texto.replace(/(\s+A\d+)+$/, '')", r"texto.replace(/(\s+[ADPHG][1-9]\d*)+$/, '')")
open(p, "w").write(s)
# Contato: WhatsApp so aparece se VITE_WHATSAPP=1 (por ora, so e-mail).
p = f"{src}/pages/aluno/Contato.tsx"; s = open(p).read()
if "MOSTRAR_ZAP" not in s:
    s = s.replace("export function Contato() {", "const MOSTRAR_ZAP = import.meta.env.VITE_WHATSAPP === '1';\n\nexport function Contato() {", 1)
    s = s.replace("<label>WhatsApp (com DDD)", "{MOSTRAR_ZAP && <label>WhatsApp (com DDD)", 1)
    s = s.replace('placeholder="(16) 99999-0000" />\n      </label>', 'placeholder="(16) 99999-0000" />\n      </label>}', 1)
    s = s.replace("<label style={{ display: 'block', margin: '8px 0' }}>\n        <input type=\"checkbox\" checked={aZap}", "{MOSTRAR_ZAP && <label style={{ display: 'block', margin: '8px 0' }}>\n        <input type=\"checkbox\" checked={aZap}", 1)
    s = s.replace("Autorizo lembretes por WhatsApp\n      </label>", "Autorizo lembretes por WhatsApp\n      </label>}", 1)
    s = s.replace("receber os lembretes por e-mail e WhatsApp:", "receber os lembretes também por e-mail:", 1)
    s = s.replace("<a href=\"/aluno\">Voltar</a>", "<a href=\"/aluno\">Voltar ao início</a>", 1)
    open(p, "w").write(s)
    if s.count("MOSTRAR_ZAP") < 3: sys.exit("ERRO: nao consegui ajustar a tela de contato")
PY
echo "atualizados: Leitura (codigos de todas as camadas), Contato (WhatsApp desligado)"

# ---------- API ----------
mkdir -p "$API/middleware"
cp "$M/api/src/middleware/protecao.ts" "$API/middleware/protecao.ts"
python3 - "$API" <<'PY'
import sys
api = sys.argv[1]
p = f"{api}/main.ts"; s = open(p).read()
if "middleware/protecao.js" not in s:
    s = s.replace("import { contatoRouter } from './routes/contato.js';",
                  "import { contatoRouter } from './routes/contato.js';\nimport { limite, conteudoProtegido } from './middleware/protecao.js';", 1)
    s = s.replace("const app = express();", "const app = express();\nif (config.producao) app.set('trust proxy', 1);\napp.disable('x-powered-by');", 1)
    s = s.replace("app.use('/auth', authRouter);", "app.use('/auth', limite('auth', 120, 60_000), authRouter);", 1)
    for r in ("revisao", "leitura", "teste"):
        s = s.replace(f"app.use('/{r}', {r}Router);", f"app.use('/{r}', limite('{r}', 240, 60_000), conteudoProtegido, {r}Router);", 1)
    open(p, "w").write(s)
    for x in ("trust proxy", "limite('auth'", "conteudoProtegido, revisaoRouter", "conteudoProtegido, leituraRouter", "conteudoProtegido, testeRouter"):
        if x not in s: sys.exit(f"ERRO: nao consegui ajustar main.ts ({x})")
# Revisao: pecas na ordem pedagogica.
p = f"{api}/routes/revisao.ts"; s = open(p).read()
ordem = ("ARRAY['objetivos','resumo_basico','podcast_roteiro','caso_base','sintese_evidencia','resumo','mapa','flashcard',"
         "'protocolo','checklist','aula','slides','caso','teste_1','gabarito_1','teste_2','gabarito_2','teste_3','gabarito_3',"
         "'teste_4','gabarito_4','teste_5','gabarito_5','teste_6','gabarito_6','banco_dificuldade']")
if "array_position(ARRAY['objetivos'" not in s and "ORDER BY a.tipo`" in s:
    s = s.replace("ORDER BY a.tipo`", f"ORDER BY coalesce(array_position({ordem}, a.tipo::text), 99), a.tipo`", 1)
    open(p, "w").write(s)
PY
echo "atualizados: api main.ts (limites, protecao, proxy) e revisao.ts (ordem das pecas)"

# ---------- gateway do servidor ----------
mkdir -p "$RAIZ/servidor"
cp "$M/servidor/gateway.mjs" "$RAIZ/servidor/gateway.mjs"
echo "criado: servidor/gateway.mjs"
echo "=== acabamento instalado ==="
