-- 65_arvore_temas_v1.0.sql
-- Arvore de temas mae/filho: um tema filho so e liberado quando TODOS os seus temas mae estao concluidos
-- (concluido = pos-teste D0 enviado). Um filho pode ter varias maes e uma mae pode liberar varios filhos.
-- Temas sem mae e sem filho sao "orfaos" (avulsos): nunca ficam bloqueados.
-- Nos temas principais, as maes sempre vem antes no calendario. Nos opcionais, o aluno so agenda o D0
-- depois de concluir as maes.
-- Pre-requisito: 53, 54, 60. Pode ser rodado mais de uma vez (as relacoes sao recarregadas).
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.tema_requisito (
  tema_id      BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  requisito_id BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  PRIMARY KEY (tema_id, requisito_id),
  CHECK (tema_id <> requisito_id));
GRANT SELECT ON app.tema_requisito TO api_rw;

-- filho <- maes (codigos sem hifen)
CREATE TEMP TABLE req (filho TEXT, maes TEXT) ON COMMIT DROP;
INSERT INTO req VALUES
-- Reanimacao, via aerea, choque (principais)
('T002','T001'),('T003','T001'),('T013','T001'),('T004','T001 T003'),('T005','T004'),
('T007','T005'),('T008','T007'),('T011','T013'),('T012','T011'),('T018','T013 T003'),
('T024','T003'),('T029','T001 T004'),
-- Abdome agudo (principais)
('T039','T037'),('T041','T036'),('T042','T036'),('T043','T041'),('T044','T004'),('T046','T044'),
('T050','T036 T042'),('T038','T037 T050'),('T051','T050'),('T139','T041 T050'),
-- Trauma avancado (principais)
('T016','T013 T004'),('T021','T003 T004'),('T022','T021 T007'),('T023','T021'),('T027','T002 T004'),
('T028','T004 T029'),('T031','T001 T002'),('T032','T001'),('T034','T002 T027'),('T015','T016 T004'),
('T026','T021 T007 T028'),('T071','T031 T005'),('T072','T029 T005'),('T077','T071 T072 T026 T015'),
-- Opcionais de trauma
('T006','T001'),('T009','T007'),('T010','T008 T009'),('T014','T013'),('T017','T016'),('T019','T034 T018'),
('T020','T014'),('T025','T024 T021'),('T030','T029'),('T033','T002'),('T035','T034 T050'),
('T062','T021'),('T063','T062'),('T070','T031'),('T100','T021 T088'),('T105','T031'),('T142','T021'),
('T059','T001'),('T060','T059 T002'),('T061','T059'),('T076','T059 T060'),('T075','T033 T002'),
('T113','T001'),('T116','T113'),('T143','T113'),('T144','T116'),
-- Opcionais de abdome, digestivo e parede
('T040','T042'),('T045','T044'),('T047','T044 T094'),('T049','T051'),('T052','T050 T009'),
('T066','T041'),('T067','T041 T046'),('T073','T094 T036'),('T074','T043 T139'),('T095','T036 T037'),
('T097','T036'),('T098','T036'),('T099','T036 T088'),('T101','T044'),('T102','T046'),('T103','T101 T102'),
('T104','T023'),('T106','T041'),('T108','T109'),('T109','T036 T037'),('T140','T043'),('T141','T008'),
('T096','T004'),
-- Terapia intensiva, perioperatorio e farmacologia
('T053','T011'),('T054','T053'),('T055','T004'),('T056','T055'),('T057','T089'),('T087','T086'),
('T088','T086'),('T091','T086'),('T090','T089'),('T092','T089 T056'),('T093','T050'),('T083','T093'),
('T094','T005'),
-- Temas que entraram em 13/11/2026 (opcionais)
('T136','T001 T021'),('T137','T001 T012'),('T138','T001 T004 T095'),
-- Imagem e procedimentos
('T079','T003'),('T080','T079'),('T110','T003'),('T111','T002'),('T081','T013 T002'),('T146','T013'),
('T147','T009 T081'),('T148','T081'),('T149','T002 T081'),('T150','T081 T131'),
-- Seguranca, qualidade, governanca
('T084','T082'),('T085','T082'),('T114','T082'),('T115','T114'),('T078','T077'),
-- Medicina baseada em evidencias
('T118','T117'),('T119','T118'),('T120','T119'),('T121','T120'),('T122','T121'),('T123','T122'),
('T124','T117'),('T125','T120 T122'),('T126','T121 T125'),
-- Ensino e preceptoria
('T128','T127'),('T129','T127'),('T130','T129'),('T131','T128'),('T132','T131'),('T133','T130 T131'),
('T134','T129 T081'),('T135','T130 T145');
-- Orfaos (sem mae e sem filho): T048, T058, T064, T065, T068, T069, T107, T112.

