#!/usr/bin/env bash
# ============================================================
# 82_interativo_app_v1.0.sh
# OBJETIVO: material interativo na tela de leitura do aluno (SQL 82):
#  - caso da aula: conduta e certeza em cada ponto de decisao antes da discussao, comparacao depois, resumo no fim;
#  - caso base: respostas as perguntas do fim salvas antes da aula e revisadas depois (com "o que eu responderia agora");
#  - mapa conceitual: ramos em cartoes que abrem e fecham, com modo "Testar-me";
#  - checklist: itens clicaveis, marcacoes salvas;
#  - slides da aula e do caso: imagem do slide (se houver) ou slide desenhado, roteiro de fala, audio por slide,
#    "Apresentar com audio" (passa sozinho, sincronizado com a fala), velocidade de 1x a 2x;
#  - podcast: velocidade de 1x a 2x e retomada do ponto em que parou;
#  - onde parou: peca aberta, posicao do texto, ponto do caso, slide e tempo do audio, guardados no aparelho e no
#    servidor (sem internet, vao quando a conexao voltar); cartao "Continuar de onde parou" no Inicio.
# USO: bash 82_interativo_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 34, 61, 81. Rodar depois do 81. Pode ser rodado mais de uma vez.
# DESFAZER: rodar de novo a cadeia de scripts de telas sem o 82.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 82_interativo_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/interativo_v1.0"
mkdir -p "$RAIZ/slides" "$RAIZ/pwa/src/components/leitura"
cp "$M/api/src/routes/leitura_interativo.ts" "$RAIZ/api/src/routes/"
cp "$M"/pwa/src/components/leitura/*.tsx "$RAIZ/pwa/src/components/leitura/"
# imagens dos decks que vieram no pacote (conteudo/<TEMA>/slides/imagens): copiadas so se o tema ainda nao tiver
# imagens proprias (as do preparar_slides_pdf ficam valendo)
for d in "$AQUI"/conteudo/*/slides/imagens; do
  [ -d "$d" ] || continue
  cod="$(basename "$(dirname "$(dirname "$d")")" | tr -d '-' | tr '[:lower:]' '[:upper:]')"
  if ! ls "$RAIZ/slides/$cod"/slide_*.png >/dev/null 2>&1; then mkdir -p "$RAIZ/slides/$cod" && cp "$d"/slide_*.png "$RAIZ/slides/$cod/"; fi
done
python3 - "$RAIZ" "$M/estilo_interativo.css" <<'PY'
import sys, os
raiz, css = sys.argv[1], open(sys.argv[2], encoding='utf-8').read()
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:70]}")
    return s.replace(a, b, 1)

# API
p = os.path.join(raiz, 'api/src/routes/leitura.ts'); s = ler(p)
s = trocar(s, "export const leituraRouter = Router();", "export const leituraRouter = Router();\nregistrarInterativo(leituraRouter);",
           'registrarInterativo(leituraRouter)', 'leitura.ts')
s = trocar(s, "import { withMaestro } from '../db/transaction.js';",
           "import { withMaestro } from '../db/transaction.js';\nimport { registrarInterativo } from './leitura_interativo.js';",
           "from './leitura_interativo.js'", 'leitura.ts')
gravar(p, s)

