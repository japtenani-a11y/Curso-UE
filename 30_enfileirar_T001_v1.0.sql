-- 30_enfileirar_T001_v1.0.sql
-- Enfileira os 12 artefatos do T001 para o executor. Pre-requisitos: 28 (texto_integral), carga de fontes do T001
-- (29_carga_fontes com fontes/catalogo_T001.csv) e executor rodando com ANTHROPIC_API_KEY / ANTHROPIC_MODEL.
-- Cada job gera um 'rascunho' so se o gate de evidencia aprovar; nada e publicado sem revisao humana.
-- Uso: psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 30_enfileirar_T001_v1.0.sql
BEGIN;
WITH t AS (SELECT tema_id FROM app.tema WHERE replace(codigo,'-','') = 'T001'),
d(tipo, titulo, fase, skill, prio) AS (VALUES
 ('sintese_evidencia','Sintese de evidencia','evidencia','SK-01',1),
 ('objetivos','Objetivos de aprendizagem','objetivos','SK-04',2),
 ('item','Item de avaliacao','instrumento','SK-05',3),
 ('gabarito','Gabarito comentado','instrumento','SK-05',3),
 ('simulado','Simulado','instrumento','SK-05',3),
 ('aula','Aula expositiva','didatico','SK-08',3),
 ('caso','Caso clinico','didatico','SK-08',3),
 ('resumo','Resumo executivo','didatico','SK-08',3),
 ('mapa','Mapa conceitual','didatico','SK-08',3),
 ('flashcard','Flashcards','didatico','SK-08',3),
 ('protocolo','Protocolo assistencial','protocolo','SK-13',4),
 ('checklist','Checklist de procedimento','protocolo','SK-13',4))
INSERT INTO maestro.job (tema_id, fase, skill_codigo, estado, prioridade, payload)
SELECT t.tema_id, d.fase, d.skill, 'pendente', d.prio,
       jsonb_build_object('tipo', d.tipo, 'titulo', d.titulo,
         'termos', 'ATLS advanced trauma life support primary survey xABCDE exsanguinating hemorrhage initial assessment trauma team')
FROM t, d
WHERE NOT EXISTS (SELECT 1 FROM maestro.job j WHERE j.tema_id = t.tema_id AND j.payload->>'tipo' = d.tipo AND j.estado IN ('pendente','executando'));
SELECT 'jobs T001 enfileirados: ' || count(*) FROM maestro.job j JOIN app.tema a USING (tema_id) WHERE replace(a.codigo,'-','')='T001' AND j.estado='pendente';
COMMIT;
