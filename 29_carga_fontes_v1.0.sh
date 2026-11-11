#!/usr/bin/env bash
# 29_carga_fontes_v1.0.sh — carrega as fontes do Drive em conteudo.fonte, uma linha por (arquivo, tema).
# USO: bash 29_carga_fontes_v1.0.sh <catalogo.csv> <pasta_raiz_dos_zips_descompactados> [--aplicar]
# Sem --aplicar gera so o SQL em ./carga_fontes.sql (para conferir). Com --aplicar roda no banco ($DATABASE_URL).
# Entram apenas uso=literatura|fonte_institucional com tema != REVISAR. Dado de paciente nunca entra.
# Camada e tema entram como SUGESTAO (camada_confirmada=false, tema_confirmado=false) ate o curador confirmar.
set -euo pipefail
CAT="${1:?catalogo.csv}"; RAIZ="${2:?pasta raiz}"; APLICAR="${3:-}"
command -v pdftotext >/dev/null || { echo "ERRO: pdftotext ausente (poppler-utils)"; exit 1; }
python3 -I - "$CAT" "$RAIZ" > carga_fontes.sql <<'PY'
import csv,sys,os,re,subprocess,zipfile,hashlib,unicodedata
cat,raiz=sys.argv[1:3]
def idx(raiz):
    m={}
    for d,_,fs in os.walk(raiz):
        for f in fs:
            p=os.path.join(d,f); rel=re.sub(r'#U([0-9a-fA-F]{4})',lambda m:chr(int(m.group(1),16)),os.path.relpath(p,raiz))
            m[unicodedata.normalize('NFC',rel)]=p
            m[unicodedata.normalize('NFC',re.sub(r'^[^/]*/','',rel))]=p
    return m
fm=idx(raiz)
def texto(p):
    e=p.rsplit('.',1)[-1].lower()
    if e=='pdf': return subprocess.run(['pdftotext','-layout' if False else '-q',p,'-'],capture_output=True,text=True,timeout=180).stdout
    if e=='pptx':
        z=zipfile.ZipFile(p); sl=sorted([n for n in z.namelist() if re.match(r'ppt/slides/slide\d+\.xml',n)],key=lambda s:int(re.findall(r'\d+',s)[0]))
        return '\n\n'.join(' '.join(re.findall(r'<a:t>([^<]*)</a:t>',z.read(n).decode('utf8','ignore'))) for n in sl)
    if e=='docx':
        z=zipfile.ZipFile(p); x=z.read('word/document.xml').decode('utf8','ignore')
        return re.sub(r'</w:p>','\n',x) and ' '.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>',re.sub(r'</w:p>','</w:t><w:t>\n</w:t>',x)))
    if e in('txt',): return open(p,errors='ignore').read()
    return ''
def q(s): return "'"+s.replace("'","''")+"'" if s is not None else 'NULL'
print('BEGIN;'); nl=0; faltam=[]
for r in csv.DictReader(open(cat,encoding='utf-8')):
    if r['uso'] not in('literatura','fonte_institucional') or r['temas_provaveis']=='REVISAR' or r.get('duplicata_de_doi')=='SIM': continue
    p=fm.get(unicodedata.normalize('NFC',r['arquivo']))
    if not p: faltam.append(r['arquivo']); continue
    t=texto(p).replace('\x00','')
    if len(t)<200: faltam.append(r['arquivo']+' (sem texto extraivel)'); continue
    h=hashlib.sha256(t.encode()).hexdigest(); tag='$f'+h[:8]+'$'
    for tema in r['temas_provaveis'].split(';'):
        print(f"INSERT INTO conteudo.fonte (tema_id,camada,titulo,doi,trecho_literal,texto_integral,arquivo_origem,sha256) "
              f"SELECT tema_id,{int(r['camada_sugerida'] or 4)},{q(r['titulo_extraido'][:300] or os.path.basename(r['arquivo']))},{q(r['doi'] or None)},NULL,{tag}{t}{tag},{q(r['arquivo'])},'{h}' "
              f"FROM app.tema WHERE replace(codigo,'-','')='{tema}' ON CONFLICT DO NOTHING;"); nl+=1
print('COMMIT;')
sys.stderr.write(f'{nl} insercoes; {len(faltam)} arquivos nao encontrados ou sem texto\n')
open('carga_fontes_pendentes.txt','w').write('\n'.join(faltam))
PY
if [ "$APLICAR" = "--aplicar" ]; then psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f carga_fontes.sql; else echo "SQL em carga_fontes.sql (nao aplicado)"; fi
