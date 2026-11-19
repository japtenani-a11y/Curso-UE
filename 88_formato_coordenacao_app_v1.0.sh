#!/usr/bin/env bash
# ============================================================
# 88_formato_coordenacao_app_v1.0.sh
# OBJETIVO: telas do SQL 88 (formato, ancoras, tempo de estudo) e do SQL 89 (agentes da coordenacao).
#  - Material do aluno: cada peca mostra "Essencial · N min" ou "Aprofundamento · N min"; cada grupo mostra o tempo
#    essencial. Na previa, a conferencia de formato da peca aberta.
#  - Revisao: conferencia de formato da peca; o botao de publicar fica bloqueado com erro de formato; a mensagem do banco
#    aparece se a publicacao for recusada.
#  - Painel: abas "Para revisar" (propostas dos agentes: aprovar, aprovar com alteracao, vetar) e "Conferencia dos temas".
#  - Telas antigas no Design System: Contato (lembretes), Leitura e Revisao sem cor ou fonte fixa.
# USO: bash 88_formato_coordenacao_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 82, 85, 87 (rodar depois deles). Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 88_formato_coordenacao_app_v1.0.sh <pasta programa-cut>}"
M="$(cd "$(dirname "$0")" && pwd)/modelos/interativo_v1.0"
cp "$M/api/src/routes/coordenacao.ts" "$RAIZ/api/src/routes/"
cp "$M"/pwa/src/components/leitura/*.tsx "$RAIZ/pwa/src/components/leitura/"
cp "$M/pwa/src/pages/aluno/Contato.tsx" "$RAIZ/pwa/src/pages/aluno/Contato.tsx"
python3 - "$RAIZ" "$M" <<'PY'
import sys, os, re
raiz, m = sys.argv[1], sys.argv[2]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:70]}")
    return s.replace(a, b, 1)
def tokens(s):
    # cores e fonte fixas -> variaveis do Design System CUT (modo escuro passa a funcionar)
    s = s.replace('font-family:system-ui,sans-serif', 'font-family:var(--cut-font)')
    s = s.replace('background:#fff', 'background:var(--cut-surface-raised)')
    return s.replace('color:#fff', 'color:var(--cut-on-action)')

# API: rota da coordenacao
p = os.path.join(raiz, 'api/src/main.ts'); s = ler(p)
s = trocar(s, "import { painelRouter } from './routes/painel.js';",
  "import { painelRouter } from './routes/painel.js';\nimport { coordenacaoRouter } from './routes/coordenacao.js';", 'coordenacaoRouter }', 'main.ts')
s = trocar(s, "app.use('/painel', limite('painel', 120, 60_000), painelRouter);",
  "app.use('/painel', limite('painel', 120, 60_000), painelRouter);\napp.use('/coordenacao', limite('coordenacao', 240, 60_000), coordenacaoRouter);",
  "app.use('/coordenacao'", 'main.ts')
gravar(p, s)

# API: erro de formato com a mensagem do banco
p = os.path.join(raiz, 'api/src/middleware/erro.ts'); s = ler(p)
s = trocar(s, "  if (e.code === '23514') {",
  "  if (e.code === '23514' && String(e.message ?? '').startsWith('formato_invalido')) {\n"
  "    res.status(422).json({ erro: 'formato_invalido', detalhe: String(e.message).replace(/^formato_invalido:\\s*/, '') });\n    return;\n  }\n"
  "  if (e.code === '23514') {", "erro: 'formato_invalido'", 'erro.ts')
gravar(p, s)

# API: revisao devolve a conferencia de formato e o motivo da recusa
p = os.path.join(raiz, 'api/src/routes/revisao.ts'); s = ler(p)
s = trocar(s, "(SELECT row_to_json(s) FROM app.situacao_revisao(a.artefato_id) s) AS situacao",
  "(SELECT row_to_json(s) FROM app.situacao_revisao(a.artefato_id) s) AS situacao, app.formato_peca(a.artefato_id) AS formato",
  'app.formato_peca(a.artefato_id) AS formato', 'revisao.ts')
s = trocar(s, "    const m = (err as { message?: string }).message ?? '';\n    for (const e of ['revisao_incompleta_ou_fora_da_tolerancia',",
  "    const m = (err as { message?: string }).message ?? '';\n"
  "    if (m.startsWith('formato_invalido')) { res.status(422).json({ erro: 'formato_invalido', detalhe: m.replace(/^formato_invalido:\\s*/, '') }); return; }\n"
  "    for (const e of ['revisao_incompleta_ou_fora_da_tolerancia',", "m.startsWith('formato_invalido')", 'revisao.ts')
