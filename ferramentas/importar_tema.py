#!/usr/bin/env python3
# importar_tema.py — importador generico de um tema do CUT (pecas, afirmacoes, fontes, casos dos testes e questoes).
# Uso (pelo importar_tema_v1.0.sh): python3 -I ferramentas/importar_tema.py <pasta do tema> <saida.sql>
# Le a pasta no formato de docs/producao_de_tema.md, confere tudo o que da para conferir sem o banco, gera os
# testes e gabaritos a partir de questoes.json e escreve um SQL unico. O SQL confere o formato das pecas no banco
# (conteudo.erros_formato) antes de gravar e termina em ROLLBACK (conferencia) ou COMMIT (com --aplicar).
# Sai com codigo 2 se houver erro; avisos nao impedem.
import csv, hashlib, json, os, re, subprocess, sys, unicodedata

PERFIS = ['Graduação', 'R1', 'R2', 'R3', 'R+']
PER_BANCO = {'Graduação': 'graduacao', 'R1': 'R1', 'R2': 'R2', 'R3': 'R3', 'R+': 'R+'}
NOMES = {1: 'Pré-teste 1', 2: 'Pré-teste 2', 3: 'Pós-teste D0', 4: 'Pós-teste D+15', 5: 'Pós-teste D+45', 6: 'Pós-teste D+90'}
GRAUS = ['Muito fácil', 'Fácil', 'Média', 'Difícil', 'Muito difícil', 'Extrema']
TAXA = ['acima de 90%', '75% a 90%', '50% a 75%', '30% a 50%', '15% a 30%', 'abaixo de 15%']
CATEG = {'correta': None, 'erro conceitual': 'erro_conceitual', 'erro de conduta': 'erro_conduta',
         'erro de indicação': 'erro_indicacao', 'erro técnico': 'erro_tecnico'}
MATERIAL = ['objetivos', 'resumo_basico', 'podcast_roteiro', 'caso_base', 'sintese_evidencia', 'mapa', 'aula', 'slides',
            'caso', 'resumo', 'protocolo', 'checklist', 'flashcard']
OPCIONAIS = ['simulado', 'banco_dificuldade']
LET = 'ABCDE'
REF = re.compile(r'\b[ADPHG]\d+\b')

erros, avisos = [], []
def erro(m): erros.append(m)
def aviso(m): avisos.append(m)
def norm(t):
    t = unicodedata.normalize('NFC', t or '')
    t = re.sub(r'-\s*\n\s*', '', t)
    return re.sub(r'\s+', ' ', t).strip().lower()
def dq(s, tag='cut'):
    s = s if isinstance(s, str) else str(s)
    k = tag
    while f'${k}$' in s: k += 'x'
    return f'${k}${s}${k}$'
def lit(v): return 'NULL' if v in (None, '') else dq(v)

pasta, saida = sys.argv[1], sys.argv[2]
tema = os.path.basename(os.path.normpath(pasta)).upper().replace('-', '')
if not re.fullmatch(r'T\d{3}', tema): sys.exit(f'ERRO: a pasta precisa se chamar como o tema, por exemplo T002 (veio "{tema}").')
TEMA_SQL = f"replace(t.codigo,'-','')='{tema}'"

# ---------- pecas ----------
pecas = {}
for tipo in MATERIAL + OPCIONAIS:
    f = os.path.join(pasta, 'pecas', f'{tipo}.md')
    if not os.path.exists(f):
        if tipo in MATERIAL: erro(f'falta a peça pecas/{tipo}.md')
        continue
    corpo = open(f, encoding='utf-8').read().replace('\r\n', '\n')
    m = re.search(r'^# (.+)$', corpo, re.M)
    titulo = re.sub(rf'^{tema[0]}-?{tema[1:]}\s*[—-]\s*', '', m.group(1).strip()) if m else tipo
    if not m: aviso(f'{tipo}: sem título "# {tema} — ..." (usei o nome do tipo)')
    pecas[tipo] = {'titulo': titulo, 'corpo': corpo}

