#!/usr/bin/env bash
# ============================================================
# 98_embaralhar_ancoras_app_v1.0.sh
# OBJETIVO: as questoes ancora (fixas) aparecem com as alternativas em ordem diferente em cada onda (teste 1 a 6),
# para o aluno nao acertar pela letra que viu no gabarito da onda anterior. A ordem e fixa dentro da mesma onda
# (a mesma no teste e no gabarito) e e calculada por md5(codigo da questao : ordem da alternativa : numero do teste),
# a mesma regra que o importador usa nos testes e gabaritos em texto. As questoes de caso nao mudam.
# A resposta continua gravada pelo id da alternativa: nada muda no banco nem nas respostas ja dadas.
# USO: bash 98_embaralhar_ancoras_app_v1.0.sh ./programa-cut   (o subir roda sozinho, depois do 97)
# Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 98_embaralhar_ancoras_app_v1.0.sh <pasta programa-cut>}"
python3 - "$RAIZ" <<'PY'
import sys, os
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
CHAVE = "CASE WHEN i.fixa THEN md5(coalesce(i.codigo, i.item_id::text) || ':' || a.ordem::text || ':' || coalesce({n}, '0')) ELSE lpad(a.ordem::text, 4, '0') END"

# 1) teste.ts: tela do teste e gabarito da onda
p = os.path.join(raiz, 'api/src/routes/teste.ts'); s = ler(p)
if 'ancora_embaralhada' not in s:
    a = "json_agg(json_build_object('alternativa_id', a.alternativa_id, 'ordem', a.ordem, 'texto', a.texto) ORDER BY a.ordem) AS alternativas,"
    b = ("json_agg(json_build_object('alternativa_id', a.alternativa_id, 'ordem', a.ordem, 'texto', a.texto) ORDER BY "
         + CHAVE.format(n="(SELECT o.teste_num FROM app.onda_instancia o WHERE o.onda_id = $1)::text") + ") AS alternativas, /* ancora_embaralhada */")
    if s.count(a) != 1: sys.exit('ERRO: nao encontrei a consulta das alternativas do teste em teste.ts')
    s = s.replace(a, b)
    a = "'correta', a.eh_correta, 'categoria', a.categoria_distrator, 'justificativa', a.justificativa) ORDER BY a.ordem) AS alternativas"
    b = ("'correta', a.eh_correta, 'categoria', a.categoria_distrator, 'justificativa', a.justificativa) ORDER BY "
         + CHAVE.format(n="(SELECT o.teste_num FROM app.tentativa t2 JOIN app.onda_instancia o ON o.onda_id = t2.onda_id WHERE t2.tentativa_id = $1)::text")
         + ") AS alternativas")
    if s.count(a) != 1: sys.exit('ERRO: nao encontrei a consulta das alternativas do gabarito em teste.ts')
    s = s.replace(a, b)
    gravar(p, s)

# 2) aluno.ts: rota antiga das tentativas (mesma regra)
p = os.path.join(raiz, 'api/src/routes/aluno.ts')
if os.path.exists(p):
    s = ler(p)
    if 'ancora_embaralhada' not in s:
        a = """                  'texto', a.texto
                ) ORDER BY a.ordem) AS alternativas"""
        if s.count(a) == 1:
            s = s.replace(a, """                  'texto', a.texto
                ) ORDER BY """ + CHAVE.format(n="(SELECT o.teste_num FROM app.onda_instancia o WHERE o.onda_id = t.onda_id)::text") + ") AS alternativas /* ancora_embaralhada */")
            gravar(p, s)
print('ancoras: alternativas embaralhadas por onda')
PY
