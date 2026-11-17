#!/usr/bin/env python3
# fontes_banco.py — grava em <destino> o texto de cada fonte do tema (um .txt por fonte) e o catalogo fontes_banco.csv.
# Uso: python3 -I ferramentas/fontes_banco.py <json das fontes> <destino>
# O json vem do banco (lista de {arquivo, titulo, autores, ano, doi, pmid, camada, texto}). Usado pela ponte, para a pasta
# do agente produtor (CUT_coordenacao\producao\<TEMA>\fontes_banco). Mesmo formato do fontes_do_tema_v1.0.sh.
import csv, json, os, sys
js, d = sys.argv[1], sys.argv[2]
fs = json.load(open(js, encoding='utf-8')) or []
os.makedirs(d, exist_ok=True)
tmp = os.path.join(d, '.fontes_banco.csv')
with open(tmp, 'w', encoding='utf-8', newline='') as fh:
    w = csv.writer(fh, delimiter=';')
    w.writerow(['arquivo_txt', 'codigo_para_citar', 'titulo', 'autores', 'ano', 'doi', 'pmid', 'camada', 'tem_texto'])
    for f in fs:
        base = os.path.basename(f['arquivo']).rsplit('.', 1)[0]
        cod = base.split('_')[0] if base.startswith('F') else '_'.join(base.split('_')[1:3])
        if f.get('texto'):
            alvo = os.path.join(d, base + '.txt')
            novo = f['texto']
            if not os.path.exists(alvo) or open(alvo, encoding='utf-8', errors='ignore').read() != novo:
                open(alvo, 'w', encoding='utf-8').write(novo)
        w.writerow([base + '.txt' if f.get('texto') else '', cod, f['titulo'], f.get('autores') or '', f.get('ano') or '',
                    f.get('doi') or '', f.get('pmid') or '', f['camada'], 'sim' if f.get('texto') else 'nao'])
os.replace(tmp, os.path.join(d, 'fontes_banco.csv'))
print(f'{len(fs)} fontes ({sum(1 for f in fs if f.get("texto"))} com texto)')