# ---------- afirmacoes ----------
afirm = {}
fa = os.path.join(pasta, 'afirmacoes.csv')
if not os.path.exists(fa): erro('falta afirmacoes.csv (codigo;texto;fonte_arquivo;trecho_literal)')
else:
    for i, r in enumerate(csv.DictReader(open(fa, encoding='utf-8-sig'), delimiter=';'), 2):
        cod = (r.get('codigo') or '').strip()
        if not REF.fullmatch(cod): erro(f'afirmacoes.csv linha {i}: código "{cod}" fora do padrão (A1, D3, P2, H1, G4)'); continue
        if cod in afirm: erro(f'afirmacoes.csv: código {cod} repetido'); continue
        if not (r.get('texto') or '').strip(): erro(f'afirmacoes.csv: {cod} sem texto')
        if not (r.get('trecho_literal') or '').strip(): aviso(f'afirmacoes.csv: {cod} sem trecho literal da fonte')
        afirm[cod] = {k: (r.get(k) or '').strip() for k in ('texto', 'fonte_arquivo', 'trecho_literal')}

# ---------- fontes ----------
fontes = []
ff = os.path.join(pasta, 'fontes.csv')
dir_fontes = os.path.join(pasta, 'fontes')
if not os.path.exists(ff): aviso('sem fontes.csv: nenhuma fonte com texto integral será carregada')
else:
    for i, r in enumerate(csv.DictReader(open(ff, encoding='utf-8-sig'), delimiter=';'), 2):
        arq = (r.get('arquivo') or '').strip()
        cam = (r.get('camada') or '').strip()
        if cam not in ('1', '2', '3', '4', '5'): erro(f'fontes.csv linha {i}: camada "{cam}" (use 1 histórico, 2 livro-texto, 3 protocolo, 4 literatura, 5 diretriz)'); continue
        texto = None; sha = None
        if arq:
            p = os.path.join(dir_fontes, arq)
            if not os.path.exists(p): erro(f'fontes.csv linha {i}: arquivo fontes/{arq} não encontrado'); continue
            if not arq.upper().startswith(tema + '_'): aviso(f'fontes/{arq}: o nome deveria começar por {tema}_AAAA_NN_ (por exemplo {tema}_2024_01_titulo.pdf)')
            sha = hashlib.sha256(open(p, 'rb').read()).hexdigest()
            if arq.lower().endswith('.pdf'):
                try: texto = subprocess.run(['pdftotext', '-q', p, '-'], capture_output=True, text=True, timeout=180).stdout
                except FileNotFoundError: sys.exit('ERRO: falta o pdftotext. Rode: sudo apt install -y poppler-utils')
            elif arq.lower().endswith(('.txt', '.md')): texto = open(p, encoding='utf-8', errors='ignore').read()
            if not (texto or '').strip(): aviso(f'fontes/{arq}: não saiu texto (PDF escaneado?); o revisor não conseguirá conferir os trechos')
            texto = (texto or '').replace('\x00', '')
        fontes.append({'arquivo': arq, 'titulo': (r.get('titulo') or arq).strip(), 'autores': (r.get('autores') or '').strip(),
                       'ano': (r.get('ano') or '').strip(), 'doi': (r.get('doi') or '').strip(), 'pmid': (r.get('pmid') or '').strip(),
                       'camada': int(cam), 'texto': texto, 'sha': sha})
    if os.path.isdir(dir_fontes):
        listados = {f['arquivo'] for f in fontes}
        for arq in sorted(os.listdir(dir_fontes)):
            if arq not in listados and not arq.startswith('.'): aviso(f'fontes/{arq} não está no fontes.csv e não será carregado')

# fontes ja guardadas no banco para o tema (fontes_do_tema_v1.0.sh): reconhecidas, nao sao carregadas de novo
dir_banco = os.path.join(pasta, 'fontes_banco')
banco = []
if os.path.isdir(dir_banco):
    for arq in sorted(os.listdir(dir_banco)):
        if arq.endswith('.txt'): banco.append({'arquivo': arq, 'texto': open(os.path.join(dir_banco, arq), encoding='utf-8', errors='ignore').read()})
# trechos literais nas fontes
sem_arquivo = {}
for cod, a in afirm.items():
    if not a['fonte_arquivo']: continue
    alvo = [f for f in fontes + banco if f['arquivo'] and a['fonte_arquivo'].lower() in f['arquivo'].lower()]
    if not alvo:
        if cod.startswith('A'): sem_arquivo.setdefault(a['fonte_arquivo'], []).append(cod)
        continue
    if a['trecho_literal'] and alvo[0]['texto'] and norm(a['trecho_literal'])[:60] not in norm(alvo[0]['texto']):
        aviso(f'{cod}: o trecho literal não foi achado no texto de {alvo[0]["arquivo"]}')

for fo, cs in sorted(sem_arquivo.items()):
    aviso(f'fonte "{fo}" sem arquivo em fontes/ nem em fontes_banco/ ({", ".join(cs)}): o revisor confere à mão')
