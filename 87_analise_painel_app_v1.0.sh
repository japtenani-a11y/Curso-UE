#!/usr/bin/env bash
# ============================================================
# 87_analise_painel_app_v1.0.sh
# OBJETIVO: relatorio de analise (Python) dentro do painel.
#  - copia analise/*.py para programa-cut/analise/;
#  - API: GET /painel/relatorio (e ?simulados=1 para o ensaio) monta a base atual com as permissoes de quem pediu,
#    roda python3 analise/analise_cut_v1.0.py e devolve o relatorio (pagina HTML). Sem Python ou sem as bibliotecas,
#    devolve uma pagina explicando como instalar (instalar_python_analise_v1.0.sh);
#  - painel: cartao "Relatório de análise" na primeira aba, com os dois botoes.
# USO: bash 87_analise_painel_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 85. Rodar depois do 85. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 87_analise_painel_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$RAIZ/analise"
cp "$AQUI"/analise/analise_cut_v1.0.py "$AQUI"/analise/modelo_cut.py "$RAIZ/analise/"
cp "$AQUI"/modelos/interativo_v1.0/pwa/src/components/leitura/RelatorioAnalise.tsx "$RAIZ/pwa/src/components/leitura/"
python3 - "$RAIZ" <<'PY'
import sys, os
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:80]}")
    return s.replace(a, b, 1)

p = os.path.join(raiz, 'api/src/routes/painel.ts'); s = ler(p)
s = trocar(s, "import { Router } from 'express';", "import { Router } from 'express';\nimport { execFile } from 'node:child_process';\nimport fs from 'node:fs';\nimport os from 'node:os';\nimport path from 'node:path';",
           "from 'node:child_process'", 'painel.ts')
s = trocar(s, "painelRouter.get('/:conjunto', async (req, res, next) => {", """// Relatorio de analise (Python): base atual, com as permissoes de quem pediu (pesquisador: codigo e so quem consentiu).
const PAGINA_SEM_PYTHON = (detalhe: string) => `<!doctype html><meta charset="utf-8"><title>Relatório de análise</title>
<body style="font-family:system-ui;max-width:720px;margin:40px auto;padding:0 16px;line-height:1.5">
<h1>Não foi possível gerar o relatório</h1><p>O computador do curso precisa do Python com pandas, scipy e matplotlib.
No WSL, dentro de ~/Curso-UE, rode uma vez:</p><pre style="background:#f3f5f8;padding:12px">bash instalar_python_analise_v1.0.sh</pre>
<p>Depois, gere o relatório de novo.</p><details><summary>Detalhe técnico</summary><pre>${detalhe.replace(/[<>&]/g, '')}</pre></details></body>`;
painelRouter.get('/relatorio', async (req, res, next) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'cut-rel-'));
  try {
    const linhas = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.pesquisa_respostas()')).rows as Record<string, unknown>[]);
    const cols = linhas[0] ? Object.keys(linhas[0]) : ['participante','ano','especialidade','turma','tema','teste_num','teste','dias_da_aula','item','perfil_item','dificuldade','correta','certeza','tempo_s','rapida','apos_aula','aula','equipe','simulado','consentiu','valida','enviada_em'];
    const cel = (v: unknown) => v === null || v === undefined ? '' : typeof v === 'boolean' ? (v ? 't' : 'f') : v instanceof Date ? v.toISOString() : String(v).replace(/[;\\r\\n"]/g, ' ');
    fs.writeFileSync(path.join(dir, 'base.csv'), [cols.join(';'), ...linhas.map((l) => cols.map((c) => cel(l[c])).join(';'))].join('\\n'));
    const script = path.resolve(process.env.ANALISE_DIR ?? path.join(process.cwd(), '..', 'analise'), 'analise_cut_v1.0.py');
    const args = [script, path.join(dir, 'base.csv'), '--saida', path.join(dir, 'relatorio.html')];
    if (req.query.simulados === '1') args.push('--so-simulados');
    execFile(process.env.PYTHON ?? 'python3', args, { timeout: 120_000, maxBuffer: 4 * 1024 * 1024 }, (erro, _out, saidaErro) => {
      try {
        res.setHeader('Cache-Control', 'no-store');
        if (erro || !fs.existsSync(path.join(dir, 'relatorio.html'))) { res.status(500).type('html').send(PAGINA_SEM_PYTHON(String(saidaErro || erro?.message || '').slice(-1500))); return; }
        res.type('html').send(fs.readFileSync(path.join(dir, 'relatorio.html'), 'utf-8'));
      } finally { fs.rmSync(dir, { recursive: true, force: true }); }
    });
  } catch (err) { fs.rmSync(dir, { recursive: true, force: true }); next(err); }
});

painelRouter.get('/:conjunto', async (req, res, next) => {""", "painelRouter.get('/relatorio'", 'painel.ts')
gravar(p, s)

p = os.path.join(raiz, 'pwa/src/pages/painel/Painel.tsx'); s = ler(p)
s = trocar(s, "import { FormIndicador } from '../../components/leitura/FormIndicador.js';",
           "import { FormIndicador } from '../../components/leitura/FormIndicador.js';\nimport { RelatorioAnalise } from '../../components/leitura/RelatorioAnalise.js';", 'RelatorioAnalise.js', 'Painel.tsx')
s = trocar(s, "      {aba === 'indicadores' && <FormIndicador", "      {aba === 'graficos' && <RelatorioAnalise />}\n      {aba === 'indicadores' && <FormIndicador", '<RelatorioAnalise />', 'Painel.tsx')
gravar(p, s)
print('87: relatorio de analise no painel pronto')
PY
