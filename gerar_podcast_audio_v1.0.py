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

def roteiro(codigo, rascunho):
    status = 'rascunho' if rascunho else 'publicado'
    return psql("""SELECT a.corpo FROM conteudo.artefato a JOIN app.tema t ON t.tema_id = a.tema_id
                    WHERE upper(replace(t.codigo,'-','')) = :'a0' AND a.tipo = 'podcast_roteiro' AND a.status::text = :'a1'
                    ORDER BY a.versao DESC LIMIT 1""", codigo, status)

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
    for cod in cods: gerar(cod, rasc, txt, c)