# ---------- casos e questoes ----------
casos = {}
fc = os.path.join(pasta, 'casos_teste.json')
if os.path.exists(fc):
    for k, v in json.load(open(fc, encoding='utf-8')).items():
        casos[int(k)] = (v['titulo'], v['texto'])
for n in range(1, 7):
    if n not in casos: erro(f'casos_teste.json: falta o caso do teste {n}')

questoes = []
fq = os.path.join(pasta, 'questoes.json')
if not os.path.exists(fq): erro('falta questoes.json')
else: questoes = json.load(open(fq, encoding='utf-8'))
cods = set(); longas = []
for q in questoes:
    qid = q.get('id', '?')
    if qid in cods: erro(f'questão {qid}: id repetido')
    cods.add(qid)
    if not q.get('enunciado'): erro(f'questão {qid}: sem enunciado')
    alts, js, cats = q.get('alternativas', []), q.get('justificativas', []), q.get('categorias', [])
    if len(alts) != 5 or len(js) != 5 or len(cats) != 5: erro(f'questão {qid}: precisa de 5 alternativas, 5 justificativas e 5 categorias')
    elif cats.count('correta') != 1: erro(f'questão {qid}: exatamente uma categoria "correta"')
    elif LET[cats.index('correta')] != q.get('correta'): erro(f'questão {qid}: a letra "correta" ({q.get("correta")}) não bate com a categoria "correta"')
    for c in cats:
        if c not in CATEG: erro(f'questão {qid}: categoria "{c}" desconhecida ({", ".join(CATEG)})')
    if not isinstance(q.get('grau'), int) or not 1 <= q['grau'] <= 6: erro(f'questão {qid}: grau de 1 a 6')
    if q.get('fixa'):
        if q.get('perfil') or q.get('teste'): erro(f'questão {qid}: âncora (fixa) não tem perfil nem teste: vale para todos, nas seis ondas')
    else:
        if q.get('perfil') not in PERFIS: erro(f'questão {qid}: perfil "{q.get("perfil")}" ({", ".join(PERFIS)})')
        if q.get('teste') not in range(1, 7): erro(f'questão {qid}: teste de 1 a 6')
    for a in q.get('ancoras', []):
        if REF.fullmatch(a) and a.startswith('A') and a not in afirm: aviso(f'questão {qid}: âncora {a} não está em afirmacoes.csv')
    # pistas classicas de item mal escrito
    if alts and max(alts, key=len) == alts[LET.index(q.get('correta', 'A'))] and len(alts[LET.index(q.get('correta', 'A'))]) > 1.5 * sorted(map(len, alts))[-2]:
        longas.append(qid)
    if any(re.search(r'todas as (anteriores|alternativas)|nenhuma das anteriores', x, re.I) for x in alts):
        aviso(f'questão {qid}: evite "todas" ou "nenhuma das anteriores"')
if longas: aviso(f'{len(longas)} de {len(questoes)} questões têm a correta bem mais longa que as outras (pista para o aluno): ' + ', '.join(longas[:12]) + (' ...' if len(longas) > 12 else ''))
fixas = [q for q in questoes if q.get('fixa')]
if not fixas: erro('nenhuma questão âncora (fixa): a regra é 2 a 3 por tema')
elif len(fixas) < 2: aviso(f'{len(fixas)} questão âncora: a regra é 2 a 3 por tema')
elif len(fixas) > 3: aviso(f'{len(fixas)} questões âncora: a regra é 2 a 3 por tema')
for n in range(1, 7):
    for p in PERFIS:
        k = len([q for q in questoes if not q.get('fixa') and q.get('teste') == n and q.get('perfil') == p])
        if k == 0: erro(f'teste {n}, perfil {p}: nenhuma questão')
        elif k < 4: aviso(f'teste {n}, perfil {p}: só {k} questões')
for n in range(1, 7):
    letras = [q['correta'] for q in questoes if q.get('teste') == n and not q.get('fixa')]
    if letras and max(letras.count(l) for l in LET) > 0.4 * len(letras): aviso(f'teste {n}: a mesma letra é a correta em mais de 40% das questões')

# referencias das pecas
for tipo, pc in pecas.items():
    for r in sorted(set(REF.findall(pc['corpo']))):
        if r.startswith('A') and r not in afirm: aviso(f'{tipo}: cita [{r}], que não está em afirmacoes.csv')

