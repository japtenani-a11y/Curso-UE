#!/usr/bin/env python3
# registrar_fonte.py — usado pela ponte da coordenacao para cada arquivo solto em CUT_coordenacao\fontes_novas.
# Extrai o texto (PDF, TXT ou DOCX), confere se ha cara de dado de paciente e imprime:
#   RECUSAR<TAB>motivo           -> a ponte move o arquivo para fontes_recusadas e nada entra no banco
#   REGISTRAR<TAB>nome_destino   -> seguido, nas linhas seguintes, do SQL que registra a fonte (app.coord_registrar_fonte)
import hashlib, os, re, subprocess, sys, unicodedata, zipfile
p = sys.argv[1]
nome = os.path.basename(p)
dados = open(p, 'rb').read()
sha = hashlib.sha256(dados).hexdigest()
ext = nome.rsplit('.', 1)[-1].lower() if '.' in nome else ''
texto = ''
try:
    if ext == 'pdf':
        texto = subprocess.run(['pdftotext', '-q', p, '-'], capture_output=True, text=True, timeout=300).stdout
    elif ext in ('txt', 'md'):
        texto = dados.decode('utf-8', 'ignore')
    elif ext == 'docx':
        x = zipfile.ZipFile(p).read('word/document.xml').decode('utf8', 'ignore')
        texto = re.sub(r'<[^>]+>', ' ', re.sub(r'</w:p>', '\n', x))
    else:
        print(f'RECUSAR\ttipo de arquivo nao aceito ({ext or "sem extensao"}): use PDF, DOCX ou TXT'); sys.exit(0)
except FileNotFoundError:
    print('RECUSAR\tfalta o pdftotext no WSL (sudo apt install -y poppler-utils)'); sys.exit(0)
texto = texto.replace('\x00', '')
# cara de dado de paciente: CPF, prontuario/registro com numero, data de nascimento preenchida, nome de paciente preenchido
padroes = [(r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b', 'CPF'),
           (r'(?i)prontu[aá]rio\s*(n[ºo°.]*)?\s*:?\s*\d{5,}', 'número de prontuário'),
           (r'(?i)\bregistro\s*(hc|hospitalar)?\s*:?\s*\d{6,}', 'número de registro hospitalar'),
           (r'(?i)data\s+de\s+nascimento\s*:?\s*\d{1,2}/\d{1,2}/\d{2,4}', 'data de nascimento preenchida'),
           (r'(?i)nome\s+do\s+paciente\s*:?\s*[A-ZÁÉÍÓÚÂÊÔÃÕÇ][a-záéíóúâêôãõç]+\s+[A-ZÁÉÍÓÚÂÊÔÃÕÇ]', 'nome de paciente preenchido')]
for rx, o in padroes:
    if re.search(rx, texto):
        print(f'RECUSAR\tparece ter dado de paciente ({o}); só entram fontes sem dado de paciente (fichas em branco, protocolos, artigos)'); sys.exit(0)
base = unicodedata.normalize('NFKD', nome.rsplit('.', 1)[0]).encode('ascii', 'ignore').decode()
base = re.sub(r'[^A-Za-z0-9]+', '-', base).strip('-').lower()[:60] or 'fonte'
destino = f'F{sha[:8]}_{base}.{ext}'
def dq(s):
    k = 'f'
    while f'${k}$' in s: k += 'x'
    return f'${k}${s}${k}$'
print(f'REGISTRAR\t{destino}')
print(f"SELECT app.coord_registrar_fonte('{sha}', {dq(nome)}, {dq(destino)}, {dq(texto)});")
