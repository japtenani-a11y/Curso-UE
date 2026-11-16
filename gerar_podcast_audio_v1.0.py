#!/usr/bin/env python3
# gerar_podcast_audio_v1.0.py
# OBJETIVO: transformar o roteiro do podcast de um tema (peca "podcast_roteiro" publicada no banco) em audio MP3,
#           com duas vozes (PRECEPTOR e RESIDENTE), pela Text-to-Speech do Google Cloud.
# SAIDA: programa-cut/podcast/<CODIGO>.mp3 (ex.: T001.mp3). O aplicativo mostra o player na peca "Podcast".
#        Os audios ficam fora do GitHub.
# CHAVE: a chave da API fica so em ~/.config/curso-ue/tts.env (chmod 600), numa linha GOOGLE_TTS_KEY=...
#        Nunca no codigo, no repositorio ou na conversa.
# USO (no WSL, dentro de ~/Curso-UE):
#   python3 gerar_podcast_audio_v1.0.py T001            (um tema)
#   python3 gerar_podcast_audio_v1.0.py --todos         (todos os temas com roteiro publicado e sem audio)
#   python3 gerar_podcast_audio_v1.0.py T001 --rascunho (usa o rascunho mais recente, para ouvir antes de publicar;
#                                                        salva como T001_rascunho.mp3, que o aplicativo nao mostra)
#   python3 gerar_podcast_audio_v1.0.py T001 --so-texto (nao chama o Google: mostra o texto que seria falado)
#   python3 gerar_podcast_audio_v1.0.py T001 --slides   (audio da fala de cada slide da aula e do caso:
#                                                        programa-cut/slides/T001/slide_01.mp3, slide_02.mp3...)
#   A fala de cada slide vem da linha "> **Fala:**" do slide; sem ela, da "> **Nota do apresentador:**".
#   Os slides do caso clinico sao montados a partir da peca "Caso da aula", na mesma ordem que o aplicativo mostra.
# VOZES (opcional, no mesmo tts.env): VOZ_PRECEPTOR=pt-BR-Neural2-B  VOZ_RESIDENTE=pt-BR-Neural2-C
# BANCO: usa as mesmas variaveis do subir (PGHOST, PGPORT; padrao localhost:5432) e o usuario postgres.
# CUSTO: cada roteiro tem cerca de 8 mil caracteres; a cota gratuita das vozes Neural2 e de 1 milhao por mes.
import json, os, re, subprocess, sys, urllib.request, urllib.error

RAIZ = os.path.dirname(os.path.abspath(__file__))
PASTA = os.path.join(RAIZ, 'programa-cut', 'podcast') if os.path.isdir(os.path.join(RAIZ, 'programa-cut')) else os.path.join(RAIZ, 'podcast')
ENV = os.path.expanduser('~/.config/curso-ue/tts.env')

def config():
    c = {}
    if os.path.exists(ENV):
        for l in open(ENV, encoding='utf-8'):
            if '=' in l and not l.lstrip().startswith('#'):
                k, v = l.split('=', 1); c[k.strip()] = v.strip().strip('"').strip("'")
    return c

def psql(sql, *args):
    cmd = ['psql', '-h', os.environ.get('PGHOST', 'localhost'), '-p', os.environ.get('PGPORT', '5432'), '-U', 'postgres',
           '-d', 'programa', '-At', '-v', 'ON_ERROR_STOP=1']
    for i, a in enumerate(args): cmd += ['-v', f'a{i}={a}']
    return subprocess.run(cmd, input=sql, capture_output=True, text=True, check=True).stdout

def peca(codigo, tipo, rascunho):
    status = 'rascunho' if rascunho else 'publicado'
    return psql("""SELECT a.corpo FROM conteudo.artefato a JOIN app.tema t ON t.tema_id = a.tema_id
                    WHERE upper(replace(t.codigo,'-','')) = :'a0' AND a.tipo = :'a2' AND a.status::text = :'a1'
                    ORDER BY a.versao DESC LIMIT 1""", codigo, status, tipo)

def roteiro(codigo, rascunho): return peca(codigo, 'podcast_roteiro', rascunho)

def sem_codigos(t):
    return re.sub(r'\s*\[[ADPHG][1-9]\d*(?:,\s*[ADPHG][1-9]\d*)*\]', '', t).strip()

def falar(t):
    t = re.sub(r'[*_`#>]', '', sem_codigos(t)).replace('xABCDE', 'X, A, B, C, D, E').replace('ABCDE', 'A, B, C, D, E')
    return re.sub(r'\s+', ' ', t).strip()

