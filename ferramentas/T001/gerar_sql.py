# Gera 36_importar_T001_v2.sql (pecas) e 37_banco_questoes_v1.0.sql (questoes) a partir de conteudo/T001/v2.
import json,glob,os,sys
RAIZ=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
V=os.path.join(RAIZ,'conteudo/T001/v2')
tipos=sorted(os.path.basename(f)[5:-5] for f in glob.glob(V+'/T001_*.json') if 'banco_questoes' not in f)
todos=sorted(set(['sintese_evidencia','objetivos','item','gabarito','aula','caso','protocolo','checklist','resumo','mapa','flashcard','simulado','podcast_roteiro','slides','caso_semente']+tipos))
q=lambda s,tag: f"${tag}${s}${tag}$"
L=["-- 36_importar_T001_v2.sql : T001 no padrao do guia v0.1 (12/11/2026). Novas versoes em RASCUNHO; nada e apagado.",
"-- Pre-requisito: 32_revisao_v1.0.sql (tabela conteudo.afirmacao). Pode ser rodado mais de uma vez.",
"\\set ON_ERROR_STOP on","BEGIN;",
"ALTER TABLE conteudo.artefato DROP CONSTRAINT IF EXISTS artefato_tipo_check;",
"ALTER TABLE conteudo.artefato ADD CONSTRAINT artefato_tipo_check CHECK (tipo IN ("+", ".join(f"'{t}'" for t in todos)+"));",
"-- renomeia o antigo 'caso semente' para 'caso base' (se ja importado)",
"UPDATE conteudo.artefato SET tipo='caso_base', titulo=replace(titulo,'Caso semente','Caso base'), corpo=replace(replace(corpo,'Caso semente','Caso base'),'caso semente','caso base') WHERE tipo='caso_semente';"]
for t in tipos:
    o=json.load(open(f'{V}/T001_{t}.json')); c=o['corpo']; assert '$T1$' not in c
    L.append(f"""INSERT INTO conteudo.artefato (tema_id, tipo, versao, status, titulo, corpo, checklist_conforme)
SELECT t.tema_id, '{t}', COALESCE((SELECT MAX(versao) FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='{t}'),0)+1, 'rascunho', {q(o['titulo'],'T1')}, {q(c,'T1')}, false
  FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
   AND NOT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id=t.tema_id AND a.tipo='{t}' AND a.corpo={q(c,'T1')});""")
    for a in o['afirmacoes']:
        assert '$af$' not in a['texto']+a['trecho_literal']
        L.append(f"""INSERT INTO conteudo.afirmacao (artefato_id, codigo, texto, fonte_arquivo, trecho_literal)
SELECT a.artefato_id, '{a['id']}', $af${a['texto']}$af$, '{a['fonte_arquivo']}', $af${a['trecho_literal']}$af$
  FROM conteudo.artefato a JOIN app.tema t USING (tema_id)
 WHERE replace(t.codigo,'-','')='T001' AND a.tipo='{t}' AND a.versao=(SELECT max(versao) FROM conteudo.artefato x WHERE x.tema_id=a.tema_id AND x.tipo='{t}')
ON CONFLICT (artefato_id, codigo) DO NOTHING;""")
L+=["SELECT a.tipo, max(a.versao) AS versao FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' GROUP BY a.tipo ORDER BY 1;","COMMIT;"]
open(os.path.join(RAIZ,'36_importar_T001_v2.sql'),'w').write("\n".join(L)+"\n")

