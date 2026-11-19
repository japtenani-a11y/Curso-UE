# Ferramenta de uso unico (decisao da coordenacao de 19/11/2026): fusoes, temas novos, escopo ampliado e
# renumeracao T001-T150 na ordem dos modulos. Le os arquivos atuais e reescreve:
#   53_temas_programa_v1.0.sql, 65_arvore_temas_v1.0.sql, 73_extras_v1.0.sql, 92_prazos_producao_v1.0.sql,
#   docs/BUSCAS_PUBMED_150_temas.txt, docs/fila_producao_150.md
# e gera 101_reestruturacao_temas_v1.0.sql (migracao do banco) e docs/renumeracao_temas_2026-11-19.csv.
# Rodar uma vez so, a partir da raiz do repositorio: python3 ferramentas/reestruturar_temas_2026-11-19.py
import re, csv, sys, os

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def ler(p): return open(os.path.join(R, p), encoding='utf-8').read()
def gravar(p, s): open(os.path.join(R, p), 'w', encoding='utf-8').write(s)

s53 = ler('53_temas_programa_v1.0.sql')
if 'renumeracao de 19/11/2026' in s53:
    sys.exit('ja aplicado')
LINHA = re.compile(r"^\('T-(\d{3})','((?:[^']|'')*)','([^']*)',(\d),'(\w+)',(NULL|\d+)\)", re.M)
temas = [dict(c='T' + m.group(1), titulo=m.group(2), modulo=m.group(3), grau=int(m.group(4)), papel=m.group(5),
              ordem=m.group(6)) for m in LINHA.finditer(s53)]
assert len(temas) == 147, len(temas)
por = {t['c']: t for t in temas}

FUSOES = {'T126': 'T121', 'T125': 'T122', 'T129': 'T130', 'T132': 'T131', 'T150': 'T134'}
FUSOES_ANTIGAS = {'T078': 'T077', 'T144': 'T143', 'T145': 'T135', 'T146': 'T081', 'T147': 'T009', 'T092': 'T056',
                  'T057': 'T089', 'T080': 'T079', 'T120': 'T119', 'T124': 'T123', 'T128': 'T127'}
TITULOS = {
 'T121': 'Revisão sistemática, metanálise e qualidade do relato: forest plot, risco de viés, PRISMA, CONSORT, STROBE e IDEAL',
 'T122': 'Da evidência à decisão: GRADE, força da recomendação e aplicabilidade ao meu paciente',
 'T130': 'Preceptoria à beira do leito: autonomia supervisionada, prática deliberada e feedback que muda desempenho',
 'T131': 'Avaliação do residente: instrumentos, validade, construção de questões e rubricas e análise psicométrica',
 'T134': 'Ensino e certificação de procedimentos: laboratório, simulação, transferência para o ambiente real e medida da habilidade',
 'T007': 'Cirurgia de controle de danos no trauma e na cirurgia de urgência não traumática: indicação e timing de reoperação',
 'T050': 'Sepse e choque séptico no paciente cirúrgico: foco abdominal, controle do foco e ressuscitação',
 'T069': 'Cuidados paliativos na cirurgia de urgência e trauma: comunicação de más notícias e conversa com a família',
 'T086': 'Avaliação perioperatória, estratificação de risco e recuperação acelerada (ERAS) na cirurgia de urgência',
 'T114': 'Auditoria de protocolos, indicadores de qualidade das diretrizes e escores de trauma e de cirurgia de urgência (RTS, ISS, TRISS, AAST)',
 'T123': 'Diretrizes clínicas: leitura crítica, adaptação e elaboração (AGREE II, ADAPTE, GRADE), conflito de interesse e sociedades que discordam',
 'T141': 'Técnicas de fechamento de parede, prevenção de hérnia incisional, evisceração e deiscência de parede',
 'T085': 'Liderança da equipe de trauma e comunicação em crise: briefing, debriefing, CRM, TeamSTEPPS e simulação realística',
}
NOVOS = [  # (chave provisoria, titulo, modulo, grau, papel, maes, relevancia)
 ('N1', 'Registro de trauma, vigilância e painéis de desempenho do serviço: da ficha ao indicador', 'Auditoria, governança e sistemas', 3, 'complementar', ['T114', 'T113'], 4),
 ('N7', 'Custos e economia em saúde na urgência: custo-efetividade de protocolos, desperdício e o argumento financeiro de uma diretriz', 'Auditoria, governança e sistemas', 3, 'eletivo', ['T114'], 3),
 ('N2', 'Melhoria da qualidade e implementação de diretrizes: PDSA, lean, auditoria e retroalimentação, barreiras e ciência da implementação', 'Segurança do paciente e qualidade', 3, 'complementar', ['T114', 'T123'], 4),
 ('N3', 'Raciocínio clínico e erro diagnóstico na urgência: vieses cognitivos, tempo de decisão e checagem', 'Segurança do paciente e qualidade', 3, 'complementar', ['T084', 'T082'], 4),
 ('N4', 'Do tema ao projeto de pesquisa: pergunta, protocolo, CEP e Plataforma Brasil, LGPD, registro de dados e publicação', 'Medicina baseada em evidências — julgar e aplicar', 3, 'eletivo', ['T117', 'T118'], 3),
 ('N5', 'Pesquisa em educação médica: como avaliar o próprio curso (Kirkpatrick, desenho, instrumentos e ética)', 'Ensino, preceptoria e avaliação', 4, 'eletivo', ['T131', 'T127'], 3),
 ('N6', 'Organização do serviço de cirurgia de urgência (acute care surgery): escala, sala dedicada, fluxo do paciente e superlotação', 'Governança compartilhada e saúde do profissional', 3, 'complementar', ['T113', 'T143'], 4),
 ('N8', 'Hemorragia pós-operatória e reoperação não planejada: reconhecimento, imagem, embolização ou reoperação', 'Infecção e sepse cirúrgica', 3, 'complementar', ['T155', 'T104'], 4),
]

