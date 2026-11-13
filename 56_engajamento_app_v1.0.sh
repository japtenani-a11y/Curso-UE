#!/usr/bin/env bash
# ============================================================
# 56_engajamento_app_v1.0.sh
# OBJETIVO: instalar no aplicativo e na API:
#  - Temas: os 39 principais com a data da reuniao e os opcionais com D0 escolhido pelo residente
#  - Avaliacao (NPS 0-10 + satisfacao 1-5) no fim de cada peca, de cada gabarito e do curso
#  - Duvidas (enviadas por e-mail aos curadores e respondidas pela coordenacao na tela /curador/duvidas)
#    e feedback, em cada peca e numa tela propria
#  - Desempenho: minhas notas e ranking (todos, especialidade, ano, ano + especialidade)
#  - Tempo de leitura de cada peca (coleta para pesquisa; o termo de consentimento fica para depois)
#  - Revisao: botao "Aprovar e publicar" (basta 1 revisor completo, ate 5% de erro leve e zero critico)
#  - API: rotas /eng e /curadoria; publicacao em /revisao/artefatos/:id/publicar
# USO: bash 56_engajamento_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 51 (script) e, no banco, 53, 54, 55 e 58. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 56_engajamento_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/engajamento_v1.0"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$PWA/components/Layout.tsx" ] || { echo "ERRO: rode antes o 51_acabamento_app_v1.0.sh"; exit 1; }

cp "$M/api/src/routes/engajamento.ts" "$API/routes/engajamento.ts"
cp "$M/api/src/routes/curadoria.ts" "$API/routes/curadoria.ts"
rm -f "$API/respondedor.ts"   # versao anterior respondia por IA; agora a coordenacao responde
mkdir -p "$PWA/pages/curador"
cp "$M/pwa/src/pages/curador/Duvidas.tsx" "$PWA/pages/curador/Duvidas.tsx"
cp "$M/pwa/src/components/Engajamento.tsx" "$PWA/components/Engajamento.tsx"
cp "$M/pwa/src/pages/aluno/Temas.tsx" "$M/pwa/src/pages/aluno/Desempenho.tsx" "$M/pwa/src/pages/aluno/Duvidas.tsx" "$PWA/pages/aluno/"
grep -q "engajamento (avaliacao" "$PWA/estilo.css" || cat "$M/estilo_engajamento.css" >> "$PWA/estilo.css"
echo "copiados: routes/engajamento.ts, routes/curadoria.ts, Engajamento.tsx, Temas, Desempenho, Duvidas (aluno e curador)"

python3 - "$API" "$PWA" "$RAIZ/api/package.json" <<'PY'
import sys, json
api, pwa, pkg = sys.argv[1:4]
def trocar(p, a, b, marca):
    s = open(p).read()
    if marca in s: return
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de insercao em {p}: {a[:60]}")
    open(p, "w").write(s.replace(a, b, 1))

# API: rotas /eng e /curadoria (o antigo script "respondedor" sai do package.json)
trocar(f"{api}/main.ts", "import { contatoRouter } from './routes/contato.js';",
       "import { contatoRouter } from './routes/contato.js';\nimport { engajamentoRouter } from './routes/engajamento.js';", "engajamentoRouter")
trocar(f"{api}/main.ts", "app.use('/contato', contatoRouter);",
       "app.use('/contato', contatoRouter);\napp.use('/eng', limite('eng', 240, 60_000), engajamentoRouter);", "app.use('/eng'")
trocar(f"{api}/main.ts", "import { engajamentoRouter } from './routes/engajamento.js';",
       "import { engajamentoRouter } from './routes/engajamento.js';\nimport { curadoriaRouter } from './routes/curadoria.js';", "curadoriaRouter }")
trocar(f"{api}/main.ts", "app.use('/eng', limite('eng', 240, 60_000), engajamentoRouter);",
       "app.use('/eng', limite('eng', 240, 60_000), engajamentoRouter);\napp.use('/curadoria', limite('curadoria', 240, 60_000), curadoriaRouter);", "app.use('/curadoria'")