# Mesma leitura da tela (Slides.tsx): fala por slide, e o caso no fim se a peca de slides nao trouxer o caso.
def falas_dos_slides(corpo, caso):
    slides, secao, atual, campo = [], '', None, None
    for l in corpo.split('\n'):
        l = l.rstrip()
        m = re.match(r'^###\s+Slide\s+\d+\.?\s*(.*)$', l, re.I)
        if m:
            atual = {'secao': secao, 'titulo': m.group(1).strip(), 'fala': '', 'nota': ''}; slides.append(atual); campo = None; continue
        m = re.match(r'^##\s+(?:\d+\.\s*)?(.*)$', l)
        if m and not l.startswith('###'):
            secao = re.sub(r':.*$', '', m.group(1)).strip(); atual = None; continue
        if not atual: continue
        m = re.match(r'^>\s?(.*)$', l)
        if m:
            t = m.group(1)
            f = re.match(r'^\*\*(Fala|Roteiro de fala|Nota do apresentador)\s*:?\*\*\s*:?\s*(.*)$', t, re.I)
            if f: campo = 'nota' if 'nota' in f.group(1).lower() else 'fala'; t = f.group(2)
            if campo: atual[campo] = (atual[campo] + ' ' + t).strip()
            continue
        campo = None
    saida = [falar(s['fala'] or s['nota']) for s in slides]
    if caso and not any(re.search('caso', s['secao'] + ' ' + s['titulo'], re.I) for s in slides):
        blocos, abertura = [], []
        for l in caso.split('\n'):
            m = re.match(r'^\*\*((?:Ponto de decisão|Perguntas de fechamento|Desfecho)[^*]*)\*\*\s*(.*)$', l)
            if m: blocos.append([re.sub(r'[.:]\s*$', '', m.group(1)).strip(), [m.group(2)] if m.group(2) else []]); continue
            if blocos: blocos[-1][1].append(l)
            elif not l.startswith('# ') and not re.match(r'^Duração:', l.strip(), re.I) and not l.startswith('>'): abertura.append(l)
        pontos = [b for b in blocos if not b[0].startswith('Desfecho')]
        desf = ' '.join(' '.join(b[1]) for b in blocos if b[0].startswith('Desfecho')).strip()
        if pontos:
            saida.append(falar(' '.join(x for x in abertura if x.strip())))
            for tit, ls in pontos:
                t = '\n'.join(ls).strip(); i = t.find('Discussão:')
                sit = re.sub(r'^Situação:\s*', '', t[:i] if i >= 0 else t, flags=re.M).strip()
                disc = t[i + len('Discussão:'):].strip() if i >= 0 else ''
                nome = re.sub(r'^Ponto de decisão \d+\s*[—-]\s*', '', tit)
                saida.append(falar(f"{nome}{'' if nome[-1:] in '?!.' else '.'} {sit} Pense na sua conduta. {disc}"))
            if desf: saida.append(falar(desf))
    return saida

def gerar_slides(codigo, rascunho, so_texto, c):
    corpo = peca(codigo, 'slides', rascunho)
    if not corpo.strip(): print(f"{codigo}: sem slides {'em rascunho' if rascunho else 'publicados'}; nada feito."); return
    lista = falas_dos_slides(corpo, peca(codigo, 'caso', rascunho))
    if so_texto:
        for i, t in enumerate(lista, 1): print(f"[slide {i:02d}] {t}")
        print(f"\n{codigo}: {len(lista)} slides, {sum(len(t) for t in lista)} caracteres."); return
    chave = c.get('GOOGLE_TTS_KEY') or sys.exit(f"ERRO: falta GOOGLE_TTS_KEY em {ENV} (veja docs/podcast_audio.md).")
    voz = c.get('VOZ_SLIDES', c.get('VOZ_PRECEPTOR', 'pt-BR-Neural2-B'))
    base = os.path.dirname(PASTA)
    pasta = os.path.join(base, 'slides', codigo + ('_rascunho' if rascunho else ''))
    os.makedirs(pasta, exist_ok=True)
    for i, t in enumerate(lista, 1):
        if not t: continue
        destino = os.path.join(pasta, f'slide_{i:02d}.mp3')
        open(destino + '.parcial', 'wb').write(sintetizar(t, voz, chave)); os.replace(destino + '.parcial', destino)
        print(f"\r{codigo}: slide {i} de {len(lista)}", end='', flush=True)
    print(f"\n{codigo}: audios dos slides em {pasta}")

