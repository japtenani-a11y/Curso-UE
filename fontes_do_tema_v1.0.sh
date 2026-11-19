#!/usr/bin/env bash
# ============================================================
# fontes_do_tema_v1.0.sh
# OBJETIVO: antes de produzir um tema, trazer do banco TODAS as fontes ja guardadas para ele (as do triador de fontes,
#   inclusive as que chegaram antes de o tema ser produzido, e as carregadas antes) para conteudo/<TEMA>/fontes_banco:
#   um .txt com o texto integral de cada uma e o catalogo fontes_banco.csv. Quem produz o tema le esses textos e cita a
#   fonte pelo codigo do arquivo (por exemplo F1a2b3c4d ou 2016_01). O importador reconhece essas fontes e nao as
#   carrega de novo.
# USO: bash fontes_do_tema_v1.0.sh T002 SENHA
# ============================================================
set -uo pipefail
TEMA="$(echo "${1:?uso: bash fontes_do_tema_v1.0.sh T002 SENHA}" | tr -d '-' | tr 'a-z' 'A-Z')"; PW="${2:?informe a senha do banco}"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
AQUI="$(cd "$(dirname "$0")" && pwd)"; DEST="$AQUI/conteudo/$TEMA/fontes_banco"
mkdir -p "$DEST"
PGPASSWORD="$PW" psql -h "$HOST" -p "$PORTA" -U postgres -d programa -X -q -At -v ON_ERROR_STOP=1 -c "
  SELECT json_agg(json_build_object('arquivo', regexp_replace(coalesce(nullif(f.arquivo_origem, ''), 'sem_arquivo_' || f.fonte_id), '^.*/', ''),
         'titulo', f.titulo, 'autores', f.autores, 'ano', f.ano, 'doi', f.doi, 'pmid', f.pmid, 'camada', f.camada, 'texto', f.texto_integral))
    FROM conteudo.fonte f JOIN app.tema t USING (tema_id) WHERE replace(t.codigo, '-', '') = '$TEMA'" > "$DEST/.fontes.json" || { echo "ERRO ao ler o banco"; exit 1; }
python3 -I - "$DEST" <<'PY'
import json, os, sys, csv
d = sys.argv[1]; fs = json.load(open(os.path.join(d, '.fontes.json'))) or []
w = csv.writer(open(os.path.join(d, 'fontes_banco.csv'), 'w', encoding='utf-8'), delimiter=';')
w.writerow(['arquivo_txt', 'codigo_para_citar', 'titulo', 'autores', 'ano', 'doi', 'pmid', 'camada', 'tem_texto'])
for f in fs:
    base = f['arquivo'].rsplit('.', 1)[0]
    cod = base.split('_')[0] if base.startswith('F') else '_'.join(base.split('_')[1:3])
    if f['texto']: open(os.path.join(d, base + '.txt'), 'w', encoding='utf-8').write(f['texto'])
    w.writerow([base + '.txt' if f['texto'] else '', cod, f['titulo'], f['autores'] or '', f['ano'] or '', f['doi'] or '', f['pmid'] or '', f['camada'], 'sim' if f['texto'] else 'nao'])
os.remove(os.path.join(d, '.fontes.json'))
print(f'{len(fs)} fontes do banco em {d} ({sum(1 for f in fs if f["texto"])} com texto integral)')
PY