j = json.load(open(pkg))
if j.get("scripts", {}).pop("respondedor", None) is not None:
    json.dump(j, open(pkg, "w"), indent=2); open(pkg, "a").write("\n")

# API: revisao mostra a situacao de cada peca e publica com a aprovacao de 1 revisor
p = f"{api}/routes/revisao.ts"
trocar(p, "                    WHERE p.artefato_id = a.artefato_id), '[]'::json) AS pareceres\n",
       "                    WHERE p.artefato_id = a.artefato_id), '[]'::json) AS pareceres,\n                (SELECT row_to_json(s) FROM app.situacao_revisao(a.artefato_id) s) AS situacao\n", "AS situacao")
s2 = open(p).read()
if "/artefatos/:id/publicar" not in s2:
    s2 += """
// Publica a peca: basta 1 revisor ter avaliado todas as afirmacoes, com ate 5% de erro leve, zero erro
// critico e parecer geral sem erro critico (regra conferida no banco por app.situacao_revisao).
revisaoRouter.post('/artefatos/:id/publicar', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) { res.status(400).json({ erro: 'parametros_invalidos' }); return; }
    const r = await withMaestro(null, async (c) => (await c.query('SELECT app.publicar_artefato($1) AS status', [id])).rows[0]);
    res.json({ ok: true, status: r?.status });
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    for (const e of ['revisao_incompleta_ou_fora_da_tolerancia', 'artefato_nao_e_rascunho', 'artefato_nao_encontrado', 'proibido']) {
      if (m.includes(e)) { res.status(e === 'proibido' ? 403 : 409).json({ erro: e }); return; }
    }
    next(err);
  }
});
"""
    open(p, "w").write(s2)

# Enviador de e-mails: rodape e rotulo do link proprios para avisos de duvida (curadores) e respostas (aluno)
p = f"{api}/notificador.ts"
trocar(p, "text: `${m.corpo}\\n\\nResponder agora: ${link(m)}\\n\\n—\\nVocê recebe este aviso porque autorizou lembretes por e-mail no Programa de Cirurgia de Urgência e Trauma. Para parar, desmarque em ${APP_URL}/aluno/contato`,",
       "text: `${m.corpo}\\n\\n${String(m.parametros.rotulo_link ?? 'Responder agora')}: ${link(m)}\\n\\n—\\n${String(m.parametros.rodape ?? `Você recebe este aviso porque autorizou lembretes por e-mail no Programa de Cirurgia de Urgência e Trauma. Para parar, desmarque em ${APP_URL}/aluno/contato`)}`,", "rotulo_link")

# API: teste por pessoa (ondas pessoais dos temas opcionais)
p = f"{api}/routes/teste.ts"; s = open(p).read()
s = s.replace("FROM app.onda_instancia o WHERE o.tema_id = $1 ORDER BY o.teste_num`, [t.tema_id, p]);",
              "FROM app.onda_instancia o WHERE o.tema_id = $1 AND o.onda_id = app.onda_da_pessoa($2, o.tema_id, o.teste_num) ORDER BY o.teste_num`, [t.tema_id, p]);")
s = s.replace("FROM app.onda_instancia o WHERE o.onda_id = $1 AND o.tema_id IS NOT NULL`, [ondaId, p]);",
              "FROM app.onda_instancia o WHERE o.onda_id = $1 AND o.tema_id IS NOT NULL AND (o.pessoa_id IS NULL OR o.pessoa_id = $2)`, [ondaId, p]);")
open(p, "w").write(s)
if "app.onda_da_pessoa($2" not in s or "o.pessoa_id = $2)`, [ondaId, p]" not in s: sys.exit("ERRO: nao consegui ajustar teste.ts para as ondas pessoais")

# PWA: rotas e navegacao
trocar(f"{pwa}/App.tsx", "import { Contato } from './pages/aluno/Contato.js';",
       "import { Contato } from './pages/aluno/Contato.js';\nimport { Temas } from './pages/aluno/Temas.js';\nimport { Desempenho } from './pages/aluno/Desempenho.js';\nimport { Duvidas } from './pages/aluno/Duvidas.js';", "pages/aluno/Temas.js")
