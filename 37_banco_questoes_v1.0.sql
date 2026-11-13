-- 37_banco_questoes_v1.0.sql : perfis (Graduacao a R+), 6 graus de dificuldade e carga do banco de questoes do T001.
-- Pode ser rodado mais de uma vez. Questao ja existente (mesmo codigo) e ATUALIZADA com o texto mais recente,
-- desde que ainda nao tenha respostas de alunos.
\set ON_ERROR_STOP on
ALTER TYPE app.grau_enum ADD VALUE IF NOT EXISTS 'graduacao';
ALTER TYPE app.grau_enum ADD VALUE IF NOT EXISTS 'R6';
ALTER TYPE app.grau_enum ADD VALUE IF NOT EXISTS 'egresso';
BEGIN;
CREATE OR REPLACE FUNCTION app.perfil_questoes(g app.grau_enum) RETURNS text LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE g::text WHEN 'graduacao' THEN 'graduacao' WHEN 'R1' THEN 'R1' WHEN 'R2' THEN 'R2' WHEN 'R3' THEN 'R3' ELSE 'R+' END $$;
COMMENT ON FUNCTION app.perfil_questoes(app.grau_enum) IS 'Perfil de questoes: R4 a R6, egressos, preceptores e docentes recebem as do R+.';
ALTER TABLE app.item DROP CONSTRAINT IF EXISTS item_dificuldade_check;
ALTER TABLE app.item ADD CONSTRAINT item_dificuldade_check CHECK (dificuldade BETWEEN 1 AND 6);
ALTER TABLE app.item ADD COLUMN IF NOT EXISTS codigo TEXT, ADD COLUMN IF NOT EXISTS perfil TEXT, ADD COLUMN IF NOT EXISTS teste_num SMALLINT, ADD COLUMN IF NOT EXISTS fixa BOOLEAN NOT NULL DEFAULT false, ADD COLUMN IF NOT EXISTS taxa_esperada TEXT;
ALTER TABLE app.item DROP CONSTRAINT IF EXISTS item_perfil_check;
ALTER TABLE app.item ADD CONSTRAINT item_perfil_check CHECK (perfil IS NULL OR perfil IN ('graduacao','R1','R2','R3','R+'));
ALTER TABLE app.item DROP CONSTRAINT IF EXISTS item_teste_check;
ALTER TABLE app.item ADD CONSTRAINT item_teste_check CHECK (teste_num IS NULL OR teste_num BETWEEN 1 AND 6);
CREATE UNIQUE INDEX IF NOT EXISTS uq_item_tema_codigo ON app.item (tema_id, codigo) WHERE codigo IS NOT NULL;
ALTER TABLE app.alternativa ADD COLUMN IF NOT EXISTS justificativa TEXT;
CREATE TABLE IF NOT EXISTS app.caso_teste (
  caso_id BIGSERIAL PRIMARY KEY,
  tema_id BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  teste_num SMALLINT NOT NULL CHECK (teste_num BETWEEN 1 AND 6),
  titulo TEXT NOT NULL,
  texto TEXT NOT NULL,
  UNIQUE (tema_id, teste_num));