gravar(p, s)

# API: leitura devolve tempo de estudo (e formato na previa)
p = os.path.join(raiz, 'api/src/routes/leitura.ts'); s = ler(p)
s = trocar(s, "a.corpo, app.etapa_do_material(a.tipo::text) AS etapa\n",
  "a.corpo, app.etapa_do_material(a.tipo::text) AS etapa,\n"
  "                (SELECT row_to_json(tp) FROM app.tempo_peca(a.artefato_id) tp) AS tempo,\n"
  "                CASE WHEN $2 = 'rascunho' THEN app.formato_peca(a.artefato_id) END AS formato\n",
  'app.tempo_peca(a.artefato_id) tp', 'leitura.ts')
gravar(p, s)

# API: painel, conferencia dos temas
p = os.path.join(raiz, 'api/src/routes/painel.ts'); s = ler(p)
s = trocar(s, "  indicadores: 'SELECT * FROM app.painel_indicadores()',",
  "  indicadores: 'SELECT * FROM app.painel_indicadores()',\n  conferencia: 'SELECT * FROM app.painel_conferencia()',",
  'app.painel_conferencia()', 'painel.ts')
s = trocar(s, "  conferencia: 'SELECT * FROM app.painel_conferencia()',",
  "  conferencia: 'SELECT * FROM app.painel_conferencia()',\n  prazos: 'SELECT * FROM app.painel_prazos()',",
  'app.painel_prazos()', 'painel.ts')
gravar(p, s)

# PWA: material do aluno
p = os.path.join(raiz, 'pwa/src/pages/aluno/Leitura.tsx'); s = ler(p)
s = trocar(s, "interface Artefato { artefato_id: number; tipo: string; versao: number; titulo: string; corpo: string }",
  "interface Artefato { artefato_id: number; tipo: string; versao: number; titulo: string; corpo: string;\n"
  "  tempo?: { nivel: string | null; minutos: number | null } | null; formato?: { gravidade: 'erro' | 'aviso'; mensagem: string }[] | null }",
  'formato?: { gravidade', 'Leitura.tsx')
s = trocar(s, "import { AbasPorEtapa } from '../../components/leitura/AbasPorEtapa.js';",
  "import { AbasPorEtapa } from '../../components/leitura/AbasPorEtapa.js';\nimport { FormatoPeca } from '../../components/leitura/FormatoPeca.js';",
  'FormatoPeca }', 'Leitura.tsx')
s = trocar(s, "etapa={dados.etapa ?? 1} previa={dados.previa} />\n",
  "etapa={dados.etapa ?? 1} previa={dados.previa} />\n          {dados.previa && <FormatoPeca itens={art.formato} />}\n",
  '<FormatoPeca itens', 'Leitura.tsx')
gravar(p, tokens(s))

# PWA: revisao
p = os.path.join(raiz, 'pwa/src/pages/curador/Revisao.tsx'); s = ler(p)
s = trocar(s, "  afirmacoes: Afirmacao[]; pareceres: Parecer[];",
  "  afirmacoes: Afirmacao[]; pareceres: Parecer[]; formato?: { gravidade: 'erro' | 'aviso'; mensagem: string }[] | null;",
  'formato?: { gravidade', 'Revisao.tsx')
s = trocar(s, "import { Markdown } from '../../lib/md.js';",
  "import { Markdown } from '../../lib/md.js';\nimport { FormatoPeca } from '../../components/leitura/FormatoPeca.js';", 'FormatoPeca }', 'Revisao.tsx')
s = trocar(s, "  const podePublicar = art.situacao?.pode_publicar === true;",
  "  const errosFormato = (art.formato ?? []).filter((f) => f.gravidade === 'erro').length;\n"
  "  const podePublicar = art.situacao?.pode_publicar === true && errosFormato === 0;", 'errosFormato', 'Revisao.tsx')
