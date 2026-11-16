#!/usr/bin/env bash
# ============================================================
# 76_certeza_app_v1.0.sh
# OBJETIVO: tela de testes do aluno no padrao do Design System CUT, com a certeza marcada em cada questao.
#  - Uma questao por tela, progresso "questao 3 de 12", resposta salva na hora e retomada de onde parou.
#  - Em cada questao: alternativa + certeza ("Chutei", "Acho que sim", "Tenho certeza"), antes de qualquer gabarito.
#  - Revisao antes de enviar; o envio exige alternativa e certeza em todas.
#  - Gabarito em azul (acerto) e laranja (erro), com icone e texto, a certeza marcada e os erros com
#    "tenho certeza" destacados no alto. Substitui a confianca unica de 0 a 100% por teste.
#  - Respostas guardadas tambem no aparelho quando a internet cai; aviso de sem conexao; mensagens de erro separadas.
#  - Inicio: testes pendentes em destaque, com botao direto para responder.
#  - API (/teste): grava e devolve a certeza. Painel: aba "Certeza por questao" (vem do 61).
# USO: bash 76_certeza_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 40, 56, 61, 74, 75 (scripts) e, no banco, 76_certeza_questao_v1.0.sql. Pode ser rodado mais de uma vez.
# DESFAZER: rodar de novo do 40 ao 75 (o 40 recria a tela antiga).
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 76_certeza_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/certeza_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/teste.ts" ] || { echo "ERRO: rode antes o 40_testes_aluno_v1.0.sh"; exit 1; }
grep -q -- "--cut-surface" "$PWA/estilo.css" || { echo "ERRO: rode antes o 75_arvore_app_v1.0.sh (tema CUT)"; exit 1; }
cp "$M/pwa/src/pages/aluno/Testes.tsx" "$PWA/pages/aluno/Testes.tsx"
cp "$M/pwa/src/components/Lembretes.tsx" "$PWA/components/Lembretes.tsx"
python3 - "$PWA/estilo.css" "$M/estilo_testes.css" "testes v2 (uma" <<'PY'
import sys
css, novo, marca = sys.argv[1], open(sys.argv[2]).read(), sys.argv[3]
s = open(css).read()
i = s.find("/* ---------- " + marca)
if i < 0:
    s = s.rstrip("\n") + "\n" + novo
else:
    j = s.find("/* ---------- ", i + 10)
    s = s[:i].rstrip("\n") + "\n" + novo.lstrip("\n").rstrip("\n") + "\n" + ("\n" + s[j:] if j >= 0 else "")
open(css, "w").write(s)
PY
python3 - "$API/routes/teste.ts" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
def trocar(a, b, marca):
    global s
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em teste.ts: {a[:80]}")
    s = s.replace(a, b, 1)
# abrir: devolve a certeza ja marcada (retomar de onde parou)
trocar("(SELECT r.alternativa_id FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id) AS resposta",
       "(SELECT r.alternativa_id FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id) AS resposta,\n"
       "                (SELECT r.certeza FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id) AS certeza",
       "r.certeza FROM app.resposta r WHERE r.tentativa_id = $3")
# gravar: aceita a certeza (1 a 3); nao apaga certeza nem tempo ja gravados quando vierem vazios
trocar("respostas?: { item_id: number; alternativa_id: number; tempo_resposta_ms?: number }[]",
       "respostas?: { item_id: number; alternativa_id: number; tempo_resposta_ms?: number; certeza?: number | null }[]", "certeza?: number | null")
trocar("""          `INSERT INTO app.resposta (tentativa_id, item_id, alternativa_id, tempo_resposta_ms)
           SELECT $1, i.item_id, a.alternativa_id, $5""",
       """          `INSERT INTO app.resposta (tentativa_id, item_id, alternativa_id, tempo_resposta_ms, certeza)
           SELECT $1, i.item_id, a.alternativa_id, $5, $7""", "tempo_resposta_ms, certeza)")
