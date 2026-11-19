#!/usr/bin/env bash
# ============================================================
# 83_ajustes_app_v1.0.sh
# OBJETIVO: telas dos ajustes do SQL 83.
#  - Testes e tela do tema: pre-teste 2 fora do prazo continua disponivel, com o aviso de que, feito depois da aula,
#    fica registrado assim; o enviado depois da aula aparece como "respondido depois da aula".
#  - Painel: abas "Caso da aula" e "Caso base" (respostas dos alunos; pesquisador ve o codigo, nao o nome).
#  - Nome CUT no lugar do nome antigo do programa (por extenso e a sigla antiga) em todas as telas.
# USO: bash 83_ajustes_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 61, 76, 82. Rodar depois do 82. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 83_ajustes_app_v1.0.sh <pasta programa-cut>}"
python3 - "$RAIZ" <<'PY'
import sys, os, re, glob
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:70]}")
    return s.replace(a, b, 1)

# Testes: situacao de cada teste na lista
p = os.path.join(raiz, 'pwa/src/pages/aluno/Testes.tsx'); s = ler(p)
s = trocar(s, "  if (t.submetida_em) return 'Respondido';",
  "  if (t.submetida_em) return t.teste_num === 2 && t.data_fechamento && new Date(t.submetida_em) > new Date(t.data_fechamento)\n"
  "    ? 'Respondido fora do prazo (se foi depois da aula, fica registrado assim)' : 'Respondido';",
  'Respondido fora do prazo', 'Testes.tsx')
s = trocar(s, "  return t.teste_num === 2 ? `Liberado · prazo: até ${dataHora(t.data_fechamento)} (1 hora antes da aula)` : 'Liberado';",
  "  if (t.teste_num === 2 && new Date(t.data_fechamento) <= new Date()) return 'Fora do prazo: ainda dá para fazer, mas, depois da aula, fica registrado como feito com o conteúdo já apresentado';\n"
  "  return t.teste_num === 2 ? `Liberado · prazo: até ${dataHora(t.data_fechamento)} (1 hora antes da aula)` : 'Liberado';",
  'Fora do prazo: ainda dá para fazer', 'Testes.tsx')
gravar(p, s)

# Tela do tema: pre-teste 2 atrasado ainda disponivel
p = os.path.join(raiz, 'pwa/src/pages/aluno/Tema.tsx'); s = ler(p)
s = trocar(s, "  if (t.perdido) return { rotulo: 'prazo encerrado', classe: 'perdido' };",
  "  if (t.perdido && t.respondivel) return { rotulo: 'fora do prazo · ainda dá para fazer', classe: 'aberto' };\n"
  "  if (t.perdido) return { rotulo: 'prazo encerrado', classe: 'perdido' };", 'fora do prazo · ainda', 'Tema.tsx')
gravar(p, s)

# Painel
p = os.path.join(raiz, 'api/src/routes/painel.ts'); s = ler(p)
s = trocar(s, "  leitura: 'SELECT * FROM app.painel_leitura()',",
  "  leitura: 'SELECT * FROM app.painel_leitura()',\n  caso: 'SELECT * FROM app.painel_caso()',\n  caso_base: 'SELECT * FROM app.painel_caso_base()',",
  'app.painel_caso()', 'painel.ts')
gravar(p, s)
p = os.path.join(raiz, 'pwa/src/pages/painel/Painel.tsx'); s = ler(p)
s = trocar(s, "| 'certeza' | 'leitura';", "| 'certeza' | 'leitura' | 'caso' | 'caso_base';", "| 'caso' | 'caso_base'", 'Painel.tsx')
s = trocar(s, "  { id: 'mensagens', rotulo: 'Dúvidas e feedback' },",
  "  { id: 'caso', rotulo: 'Caso da aula' }, { id: 'caso_base', rotulo: 'Caso base' },\n  { id: 'mensagens', rotulo: 'Dúvidas e feedback' },",
  "rotulo: 'Caso da aula'", 'Painel.tsx')
gravar(p, s)

# Nome CUT em todas as telas
n = 0
for f in glob.glob(os.path.join(raiz, 'pwa/src/**/*.ts*'), recursive=True) + glob.glob(os.path.join(raiz, 'api/src/**/*.ts'), recursive=True) \
        + [os.path.join(raiz, 'pwa/index.html'), os.path.join(raiz, 'pwa/public/manifest.webmanifest'), os.path.join(raiz, 'pwa/public/manifest.json')]:
    if not os.path.exists(f): continue
    s = ler(f)
    s2 = re.sub(r'Programa de Cirurgia de Urg[eê]ncia e Trauma', 'CUT', s)
    s2 = re.sub(r'UE[ -]TRAUMA( 2027)?', 'CUT', s2)
    if s2 != s: gravar(f, s2); n += 1
print(f"ajustes v2p: telas prontas ({n} arquivos com o nome trocado para CUT)")
PY
