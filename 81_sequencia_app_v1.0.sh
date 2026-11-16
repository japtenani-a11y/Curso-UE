#!/usr/bin/env bash
# ============================================================
# 81_sequencia_app_v1.0.sh
# OBJETIVO: telas da nova sequencia de entrega do material (SQL 81).
#  - API /leitura: material na ordem da entrega; devolve o perfil do aluno (R1, R2, R3, R+, graduacao);
#    nova rota /leitura/podcast/:codigo que entrega o audio do podcast (so com login e com o tema liberado
#    ate o pre-aula). Os audios ficam na pasta programa-cut/podcast/<CODIGO>.mp3 (ex.: T001.mp3), fora do GitHub.
#  - Leitura: "Objetivos de aprendizagem" abre na parte do ano do aluno (as dos outros anos ficam recolhidas);
#    "Podcast" mostra o player de audio acima do roteiro, ou avisa que o audio ainda nao esta pronto.
#  - Nomes: "Pre-teste inicial" -> "Pre-teste 1"; "Simulados" -> "Banco de questoes".
# USO: bash 81_sequencia_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 34, 61, 80. Rodar depois do 80. Pode ser rodado mais de uma vez.
# DESFAZER: rodar de novo a cadeia de scripts de telas sem o 81.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 81_sequencia_app_v1.0.sh <pasta programa-cut>}"
mkdir -p "$RAIZ/podcast"
python3 - "$RAIZ" <<'PY'
import sys, os, glob
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:60]}")
    return s.replace(a, b, 1)

# ---------- API: leitura.ts ----------
p = os.path.join(raiz, 'api/src/routes/leitura.ts'); s = ler(p)
s = s.replace("""const TIPOS = ['objetivos', 'resumo_basico', 'podcast_roteiro', 'caso_base', 'aula', 'slides', 'caso', 'sintese_evidencia',
  'resumo', 'mapa', 'flashcard', 'protocolo', 'checklist', 'simulado'];""",
"""const TIPOS = ['objetivos', 'resumo_basico', 'podcast_roteiro', 'caso_base', 'sintese_evidencia', 'mapa',
  'aula', 'slides', 'caso', 'resumo', 'protocolo', 'checklist', 'flashcard', 'simulado'];""")
if "'sintese_evidencia', 'mapa',\n  'aula'" not in s: sys.exit("ERRO: nao consegui ajustar a ordem do material em leitura.ts")
s = trocar(s, "app.etapa_liberada($2, tema_id) AS etapa\n           FROM app.tema",
           "app.etapa_liberada($2, tema_id) AS etapa, app.perfil_da_pessoa($2) AS perfil\n           FROM app.tema", 'AS perfil', 'leitura.ts')
s = trocar(s, "return { tema: { codigo: t.codigo, titulo: t.titulo }, previa, etapa, bloqueados, artefatos: liberados };",
           "return { tema: { codigo: t.codigo, titulo: t.titulo }, previa, etapa, bloqueados, perfil: t.perfil ?? null, artefatos: liberados };",
           'perfil: t.perfil', 'leitura.ts')
if "/podcast/:codigo" not in s:
    if "import path from 'node:path';" not in s:
        s = "import fs from 'node:fs';\nimport path from 'node:path';\n" + s
    s += """
// Audio do podcast: pasta programa-cut/podcast/<CODIGO>.mp3. So com login e com o tema liberado ate o pre-aula
// (revisores ouvem sempre). O arquivo nao fica na pasta publica do aplicativo, para nao ficar aberto a quem tiver o link.
leituraRouter.get('/podcast/:codigo', async (req, res, next) => {
  try {
    const r = req as { pessoaId?: number; papel?: string };
    if (!r.pessoaId) { res.status(401).end(); return; }
    const codigo = String(req.params.codigo).replace(/[^A-Za-z0-9]/g, '').toUpperCase();
    const pode = await withMaestro(null, async (client) => (await client.query(
      `SELECT app.etapa_liberada($2, tema_id) >= 2 AS ok FROM app.tema WHERE upper(replace(codigo, '-', '')) = $1`,
      [codigo, r.pessoaId])).rows[0]?.ok === true);
    if (!pode && !REVISORES.includes(r.papel ?? '')) { res.status(403).end(); return; }
    const pasta = path.resolve(process.env.PODCAST_DIR ?? path.join(process.cwd(), '..', 'podcast'));
    const arq = path.join(pasta, `${codigo}.mp3`);
    if (!fs.existsSync(arq)) { res.status(404).end(); return; }
    res.setHeader('Cross-Origin-Resource-Policy', 'same-site');
    res.setHeader('Cache-Control', 'private, max-age=3600');
    res.sendFile(arq);
  } catch (e) { next(e); }
});
"""
gravar(p, s)

# ---------- PWA: Leitura.tsx ----------
p = os.path.join(raiz, 'pwa/src/pages/aluno/Leitura.tsx'); s = ler(p)
s = trocar(s, "etapa?: number; bloqueados?: number }", "etapa?: number; bloqueados?: number; perfil?: string | null }",
           'perfil?: string | null', 'Leitura.tsx')