# lista final na ordem dos modulos (ordem de primeira aparicao), temas novos no fim do modulo
fica = [t for t in temas if t['c'] not in FUSOES]
for t in fica:
    if t['c'] in TITULOS: t['titulo'] = TITULOS[t['c']].replace("'", "''")
modulos = []
for t in fica:
    if t['modulo'] not in modulos: modulos.append(t['modulo'])
for n in NOVOS: assert n[2] in modulos, n[2]
final = []
for m in modulos:
    final += [t for t in fica if t['modulo'] == m]
    final += [dict(c=n[0], titulo=n[1], modulo=n[2], grau=n[3], papel=n[4], ordem='NULL', novo=True) for n in NOVOS if n[2] == m]
assert len(final) == 150, len(final)
MAPA = {}
for i, t in enumerate(final, 1):
    t['novo_codigo'] = f'T{i:03d}'; MAPA[t['c']] = t['novo_codigo']
assert MAPA['T001'] == 'T001' and MAPA['T002'] == 'T002'
def mapear(c):
    c = c.replace('-', '')
    c = FUSOES.get(c, FUSOES_ANTIGAS.get(c, c))
    return MAPA.get(c)

# tabela de correspondencia
with open(os.path.join(R, 'docs/renumeracao_temas_2026-11-19.csv'), 'w', encoding='utf-8', newline='') as f:
    w = csv.writer(f, delimiter=';'); w.writerow(['codigo_novo', 'codigo_antigo', 'titulo', 'modulo', 'papel', 'situacao'])
    for t in final:
        w.writerow([t['novo_codigo'], '' if t.get('novo') else t['c'], t['titulo'].replace("''", "'"), t['modulo'], t['papel'],
                    'novo' if t.get('novo') else ('escopo ampliado' if t['c'] in TITULOS else 'mantido')])
    for a, b in {**FUSOES_ANTIGAS, **FUSOES}.items():
        w.writerow(['', a, f'fundido em {b} (hoje {MAPA[b]})', '', '', 'fundido'])

# ---- 53 ----
ini = s53.index("('T-001',"); fim = s53.index(") v(codigo, titulo, modulo, grau, papel, ordem)")
linhas = [f"('T-{t['novo_codigo'][1:]}','{t['titulo']}','{t['modulo']}',{t['grau']},'{t['papel']}',{t['ordem']})" for t in final]
s53 = s53[:ini] + ',\n'.join(linhas) + '  ' + s53[fim:]
s53 = s53.replace('-- 18/11/2026, segunda revisao:', '-- 19/11/2026, renumeracao de 19/11/2026: 5 fusoes (T126, T125, T129, T132, T150), 8 temas novos e todos os\n--   codigos renumerados de T001 a T150 na ordem dos modulos (101_reestruturacao_temas_v1.0.sql faz a troca no banco;\n--   docs/renumeracao_temas_2026-11-19.csv tem a correspondencia). Total: 150 temas.\n-- 18/11/2026, segunda revisao:', 1)
gravar('53_temas_programa_v1.0.sql', s53)