def temas_sem_audio():
    cods = psql("""SELECT DISTINCT upper(replace(t.codigo,'-','')) FROM conteudo.artefato a JOIN app.tema t ON t.tema_id = a.tema_id
                    WHERE a.tipo = 'podcast_roteiro' AND a.status = 'publicado' ORDER BY 1""").split()
    return [c for c in cods if not os.path.exists(os.path.join(PASTA, f'{c}.mp3'))]

# Falas na ordem: [(voz, texto)]. So entram as linhas "**PRECEPTOR:** ..." e "**RESIDENTE:** ...";
# saem titulo, rubricas, faixa de rascunho, codigos de fonte [A1, D2] e marcas de formatacao.
def falas(corpo):
    saida = []
    for l in corpo.split('\n'):
        m = re.match(r'^\s*\*\*(PRECEPTOR|RESIDENTE)\s*:?\*\*\s*:?\s*(.+)$', l)
        if not m: continue
        t = re.sub(r'\s*\[[ADPHG]\d+(?:\s*,\s*[ADPHG]\d+)*\]', '', m.group(2))
        t = re.sub(r'[*_`#>]', '', t).replace('xABCDE', 'X, A, B, C, D, E').replace('ABCDE', 'A, B, C, D, E')
        t = re.sub(r'\s+', ' ', t).strip()
        if t: saida.append((m.group(1), t))
    return saida

def sintetizar(texto, voz, chave):
    corpo = json.dumps({'input': {'text': texto}, 'voice': {'languageCode': 'pt-BR', 'name': voz},
                        'audioConfig': {'audioEncoding': 'MP3', 'speakingRate': 1.0, 'sampleRateHertz': 24000}}).encode()
    req = urllib.request.Request('https://texttospeech.googleapis.com/v1/text:synthesize', data=corpo,
                                 headers={'Content-Type': 'application/json', 'X-Goog-Api-Key': chave})
    try:
        with urllib.request.urlopen(req, timeout=60) as r: resp = json.load(r)
    except urllib.error.HTTPError as e:
        sys.exit(f"ERRO do Google ({e.code}): {e.read().decode()[:300]}\n"
                 "Confira se a API 'Cloud Text-to-Speech' esta ativada no projeto e se a chave permite usa-la.")
    import base64
    return base64.b64decode(resp['audioContent'])

def gerar(codigo, rascunho, so_texto, c):
    corpo = roteiro(codigo, rascunho)
    if not corpo.strip():
        print(f"{codigo}: sem roteiro {'em rascunho' if rascunho else 'publicado'}; nada feito."); return
    lista = falas(corpo)
    if not lista:
        print(f"{codigo}: o roteiro nao tem falas no formato **PRECEPTOR:** / **RESIDENTE:**; nada feito."); return
    if so_texto:
        for v, t in lista: print(f"[{v}] {t}")
        print(f"\n{codigo}: {len(lista)} falas, {sum(len(t) for _, t in lista)} caracteres."); return
    chave = c.get('GOOGLE_TTS_KEY') or sys.exit(f"ERRO: falta GOOGLE_TTS_KEY em {ENV} (veja docs/podcast_audio.md).")
    vozes = {'PRECEPTOR': c.get('VOZ_PRECEPTOR', 'pt-BR-Neural2-B'), 'RESIDENTE': c.get('VOZ_RESIDENTE', 'pt-BR-Neural2-C')}
    os.makedirs(PASTA, exist_ok=True)
    destino = os.path.join(PASTA, f"{codigo}{'_rascunho' if rascunho else ''}.mp3")
    partes = []
    for i, (v, t) in enumerate(lista, 1):
        partes.append(sintetizar(t, vozes[v], chave))
        print(f"\r{codigo}: fala {i} de {len(lista)}", end='', flush=True)
    tmp = destino + '.parcial'
    with open(tmp, 'wb') as f:
        for p in partes: f.write(p)
    os.replace(tmp, destino)
    print(f"\n{codigo}: audio salvo em {destino}")

if __name__ == '__main__':
    a = sys.argv[1:]
    if not a or a[0] in ('-h', '--help'): print(open(__file__).read().split('import json')[0]); sys.exit(0)
    c = config()
    rasc, txt = '--rascunho' in a, '--so-texto' in a
    cods = temas_sem_audio() if '--todos' in a else [x.replace('-', '').upper() for x in a if not x.startswith('--')]
    if not cods: print('Nenhum tema para gerar.')
    for cod in cods:
        if '--slides' in a: gerar_slides(cod, rasc, txt, c)
        else: gerar(cod, rasc, txt, c)