if erros:
    print('ERROS (nada foi gravado):'); [print('  - ' + e) for e in erros]
    if avisos: print('AVISOS:'); [print('  - ' + a) for a in avisos]
    sys.exit(2)

# ---------- testes e gabaritos gerados ----------
FAIXA = (f'> RASCUNHO para revisão (tolerância: 5% de erro leve, zero crítico). [H#] histórico; [D#] livro-texto; [P#] protocolo '
         f'institucional; [A#] artigo; [G#] diretriz. Casos e dados de pacientes são fictícios.\n\n')
for n in range(1, 7):
    ct, cx = casos[n]
    prova = [f'# {tema[0]}-{tema[1:]} — {NOMES[n]}\n',
             f'Múltipla escolha, 5 alternativas, uma correta. As primeiras questões são as âncoras do tema; as demais partem do {ct.lower()}.\n',
             f'**{ct}.** {cx}\n']
    gab = [f'# {tema[0]}-{tema[1:]} — Gabarito comentado: {NOMES[n]}\n',
           'Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau, taxa de acerto esperada, justificativa de cada alternativa e âncora na fonte.\n']
    anc = set()
    for p in PERFIS:
        prova.append(f'\n## Perfil {p}\n'); gab.append(f'\n## Perfil {p}\n')
        lista = fixas + [q for q in questoes if not q.get('fixa') and q.get('teste') == n and q.get('perfil') == p]
        for k, q in enumerate(lista, 1):
            prova.append(f"**{k}.** {q['enunciado']}\n" + '\n'.join(f'- {LET[i]}) {a}' for i, a in enumerate(q['alternativas'])) + '\n')
            gab.append(f"**{k}. Resposta {q['correta']}** · grau {GRAUS[q['grau'] - 1]} · taxa de acerto esperada {q.get('taxa_esperada') or TAXA[q['grau'] - 1]}"
                       f" · âncora {', '.join(q.get('ancoras', [])) or '—'}\n"
                       + '\n'.join(f"- {LET[i]}) {'**correta**' if c == 'correta' else c}: {j}" for i, (j, c) in enumerate(zip(q['justificativas'], q['categorias']))) + '\n')
            anc.update(q.get('ancoras', []))
    pecas[f'teste_{n}'] = {'titulo': NOMES[n], 'corpo': FAIXA + '\n'.join(prova), 'anc': anc}
    pecas[f'gabarito_{n}'] = {'titulo': f'Gabarito comentado — {NOMES[n]}', 'corpo': FAIXA + '\n'.join(gab), 'anc': anc}

# ---------- SQL ----------
L = [f'-- importacao do tema {tema} (gerado por ferramentas/importar_tema.py). Novas versoes em RASCUNHO; nada e apagado.',
     '\\set ON_ERROR_STOP on', 'BEGIN;',
     f"DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM app.tema t WHERE {TEMA_SQL}) THEN RAISE EXCEPTION 'tema {tema} nao existe no banco'; END IF; END $$;",
     'CREATE TEMP TABLE _imp (tipo TEXT PRIMARY KEY, titulo TEXT, corpo TEXT) ON COMMIT DROP;']
for tipo, pc in pecas.items():
    L.append(f"INSERT INTO _imp VALUES ('{tipo}', {dq(pc['titulo'])}, {dq(pc['corpo'])});")