# ---- 65: arvore ----
s65 = ler('65_arvore_temas_v1.0.sql')
ini = s65.index('INSERT INTO req VALUES\n') + len('INSERT INTO req VALUES\n')
fim = s65.index(';', ini)
pares = re.findall(r"\('(T\d{3})','([T\d ]+)'\)", s65[ini:fim])
arestas = {}
for f_, ms in pares:
    if f_ in FUSOES or f_ in FUSOES_ANTIGAS: continue   # o tema que saiu nao leva as suas maes
    nf = mapear(f_)
    if not nf: continue
    for m in ms.split():
        nm = mapear(m)
        if nm and nm != nf: arestas.setdefault(nf, []).append(nm) if nm not in arestas.get(nf, []) else None
for t in final:
    if t.get('novo'):
        n = [x for x in NOVOS if x[0] == t['c']][0]
        arestas[t['novo_codigo']] = [MAPA[m] for m in n[5]]
itens = [f"('{f_}','{' '.join(ms)}')" for f_, ms in sorted(arestas.items())]
bloco = '-- renumerada em 19/11/2026 (codigos novos, T001 a T150)\n' + ',\n'.join(', '.join(itens[i:i + 6]) for i in range(0, len(itens), 6)) + '\n'
s65 = s65[:ini] + bloco + s65[fim:]
gravar('65_arvore_temas_v1.0.sql', s65)

# ---- 73: relevancia por tema ----
s73 = ler('73_extras_v1.0.sql')
m = re.search(r"FROM \(VALUES (\('T-\d{3}',\d\)(?:,\s*\('T-\d{3}',\d\))*)\) v\(c, r\)", s73)
assert m, '73 mudou'
rel = {}
for c, r in re.findall(r"\('T-(\d{3})',(\d)\)", m.group(1)):
    nc = mapear('T' + c)
    if nc: rel[nc] = int(r)
for n in NOVOS: rel[MAPA[n[0]]] = n[6]
novo = ','.join(f"('T-{c[1:]}',{r})" for c, r in sorted(rel.items()))
s73 = s73[:m.start(1)] + novo + s73[m.end(1):]
gravar('73_extras_v1.0.sql', s73)

# ---- 92: calendario dos principais ----
s92 = ler('92_prazos_producao_v1.0.sql')
s92 = re.sub(r"'T-(\d{3})'", lambda x: f"'T-{mapear('T' + x.group(1))[1:]}'", s92)
gravar('92_prazos_producao_v1.0.sql', s92)

# ---- buscas e fila: troca o codigo no inicio das entradas ----
for p in ('docs/BUSCAS_PUBMED_150_temas.txt', 'docs/fila_producao_150.md'):
    s = ler(p)
    s = re.sub(r'(?m)^(T)(\d{3})\b', lambda x: (mapear('T' + x.group(2)) or ('T' + x.group(2) + ' [FUNDIDO]')), s)
    s = re.sub(r'\| T-(\d{3}) \|', lambda x: f"| {('T-' + mapear('T' + x.group(1))[1:]) if mapear('T' + x.group(1)) else 'T-' + x.group(1)} |", s)
    gravar(p, s)