DELETE FROM app.tema_requisito;
INSERT INTO app.tema_requisito (tema_id, requisito_id)
SELECT f.tema_id, m.tema_id
  FROM req r CROSS JOIN LATERAL regexp_split_to_table(r.maes, ' ') AS mae(cod)
  JOIN app.tema f ON replace(f.codigo,'-','') = r.filho
  JOIN app.tema m ON replace(m.codigo,'-','') = mae.cod
ON CONFLICT DO NOTHING;

-- Conferencias: todas as relacoes carregadas, sem ciclo, e mae de tema principal e sempre principal e anterior no calendario.
DO $$
DECLARE n_esperado INT; n INT; v TEXT;
BEGIN
  SELECT count(*) INTO n_esperado FROM req r CROSS JOIN LATERAL regexp_split_to_table(r.maes, ' ');
  SELECT count(*) INTO n FROM app.tema_requisito;
  IF n <> n_esperado THEN RAISE EXCEPTION 'relacoes carregadas % de %: algum codigo nao existe', n, n_esperado; END IF;
  WITH RECURSIVE anc(tema_id, req_id, caminho) AS (
    SELECT tema_id, requisito_id, ARRAY[tema_id, requisito_id] FROM app.tema_requisito
    UNION ALL
    SELECT a.tema_id, r.requisito_id, a.caminho || r.requisito_id FROM anc a JOIN app.tema_requisito r ON r.tema_id = a.req_id
     WHERE NOT r.requisito_id = ANY (a.caminho[2:]) AND array_length(a.caminho, 1) < 40)
  SELECT string_agg(DISTINCT t.codigo, ', ') INTO v FROM anc JOIN app.tema t ON t.tema_id = anc.tema_id WHERE anc.tema_id = anc.req_id;
  IF v IS NOT NULL THEN RAISE EXCEPTION 'ciclo na arvore de temas: %', v; END IF;
  SELECT string_agg(f.codigo || '<-' || m.codigo, ', ') INTO v
    FROM app.tema_requisito r JOIN app.tema f ON f.tema_id = r.tema_id JOIN app.tema m ON m.tema_id = r.requisito_id
   WHERE f.papel_curricular = 'nuclear' AND (m.papel_curricular <> 'nuclear' OR m.ordem_principal >= f.ordem_principal);
  IF v IS NOT NULL THEN RAISE EXCEPTION 'tema principal com mae fora de ordem: %', v; END IF;
END $$;