# ---- banco de questoes ----
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
import testes_a,testes_b,testes_c
CASOS={**testes_a.CASOS,**testes_b.CASOS,**testes_c.CASOS}
b=json.load(open(f'{V}/T001_banco_questoes.json'))
PER={'Graduação':'graduacao','R1':'R1','R2':'R2','R3':'R3','R+':'R+'}
CAT={'erro conceitual':'erro_conceitual','erro de conduta':'erro_conduta','erro de indicação':'erro_indicacao','erro técnico':'erro_tecnico','correta':None}
def qq(s): assert '$q$' not in s; return f"$q${s}$q$"
T="FROM app.tema t WHERE replace(t.codigo,'-','')='T001'"
L=["-- 37_banco_questoes_v1.0.sql : perfis (Graduacao a R+), 6 graus de dificuldade e carga do banco de questoes do T001.",
"-- Pode ser rodado mais de uma vez. Questao ja existente (mesmo codigo) e ATUALIZADA com o texto mais recente,",
"-- desde que ainda nao tenha respostas de alunos.",
"\\set ON_ERROR_STOP on",
"ALTER TYPE app.grau_enum ADD VALUE IF NOT EXISTS 'graduacao';","ALTER TYPE app.grau_enum ADD VALUE IF NOT EXISTS 'R6';","ALTER TYPE app.grau_enum ADD VALUE IF NOT EXISTS 'egresso';",
"BEGIN;",
"""CREATE OR REPLACE FUNCTION app.perfil_questoes(g app.grau_enum) RETURNS text LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE g::text WHEN 'graduacao' THEN 'graduacao' WHEN 'R1' THEN 'R1' WHEN 'R2' THEN 'R2' WHEN 'R3' THEN 'R3' ELSE 'R+' END $$;""",
"COMMENT ON FUNCTION app.perfil_questoes(app.grau_enum) IS 'Perfil de questoes: R4 a R6, egressos, preceptores e docentes recebem as do R+.';",
"ALTER TABLE app.item DROP CONSTRAINT IF EXISTS item_dificuldade_check;",
"ALTER TABLE app.item ADD CONSTRAINT item_dificuldade_check CHECK (dificuldade BETWEEN 1 AND 6);",
"ALTER TABLE app.item ADD COLUMN IF NOT EXISTS codigo TEXT, ADD COLUMN IF NOT EXISTS perfil TEXT, ADD COLUMN IF NOT EXISTS teste_num SMALLINT, ADD COLUMN IF NOT EXISTS fixa BOOLEAN NOT NULL DEFAULT false, ADD COLUMN IF NOT EXISTS taxa_esperada TEXT;",
"ALTER TABLE app.item DROP CONSTRAINT IF EXISTS item_perfil_check;",
"ALTER TABLE app.item ADD CONSTRAINT item_perfil_check CHECK (perfil IS NULL OR perfil IN ('graduacao','R1','R2','R3','R+'));",
"ALTER TABLE app.item DROP CONSTRAINT IF EXISTS item_teste_check;",
"ALTER TABLE app.item ADD CONSTRAINT item_teste_check CHECK (teste_num IS NULL OR teste_num BETWEEN 1 AND 6);",
"CREATE UNIQUE INDEX IF NOT EXISTS uq_item_tema_codigo ON app.item (tema_id, codigo) WHERE codigo IS NOT NULL;",
"ALTER TABLE app.alternativa ADD COLUMN IF NOT EXISTS justificativa TEXT;",
"""CREATE TABLE IF NOT EXISTS app.caso_teste (
  caso_id BIGSERIAL PRIMARY KEY,
  tema_id BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  teste_num SMALLINT NOT NULL CHECK (teste_num BETWEEN 1 AND 6),
  titulo TEXT NOT NULL,
  texto TEXT NOT NULL,
  UNIQUE (tema_id, teste_num));""",
"GRANT SELECT ON app.caso_teste TO api_rw;"]
for n,(tit,txt) in sorted(CASOS.items()):
    L.append(f"INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, {n}, {qq(tit)}, {qq(txt)} {T} ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;")
vistos=set()
for it in b:
    cod='T001-FIXA' if it['fixa'] else it['id']
    if cod in vistos: continue
    vistos.add(cod)
    perfil='NULL' if it['fixa'] else f"'{PER[it['perfil']]}'"
    teste='NULL' if it['fixa'] else str(it['teste'])
    grau=2 if it['fixa'] else it['grau']
    taxa='por perfil' if it['fixa'] else it['taxa_esperada']
    anc=', '.join(it['ancoras'])
    vals=",\n  ".join(f"({i+1}, {qq(a)}, {'true' if c=='correta' else 'false'}, {('NULL' if CAT[c] is None else repr(CAT[c]))}, {qq(j)})" for i,(a,c,j) in enumerate(zip(it['alternativas'],it['categorias'],it['justificativas'])))
    sem_resp=f"NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='{cod}')"
    # atualiza questao existente sem respostas: apaga alternativas e regrava
    L.append(f"""UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='{cod}' AND {sem_resp}
   AND (i.enunciado IS DISTINCT FROM {qq(it['enunciado'])} OR i.ancora IS DISTINCT FROM '{anc}' OR i.dificuldade <> {grau}
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM {qq('#'.join(a+'|'+j for a,j in zip(it['alternativas'],it['justificativas'])))});
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='{cod}' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado={qq(it['enunciado'])}, dificuldade={grau}, ancora='{anc}', taxa_esperada='{taxa}' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='{cod}' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, {qq(it['enunciado'])}, {grau}, '{anc}', '{cod}', {perfil}, {teste}, {'true' if it['fixa'] else 'false'}, '{taxa}' {T}
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='{cod}')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='{cod}' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  {vals}) v(ordem, texto, correta, cat, just);""")
L+=["UPDATE app.item i SET gabarito_alternativa_id = a.alternativa_id FROM app.alternativa a WHERE a.item_id=i.item_id AND a.eh_correta AND i.gabarito_alternativa_id IS NULL AND i.codigo LIKE 'T%';",
"SELECT coalesce(i.perfil,'fixa') AS perfil, count(*) AS questoes, count(*) FILTER (WHERE gabarito_alternativa_id IS NOT NULL) AS com_gabarito, min(i.dificuldade) AS grau_min, max(i.dificuldade) AS grau_max FROM app.item i JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' AND i.codigo IS NOT NULL GROUP BY 1 ORDER BY 1;",
"COMMIT;"]
open(os.path.join(RAIZ,'37_banco_questoes_v1.0.sql'),'w').write("\n".join(L)+"\n")
print(len(tipos),'pecas;',len(vistos),'questoes')