# ---- 101: migracao no banco (roda ANTES do 53) ----
valores = ',\n'.join(f"  ('{t['c']}','{t['novo_codigo']}')" for t in final if not t.get('novo'))
fus = ','.join(f"('{a}','{b}')" for a, b in {**FUSOES_ANTIGAS, **FUSOES}.items())
gravar('101_reestruturacao_temas_v1.0.sql', f"""-- ============================================================
-- 101_reestruturacao_temas_v1.0.sql
-- OBJETIVO (decisao da coordenacao de 19/11/2026): 1) fundir os temas que sairam do programa (as 11 fusoes de 18/11 e
-- as 5 de 19/11: T126 em T121, T125 em T122, T129 em T130, T132 em T131, T150 em T134); 2) renumerar todos os codigos
-- de T001 a T150 na ordem dos modulos. Os temas novos entram depois, pelo SQL 53.
-- RODA ANTES DO 53. Roda uma vez so: depois de aplicada, a marca app.migracao_aplicada impede nova troca
-- (e o 100, que usa os codigos antigos, deixa de agir).
-- O tema_id nao muda: material, questoes, notas, presenca e calendario continuam ligados ao mesmo tema.
-- Correspondencia completa: docs/renumeracao_temas_2026-11-19.csv.
-- ============================================================
\\set ON_ERROR_STOP on
BEGIN;
CREATE TABLE IF NOT EXISTS app.migracao_aplicada (nome TEXT PRIMARY KEY, em TIMESTAMPTZ NOT NULL DEFAULT now());

DO $$
DECLARE r RECORD; v_old BIGINT; v_new BIGINT; n INT;
BEGIN
  IF EXISTS (SELECT 1 FROM app.migracao_aplicada WHERE nome = 'renumeracao_2026-11-19') THEN
    RAISE NOTICE 'renumeracao de 19/11/2026 ja aplicada'; RETURN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM app.tema) THEN
    INSERT INTO app.migracao_aplicada VALUES ('renumeracao_2026-11-19'); RETURN;   -- banco novo: o 53 ja cria com os codigos novos
  END IF;
  -- 1) fusoes (codigos antigos)
  FOR r IN SELECT * FROM (VALUES {fus}) v(velho, novo) LOOP
    SELECT tema_id INTO v_old FROM app.tema WHERE replace(codigo,'-','') = r.velho;
    SELECT tema_id INTO v_new FROM app.tema WHERE replace(codigo,'-','') = r.novo;
    IF v_old IS NULL OR v_new IS NULL THEN CONTINUE; END IF;
    SELECT (SELECT count(*) FROM conteudo.artefato WHERE tema_id = v_old) + (SELECT count(*) FROM app.item WHERE tema_id = v_old)
         + (SELECT count(*) FROM app.onda_instancia WHERE tema_id = v_old) + (SELECT count(*) FROM app.nota_teste WHERE tema_id = v_old)
         + (SELECT count(*) FROM app.presenca WHERE tema_id = v_old) + (SELECT count(*) FROM app.caso_teste WHERE tema_id = v_old) INTO n;
    IF n > 0 THEN RAISE EXCEPTION '% ja tem material, questoes, ondas ou presenca (% registros): a reestruturacao parou para a coordenacao decidir', r.velho, n; END IF;
    UPDATE conteudo.fonte f SET tema_id = v_new
     WHERE f.tema_id = v_old AND (f.sha256 IS NULL OR NOT EXISTS (SELECT 1 FROM conteudo.fonte g WHERE g.tema_id = v_new AND g.sha256 = f.sha256));
    DELETE FROM conteudo.fonte WHERE tema_id = v_old;
    INSERT INTO app.tema_interesse (pessoa_id, tema_id, criado_em, avisado_em)
      SELECT pessoa_id, v_new, criado_em, avisado_em FROM app.tema_interesse WHERE tema_id = v_old ON CONFLICT DO NOTHING;
    UPDATE conteudo.termo_variante SET tema_id = v_new WHERE tema_id = v_old;
    UPDATE maestro.execucao_motor SET tema_id = v_new WHERE tema_id = v_old;
    UPDATE maestro.job SET tema_id = v_new WHERE tema_id = v_old;
    DELETE FROM app.tema_requisito WHERE tema_id = v_old OR requisito_id = v_old;
    DELETE FROM app.tema WHERE tema_id = v_old;
    RAISE NOTICE '% fundido em %', r.velho, r.novo;
  END LOOP;
  -- 2) renumeracao em duas etapas (prefixo provisorio, para nao colidir com o codigo de outro tema)
  CREATE TEMP TABLE mapa (velho TEXT, novo TEXT) ON COMMIT DROP;
  INSERT INTO mapa VALUES
{valores};
  UPDATE app.tema t SET codigo = 'X' || m.novo FROM mapa m WHERE replace(t.codigo,'-','') = m.velho;
  UPDATE app.tema SET codigo = 'T-' || substr(codigo, 3) WHERE codigo LIKE 'XT%';
  INSERT INTO app.migracao_aplicada VALUES ('renumeracao_2026-11-19');
  RAISE NOTICE 'renumeracao de 19/11/2026 aplicada';
END $$;
SELECT count(*) AS temas FROM app.tema;
COMMIT;
\\echo 'reestruturacao dos temas (19/11/2026): pronto'
""")
print('ok: 150 temas;', sum(1 for t in final if t.get('novo')), 'novos;', sum(1 for t in final if not t.get('novo') and MAPA[t['c']] != t['c']), 'codigos mudaram')