-- Tema concluido pela pessoa (pos-teste D0 enviado).
CREATE OR REPLACE FUNCTION app.tema_concluido(p_pessoa BIGINT, p_tema BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$ SELECT app.teste_submetido(p_pessoa, p_tema, 3::smallint) $$;

-- Maes que ainda faltam para a pessoa.
CREATE OR REPLACE FUNCTION app.maes_pendentes(p_pessoa BIGINT, p_tema BIGINT) RETURNS TEXT[]
LANGUAGE sql STABLE AS $$
  SELECT coalesce(array_agg(t.codigo ORDER BY t.codigo), '{}') FROM app.tema_requisito r JOIN app.tema t ON t.tema_id = r.requisito_id
   WHERE r.tema_id = p_tema AND NOT app.tema_concluido(p_pessoa, r.requisito_id) $$;

-- Etapa 0 = bloqueado pela arvore (as demais regras sao as do 60).
CREATE OR REPLACE FUNCTION app.etapa_liberada(p_pessoa BIGINT, p_tema BIGINT) RETURNS INT
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint)
         AND EXISTS (SELECT 1 FROM app.tema_requisito r WHERE r.tema_id = p_tema AND NOT app.tema_concluido(p_pessoa, r.requisito_id)) THEN 0
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint) THEN 1
    WHEN coalesce(now() < app.d0_da_pessoa(p_pessoa, p_tema), true) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 3::smallint) THEN 3
    ELSE 4 END $$;
-- teste_liberado (38): teste 1 precisa de etapa >= 1.
CREATE OR REPLACE FUNCTION app.teste_liberado(p_pessoa BIGINT, p_tema BIGINT, p_teste SMALLINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
  SELECT app.etapa_liberada(p_pessoa, p_tema) >= CASE WHEN p_teste <= 3 THEN p_teste ELSE 4 END $$;
GRANT EXECUTE ON FUNCTION app.tema_concluido(BIGINT, BIGINT), app.maes_pendentes(BIGINT, BIGINT) TO api_rw;

-- Opcional so pode ser agendado com as maes concluidas.
CREATE OR REPLACE FUNCTION app.fn_bloquear_agendamento() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.pessoa_id IS NOT NULL AND NEW.teste_num = 1 AND cardinality(app.maes_pendentes(NEW.pessoa_id, NEW.tema_id)) > 0 THEN
    RAISE EXCEPTION 'tema_bloqueado:%', array_to_string(app.maes_pendentes(NEW.pessoa_id, NEW.tema_id), ',');
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_bloquear_agendamento ON app.onda_instancia;
CREATE TRIGGER tg_bloquear_agendamento BEFORE INSERT ON app.onda_instancia FOR EACH ROW EXECUTE FUNCTION app.fn_bloquear_agendamento();

-- Arvore inteira para a pessoa logada: nos (com situacao) e arestas.
CREATE OR REPLACE FUNCTION app.arvore_temas() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH RECURSIVE p AS (SELECT app.pessoa_atual() AS id),
  prof(tema_id, nivel) AS (
    SELECT t.tema_id, 0 FROM app.tema t WHERE NOT EXISTS (SELECT 1 FROM app.tema_requisito r WHERE r.tema_id = t.tema_id)
    UNION ALL
    SELECT r.tema_id, prof.nivel + 1 FROM prof JOIN app.tema_requisito r ON r.requisito_id = prof.tema_id WHERE prof.nivel < 30),
  niv AS (SELECT tema_id, max(nivel) AS nivel FROM prof GROUP BY tema_id)
  SELECT jsonb_build_object(
    'nos', (SELECT jsonb_agg(jsonb_build_object(
        'codigo', t.codigo, 'titulo', t.titulo, 'modulo', t.modulo, 'papel', t.papel_curricular, 'nivel', n.nivel,
        'orfao', NOT EXISTS (SELECT 1 FROM app.tema_requisito r WHERE r.tema_id = t.tema_id OR r.requisito_id = t.tema_id),
        'concluido', app.tema_concluido(p.id, t.tema_id),
        'iniciado', app.teste_submetido(p.id, t.tema_id, 1::smallint),
        'faltam', app.maes_pendentes(p.id, t.tema_id),
        'publicado', EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status = 'publicado')) ORDER BY n.nivel, t.modulo, t.codigo)
      FROM app.tema t JOIN niv n ON n.tema_id = t.tema_id, p),
    'arestas', (SELECT jsonb_agg(jsonb_build_object('de', m.codigo, 'para', f.codigo))
      FROM app.tema_requisito r JOIN app.tema f ON f.tema_id = r.tema_id JOIN app.tema m ON m.tema_id = r.requisito_id))
  WHERE app.pessoa_atual() IS NOT NULL $$;