# Leitura
p = os.path.join(raiz, 'pwa/src/pages/aluno/Leitura.tsx'); s = ler(p)
s = trocar(s, "import { Engajamento } from '../../components/Engajamento.js';", """import { Engajamento } from '../../components/Engajamento.js';
import { CasoInterativo, partesDoCaso } from '../../components/leitura/CasoInterativo.js';
import { CasoBase } from '../../components/leitura/CasoBase.js';
import { MapaConceitual, arvoreDoMapa } from '../../components/leitura/MapaConceitual.js';
import { Checklist } from '../../components/leitura/Checklist.js';
import { Slides } from '../../components/leitura/Slides.js';
import { PodcastPlayer } from '../../components/leitura/PodcastPlayer.js';
import { useMemoriaTema } from '../../components/leitura/Continuar.js';""", 'components/leitura/CasoInterativo', 'Leitura.tsx')
s = trocar(s, """  const [ativo, setAtivo] = useState(0);
""", """  const [ativo, setAtivo] = useState(0);
  const pecaAtiva = dados ? dados.artefatos[Math.min(ativo, Math.max(0, dados.artefatos.length - 1))]?.tipo ?? null : null;
  useMemoriaTema(codigoDoTema(), pecaAtiva, (p) => {
    const k = dados ? dados.artefatos.findIndex((a) => a.tipo === p) : -1;
    if (k >= 0) setAtivo(k);
  }, !previa);
""", 'useMemoriaTema(codigoDoTema()', 'Leitura.tsx')
s = trocar(s, "{art.tipo === 'podcast_roteiro' && <Podcast key={`p${dados.tema.codigo}`} codigo={dados.tema.codigo} />}",
           "{art.tipo === 'podcast_roteiro' && (dados.previa ? <Podcast key={`p${dados.tema.codigo}`} codigo={dados.tema.codigo} /> : <PodcastPlayer key={`p${dados.tema.codigo}`} codigo={dados.tema.codigo} />)}",
           '<PodcastPlayer', 'Leitura.tsx')
# sem o audio gravado, o podcast le o roteiro com a voz do aparelho: o player recebe o texto do roteiro
s = trocar(s, "<PodcastPlayer key={`p${dados.tema.codigo}`} codigo={dados.tema.codigo} />",
           "<PodcastPlayer key={`p${dados.tema.codigo}`} codigo={dados.tema.codigo} roteiro={art.corpo} />",
           'roteiro={art.corpo}', 'Leitura.tsx')
s = trocar(s, "          ) : art.tipo === 'flashcard' && cartoes(art.corpo).length > 0 ? (", """          ) : art.tipo === 'caso' && !dados.previa && partesDoCaso(art.corpo).pontos.length > 0 ? (
            <CasoInterativo key={`c${art.artefato_id}`} codigo={dados.tema.codigo} corpo={limpar(art.corpo, false)} />
          ) : art.tipo === 'caso_base' && !dados.previa ? (
            <CasoBase key={`b${art.artefato_id}`} codigo={dados.tema.codigo} corpo={limpar(art.corpo, false)} etapa={dados.etapa ?? 1} />
          ) : art.tipo === 'checklist' && !dados.previa ? (
            <Checklist key={`k${art.artefato_id}`} codigo={dados.tema.codigo} corpo={limpar(art.corpo, false)} />
          ) : art.tipo === 'slides' ? (
            <Slides key={`s${art.artefato_id}`} codigo={dados.tema.codigo} corpo={limpar(art.corpo, dados.previa)}
              caso={(() => { const c = dados.artefatos.find((a) => a.tipo === 'caso'); return c ? limpar(c.corpo, dados.previa) : undefined; })()} />
          ) : art.tipo === 'mapa' && arvoreDoMapa(art.corpo, dados.previa) ? (
            <MapaConceitual corpo={art.corpo} previa={dados.previa} />
          ) : art.tipo === 'flashcard' && cartoes(art.corpo).length > 0 ? (""", '<CasoInterativo key=', 'Leitura.tsx')
gravar(p, s)

# Inicio: continuar de onde parou
p = os.path.join(raiz, 'pwa/src/pages/aluno/Home.tsx'); s = ler(p)
s = trocar(s, "import { Lembretes } from '../../components/Lembretes.js';",
           "import { Lembretes } from '../../components/Lembretes.js';\nimport { Continuar } from '../../components/leitura/Continuar.js';",
           "components/leitura/Continuar.js", 'Home.tsx')
s = trocar(s, "      <Lembretes />\n", "      <Lembretes />\n      <Continuar />\n", '<Continuar />', 'Home.tsx')
gravar(p, s)

# estilo
p = os.path.join(raiz, 'pwa/src/estilo.css'); s = ler(p)
marca = '/* ---------- material interativo'
if marca in s:
    i = s.index(marca); j = s.find('/* ---------- ', i + len(marca))
    s = s[:i] + css.rstrip() + '\n' + ('\n' + s[j:] if j >= 0 else '')
else:
    s = s.rstrip() + '\n\n' + css
gravar(p, s)
print('material interativo: telas prontas')
PY