s = trocar(s, "`;\n\nfunction codigoDoTema", """.lei .obj-outros{margin-top:14px;border-top:1px solid var(--cut-line);padding-top:8px}
.lei .obj-outros summary{cursor:pointer;font-weight:600;min-height:44px;display:flex;align-items:center}
.lei .pod{display:flex;flex-direction:column;gap:6px;background:var(--cut-surface-sunken);border:1px solid var(--cut-line);border-radius:8px;padding:10px 14px;margin:0 0 12px}
.lei .pod audio{width:100%}
.lei .pod-sem{font-size:14px;color:var(--cut-text-muted);margin:0 0 12px}
`;

function codigoDoTema""", '.obj-outros', 'Leitura.tsx')
s = trocar(s, "export function Leitura() {", """// Objetivos: a parte do ano do aluno vem primeiro; as dos outros anos ficam recolhidas.
interface Secao { titulo: string; texto: string }
function secoesObjetivos(corpo: string): { intro: string; secoes: Secao[] } {
  const partes = corpo.split(/^## /m);
  const intro = partes.shift() ?? '';
  return { intro, secoes: partes.map((p) => { const i = p.indexOf('\\n'); return { titulo: (i < 0 ? p : p.slice(0, i)).trim(), texto: i < 0 ? '' : p.slice(i + 1) }; }) };
}
function doPerfil(titulo: string, perfil: string | null | undefined): boolean {
  if (!perfil) return false;
  const t = titulo.toLowerCase(); const q = perfil.toLowerCase();
  if (q === 'graduacao') return t.startsWith('gradua');
  return t === q || t.startsWith(q + ' ');
}
function Objetivos(props: { corpo: string; perfil?: string | null }) {
  const { intro, secoes } = secoesObjetivos(props.corpo);
  const minha = secoes.find((x) => doPerfil(x.titulo, props.perfil));
  if (!minha) return <Markdown texto={props.corpo} />;
  return (
    <div>
      <Markdown texto={intro} />
      <h2>Os seus objetivos ({minha.titulo})</h2>
      <Markdown texto={minha.texto} />
      <details className="obj-outros">
        <summary>Ver os objetivos dos outros anos</summary>
        {secoes.filter((x) => x !== minha).map((x) => <div key={x.titulo}><h3>{x.titulo}</h3><Markdown texto={x.texto} /></div>)}
      </details>
    </div>
  );
}

// Podcast: player do audio (rota protegida da API); sem audio, avisa e fica o roteiro.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
function Podcast(props: { codigo: string }) {
  const [ok, setOk] = useState(true);
  if (!ok) return <p className="pod-sem">O áudio deste episódio ainda não está pronto. Por enquanto, leia o roteiro abaixo.</p>;
  return (
    <div className="pod">
      <strong>Ouvir o episódio</strong>
      <audio controls preload="metadata" src={`${API_BASE}/leitura/podcast/${props.codigo.replace(/-/g, '')}`} onError={() => setOk(false)} />
    </div>
  );
}

export function Leitura() {""", 'function Objetivos(', 'Leitura.tsx')
s = trocar(s, """          {art.tipo === 'flashcard' && cartoes(art.corpo).length > 0 ? (""",
           """          {art.tipo === 'podcast_roteiro' && <Podcast key={`p${dados.tema.codigo}`} codigo={dados.tema.codigo} />}
          {art.tipo === 'objetivos' && !dados.previa ? (
            <Objetivos corpo={limpar(art.corpo, dados.previa)} perfil={dados.perfil} />
          ) : art.tipo === 'flashcard' && cartoes(art.corpo).length > 0 ? (""", '<Objetivos corpo=', 'Leitura.tsx')
gravar(p, s)

# ---------- nomes em todas as telas ----------
TROCAS = [("Pré-teste após o conhecimento básico", "Pré-teste 2"), ("Pré-teste inicial", "Pré-teste 1"), ("pré-teste inicial", "pré-teste 1"),
          ("['simulado', 'Simulados']", "['simulado', 'Banco de questões']"), ("simulado: 'Simulados'", "simulado: 'Banco de questões'"),
          ("slides: 'Slides'", "slides: 'Slides da aula'"), ("protocolo: 'Protocolo'", "protocolo: 'Protocolo assistencial'")]
n = 0
for f in glob.glob(os.path.join(raiz, 'pwa/src/**/*.tsx'), recursive=True) + glob.glob(os.path.join(raiz, 'pwa/src/**/*.ts'), recursive=True) \
        + glob.glob(os.path.join(raiz, 'api/src/**/*.ts'), recursive=True):
    s = ler(f); s2 = s
    for a, b in TROCAS: s2 = s2.replace(a, b)
    if s2 != s: gravar(f, s2); n += 1
print(f"sequencia do material: telas ajustadas ({n} arquivos com nomes trocados)")
PY