trocar("""           ON CONFLICT (tentativa_id, item_id) DO UPDATE SET alternativa_id = EXCLUDED.alternativa_id,
                  tempo_resposta_ms = EXCLUDED.tempo_resposta_ms, respondida_em = now()`,""",
       """           ON CONFLICT (tentativa_id, item_id) DO UPDATE SET alternativa_id = EXCLUDED.alternativa_id,
                  tempo_resposta_ms = coalesce(EXCLUDED.tempo_resposta_ms, app.resposta.tempo_resposta_ms),
                  certeza = coalesce(EXCLUDED.certeza, app.resposta.certeza), respondida_em = now()`,""", "certeza = coalesce(EXCLUDED.certeza")
trocar("x.tempo_resposta_ms == null ? null : Math.max(0, Math.round(Number(x.tempo_resposta_ms))), tent.perfil]);",
       "x.tempo_resposta_ms == null ? null : Math.max(0, Math.round(Number(x.tempo_resposta_ms))), tent.perfil,\n"
       "           [1, 2, 3].includes(Number(x.certeza)) ? Number(x.certeza) : null]);", "[1, 2, 3].includes(Number(x.certeza))")
# rascunho: com o teste aberto, cada resposta vai para app.resposta_rascunho (app.resposta e imutavel; so recebe no envio)
trocar("      if (tent.submetida_em) return { erro: 'teste_ja_submetido', status: 409 };\n",
       "      if (tent.submetida_em) return { erro: 'teste_ja_submetido', status: 409 };\n"
       "      if (!corpo.submeter) {\n"
       "        let salvas = 0;\n"
       "        for (const x of respostas) {\n"
       "          const q = await client.query('SELECT app.salvar_rascunho($1, $2, $3, $4, $5) AS ok',\n"
       "            [ondaId, Number(x.item_id), Number(x.alternativa_id), [1, 2, 3].includes(Number(x.certeza)) ? Number(x.certeza) : null,\n"
       "             x.tempo_resposta_ms == null ? null : Math.max(0, Math.round(Number(x.tempo_resposta_ms)))]);\n"
       "          if (q.rows[0]?.ok) salvas++;\n"
       "        }\n"
       "        return { ok: true, submetido: false, salvas };\n"
       "      }\n", "app.salvar_rascunho($1")
trocar("      return { teste_num: onda.teste_num, perfil: onda.perfil, tentativa: tent.rows[0], caso: caso.rows[0] ?? null, itens: itens.rows };",
       "      const rasc = await client.query('SELECT item_id, alternativa_id, certeza FROM app.rascunho_onda($1)', [ondaId]);\n"
       "      const porItem = new Map(rasc.rows.map((x: { item_id: string | number; alternativa_id: number; certeza: number | null }) => [Number(x.item_id), x]));\n"
       "      const comRascunho = itens.rows.map((i: { item_id: number; resposta: number | null; certeza: number | null }) => {\n"
       "        const x = porItem.get(Number(i.item_id));\n"
       "        return x ? { ...i, resposta: i.resposta ?? x.alternativa_id, certeza: i.certeza ?? x.certeza } : i;\n"
       "      });\n"
       "      return { teste_num: onda.teste_num, perfil: onda.perfil, tentativa: tent.rows[0], caso: caso.rows[0] ?? null, itens: comRascunho };",
       "app.rascunho_onda($1)")
# enviar: exige alternativa e certeza em todas
trocar("AND NOT EXISTS (SELECT 1 FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id)`,",
       "AND NOT EXISTS (SELECT 1 FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id AND r.certeza IS NOT NULL)`,",
       "r.item_id = i.item_id AND r.certeza IS NOT NULL")
# gabarito: devolve a certeza marcada
trocar("SELECT i.item_id, i.enunciado, i.fixa, i.dificuldade, i.ancora, r.alternativa_id AS escolhida,",
       "SELECT i.item_id, i.enunciado, i.fixa, i.dificuldade, i.ancora, r.alternativa_id AS escolhida, r.certeza,", "r.alternativa_id AS escolhida, r.certeza,")
trocar("GROUP BY i.item_id, i.enunciado, i.fixa, i.dificuldade, i.ancora, r.alternativa_id\n",
       "GROUP BY i.item_id, i.enunciado, i.fixa, i.dificuldade, i.ancora, r.alternativa_id, r.certeza\n", "r.alternativa_id, r.certeza\n")
open(p, "w").write(s)
PY
echo "certeza por questao instalada: Testes.tsx (uma questao por tela), teste.ts (certeza), estilo.css (testes v2)"