L += ["\\echo 'conferencia de formato das pecas (erros impedem a publicacao):'",
      "SELECT tipo, f.gravidade, f.mensagem FROM _imp CROSS JOIN LATERAL conteudo.conferir_formato(tipo, corpo) f ORDER BY f.gravidade, tipo;",
      "DO $$ DECLARE e TEXT; BEGIN SELECT string_agg(tipo || ': ' || conteudo.erros_formato(tipo, corpo), ' | ') INTO e FROM _imp WHERE conteudo.erros_formato(tipo, corpo) IS NOT NULL;"
      " IF e IS NOT NULL THEN RAISE EXCEPTION 'formato_invalido: %', e; END IF; END $$;",
      # pecas: nova versao em rascunho quando o texto mudou
      f"""INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, i.tipo, coalesce((SELECT max(versao) FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.tipo::text = i.tipo), 0) + 1,
       'rascunho', i.titulo, i.corpo, false
  FROM _imp i CROSS JOIN app.tema t WHERE {TEMA_SQL}
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.tipo::text = i.tipo AND a.corpo = i.corpo);"""]
# afirmacoes de cada peca (as que ela cita) na versao mais recente
for tipo, pc in pecas.items():
    usados = sorted(set(REF.findall(pc['corpo'])) | set(pc.get('anc', set())))
    for cod in [c for c in usados if c in afirm]:
        a = afirm[cod]
        L.append(f"""INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, '{cod}', {dq(a['texto'])}, {lit(a['fonte_arquivo'])}, {lit(a['trecho_literal'])}
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE {TEMA_SQL} AND a.tipo::text = '{tipo}'
   AND a.versao = (SELECT max(x.versao) FROM conteudo.artefato x WHERE x.tema_id = a.tema_id AND x.tipo = a.tipo)
ON CONFLICT (artefato_id, codigo) DO UPDATE SET texto = EXCLUDED.texto, fonte_arquivo = EXCLUDED.fonte_arquivo, trecho_literal = EXCLUDED.trecho_literal;""")
# questoes carregadas antes do importador (T001): passam a usar o codigo no padrao <tema>-<id>
L.append(f"""UPDATE app.item i SET codigo = '{tema}-' || i.codigo FROM app.tema t
 WHERE i.tema_id = t.tema_id AND {TEMA_SQL} AND i.codigo ~ '^T[1-6]-';
UPDATE app.item i SET codigo = '{tema}-FIXA-1' FROM app.tema t WHERE i.tema_id = t.tema_id AND {TEMA_SQL} AND i.codigo = '{tema}-FIXA';""")
# fonte guardada em outro tema (triador de fontes) e citada aqui pelo codigo F<8 letras>: passa a valer tambem neste tema
for ref in sorted({a['fonte_arquivo'] for a in afirm.values() if re.fullmatch(r'F[0-9a-f]{8}', a['fonte_arquivo'] or '')}):
    L.append(f"""INSERT INTO conteudo.fonte (tema_id, camada, titulo, autores, ano, doi, pmid, url, texto_integral, arquivo_origem, sha256, camada_confirmada, tema_confirmado)
SELECT t.tema_id, x.camada, x.titulo, x.autores, x.ano, x.doi, x.pmid, x.url, x.texto_integral, x.arquivo_origem, x.sha256, true, true
  FROM app.tema t, LATERAL (SELECT * FROM conteudo.fonte f WHERE f.sha256 LIKE '{ref[1:]}%' AND f.texto_integral IS NOT NULL ORDER BY f.fonte_id LIMIT 1) x
 WHERE {TEMA_SQL} AND NOT EXISTS (SELECT 1 FROM conteudo.fonte y WHERE y.tema_id = t.tema_id AND y.sha256 = x.sha256);""")
# fontes
for f in fontes:
    L.append(f"""INSERT INTO conteudo.fonte (tema_id, camada, titulo, autores, ano, doi, pmid, texto_integral, arquivo_origem, sha256, camada_confirmada, tema_confirmado)
SELECT t.tema_id, {f['camada']}, {dq(f['titulo'])}, {lit(f['autores'])}, {f['ano'] if f['ano'].isdigit() else 'NULL'}, {lit(f['doi'])}, {lit(f['pmid'])},
       {lit(f['texto'])}, {lit(tema + '/' + f['arquivo'] if f['arquivo'] else '')}, {lit(f['sha'])}, true, true
  FROM app.tema t WHERE {TEMA_SQL}
   AND NOT EXISTS (SELECT 1 FROM conteudo.fonte x WHERE x.tema_id = t.tema_id
                     AND ({'x.sha256 = ' + dq(f['sha']) if f['sha'] else 'false'} OR (x.titulo = {dq(f['titulo'])} AND x.texto_integral IS NULL)));""")
# casos dos testes
for n, (ct, cx) in sorted(casos.items()):
    L.append(f"INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, {n}, {dq(ct)}, {dq(cx)} FROM app.tema t WHERE {TEMA_SQL} "
             "ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo = EXCLUDED.titulo, texto = EXCLUDED.texto;")