GRANT SELECT ON app.caso_teste TO api_rw;
INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, 1, $q$Caso 1$q$, $q$Mulher de 45 anos, motorista, colisão frontal. Chega acordada e responde às perguntas com voz normal. Há fratura exposta da perna direita com sangramento ativo em jato, que encharca o lençol. FC 124, pele fria e pálida. A equipe ainda não fez nenhuma intervenção.$q$ FROM app.tema t WHERE replace(t.codigo,'-','')='T001' ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;
INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, 2, $q$Caso 2$q$, $q$Homem de 22 anos, ferido por faca no hemitórax esquerdo. Chega falando, ansioso, com respiração rápida. SpO2 89% em ar ambiente, FC 112, o aparelho automático marca PA 104/70. O eFAST não mostra sinais de pneumotórax. A equipe do SAMU quer contar o caso enquanto o paciente é passado para a maca.$q$ FROM app.tema t WHERE replace(t.codigo,'-','')='T001' ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;
INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, 3, $q$Caso 3$q$, $q$Homem de 72 anos, caiu de uma escada de 3 metros. Chega com Glasgow 7, ronco, hálito alcoólico. No caminho estava agitado. FC 118, pele fria, temperatura 35,1 °C. O aparelho automático marca PA 132/84.$q$ FROM app.tema t WHERE replace(t.codigo,'-','')='T001' ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;
INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, 4, $q$Caso 4$q$, $q$Homem de 30 anos, motociclista, colisão contra poste. Chega pálido e sonolento. PA 78/50 medida manualmente, FC 136. Dor à palpação da bacia, sem sangramento externo. Duas tentativas de acesso venoso falharam. O ultrassom à beira-leito está disponível.$q$ FROM app.tema t WHERE replace(t.codigo,'-','')='T001' ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;
INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, 5, $q$Caso 5$q$, $q$Mulher de 41 anos, atropelada. Foi avaliada na sala de trauma, com avaliações primária e secundária sem alterações importantes, e fez TC de corpo inteiro, sem lesões. Foi internada para observação. No dia seguinte, refere dor no pé esquerdo e no ombro direito. À tarde, a PA cai para 88/56.$q$ FROM app.tema t WHERE replace(t.codigo,'-','')='T001' ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;
INSERT INTO app.caso_teste (tema_id, teste_num, titulo, texto) SELECT t.tema_id, 6, $q$Caso 6$q$, $q$Sábado à noite. O SAMU avisa que dois pacientes de um mesmo acidente chegarão em 10 minutos: um motorista consciente com sangramento em antebraço e um passageiro inconsciente. Na sala estão um R1, um R2, um R3, dois enfermeiros e o cirurgião assistente.$q$ FROM app.tema t WHERE replace(t.codigo,'-','')='T001' ON CONFLICT (tema_id, teste_num) DO UPDATE SET titulo=EXCLUDED.titulo, texto=EXCLUDED.texto;
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T001-FIXA' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T001-FIXA')
   AND (i.enunciado IS DISTINCT FROM $q$Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?$q$ OR i.ancora IS DISTINCT FROM 'D2, D3, D11' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Em todo paciente com fratura de membro|Fratura sem sangramento grave não muda a ordem ABCDE.#Na hemorragia externa ou compressível com risco de vida e no paciente em extremis|Correta: nesses casos a circulação vem antes da via aérea (CAB, CABDE).#Somente quando o Glasgow é menor ou igual a 8|Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.#Sempre que houver trauma penetrante, independentemente do sangramento|O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.#Apenas depois de obtida a radiografia de tórax|A radiografia é adjunta; a prioridade não espera exame de imagem.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T001-FIXA' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?$q$, dificuldade=2, ancora='D2, D3, D11', taxa_esperada='por perfil' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T001-FIXA' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Na avaliação inicial do traumatizado, em qual situação a avaliação e o tratamento da circulação vêm antes da via aérea?$q$, 2, 'D2, D3, D11', 'T001-FIXA', NULL, NULL, true, 'por perfil' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T001-FIXA')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T001-FIXA' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Em todo paciente com fratura de membro$q$, false, 'erro_conceitual', $q$Fratura sem sangramento grave não muda a ordem ABCDE.$q$),
  (2, $q$Na hemorragia externa ou compressível com risco de vida e no paciente em extremis$q$, true, NULL, $q$Correta: nesses casos a circulação vem antes da via aérea (CAB, CABDE).$q$),
  (3, $q$Somente quando o Glasgow é menor ou igual a 8$q$, false, 'erro_indicacao', $q$Glasgow ≤8 indica via aérea definitiva; não inverte a ordem para a circulação.$q$),
  (4, $q$Sempre que houver trauma penetrante, independentemente do sangramento$q$, false, 'erro_conduta', $q$O mecanismo penetrante não inverte a ordem; o que inverte é a hemorragia com risco de vida ou o extremis.$q$),
  (5, $q$Apenas depois de obtida a radiografia de tórax$q$, false, 'erro_tecnico', $q$A radiografia é adjunta; a prioridade não espera exame de imagem.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, qual é a primeira medida?$q$ OR i.ancora IS DISTINCT FROM 'D2, D6, D10' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Pedir radiografia de tórax|Exame de imagem não vem antes de controlar um sangramento que mata em minutos.#Comprimir diretamente o ponto que sangra|Correta: hemorragia externa com risco de vida vem primeiro, começando pela compressão direta.#Levar para a tomografia|Transportar sangrando para a tomografia é perigoso e atrasa o tratamento.#Colher a história AMPLA|A história faz parte da avaliação secundária, depois da primária.#Intubar a paciente|Ela fala com voz normal: a via aérea está pérvia e intubar agora atrasa o controle do sangramento.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, qual é a primeira medida?$q$, dificuldade=1, ancora='D2, D6, D10', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, qual é a primeira medida?$q$, 1, 'D2, D6, D10', 'T1-Graduação-1', 'graduacao', 1, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-Graduação-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Pedir radiografia de tórax$q$, false, 'erro_tecnico', $q$Exame de imagem não vem antes de controlar um sangramento que mata em minutos.$q$),
  (2, $q$Comprimir diretamente o ponto que sangra$q$, true, NULL, $q$Correta: hemorragia externa com risco de vida vem primeiro, começando pela compressão direta.$q$),
  (3, $q$Levar para a tomografia$q$, false, 'erro_conduta', $q$Transportar sangrando para a tomografia é perigoso e atrasa o tratamento.$q$),
  (4, $q$Colher a história AMPLA$q$, false, 'erro_conceitual', $q$A história faz parte da avaliação secundária, depois da primária.$q$),
  (5, $q$Intubar a paciente$q$, false, 'erro_indicacao', $q$Ela fala com voz normal: a via aérea está pérvia e intubar agora atrasa o controle do sangramento.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-2')
   AND (i.enunciado IS DISTINCT FROM $q$A paciente do caso 1 responde às perguntas com voz normal. O que isso indica?$q$ OR i.ancora IS DISTINCT FROM 'D10, D11' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Que a coluna cervical está lesada|A fala não informa sobre a coluna.#Que ela precisa de via aérea definitiva|Via aérea definitiva é indicada por Glasgow ≤8 ou obstrução, não por fala normal.#Que o Glasgow é menor que 8|Quem responde às perguntas não tem Glasgow tão baixo.#Que não há choque|Falar não exclui choque: FC 124 e pele fria sugerem o contrário.#Que a via aérea está pérvia|Correta: quem fala com voz normal não tem obstrução de via aérea.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$A paciente do caso 1 responde às perguntas com voz normal. O que isso indica?$q$, dificuldade=1, ancora='D10, D11', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$A paciente do caso 1 responde às perguntas com voz normal. O que isso indica?$q$, 1, 'D10, D11', 'T1-Graduação-2', 'graduacao', 1, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-Graduação-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Que a coluna cervical está lesada$q$, false, 'erro_tecnico', $q$A fala não informa sobre a coluna.$q$),
  (2, $q$Que ela precisa de via aérea definitiva$q$, false, 'erro_indicacao', $q$Via aérea definitiva é indicada por Glasgow ≤8 ou obstrução, não por fala normal.$q$),
  (3, $q$Que o Glasgow é menor que 8$q$, false, 'erro_conceitual', $q$Quem responde às perguntas não tem Glasgow tão baixo.$q$),
  (4, $q$Que não há choque$q$, false, 'erro_conduta', $q$Falar não exclui choque: FC 124 e pele fria sugerem o contrário.$q$),
  (5, $q$Que a via aérea está pérvia$q$, true, NULL, $q$Correta: quem fala com voz normal não tem obstrução de via aérea.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-3')
   AND (i.enunciado IS DISTINCT FROM $q$Por que, no caso 1, a circulação é tratada antes da via aérea?$q$ OR i.ancora IS DISTINCT FROM 'D2' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Porque há hemorragia externa com risco de vida|Correta: hemorragia externa com risco de vida inverte a ordem (CAB).#Porque a fratura é exposta|O que muda a ordem é o sangramento grave, não o tipo de fratura.#Porque ela tem mais de 40 anos|A idade não muda a ordem da avaliação.#Porque a FC é o primeiro sinal vital medido|A ordem de medida dos sinais vitais não define a prioridade.#Porque a via aérea nunca é prioridade no trauma|A via aérea é prioridade na maioria dos casos; a inversão é a exceção.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Por que, no caso 1, a circulação é tratada antes da via aérea?$q$, dificuldade=1, ancora='D2', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Por que, no caso 1, a circulação é tratada antes da via aérea?$q$, 1, 'D2', 'T1-Graduação-3', 'graduacao', 1, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-Graduação-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Porque há hemorragia externa com risco de vida$q$, true, NULL, $q$Correta: hemorragia externa com risco de vida inverte a ordem (CAB).$q$),
  (2, $q$Porque a fratura é exposta$q$, false, 'erro_indicacao', $q$O que muda a ordem é o sangramento grave, não o tipo de fratura.$q$),
  (3, $q$Porque ela tem mais de 40 anos$q$, false, 'erro_conceitual', $q$A idade não muda a ordem da avaliação.$q$),
  (4, $q$Porque a FC é o primeiro sinal vital medido$q$, false, 'erro_tecnico', $q$A ordem de medida dos sinais vitais não define a prioridade.$q$),
  (5, $q$Porque a via aérea nunca é prioridade no trauma$q$, false, 'erro_conduta', $q$A via aérea é prioridade na maioria dos casos; a inversão é a exceção.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-4')
   AND (i.enunciado IS DISTINCT FROM $q$Controlado o sangramento e terminado o exame com a paciente despida, o que deve ser feito?$q$ OR i.ancora IS DISTINCT FROM 'D19, A36' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Dar banho com água fria para limpar|Água fria piora a hipotermia.#Aquecer só se a temperatura cair abaixo de 32 °C|Esperar a hipotermia grave contraria a prevenção, que é a prioridade.#Mantê-la descoberta para reexaminar|Deixar o paciente descoberto favorece hipotermia.#Aquecê-la com mantas, ar forçado e fluidos aquecidos|Correta: terminado o exame, manter o paciente aquecido é prioridade.#Esperar a TC para decidir|Aquecer não depende de exame de imagem.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Controlado o sangramento e terminado o exame com a paciente despida, o que deve ser feito?$q$, dificuldade=2, ancora='D19, A36', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Controlado o sangramento e terminado o exame com a paciente despida, o que deve ser feito?$q$, 2, 'D19, A36', 'T1-Graduação-4', 'graduacao', 1, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-Graduação-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-Graduação-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Dar banho com água fria para limpar$q$, false, 'erro_tecnico', $q$Água fria piora a hipotermia.$q$),
  (2, $q$Aquecer só se a temperatura cair abaixo de 32 °C$q$, false, 'erro_conceitual', $q$Esperar a hipotermia grave contraria a prevenção, que é a prioridade.$q$),
  (3, $q$Mantê-la descoberta para reexaminar$q$, false, 'erro_conduta', $q$Deixar o paciente descoberto favorece hipotermia.$q$),
  (4, $q$Aquecê-la com mantas, ar forçado e fluidos aquecidos$q$, true, NULL, $q$Correta: terminado o exame, manter o paciente aquecido é prioridade.$q$),
  (5, $q$Esperar a TC para decidir$q$, false, 'erro_indicacao', $q$Aquecer não depende de exame de imagem.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, a compressão direta não controla o sangramento da perna. Qual é a próxima medida?$q$ OR i.ancora IS DISTINCT FROM 'D7, D8, D2' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Pinçar às cegas dentro da ferida|Pinçar às cegas pode lesar nervos e piorar o sangramento.#Elevar o membro e observar por 10 minutos|Observar sangramento ativo não controlado é perder tempo.#Aplicar torniquete proximal à lesão|Correta: no trauma de membro, o torniquete pode salvar a vida.#Intubar antes de qualquer outra coisa|A via aérea está pérvia; intubar atrasa o controle do sangramento.#Pedir angiotomografia antes de agir|Imagem não precede o controle de hemorragia com risco de vida.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, a compressão direta não controla o sangramento da perna. Qual é a próxima medida?$q$, dificuldade=1, ancora='D7, D8, D2', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, a compressão direta não controla o sangramento da perna. Qual é a próxima medida?$q$, 1, 'D7, D8, D2', 'T1-R1-1', 'R1', 1, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R1-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Pinçar às cegas dentro da ferida$q$, false, 'erro_tecnico', $q$Pinçar às cegas pode lesar nervos e piorar o sangramento.$q$),
  (2, $q$Elevar o membro e observar por 10 minutos$q$, false, 'erro_conduta', $q$Observar sangramento ativo não controlado é perder tempo.$q$),
  (3, $q$Aplicar torniquete proximal à lesão$q$, true, NULL, $q$Correta: no trauma de membro, o torniquete pode salvar a vida.$q$),
  (4, $q$Intubar antes de qualquer outra coisa$q$, false, 'erro_indicacao', $q$A via aérea está pérvia; intubar atrasa o controle do sangramento.$q$),
  (5, $q$Pedir angiotomografia antes de agir$q$, false, 'erro_conceitual', $q$Imagem não precede o controle de hemorragia com risco de vida.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, o aparelho automático marca PA 120/80. Como interpretar?$q$ OR i.ancora IS DISTINCT FROM 'D14, D17' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A paciente não está em choque|FC 124 e pele fria sugerem choque apesar do número.#A pressão normal libera a paciente para a TC sem reavaliação|Pressão isolada não dispensa a reavaliação.#Deve-se suspender a reposição|Suspender a reposição com base num número possivelmente errado é erro de conduta.#A FC alta é só dor|Atribuir a taquicardia à dor sem excluir sangramento é perigoso.#O aparelho automático pode errar no choque; confirmar com medida manual e com a clínica|Correta: o aparelho automático pode errar no choque.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, o aparelho automático marca PA 120/80. Como interpretar?$q$, dificuldade=2, ancora='D14, D17', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, o aparelho automático marca PA 120/80. Como interpretar?$q$, 2, 'D14, D17', 'T1-R1-2', 'R1', 1, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R1-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A paciente não está em choque$q$, false, 'erro_conceitual', $q$FC 124 e pele fria sugerem choque apesar do número.$q$),
  (2, $q$A pressão normal libera a paciente para a TC sem reavaliação$q$, false, 'erro_tecnico', $q$Pressão isolada não dispensa a reavaliação.$q$),
  (3, $q$Deve-se suspender a reposição$q$, false, 'erro_conduta', $q$Suspender a reposição com base num número possivelmente errado é erro de conduta.$q$),
  (4, $q$A FC alta é só dor$q$, false, 'erro_indicacao', $q$Atribuir a taquicardia à dor sem excluir sangramento é perigoso.$q$),
  (5, $q$O aparelho automático pode errar no choque; confirmar com medida manual e com a clínica$q$, true, NULL, $q$Correta: o aparelho automático pode errar no choque.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, a equipe não consegue acesso venoso em duas tentativas. Qual a melhor alternativa?$q$ OR i.ancora IS DISTINCT FROM 'D15, D28' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Continuar tentando veia periférica por 15 minutos|Insistir prolongadamente atrasa a ressuscitação.#Acesso intraósseo|Correta: sem acesso venoso imediato, considerar o intraósseo.#Puncionar a artéria femoral para infundir|Infusão arterial não é via de reposição.#Adiar a reposição até chegar à TC|Adiar a reposição no choque é erro de conduta.#Dar líquidos por via oral|Via oral não serve para ressuscitação no choque.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, a equipe não consegue acesso venoso em duas tentativas. Qual a melhor alternativa?$q$, dificuldade=2, ancora='D15, D28', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, a equipe não consegue acesso venoso em duas tentativas. Qual a melhor alternativa?$q$, 2, 'D15, D28', 'T1-R1-3', 'R1', 1, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R1-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Continuar tentando veia periférica por 15 minutos$q$, false, 'erro_indicacao', $q$Insistir prolongadamente atrasa a ressuscitação.$q$),
  (2, $q$Acesso intraósseo$q$, true, NULL, $q$Correta: sem acesso venoso imediato, considerar o intraósseo.$q$),
  (3, $q$Puncionar a artéria femoral para infundir$q$, false, 'erro_tecnico', $q$Infusão arterial não é via de reposição.$q$),
  (4, $q$Adiar a reposição até chegar à TC$q$, false, 'erro_conduta', $q$Adiar a reposição no choque é erro de conduta.$q$),
  (5, $q$Dar líquidos por via oral$q$, false, 'erro_conceitual', $q$Via oral não serve para ressuscitação no choque.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-4')
   AND (i.enunciado IS DISTINCT FROM $q$Ao despir a paciente do caso 1, o que justifica remover toda a roupa?$q$ OR i.ancora IS DISTINCT FROM 'D18, D19' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Permitir o exame completo em 360 graus, para não deixar lesões passarem|Correta: a exposição completa permite o exame em 360 graus.#Facilitar o uso da cinta pélvica em todos os casos|Cinta pélvica é indicada pelo risco, não justifica despir.#Só é necessário no trauma penetrante|A exposição vale para todo trauma, não só o penetrante.#Só facilitar a limpeza|Limpeza não é o objetivo da exposição.#Evitar a hipotermia|Despir favorece a perda de calor; por isso se aquece depois.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Ao despir a paciente do caso 1, o que justifica remover toda a roupa?$q$, dificuldade=3, ancora='D18, D19', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R1-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Ao despir a paciente do caso 1, o que justifica remover toda a roupa?$q$, 3, 'D18, D19', 'T1-R1-4', 'R1', 1, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R1-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R1-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Permitir o exame completo em 360 graus, para não deixar lesões passarem$q$, true, NULL, $q$Correta: a exposição completa permite o exame em 360 graus.$q$),
  (2, $q$Facilitar o uso da cinta pélvica em todos os casos$q$, false, 'erro_tecnico', $q$Cinta pélvica é indicada pelo risco, não justifica despir.$q$),
  (3, $q$Só é necessário no trauma penetrante$q$, false, 'erro_conduta', $q$A exposição vale para todo trauma, não só o penetrante.$q$),
  (4, $q$Só facilitar a limpeza$q$, false, 'erro_conceitual', $q$Limpeza não é o objetivo da exposição.$q$),
  (5, $q$Evitar a hipotermia$q$, false, 'erro_indicacao', $q$Despir favorece a perda de calor; por isso se aquece depois.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, um torniquete é aplicado e controla o sangramento. O que a evidência mostra sobre o torniquete pré-hospitalar?$q$ OR i.ancora IS DISTINCT FROM 'A23, A24, D7' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não altera a taxa de amputação|A amputação inicial foi mais frequente no grupo torniquete.#Redução de mortalidade não significativa e mais amputação inicial|Correta: RR 0,70 não significativo para mortalidade e RR 2,07 para amputação inicial.#Reduz a mortalidade de forma significativa|A redução (RR 0,70) não foi estatisticamente significativa.#Só deve ser usado no membro superior|Não há essa restrição; o torniquete serve para o trauma de membro.#Aumenta a mortalidade|Não houve aumento de mortalidade.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, um torniquete é aplicado e controla o sangramento. O que a evidência mostra sobre o torniquete pré-hospitalar?$q$, dificuldade=2, ancora='A23, A24, D7', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, um torniquete é aplicado e controla o sangramento. O que a evidência mostra sobre o torniquete pré-hospitalar?$q$, 2, 'A23, A24, D7', 'T1-R2-1', 'R2', 1, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R2-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não altera a taxa de amputação$q$, false, 'erro_indicacao', $q$A amputação inicial foi mais frequente no grupo torniquete.$q$),
  (2, $q$Redução de mortalidade não significativa e mais amputação inicial$q$, true, NULL, $q$Correta: RR 0,70 não significativo para mortalidade e RR 2,07 para amputação inicial.$q$),
  (3, $q$Reduz a mortalidade de forma significativa$q$, false, 'erro_conceitual', $q$A redução (RR 0,70) não foi estatisticamente significativa.$q$),
  (4, $q$Só deve ser usado no membro superior$q$, false, 'erro_tecnico', $q$Não há essa restrição; o torniquete serve para o trauma de membro.$q$),
  (5, $q$Aumenta a mortalidade$q$, false, 'erro_conduta', $q$Não houve aumento de mortalidade.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, FC 124 e pele fria, mas a paciente está lúcida e responde bem. O que considerar?$q$ OR i.ancora IS DISTINCT FROM 'A32, A33' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A tabela de classes de choque é suficiente para decidir|Os parâmetros clássicos tiveram viés e não há consenso sobre estabilidade.#Lucidez exclui choque grave|Pacientes jovens podem compensar com lucidez preservada.#Não decidir por um parâmetro isolado; a classificação clássica tem limitações|Correta: a classe de choque pelos parâmetros tradicionais foi superestimada e a definição de estabilidade é heterogênea.#Sedar para medir melhor a FC|Sedar sem indicação piora a avaliação.#Aguardar a hipotensão para tratar|Esperar a hipotensão atrasa o tratamento.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, FC 124 e pele fria, mas a paciente está lúcida e responde bem. O que considerar?$q$, dificuldade=3, ancora='A32, A33', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, FC 124 e pele fria, mas a paciente está lúcida e responde bem. O que considerar?$q$, 3, 'A32, A33', 'T1-R2-2', 'R2', 1, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R2-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A tabela de classes de choque é suficiente para decidir$q$, false, 'erro_indicacao', $q$Os parâmetros clássicos tiveram viés e não há consenso sobre estabilidade.$q$),
  (2, $q$Lucidez exclui choque grave$q$, false, 'erro_conceitual', $q$Pacientes jovens podem compensar com lucidez preservada.$q$),
  (3, $q$Não decidir por um parâmetro isolado; a classificação clássica tem limitações$q$, true, NULL, $q$Correta: a classe de choque pelos parâmetros tradicionais foi superestimada e a definição de estabilidade é heterogênea.$q$),
  (4, $q$Sedar para medir melhor a FC$q$, false, 'erro_tecnico', $q$Sedar sem indicação piora a avaliação.$q$),
  (5, $q$Aguardar a hipotensão para tratar$q$, false, 'erro_conduta', $q$Esperar a hipotensão atrasa o tratamento.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, há suspeita de lesão de bacia associada, com sangramento. Qual a conduta inicial?$q$ OR i.ancora IS DISTINCT FROM 'D9' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Fazer laparotomia exploradora antes de qualquer imagem|Laparotomia não é o tratamento do sangramento pélvico.#Retirar a cinta para radiografar|Retirar a cinta para imagem expõe a novo sangramento.#Esperar a TC para confirmar|Esperar a imagem atrasa o controle do sangramento.#Colocar a cinta pélvica imediatamente|Correta: nos pacientes de alto risco, a cinta pélvica deve ser colocada imediatamente.#Testar a estabilidade da bacia várias vezes|Manipular a bacia não controla o sangramento e atrasa a cinta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, há suspeita de lesão de bacia associada, com sangramento. Qual a conduta inicial?$q$, dificuldade=3, ancora='D9', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, há suspeita de lesão de bacia associada, com sangramento. Qual a conduta inicial?$q$, 3, 'D9', 'T1-R2-3', 'R2', 1, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R2-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Fazer laparotomia exploradora antes de qualquer imagem$q$, false, 'erro_conduta', $q$Laparotomia não é o tratamento do sangramento pélvico.$q$),
  (2, $q$Retirar a cinta para radiografar$q$, false, 'erro_conceitual', $q$Retirar a cinta para imagem expõe a novo sangramento.$q$),
  (3, $q$Esperar a TC para confirmar$q$, false, 'erro_indicacao', $q$Esperar a imagem atrasa o controle do sangramento.$q$),
  (4, $q$Colocar a cinta pélvica imediatamente$q$, true, NULL, $q$Correta: nos pacientes de alto risco, a cinta pélvica deve ser colocada imediatamente.$q$),
  (5, $q$Testar a estabilidade da bacia várias vezes$q$, false, 'erro_tecnico', $q$Manipular a bacia não controla o sangramento e atrasa a cinta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, um colega diz que, com a perna controlada, a 'avaliação primária acabou'. O que está errado?$q$ OR i.ancora IS DISTINCT FROM 'D1, D5' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A primária segue por todas as letras, reavaliando após cada intervenção|Correta: a avaliação inicial identifica e trata todas as lesões que ameaçam a vida, seguindo as demais letras.#Nada; o sangramento era o único problema|Controlar um problema não exclui outros.#A primária termina com a radiografia de tórax|A radiografia é adjunta, não o fim da avaliação.#Basta repetir a FC|A FC sozinha não completa a avaliação.#É hora de dar alta da sala|Ainda faltam via aérea, respiração, neurológico e exposição.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, um colega diz que, com a perna controlada, a 'avaliação primária acabou'. O que está errado?$q$, dificuldade=4, ancora='D1, D5', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R2-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, um colega diz que, com a perna controlada, a 'avaliação primária acabou'. O que está errado?$q$, 4, 'D1, D5', 'T1-R2-4', 'R2', 1, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R2-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R2-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A primária segue por todas as letras, reavaliando após cada intervenção$q$, true, NULL, $q$Correta: a avaliação inicial identifica e trata todas as lesões que ameaçam a vida, seguindo as demais letras.$q$),
  (2, $q$Nada; o sangramento era o único problema$q$, false, 'erro_conceitual', $q$Controlar um problema não exclui outros.$q$),
  (3, $q$A primária termina com a radiografia de tórax$q$, false, 'erro_indicacao', $q$A radiografia é adjunta, não o fim da avaliação.$q$),
  (4, $q$Basta repetir a FC$q$, false, 'erro_tecnico', $q$A FC sozinha não completa a avaliação.$q$),
  (5, $q$É hora de dar alta da sala$q$, false, 'erro_conduta', $q$Ainda faltam via aérea, respiração, neurológico e exposição.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, você é o líder. Antes da chegada da paciente, o que deveria ter sido feito?$q$ OR i.ancora IS DISTINCT FROM 'D22, D29' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Definir funções e preparar material, já que houve aviso prévio|Correta: com o pré-aviso, o líder dirige a equipe e distribui tarefas antes da chegada.#Chamar a TC para reservar horário e nada mais|Reservar a TC não substitui o preparo da equipe.#Pedir que todos examinem a paciente ao mesmo tempo, sem funções|Sem funções definidas, a avaliação fica desorganizada.#Esperar a paciente para distribuir funções|Distribuir funções depois da chegada desperdiça tempo.#Deixar o residente mais novo liderar sem supervisão|Treinandos podem liderar, mas sob supervisão próxima.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, você é o líder. Antes da chegada da paciente, o que deveria ter sido feito?$q$, dificuldade=2, ancora='D22, D29', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, você é o líder. Antes da chegada da paciente, o que deveria ter sido feito?$q$, 2, 'D22, D29', 'T1-R3-1', 'R3', 1, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R3-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Definir funções e preparar material, já que houve aviso prévio$q$, true, NULL, $q$Correta: com o pré-aviso, o líder dirige a equipe e distribui tarefas antes da chegada.$q$),
  (2, $q$Chamar a TC para reservar horário e nada mais$q$, false, 'erro_indicacao', $q$Reservar a TC não substitui o preparo da equipe.$q$),
  (3, $q$Pedir que todos examinem a paciente ao mesmo tempo, sem funções$q$, false, 'erro_tecnico', $q$Sem funções definidas, a avaliação fica desorganizada.$q$),
  (4, $q$Esperar a paciente para distribuir funções$q$, false, 'erro_conduta', $q$Distribuir funções depois da chegada desperdiça tempo.$q$),
  (5, $q$Deixar o residente mais novo liderar sem supervisão$q$, false, 'erro_conceitual', $q$Treinandos podem liderar, mas sob supervisão próxima.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, como deveria ser a passagem do caso pelo pré-hospitalar?$q$ OR i.ancora IS DISTINCT FROM 'D23, D24' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só com os sinais vitais|Faltariam mecanismo, lesões suspeitas e tratamentos.#Por escrito, lida depois do atendimento|A informação é necessária na chegada, não depois.#Livre, enquanto a equipe já examina|Examinar enquanto o caso é contado faz a equipe perder informação.#Estruturada (MIST), com a equipe parada ouvindo, em até 1 minuto|Correta: passagem estruturada como o MIST, em no máximo 45 segundos a 1 minuto.#Longa, com todos os detalhes da cena|A passagem longa atrasa o atendimento.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, como deveria ser a passagem do caso pelo pré-hospitalar?$q$, dificuldade=3, ancora='D23, D24', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, como deveria ser a passagem do caso pelo pré-hospitalar?$q$, 3, 'D23, D24', 'T1-R3-2', 'R3', 1, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R3-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só com os sinais vitais$q$, false, 'erro_conceitual', $q$Faltariam mecanismo, lesões suspeitas e tratamentos.$q$),
  (2, $q$Por escrito, lida depois do atendimento$q$, false, 'erro_conduta', $q$A informação é necessária na chegada, não depois.$q$),
  (3, $q$Livre, enquanto a equipe já examina$q$, false, 'erro_tecnico', $q$Examinar enquanto o caso é contado faz a equipe perder informação.$q$),
  (4, $q$Estruturada (MIST), com a equipe parada ouvindo, em até 1 minuto$q$, true, NULL, $q$Correta: passagem estruturada como o MIST, em no máximo 45 segundos a 1 minuto.$q$),
  (5, $q$Longa, com todos os detalhes da cena$q$, false, 'erro_indicacao', $q$A passagem longa atrasa o atendimento.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, após o torniquete, a paciente segue com FC 124 e pele fria. Qual a decisão do líder?$q$ OR i.ancora IS DISTINCT FROM 'D26, A39' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Encerrar a reposição porque o torniquete resolveu|Sinais de choque persistentes indicam que algo não está resolvido.#Esperar o resultado do lactato antes de qualquer conduta|Esperar exame laboratorial atrasa a conduta.#Dar alta da sala para a enfermaria|Alta da sala sem completar a avaliação é erro grave.#Manter a avaliação primária, buscar outras fontes de sangramento e decidir o destino com base na resposta à ressuscitação|Correta: a fisiologia é o maior determinante do desfecho; o destino depende da resposta.#Mandar para a TC e reavaliar na volta|Levar à TC um paciente sem resposta clara à ressuscitação é arriscado.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, após o torniquete, a paciente segue com FC 124 e pele fria. Qual a decisão do líder?$q$, dificuldade=3, ancora='D26, A39', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, após o torniquete, a paciente segue com FC 124 e pele fria. Qual a decisão do líder?$q$, 3, 'D26, A39', 'T1-R3-3', 'R3', 1, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R3-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Encerrar a reposição porque o torniquete resolveu$q$, false, 'erro_conceitual', $q$Sinais de choque persistentes indicam que algo não está resolvido.$q$),
  (2, $q$Esperar o resultado do lactato antes de qualquer conduta$q$, false, 'erro_tecnico', $q$Esperar exame laboratorial atrasa a conduta.$q$),
  (3, $q$Dar alta da sala para a enfermaria$q$, false, 'erro_conduta', $q$Alta da sala sem completar a avaliação é erro grave.$q$),
  (4, $q$Manter a avaliação primária, buscar outras fontes de sangramento e decidir o destino com base na resposta à ressuscitação$q$, true, NULL, $q$Correta: a fisiologia é o maior determinante do desfecho; o destino depende da resposta.$q$),
  (5, $q$Mandar para a TC e reavaliar na volta$q$, false, 'erro_indicacao', $q$Levar à TC um paciente sem resposta clara à ressuscitação é arriscado.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, o enfermeiro registra a avaliação em um formulário estruturado. O que a evidência mostra sobre esse tipo de formulário?$q$ OR i.ancora IS DISTINCT FROM 'A13, A14, A15, A45, A46' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Redução de mortalidade em todos os pacientes, como desfecho principal|A mortalidade foi desfecho secundário e caiu no subgrupo com fisiologia alterada, em ensaio randomizado por conglomerados.#Nenhum efeito sobre o processo|Houve melhora em 14 de 16 indicadores.#Aumento comprovado da mortalidade|Não houve aumento de mortalidade.#Só serve para fins de auditoria, sem relação com o cuidado|Os indicadores melhorados são do cuidado, não só do registro.#Melhora de indicadores da avaliação primária, como o registro da via aérea|Correta: melhora em 14 de 16 indicadores; registro da via aérea de 72,9% para 98,4%.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, o enfermeiro registra a avaliação em um formulário estruturado. O que a evidência mostra sobre esse tipo de formulário?$q$, dificuldade=4, ancora='A13, A14, A15, A45, A46', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R3-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, o enfermeiro registra a avaliação em um formulário estruturado. O que a evidência mostra sobre esse tipo de formulário?$q$, 4, 'A13, A14, A15, A45, A46', 'T1-R3-4', 'R3', 1, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R3-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R3-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Redução de mortalidade em todos os pacientes, como desfecho principal$q$, false, 'erro_indicacao', $q$A mortalidade foi desfecho secundário e caiu no subgrupo com fisiologia alterada, em ensaio randomizado por conglomerados.$q$),
  (2, $q$Nenhum efeito sobre o processo$q$, false, 'erro_conceitual', $q$Houve melhora em 14 de 16 indicadores.$q$),
  (3, $q$Aumento comprovado da mortalidade$q$, false, 'erro_conduta', $q$Não houve aumento de mortalidade.$q$),
  (4, $q$Só serve para fins de auditoria, sem relação com o cuidado$q$, false, 'erro_tecnico', $q$Os indicadores melhorados são do cuidado, não só do registro.$q$),
  (5, $q$Melhora de indicadores da avaliação primária, como o registro da via aérea$q$, true, NULL, $q$Correta: melhora em 14 de 16 indicadores; registro da via aérea de 72,9% para 98,4%.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 1, um residente pergunta se o torniquete 'salva vidas'. Qual a resposta mais fiel à evidência?$q$ OR i.ancora IS DISTINCT FROM 'D7, A23, A24' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não, ele aumenta a mortalidade|Não houve aumento de mortalidade.#Não há dados sobre o tema|Há revisão sistemática sobre o tema.#Sim, com redução significativa comprovada|A redução de mortalidade não foi significativa (RR 0,70).#Só salva vidas quando colocado no hospital|A revisão estudou o torniquete pré-hospitalar.#A doutrina o considera potencialmente salvador, mas a revisão pré-hospitalar não mostrou redução significativa e há mais amputação inicial, possivelmente por confusão com a gravidade|Correta: há conflito entre doutrina e evidência observacional, que precisa ser interpretado.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 1, um residente pergunta se o torniquete 'salva vidas'. Qual a resposta mais fiel à evidência?$q$, dificuldade=3, ancora='D7, A23, A24', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 1, um residente pergunta se o torniquete 'salva vidas'. Qual a resposta mais fiel à evidência?$q$, 3, 'D7, A23, A24', 'T1-R+-1', 'R+', 1, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R+-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não, ele aumenta a mortalidade$q$, false, 'erro_conduta', $q$Não houve aumento de mortalidade.$q$),
  (2, $q$Não há dados sobre o tema$q$, false, 'erro_tecnico', $q$Há revisão sistemática sobre o tema.$q$),
  (3, $q$Sim, com redução significativa comprovada$q$, false, 'erro_conceitual', $q$A redução de mortalidade não foi significativa (RR 0,70).$q$),
  (4, $q$Só salva vidas quando colocado no hospital$q$, false, 'erro_indicacao', $q$A revisão estudou o torniquete pré-hospitalar.$q$),
  (5, $q$A doutrina o considera potencialmente salvador, mas a revisão pré-hospitalar não mostrou redução significativa e há mais amputação inicial, possivelmente por confusão com a gravidade$q$, true, NULL, $q$Correta: há conflito entre doutrina e evidência observacional, que precisa ser interpretado.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-2')
   AND (i.enunciado IS DISTINCT FROM $q$Ainda no caso 1: qual afirmação sobre treinamentos como o ATLS é a mais precisa?$q$ OR i.ancora IS DISTINCT FROM 'A2, A4' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Associam-se a menor mortalidade (OR 0,60) em estudos observacionais, sem evidência de alta qualidade|Correta: associação em estudos observacionais; falta evidência de alta qualidade.#Reduzem a mortalidade, como mostram ensaios randomizados|Não há ensaio randomizado de alta qualidade demonstrando benefício.#Não têm associação com mortalidade|Há associação com menor mortalidade.#Só funcionam em países de alta renda|Não há dado que sustente isso.#Aumentam o tempo de atendimento|Não há dado que sustente isso.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Ainda no caso 1: qual afirmação sobre treinamentos como o ATLS é a mais precisa?$q$, dificuldade=4, ancora='A2, A4', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Ainda no caso 1: qual afirmação sobre treinamentos como o ATLS é a mais precisa?$q$, 4, 'A2, A4', 'T1-R+-2', 'R+', 1, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R+-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Associam-se a menor mortalidade (OR 0,60) em estudos observacionais, sem evidência de alta qualidade$q$, true, NULL, $q$Correta: associação em estudos observacionais; falta evidência de alta qualidade.$q$),
  (2, $q$Reduzem a mortalidade, como mostram ensaios randomizados$q$, false, 'erro_conceitual', $q$Não há ensaio randomizado de alta qualidade demonstrando benefício.$q$),
  (3, $q$Não têm associação com mortalidade$q$, false, 'erro_conduta', $q$Há associação com menor mortalidade.$q$),
  (4, $q$Só funcionam em países de alta renda$q$, false, 'erro_indicacao', $q$Não há dado que sustente isso.$q$),
  (5, $q$Aumentam o tempo de atendimento$q$, false, 'erro_tecnico', $q$Não há dado que sustente isso.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-3')
   AND (i.enunciado IS DISTINCT FROM $q$Se a paciente do caso 1 chegasse em parada cardíaca traumática, o que a evidência observacional mostra sobre a adrenalina?$q$ OR i.ancora IS DISTINCT FROM 'A31' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Obrigatória antes de qualquer outra medida|Dar adrenalina antes de tratar a causa contraria a prioridade.#Sem associação com sobrevida|Houve associação significativa.#Associada a maior sobrevida em 7 dias|A associação foi com menor sobrevida.#Associada a melhor desfecho neurológico comprovado|Não há esse dado.#Associada a menor sobrevida em 7 dias (OR 0,20)|Correta: menor sobrevida em 7 dias, em dado observacional; na parada traumática, o foco é a causa.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Se a paciente do caso 1 chegasse em parada cardíaca traumática, o que a evidência observacional mostra sobre a adrenalina?$q$, dificuldade=4, ancora='A31', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Se a paciente do caso 1 chegasse em parada cardíaca traumática, o que a evidência observacional mostra sobre a adrenalina?$q$, 4, 'A31', 'T1-R+-3', 'R+', 1, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R+-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Obrigatória antes de qualquer outra medida$q$, false, 'erro_conduta', $q$Dar adrenalina antes de tratar a causa contraria a prioridade.$q$),
  (2, $q$Sem associação com sobrevida$q$, false, 'erro_tecnico', $q$Houve associação significativa.$q$),
  (3, $q$Associada a maior sobrevida em 7 dias$q$, false, 'erro_conceitual', $q$A associação foi com menor sobrevida.$q$),
  (4, $q$Associada a melhor desfecho neurológico comprovado$q$, false, 'erro_indicacao', $q$Não há esse dado.$q$),
  (5, $q$Associada a menor sobrevida em 7 dias (OR 0,20)$q$, true, NULL, $q$Correta: menor sobrevida em 7 dias, em dado observacional; na parada traumática, o foco é a causa.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-4')
   AND (i.enunciado IS DISTINCT FROM $q$Você vai propor ao serviço um checklist para a sala de trauma, usando casos como o 1. Qual cautela a evidência impõe?$q$ OR i.ancora IS DISTINCT FROM 'A7, A9, A10' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O checklist só funciona em pacientes com ISS abaixo de 25|O benefício de mortalidade apareceu justamente no ISS > 25.#Os estudos são antes-e-depois e um deles mostrou mais pneumonia; medir desfechos após implantar|Correta: evidência antes-e-depois, com sinal de efeito adverso (pneumonia, aOR 1,69); monitorar desfechos.#Nenhuma; os benefícios são comprovados por ensaios|Não há ensaios; os estudos são antes-e-depois.#Não há estudos sobre checklist no trauma|Há revisão sistemática sobre o tema.#O checklist aumenta a mortalidade|Um estudo mostrou menor mortalidade no ISS > 25.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Você vai propor ao serviço um checklist para a sala de trauma, usando casos como o 1. Qual cautela a evidência impõe?$q$, dificuldade=5, ancora='A7, A9, A10', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T1-R+-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Você vai propor ao serviço um checklist para a sala de trauma, usando casos como o 1. Qual cautela a evidência impõe?$q$, 5, 'A7, A9, A10', 'T1-R+-4', 'R+', 1, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T1-R+-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T1-R+-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O checklist só funciona em pacientes com ISS abaixo de 25$q$, false, 'erro_indicacao', $q$O benefício de mortalidade apareceu justamente no ISS > 25.$q$),
  (2, $q$Os estudos são antes-e-depois e um deles mostrou mais pneumonia; medir desfechos após implantar$q$, true, NULL, $q$Correta: evidência antes-e-depois, com sinal de efeito adverso (pneumonia, aOR 1,69); monitorar desfechos.$q$),
  (3, $q$Nenhuma; os benefícios são comprovados por ensaios$q$, false, 'erro_conceitual', $q$Não há ensaios; os estudos são antes-e-depois.$q$),
  (4, $q$Não há estudos sobre checklist no trauma$q$, false, 'erro_tecnico', $q$Há revisão sistemática sobre o tema.$q$),
  (5, $q$O checklist aumenta a mortalidade$q$, false, 'erro_conduta', $q$Um estudo mostrou menor mortalidade no ISS > 25.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o paciente fala. O que isso indica sobre a via aérea?$q$ OR i.ancora IS DISTINCT FROM 'D10' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Que o Glasgow é menor que 8|Quem fala e responde não tem Glasgow tão baixo.#Que precisa ser intubado|Falar não indica intubação.#Que está pérvia|Correta: quem fala com voz normal não tem obstrução.#Que não há lesão no tórax|Falar não exclui lesão torácica.#Que há lesão de coluna|A fala não informa sobre a coluna.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o paciente fala. O que isso indica sobre a via aérea?$q$, dificuldade=1, ancora='D10', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o paciente fala. O que isso indica sobre a via aérea?$q$, 1, 'D10', 'T2-Graduação-1', 'graduacao', 2, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-Graduação-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Que o Glasgow é menor que 8$q$, false, 'erro_conduta', $q$Quem fala e responde não tem Glasgow tão baixo.$q$),
  (2, $q$Que precisa ser intubado$q$, false, 'erro_indicacao', $q$Falar não indica intubação.$q$),
  (3, $q$Que está pérvia$q$, true, NULL, $q$Correta: quem fala com voz normal não tem obstrução.$q$),
  (4, $q$Que não há lesão no tórax$q$, false, 'erro_conceitual', $q$Falar não exclui lesão torácica.$q$),
  (5, $q$Que há lesão de coluna$q$, false, 'erro_tecnico', $q$A fala não informa sobre a coluna.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, a SpO2 é 89%. O oxigênio está indicado?$q$ OR i.ancora IS DISTINCT FROM 'A27' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só depois da TC|Não se espera exame de imagem para tratar hipoxemia.#Sim, guiado pela saturação baixa|Correta: a prática caminha para oxigênio guiado pela SpO2; aqui a saturação está baixa.#Só se o eFAST for positivo|O eFAST não é o critério para oxigênio.#Não, oxigênio nunca é usado no trauma|Oxigênio é usado quando indicado.#Só se houver parada|Esperar a parada é erro de conduta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, a SpO2 é 89%. O oxigênio está indicado?$q$, dificuldade=1, ancora='A27', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, a SpO2 é 89%. O oxigênio está indicado?$q$, 1, 'A27', 'T2-Graduação-2', 'graduacao', 2, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-Graduação-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só depois da TC$q$, false, 'erro_indicacao', $q$Não se espera exame de imagem para tratar hipoxemia.$q$),
  (2, $q$Sim, guiado pela saturação baixa$q$, true, NULL, $q$Correta: a prática caminha para oxigênio guiado pela SpO2; aqui a saturação está baixa.$q$),
  (3, $q$Só se o eFAST for positivo$q$, false, 'erro_tecnico', $q$O eFAST não é o critério para oxigênio.$q$),
  (4, $q$Não, oxigênio nunca é usado no trauma$q$, false, 'erro_conceitual', $q$Oxigênio é usado quando indicado.$q$),
  (5, $q$Só se houver parada$q$, false, 'erro_conduta', $q$Esperar a parada é erro de conduta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o que fazer com a roupa do paciente?$q$ OR i.ancora IS DISTINCT FROM 'D18, D19' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Retirar só se houver sangue visível|Lesões podem estar escondidas sem sangue visível.#Retirar toda a roupa para examinar o corpo inteiro|Correta: a exposição completa permite o exame em 360 graus; depois se aquece.#Manter a roupa para evitar frio|O frio se evita aquecendo depois do exame, não deixando de examinar.#Cortar só a camisa|Outras lesões podem passar despercebidas.#Retirar depois da TC|Lesões precisam ser vistas antes.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o que fazer com a roupa do paciente?$q$, dificuldade=2, ancora='D18, D19', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o que fazer com a roupa do paciente?$q$, 2, 'D18, D19', 'T2-Graduação-3', 'graduacao', 2, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-Graduação-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Retirar só se houver sangue visível$q$, false, 'erro_indicacao', $q$Lesões podem estar escondidas sem sangue visível.$q$),
  (2, $q$Retirar toda a roupa para examinar o corpo inteiro$q$, true, NULL, $q$Correta: a exposição completa permite o exame em 360 graus; depois se aquece.$q$),
  (3, $q$Manter a roupa para evitar frio$q$, false, 'erro_conduta', $q$O frio se evita aquecendo depois do exame, não deixando de examinar.$q$),
  (4, $q$Cortar só a camisa$q$, false, 'erro_tecnico', $q$Outras lesões podem passar despercebidas.$q$),
  (5, $q$Retirar depois da TC$q$, false, 'erro_conceitual', $q$Lesões precisam ser vistas antes.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, qual é o objetivo da avaliação primária?$q$ OR i.ancora IS DISTINCT FROM 'D1, D20' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Fazer o diagnóstico completo de todas as lesões|O diagnóstico completo é tarefa da secundária e da terciária.#Decidir a alta|Não é momento de alta.#Colher a história da família|A história vem depois.#Identificar e tratar rapidamente as lesões que ameaçam a vida|Correta: esse é o objetivo da avaliação inicial.#Preencher o prontuário|O registro acompanha, mas não é o objetivo.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, qual é o objetivo da avaliação primária?$q$, dificuldade=2, ancora='D1, D20', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, qual é o objetivo da avaliação primária?$q$, 2, 'D1, D20', 'T2-Graduação-4', 'graduacao', 2, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-Graduação-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Fazer o diagnóstico completo de todas as lesões$q$, false, 'erro_conceitual', $q$O diagnóstico completo é tarefa da secundária e da terciária.$q$),
  (2, $q$Decidir a alta$q$, false, 'erro_conduta', $q$Não é momento de alta.$q$),
  (3, $q$Colher a história da família$q$, false, 'erro_indicacao', $q$A história vem depois.$q$),
  (4, $q$Identificar e tratar rapidamente as lesões que ameaçam a vida$q$, true, NULL, $q$Correta: esse é o objetivo da avaliação inicial.$q$),
  (5, $q$Preencher o prontuário$q$, false, 'erro_tecnico', $q$O registro acompanha, mas não é o objetivo.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, quanto tempo a passagem do caso pelo SAMU deveria durar?$q$ OR i.ancora IS DISTINCT FROM 'D24, D23' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Pelo menos 5 minutos|Passagem longa atrasa o atendimento.#No máximo 45 segundos a 1 minuto|Correta: a passagem não deve passar de 45 segundos a 1 minuto.#Não deve haver passagem verbal|A passagem verbal estruturada melhora a comunicação.#Só depois do exame da equipe|A equipe deve ouvir antes de examinar, salvo extremis.#O tempo que o SAMU quiser|O líder conduz e limita a passagem.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, quanto tempo a passagem do caso pelo SAMU deveria durar?$q$, dificuldade=3, ancora='D24, D23', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, quanto tempo a passagem do caso pelo SAMU deveria durar?$q$, 3, 'D24, D23', 'T2-Graduação-5', 'graduacao', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-Graduação-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Pelo menos 5 minutos$q$, false, 'erro_conduta', $q$Passagem longa atrasa o atendimento.$q$),
  (2, $q$No máximo 45 segundos a 1 minuto$q$, true, NULL, $q$Correta: a passagem não deve passar de 45 segundos a 1 minuto.$q$),
  (3, $q$Não deve haver passagem verbal$q$, false, 'erro_conceitual', $q$A passagem verbal estruturada melhora a comunicação.$q$),
  (4, $q$Só depois do exame da equipe$q$, false, 'erro_tecnico', $q$A equipe deve ouvir antes de examinar, salvo extremis.$q$),
  (5, $q$O tempo que o SAMU quiser$q$, false, 'erro_indicacao', $q$O líder conduz e limita a passagem.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o eFAST não mostra pneumotórax. Isso exclui pneumotórax?$q$ OR i.ancora IS DISTINCT FROM 'A30, A29' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O eFAST não avalia o tórax|O eFAST inclui a avaliação do tórax.#Sim, sempre|Os estudos são conflitantes.#Só exclui se repetido três vezes|Não há esse critério nas fontes.#Não necessariamente; houve estudo com baixa sensibilidade|Correta: estudo prospectivo mostrou baixa sensibilidade e muitos falsos negativos.#Sim, se o paciente fala|Falar não exclui pneumotórax.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o eFAST não mostra pneumotórax. Isso exclui pneumotórax?$q$, dificuldade=3, ancora='A30, A29', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o eFAST não mostra pneumotórax. Isso exclui pneumotórax?$q$, 3, 'A30, A29', 'T2-Graduação-6', 'graduacao', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-Graduação-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-Graduação-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O eFAST não avalia o tórax$q$, false, 'erro_conduta', $q$O eFAST inclui a avaliação do tórax.$q$),
  (2, $q$Sim, sempre$q$, false, 'erro_conceitual', $q$Os estudos são conflitantes.$q$),
  (3, $q$Só exclui se repetido três vezes$q$, false, 'erro_tecnico', $q$Não há esse critério nas fontes.$q$),
  (4, $q$Não necessariamente; houve estudo com baixa sensibilidade$q$, true, NULL, $q$Correta: estudo prospectivo mostrou baixa sensibilidade e muitos falsos negativos.$q$),
  (5, $q$Sim, se o paciente fala$q$, false, 'erro_indicacao', $q$Falar não exclui pneumotórax.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, como conduzir a passagem do SAMU?$q$ OR i.ancora IS DISTINCT FROM 'D23, D24' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O SAMU entrega um papel e sai|A passagem verbal estruturada melhora a comunicação.#Só o enfermeiro ouve|O líder conduz a passagem para toda a equipe.#A equipe para e ouve uma passagem estruturada, como o MIST, antes de passar o paciente|Correta: fora do extremis, a passagem é feita antes ou durante a passagem para a maca, com a equipe ouvindo.#A passagem é feita depois da TC|A informação é necessária na chegada.#Todos examinam enquanto o SAMU fala|Examinar enquanto ouve faz perder informação.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, como conduzir a passagem do SAMU?$q$, dificuldade=2, ancora='D23, D24', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, como conduzir a passagem do SAMU?$q$, 2, 'D23, D24', 'T2-R1-1', 'R1', 2, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R1-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O SAMU entrega um papel e sai$q$, false, 'erro_conceitual', $q$A passagem verbal estruturada melhora a comunicação.$q$),
  (2, $q$Só o enfermeiro ouve$q$, false, 'erro_indicacao', $q$O líder conduz a passagem para toda a equipe.$q$),
  (3, $q$A equipe para e ouve uma passagem estruturada, como o MIST, antes de passar o paciente$q$, true, NULL, $q$Correta: fora do extremis, a passagem é feita antes ou durante a passagem para a maca, com a equipe ouvindo.$q$),
  (4, $q$A passagem é feita depois da TC$q$, false, 'erro_conduta', $q$A informação é necessária na chegada.$q$),
  (5, $q$Todos examinam enquanto o SAMU fala$q$, false, 'erro_tecnico', $q$Examinar enquanto ouve faz perder informação.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, quais são os elementos do MIST?$q$ OR i.ancora IS DISTINCT FROM 'D23' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos|Correta.#Monitorização, imagem, sangue, tomografia|Não são os elementos do MIST.#Motivo, informante, situação, telefone|Não são os elementos do MIST.#Medicações, idade, sexo, tempo|Não são os elementos do MIST.#Mecanismo, intubação, sedação, transporte|Não são os elementos do MIST.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, quais são os elementos do MIST?$q$, dificuldade=2, ancora='D23', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, quais são os elementos do MIST?$q$, 2, 'D23', 'T2-R1-2', 'R1', 2, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R1-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Monitorização, imagem, sangue, tomografia$q$, false, 'erro_tecnico', $q$Não são os elementos do MIST.$q$),
  (3, $q$Motivo, informante, situação, telefone$q$, false, 'erro_conduta', $q$Não são os elementos do MIST.$q$),
  (4, $q$Medicações, idade, sexo, tempo$q$, false, 'erro_conceitual', $q$Não são os elementos do MIST.$q$),
  (5, $q$Mecanismo, intubação, sedação, transporte$q$, false, 'erro_indicacao', $q$Não são os elementos do MIST.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, PA 104/70 no aparelho automático e FC 112. Qual a interpretação correta?$q$ OR i.ancora IS DISTINCT FROM 'D14, A33' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A pressão normal dispensa acesso venoso|O acesso venoso faz parte da avaliação da circulação.#A FC alta é só ansiedade|Atribuir à ansiedade sem excluir sangramento é perigoso.#O paciente está estável|Não há definição consensual de estabilidade que permita concluir isso.#O aparelho pode errar no choque; medir manualmente e avaliar a clínica|Correta: o aparelho automático pode errar no choque.#Deve-se esperar a pressão cair|Esperar a hipotensão atrasa o tratamento.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, PA 104/70 no aparelho automático e FC 112. Qual a interpretação correta?$q$, dificuldade=3, ancora='D14, A33', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, PA 104/70 no aparelho automático e FC 112. Qual a interpretação correta?$q$, 3, 'D14, A33', 'T2-R1-3', 'R1', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R1-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A pressão normal dispensa acesso venoso$q$, false, 'erro_conduta', $q$O acesso venoso faz parte da avaliação da circulação.$q$),
  (2, $q$A FC alta é só ansiedade$q$, false, 'erro_indicacao', $q$Atribuir à ansiedade sem excluir sangramento é perigoso.$q$),
  (3, $q$O paciente está estável$q$, false, 'erro_conceitual', $q$Não há definição consensual de estabilidade que permita concluir isso.$q$),
  (4, $q$O aparelho pode errar no choque; medir manualmente e avaliar a clínica$q$, true, NULL, $q$Correta: o aparelho automático pode errar no choque.$q$),
  (5, $q$Deve-se esperar a pressão cair$q$, false, 'erro_tecnico', $q$Esperar a hipotensão atrasa o tratamento.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, depois da primária, como colher a história?$q$ OR i.ancora IS DISTINCT FROM 'D21, D20' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Perguntando só sobre dor|Incompleto.#Não é necessário colher história no trauma|A história faz parte da avaliação secundária.#Usando o AMPLA: alergias, medicações, doenças prévias, última refeição, eventos|Correta: o AMPLA organiza a história da secundária.#Só com a família, depois da alta|A história é colhida na secundária.#Pedindo que o paciente escreva|Não é o método.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, depois da primária, como colher a história?$q$, dificuldade=3, ancora='D21, D20', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, depois da primária, como colher a história?$q$, 3, 'D21, D20', 'T2-R1-4', 'R1', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R1-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Perguntando só sobre dor$q$, false, 'erro_conceitual', $q$Incompleto.$q$),
  (2, $q$Não é necessário colher história no trauma$q$, false, 'erro_indicacao', $q$A história faz parte da avaliação secundária.$q$),
  (3, $q$Usando o AMPLA: alergias, medicações, doenças prévias, última refeição, eventos$q$, true, NULL, $q$Correta: o AMPLA organiza a história da secundária.$q$),
  (4, $q$Só com a família, depois da alta$q$, false, 'erro_conduta', $q$A história é colhida na secundária.$q$),
  (5, $q$Pedindo que o paciente escreva$q$, false, 'erro_tecnico', $q$Não é o método.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, por que examinar as costas e as axilas do paciente esfaqueado?$q$ OR i.ancora IS DISTINCT FROM 'D18' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Porque a TC não vê as costas|Não é esse o motivo.#Porque é rotina só para fins legais|Não é só uma rotina legal.#Porque o eFAST já excluiu lesões|O eFAST não exclui outras feridas.#Não é necessário examinar as costas|Feridas escondidas podem passar despercebidas.#Porque a exposição completa permite achar outras lesões|Correta: o exame em 360 graus evita que lesões passem.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, por que examinar as costas e as axilas do paciente esfaqueado?$q$, dificuldade=4, ancora='D18', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, por que examinar as costas e as axilas do paciente esfaqueado?$q$, 4, 'D18', 'T2-R1-5', 'R1', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R1-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Porque a TC não vê as costas$q$, false, 'erro_tecnico', $q$Não é esse o motivo.$q$),
  (2, $q$Porque é rotina só para fins legais$q$, false, 'erro_conceitual', $q$Não é só uma rotina legal.$q$),
  (3, $q$Porque o eFAST já excluiu lesões$q$, false, 'erro_indicacao', $q$O eFAST não exclui outras feridas.$q$),
  (4, $q$Não é necessário examinar as costas$q$, false, 'erro_conduta', $q$Feridas escondidas podem passar despercebidas.$q$),
  (5, $q$Porque a exposição completa permite achar outras lesões$q$, true, NULL, $q$Correta: o exame em 360 graus evita que lesões passem.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, achados positivos no exame físico do tórax devem ser valorizados?$q$ OR i.ancora IS DISTINCT FROM 'D25' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só se o eFAST concordar|Achados positivos exigem ação por si.#Sim: o exame tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave|Correta.#Não, só valem com imagem|Achados positivos exigem ação.#Não, o exame físico não tem valor no trauma|O exame tem valor, com limitações.#Só no trauma fechado|Vale para todo trauma.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, achados positivos no exame físico do tórax devem ser valorizados?$q$, dificuldade=4, ancora='D25', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R1-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, achados positivos no exame físico do tórax devem ser valorizados?$q$, 4, 'D25', 'T2-R1-6', 'R1', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R1-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R1-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só se o eFAST concordar$q$, false, 'erro_indicacao', $q$Achados positivos exigem ação por si.$q$),
  (2, $q$Sim: o exame tem baixo valor preditivo negativo, mas achados positivos quase sempre indicam lesão grave$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Não, só valem com imagem$q$, false, 'erro_conceitual', $q$Achados positivos exigem ação.$q$),
  (4, $q$Não, o exame físico não tem valor no trauma$q$, false, 'erro_conduta', $q$O exame tem valor, com limitações.$q$),
  (5, $q$Só no trauma fechado$q$, false, 'erro_tecnico', $q$Vale para todo trauma.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o eFAST não mostrou pneumotórax, mas a SpO2 segue 89% e a respiração rápida. O que fazer?$q$ OR i.ancora IS DISTINCT FROM 'A30, A29' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Repetir o eFAST só no dia seguinte|A investigação deve continuar agora.#Atribuir à ansiedade|Hipoxemia não se explica por ansiedade sem investigação.#Dar alta da sala|Não há condição para alta.#Manter a investigação e o exame, porque o ultrassom pode dar falso negativo|Correta: há estudo com baixa sensibilidade e muitos falsos negativos.#Encerrar a hipótese de pneumotórax|O resultado negativo não basta com a clínica alterada.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o eFAST não mostrou pneumotórax, mas a SpO2 segue 89% e a respiração rápida. O que fazer?$q$, dificuldade=2, ancora='A30, A29', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o eFAST não mostrou pneumotórax, mas a SpO2 segue 89% e a respiração rápida. O que fazer?$q$, 2, 'A30, A29', 'T2-R2-1', 'R2', 2, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R2-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Repetir o eFAST só no dia seguinte$q$, false, 'erro_tecnico', $q$A investigação deve continuar agora.$q$),
  (2, $q$Atribuir à ansiedade$q$, false, 'erro_indicacao', $q$Hipoxemia não se explica por ansiedade sem investigação.$q$),
  (3, $q$Dar alta da sala$q$, false, 'erro_conduta', $q$Não há condição para alta.$q$),
  (4, $q$Manter a investigação e o exame, porque o ultrassom pode dar falso negativo$q$, true, NULL, $q$Correta: há estudo com baixa sensibilidade e muitos falsos negativos.$q$),
  (5, $q$Encerrar a hipótese de pneumotórax$q$, false, 'erro_conceitual', $q$O resultado negativo não basta com a clínica alterada.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o eFAST foi negativo e a SpO2 melhora com oxigênio. Como usar esse eFAST negativo na decisão?$q$ OR i.ancora IS DISTINCT FROM 'A29, A30' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Ignorá-lo, porque o ultrassom não avalia o tórax|O eFAST inclui a avaliação do tórax.#Para indicar drenagem torácica imediata|Exame negativo não indica drenagem.#Como dado de apoio, sem descartar pneumotórax: a sensibilidade variou entre os estudos|Correta: sensibilidade de 93,6% em um estudo e baixa, com muitos falsos negativos, em outro.#Para descartar pneumotórax, porque a sensibilidade é sempre maior que 99%|99,8% foi a especificidade, não a sensibilidade.#Para liberar o paciente da sala sem reavaliar|Sem reavaliação, um pneumotórax pode passar.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o eFAST foi negativo e a SpO2 melhora com oxigênio. Como usar esse eFAST negativo na decisão?$q$, dificuldade=2, ancora='A29, A30', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o eFAST foi negativo e a SpO2 melhora com oxigênio. Como usar esse eFAST negativo na decisão?$q$, 2, 'A29, A30', 'T2-R2-2', 'R2', 2, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R2-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Ignorá-lo, porque o ultrassom não avalia o tórax$q$, false, 'erro_tecnico', $q$O eFAST inclui a avaliação do tórax.$q$),
  (2, $q$Para indicar drenagem torácica imediata$q$, false, 'erro_indicacao', $q$Exame negativo não indica drenagem.$q$),
  (3, $q$Como dado de apoio, sem descartar pneumotórax: a sensibilidade variou entre os estudos$q$, true, NULL, $q$Correta: sensibilidade de 93,6% em um estudo e baixa, com muitos falsos negativos, em outro.$q$),
  (4, $q$Para descartar pneumotórax, porque a sensibilidade é sempre maior que 99%$q$, false, 'erro_conceitual', $q$99,8% foi a especificidade, não a sensibilidade.$q$),
  (5, $q$Para liberar o paciente da sala sem reavaliar$q$, false, 'erro_conduta', $q$Sem reavaliação, um pneumotórax pode passar.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, sem acesso venoso após tentativas, qual a melhor opção?$q$ OR i.ancora IS DISTINCT FROM 'D15, D28' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Esperar a TC|A TC não resolve o acesso.#Insistir na veia por tempo indefinido|Insistir atrasa a ressuscitação.#Acesso intraósseo|Correta: o intraósseo pode salvar vidas no choque.#Usar só via oral|Via oral não serve.#Adiar a reposição|Adiar a reposição é erro de conduta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, sem acesso venoso após tentativas, qual a melhor opção?$q$, dificuldade=3, ancora='D15, D28', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, sem acesso venoso após tentativas, qual a melhor opção?$q$, 3, 'D15, D28', 'T2-R2-3', 'R2', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R2-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Esperar a TC$q$, false, 'erro_conceitual', $q$A TC não resolve o acesso.$q$),
  (2, $q$Insistir na veia por tempo indefinido$q$, false, 'erro_tecnico', $q$Insistir atrasa a ressuscitação.$q$),
  (3, $q$Acesso intraósseo$q$, true, NULL, $q$Correta: o intraósseo pode salvar vidas no choque.$q$),
  (4, $q$Usar só via oral$q$, false, 'erro_indicacao', $q$Via oral não serve.$q$),
  (5, $q$Adiar a reposição$q$, false, 'erro_conduta', $q$Adiar a reposição é erro de conduta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o paciente em choque tem a pele fria. Qual medida não deve ser esquecida após o exame?$q$ OR i.ancora IS DISTINCT FROM 'D19, A36' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Manter despido|Despido, perde calor.#Dar líquidos frios|Fluidos frios pioram a hipotermia.#Aquecer com mantas, ar forçado e fluidos aquecidos|Correta.#Esperar a temperatura cair para agir|Prevenção é prioridade.#Aquecer só na UTI|Aquecer começa na sala de trauma.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o paciente em choque tem a pele fria. Qual medida não deve ser esquecida após o exame?$q$, dificuldade=3, ancora='D19, A36', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o paciente em choque tem a pele fria. Qual medida não deve ser esquecida após o exame?$q$, 3, 'D19, A36', 'T2-R2-4', 'R2', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R2-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Manter despido$q$, false, 'erro_conduta', $q$Despido, perde calor.$q$),
  (2, $q$Dar líquidos frios$q$, false, 'erro_tecnico', $q$Fluidos frios pioram a hipotermia.$q$),
  (3, $q$Aquecer com mantas, ar forçado e fluidos aquecidos$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Esperar a temperatura cair para agir$q$, false, 'erro_indicacao', $q$Prevenção é prioridade.$q$),
  (5, $q$Aquecer só na UTI$q$, false, 'erro_conceitual', $q$Aquecer começa na sala de trauma.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, por que a ordem padrão ABCDE é mantida e não invertida para CAB?$q$ OR i.ancora IS DISTINCT FROM 'D2, D3' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Porque não há hemorragia externa com risco de vida nem o paciente está em extremis|Correta: só esses cenários invertem a ordem.#Porque o paciente é jovem|A idade não inverte a ordem.#Porque o eFAST foi negativo|O eFAST não define a ordem.#Porque o ferimento é penetrante|O mecanismo não inverte a ordem.#Porque a SpO2 está baixa|Hipoxemia é tratada no B, não inverte a ordem.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, por que a ordem padrão ABCDE é mantida e não invertida para CAB?$q$, dificuldade=4, ancora='D2, D3', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, por que a ordem padrão ABCDE é mantida e não invertida para CAB?$q$, 4, 'D2, D3', 'T2-R2-5', 'R2', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R2-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Porque não há hemorragia externa com risco de vida nem o paciente está em extremis$q$, true, NULL, $q$Correta: só esses cenários invertem a ordem.$q$),
  (2, $q$Porque o paciente é jovem$q$, false, 'erro_indicacao', $q$A idade não inverte a ordem.$q$),
  (3, $q$Porque o eFAST foi negativo$q$, false, 'erro_tecnico', $q$O eFAST não define a ordem.$q$),
  (4, $q$Porque o ferimento é penetrante$q$, false, 'erro_conceitual', $q$O mecanismo não inverte a ordem.$q$),
  (5, $q$Porque a SpO2 está baixa$q$, false, 'erro_conduta', $q$Hipoxemia é tratada no B, não inverte a ordem.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o paciente fica sonolento, com Glasgow 8, e fala com dificuldade. Qual a conduta de via aérea?$q$ OR i.ancora IS DISTINCT FROM 'D11, D12, A28' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhuma, porque ele ainda fala|Fala difícil com Glasgow 8 não garante a via aérea.#Cricotireoidostomia imediata, sem tentar intubação|A via aérea cirúrgica é exceção (0,24% numa grande coorte), não a primeira opção.#Sedar e paralisar antes de qualquer exame neurológico|Perde-se a informação neurológica de base.#Aguardar o Glasgow cair mais|Esperar piora atrasa a proteção da via aérea.#Via aérea definitiva, com exame neurológico breve antes da sedação|Correta: Glasgow ≤8 indica via aérea definitiva, com exame neurológico antes da sedação.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o paciente fica sonolento, com Glasgow 8, e fala com dificuldade. Qual a conduta de via aérea?$q$, dificuldade=4, ancora='D11, D12, A28', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R2-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o paciente fica sonolento, com Glasgow 8, e fala com dificuldade. Qual a conduta de via aérea?$q$, 4, 'D11, D12, A28', 'T2-R2-6', 'R2', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R2-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R2-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhuma, porque ele ainda fala$q$, false, 'erro_conceitual', $q$Fala difícil com Glasgow 8 não garante a via aérea.$q$),
  (2, $q$Cricotireoidostomia imediata, sem tentar intubação$q$, false, 'erro_indicacao', $q$A via aérea cirúrgica é exceção (0,24% numa grande coorte), não a primeira opção.$q$),
  (3, $q$Sedar e paralisar antes de qualquer exame neurológico$q$, false, 'erro_tecnico', $q$Perde-se a informação neurológica de base.$q$),
  (4, $q$Aguardar o Glasgow cair mais$q$, false, 'erro_conduta', $q$Esperar piora atrasa a proteção da via aérea.$q$),
  (5, $q$Via aérea definitiva, com exame neurológico breve antes da sedação$q$, true, NULL, $q$Correta: Glasgow ≤8 indica via aérea definitiva, com exame neurológico antes da sedação.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, você lidera. Onde se posicionar durante o atendimento?$q$ OR i.ancora IS DISTINCT FROM 'D22' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Na cabeceira, fazendo a via aérea|Fazer a via aérea tira o líder da coordenação.#Onde tenha a visão do todo, geralmente aos pés da maca|Correta: o líder deve ter a 'visão grande' da sala.#No posto de enfermagem|Longe demais para coordenar.#Fora da sala, ao telefone|Fora da sala não coordena.#Junto ao monitor, de costas para o paciente|De costas não acompanha a equipe.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, você lidera. Onde se posicionar durante o atendimento?$q$, dificuldade=3, ancora='D22', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, você lidera. Onde se posicionar durante o atendimento?$q$, 3, 'D22', 'T2-R3-1', 'R3', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R3-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Na cabeceira, fazendo a via aérea$q$, false, 'erro_conduta', $q$Fazer a via aérea tira o líder da coordenação.$q$),
  (2, $q$Onde tenha a visão do todo, geralmente aos pés da maca$q$, true, NULL, $q$Correta: o líder deve ter a 'visão grande' da sala.$q$),
  (3, $q$No posto de enfermagem$q$, false, 'erro_indicacao', $q$Longe demais para coordenar.$q$),
  (4, $q$Fora da sala, ao telefone$q$, false, 'erro_conceitual', $q$Fora da sala não coordena.$q$),
  (5, $q$Junto ao monitor, de costas para o paciente$q$, false, 'erro_tecnico', $q$De costas não acompanha a equipe.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, quem deve tomar as decisões sobre os próximos passos?$q$ OR i.ancora IS DISTINCT FROM 'D22' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Quem chegar primeiro|Não é critério.#Cada membro decide sua parte|Decisões fragmentadas desorganizam a equipe.#O enfermeiro da maca|O enfermeiro tem outras funções.#O SAMU|O SAMU passa o caso e sai do comando.#O líder da equipe|Correta: as decisões são do líder.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, quem deve tomar as decisões sobre os próximos passos?$q$, dificuldade=3, ancora='D22', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, quem deve tomar as decisões sobre os próximos passos?$q$, 3, 'D22', 'T2-R3-2', 'R3', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R3-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Quem chegar primeiro$q$, false, 'erro_conceitual', $q$Não é critério.$q$),
  (2, $q$Cada membro decide sua parte$q$, false, 'erro_conduta', $q$Decisões fragmentadas desorganizam a equipe.$q$),
  (3, $q$O enfermeiro da maca$q$, false, 'erro_tecnico', $q$O enfermeiro tem outras funções.$q$),
  (4, $q$O SAMU$q$, false, 'erro_indicacao', $q$O SAMU passa o caso e sai do comando.$q$),
  (5, $q$O líder da equipe$q$, true, NULL, $q$Correta: as decisões são do líder.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, o paciente responde à reposição e segue com SpO2 baixa. A TC de corpo inteiro de rotina reduz mortalidade?$q$ OR i.ancora IS DISTINCT FROM 'A12, A42' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Reduz a mortalidade de forma comprovada|Não há essa comprovação.#Aumenta a mortalidade|Não há esse dado.#Dispensa a avaliação secundária|A TC não substitui o exame.#Dispensa a avaliação terciária|Lesões tardias ocorrem mesmo com TC.#Parece ter pouco ou nenhum efeito em mortalidade|Correta: segundo revisão de revisões.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, o paciente responde à reposição e segue com SpO2 baixa. A TC de corpo inteiro de rotina reduz mortalidade?$q$, dificuldade=4, ancora='A12, A42', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, o paciente responde à reposição e segue com SpO2 baixa. A TC de corpo inteiro de rotina reduz mortalidade?$q$, 4, 'A12, A42', 'T2-R3-3', 'R3', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R3-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Reduz a mortalidade de forma comprovada$q$, false, 'erro_conceitual', $q$Não há essa comprovação.$q$),
  (2, $q$Aumenta a mortalidade$q$, false, 'erro_conduta', $q$Não há esse dado.$q$),
  (3, $q$Dispensa a avaliação secundária$q$, false, 'erro_indicacao', $q$A TC não substitui o exame.$q$),
  (4, $q$Dispensa a avaliação terciária$q$, false, 'erro_tecnico', $q$Lesões tardias ocorrem mesmo com TC.$q$),
  (5, $q$Parece ter pouco ou nenhum efeito em mortalidade$q$, true, NULL, $q$Correta: segundo revisão de revisões.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, a passagem do SAMU durou 4 minutos com detalhes da cena. Qual a correção?$q$ OR i.ancora IS DISTINCT FROM 'D24' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Pedir que o SAMU volte depois|Atrasa a informação.#Nenhuma; detalhes são sempre úteis|Passagem longa atrasa e dispersa.#Deixar a passagem para o fim|A informação é necessária na chegada.#O líder deve conduzir e limitar a passagem a 45 segundos a 1 minuto|Correta.#Proibir a passagem verbal|A passagem estruturada é útil.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, a passagem do SAMU durou 4 minutos com detalhes da cena. Qual a correção?$q$, dificuldade=4, ancora='D24', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, a passagem do SAMU durou 4 minutos com detalhes da cena. Qual a correção?$q$, 4, 'D24', 'T2-R3-4', 'R3', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R3-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Pedir que o SAMU volte depois$q$, false, 'erro_tecnico', $q$Atrasa a informação.$q$),
  (2, $q$Nenhuma; detalhes são sempre úteis$q$, false, 'erro_conceitual', $q$Passagem longa atrasa e dispersa.$q$),
  (3, $q$Deixar a passagem para o fim$q$, false, 'erro_indicacao', $q$A informação é necessária na chegada.$q$),
  (4, $q$O líder deve conduzir e limitar a passagem a 45 segundos a 1 minuto$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Proibir a passagem verbal$q$, false, 'erro_conduta', $q$A passagem estruturada é útil.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, quando o residente do primeiro ano pode liderar?$q$ OR i.ancora IS DISTINCT FROM 'D29' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sempre que quiser|Sem supervisão, não.#Só se o assistente sair|Sem supervisão, não.#Só em pacientes graves|Não é o critério.#Nunca|Treinandos devem ter oportunidade de liderar.#Sob supervisão próxima do assistente|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, quando o residente do primeiro ano pode liderar?$q$, dificuldade=5, ancora='D29', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, quando o residente do primeiro ano pode liderar?$q$, 5, 'D29', 'T2-R3-5', 'R3', 2, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R3-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sempre que quiser$q$, false, 'erro_indicacao', $q$Sem supervisão, não.$q$),
  (2, $q$Só se o assistente sair$q$, false, 'erro_conduta', $q$Sem supervisão, não.$q$),
  (3, $q$Só em pacientes graves$q$, false, 'erro_tecnico', $q$Não é o critério.$q$),
  (4, $q$Nunca$q$, false, 'erro_conceitual', $q$Treinandos devem ter oportunidade de liderar.$q$),
  (5, $q$Sob supervisão próxima do assistente$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, qual estratégia de treinamento da equipe reduz o tempo de ressuscitação, segundo estudo?$q$ OR i.ancora IS DISTINCT FROM 'A18' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Avaliação escrita semestral|Não foi o que o estudo testou.#Nenhuma estratégia mostrou efeito|Houve redução de tempo com o treino in situ.#Treino mensal in situ com debriefing em vídeo|Correta.#Aulas teóricas anuais|Não foi o que o estudo testou.#Leitura de protocolos|Não foi o que o estudo testou.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, qual estratégia de treinamento da equipe reduz o tempo de ressuscitação, segundo estudo?$q$, dificuldade=5, ancora='A18', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R3-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, qual estratégia de treinamento da equipe reduz o tempo de ressuscitação, segundo estudo?$q$, 5, 'A18', 'T2-R3-6', 'R3', 2, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R3-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R3-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Avaliação escrita semestral$q$, false, 'erro_conduta', $q$Não foi o que o estudo testou.$q$),
  (2, $q$Nenhuma estratégia mostrou efeito$q$, false, 'erro_conceitual', $q$Houve redução de tempo com o treino in situ.$q$),
  (3, $q$Treino mensal in situ com debriefing em vídeo$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Aulas teóricas anuais$q$, false, 'erro_indicacao', $q$Não foi o que o estudo testou.$q$),
  (5, $q$Leitura de protocolos$q$, false, 'erro_tecnico', $q$Não foi o que o estudo testou.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, discutindo com residentes os dois estudos de eFAST para pneumotórax, qual a síntese correta?$q$ OR i.ancora IS DISTINCT FROM 'A29, A30, A47' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O eFAST é sempre sensível|Um estudo mostrou baixa sensibilidade.#Os dois estudos concordam|Os resultados divergem.#A especificidade é baixa|A especificidade foi 99,8% no estudo citado.#O eFAST é sempre inútil|Um estudo mostrou sensibilidade de 93,6%.#Resultados conflitantes: sensibilidade alta em um, baixa em outro; negativo não encerra a investigação|Correta. Atenção: o estudo de baixa sensibilidade incluiu só trauma torácico fechado, e o paciente do caso 2 tem ferimento penetrante.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, discutindo com residentes os dois estudos de eFAST para pneumotórax, qual a síntese correta?$q$, dificuldade=3, ancora='A29, A30, A47', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, discutindo com residentes os dois estudos de eFAST para pneumotórax, qual a síntese correta?$q$, 3, 'A29, A30, A47', 'T2-R+-1', 'R+', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R+-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O eFAST é sempre sensível$q$, false, 'erro_conceitual', $q$Um estudo mostrou baixa sensibilidade.$q$),
  (2, $q$Os dois estudos concordam$q$, false, 'erro_indicacao', $q$Os resultados divergem.$q$),
  (3, $q$A especificidade é baixa$q$, false, 'erro_tecnico', $q$A especificidade foi 99,8% no estudo citado.$q$),
  (4, $q$O eFAST é sempre inútil$q$, false, 'erro_conduta', $q$Um estudo mostrou sensibilidade de 93,6%.$q$),
  (5, $q$Resultados conflitantes: sensibilidade alta em um, baixa em outro; negativo não encerra a investigação$q$, true, NULL, $q$Correta. Atenção: o estudo de baixa sensibilidade incluiu só trauma torácico fechado, e o paciente do caso 2 tem ferimento penetrante.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, sobre oxigênio suplementar no traumatizado grave, o que a pesquisa com profissionais mostrou?$q$ OR i.ancora IS DISTINCT FROM 'A27' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Contraindica oxigênio no trauma|Não há contraindicação.#Não houve consenso algum|Houve maioria clara.#É um ensaio clínico com desfecho de mortalidade|É pesquisa de opinião.#A maioria (73 %) não apoia dar oxigênio sempre, sem considerar a SpO2|Correta; é opinião de profissionais, não desfecho clínico.#A maioria apoia oxigênio para todos|Foi o contrário.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, sobre oxigênio suplementar no traumatizado grave, o que a pesquisa com profissionais mostrou?$q$, dificuldade=3, ancora='A27', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, sobre oxigênio suplementar no traumatizado grave, o que a pesquisa com profissionais mostrou?$q$, 3, 'A27', 'T2-R+-2', 'R+', 2, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R+-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Contraindica oxigênio no trauma$q$, false, 'erro_conduta', $q$Não há contraindicação.$q$),
  (2, $q$Não houve consenso algum$q$, false, 'erro_indicacao', $q$Houve maioria clara.$q$),
  (3, $q$É um ensaio clínico com desfecho de mortalidade$q$, false, 'erro_tecnico', $q$É pesquisa de opinião.$q$),
  (4, $q$A maioria (73 %) não apoia dar oxigênio sempre, sem considerar a SpO2$q$, true, NULL, $q$Correta; é opinião de profissionais, não desfecho clínico.$q$),
  (5, $q$A maioria apoia oxigênio para todos$q$, false, 'erro_conceitual', $q$Foi o contrário.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, um residente quer intubar porque o paciente 'pode piorar'. Qual a melhor resposta baseada na doutrina?$q$ OR i.ancora IS DISTINCT FROM 'D10, D11, D12' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O paciente fala com voz normal e tem Glasgow alto; tratar a hipoxemia e reavaliar|Correta: voz normal indica via aérea pérvia; a indicação de via aérea definitiva tem critérios.#Intubar só após a TC|A decisão não depende da TC.#Intubar sempre no trauma penetrante de tórax|O mecanismo não indica intubação por si.#Intubar sem exame neurológico prévio|O exame neurológico vem antes da sedação.#Nunca intubar no trauma de tórax|A via aérea definitiva pode ser necessária.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, um residente quer intubar porque o paciente 'pode piorar'. Qual a melhor resposta baseada na doutrina?$q$, dificuldade=4, ancora='D10, D11, D12', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, um residente quer intubar porque o paciente 'pode piorar'. Qual a melhor resposta baseada na doutrina?$q$, 4, 'D10, D11, D12', 'T2-R+-3', 'R+', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R+-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O paciente fala com voz normal e tem Glasgow alto; tratar a hipoxemia e reavaliar$q$, true, NULL, $q$Correta: voz normal indica via aérea pérvia; a indicação de via aérea definitiva tem critérios.$q$),
  (2, $q$Intubar só após a TC$q$, false, 'erro_conduta', $q$A decisão não depende da TC.$q$),
  (3, $q$Intubar sempre no trauma penetrante de tórax$q$, false, 'erro_indicacao', $q$O mecanismo não indica intubação por si.$q$),
  (4, $q$Intubar sem exame neurológico prévio$q$, false, 'erro_tecnico', $q$O exame neurológico vem antes da sedação.$q$),
  (5, $q$Nunca intubar no trauma de tórax$q$, false, 'erro_conceitual', $q$A via aérea definitiva pode ser necessária.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, se o paciente sangrasse muito pela boca após trauma de face penetrante, sem indicação de proteção cervical, qual medida simples pode ajudar?$q$ OR i.ancora IS DISTINCT FROM 'D13' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sentá-lo para que cuspa ou aspire o sangue|Correta: pode transformar uma emergência de via aérea em situação mais controlada.#Sedar profundamente antes de avaliar|Sedar sem preparar a via aérea é perigoso.#Deitá-lo em decúbito dorsal|Deitado, o sangue tende a ir para a via aérea.#Tamponar a boca|Tamponar a boca obstrui a via aérea.#Colocar colar cervical|O colar não está indicado nesse cenário.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, se o paciente sangrasse muito pela boca após trauma de face penetrante, sem indicação de proteção cervical, qual medida simples pode ajudar?$q$, dificuldade=4, ancora='D13', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, se o paciente sangrasse muito pela boca após trauma de face penetrante, sem indicação de proteção cervical, qual medida simples pode ajudar?$q$, 4, 'D13', 'T2-R+-4', 'R+', 2, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R+-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sentá-lo para que cuspa ou aspire o sangue$q$, true, NULL, $q$Correta: pode transformar uma emergência de via aérea em situação mais controlada.$q$),
  (2, $q$Sedar profundamente antes de avaliar$q$, false, 'erro_conceitual', $q$Sedar sem preparar a via aérea é perigoso.$q$),
  (3, $q$Deitá-lo em decúbito dorsal$q$, false, 'erro_conduta', $q$Deitado, o sangue tende a ir para a via aérea.$q$),
  (4, $q$Tamponar a boca$q$, false, 'erro_tecnico', $q$Tamponar a boca obstrui a via aérea.$q$),
  (5, $q$Colocar colar cervical$q$, false, 'erro_indicacao', $q$O colar não está indicado nesse cenário.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, como interpretar a evidência sobre treinamentos de suporte de vida ao planejar o ensino da equipe?$q$ OR i.ancora IS DISTINCT FROM 'A2, A4, A5, A6' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Associação com menor mortalidade em estudos observacionais e ensaio pragmático em andamento|Correta.#Benefício comprovado por ensaios|Não há ensaio de alta qualidade concluído.#Nenhuma associação|Há associação.#Custos iguais entre programas|Os custos variam muito.#O ATLS é o programa mais barato|O ATLS foi o mais caro (USD 1433,5).$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, como interpretar a evidência sobre treinamentos de suporte de vida ao planejar o ensino da equipe?$q$, dificuldade=5, ancora='A2, A4, A5, A6', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, como interpretar a evidência sobre treinamentos de suporte de vida ao planejar o ensino da equipe?$q$, 5, 'A2, A4, A5, A6', 'T2-R+-5', 'R+', 2, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R+-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Associação com menor mortalidade em estudos observacionais e ensaio pragmático em andamento$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Benefício comprovado por ensaios$q$, false, 'erro_conceitual', $q$Não há ensaio de alta qualidade concluído.$q$),
  (3, $q$Nenhuma associação$q$, false, 'erro_conduta', $q$Há associação.$q$),
  (4, $q$Custos iguais entre programas$q$, false, 'erro_indicacao', $q$Os custos variam muito.$q$),
  (5, $q$O ATLS é o programa mais barato$q$, false, 'erro_tecnico', $q$O ATLS foi o mais caro (USD 1433,5).$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 2, um colega afirma que lesões passam despercebidas só sem TC. Qual dado o contradiz?$q$ OR i.ancora IS DISTINCT FROM 'A42, D30' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Lesões tardias só ocorrem em crianças|Não há esse dado.#Nenhum dado|Há dado que contradiz.#A TC detecta 100% das lesões|Nenhum estudo mostrou isso.#Lesões com diagnóstico tardio em 13,9 % mesmo com TC de corpo inteiro|Correta.#A avaliação terciária é desnecessária|A terciária reduz lesões não identificadas.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 2, um colega afirma que lesões passam despercebidas só sem TC. Qual dado o contradiz?$q$, dificuldade=5, ancora='A42, D30', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T2-R+-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 2, um colega afirma que lesões passam despercebidas só sem TC. Qual dado o contradiz?$q$, 5, 'A42, D30', 'T2-R+-6', 'R+', 2, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T2-R+-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T2-R+-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Lesões tardias só ocorrem em crianças$q$, false, 'erro_indicacao', $q$Não há esse dado.$q$),
  (2, $q$Nenhum dado$q$, false, 'erro_conceitual', $q$Há dado que contradiz.$q$),
  (3, $q$A TC detecta 100% das lesões$q$, false, 'erro_conduta', $q$Nenhum estudo mostrou isso.$q$),
  (4, $q$Lesões com diagnóstico tardio em 13,9 % mesmo com TC de corpo inteiro$q$, true, NULL, $q$Correta.$q$),
  (5, $q$A avaliação terciária é desnecessária$q$, false, 'erro_tecnico', $q$A terciária reduz lesões não identificadas.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, o Glasgow é 7. O que isso indica?$q$ OR i.ancora IS DISTINCT FROM 'D11' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Que basta oxigênio por cateter|Insuficiente para Glasgow 7.#Que a via aérea está garantida|Ronco e Glasgow 7 indicam risco.#Necessidade de via aérea definitiva|Correta: Glasgow ≤8 indica via aérea definitiva.#Que pode esperar a TC para decidir|A decisão sobre a via aérea não espera a TC.#Que não há trauma de crânio|O Glasgow baixo sugere o contrário.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, o Glasgow é 7. O que isso indica?$q$, dificuldade=1, ancora='D11', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, o Glasgow é 7. O que isso indica?$q$, 1, 'D11', 'T3-Graduação-1', 'graduacao', 3, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-Graduação-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Que basta oxigênio por cateter$q$, false, 'erro_tecnico', $q$Insuficiente para Glasgow 7.$q$),
  (2, $q$Que a via aérea está garantida$q$, false, 'erro_conceitual', $q$Ronco e Glasgow 7 indicam risco.$q$),
  (3, $q$Necessidade de via aérea definitiva$q$, true, NULL, $q$Correta: Glasgow ≤8 indica via aérea definitiva.$q$),
  (4, $q$Que pode esperar a TC para decidir$q$, false, 'erro_conduta', $q$A decisão sobre a via aérea não espera a TC.$q$),
  (5, $q$Que não há trauma de crânio$q$, false, 'erro_indicacao', $q$O Glasgow baixo sugere o contrário.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, a agitação no caminho pode significar o quê?$q$ OR i.ancora IS DISTINCT FROM 'D17' OR i.dificuldade <> 1
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só embriaguez|Atribuir só ao álcool é perigoso.#Choque, além de álcool ou trauma de crânio|Correta: agitação é sinal clássico de choque classe III e IV.#Só dor|Incompleto.#Que o paciente está bem|Agitação não é sinal de bem-estar.#Nada de importante|Pode ser grave.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, a agitação no caminho pode significar o quê?$q$, dificuldade=1, ancora='D17', taxa_esperada='acima de 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, a agitação no caminho pode significar o quê?$q$, 1, 'D17', 'T3-Graduação-2', 'graduacao', 3, false, 'acima de 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-Graduação-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só embriaguez$q$, false, 'erro_conceitual', $q$Atribuir só ao álcool é perigoso.$q$),
  (2, $q$Choque, além de álcool ou trauma de crânio$q$, true, NULL, $q$Correta: agitação é sinal clássico de choque classe III e IV.$q$),
  (3, $q$Só dor$q$, false, 'erro_indicacao', $q$Incompleto.$q$),
  (4, $q$Que o paciente está bem$q$, false, 'erro_tecnico', $q$Agitação não é sinal de bem-estar.$q$),
  (5, $q$Nada de importante$q$, false, 'erro_conduta', $q$Pode ser grave.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, temperatura de 35,1 °C. O que fazer?$q$ OR i.ancora IS DISTINCT FROM 'D19, A36' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Esperar a TC|Aquecer não depende de imagem.#Dar banho frio|Piora a hipotermia.#Retirar as mantas para examinar de novo|Reexaminar não justifica deixá-lo frio.#Nada, é normal|Abaixo do normal e frequente no trauma grave.#Aquecer: mantas, ar forçado, fluidos aquecidos|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, temperatura de 35,1 °C. O que fazer?$q$, dificuldade=2, ancora='D19, A36', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, temperatura de 35,1 °C. O que fazer?$q$, 2, 'D19, A36', 'T3-Graduação-3', 'graduacao', 3, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-Graduação-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Esperar a TC$q$, false, 'erro_indicacao', $q$Aquecer não depende de imagem.$q$),
  (2, $q$Dar banho frio$q$, false, 'erro_conduta', $q$Piora a hipotermia.$q$),
  (3, $q$Retirar as mantas para examinar de novo$q$, false, 'erro_tecnico', $q$Reexaminar não justifica deixá-lo frio.$q$),
  (4, $q$Nada, é normal$q$, false, 'erro_conceitual', $q$Abaixo do normal e frequente no trauma grave.$q$),
  (5, $q$Aquecer: mantas, ar forçado, fluidos aquecidos$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, quando o Glasgow deve ser avaliado?$q$ OR i.ancora IS DISTINCT FROM 'D16' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Na chegada e de novo durante a ressuscitação|Correta.#Só na chegada|A avaliação deve ser repetida.#Só se houver fratura de crânio|Vale para todos.#Só na UTI|Começa na sala de trauma.#Só depois da intubação|Antes também.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, quando o Glasgow deve ser avaliado?$q$, dificuldade=2, ancora='D16', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, quando o Glasgow deve ser avaliado?$q$, 2, 'D16', 'T3-Graduação-4', 'graduacao', 3, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-Graduação-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Na chegada e de novo durante a ressuscitação$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Só na chegada$q$, false, 'erro_conceitual', $q$A avaliação deve ser repetida.$q$),
  (3, $q$Só se houver fratura de crânio$q$, false, 'erro_conduta', $q$Vale para todos.$q$),
  (4, $q$Só na UTI$q$, false, 'erro_indicacao', $q$Começa na sala de trauma.$q$),
  (5, $q$Só depois da intubação$q$, false, 'erro_tecnico', $q$Antes também.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, a pressão de 132/84 no aparelho automático exclui choque?$q$ OR i.ancora IS DISTINCT FROM 'D14, D17' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sim|FC 118 e pele fria sugerem choque.#Sim, no idoso|A idade não torna o aparelho confiável.#Sim, se a FC for alta|FC alta não confirma ausência de choque.#Só se a pele estiver quente|A pele aqui está fria.#Não; o aparelho automático pode errar no choque|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, a pressão de 132/84 no aparelho automático exclui choque?$q$, dificuldade=3, ancora='D14, D17', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, a pressão de 132/84 no aparelho automático exclui choque?$q$, 3, 'D14, D17', 'T3-Graduação-5', 'graduacao', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-Graduação-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sim$q$, false, 'erro_conceitual', $q$FC 118 e pele fria sugerem choque.$q$),
  (2, $q$Sim, no idoso$q$, false, 'erro_tecnico', $q$A idade não torna o aparelho confiável.$q$),
  (3, $q$Sim, se a FC for alta$q$, false, 'erro_indicacao', $q$FC alta não confirma ausência de choque.$q$),
  (4, $q$Só se a pele estiver quente$q$, false, 'erro_conduta', $q$A pele aqui está fria.$q$),
  (5, $q$Não; o aparelho automático pode errar no choque$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, qual é a sequência padrão da avaliação primária neste paciente sem hemorragia externa?$q$ OR i.ancora IS DISTINCT FROM 'D2' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só AB|Incompleta.#CAB|CAB é para hemorragia externa ou extremis.#ABCDE|Correta: sem hemorragia externa grave nem extremis, a ordem é ABCDE.#EDCBA|Ordem inexistente.#DEABC|Ordem inexistente.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, qual é a sequência padrão da avaliação primária neste paciente sem hemorragia externa?$q$, dificuldade=3, ancora='D2', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, qual é a sequência padrão da avaliação primária neste paciente sem hemorragia externa?$q$, 3, 'D2', 'T3-Graduação-6', 'graduacao', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-Graduação-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-Graduação-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só AB$q$, false, 'erro_conceitual', $q$Incompleta.$q$),
  (2, $q$CAB$q$, false, 'erro_indicacao', $q$CAB é para hemorragia externa ou extremis.$q$),
  (3, $q$ABCDE$q$, true, NULL, $q$Correta: sem hemorragia externa grave nem extremis, a ordem é ABCDE.$q$),
  (4, $q$EDCBA$q$, false, 'erro_tecnico', $q$Ordem inexistente.$q$),
  (5, $q$DEABC$q$, false, 'erro_conduta', $q$Ordem inexistente.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, antes de sedar e intubar, o que deve ser feito?$q$ OR i.ancora IS DISTINCT FROM 'D12' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nada; intubar imediatamente sem exame|Perde-se a informação neurológica de base.#Retirar o colar|Não é o passo antes da intubação.#TC de crânio|A TC não precede a via aérea.#Exame neurológico breve e completo|Correta.#Colher o AMPLA completo|O AMPLA é da secundária.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, antes de sedar e intubar, o que deve ser feito?$q$, dificuldade=2, ancora='D12', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, antes de sedar e intubar, o que deve ser feito?$q$, 2, 'D12', 'T3-R1-1', 'R1', 3, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R1-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nada; intubar imediatamente sem exame$q$, false, 'erro_conduta', $q$Perde-se a informação neurológica de base.$q$),
  (2, $q$Retirar o colar$q$, false, 'erro_tecnico', $q$Não é o passo antes da intubação.$q$),
  (3, $q$TC de crânio$q$, false, 'erro_indicacao', $q$A TC não precede a via aérea.$q$),
  (4, $q$Exame neurológico breve e completo$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Colher o AMPLA completo$q$, false, 'erro_conceitual', $q$O AMPLA é da secundária.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, por que medir a pressão manualmente?$q$ OR i.ancora IS DISTINCT FROM 'D14' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Porque o aparelho automático pode errar no choque|Correta.#Por tradição, sem motivo|Há motivo.#Porque o manual é sempre mais alto|Não é a razão.#Porque o idoso não tem pulso|Falso.#Porque o automático é proibido|Não é proibido.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, por que medir a pressão manualmente?$q$, dificuldade=2, ancora='D14', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, por que medir a pressão manualmente?$q$, 2, 'D14', 'T3-R1-2', 'R1', 3, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R1-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Porque o aparelho automático pode errar no choque$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Por tradição, sem motivo$q$, false, 'erro_conduta', $q$Há motivo.$q$),
  (3, $q$Porque o manual é sempre mais alto$q$, false, 'erro_conceitual', $q$Não é a razão.$q$),
  (4, $q$Porque o idoso não tem pulso$q$, false, 'erro_tecnico', $q$Falso.$q$),
  (5, $q$Porque o automático é proibido$q$, false, 'erro_indicacao', $q$Não é proibido.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, o hálito alcoólico explica o Glasgow 7?$q$ OR i.ancora IS DISTINCT FROM 'D17' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não se deve atribuir ao álcool sem excluir choque e trauma de crânio|Correta: agitação e rebaixamento podem ser choque.#Não importa a causa|A causa muda a conduta.#Sim, sempre|Atribuir ao álcool é armadilha.#Sim, se o paciente for idoso|A idade não muda isso.#Sim, se a TC for normal|A TC não exclui choque.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, o hálito alcoólico explica o Glasgow 7?$q$, dificuldade=3, ancora='D17', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, o hálito alcoólico explica o Glasgow 7?$q$, 3, 'D17', 'T3-R1-3', 'R1', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R1-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não se deve atribuir ao álcool sem excluir choque e trauma de crânio$q$, true, NULL, $q$Correta: agitação e rebaixamento podem ser choque.$q$),
  (2, $q$Não importa a causa$q$, false, 'erro_conduta', $q$A causa muda a conduta.$q$),
  (3, $q$Sim, sempre$q$, false, 'erro_conceitual', $q$Atribuir ao álcool é armadilha.$q$),
  (4, $q$Sim, se o paciente for idoso$q$, false, 'erro_indicacao', $q$A idade não muda isso.$q$),
  (5, $q$Sim, se a TC for normal$q$, false, 'erro_tecnico', $q$A TC não exclui choque.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, após a intubação, qual cuidado com a temperatura?$q$ OR i.ancora IS DISTINCT FROM 'D19, A36' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum|A hipotermia é frequente e subvalorizada.#Só na UTI|Começa na sala.#Só se abaixo de 30 °C|Esperar piora é erro.#Resfriar para proteger o cérebro|Não há base para isso aqui.#Aquecer ativamente e medir|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, após a intubação, qual cuidado com a temperatura?$q$, dificuldade=3, ancora='D19, A36', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, após a intubação, qual cuidado com a temperatura?$q$, 3, 'D19, A36', 'T3-R1-4', 'R1', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R1-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum$q$, false, 'erro_conceitual', $q$A hipotermia é frequente e subvalorizada.$q$),
  (2, $q$Só na UTI$q$, false, 'erro_tecnico', $q$Começa na sala.$q$),
  (3, $q$Só se abaixo de 30 °C$q$, false, 'erro_conduta', $q$Esperar piora é erro.$q$),
  (4, $q$Resfriar para proteger o cérebro$q$, false, 'erro_indicacao', $q$Não há base para isso aqui.$q$),
  (5, $q$Aquecer ativamente e medir$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, um colega diz que o exame físico normal da barriga dispensa investigação. O que a doutrina diz?$q$ OR i.ancora IS DISTINCT FROM 'D25' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Exame normal exclui lesão|O exame normal não exclui.#Exame físico não tem valor|Achados positivos têm valor.#Exame normal libera a alta|Não libera.#Só a TC tem valor|O exame físico tem valor.#O exame físico tem baixo valor preditivo negativo; um exame normal não exclui lesão|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, um colega diz que o exame físico normal da barriga dispensa investigação. O que a doutrina diz?$q$, dificuldade=4, ancora='D25', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, um colega diz que o exame físico normal da barriga dispensa investigação. O que a doutrina diz?$q$, 4, 'D25', 'T3-R1-5', 'R1', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R1-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Exame normal exclui lesão$q$, false, 'erro_conceitual', $q$O exame normal não exclui.$q$),
  (2, $q$Exame físico não tem valor$q$, false, 'erro_indicacao', $q$Achados positivos têm valor.$q$),
  (3, $q$Exame normal libera a alta$q$, false, 'erro_conduta', $q$Não libera.$q$),
  (4, $q$Só a TC tem valor$q$, false, 'erro_tecnico', $q$O exame físico tem valor.$q$),
  (5, $q$O exame físico tem baixo valor preditivo negativo; um exame normal não exclui lesão$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, a temperatura é 35,1 °C e um colega diz que isso não é prioridade. Como responder?$q$ OR i.ancora IS DISTINCT FROM 'A36, D19, A38' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Resfriar para proteger o cérebro|Não há base para resfriar aqui.#Aquecer só com fluido, sem mantas|Fluido aquecido sozinho pode não bastar; usar mantas e ar forçado.#A hipotermia atinge até dois terços dos graves e é subvalorizada: aquecer já|Correta.#Hipotermia é rara no trauma|É frequente.#Concordar: só tratar abaixo de 32 °C|Esperar piorar contraria a prevenção.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, a temperatura é 35,1 °C e um colega diz que isso não é prioridade. Como responder?$q$, dificuldade=4, ancora='A36, D19, A38', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R1-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, a temperatura é 35,1 °C e um colega diz que isso não é prioridade. Como responder?$q$, 4, 'A36, D19, A38', 'T3-R1-6', 'R1', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R1-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R1-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Resfriar para proteger o cérebro$q$, false, 'erro_indicacao', $q$Não há base para resfriar aqui.$q$),
  (2, $q$Aquecer só com fluido, sem mantas$q$, false, 'erro_tecnico', $q$Fluido aquecido sozinho pode não bastar; usar mantas e ar forçado.$q$),
  (3, $q$A hipotermia atinge até dois terços dos graves e é subvalorizada: aquecer já$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Hipotermia é rara no trauma$q$, false, 'erro_conceitual', $q$É frequente.$q$),
  (5, $q$Concordar: só tratar abaixo de 32 °C$q$, false, 'erro_conduta', $q$Esperar piorar contraria a prevenção.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, por que o aquecimento com fluido aquecido pode ser insuficiente?$q$ OR i.ancora IS DISTINCT FROM 'A38' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Fluido aquecido não existe na prática|Existe.#Fluido aquecido esfria o paciente|Não esfria; pode chegar abaixo do esperado.#O fluido chega sempre a 39 °C|Perde calor no equipo.#Fluido a 39 °C só chega acima de 37 °C com alto fluxo e ambiente quente|Correta.#O fluido aquecido é contraindicado|Não é contraindicado.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, por que o aquecimento com fluido aquecido pode ser insuficiente?$q$, dificuldade=3, ancora='A38', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, por que o aquecimento com fluido aquecido pode ser insuficiente?$q$, 3, 'A38', 'T3-R2-1', 'R2', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R2-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Fluido aquecido não existe na prática$q$, false, 'erro_conduta', $q$Existe.$q$),
  (2, $q$Fluido aquecido esfria o paciente$q$, false, 'erro_conceitual', $q$Não esfria; pode chegar abaixo do esperado.$q$),
  (3, $q$O fluido chega sempre a 39 °C$q$, false, 'erro_tecnico', $q$Perde calor no equipo.$q$),
  (4, $q$Fluido a 39 °C só chega acima de 37 °C com alto fluxo e ambiente quente$q$, true, NULL, $q$Correta.$q$),
  (5, $q$O fluido aquecido é contraindicado$q$, false, 'erro_indicacao', $q$Não é contraindicado.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, existe abordagem baseada em evidência para manejar a hipotermia no trauma?$q$ OR i.ancora IS DISTINCT FROM 'A37' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sim, só para idosos|Não há.#Sim, resfriar ativamente|Não há base.#Não, ao contrário da acidose e do sangramento|Correta: é uma lacuna.#Sim, com ensaios definitivos|Não há.#Não é necessária|É necessária; é frequente.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, existe abordagem baseada em evidência para manejar a hipotermia no trauma?$q$, dificuldade=3, ancora='A37', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, existe abordagem baseada em evidência para manejar a hipotermia no trauma?$q$, 3, 'A37', 'T3-R2-2', 'R2', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R2-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sim, só para idosos$q$, false, 'erro_indicacao', $q$Não há.$q$),
  (2, $q$Sim, resfriar ativamente$q$, false, 'erro_tecnico', $q$Não há base.$q$),
  (3, $q$Não, ao contrário da acidose e do sangramento$q$, true, NULL, $q$Correta: é uma lacuna.$q$),
  (4, $q$Sim, com ensaios definitivos$q$, false, 'erro_conceitual', $q$Não há.$q$),
  (5, $q$Não é necessária$q$, false, 'erro_conduta', $q$É necessária; é frequente.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, FC 118 e pele fria com PA normal no automático. Como avaliar o choque?$q$ OR i.ancora IS DISTINCT FROM 'A32, D14' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Pela FC apenas|Insuficiente.#Pelo Glasgow apenas|Insuficiente.#Pela tabela de classes apenas|A tabela clássica teve viés.#Pela PA apenas|Pode errar no choque.#Sem depender de um parâmetro isolado; a classificação clássica tem limitações|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, FC 118 e pele fria com PA normal no automático. Como avaliar o choque?$q$, dificuldade=4, ancora='A32, D14', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, FC 118 e pele fria com PA normal no automático. Como avaliar o choque?$q$, 4, 'A32, D14', 'T3-R2-3', 'R2', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R2-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Pela FC apenas$q$, false, 'erro_tecnico', $q$Insuficiente.$q$),
  (2, $q$Pelo Glasgow apenas$q$, false, 'erro_conduta', $q$Insuficiente.$q$),
  (3, $q$Pela tabela de classes apenas$q$, false, 'erro_conceitual', $q$A tabela clássica teve viés.$q$),
  (4, $q$Pela PA apenas$q$, false, 'erro_indicacao', $q$Pode errar no choque.$q$),
  (5, $q$Sem depender de um parâmetro isolado; a classificação clássica tem limitações$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, ao revisar o caso no dia seguinte, o que reduz lesões não identificadas?$q$ OR i.ancora IS DISTINCT FROM 'D30' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Dar alta precoce|Aumenta o risco.#Confiar só no laudo inicial|Lesões podem passar no laudo inicial.#Repetir a TC de corpo inteiro em todos|Não é o que a fonte recomenda.#Avaliação terciária com revisão cuidadosa das imagens|Correta.#Nada|Há medida.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, ao revisar o caso no dia seguinte, o que reduz lesões não identificadas?$q$, dificuldade=4, ancora='D30', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, ao revisar o caso no dia seguinte, o que reduz lesões não identificadas?$q$, 4, 'D30', 'T3-R2-4', 'R2', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R2-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Dar alta precoce$q$, false, 'erro_conduta', $q$Aumenta o risco.$q$),
  (2, $q$Confiar só no laudo inicial$q$, false, 'erro_tecnico', $q$Lesões podem passar no laudo inicial.$q$),
  (3, $q$Repetir a TC de corpo inteiro em todos$q$, false, 'erro_indicacao', $q$Não é o que a fonte recomenda.$q$),
  (4, $q$Avaliação terciária com revisão cuidadosa das imagens$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Nada$q$, false, 'erro_conceitual', $q$Há medida.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, após intubação, a PA cai. Como interpretar?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Ignorar|Erro de conduta.#É do álcool|Não explica.#É normal no idoso|Não é.#É só efeito da sedação|Atribuir à sedação sem investigar é armadilha.#Hipotensão após a ressuscitação é sangramento até prova em contrário|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, após intubação, a PA cai. Como interpretar?$q$, dificuldade=5, ancora='D32', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, após intubação, a PA cai. Como interpretar?$q$, 5, 'D32', 'T3-R2-5', 'R2', 3, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R2-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Ignorar$q$, false, 'erro_conduta', $q$Erro de conduta.$q$),
  (2, $q$É do álcool$q$, false, 'erro_indicacao', $q$Não explica.$q$),
  (3, $q$É normal no idoso$q$, false, 'erro_tecnico', $q$Não é.$q$),
  (4, $q$É só efeito da sedação$q$, false, 'erro_conceitual', $q$Atribuir à sedação sem investigar é armadilha.$q$),
  (5, $q$Hipotensão após a ressuscitação é sangramento até prova em contrário$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, a avaliação terciária no segundo dia não achou nada. No quarto dia, o paciente piora. Como pensar?$q$ OR i.ancora IS DISTINCT FROM 'A41, D30' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Dar alta da UTI|Inadequado com piora.#Aguardar 48 horas|Atraso.#A terciária excluiu tudo; pensar só em causas clínicas|A terciária reduz, mas não elimina, lesões não identificadas.#Ainda pode haver lesão não identificada: houve lesão potencialmente letal após a terciária em 0,26% dos graves|Correta: reexaminar e investigar.#Repetir a TC de corpo inteiro sem examinar|A imagem não substitui o reexame.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, a avaliação terciária no segundo dia não achou nada. No quarto dia, o paciente piora. Como pensar?$q$, dificuldade=5, ancora='A41, D30', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R2-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, a avaliação terciária no segundo dia não achou nada. No quarto dia, o paciente piora. Como pensar?$q$, 5, 'A41, D30', 'T3-R2-6', 'R2', 3, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R2-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R2-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Dar alta da UTI$q$, false, 'erro_indicacao', $q$Inadequado com piora.$q$),
  (2, $q$Aguardar 48 horas$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (3, $q$A terciária excluiu tudo; pensar só em causas clínicas$q$, false, 'erro_conceitual', $q$A terciária reduz, mas não elimina, lesões não identificadas.$q$),
  (4, $q$Ainda pode haver lesão não identificada: houve lesão potencialmente letal após a terciária em 0,26% dos graves$q$, true, NULL, $q$Correta: reexaminar e investigar.$q$),
  (5, $q$Repetir a TC de corpo inteiro sem examinar$q$, false, 'erro_tecnico', $q$A imagem não substitui o reexame.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, como líder, qual o destino após estabilizar a via aérea e a circulação?$q$ OR i.ancora IS DISTINCT FROM 'A39, D26' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$TC sempre, mesmo instável sem resposta|Arriscado.#Alta da sala sem TC|Inadequado.#Decidir pela resposta à ressuscitação; a TC é possível no paciente que responde|Correta: no choque, a TC não aumentou a mortalidade precoce, mas a decisão depende da resposta.#Esperar 6 horas|Atraso.#UTI sem imagem|Faltam diagnósticos.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, como líder, qual o destino após estabilizar a via aérea e a circulação?$q$, dificuldade=3, ancora='A39, D26', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, como líder, qual o destino após estabilizar a via aérea e a circulação?$q$, 3, 'A39, D26', 'T3-R3-1', 'R3', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R3-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$TC sempre, mesmo instável sem resposta$q$, false, 'erro_conduta', $q$Arriscado.$q$),
  (2, $q$Alta da sala sem TC$q$, false, 'erro_indicacao', $q$Inadequado.$q$),
  (3, $q$Decidir pela resposta à ressuscitação; a TC é possível no paciente que responde$q$, true, NULL, $q$Correta: no choque, a TC não aumentou a mortalidade precoce, mas a decisão depende da resposta.$q$),
  (4, $q$Esperar 6 horas$q$, false, 'erro_tecnico', $q$Atraso.$q$),
  (5, $q$UTI sem imagem$q$, false, 'erro_conceitual', $q$Faltam diagnósticos.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, em pacientes em choque, a TC de corpo inteiro aumentou a mortalidade em 24 h?$q$ OR i.ancora IS DISTINCT FROM 'A39' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não: 17,4% com TC e 27,6% sem, p = 0,21|Correta.#Não há estudos|Há estudo.#Sim, dobrou|Não.#Sim, com significância|Não houve significância.#Só nos idosos|Não há esse dado.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, em pacientes em choque, a TC de corpo inteiro aumentou a mortalidade em 24 h?$q$, dificuldade=3, ancora='A39', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, em pacientes em choque, a TC de corpo inteiro aumentou a mortalidade em 24 h?$q$, 3, 'A39', 'T3-R3-2', 'R3', 3, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R3-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não: 17,4% com TC e 27,6% sem, p = 0,21$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Não há estudos$q$, false, 'erro_tecnico', $q$Há estudo.$q$),
  (3, $q$Sim, dobrou$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Sim, com significância$q$, false, 'erro_indicacao', $q$Não houve significância.$q$),
  (5, $q$Só nos idosos$q$, false, 'erro_conduta', $q$Não há esse dado.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, como garantir que a equipe faça a avaliação em paralelo?$q$ OR i.ancora IS DISTINCT FROM 'D5, D22' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Um faz tudo sozinho|Lento.#Sem liderança definida|Desorganiza.#Todos fazem tudo|Desorganiza.#Esperar o assistente|Atrasa.#Funções definidas pelo líder antes da chegada|Correta: boa parte da avaliação é simultânea com funções distribuídas.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, como garantir que a equipe faça a avaliação em paralelo?$q$, dificuldade=4, ancora='D5, D22', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, como garantir que a equipe faça a avaliação em paralelo?$q$, 4, 'D5, D22', 'T3-R3-3', 'R3', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R3-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Um faz tudo sozinho$q$, false, 'erro_indicacao', $q$Lento.$q$),
  (2, $q$Sem liderança definida$q$, false, 'erro_conduta', $q$Desorganiza.$q$),
  (3, $q$Todos fazem tudo$q$, false, 'erro_conceitual', $q$Desorganiza.$q$),
  (4, $q$Esperar o assistente$q$, false, 'erro_tecnico', $q$Atrasa.$q$),
  (5, $q$Funções definidas pelo líder antes da chegada$q$, true, NULL, $q$Correta: boa parte da avaliação é simultânea com funções distribuídas.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, qual o maior determinante do desfecho?$q$ OR i.ancora IS DISTINCT FROM 'D26' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O número de exames|Não.#A idade isolada|Não isoladamente.#O horário da chegada|Não.#A alteração fisiológica|Correta.#O mecanismo isolado|Não isoladamente.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, qual o maior determinante do desfecho?$q$, dificuldade=4, ancora='D26', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, qual o maior determinante do desfecho?$q$, 4, 'D26', 'T3-R3-4', 'R3', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R3-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O número de exames$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$A idade isolada$q$, false, 'erro_conceitual', $q$Não isoladamente.$q$),
  (3, $q$O horário da chegada$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$A alteração fisiológica$q$, true, NULL, $q$Correta.$q$),
  (5, $q$O mecanismo isolado$q$, false, 'erro_indicacao', $q$Não isoladamente.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, após a TC, quem deve fazer a avaliação terciária e quando?$q$ OR i.ancora IS DISTINCT FROM 'D31, A42' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Antes da primária|Ordem errada.#Só na alta|Tarde demais.#Ninguém, a TC basta|Lesões tardias ocorrem mesmo com TC.#Só se houver queixa|Pacientes intubados não se queixam.#A equipe, depois de concluídas a ressuscitação inicial e as intervenções|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, após a TC, quem deve fazer a avaliação terciária e quando?$q$, dificuldade=5, ancora='D31, A42', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, após a TC, quem deve fazer a avaliação terciária e quando?$q$, 5, 'D31, A42', 'T3-R3-5', 'R3', 3, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R3-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Antes da primária$q$, false, 'erro_tecnico', $q$Ordem errada.$q$),
  (2, $q$Só na alta$q$, false, 'erro_indicacao', $q$Tarde demais.$q$),
  (3, $q$Ninguém, a TC basta$q$, false, 'erro_conceitual', $q$Lesões tardias ocorrem mesmo com TC.$q$),
  (4, $q$Só se houver queixa$q$, false, 'erro_conduta', $q$Pacientes intubados não se queixam.$q$),
  (5, $q$A equipe, depois de concluídas a ressuscitação inicial e as intervenções$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, o paciente intubado tem a perna esquerda edemaciada e o teste clínico SILENT é negativo. Como agir?$q$ OR i.ancora IS DISTINCT FROM 'A43, D25' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Indicar fasciotomia imediata|Não há indicação com os dados do caso.#Não excluir lesão: o SILENT tem sensibilidade de 75%; investigar com imagem|Correta: bom para confirmar, insuficiente para excluir.#Repetir o SILENT até ficar positivo|Repetir o teste não muda seu desempenho.#Excluir lesão, porque a especificidade é 99%|A especificidade alta serve para confirmar, não para excluir.#Ignorar o edema|Achado positivo de exame exige ação.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, o paciente intubado tem a perna esquerda edemaciada e o teste clínico SILENT é negativo. Como agir?$q$, dificuldade=5, ancora='A43, D25', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R3-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, o paciente intubado tem a perna esquerda edemaciada e o teste clínico SILENT é negativo. Como agir?$q$, 5, 'A43, D25', 'T3-R3-6', 'R3', 3, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R3-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R3-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Indicar fasciotomia imediata$q$, false, 'erro_indicacao', $q$Não há indicação com os dados do caso.$q$),
  (2, $q$Não excluir lesão: o SILENT tem sensibilidade de 75%; investigar com imagem$q$, true, NULL, $q$Correta: bom para confirmar, insuficiente para excluir.$q$),
  (3, $q$Repetir o SILENT até ficar positivo$q$, false, 'erro_tecnico', $q$Repetir o teste não muda seu desempenho.$q$),
  (4, $q$Excluir lesão, porque a especificidade é 99%$q$, false, 'erro_conceitual', $q$A especificidade alta serve para confirmar, não para excluir.$q$),
  (5, $q$Ignorar o edema$q$, false, 'erro_conduta', $q$Achado positivo de exame exige ação.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, ao ensinar sobre classes de choque, qual crítica metodológica deve ser apresentada?$q$ OR i.ancora IS DISTINCT FROM 'A32' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A tabela foi validada sem limitações|Há limitações.#A comparação clássica com o déficit de base teve viés que superestimou a classe pelos parâmetros tradicionais|Correta.#O déficit de base nunca foi estudado|Foi estudado.#Não há críticas publicadas|Há.#A classe de choque é definida pela idade|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, ao ensinar sobre classes de choque, qual crítica metodológica deve ser apresentada?$q$, dificuldade=4, ancora='A32', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, ao ensinar sobre classes de choque, qual crítica metodológica deve ser apresentada?$q$, 4, 'A32', 'T3-R+-1', 'R+', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R+-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A tabela foi validada sem limitações$q$, false, 'erro_conceitual', $q$Há limitações.$q$),
  (2, $q$A comparação clássica com o déficit de base teve viés que superestimou a classe pelos parâmetros tradicionais$q$, true, NULL, $q$Correta.$q$),
  (3, $q$O déficit de base nunca foi estudado$q$, false, 'erro_indicacao', $q$Foi estudado.$q$),
  (4, $q$Não há críticas publicadas$q$, false, 'erro_conduta', $q$Há.$q$),
  (5, $q$A classe de choque é definida pela idade$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, um residente diz que o paciente está 'hemodinamicamente estável' porque a PA do aparelho automático é normal. Como corrigir o raciocínio?$q$ OR i.ancora IS DISTINCT FROM 'A33, D14' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Estabilidade não tem definição consensual; descrever os parâmetros e a resposta, e medir a PA manualmente|Correta: foi definida em 70% dos artigos, sem consenso nos cortes; e o aparelho automático pode errar no choque.#Confiar no aparelho automático no choque|Pode errar no choque.#Encerrar a reposição|FC 118 e pele fria sugerem choque.#Concordar: PA normal define estabilidade|Não há definição única.#Usar só a FC para decidir|Parâmetro isolado não basta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, um residente diz que o paciente está 'hemodinamicamente estável' porque a PA do aparelho automático é normal. Como corrigir o raciocínio?$q$, dificuldade=4, ancora='A33, D14', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, um residente diz que o paciente está 'hemodinamicamente estável' porque a PA do aparelho automático é normal. Como corrigir o raciocínio?$q$, 4, 'A33, D14', 'T3-R+-2', 'R+', 3, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R+-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Estabilidade não tem definição consensual; descrever os parâmetros e a resposta, e medir a PA manualmente$q$, true, NULL, $q$Correta: foi definida em 70% dos artigos, sem consenso nos cortes; e o aparelho automático pode errar no choque.$q$),
  (2, $q$Confiar no aparelho automático no choque$q$, false, 'erro_tecnico', $q$Pode errar no choque.$q$),
  (3, $q$Encerrar a reposição$q$, false, 'erro_conduta', $q$FC 118 e pele fria sugerem choque.$q$),
  (4, $q$Concordar: PA normal define estabilidade$q$, false, 'erro_conceitual', $q$Não há definição única.$q$),
  (5, $q$Usar só a FC para decidir$q$, false, 'erro_indicacao', $q$Parâmetro isolado não basta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, você audita o serviço. Qual indicador de processo é mais coerente com as lacunas do tema?$q$ OR i.ancora IS DISTINCT FROM 'A36, A37' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Tempo de alta hospitalar|Não mede a lacuna.#Número de TCs por mês|Não mede a lacuna.#Custo do material|Não mede a lacuna.#Número de residentes|Não mede a lacuna.#Temperatura medida na admissão|Correta: a hipotermia é frequente, subvalorizada e sem manejo baseado em evidência.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, você audita o serviço. Qual indicador de processo é mais coerente com as lacunas do tema?$q$, dificuldade=5, ancora='A36, A37', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, você audita o serviço. Qual indicador de processo é mais coerente com as lacunas do tema?$q$, 5, 'A36, A37', 'T3-R+-3', 'R+', 3, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R+-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Tempo de alta hospitalar$q$, false, 'erro_indicacao', $q$Não mede a lacuna.$q$),
  (2, $q$Número de TCs por mês$q$, false, 'erro_conceitual', $q$Não mede a lacuna.$q$),
  (3, $q$Custo do material$q$, false, 'erro_tecnico', $q$Não mede a lacuna.$q$),
  (4, $q$Número de residentes$q$, false, 'erro_conduta', $q$Não mede a lacuna.$q$),
  (5, $q$Temperatura medida na admissão$q$, true, NULL, $q$Correta: a hipotermia é frequente, subvalorizada e sem manejo baseado em evidência.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, ao discutir lesões não identificadas, qual a melhor estratégia institucional baseada nas fontes?$q$ OR i.ancora IS DISTINCT FROM 'D30, A41, A42' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Restringir o exame físico|O exame tem valor.#Avaliação terciária com revisão de imagens e vigilância depois dela|Correta.#Nada a fazer|Há estratégia.#Alta precoce|Aumenta o risco.#Mais TCs de rotina|A TC de rotina não eliminou lesões tardias.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, ao discutir lesões não identificadas, qual a melhor estratégia institucional baseada nas fontes?$q$, dificuldade=5, ancora='D30, A41, A42', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, ao discutir lesões não identificadas, qual a melhor estratégia institucional baseada nas fontes?$q$, 5, 'D30, A41, A42', 'T3-R+-4', 'R+', 3, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R+-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Restringir o exame físico$q$, false, 'erro_tecnico', $q$O exame tem valor.$q$),
  (2, $q$Avaliação terciária com revisão de imagens e vigilância depois dela$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Nada a fazer$q$, false, 'erro_conduta', $q$Há estratégia.$q$),
  (4, $q$Alta precoce$q$, false, 'erro_indicacao', $q$Aumenta o risco.$q$),
  (5, $q$Mais TCs de rotina$q$, false, 'erro_conceitual', $q$A TC de rotina não eliminou lesões tardias.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, qual a interpretação correta de 'achados positivos no exame físico quase sempre indicam lesão grave'?$q$ OR i.ancora IS DISTINCT FROM 'D25' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O exame normal exclui lesão|Baixo valor preditivo negativo.#Achados positivos exigem ação, mesmo que o exame normal não exclua lesão|Correta.#Só vale com TC|Vale por si.#O exame não tem valor|Tem valor.#Só vale para o tórax|Vale em geral.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, qual a interpretação correta de 'achados positivos no exame físico quase sempre indicam lesão grave'?$q$, dificuldade=6, ancora='D25', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, qual a interpretação correta de 'achados positivos no exame físico quase sempre indicam lesão grave'?$q$, 6, 'D25', 'T3-R+-5', 'R+', 3, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R+-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O exame normal exclui lesão$q$, false, 'erro_conceitual', $q$Baixo valor preditivo negativo.$q$),
  (2, $q$Achados positivos exigem ação, mesmo que o exame normal não exclua lesão$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Só vale com TC$q$, false, 'erro_conduta', $q$Vale por si.$q$),
  (4, $q$O exame não tem valor$q$, false, 'erro_indicacao', $q$Tem valor.$q$),
  (5, $q$Só vale para o tórax$q$, false, 'erro_tecnico', $q$Vale em geral.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 3, ao revisar o protocolo, o que justificaria manter o aquecimento ativo como item obrigatório, apesar da falta de evidência de manejo?$q$ OR i.ancora IS DISTINCT FROM 'A36, A37, D19' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhuma razão|Há razões.#Ensaio randomizado definitivo|Não existe.#A frequência alta e a subvalorização da hipotermia, e a recomendação da doutrina de aquecer|Correta.#Mortalidade comprovadamente reduzida|Não há essa comprovação.#Custo zero comprovado|Não é o argumento.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 3, ao revisar o protocolo, o que justificaria manter o aquecimento ativo como item obrigatório, apesar da falta de evidência de manejo?$q$, dificuldade=6, ancora='A36, A37, D19', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T3-R+-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 3, ao revisar o protocolo, o que justificaria manter o aquecimento ativo como item obrigatório, apesar da falta de evidência de manejo?$q$, 6, 'A36, A37, D19', 'T3-R+-6', 'R+', 3, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T3-R+-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T3-R+-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhuma razão$q$, false, 'erro_indicacao', $q$Há razões.$q$),
  (2, $q$Ensaio randomizado definitivo$q$, false, 'erro_conceitual', $q$Não existe.$q$),
  (3, $q$A frequência alta e a subvalorização da hipotermia, e a recomendação da doutrina de aquecer$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Mortalidade comprovadamente reduzida$q$, false, 'erro_conduta', $q$Não há essa comprovação.$q$),
  (5, $q$Custo zero comprovado$q$, false, 'erro_tecnico', $q$Não é o argumento.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o paciente está em choque grave. Qual a ordem da avaliação?$q$ OR i.ancora IS DISTINCT FROM 'D3' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Primeiro a história AMPLA|O AMPLA é da secundária.#Primeiro a TC|A TC não vem antes.#Primeiro a radiografia|Exame de imagem não vem antes.#Exposição antes de tudo|A exposição não precede a circulação.#A circulação tem precedência (CABDE)|Correta: no paciente em extremis, a circulação vem primeiro.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o paciente está em choque grave. Qual a ordem da avaliação?$q$, dificuldade=2, ancora='D3', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o paciente está em choque grave. Qual a ordem da avaliação?$q$, 2, 'D3', 'T4-Graduação-1', 'graduacao', 4, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-Graduação-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Primeiro a história AMPLA$q$, false, 'erro_conceitual', $q$O AMPLA é da secundária.$q$),
  (2, $q$Primeiro a TC$q$, false, 'erro_conduta', $q$A TC não vem antes.$q$),
  (3, $q$Primeiro a radiografia$q$, false, 'erro_tecnico', $q$Exame de imagem não vem antes.$q$),
  (4, $q$Exposição antes de tudo$q$, false, 'erro_indicacao', $q$A exposição não precede a circulação.$q$),
  (5, $q$A circulação tem precedência (CABDE)$q$, true, NULL, $q$Correta: no paciente em extremis, a circulação vem primeiro.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, há dor na bacia e choque. O que colocar imediatamente?$q$ OR i.ancora IS DISTINCT FROM 'D9' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nada até a TC|Esperar atrasa o controle.#Sonda vesical|Não é a prioridade.#Cinta pélvica|Correta: no alto risco, a cinta pélvica vai imediatamente.#Colar cervical apenas|Não trata o sangramento pélvico.#Torniquete na coxa|Não há sangramento de membro.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, há dor na bacia e choque. O que colocar imediatamente?$q$, dificuldade=2, ancora='D9', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, há dor na bacia e choque. O que colocar imediatamente?$q$, 2, 'D9', 'T4-Graduação-2', 'graduacao', 4, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-Graduação-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nada até a TC$q$, false, 'erro_conduta', $q$Esperar atrasa o controle.$q$),
  (2, $q$Sonda vesical$q$, false, 'erro_tecnico', $q$Não é a prioridade.$q$),
  (3, $q$Cinta pélvica$q$, true, NULL, $q$Correta: no alto risco, a cinta pélvica vai imediatamente.$q$),
  (4, $q$Colar cervical apenas$q$, false, 'erro_conceitual', $q$Não trata o sangramento pélvico.$q$),
  (5, $q$Torniquete na coxa$q$, false, 'erro_indicacao', $q$Não há sangramento de membro.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, as veias falharam. Qual acesso usar?$q$ OR i.ancora IS DISTINCT FROM 'D15, D28' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Intraósseo|Correta.#Nenhum até a TC|Atrasa a ressuscitação.#Intramuscular|Não serve para ressuscitação.#Continuar tentando veia por muito tempo|Atrasa.#Oral|Não serve.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, as veias falharam. Qual acesso usar?$q$, dificuldade=3, ancora='D15, D28', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, as veias falharam. Qual acesso usar?$q$, 3, 'D15, D28', 'T4-Graduação-3', 'graduacao', 4, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-Graduação-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Intraósseo$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Nenhum até a TC$q$, false, 'erro_conduta', $q$Atrasa a ressuscitação.$q$),
  (3, $q$Intramuscular$q$, false, 'erro_indicacao', $q$Não serve para ressuscitação.$q$),
  (4, $q$Continuar tentando veia por muito tempo$q$, false, 'erro_tecnico', $q$Atrasa.$q$),
  (5, $q$Oral$q$, false, 'erro_conceitual', $q$Não serve.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o paciente sonolento e pálido. A sonolência pode ser sinal de quê?$q$ OR i.ancora IS DISTINCT FROM 'D17, D26' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nada|Não.#Só álcool|Não deve ser presumido.#Choque|Correta: alteração do nível de consciência acompanha o choque grave.#Boa evolução|Não.#Só cansaço|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o paciente sonolento e pálido. A sonolência pode ser sinal de quê?$q$, dificuldade=3, ancora='D17, D26', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o paciente sonolento e pálido. A sonolência pode ser sinal de quê?$q$, 3, 'D17, D26', 'T4-Graduação-4', 'graduacao', 4, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-Graduação-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nada$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$Só álcool$q$, false, 'erro_indicacao', $q$Não deve ser presumido.$q$),
  (3, $q$Choque$q$, true, NULL, $q$Correta: alteração do nível de consciência acompanha o choque grave.$q$),
  (4, $q$Boa evolução$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$Só cansaço$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o que mais define o prognóstico deste paciente?$q$ OR i.ancora IS DISTINCT FROM 'D26' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O número de exames|Não.#A idade|Não isoladamente.#A alteração fisiológica|Correta.#A marca da moto|Irrelevante.#O horário|Irrelevante.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o que mais define o prognóstico deste paciente?$q$, dificuldade=4, ancora='D26', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o que mais define o prognóstico deste paciente?$q$, 4, 'D26', 'T4-Graduação-5', 'graduacao', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-Graduação-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O número de exames$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$A idade$q$, false, 'erro_indicacao', $q$Não isoladamente.$q$),
  (3, $q$A alteração fisiológica$q$, true, NULL, $q$Correta.$q$),
  (4, $q$A marca da moto$q$, false, 'erro_conceitual', $q$Irrelevante.$q$),
  (5, $q$O horário$q$, false, 'erro_tecnico', $q$Irrelevante.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, a PA foi medida manualmente. Por quê?$q$ OR i.ancora IS DISTINCT FROM 'D14' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Por tradição|Há motivo.#Porque o automático não existe|Não.#Porque o aparelho automático pode errar no choque|Correta.#Sem motivo|Há motivo.#Porque é mais rápido|Não é o motivo.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, a PA foi medida manualmente. Por quê?$q$, dificuldade=4, ancora='D14', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, a PA foi medida manualmente. Por quê?$q$, 4, 'D14', 'T4-Graduação-6', 'graduacao', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-Graduação-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-Graduação-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Por tradição$q$, false, 'erro_indicacao', $q$Há motivo.$q$),
  (2, $q$Porque o automático não existe$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Porque o aparelho automático pode errar no choque$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Sem motivo$q$, false, 'erro_conduta', $q$Há motivo.$q$),
  (5, $q$Porque é mais rápido$q$, false, 'erro_conceitual', $q$Não é o motivo.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, ao colocar a cinta pélvica, o que a doutrina recomenda?$q$ OR i.ancora IS DISTINCT FROM 'D9' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Colocá-la imediatamente nos pacientes de alto risco|Correta.#Não usar no choque|É justamente indicada.#Colocar só no centro cirúrgico|Atraso.#Testar a bacia repetidamente antes|Não controla o sangramento e atrasa.#Esperar a radiografia|Atraso.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, ao colocar a cinta pélvica, o que a doutrina recomenda?$q$, dificuldade=2, ancora='D9', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, ao colocar a cinta pélvica, o que a doutrina recomenda?$q$, 2, 'D9', 'T4-R1-1', 'R1', 4, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R1-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Colocá-la imediatamente nos pacientes de alto risco$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Não usar no choque$q$, false, 'erro_conceitual', $q$É justamente indicada.$q$),
  (3, $q$Colocar só no centro cirúrgico$q$, false, 'erro_indicacao', $q$Atraso.$q$),
  (4, $q$Testar a bacia repetidamente antes$q$, false, 'erro_tecnico', $q$Não controla o sangramento e atrasa.$q$),
  (5, $q$Esperar a radiografia$q$, false, 'erro_conduta', $q$Atraso.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, qual exame à beira-leito ajuda a buscar sangramento cavitário?$q$ OR i.ancora IS DISTINCT FROM 'A34, A35' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum|Há adjuntos.#TC antes de qualquer conduta|Transportar paciente instável é arriscado.#Ultrassom (FAST)|Correta: adjunto para buscar sangramento intracavitário.#Ressonância|Não é exame de emergência.#Endoscopia|Não se aplica.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, qual exame à beira-leito ajuda a buscar sangramento cavitário?$q$, dificuldade=2, ancora='A34, A35', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, qual exame à beira-leito ajuda a buscar sangramento cavitário?$q$, 2, 'A34, A35', 'T4-R1-2', 'R1', 4, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R1-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum$q$, false, 'erro_conceitual', $q$Há adjuntos.$q$),
  (2, $q$TC antes de qualquer conduta$q$, false, 'erro_conduta', $q$Transportar paciente instável é arriscado.$q$),
  (3, $q$Ultrassom (FAST)$q$, true, NULL, $q$Correta: adjunto para buscar sangramento intracavitário.$q$),
  (4, $q$Ressonância$q$, false, 'erro_tecnico', $q$Não é exame de emergência.$q$),
  (5, $q$Endoscopia$q$, false, 'erro_indicacao', $q$Não se aplica.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, qual a mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência?$q$ OR i.ancora IS DISTINCT FROM 'D27' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Abaixo de 5%|Muito abaixo.#Não há dados|Há dados.#Cerca de 10%|Abaixo.#Acima de 40%|Correta.#Zero|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, qual a mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência?$q$, dificuldade=3, ancora='D27', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, qual a mortalidade dos pacientes com PAS abaixo de 90 mmHg que precisam de laparotomia de emergência?$q$, 3, 'D27', 'T4-R1-3', 'R1', 4, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R1-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Abaixo de 5%$q$, false, 'erro_conceitual', $q$Muito abaixo.$q$),
  (2, $q$Não há dados$q$, false, 'erro_conduta', $q$Há dados.$q$),
  (3, $q$Cerca de 10%$q$, false, 'erro_indicacao', $q$Abaixo.$q$),
  (4, $q$Acima de 40%$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Zero$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o intraósseo foi obtido. Qual o papel dele?$q$ OR i.ancora IS DISTINCT FROM 'D28' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só para medicação de parada|Não só.#Não serve no adulto|Serve.#Só para colher exames|Não só.#Só depois da TC|Atraso.#Iniciar a ressuscitação; pode salvar vidas no choque|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o intraósseo foi obtido. Qual o papel dele?$q$, dificuldade=3, ancora='D28', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o intraósseo foi obtido. Qual o papel dele?$q$, 3, 'D28', 'T4-R1-4', 'R1', 4, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R1-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só para medicação de parada$q$, false, 'erro_indicacao', $q$Não só.$q$),
  (2, $q$Não serve no adulto$q$, false, 'erro_tecnico', $q$Serve.$q$),
  (3, $q$Só para colher exames$q$, false, 'erro_conceitual', $q$Não só.$q$),
  (4, $q$Só depois da TC$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (5, $q$Iniciar a ressuscitação; pode salvar vidas no choque$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o ultrassom à beira-leito mostra afastamento da sínfise púbica. O que fazer?$q$ OR i.ancora IS DISTINCT FROM 'D9, A35' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Ignorar: o ultrassom não avalia a bacia|O FAST-PLUS avalia a sínfise.#Aguardar a TC para colocar a cinta|Atraso no controle do sangramento.#Manter a cinta pélvica e tratar como sangramento pélvico|Correta: o ultrassom detectou alargamento crítico confirmado na TC, e a cinta vai já no alto risco.#Retirar a cinta para radiografar|Retirar expõe a novo sangramento.#Laparotomia imediata para tratar a bacia|Laparotomia não trata o sangramento pélvico.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o ultrassom à beira-leito mostra afastamento da sínfise púbica. O que fazer?$q$, dificuldade=4, ancora='D9, A35', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o ultrassom à beira-leito mostra afastamento da sínfise púbica. O que fazer?$q$, 4, 'D9, A35', 'T4-R1-5', 'R1', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R1-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Ignorar: o ultrassom não avalia a bacia$q$, false, 'erro_conceitual', $q$O FAST-PLUS avalia a sínfise.$q$),
  (2, $q$Aguardar a TC para colocar a cinta$q$, false, 'erro_conduta', $q$Atraso no controle do sangramento.$q$),
  (3, $q$Manter a cinta pélvica e tratar como sangramento pélvico$q$, true, NULL, $q$Correta: o ultrassom detectou alargamento crítico confirmado na TC, e a cinta vai já no alto risco.$q$),
  (4, $q$Retirar a cinta para radiografar$q$, false, 'erro_tecnico', $q$Retirar expõe a novo sangramento.$q$),
  (5, $q$Laparotomia imediata para tratar a bacia$q$, false, 'erro_indicacao', $q$Laparotomia não trata o sangramento pélvico.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, um colega quer levar o paciente para a TC antes de qualquer resposta à reposição. O que considerar?$q$ OR i.ancora IS DISTINCT FROM 'D26, A39, D22' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$TC sempre primeiro|Arriscado.#Não importa|Importa.#Esperar 2 horas|Atraso.#A decisão depende da resposta à ressuscitação; paciente sem resposta não deve sair para a TC sem decisão do líder|Correta.#Alta da sala|Inadequado.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, um colega quer levar o paciente para a TC antes de qualquer resposta à reposição. O que considerar?$q$, dificuldade=4, ancora='D26, A39, D22', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R1-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, um colega quer levar o paciente para a TC antes de qualquer resposta à reposição. O que considerar?$q$, 4, 'D26, A39, D22', 'T4-R1-6', 'R1', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R1-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R1-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$TC sempre primeiro$q$, false, 'erro_conduta', $q$Arriscado.$q$),
  (2, $q$Não importa$q$, false, 'erro_conceitual', $q$Importa.$q$),
  (3, $q$Esperar 2 horas$q$, false, 'erro_tecnico', $q$Atraso.$q$),
  (4, $q$A decisão depende da resposta à ressuscitação; paciente sem resposta não deve sair para a TC sem decisão do líder$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Alta da sala$q$, false, 'erro_indicacao', $q$Inadequado.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, você faz o protocolo RUSH à beira-leito. Para que ele serve neste paciente?$q$ OR i.ancora IS DISTINCT FROM 'A34' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Substituir o controle do sangramento|Diagnóstico não substitui tratamento.#Deve ser feito dentro da TC|É exame de beira-leito.#Buscar a causa do choque sem sair da sala|Correta: teve sensibilidade de 94,2% no politraumatizado instável.#Definir a classe de choque pela tabela|Não é essa a função.#Só serve para pacientes estáveis|Foi estudado justamente no instável.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, você faz o protocolo RUSH à beira-leito. Para que ele serve neste paciente?$q$, dificuldade=3, ancora='A34', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, você faz o protocolo RUSH à beira-leito. Para que ele serve neste paciente?$q$, 3, 'A34', 'T4-R2-1', 'R2', 4, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R2-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Substituir o controle do sangramento$q$, false, 'erro_conduta', $q$Diagnóstico não substitui tratamento.$q$),
  (2, $q$Deve ser feito dentro da TC$q$, false, 'erro_tecnico', $q$É exame de beira-leito.$q$),
  (3, $q$Buscar a causa do choque sem sair da sala$q$, true, NULL, $q$Correta: teve sensibilidade de 94,2% no politraumatizado instável.$q$),
  (4, $q$Definir a classe de choque pela tabela$q$, false, 'erro_conceitual', $q$Não é essa a função.$q$),
  (5, $q$Só serve para pacientes estáveis$q$, false, 'erro_indicacao', $q$Foi estudado justamente no instável.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, após a cinta e a reposição, a PA segue 80/50. Qual a decisão mais adequada?$q$ OR i.ancora IS DISTINCT FROM 'D26, D27' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Suspender a reposição|Erro de conduta.#Dar alta para a enfermaria|Inadequado.#Controle do sangramento (centro cirúrgico ou radiologia intervencionista), conforme a fonte|Correta: sem resposta, a prioridade é controlar o sangramento.#Observar na sala|Atraso.#TC de corpo inteiro e aguardar|Atraso no instável sem resposta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, após a cinta e a reposição, a PA segue 80/50. Qual a decisão mais adequada?$q$, dificuldade=3, ancora='D26, D27', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, após a cinta e a reposição, a PA segue 80/50. Qual a decisão mais adequada?$q$, 3, 'D26, D27', 'T4-R2-2', 'R2', 4, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R2-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Suspender a reposição$q$, false, 'erro_conceitual', $q$Erro de conduta.$q$),
  (2, $q$Dar alta para a enfermaria$q$, false, 'erro_indicacao', $q$Inadequado.$q$),
  (3, $q$Controle do sangramento (centro cirúrgico ou radiologia intervencionista), conforme a fonte$q$, true, NULL, $q$Correta: sem resposta, a prioridade é controlar o sangramento.$q$),
  (4, $q$Observar na sala$q$, false, 'erro_tecnico', $q$Atraso.$q$),
  (5, $q$TC de corpo inteiro e aguardar$q$, false, 'erro_conduta', $q$Atraso no instável sem resposta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o FAST não mostra líquido livre e há suspeita de sangramento pélvico ativo. Qual o próximo passo mais adequado?$q$ OR i.ancora IS DISTINCT FROM 'A22, D9' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Retirar a cinta para examinar a bacia|Expõe a novo sangramento.#Esperar o resultado do lactato|Atraso.#Acionar cirurgia e radiologia intervencionista juntas|Correta: a colaboração próxima associou-se a sobrevida 15,5% maior que a prevista.#Concluir que o FAST negativo exclui sangramento|Não exclui sangramento retroperitoneal ou pélvico.#Laparotomia exploradora de rotina|Não trata o sangramento pélvico.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o FAST não mostra líquido livre e há suspeita de sangramento pélvico ativo. Qual o próximo passo mais adequado?$q$, dificuldade=4, ancora='A22, D9', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o FAST não mostra líquido livre e há suspeita de sangramento pélvico ativo. Qual o próximo passo mais adequado?$q$, 4, 'A22, D9', 'T4-R2-3', 'R2', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R2-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Retirar a cinta para examinar a bacia$q$, false, 'erro_tecnico', $q$Expõe a novo sangramento.$q$),
  (2, $q$Esperar o resultado do lactato$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (3, $q$Acionar cirurgia e radiologia intervencionista juntas$q$, true, NULL, $q$Correta: a colaboração próxima associou-se a sobrevida 15,5% maior que a prevista.$q$),
  (4, $q$Concluir que o FAST negativo exclui sangramento$q$, false, 'erro_conceitual', $q$Não exclui sangramento retroperitoneal ou pélvico.$q$),
  (5, $q$Laparotomia exploradora de rotina$q$, false, 'erro_indicacao', $q$Não trata o sangramento pélvico.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, a FC 136 e a PA baixa. O que dizer da tabela de classes de choque?$q$ OR i.ancora IS DISTINCT FROM 'A32, D17' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Perfeitamente validada|Teve viés.#Só vale no idoso|Não.#Define a conduta sozinha|Não deve decidir sozinha.#Inútil|Tem utilidade com limites.#Útil como referência, mas com limitações metodológicas; não decidir por ela sozinha|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, a FC 136 e a PA baixa. O que dizer da tabela de classes de choque?$q$, dificuldade=4, ancora='A32, D17', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, a FC 136 e a PA baixa. O que dizer da tabela de classes de choque?$q$, 4, 'A32, D17', 'T4-R2-4', 'R2', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R2-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Perfeitamente validada$q$, false, 'erro_conceitual', $q$Teve viés.$q$),
  (2, $q$Só vale no idoso$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Define a conduta sozinha$q$, false, 'erro_indicacao', $q$Não deve decidir sozinha.$q$),
  (4, $q$Inútil$q$, false, 'erro_conduta', $q$Tem utilidade com limites.$q$),
  (5, $q$Útil como referência, mas com limitações metodológicas; não decidir por ela sozinha$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, o FAST-PLUS teve qual concordância com a TC para alargamento crítico da sínfise?$q$ OR i.ancora IS DISTINCT FROM 'A35' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum confirmado|Não.#Metade confirmada|Não.#Todos os casos confirmados na TC|Correta.#Não foi comparado|Foi comparado.#Só 10% confirmados|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, o FAST-PLUS teve qual concordância com a TC para alargamento crítico da sínfise?$q$, dificuldade=5, ancora='A35', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, o FAST-PLUS teve qual concordância com a TC para alargamento crítico da sínfise?$q$, 5, 'A35', 'T4-R2-5', 'R2', 4, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R2-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum confirmado$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Metade confirmada$q$, false, 'erro_indicacao', $q$Não.$q$),
  (3, $q$Todos os casos confirmados na TC$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Não foi comparado$q$, false, 'erro_tecnico', $q$Foi comparado.$q$),
  (5, $q$Só 10% confirmados$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, por que não pinçar às cegas um sangramento profundo encontrado durante o exame?$q$ OR i.ancora IS DISTINCT FROM 'D8' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Porque é sempre ineficaz|Não é o motivo descrito.#Porque atrasa a TC|Não é o motivo.#Não há motivo|Há motivo.#Risco de lesar nervos e criar novo trauma e sangramento|Correta.#Porque é proibido por lei|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, por que não pinçar às cegas um sangramento profundo encontrado durante o exame?$q$, dificuldade=5, ancora='D8', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R2-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, por que não pinçar às cegas um sangramento profundo encontrado durante o exame?$q$, 5, 'D8', 'T4-R2-6', 'R2', 4, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R2-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R2-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Porque é sempre ineficaz$q$, false, 'erro_conceitual', $q$Não é o motivo descrito.$q$),
  (2, $q$Porque atrasa a TC$q$, false, 'erro_tecnico', $q$Não é o motivo.$q$),
  (3, $q$Não há motivo$q$, false, 'erro_conduta', $q$Há motivo.$q$),
  (4, $q$Risco de lesar nervos e criar novo trauma e sangramento$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Porque é proibido por lei$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, quem deve liderar e como?$q$ OR i.ancora IS DISTINCT FROM 'D22, D3' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O cirurgião do trauma, com participação ativa, dada a gravidade|Correta: no extremis, os mais experientes participam ativamente.#Ninguém em particular|Desorganiza.#O radiologista|Não.#Um residente sem supervisão|Não sem supervisão.#O SAMU|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, quem deve liderar e como?$q$, dificuldade=4, ancora='D22, D3', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, quem deve liderar e como?$q$, 4, 'D22, D3', 'T4-R3-1', 'R3', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R3-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O cirurgião do trauma, com participação ativa, dada a gravidade$q$, true, NULL, $q$Correta: no extremis, os mais experientes participam ativamente.$q$),
  (2, $q$Ninguém em particular$q$, false, 'erro_conceitual', $q$Desorganiza.$q$),
  (3, $q$O radiologista$q$, false, 'erro_tecnico', $q$Não.$q$),
  (4, $q$Um residente sem supervisão$q$, false, 'erro_conduta', $q$Não sem supervisão.$q$),
  (5, $q$O SAMU$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, quais as opções para controlar o sangramento pélvico e abdominal?$q$ OR i.ancora IS DISTINCT FROM 'A22, D27' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só observação|Não.#Só TC|Não controla.#Alta|Não.#Só reposição|Não controla.#Centro cirúrgico ou radiologia intervencionista, conforme a fonte|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, quais as opções para controlar o sangramento pélvico e abdominal?$q$, dificuldade=4, ancora='A22, D27', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, quais as opções para controlar o sangramento pélvico e abdominal?$q$, 4, 'A22, D27', 'T4-R3-2', 'R3', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R3-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só observação$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Só TC$q$, false, 'erro_tecnico', $q$Não controla.$q$),
  (3, $q$Alta$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Só reposição$q$, false, 'erro_indicacao', $q$Não controla.$q$),
  (5, $q$Centro cirúrgico ou radiologia intervencionista, conforme a fonte$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, qual o papel da TC de corpo inteiro neste paciente sem resposta à reposição?$q$ OR i.ancora IS DISTINCT FROM 'A12, D26' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não é prioridade antes do controle do sangramento|Correta: a TC de rotina não mostrou efeito em mortalidade e o paciente não respondeu.#Substitui o FAST|Não.#Reduz a mortalidade comprovadamente|Não comprovado.#Obrigatória antes da cirurgia|Atraso.#Deve ser repetida a cada hora|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, qual o papel da TC de corpo inteiro neste paciente sem resposta à reposição?$q$, dificuldade=5, ancora='A12, D26', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, qual o papel da TC de corpo inteiro neste paciente sem resposta à reposição?$q$, 5, 'A12, D26', 'T4-R3-3', 'R3', 4, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R3-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não é prioridade antes do controle do sangramento$q$, true, NULL, $q$Correta: a TC de rotina não mostrou efeito em mortalidade e o paciente não respondeu.$q$),
  (2, $q$Substitui o FAST$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Reduz a mortalidade comprovadamente$q$, false, 'erro_conceitual', $q$Não comprovado.$q$),
  (4, $q$Obrigatória antes da cirurgia$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (5, $q$Deve ser repetida a cada hora$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, na equipe, como organizar os procedimentos simultâneos?$q$ OR i.ancora IS DISTINCT FROM 'D22, D5' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sem organização|Não.#O líder define antes quem faz cada procedimento|Correta.#Cada um escolhe na hora|Desorganiza.#Esperar o assistente|Atrasa.#Um só faz todos|Lento.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, na equipe, como organizar os procedimentos simultâneos?$q$, dificuldade=5, ancora='D22, D5', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, na equipe, como organizar os procedimentos simultâneos?$q$, 5, 'D22, D5', 'T4-R3-4', 'R3', 4, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R3-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sem organização$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$O líder define antes quem faz cada procedimento$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Cada um escolhe na hora$q$, false, 'erro_conceitual', $q$Desorganiza.$q$),
  (4, $q$Esperar o assistente$q$, false, 'erro_tecnico', $q$Atrasa.$q$),
  (5, $q$Um só faz todos$q$, false, 'erro_indicacao', $q$Lento.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, após cirurgia, o paciente volta hipotenso na UTI. Como pensar?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Esperar a manhã|Atraso.#Só fratura de fêmur|Armadilha descrita.#Efeito da anestesia apenas|Armadilha.#Sangramento até prova em contrário; investigar lesão não identificada|Correta.#Normal|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, após cirurgia, o paciente volta hipotenso na UTI. Como pensar?$q$, dificuldade=6, ancora='D32', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, após cirurgia, o paciente volta hipotenso na UTI. Como pensar?$q$, 6, 'D32', 'T4-R3-5', 'R3', 4, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R3-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Esperar a manhã$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (2, $q$Só fratura de fêmur$q$, false, 'erro_tecnico', $q$Armadilha descrita.$q$),
  (3, $q$Efeito da anestesia apenas$q$, false, 'erro_conceitual', $q$Armadilha.$q$),
  (4, $q$Sangramento até prova em contrário; investigar lesão não identificada$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Normal$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, qual a mortalidade a esperar e qual a implicação para a equipe?$q$ OR i.ancora IS DISTINCT FROM 'D27' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Igual à de pacientes estáveis|Não.#Não há dados|Há.#Zero; não há urgência|Não.#Abaixo de 5%; pode esperar|Não.#Acima de 40%; exige os mais experientes e decisão rápida|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, qual a mortalidade a esperar e qual a implicação para a equipe?$q$, dificuldade=6, ancora='D27', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R3-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, qual a mortalidade a esperar e qual a implicação para a equipe?$q$, 6, 'D27', 'T4-R3-6', 'R3', 4, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R3-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R3-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Igual à de pacientes estáveis$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Não há dados$q$, false, 'erro_tecnico', $q$Há.$q$),
  (3, $q$Zero; não há urgência$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Abaixo de 5%; pode esperar$q$, false, 'erro_conceitual', $q$Não.$q$),
  (5, $q$Acima de 40%; exige os mais experientes e decisão rápida$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, ao discutir com residentes a avaliação ultrassonográfica, qual síntese das fontes é correta?$q$ OR i.ancora IS DISTINCT FROM 'A34, A35' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Ultrassom sem utilidade no choque|Não.#Ultrassom substitui a TC sempre|Não.#Sensibilidade de 100% em todos os estudos|Não.#RUSH sensível no instável e FAST-PLUS com alargamento pélvico confirmado na TC|Correta.#Não há estudos|Há.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, ao discutir com residentes a avaliação ultrassonográfica, qual síntese das fontes é correta?$q$, dificuldade=4, ancora='A34, A35', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, ao discutir com residentes a avaliação ultrassonográfica, qual síntese das fontes é correta?$q$, 4, 'A34, A35', 'T4-R+-1', 'R+', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R+-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Ultrassom sem utilidade no choque$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Ultrassom substitui a TC sempre$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Sensibilidade de 100% em todos os estudos$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$RUSH sensível no instável e FAST-PLUS com alargamento pélvico confirmado na TC$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Não há estudos$q$, false, 'erro_tecnico', $q$Há.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, um estudo de colaboração entre cirurgia e radiologia intervencionista mostrou sobrevida maior que a prevista. Como interpretar?$q$ OR i.ancora IS DISTINCT FROM 'A22' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Mostra pior desfecho|Não.#Associação favorável num desenho observacional; apoia a integração, sem provar causa|Correta.#Só vale para trauma penetrante|Não há essa restrição.#Sem relevância|Relevante.#Prova causal definitiva|Desenho não permite.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, um estudo de colaboração entre cirurgia e radiologia intervencionista mostrou sobrevida maior que a prevista. Como interpretar?$q$, dificuldade=4, ancora='A22', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, um estudo de colaboração entre cirurgia e radiologia intervencionista mostrou sobrevida maior que a prevista. Como interpretar?$q$, 4, 'A22', 'T4-R+-2', 'R+', 4, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R+-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Mostra pior desfecho$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Associação favorável num desenho observacional; apoia a integração, sem provar causa$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Só vale para trauma penetrante$q$, false, 'erro_tecnico', $q$Não há essa restrição.$q$),
  (4, $q$Sem relevância$q$, false, 'erro_indicacao', $q$Relevante.$q$),
  (5, $q$Prova causal definitiva$q$, false, 'erro_conceitual', $q$Desenho não permite.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, qual frase resume a doutrina do paciente em extremis?$q$ OR i.ancora IS DISTINCT FROM 'D3, D22' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Esperar estabilizar para decidir|Atraso.#Exposição primeiro|Não.#ABCDE sem exceção|Há exceção.#A via aérea sempre primeiro|Não no extremis.#A circulação tem precedência (CABDE) e os mais experientes conduzem|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, qual frase resume a doutrina do paciente em extremis?$q$, dificuldade=5, ancora='D3, D22', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, qual frase resume a doutrina do paciente em extremis?$q$, 5, 'D3, D22', 'T4-R+-3', 'R+', 4, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R+-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Esperar estabilizar para decidir$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (2, $q$Exposição primeiro$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$ABCDE sem exceção$q$, false, 'erro_conceitual', $q$Há exceção.$q$),
  (4, $q$A via aérea sempre primeiro$q$, false, 'erro_indicacao', $q$Não no extremis.$q$),
  (5, $q$A circulação tem precedência (CABDE) e os mais experientes conduzem$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, você revisa o protocolo. Que indicador captaria atraso neste tipo de paciente?$q$ OR i.ancora IS DISTINCT FROM 'D27, D3' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Número de residentes|Não.#Tempo de internação|Indireto.#Tempo até o controle do sangramento|Correta: ligado à mortalidade acima de 40% e à prioridade da circulação.#Custo da cinta|Não.#Número de radiografias|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, você revisa o protocolo. Que indicador captaria atraso neste tipo de paciente?$q$, dificuldade=5, ancora='D27, D3', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, você revisa o protocolo. Que indicador captaria atraso neste tipo de paciente?$q$, 5, 'D27, D3', 'T4-R+-4', 'R+', 4, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R+-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Número de residentes$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Tempo de internação$q$, false, 'erro_indicacao', $q$Indireto.$q$),
  (3, $q$Tempo até o controle do sangramento$q$, true, NULL, $q$Correta: ligado à mortalidade acima de 40% e à prioridade da circulação.$q$),
  (4, $q$Custo da cinta$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Número de radiografias$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, qual crítica faria a quem decide só pela tabela de classes de choque?$q$ OR i.ancora IS DISTINCT FROM 'A32, A33' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A tabela é perfeita|Não.#A comparação clássica teve viés e não há consenso sobre estabilidade|Correta.#Classes não existem|Não.#Só a FC importa|Não.#Só a PA importa|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, qual crítica faria a quem decide só pela tabela de classes de choque?$q$, dificuldade=6, ancora='A32, A33', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, qual crítica faria a quem decide só pela tabela de classes de choque?$q$, 6, 'A32, A33', 'T4-R+-5', 'R+', 4, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R+-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A tabela é perfeita$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$A comparação clássica teve viés e não há consenso sobre estabilidade$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Classes não existem$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Só a FC importa$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$Só a PA importa$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 4, um residente pergunta sobre o acesso intraósseo no adulto em choque. Qual resposta das fontes?$q$ OR i.ancora IS DISTINCT FROM 'D28, D15' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só para crianças|Não.#Contraindicado no adulto|Não.#Sem papel no trauma|Não.#Pode salvar vidas ao iniciar a ressuscitação quando a veia falha|Correta.#Só para colher sangue|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 4, um residente pergunta sobre o acesso intraósseo no adulto em choque. Qual resposta das fontes?$q$, dificuldade=6, ancora='D28, D15', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T4-R+-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 4, um residente pergunta sobre o acesso intraósseo no adulto em choque. Qual resposta das fontes?$q$, 6, 'D28, D15', 'T4-R+-6', 'R+', 4, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T4-R+-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T4-R+-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só para crianças$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Contraindicado no adulto$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Sem papel no trauma$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$Pode salvar vidas ao iniciar a ressuscitação quando a veia falha$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Só para colher sangue$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, a TC foi normal. A dor nova pode ser uma lesão?$q$ OR i.ancora IS DISTINCT FROM 'A42' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sim; lesões podem ser descobertas depois, mesmo com TC|Correta.#Só em crianças|Não.#Não, a TC exclui tudo|Lesões tardias ocorrem mesmo com TC.#Só se houver febre|Não é critério.#Não importa|Importa.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, a TC foi normal. A dor nova pode ser uma lesão?$q$, dificuldade=2, ancora='A42', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, a TC foi normal. A dor nova pode ser uma lesão?$q$, 2, 'A42', 'T5-Graduação-1', 'graduacao', 5, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-Graduação-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sim; lesões podem ser descobertas depois, mesmo com TC$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Só em crianças$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Não, a TC exclui tudo$q$, false, 'erro_conceitual', $q$Lesões tardias ocorrem mesmo com TC.$q$),
  (4, $q$Só se houver febre$q$, false, 'erro_indicacao', $q$Não é critério.$q$),
  (5, $q$Não importa$q$, false, 'erro_conduta', $q$Importa.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, o que é a avaliação terciária?$q$ OR i.ancora IS DISTINCT FROM 'D31' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Um reexame completo depois da ressuscitação e das intervenções|Correta.#A primeira avaliação na sala|Essa é a primária.#A TC de corpo inteiro|Não.#O exame do SAMU|Não.#A alta|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, o que é a avaliação terciária?$q$, dificuldade=2, ancora='D31', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, o que é a avaliação terciária?$q$, 2, 'D31', 'T5-Graduação-2', 'graduacao', 5, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-Graduação-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Um reexame completo depois da ressuscitação e das intervenções$q$, true, NULL, $q$Correta.$q$),
  (2, $q$A primeira avaliação na sala$q$, false, 'erro_conceitual', $q$Essa é a primária.$q$),
  (3, $q$A TC de corpo inteiro$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$O exame do SAMU$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$A alta$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, a PA caiu para 88/56. O que pensar primeiro?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nada|Erro.#Ansiedade|Não.#Sono|Não.#Sangramento até prova em contrário|Correta.#Desidratação|Não presumir.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, a PA caiu para 88/56. O que pensar primeiro?$q$, dificuldade=3, ancora='D32', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, a PA caiu para 88/56. O que pensar primeiro?$q$, 3, 'D32', 'T5-Graduação-3', 'graduacao', 5, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-Graduação-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nada$q$, false, 'erro_conduta', $q$Erro.$q$),
  (2, $q$Ansiedade$q$, false, 'erro_indicacao', $q$Não.$q$),
  (3, $q$Sono$q$, false, 'erro_tecnico', $q$Não.$q$),
  (4, $q$Sangramento até prova em contrário$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Desidratação$q$, false, 'erro_conceitual', $q$Não presumir.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, a família pergunta por que a lesão não apareceu na TC. Qual a explicação correta?$q$ OR i.ancora IS DISTINCT FROM 'A42' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Lesões podem ser descobertas depois mesmo com TC|Correta: num estudo, ocorreram em 13,9 % dos pacientes.#Não é preciso reexaminar|O reexame é o que encontra essas lesões.#Isso só acontece em crianças|Ocorre em adultos.#A lesão surgiu depois, sem relação com o atropelamento|Improvável e não justifica deixar de investigar.#A TC vê todas as lesões|Não vê.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, a família pergunta por que a lesão não apareceu na TC. Qual a explicação correta?$q$, dificuldade=3, ancora='A42', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, a família pergunta por que a lesão não apareceu na TC. Qual a explicação correta?$q$, 3, 'A42', 'T5-Graduação-4', 'graduacao', 5, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-Graduação-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Lesões podem ser descobertas depois mesmo com TC$q$, true, NULL, $q$Correta: num estudo, ocorreram em 13,9 % dos pacientes.$q$),
  (2, $q$Não é preciso reexaminar$q$, false, 'erro_conduta', $q$O reexame é o que encontra essas lesões.$q$),
  (3, $q$Isso só acontece em crianças$q$, false, 'erro_tecnico', $q$Ocorre em adultos.$q$),
  (4, $q$A lesão surgiu depois, sem relação com o atropelamento$q$, false, 'erro_indicacao', $q$Improvável e não justifica deixar de investigar.$q$),
  (5, $q$A TC vê todas as lesões$q$, false, 'erro_conceitual', $q$Não vê.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, o que fazer com as imagens já feitas?$q$ OR i.ancora IS DISTINCT FROM 'D30' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Repetir todas sem revisar|Não é o recomendado.#Ignorar|Não.#Confiar só no primeiro laudo|Lesões podem passar.#Revisá-las cuidadosamente na avaliação terciária|Correta.#Descartar|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, o que fazer com as imagens já feitas?$q$, dificuldade=4, ancora='D30', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, o que fazer com as imagens já feitas?$q$, 4, 'D30', 'T5-Graduação-5', 'graduacao', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-Graduação-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Repetir todas sem revisar$q$, false, 'erro_tecnico', $q$Não é o recomendado.$q$),
  (2, $q$Ignorar$q$, false, 'erro_indicacao', $q$Não.$q$),
  (3, $q$Confiar só no primeiro laudo$q$, false, 'erro_conduta', $q$Lesões podem passar.$q$),
  (4, $q$Revisá-las cuidadosamente na avaliação terciária$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Descartar$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, o exame físico achou dor no pé. Como valorizar o achado?$q$ OR i.ancora IS DISTINCT FROM 'D25' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só valorizar se houver deformidade|Não.#Só na alta|Atraso.#Não valorizar|Não.#Achados positivos quase sempre indicam lesão e exigem ação|Correta.#Ignorar sem imagem|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, o exame físico achou dor no pé. Como valorizar o achado?$q$, dificuldade=4, ancora='D25', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, o exame físico achou dor no pé. Como valorizar o achado?$q$, 4, 'D25', 'T5-Graduação-6', 'graduacao', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-Graduação-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-Graduação-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só valorizar se houver deformidade$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Só na alta$q$, false, 'erro_tecnico', $q$Atraso.$q$),
  (3, $q$Não valorizar$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$Achados positivos quase sempre indicam lesão e exigem ação$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Ignorar sem imagem$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, quando a avaliação terciária deveria ser feita?$q$ OR i.ancora IS DISTINCT FROM 'D31' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Depois da ressuscitação inicial e das intervenções|Correta.#Antes da primária|Ordem errada.#Nunca|Não.#Só na alta|Tarde.#Só se a TC for anormal|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, quando a avaliação terciária deveria ser feita?$q$, dificuldade=3, ancora='D31', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, quando a avaliação terciária deveria ser feita?$q$, 3, 'D31', 'T5-R1-1', 'R1', 5, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R1-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Depois da ressuscitação inicial e das intervenções$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Antes da primária$q$, false, 'erro_indicacao', $q$Ordem errada.$q$),
  (3, $q$Nunca$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$Só na alta$q$, false, 'erro_conceitual', $q$Tarde.$q$),
  (5, $q$Só se a TC for anormal$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual a conduta diante da hipotensão?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Dar só analgésico|Não.#Alta|Não.#Atribuir à dor|Armadilha.#Esperar a manhã|Atraso.#Reavaliar como sangramento e procurar lesão não identificada|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual a conduta diante da hipotensão?$q$, dificuldade=3, ancora='D32', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual a conduta diante da hipotensão?$q$, 3, 'D32', 'T5-R1-2', 'R1', 5, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R1-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Dar só analgésico$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Alta$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Atribuir à dor$q$, false, 'erro_tecnico', $q$Armadilha.$q$),
  (4, $q$Esperar a manhã$q$, false, 'erro_indicacao', $q$Atraso.$q$),
  (5, $q$Reavaliar como sangramento e procurar lesão não identificada$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual teste clínico tem especificidade de 99% para lesão de membro inferior?$q$ OR i.ancora IS DISTINCT FROM 'A43' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$MIST|É formato de passagem.#AMPLA|É roteiro de história.#RUSH|É protocolo de ultrassom.#SILENT|Correta.#FAST|Não é desse teste.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual teste clínico tem especificidade de 99% para lesão de membro inferior?$q$, dificuldade=4, ancora='A43', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual teste clínico tem especificidade de 99% para lesão de membro inferior?$q$, 4, 'A43', 'T5-R1-3', 'R1', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R1-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$MIST$q$, false, 'erro_tecnico', $q$É formato de passagem.$q$),
  (2, $q$AMPLA$q$, false, 'erro_indicacao', $q$É roteiro de história.$q$),
  (3, $q$RUSH$q$, false, 'erro_conduta', $q$É protocolo de ultrassom.$q$),
  (4, $q$SILENT$q$, true, NULL, $q$Correta.$q$),
  (5, $q$FAST$q$, false, 'erro_conceitual', $q$Não é desse teste.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, o SILENT negativo exclui lesão?$q$ OR i.ancora IS DISTINCT FROM 'A43' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sim, se a TC for normal|Não.#Sempre|Não.#Sim|Não.#Só no idoso|Não.#Não; sensibilidade de 75%|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, o SILENT negativo exclui lesão?$q$, dificuldade=4, ancora='A43', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, o SILENT negativo exclui lesão?$q$, 4, 'A43', 'T5-R1-4', 'R1', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R1-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sim, se a TC for normal$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Sempre$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Sim$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Só no idoso$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Não; sensibilidade de 75%$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, a avaliação terciária foi feita no segundo dia e não achou nada. A dor no ombro surge no terceiro. O que fazer?$q$ OR i.ancora IS DISTINCT FROM 'A41, D25' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Repetir a TC de corpo inteiro sem exame|A imagem não substitui o exame.#Ignorar, porque a terciária já foi feita|A terciária não é infalível.#Reexaminar e investigar|Correta: lesões potencialmente letais apareceram após a terciária em 0,26% dos graves, e achado positivo exige ação.#Dar alta e reavaliar no ambulatório|Inadequado com queixa nova.#Atribuir à posição no leito sem examinar|Presumir sem examinar é erro.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, a avaliação terciária foi feita no segundo dia e não achou nada. A dor no ombro surge no terceiro. O que fazer?$q$, dificuldade=5, ancora='A41, D25', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, a avaliação terciária foi feita no segundo dia e não achou nada. A dor no ombro surge no terceiro. O que fazer?$q$, 5, 'A41, D25', 'T5-R1-5', 'R1', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R1-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Repetir a TC de corpo inteiro sem exame$q$, false, 'erro_tecnico', $q$A imagem não substitui o exame.$q$),
  (2, $q$Ignorar, porque a terciária já foi feita$q$, false, 'erro_conceitual', $q$A terciária não é infalível.$q$),
  (3, $q$Reexaminar e investigar$q$, true, NULL, $q$Correta: lesões potencialmente letais apareceram após a terciária em 0,26% dos graves, e achado positivo exige ação.$q$),
  (4, $q$Dar alta e reavaliar no ambulatório$q$, false, 'erro_indicacao', $q$Inadequado com queixa nova.$q$),
  (5, $q$Atribuir à posição no leito sem examinar$q$, false, 'erro_conduta', $q$Presumir sem examinar é erro.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, quem atendeu a paciente na UTI deve fazer o quê?$q$ OR i.ancora IS DISTINCT FROM 'D30' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nada|Não.#Só repetir a TC|Não é o recomendado.#Avaliação terciária e revisão das imagens|Correta.#Só prescrição|Não.#Alta|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, quem atendeu a paciente na UTI deve fazer o quê?$q$, dificuldade=5, ancora='D30', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R1-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, quem atendeu a paciente na UTI deve fazer o quê?$q$, 5, 'D30', 'T5-R1-6', 'R1', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R1-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R1-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nada$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Só repetir a TC$q$, false, 'erro_tecnico', $q$Não é o recomendado.$q$),
  (3, $q$Avaliação terciária e revisão das imagens$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Só prescrição$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$Alta$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual a melhor explicação para a lesão só aparecer no dia seguinte?$q$ OR i.ancora IS DISTINCT FROM 'A42, D30' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A TC sempre vê tudo|Não.#Lesões ocultas são comuns e a TC não elimina o risco|Correta.#Erro grosseiro sempre|Não necessariamente.#Lesão nova sem relação com o trauma|Improvável.#Simulação da paciente|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual a melhor explicação para a lesão só aparecer no dia seguinte?$q$, dificuldade=3, ancora='A42, D30', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual a melhor explicação para a lesão só aparecer no dia seguinte?$q$, 3, 'A42, D30', 'T5-R2-1', 'R2', 5, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R2-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A TC sempre vê tudo$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Lesões ocultas são comuns e a TC não elimina o risco$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Erro grosseiro sempre$q$, false, 'erro_conceitual', $q$Não necessariamente.$q$),
  (4, $q$Lesão nova sem relação com o trauma$q$, false, 'erro_tecnico', $q$Improvável.$q$),
  (5, $q$Simulação da paciente$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, hipotensão após ressuscitação. Qual armadilha evitar?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Chamar o líder|É o certo.#Revisar imagens|É o certo.#Assumir que é por outra causa e ignorar o episódio|Correta: é armadilha comum.#Investigar sangramento|É o certo.#Reexaminar|É o certo.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, hipotensão após ressuscitação. Qual armadilha evitar?$q$, dificuldade=3, ancora='D32', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, hipotensão após ressuscitação. Qual armadilha evitar?$q$, 3, 'D32', 'T5-R2-2', 'R2', 5, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R2-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Chamar o líder$q$, false, 'erro_conduta', $q$É o certo.$q$),
  (2, $q$Revisar imagens$q$, false, 'erro_tecnico', $q$É o certo.$q$),
  (3, $q$Assumir que é por outra causa e ignorar o episódio$q$, true, NULL, $q$Correta: é armadilha comum.$q$),
  (4, $q$Investigar sangramento$q$, false, 'erro_conceitual', $q$É o certo.$q$),
  (5, $q$Reexaminar$q$, false, 'erro_indicacao', $q$É o certo.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual o desempenho do SILENT e o que isso implica?$q$ OR i.ancora IS DISTINCT FROM 'A43' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Inútil|Útil para confirmar.#Ótimo para excluir|Não.#Especificidade 75%|Invertido.#Sensibilidade 75% e especificidade 99%: bom para confirmar, ruim para excluir|Correta.#Sensibilidade 99%|Invertido.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual o desempenho do SILENT e o que isso implica?$q$, dificuldade=4, ancora='A43', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual o desempenho do SILENT e o que isso implica?$q$, 4, 'A43', 'T5-R2-3', 'R2', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R2-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Inútil$q$, false, 'erro_indicacao', $q$Útil para confirmar.$q$),
  (2, $q$Ótimo para excluir$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Especificidade 75%$q$, false, 'erro_conduta', $q$Invertido.$q$),
  (4, $q$Sensibilidade 75% e especificidade 99%: bom para confirmar, ruim para excluir$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Sensibilidade 99%$q$, false, 'erro_tecnico', $q$Invertido.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-4')
   AND (i.enunciado IS DISTINCT FROM $q$Ao revisar a indicação da TC no caso 5, qual argumento é sustentado pela evidência?$q$ OR i.ancora IS DISTINCT FROM 'A40, A12' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A TC de rotina reduz a mortalidade de forma comprovada|Teve pouco ou nenhum efeito em mortalidade.#A TC deve ser repetida a cada 12 horas|Não há base.#A TC dispensa a avaliação terciária|Lesões tardias ocorrem mesmo com TC.#Com primária sem alterações, a TC de corpo inteiro acrescentou pouco: 3,02% dos submetidos estavam nesse grupo e nenhum teve lesão na imagem|Correta (120 de 3976).#A TC encontra lesão grave em metade desses pacientes|Não foi o achado.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Ao revisar a indicação da TC no caso 5, qual argumento é sustentado pela evidência?$q$, dificuldade=4, ancora='A40, A12', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Ao revisar a indicação da TC no caso 5, qual argumento é sustentado pela evidência?$q$, 4, 'A40, A12', 'T5-R2-4', 'R2', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R2-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A TC de rotina reduz a mortalidade de forma comprovada$q$, false, 'erro_indicacao', $q$Teve pouco ou nenhum efeito em mortalidade.$q$),
  (2, $q$A TC deve ser repetida a cada 12 horas$q$, false, 'erro_tecnico', $q$Não há base.$q$),
  (3, $q$A TC dispensa a avaliação terciária$q$, false, 'erro_conduta', $q$Lesões tardias ocorrem mesmo com TC.$q$),
  (4, $q$Com primária sem alterações, a TC de corpo inteiro acrescentou pouco: 3,02% dos submetidos estavam nesse grupo e nenhum teve lesão na imagem$q$, true, NULL, $q$Correta (120 de 3976).$q$),
  (5, $q$A TC encontra lesão grave em metade desses pacientes$q$, false, 'erro_conceitual', $q$Não foi o achado.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, como reduzir a chance de nova lesão despercebida até a alta?$q$ OR i.ancora IS DISTINCT FROM 'D30, D25' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Alta precoce|Não.#Proibir queixas|Não.#Nova TC de rotina sem exame|Não é o recomendado.#Avaliação terciária, revisão de imagens e reexame ao surgirem queixas|Correta.#Nenhuma medida|Há.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, como reduzir a chance de nova lesão despercebida até a alta?$q$, dificuldade=5, ancora='D30, D25', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, como reduzir a chance de nova lesão despercebida até a alta?$q$, 5, 'D30, D25', 'T5-R2-5', 'R2', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R2-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Alta precoce$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Proibir queixas$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Nova TC de rotina sem exame$q$, false, 'erro_indicacao', $q$Não é o recomendado.$q$),
  (4, $q$Avaliação terciária, revisão de imagens e reexame ao surgirem queixas$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Nenhuma medida$q$, false, 'erro_tecnico', $q$Há.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, a paciente estava acordada. Por que a terciária importa mais ainda nos intubados?$q$ OR i.ancora IS DISTINCT FROM 'D31' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Porque têm alta mais cedo|Não.#Porque têm menos lesões|Não.#Não importa|Importa.#Porque a TC é melhor neles|Não.#Não se queixam e o exame neurológico fica indisponível|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, a paciente estava acordada. Por que a terciária importa mais ainda nos intubados?$q$, dificuldade=5, ancora='D31', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R2-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, a paciente estava acordada. Por que a terciária importa mais ainda nos intubados?$q$, 5, 'D31', 'T5-R2-6', 'R2', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R2-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R2-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Porque têm alta mais cedo$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Porque têm menos lesões$q$, false, 'erro_indicacao', $q$Não.$q$),
  (3, $q$Não importa$q$, false, 'erro_conceitual', $q$Importa.$q$),
  (4, $q$Porque a TC é melhor neles$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Não se queixam e o exame neurológico fica indisponível$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, você revisa o caso com a equipe. Qual mensagem principal?$q$ OR i.ancora IS DISTINCT FROM 'D30, A42' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Evitar internar|Não.#Nada a aprender|Há.#A sala de trauma e a TC não encerram o diagnóstico; a terciária é parte do atendimento|Correta.#A paciente simulou|Não.#A TC basta|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, você revisa o caso com a equipe. Qual mensagem principal?$q$, dificuldade=4, ancora='D30, A42', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, você revisa o caso com a equipe. Qual mensagem principal?$q$, 4, 'D30, A42', 'T5-R3-1', 'R3', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R3-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Evitar internar$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Nada a aprender$q$, false, 'erro_tecnico', $q$Há.$q$),
  (3, $q$A sala de trauma e a TC não encerram o diagnóstico; a terciária é parte do atendimento$q$, true, NULL, $q$Correta.$q$),
  (4, $q$A paciente simulou$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$A TC basta$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, como conduzir o debriefing?$q$ OR i.ancora IS DISTINCT FROM 'A18' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Punindo o residente|Não.#Só por escrito meses depois|Tarde.#Com a equipe, logo após, focando no processo|Correta: debriefing apoia o aprendizado da equipe.#Não fazer|Perde-se a oportunidade.#Sem a equipe|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, como conduzir o debriefing?$q$, dificuldade=4, ancora='A18', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, como conduzir o debriefing?$q$, 4, 'A18', 'T5-R3-2', 'R3', 5, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R3-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Punindo o residente$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Só por escrito meses depois$q$, false, 'erro_tecnico', $q$Tarde.$q$),
  (3, $q$Com a equipe, logo após, focando no processo$q$, true, NULL, $q$Correta: debriefing apoia o aprendizado da equipe.$q$),
  (4, $q$Não fazer$q$, false, 'erro_conceitual', $q$Perde-se a oportunidade.$q$),
  (5, $q$Sem a equipe$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual dado sobre a TC de rotina ajuda a explicar o caso?$q$ OR i.ancora IS DISTINCT FROM 'A12, A42' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Aumenta a mortalidade|Não.#Pouco ou nenhum efeito em mortalidade e lesões tardias mesmo com ela|Correta.#Reduz lesões tardias a zero|Não.#Dispensa a terciária|Não.#Não há dados|Há.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual dado sobre a TC de rotina ajuda a explicar o caso?$q$, dificuldade=5, ancora='A12, A42', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual dado sobre a TC de rotina ajuda a explicar o caso?$q$, 5, 'A12, A42', 'T5-R3-3', 'R3', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R3-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Aumenta a mortalidade$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Pouco ou nenhum efeito em mortalidade e lesões tardias mesmo com ela$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Reduz lesões tardias a zero$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Dispensa a terciária$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Não há dados$q$, false, 'erro_conduta', $q$Há.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual indicador de qualidade acompanharia este problema?$q$ OR i.ancora IS DISTINCT FROM 'A42' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Tempo de passagem do SAMU|Outro processo.#Número de TCs|Indireto.#Custo da TC|Não.#Lesões de diagnóstico tardio|Correta.#Número de radiografias|Indireto.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual indicador de qualidade acompanharia este problema?$q$, dificuldade=5, ancora='A42', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual indicador de qualidade acompanharia este problema?$q$, 5, 'A42', 'T5-R3-4', 'R3', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R3-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Tempo de passagem do SAMU$q$, false, 'erro_indicacao', $q$Outro processo.$q$),
  (2, $q$Número de TCs$q$, false, 'erro_conceitual', $q$Indireto.$q$),
  (3, $q$Custo da TC$q$, false, 'erro_tecnico', $q$Não.$q$),
  (4, $q$Lesões de diagnóstico tardio$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Número de radiografias$q$, false, 'erro_conduta', $q$Indireto.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, hipotensão à tarde. Qual a primeira decisão do líder?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Esperar o plantão seguinte|Atraso.#Atribuir à dor|Armadilha.#Dar alta|Não.#Suspender o soro|Não.#Tratar como sangramento e investigar já|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, hipotensão à tarde. Qual a primeira decisão do líder?$q$, dificuldade=6, ancora='D32', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, hipotensão à tarde. Qual a primeira decisão do líder?$q$, 6, 'D32', 'T5-R3-5', 'R3', 5, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R3-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Esperar o plantão seguinte$q$, false, 'erro_conduta', $q$Atraso.$q$),
  (2, $q$Atribuir à dor$q$, false, 'erro_conceitual', $q$Armadilha.$q$),
  (3, $q$Dar alta$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Suspender o soro$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Tratar como sangramento e investigar já$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual a proporção de lesões tardias após terciária, e o que implica?$q$ OR i.ancora IS DISTINCT FROM 'A41' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não há dados|Há.#13,9 %: só depende da TC|Outro estudo.#26%: a terciária é inútil|Não.#0%: a terciária é infalível|Não.#0,26%: a vigilância continua depois da terciária|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual a proporção de lesões tardias após terciária, e o que implica?$q$, dificuldade=6, ancora='A41', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R3-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual a proporção de lesões tardias após terciária, e o que implica?$q$, 6, 'A41', 'T5-R3-6', 'R3', 5, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R3-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R3-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não há dados$q$, false, 'erro_conduta', $q$Há.$q$),
  (2, $q$13,9 %: só depende da TC$q$, false, 'erro_tecnico', $q$Outro estudo.$q$),
  (3, $q$26%: a terciária é inútil$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$0%: a terciária é infalível$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$0,26%: a vigilância continua depois da terciária$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, como você explicaria os 13,9 % de lesões tardias mesmo com TC?$q$ OR i.ancora IS DISTINCT FROM 'A42, D30' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$A TC é inútil|Extrapola.#Estudo inválido|Não há base.#Erro de leitura sempre|Simplifica demais.#Só em hospitais pequenos|Não há base.#A TC não elimina lesões ocultas; exame seriado e revisão de imagens seguem necessários|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, como você explicaria os 13,9 % de lesões tardias mesmo com TC?$q$, dificuldade=5, ancora='A42, D30', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, como você explicaria os 13,9 % de lesões tardias mesmo com TC?$q$, 5, 'A42, D30', 'T5-R+-1', 'R+', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R+-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$A TC é inútil$q$, false, 'erro_conduta', $q$Extrapola.$q$),
  (2, $q$Estudo inválido$q$, false, 'erro_indicacao', $q$Não há base.$q$),
  (3, $q$Erro de leitura sempre$q$, false, 'erro_conceitual', $q$Simplifica demais.$q$),
  (4, $q$Só em hospitais pequenos$q$, false, 'erro_tecnico', $q$Não há base.$q$),
  (5, $q$A TC não elimina lesões ocultas; exame seriado e revisão de imagens seguem necessários$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, o que a doutrina recomenda para o paciente de UTI?$q$ OR i.ancora IS DISTINCT FROM 'D30' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Avaliação terciária e revisão cuidadosa das imagens|Correta.#Alta precoce|Não.#Nova TC diária|Não.#Nada|Não.#Só exames laboratoriais|Incompleto.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, o que a doutrina recomenda para o paciente de UTI?$q$, dificuldade=5, ancora='D30', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, o que a doutrina recomenda para o paciente de UTI?$q$, 5, 'D30', 'T5-R+-2', 'R+', 5, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R+-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Avaliação terciária e revisão cuidadosa das imagens$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Alta precoce$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Nova TC diária$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Nada$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Só exames laboratoriais$q$, false, 'erro_conceitual', $q$Incompleto.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, o teste SILENT poderia substituir a imagem?$q$ OR i.ancora IS DISTINCT FROM 'A43' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Não há dados|Há.#Sim, sempre|Não.#Sim, nos idosos|Não.#Sim, com especificidade de 75%|Invertido.#Não para excluir lesão: sensibilidade de 75%|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, o teste SILENT poderia substituir a imagem?$q$, dificuldade=6, ancora='A43', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, o teste SILENT poderia substituir a imagem?$q$, 6, 'A43', 'T5-R+-3', 'R+', 5, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R+-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Não há dados$q$, false, 'erro_conduta', $q$Há.$q$),
  (2, $q$Sim, sempre$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Sim, nos idosos$q$, false, 'erro_tecnico', $q$Não.$q$),
  (4, $q$Sim, com especificidade de 75%$q$, false, 'erro_indicacao', $q$Invertido.$q$),
  (5, $q$Não para excluir lesão: sensibilidade de 75%$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, ao propor mudança de protocolo, qual seria a base mais sólida?$q$ OR i.ancora IS DISTINCT FROM 'A41, A42' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Lesões tardias e lesões após terciária documentadas, apoiando reexame seriado|Correta.#Opinião isolada|Fraco.#Preferência do residente|Fraco.#Nenhuma|Há base.#Custo da TC|Não é o foco.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, ao propor mudança de protocolo, qual seria a base mais sólida?$q$, dificuldade=6, ancora='A41, A42', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, ao propor mudança de protocolo, qual seria a base mais sólida?$q$, 6, 'A41, A42', 'T5-R+-4', 'R+', 5, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R+-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Lesões tardias e lesões após terciária documentadas, apoiando reexame seriado$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Opinião isolada$q$, false, 'erro_conceitual', $q$Fraco.$q$),
  (3, $q$Preferência do residente$q$, false, 'erro_tecnico', $q$Fraco.$q$),
  (4, $q$Nenhuma$q$, false, 'erro_conduta', $q$Há base.$q$),
  (5, $q$Custo da TC$q$, false, 'erro_indicacao', $q$Não é o foco.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, qual seria o papel de reavaliar a hipotensão tardia na auditoria?$q$ OR i.ancora IS DISTINCT FROM 'D32' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Identificar lesão não identificada ou ressangramento|Correta.#Nenhum|Há papel.#Só para pesquisa|Incompleto.#Só multar|Não.#Só registrar|Incompleto.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, qual seria o papel de reavaliar a hipotensão tardia na auditoria?$q$, dificuldade=6, ancora='D32', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, qual seria o papel de reavaliar a hipotensão tardia na auditoria?$q$, 6, 'D32', 'T5-R+-5', 'R+', 5, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R+-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Identificar lesão não identificada ou ressangramento$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Nenhum$q$, false, 'erro_conceitual', $q$Há papel.$q$),
  (3, $q$Só para pesquisa$q$, false, 'erro_conduta', $q$Incompleto.$q$),
  (4, $q$Só multar$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Só registrar$q$, false, 'erro_indicacao', $q$Incompleto.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 5, você revisa o critério de TC de corpo inteiro do serviço. Qual proposta é coerente com as fontes?$q$ OR i.ancora IS DISTINCT FROM 'A12, A40, D30' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Tornar a TC universal porque reduz mortalidade|Não há essa comprovação.#Indicar só pela idade|Critério isolado e sem base.#Indicar por critérios e manter a avaliação terciária|Correta: a TC de rotina tem pouco efeito em mortalidade, a primária normal raramente esconde lesão na imagem, e a terciária reduz lesões não identificadas.#Nunca fazer TC em atropelados|Sem base.#TC para todos, dispensando a terciária|Lesões tardias ocorrem mesmo com TC.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 5, você revisa o critério de TC de corpo inteiro do serviço. Qual proposta é coerente com as fontes?$q$, dificuldade=6, ancora='A12, A40, D30', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T5-R+-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 5, você revisa o critério de TC de corpo inteiro do serviço. Qual proposta é coerente com as fontes?$q$, 6, 'A12, A40, D30', 'T5-R+-6', 'R+', 5, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T5-R+-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T5-R+-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Tornar a TC universal porque reduz mortalidade$q$, false, 'erro_conceitual', $q$Não há essa comprovação.$q$),
  (2, $q$Indicar só pela idade$q$, false, 'erro_tecnico', $q$Critério isolado e sem base.$q$),
  (3, $q$Indicar por critérios e manter a avaliação terciária$q$, true, NULL, $q$Correta: a TC de rotina tem pouco efeito em mortalidade, a primária normal raramente esconde lesão na imagem, e a terciária reduz lesões não identificadas.$q$),
  (4, $q$Nunca fazer TC em atropelados$q$, false, 'erro_indicacao', $q$Sem base.$q$),
  (5, $q$TC para todos, dispensando a terciária$q$, false, 'erro_conduta', $q$Lesões tardias ocorrem mesmo com TC.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o que a equipe deve fazer antes de os pacientes chegarem?$q$ OR i.ancora IS DISTINCT FROM 'D22' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Ir tomar café|Não.#Esperar para ver quem chega|Perde-se tempo.#Definir funções e preparar o material|Correta.#Nada|Não.#Pedir TC para os dois|Sem avaliação.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o que a equipe deve fazer antes de os pacientes chegarem?$q$, dificuldade=2, ancora='D22', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o que a equipe deve fazer antes de os pacientes chegarem?$q$, 2, 'D22', 'T6-Graduação-1', 'graduacao', 6, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-Graduação-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Ir tomar café$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Esperar para ver quem chega$q$, false, 'erro_conduta', $q$Perde-se tempo.$q$),
  (3, $q$Definir funções e preparar o material$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Nada$q$, false, 'erro_conceitual', $q$Não.$q$),
  (5, $q$Pedir TC para os dois$q$, false, 'erro_tecnico', $q$Sem avaliação.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o motorista sangra no antebraço. Qual a primeira medida?$q$ OR i.ancora IS DISTINCT FROM 'D6' OR i.dificuldade <> 2
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$TC|Não.#Compressão direta|Correta.#AMPLA|Depois.#Radiografia|Não.#Intubação|Não indicada.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o motorista sangra no antebraço. Qual a primeira medida?$q$, dificuldade=2, ancora='D6', taxa_esperada='75% a 90%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o motorista sangra no antebraço. Qual a primeira medida?$q$, 2, 'D6', 'T6-Graduação-2', 'graduacao', 6, false, '75% a 90%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-Graduação-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$TC$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Compressão direta$q$, true, NULL, $q$Correta.$q$),
  (3, $q$AMPLA$q$, false, 'erro_conceitual', $q$Depois.$q$),
  (4, $q$Radiografia$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Intubação$q$, false, 'erro_indicacao', $q$Não indicada.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o passageiro está inconsciente. O que avaliar logo na via aérea?$q$ OR i.ancora IS DISTINCT FROM 'D10, D11' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Se a via aérea está pérvia e se o Glasgow indica via aérea definitiva|Correta.#Só a temperatura|Não.#Só a pressão|Não.#Só a cor da pele|Não.#Nada|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o passageiro está inconsciente. O que avaliar logo na via aérea?$q$, dificuldade=3, ancora='D10, D11', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o passageiro está inconsciente. O que avaliar logo na via aérea?$q$, 3, 'D10, D11', 'T6-Graduação-3', 'graduacao', 6, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-Graduação-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Se a via aérea está pérvia e se o Glasgow indica via aérea definitiva$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Só a temperatura$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Só a pressão$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Só a cor da pele$q$, false, 'erro_conceitual', $q$Não.$q$),
  (5, $q$Nada$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, quem deve ser o líder?$q$ OR i.ancora IS DISTINCT FROM 'D22' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$O enfermeiro|Não.#Ninguém|Não.#Quem chegar primeiro|Não.#O SAMU|Não.#O cirurgião do trauma|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, quem deve ser o líder?$q$, dificuldade=3, ancora='D22', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, quem deve ser o líder?$q$, 3, 'D22', 'T6-Graduação-4', 'graduacao', 6, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-Graduação-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$O enfermeiro$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Ninguém$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Quem chegar primeiro$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$O SAMU$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$O cirurgião do trauma$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, como o SAMU deve passar o caso?$q$ OR i.ancora IS DISTINCT FROM 'D23, D24' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só para o enfermeiro|Não.#Não passar|Não.#De forma estruturada e curta|Correta.#Por escrito depois|Não.#Livre e longa|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, como o SAMU deve passar o caso?$q$, dificuldade=4, ancora='D23, D24', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, como o SAMU deve passar o caso?$q$, 4, 'D23, D24', 'T6-Graduação-5', 'graduacao', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-Graduação-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só para o enfermeiro$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$Não passar$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$De forma estruturada e curta$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Por escrito depois$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$Livre e longa$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, depois do exame, o que fazer com os pacientes despidos?$q$ OR i.ancora IS DISTINCT FROM 'D19' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Aquecê-los|Correta.#Banho frio|Não.#Nada|Não.#Deixá-los descobertos|Não.#Esperar a TC|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, depois do exame, o que fazer com os pacientes despidos?$q$, dificuldade=4, ancora='D19', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-Graduação-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, depois do exame, o que fazer com os pacientes despidos?$q$, 4, 'D19', 'T6-Graduação-6', 'graduacao', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-Graduação-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-Graduação-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Aquecê-los$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Banho frio$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Nada$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Deixá-los descobertos$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$Esperar a TC$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o R1 pergunta se pode liderar o atendimento do motorista. Qual a resposta?$q$ OR i.ancora IS DISTINCT FROM 'D29' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sim, sozinho|Não sem supervisão.#Só no próximo ano|Não é o critério.#Sim, sob supervisão próxima do assistente|Correta.#Não, nunca|Treinandos devem ter oportunidade.#Só se o assistente sair|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o R1 pergunta se pode liderar o atendimento do motorista. Qual a resposta?$q$, dificuldade=3, ancora='D29', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o R1 pergunta se pode liderar o atendimento do motorista. Qual a resposta?$q$, 3, 'D29', 'T6-R1-1', 'R1', 6, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R1-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sim, sozinho$q$, false, 'erro_indicacao', $q$Não sem supervisão.$q$),
  (2, $q$Só no próximo ano$q$, false, 'erro_tecnico', $q$Não é o critério.$q$),
  (3, $q$Sim, sob supervisão próxima do assistente$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Não, nunca$q$, false, 'erro_conceitual', $q$Treinandos devem ter oportunidade.$q$),
  (5, $q$Só se o assistente sair$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o formulário de admissão do trauma foi associado a quê?$q$ OR i.ancora IS DISTINCT FROM 'A13, A14' OR i.dificuldade <> 3
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Melhora de indicadores, como o registro da via aérea|Correta.#Mais tempo de sala|Não.#Nenhum efeito|Não.#Piora dos indicadores|Não.#Mais mortes|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o formulário de admissão do trauma foi associado a quê?$q$, dificuldade=3, ancora='A13, A14', taxa_esperada='50% a 75%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o formulário de admissão do trauma foi associado a quê?$q$, 3, 'A13, A14', 'T6-R1-2', 'R1', 6, false, '50% a 75%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R1-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Melhora de indicadores, como o registro da via aérea$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Mais tempo de sala$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Nenhum efeito$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Piora dos indicadores$q$, false, 'erro_conceitual', $q$Não.$q$),
  (5, $q$Mais mortes$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o assistente sugere orientar por telefone, de fora da sala. O que a evidência indica?$q$ OR i.ancora IS DISTINCT FROM 'A19, D29, D22' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Ele deve estar presente: a presença do cirurgião de trauma encurtou a ressuscitação em 259 segundos|Correta.#Deixar o R1 liderar sozinho|Treinandos lideram sob supervisão próxima.#O telefone é equivalente|Não há dado que sustente.#Liderar da porta, sem ver o paciente|O líder precisa da visão do todo.#Só chamá-lo se houver parada|Atraso.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o assistente sugere orientar por telefone, de fora da sala. O que a evidência indica?$q$, dificuldade=4, ancora='A19, D29, D22', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o assistente sugere orientar por telefone, de fora da sala. O que a evidência indica?$q$, 4, 'A19, D29, D22', 'T6-R1-3', 'R1', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R1-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Ele deve estar presente: a presença do cirurgião de trauma encurtou a ressuscitação em 259 segundos$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Deixar o R1 liderar sozinho$q$, false, 'erro_conduta', $q$Treinandos lideram sob supervisão próxima.$q$),
  (3, $q$O telefone é equivalente$q$, false, 'erro_conceitual', $q$Não há dado que sustente.$q$),
  (4, $q$Liderar da porta, sem ver o paciente$q$, false, 'erro_tecnico', $q$O líder precisa da visão do todo.$q$),
  (5, $q$Só chamá-lo se houver parada$q$, false, 'erro_indicacao', $q$Atraso.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o passageiro tem Glasgow 6. O que fazer antes de sedar para intubar?$q$ OR i.ancora IS DISTINCT FROM 'D12, D11' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$AMPLA|Não.#Exame neurológico breve e completo|Correta.#Nada|Não.#TC|Não.#Alta|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o passageiro tem Glasgow 6. O que fazer antes de sedar para intubar?$q$, dificuldade=4, ancora='D12, D11', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o passageiro tem Glasgow 6. O que fazer antes de sedar para intubar?$q$, 4, 'D12, D11', 'T6-R1-4', 'R1', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R1-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$AMPLA$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Exame neurológico breve e completo$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Nada$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$TC$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$Alta$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, quais elementos do MIST o SAMU deve trazer?$q$ OR i.ancora IS DISTINCT FROM 'D23' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum|Não.#Só sinais vitais|Incompleto.#Nome, endereço, telefone|Não.#Só mecanismo|Incompleto.#Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, quais elementos do MIST o SAMU deve trazer?$q$, dificuldade=5, ancora='D23', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, quais elementos do MIST o SAMU deve trazer?$q$, 5, 'D23', 'T6-R1-5', 'R1', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R1-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Só sinais vitais$q$, false, 'erro_indicacao', $q$Incompleto.$q$),
  (3, $q$Nome, endereço, telefone$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Só mecanismo$q$, false, 'erro_tecnico', $q$Incompleto.$q$),
  (5, $q$Mecanismo, lesões suspeitas, sinais vitais e sintomas, tratamentos$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, em equipe, a avaliação deve ser feita em sequência rígida por uma pessoa?$q$ OR i.ancora IS DISTINCT FROM 'D5' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só à noite|Não.#Sim, sempre|Não.#Não há regra|Há.#Não; boa parte pode ser feita simultaneamente|Correta.#Só com dois pacientes|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, em equipe, a avaliação deve ser feita em sequência rígida por uma pessoa?$q$, dificuldade=5, ancora='D5', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R1-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, em equipe, a avaliação deve ser feita em sequência rígida por uma pessoa?$q$, 5, 'D5', 'T6-R1-6', 'R1', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R1-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R1-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só à noite$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Sim, sempre$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Não há regra$q$, false, 'erro_conduta', $q$Há.$q$),
  (4, $q$Não; boa parte pode ser feita simultaneamente$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Só com dois pacientes$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o líder cirurgião foi associado a quê em meta-análise?$q$ OR i.ancora IS DISTINCT FROM 'A20, A21' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Mais mortes|Não.#Sobrevida muito maior|Não houve diferença de sobrevida.#Mais lesões perdidas|Não.#Nada|Houve efeito.#Menos lesões não identificadas, sobrevida semelhante|Correta (OR 0,48 para lesões não identificadas; OR 0,82 sobrevida).$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o líder cirurgião foi associado a quê em meta-análise?$q$, dificuldade=4, ancora='A20, A21', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o líder cirurgião foi associado a quê em meta-análise?$q$, 4, 'A20, A21', 'T6-R2-1', 'R2', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R2-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Mais mortes$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Sobrevida muito maior$q$, false, 'erro_tecnico', $q$Não houve diferença de sobrevida.$q$),
  (3, $q$Mais lesões perdidas$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Nada$q$, false, 'erro_conduta', $q$Houve efeito.$q$),
  (5, $q$Menos lesões não identificadas, sobrevida semelhante$q$, true, NULL, $q$Correta (OR 0,48 para lesões não identificadas; OR 0,82 sobrevida).$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o checklist na ressuscitação foi associado a quê?$q$ OR i.ancora IS DISTINCT FROM 'A8, A7, A10' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Prova de menor mortalidade por ensaio|Não há ensaio.#Menos pneumonia comprovada|Um estudo mostrou mais pneumonia.#Pior adesão|Não.#Nada|Houve efeito.#Melhor adesão ao ATLS e ao fluxo; evidência antes-e-depois|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o checklist na ressuscitação foi associado a quê?$q$, dificuldade=4, ancora='A8, A7, A10', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o checklist na ressuscitação foi associado a quê?$q$, 4, 'A8, A7, A10', 'T6-R2-2', 'R2', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R2-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Prova de menor mortalidade por ensaio$q$, false, 'erro_indicacao', $q$Não há ensaio.$q$),
  (2, $q$Menos pneumonia comprovada$q$, false, 'erro_conduta', $q$Um estudo mostrou mais pneumonia.$q$),
  (3, $q$Pior adesão$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Nada$q$, false, 'erro_tecnico', $q$Houve efeito.$q$),
  (5, $q$Melhor adesão ao ATLS e ao fluxo; evidência antes-e-depois$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, treinamento de equipe por simulação mostrou qual efeito?$q$ OR i.ancora IS DISTINCT FROM 'A17' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só satisfação|Não.#Mais erros|Não.#Nenhum|Houve.#Redução do tempo até exames, tomografia e hemostasia|Correta.#Aumento do tempo|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, treinamento de equipe por simulação mostrou qual efeito?$q$, dificuldade=5, ancora='A17', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, treinamento de equipe por simulação mostrou qual efeito?$q$, 5, 'A17', 'T6-R2-3', 'R2', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R2-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só satisfação$q$, false, 'erro_conduta', $q$Não.$q$),
  (2, $q$Mais erros$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Nenhum$q$, false, 'erro_indicacao', $q$Houve.$q$),
  (4, $q$Redução do tempo até exames, tomografia e hemostasia$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Aumento do tempo$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, qual a ordem para o motorista com sangramento controlado e falando?$q$ OR i.ancora IS DISTINCT FROM 'D1, D2' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só tratar o braço|Incompleto.#Seguir ABCDE, reavaliando o sangramento|Correta.#Intubar|Não indicado.#Alta|Não.#TC sem avaliação|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, qual a ordem para o motorista com sangramento controlado e falando?$q$, dificuldade=5, ancora='D1, D2', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, qual a ordem para o motorista com sangramento controlado e falando?$q$, 5, 'D1, D2', 'T6-R2-4', 'R2', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R2-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só tratar o braço$q$, false, 'erro_conceitual', $q$Incompleto.$q$),
  (2, $q$Seguir ABCDE, reavaliando o sangramento$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Intubar$q$, false, 'erro_conduta', $q$Não indicado.$q$),
  (4, $q$Alta$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$TC sem avaliação$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-5')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, o passageiro chega hipotenso e em extremis. Qual a prioridade?$q$ OR i.ancora IS DISTINCT FROM 'D3' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$TC|Não.#AMPLA|Não.#Exposição|Não.#Radiografia|Não.#Circulação (CABDE), com os mais experientes|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, o passageiro chega hipotenso e em extremis. Qual a prioridade?$q$, dificuldade=6, ancora='D3', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, o passageiro chega hipotenso e em extremis. Qual a prioridade?$q$, 6, 'D3', 'T6-R2-5', 'R2', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R2-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$TC$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$AMPLA$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Exposição$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Radiografia$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$Circulação (CABDE), com os mais experientes$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, onde o líder deve ficar?$q$ OR i.ancora IS DISTINCT FROM 'D22' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$De costas|Não.#No posto|Não.#Com visão de toda a sala|Correta.#Fora da sala|Não.#Na via aérea|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, onde o líder deve ficar?$q$, dificuldade=6, ancora='D22', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R2-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, onde o líder deve ficar?$q$, 6, 'D22', 'T6-R2-6', 'R2', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R2-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R2-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$De costas$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$No posto$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Com visão de toda a sala$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Fora da sala$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$Na via aérea$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, você lidera. Como distribuir a equipe entre os dois pacientes?$q$ OR i.ancora IS DISTINCT FROM 'D22, D3' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Sem distribuição|Não.#Só o R1 nos dois|Não.#Funções definidas antes da chegada, com o mais experiente no paciente mais grave|Correta.#Todos no primeiro que chegar|Não.#Esperar o terceiro paciente|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, você lidera. Como distribuir a equipe entre os dois pacientes?$q$, dificuldade=4, ancora='D22, D3', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, você lidera. Como distribuir a equipe entre os dois pacientes?$q$, 4, 'D22, D3', 'T6-R3-1', 'R3', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R3-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Sem distribuição$q$, false, 'erro_indicacao', $q$Não.$q$),
  (2, $q$Só o R1 nos dois$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Funções definidas antes da chegada, com o mais experiente no paciente mais grave$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Todos no primeiro que chegar$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$Esperar o terceiro paciente$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, a OMS tem um checklist de cuidado ao trauma. O que favorece sua implantação?$q$ OR i.ancora IS DISTINCT FROM 'A16' OR i.dificuldade <> 4
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nada|Não.#Campeão institucional, adaptação ao contexto e integração à rotina e à documentação|Correta.#Só distribuir o papel|Não.#Usar só em auditorias|Não.#Imposição sem treinamento|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, a OMS tem um checklist de cuidado ao trauma. O que favorece sua implantação?$q$, dificuldade=4, ancora='A16', taxa_esperada='30% a 50%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, a OMS tem um checklist de cuidado ao trauma. O que favorece sua implantação?$q$, 4, 'A16', 'T6-R3-2', 'R3', 6, false, '30% a 50%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R3-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nada$q$, false, 'erro_conceitual', $q$Não.$q$),
  (2, $q$Campeão institucional, adaptação ao contexto e integração à rotina e à documentação$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Só distribuir o papel$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Usar só em auditorias$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Imposição sem treinamento$q$, false, 'erro_conduta', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, após os atendimentos, qual a melhor prática de equipe?$q$ OR i.ancora IS DISTINCT FROM 'A18' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Debriefing e treinamento in situ periódico|Correta.#Punição de erros|Não.#Trocar a equipe|Não.#Nada|Não.#Só relatório escrito|Incompleto.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, após os atendimentos, qual a melhor prática de equipe?$q$, dificuldade=5, ancora='A18', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, após os atendimentos, qual a melhor prática de equipe?$q$, 5, 'A18', 'T6-R3-3', 'R3', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R3-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Debriefing e treinamento in situ periódico$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Punição de erros$q$, false, 'erro_tecnico', $q$Não.$q$),
  (3, $q$Trocar a equipe$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$Nada$q$, false, 'erro_conceitual', $q$Não.$q$),
  (5, $q$Só relatório escrito$q$, false, 'erro_indicacao', $q$Incompleto.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, um R2 quer pedir TC de corpo inteiro para os dois de rotina. O que dizer?$q$ OR i.ancora IS DISTINCT FROM 'A12' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só pedir para o mais jovem|Não.#Pedir antes da primária|Não.#Sempre pedir|Não.#Nunca pedir|Não.#A TC de rotina tem pouco ou nenhum efeito em mortalidade; indicar por critérios|Correta.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, um R2 quer pedir TC de corpo inteiro para os dois de rotina. O que dizer?$q$, dificuldade=5, ancora='A12', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, um R2 quer pedir TC de corpo inteiro para os dois de rotina. O que dizer?$q$, 5, 'A12', 'T6-R3-4', 'R3', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R3-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só pedir para o mais jovem$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$Pedir antes da primária$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Sempre pedir$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Nunca pedir$q$, false, 'erro_indicacao', $q$Não.$q$),
  (5, $q$A TC de rotina tem pouco ou nenhum efeito em mortalidade; indicar por critérios$q$, true, NULL, $q$Correta.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-5')
   AND (i.enunciado IS DISTINCT FROM $q$Depois do caso 6, o serviço quer treinar toda a equipe. Qual argumento sobre o ATLS é correto ao planejar o orçamento?$q$ OR i.ancora IS DISTINCT FROM 'A6, A2, A4' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Treinar não tem efeito, então não vale treinar|Há associação com menor mortalidade (OR 0,60).#É gratuito|Não.#Tem benefício comprovado por ensaio, o que justifica qualquer custo|Não há ensaio de alta qualidade.#É o programa de maior custo (USD 1433,5), e o benefício em mortalidade vem de estudos observacionais|Correta.#Custa o mesmo que programas para leigos|O programa para leigos custou USD 3,70.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Depois do caso 6, o serviço quer treinar toda a equipe. Qual argumento sobre o ATLS é correto ao planejar o orçamento?$q$, dificuldade=6, ancora='A6, A2, A4', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Depois do caso 6, o serviço quer treinar toda a equipe. Qual argumento sobre o ATLS é correto ao planejar o orçamento?$q$, 6, 'A6, A2, A4', 'T6-R3-5', 'R3', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R3-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Treinar não tem efeito, então não vale treinar$q$, false, 'erro_conduta', $q$Há associação com menor mortalidade (OR 0,60).$q$),
  (2, $q$É gratuito$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Tem benefício comprovado por ensaio, o que justifica qualquer custo$q$, false, 'erro_indicacao', $q$Não há ensaio de alta qualidade.$q$),
  (4, $q$É o programa de maior custo (USD 1433,5), e o benefício em mortalidade vem de estudos observacionais$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Custa o mesmo que programas para leigos$q$, false, 'erro_tecnico', $q$O programa para leigos custou USD 3,70.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, qual efeito da presença do cirurgião de trauma no tempo de ressuscitação?$q$ OR i.ancora IS DISTINCT FROM 'A19' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum|Houve.#259 segundos a menos|Correta.#Mais tempo|Não.#Não há dados|Há.#Dobro do tempo|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, qual efeito da presença do cirurgião de trauma no tempo de ressuscitação?$q$, dificuldade=6, ancora='A19', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R3-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, qual efeito da presença do cirurgião de trauma no tempo de ressuscitação?$q$, 6, 'A19', 'T6-R3-6', 'R3', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R3-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R3-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum$q$, false, 'erro_indicacao', $q$Houve.$q$),
  (2, $q$259 segundos a menos$q$, true, NULL, $q$Correta.$q$),
  (3, $q$Mais tempo$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Não há dados$q$, false, 'erro_conduta', $q$Há.$q$),
  (5, $q$Dobro do tempo$q$, false, 'erro_tecnico', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-1' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-1')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, você vai ensinar a equipe. Qual formato de treino in situ é equivalente no curto prazo?$q$ OR i.ancora IS DISTINCT FROM 'A44' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum funciona|Não.#Só aula teórica|Não.#Só algoritmo funciona|Não.#Por checklist ou por algoritmo, com ganhos semelhantes|Correta.#Só checklist funciona|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-1' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, você vai ensinar a equipe. Qual formato de treino in situ é equivalente no curto prazo?$q$, dificuldade=5, ancora='A44', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-1' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, você vai ensinar a equipe. Qual formato de treino in situ é equivalente no curto prazo?$q$, 5, 'A44', 'T6-R+-1', 'R+', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-1')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R+-1' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum funciona$q$, false, 'erro_tecnico', $q$Não.$q$),
  (2, $q$Só aula teórica$q$, false, 'erro_conduta', $q$Não.$q$),
  (3, $q$Só algoritmo funciona$q$, false, 'erro_indicacao', $q$Não.$q$),
  (4, $q$Por checklist ou por algoritmo, com ganhos semelhantes$q$, true, NULL, $q$Correta.$q$),
  (5, $q$Só checklist funciona$q$, false, 'erro_conceitual', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-2' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-2')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, como explicar ao serviço o valor de ter o cirurgião como líder?$q$ OR i.ancora IS DISTINCT FROM 'A20, A21' OR i.dificuldade <> 5
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Nenhum valor|Há valor.#Mais custo sem benefício comprovado algum|Há benefício em lesões não identificadas.#Menos lesões não identificadas, sem diferença de sobrevida|Correta.#Mais lesões perdidas|Não.#Sobrevida muito maior|Não houve diferença de sobrevida.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-2' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, como explicar ao serviço o valor de ter o cirurgião como líder?$q$, dificuldade=5, ancora='A20, A21', taxa_esperada='15% a 30%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-2' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, como explicar ao serviço o valor de ter o cirurgião como líder?$q$, 5, 'A20, A21', 'T6-R+-2', 'R+', 6, false, '15% a 30%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-2')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R+-2' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Nenhum valor$q$, false, 'erro_indicacao', $q$Há valor.$q$),
  (2, $q$Mais custo sem benefício comprovado algum$q$, false, 'erro_conduta', $q$Há benefício em lesões não identificadas.$q$),
  (3, $q$Menos lesões não identificadas, sem diferença de sobrevida$q$, true, NULL, $q$Correta.$q$),
  (4, $q$Mais lesões perdidas$q$, false, 'erro_tecnico', $q$Não.$q$),
  (5, $q$Sobrevida muito maior$q$, false, 'erro_conceitual', $q$Não houve diferença de sobrevida.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-3' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-3')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, qual a evidência sobre o formulário de admissão e a mortalidade?$q$ OR i.ancora IS DISTINCT FROM 'A15, A45, A46' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Redução comprovada em todos os pacientes de centros de trauma de alta complexidade|O efeito foi num subgrupo e em hospitais não terciários.#Nenhum dado de mortalidade|Há dado de mortalidade.#Queda de 17,7% para 12,1% nos pacientes com fisiologia alterada, em ensaio randomizado por conglomerados em hospitais não terciários de Gana|Correta: desfecho secundário, num subgrupo e num contexto diferente do nosso; vale aplicar com cautela.#Queda para zero|Não.#Aumento de mortalidade|Não.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-3' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, qual a evidência sobre o formulário de admissão e a mortalidade?$q$, dificuldade=6, ancora='A15, A45, A46', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-3' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, qual a evidência sobre o formulário de admissão e a mortalidade?$q$, 6, 'A15, A45, A46', 'T6-R+-3', 'R+', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-3')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R+-3' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Redução comprovada em todos os pacientes de centros de trauma de alta complexidade$q$, false, 'erro_conceitual', $q$O efeito foi num subgrupo e em hospitais não terciários.$q$),
  (2, $q$Nenhum dado de mortalidade$q$, false, 'erro_tecnico', $q$Há dado de mortalidade.$q$),
  (3, $q$Queda de 17,7% para 12,1% nos pacientes com fisiologia alterada, em ensaio randomizado por conglomerados em hospitais não terciários de Gana$q$, true, NULL, $q$Correta: desfecho secundário, num subgrupo e num contexto diferente do nosso; vale aplicar com cautela.$q$),
  (4, $q$Queda para zero$q$, false, 'erro_conduta', $q$Não.$q$),
  (5, $q$Aumento de mortalidade$q$, false, 'erro_indicacao', $q$Não.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-4' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-4')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, como você propõe avaliar o ATLS no seu serviço, dada a evidência?$q$ OR i.ancora IS DISTINCT FROM 'A4, A2' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Medir desfechos e processo, sabendo que falta evidência de alta qualidade|Correta.#Assumir benefício comprovado|Não.#Nada|Não.#Só medir custo|Incompleto.#Abandonar o treinamento|Não há base.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-4' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, como você propõe avaliar o ATLS no seu serviço, dada a evidência?$q$, dificuldade=6, ancora='A4, A2', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-4' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, como você propõe avaliar o ATLS no seu serviço, dada a evidência?$q$, 6, 'A4, A2', 'T6-R+-4', 'R+', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-4')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R+-4' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Medir desfechos e processo, sabendo que falta evidência de alta qualidade$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Assumir benefício comprovado$q$, false, 'erro_conceitual', $q$Não.$q$),
  (3, $q$Nada$q$, false, 'erro_conduta', $q$Não.$q$),
  (4, $q$Só medir custo$q$, false, 'erro_tecnico', $q$Incompleto.$q$),
  (5, $q$Abandonar o treinamento$q$, false, 'erro_indicacao', $q$Não há base.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-5' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-5')
   AND (i.enunciado IS DISTINCT FROM $q$Após o caso 6, você quer estudar o efeito do treinamento no seu serviço. Que desenho as fontes mostram ser viável e mais informativo?$q$ OR i.ancora IS DISTINCT FROM 'A3, A7' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Comparar com dados de outro país sem ajuste|Comparação sem ajuste é enviesada.#Só pesquisa de opinião|Não mede desfecho.#Antes-e-depois sem controle, que já basta|Os estudos antes-e-depois são a limitação atual.#Nenhum estudo é possível|O piloto mostrou o contrário.#Ensaio randomizado por conglomerados, com viabilidade testada em piloto|Correta: piloto com 376 pacientes e 22 residentes mostrou a viabilidade.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-5' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$Após o caso 6, você quer estudar o efeito do treinamento no seu serviço. Que desenho as fontes mostram ser viável e mais informativo?$q$, dificuldade=6, ancora='A3, A7', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-5' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$Após o caso 6, você quer estudar o efeito do treinamento no seu serviço. Que desenho as fontes mostram ser viável e mais informativo?$q$, 6, 'A3, A7', 'T6-R+-5', 'R+', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-5')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R+-5' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Comparar com dados de outro país sem ajuste$q$, false, 'erro_tecnico', $q$Comparação sem ajuste é enviesada.$q$),
  (2, $q$Só pesquisa de opinião$q$, false, 'erro_indicacao', $q$Não mede desfecho.$q$),
  (3, $q$Antes-e-depois sem controle, que já basta$q$, false, 'erro_conceitual', $q$Os estudos antes-e-depois são a limitação atual.$q$),
  (4, $q$Nenhum estudo é possível$q$, false, 'erro_conduta', $q$O piloto mostrou o contrário.$q$),
  (5, $q$Ensaio randomizado por conglomerados, com viabilidade testada em piloto$q$, true, NULL, $q$Correta: piloto com 376 pacientes e 22 residentes mostrou a viabilidade.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = NULL FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-6' AND NOT EXISTS (SELECT 1 FROM app.resposta r JOIN app.item x ON x.item_id=r.item_id WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-6')
   AND (i.enunciado IS DISTINCT FROM $q$No caso 6, qual seria a principal lacuna a explicar aos residentes sobre checklists?$q$ OR i.ancora IS DISTINCT FROM 'A7, A9, A10' OR i.dificuldade <> 6
        OR (SELECT string_agg(a.texto||'|'||coalesce(a.justificativa,''), '#' ORDER BY a.ordem) FROM app.alternativa a WHERE a.item_id=i.item_id)
           IS DISTINCT FROM $q$Só há estudos antes-e-depois, com sinais mistos de benefício e dano|Correta.#Não há estudos|Há.#Ensaios definitivos já existem|Não.#Só há benefício|Houve mais pneumonia em um estudo.#Só há dano|Houve benefício em ISS > 25.$q$);
DELETE FROM app.alternativa a USING app.item i, app.tema t WHERE a.item_id=i.item_id AND i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-6' AND i.gabarito_alternativa_id IS NULL;
UPDATE app.item i SET enunciado=$q$No caso 6, qual seria a principal lacuna a explicar aos residentes sobre checklists?$q$, dificuldade=6, ancora='A7, A9, A10', taxa_esperada='abaixo de 15%' FROM app.tema t WHERE i.tema_id=t.tema_id AND replace(t.codigo,'-','')='T001' AND i.codigo='T6-R+-6' AND i.gabarito_alternativa_id IS NULL;
WITH i AS (
  INSERT INTO app.item (tema_id, enunciado, dificuldade, ancora, codigo, perfil, teste_num, fixa, taxa_esperada)
  SELECT t.tema_id, $q$No caso 6, qual seria a principal lacuna a explicar aos residentes sobre checklists?$q$, 6, 'A7, A9, A10', 'T6-R+-6', 'R+', 6, false, 'abaixo de 15%' FROM app.tema t WHERE replace(t.codigo,'-','')='T001'
     AND NOT EXISTS (SELECT 1 FROM app.item x WHERE x.tema_id=t.tema_id AND x.codigo='T6-R+-6')
  RETURNING item_id),
alvo AS (SELECT item_id FROM i UNION SELECT x.item_id FROM app.item x JOIN app.tema t ON t.tema_id=x.tema_id
          WHERE replace(t.codigo,'-','')='T001' AND x.codigo='T6-R+-6' AND x.gabarito_alternativa_id IS NULL
            AND NOT EXISTS (SELECT 1 FROM app.alternativa a WHERE a.item_id=x.item_id))
INSERT INTO app.alternativa (item_id, ordem, texto, eh_correta, categoria_distrator, justificativa)
SELECT alvo.item_id, v.ordem, v.texto, v.correta, v.cat, v.just FROM alvo, (VALUES
  (1, $q$Só há estudos antes-e-depois, com sinais mistos de benefício e dano$q$, true, NULL, $q$Correta.$q$),
  (2, $q$Não há estudos$q$, false, 'erro_indicacao', $q$Há.$q$),
  (3, $q$Ensaios definitivos já existem$q$, false, 'erro_conceitual', $q$Não.$q$),
  (4, $q$Só há benefício$q$, false, 'erro_tecnico', $q$Houve mais pneumonia em um estudo.$q$),
  (5, $q$Só há dano$q$, false, 'erro_conduta', $q$Houve benefício em ISS > 25.$q$)) v(ordem, texto, correta, cat, just);
UPDATE app.item i SET gabarito_alternativa_id = a.alternativa_id FROM app.alternativa a WHERE a.item_id=i.item_id AND a.eh_correta AND i.gabarito_alternativa_id IS NULL AND i.codigo LIKE 'T%';
SELECT coalesce(i.perfil,'fixa') AS perfil, count(*) AS questoes, count(*) FILTER (WHERE gabarito_alternativa_id IS NOT NULL) AS com_gabarito, min(i.dificuldade) AS grau_min, max(i.dificuldade) AS grau_max FROM app.item i JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' AND i.codigo IS NOT NULL GROUP BY 1 ORDER BY 1;
COMMIT;