trocar(f"{pwa}/App.tsx", '<Route path="/aluno/contato"',
       '<Route path="/aluno/temas" element={<Layout proteger={false}><Temas /></Layout>} />\n        <Route path="/aluno/desempenho" element={<Layout proteger={false}><Desempenho /></Layout>} />\n        <Route path="/aluno/duvidas" element={<Layout><Duvidas /></Layout>} />\n        <Route path="/aluno/contato"', 'path="/aluno/temas"')
trocar(f"{pwa}/components/Layout.tsx", "    { href: '/aluno/leitura/T001', rotulo: 'Material' },",
       "    { href: '/aluno/temas', rotulo: 'Temas' },\n    { href: '/aluno/leitura/T001', rotulo: 'Material' },", "'/aluno/temas'")
trocar(f"{pwa}/components/Layout.tsx", "    { href: '/aluno/contato', rotulo: 'Lembretes' },",
       "    { href: '/aluno/desempenho', rotulo: 'Desempenho' },\n    { href: '/aluno/duvidas', rotulo: 'Dúvidas' },\n    { href: '/aluno/contato', rotulo: 'Lembretes' },", "'/aluno/desempenho'")

trocar(f"{pwa}/App.tsx", "import { CuradorRevisao } from './pages/curador/Revisao.js';",
       "import { CuradorRevisao } from './pages/curador/Revisao.js';\nimport { CuradorDuvidas } from './pages/curador/Duvidas.js';", "CuradorDuvidas }")
trocar(f"{pwa}/App.tsx", '<Route path="/curador/*"',
       '<Route path="/curador/duvidas" element={<Layout papeis={REVISORES} proteger={false}><CuradorDuvidas /></Layout>} />\n        <Route path="/curador/*"', 'path="/curador/duvidas"')
trocar(f"{pwa}/components/Layout.tsx", "      { href: '/curador/previa/T001', rotulo: 'Prévia do aluno' },",
       "      { href: '/curador/previa/T001', rotulo: 'Prévia do aluno' },\n      { href: '/curador/duvidas', rotulo: 'Dúvidas' },", "'/curador/duvidas'")
p = f"{pwa}/pages/curador/Revisao.tsx"
trocar(p, "  afirmacoes: Afirmacao[]; pareceres: Parecer[];\n}",
       "  afirmacoes: Afirmacao[]; pareceres: Parecer[];\n  situacao?: { total: number; revisadas: number; leves: number; criticos: number; geral_ok: boolean | null; pode_publicar: boolean } | null;\n}", "situacao?:")
trocar(p, ".rev .aba{border:1px solid #c5ccd6;background:#fff;border-radius:6px;padding:6px 10px;cursor:pointer;font-size:14px}",
       ".rev .aba{border:1px solid #9aa5b4;background:#fff;color:#14213d;border-radius:6px;padding:6px 10px;cursor:pointer;font-size:14px;font-weight:500}\n.rev .aba:hover{background:#eef1f5}\n.rev .publicar{margin-top:8px;display:flex;gap:10px;align-items:center;flex-wrap:wrap}", ".rev .publicar{")
trocar(p, "  const [rascunho, setRascunho] = useState<Record<string, string>>({});",
       "  const [rascunho, setRascunho] = useState<Record<string, string>>({});\n  const [aviso, setAviso] = useState<string | null>(null);", "const [aviso, setAviso]")