REVOKE EXECUTE ON FUNCTION app.arvore_temas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.arvore_temas() TO api_rw;

-- Catalogo (54) e jornada (60) passam a informar o bloqueio.
DROP FUNCTION IF EXISTS app.catalogo_temas();
CREATE FUNCTION app.catalogo_temas()
RETURNS TABLE (codigo TEXT, titulo TEXT, modulo TEXT, dificuldade SMALLINT, papel TEXT, ordem SMALLINT,
               data_d0 TIMESTAMPTZ, d0_proprio BOOLEAN, etapa INT, testes_feitos INT, tem_conteudo BOOLEAN, faltam TEXT[], orfao BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT t.codigo, t.titulo, t.modulo, t.dificuldade, t.papel_curricular, t.ordem_principal,
         coalesce((SELECT o.data_abertura FROM app.onda_instancia o
                    WHERE o.tema_id = t.tema_id AND o.teste_num = 3 AND o.pessoa_id = app.pessoa_atual()),
                  (SELECT a.data_hora FROM app.agenda_aula a WHERE a.tema_id = t.tema_id),
                  (SELECT o.data_abertura FROM app.onda_instancia o
                    WHERE o.tema_id = t.tema_id AND o.teste_num = 3 AND o.pessoa_id IS NULL)),
         EXISTS (SELECT 1 FROM app.onda_instancia o WHERE o.tema_id = t.tema_id AND o.pessoa_id = app.pessoa_atual()),
         app.etapa_liberada(app.pessoa_atual(), t.tema_id),
         (SELECT count(*)::int FROM app.tentativa tt JOIN app.onda_instancia o USING (onda_id)
           WHERE o.tema_id = t.tema_id AND tt.pessoa_id = app.pessoa_atual() AND tt.submetida_em IS NOT NULL),
         EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status = 'publicado'),
         app.maes_pendentes(app.pessoa_atual(), t.tema_id),
         NOT EXISTS (SELECT 1 FROM app.tema_requisito r WHERE r.tema_id = t.tema_id OR r.requisito_id = t.tema_id)
    FROM app.tema t
   WHERE app.pessoa_atual() IS NOT NULL
   ORDER BY (t.papel_curricular <> 'nuclear'), t.ordem_principal, t.dificuldade, t.codigo $$;
REVOKE EXECUTE ON FUNCTION app.catalogo_temas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.catalogo_temas() TO api_rw;

-- jornada_tema: acrescenta maes, filhos e o que falta.
CREATE OR REPLACE FUNCTION app.relacoes_tema(p_codigo TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH t AS (SELECT tema_id FROM app.tema WHERE upper(replace(codigo,'-','')) = upper(replace(p_codigo,'-','')))
  SELECT jsonb_build_object(
    'maes', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', m.codigo, 'titulo', m.titulo,
                          'concluido', app.tema_concluido(app.pessoa_atual(), m.tema_id)) ORDER BY m.codigo)
                      FROM app.tema_requisito r JOIN app.tema m ON m.tema_id = r.requisito_id, t WHERE r.tema_id = t.tema_id), '[]'),
    'filhos', coalesce((SELECT jsonb_agg(jsonb_build_object('codigo', f.codigo, 'titulo', f.titulo) ORDER BY f.codigo)
                      FROM app.tema_requisito r JOIN app.tema f ON f.tema_id = r.tema_id, t WHERE r.requisito_id = t.tema_id), '[]'))
  WHERE app.pessoa_atual() IS NOT NULL $$;
REVOKE EXECUTE ON FUNCTION app.relacoes_tema(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.relacoes_tema(TEXT) TO api_rw;

COMMIT;
\echo 'arvore de temas mae/filho: pronta'