s = trocar(s, "      await apiPost(`/revisao/artefatos/${art.artefato_id}/publicar`, {});\n"
  "      setAviso(`\"${art.titulo}\" publicado. Ele sai da lista de rascunhos e aparece para os alunos.`);\n"
  "      setAtivo(0); carregar();\n"
  "    } catch { setAviso('Não foi possível publicar: a revisão ainda não está completa ou está fora da tolerância.'); }",
  "      const base = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';\n"
  "      const r = await fetch(`${base}/revisao/artefatos/${art.artefato_id}/publicar`, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' }, body: '{}' });\n"
  "      if (!r.ok) {\n"
  "        const e = (await r.json().catch(() => ({}))) as { erro?: string; detalhe?: string };\n"
  "        setAviso(e.erro === 'formato_invalido' ? `Não foi possível publicar: erro de formato. ${e.detalhe ?? ''}`\n"
  "          : 'Não foi possível publicar: a revisão ainda não está completa ou está fora da tolerância.');\n"
  "        return;\n"
  "      }\n"
  "      setAviso(`\"${art.titulo}\" publicado. Ele sai da lista de rascunhos e aparece para os alunos.`);\n"
  "      setAtivo(0); carregar();\n"
  "    } catch { setAviso('Não foi possível publicar agora. Tente de novo.'); }",
  "e.erro === 'formato_invalido'", 'Revisao.tsx')
s = trocar(s, "      {aviso && <p className=\"faixa-aviso\" role=\"status\">{aviso}</p>}\n",
  "      {aviso && <p className=\"faixa-aviso\" role=\"status\">{aviso}</p>}\n      <FormatoPeca itens={art.formato} />\n",
  '<FormatoPeca itens', 'Revisao.tsx')
if 'apiPost' in s and s.count('apiPost') == 1:   # o import ficou sem uso
    s = s.replace("import { apiGet, apiPost } from '../../lib/api.js';", "import { apiGet } from '../../lib/api.js';")
gravar(p, tokens(s))

# PWA: painel
p = os.path.join(raiz, 'pwa/src/pages/painel/Painel.tsx'); s = ler(p)
s = trocar(s, "| 'base' | 'itens' | 'indicadores';", "| 'base' | 'itens' | 'indicadores' | 'conferencia' | 'revisar';", "| 'revisar'", 'Painel.tsx')
s = trocar(s, "| 'conferencia' | 'revisar';", "| 'conferencia' | 'revisar' | 'prazos';", "| 'prazos';", 'Painel.tsx')
s = trocar(s, "  { id: 'graficos', rotulo: 'Desempenho e evolução' },",
  "  { id: 'revisar', rotulo: 'Para revisar' }, { id: 'graficos', rotulo: 'Desempenho e evolução' },", "rotulo: 'Para revisar'", 'Painel.tsx')
s = trocar(s, "{ id: 'producao', rotulo: 'Fila de produção' },",
  "{ id: 'producao', rotulo: 'Fila de produção' }, { id: 'conferencia', rotulo: 'Conferência dos temas' },", "rotulo: 'Conferência dos temas'", 'Painel.tsx')
s = trocar(s, "{ id: 'conferencia', rotulo: 'Conferência dos temas' },",
  "{ id: 'conferencia', rotulo: 'Conferência dos temas' }, { id: 'prazos', rotulo: 'Prazos de produção' },", "rotulo: 'Prazos de produção'", 'Painel.tsx')
s = trocar(s, "    const precisa: Conjunto[] = aba === 'graficos' ? ['notas', 'avaliacoes'] : [aba];",
  "    const precisa: Conjunto[] = aba === 'graficos' ? ['notas', 'avaliacoes'] : aba === 'revisar' ? [] : [aba];", "aba === 'revisar' ? []", 'Painel.tsx')
s = trocar(s, "      {aba !== 'graficos' && (dados[aba] ?",
  "      {aba === 'revisar' && <ParaRevisar />}\n      {aba !== 'graficos' && aba !== 'revisar' && (dados[aba] ?", '<ParaRevisar />', 'Painel.tsx')
s = trocar(s, "import { RelatorioAnalise } from '../../components/leitura/RelatorioAnalise.js';",
  "import { RelatorioAnalise } from '../../components/leitura/RelatorioAnalise.js';\nimport { ParaRevisar } from '../../components/leitura/ParaRevisar.js';",
  'ParaRevisar }', 'Painel.tsx')
gravar(p, s)

# CSS do material interativo (inclui tempo, formato, telas de formulario e a aba Para revisar)
css = os.path.join(raiz, 'pwa/src/estilo.css'); s = ler(css); novo = ler(os.path.join(m, 'estilo_interativo.css'))
ini = s.find('/* ---------- material interativo')
if ini >= 0:
    fim = s.find('/* ---------- ', ini + 10)
    s = s[:ini] + novo + ('\n' + s[fim:] if fim >= 0 else '')
else:
    s += '\n' + novo
gravar(css, s)
print('formato, tempo de estudo, telas no Design System e aba Para revisar: prontos')
PY