trocar(p, "  const pl = placar(art);\n",
       """  const pl = placar(art);
  const podePublicar = art.situacao?.pode_publicar === true;

  async function publicar() {
    if (!window.confirm(`Publicar "${art.titulo}" para os alunos? A versão publicada anterior, se houver, será arquivada.`)) return;
    try {
      await apiPost(`/revisao/artefatos/${art.artefato_id}/publicar`, {});
      setAviso(`"${art.titulo}" publicado. Ele sai da lista de rascunhos e aparece para os alunos.`);
      setAtivo(0); carregar();
    } catch { setAviso('Não foi possível publicar: a revisão ainda não está completa ou está fora da tolerância.'); }
  }
""", "async function publicar()")
trocar(p, """            : <span className="ruim">Fora da tolerância (até 5% leve, zero crítico).</span>}
      </div>""",
       """            : <span className="ruim">Fora da tolerância (até 5% leve, zero crítico).</span>}
        <div className="publicar">
          <button type="button" className="botao" disabled={!podePublicar} onClick={publicar}>Aprovar e publicar</button>
          <span>{podePublicar
            ? 'Revisão completa e dentro da tolerância: a aprovação de 1 revisor basta.'
            : pl.total === 0
              ? 'Peça sem afirmações: marque o parecer geral como "Correto" para liberar a publicação.'
              : 'Liberado quando todas as afirmações tiverem parecer, sem erro crítico e com até 5% de erro leve.'}</span>
        </div>
      </div>
      {aviso && <p className="faixa-aviso" role="status">{aviso}</p>}""", 'className="publicar"')

# Leitura: avaliacao, duvida e tempo de uso no fim de cada peca (so para o aluno)
p = f"{pwa}/pages/aluno/Leitura.tsx"
trocar(p, "    .filter((l) => !l.startsWith('> RASCUNHO'))\n",
       "    .filter((l) => !l.startsWith('> RASCUNHO'))\n    .map((l) => l.replace(/\\s*Rascunho sujeito à revisão[^.]*\\./, ''))\n", "Rascunho sujeito")
trocar(p, "import { Markdown } from '../../lib/md.js';",
       "import { Markdown } from '../../lib/md.js';\nimport { Engajamento } from '../../components/Engajamento.js';", "components/Engajamento.js")
trocar(p, "            <Markdown texto={limpar(art.corpo, dados.previa)} />\n          )}\n        </div>",
       "            <Markdown texto={limpar(art.corpo, dados.previa)} />\n          )}\n          {!dados.previa && <Engajamento key={art.tipo} tema={dados.tema.codigo} ferramenta={art.tipo} titulo={art.titulo} />}\n        </div>", "<Engajamento key={art.tipo}")

# Testes: avaliacao e duvida depois de cada gabarito
p = f"{pwa}/pages/aluno/Testes.tsx"
trocar(p, "import { apiGet, apiPost } from '../../lib/api.js';",
       "import { apiGet, apiPost } from '../../lib/api.js';\nimport { Avaliacao, Pergunta } from '../../components/Engajamento.js';", "components/Engajamento.js")
trocar(p, "          <button type=\"button\" className=\"sec\" onClick={() => setGab(null)}>Voltar aos testes</button>",
       "          <div className=\"engajamento\">\n            <Avaliacao tema={lista.tema.codigo} ferramenta={`teste_${lista.testes.find((t) => t.onda_id === gab.ondaId)?.teste_num ?? 0}`} titulo=\"este teste\" />\n            <Pergunta tema={lista.tema.codigo} ferramenta={`teste_${lista.testes.find((t) => t.onda_id === gab.ondaId)?.teste_num ?? 0}`} />\n          </div>\n          <button type=\"button\" className=\"sec\" onClick={() => setGab(null)}>Voltar aos testes</button>", "<Avaliacao tema={lista.tema.codigo}")

# Inicio do aluno: atalho para o desempenho. O termo de consentimento da pesquisa (TCLE) fica para
# quando o projeto for ao CEP; por ora o banco so coleta os dados (notas, avaliacoes, uso, mensagens).
p = f"{pwa}/pages/aluno/Home.tsx"
trocar(p, "            <h3>Lembretes</h3>",
       "            <h3>Desempenho e ranking</h3>\n            <p>Suas notas e sua posição entre todos, na sua especialidade, no seu ano e no seu subgrupo.</p>\n            <a className=\"botao discreto\" href=\"/aluno/desempenho\">Ver desempenho</a>\n          </article>\n          <article className=\"cartao-app\">\n            <h3>Lembretes</h3>", "Ver desempenho")
PY
echo "atualizados: main.ts (/eng, /curadoria), revisao.ts (publicar), teste.ts (ondas pessoais), App, Layout, Revisao, Leitura, Testes, Home"
echo "=== engajamento instalado ==="