# questoes: atualiza a que ainda nao tem resposta; cria a que nao existe
nf = 0
for q in questoes:
    if q.get('fixa'): nf += 1
    cod = f'{tema}-FIXA-{nf}' if q.get('fixa') else f"{tema}-{q['id']}"
    perfil = 'NULL' if q.get('fixa') else f"'{PER_BANCO[q['perfil']]}'"
    teste = 'NULL' if q.get('fixa') else str(q['teste'])
    taxa = q.get('taxa_esperada') or ('por perfil' if q.get('fixa') else TAXA[q['grau'] - 1])
    anc = ', '.join(q.get('ancoras', []))
    sem_resp = f"NOT EXISTS (SELECT 1 FROM app.resposta r WHERE r.item_id = i.item_id)"
    vals = ',\n  '.join(f"({k + 1}, {dq(a)}, {'true' if c == 'correta' else 'false'}, {('NULL' if CATEG[c] is None else repr(CATEG[c]))}, {dq(j)})"
                         for k, (a, c, j) in enumerate(zip(q['alternativas'], q['categorias'], q['justificativas'])))
    L.append(f"""UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id = t.tema_id AND {TEMA_SQL} AND i.codigo = '{cod}' AND {sem_resp};
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id = i.item_id AND i.tema_id = t.tema_id AND {TEMA_SQL} AND i.codigo = '{cod}' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado = {dq(q['enunciado'])}, dificuldade = {q['grau']}, ancora = {lit(anc)}, taxa_esperada = {dq(taxa)},
       perfil = {perfil}, teste_num = {teste}, fixa = {'true' if q.get('fixa') else 'false'}
  FROM app.tema t WHERE i.tema_id = t.tema_id AND {TEMA_SQL} AND i.codigo = '{cod}' AND i.gabarito_alternativa_id IS NULL;
WITH novo AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, {dq(q['enunciado'])}, {q['grau']}, {lit(anc)}, '{cod}', {perfil}, {teste}, {'true' if q.get('fixa') else 'false'}, {dq(taxa)}
    FROM app.tema t WHERE {TEMA_SQL} AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id = t.tema_id AND x.codigo = '{cod}')
  RETURNING item_id),
alvo AS (SELECT item_id FROM novo UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id = x.tema_id
          WHERE {TEMA_SQL} AND x.codigo = '{cod}' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id = x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  {vals}) v(ordem, texto, correta, cat, just);""")
L.append(f"UPDATE app.item i SET gabarito_alternativa_id = a.alternativa_id FROM app.alternativa a, app.tema t WHERE a.item_id = i.item_id AND a.eh_correta "
         f"AND i.gabarito_alternativa_id IS NULL AND i.tema_id = t.tema_id AND {TEMA_SQL};")
# as questoes novas entram nas ondas de teste que o tema ja tem (as que ja estavam nao mudam de ordem)
L.append(f"""INSERT INTO app.item_selecionado (onda_id, item_id, ordem_apresentada)
SELECT o.onda_id, i.item_id,
       (coalesce((SELECT max(s.ordem_apresentada) FROM app.item_selecionado s WHERE s.onda_id = o.onda_id), 0)
        + row_number() OVER (PARTITION BY o.onda_id ORDER BY i.fixa DESC, i.perfil, i.codigo))::smallint
  FROM app.onda_instancia o JOIN app.tema t ON t.tema_id = o.tema_id
  JOIN app.item i ON i.tema_id = o.tema_id AND (i.fixa OR i.teste_num = o.teste_num)
 WHERE {TEMA_SQL} AND i.codigo IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM app.item_selecionado s WHERE s.onda_id = o.onda_id AND s.item_id = i.item_id);""")
L += ["\\echo 'resultado:'",
      f"""SELECT (SELECT count(DISTINCT a.tipo) FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE {TEMA_SQL} AND a.status::text IN ('rascunho','publicado')) AS pecas,
       (SELECT count(*) FROM conteudo.afirmacao f JOIN conteudo.artefato a USING (artefato_id) JOIN app.tema t USING (tema_id) WHERE {TEMA_SQL}) AS afirmacoes,
       (SELECT count(*) FROM conteudo.fonte f JOIN app.tema t USING (tema_id) WHERE {TEMA_SQL} AND f.texto_integral IS NOT NULL) AS fontes_com_texto,
       (SELECT count(*) FROM app.item i JOIN app.tema t USING (tema_id) WHERE {TEMA_SQL}) AS questoes,
       (SELECT count(*) FROM app.item i JOIN app.tema t USING (tema_id) WHERE {TEMA_SQL} AND i.fixa) AS ancoras;"""]
open(saida, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
print(f'{tema}: {len(pecas)} peças ({len(MATERIAL)} de material, 12 testes e gabaritos gerados), {len(afirm)} afirmações, '
      f'{len(fontes)} fontes, {len(questoes)} questões ({len(fixas)} âncoras).')
if avisos: print('AVISOS (não impedem):'); [print('  - ' + a) for a in avisos]
