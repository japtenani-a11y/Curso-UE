-- ============================================================
-- 101_reestruturacao_temas_v1.0.sql
-- OBJETIVO (decisao da coordenacao de 19/11/2026): 1) fundir os temas que sairam do programa (as 11 fusoes de 18/11 e
-- as 5 de 19/11: T126 em T121, T125 em T122, T129 em T130, T132 em T131, T150 em T134); 2) renumerar todos os codigos
-- de T001 a T150 na ordem dos modulos. Os temas novos entram depois, pelo SQL 53.
-- RODA ANTES DO 53. Roda uma vez so: depois de aplicada, a marca app.migracao_aplicada impede nova troca
-- (e o 100, que usa os codigos antigos, deixa de agir).
-- O tema_id nao muda: material, questoes, notas, presenca e calendario continuam ligados ao mesmo tema.
-- Correspondencia completa: docs/renumeracao_temas_2026-11-19.csv.
-- ============================================================
\set ON_ERROR_STOP on
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
  FOR r IN SELECT * FROM (VALUES ('T078','T077'),('T144','T143'),('T145','T135'),('T146','T081'),('T147','T009'),('T092','T056'),('T057','T089'),('T080','T079'),('T120','T119'),('T124','T123'),('T128','T127'),('T126','T121'),('T125','T122'),('T129','T130'),('T132','T131'),('T150','T134')) v(velho, novo) LOOP
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
  ('T001','T001'),
  ('T002','T002'),
  ('T003','T003'),
  ('T004','T004'),
  ('T005','T005'),
  ('T006','T006'),
  ('T137','T007'),
  ('T158','T008'),
  ('T007','T009'),
  ('T008','T010'),
  ('T009','T011'),
  ('T010','T012'),
  ('T011','T013'),
  ('T012','T014'),
  ('T013','T015'),
  ('T014','T016'),
  ('T018','T017'),
  ('T020','T018'),
  ('T015','T019'),
  ('T016','T020'),
  ('T017','T021'),
  ('T019','T022'),
  ('T021','T023'),
  ('T022','T024'),
  ('T023','T025'),
  ('T024','T026'),
  ('T025','T027'),
  ('T026','T028'),
  ('T136','T029'),
  ('T027','T030'),
  ('T104','T031'),
  ('T107','T032'),
  ('T111','T033'),
  ('T112','T034'),
  ('T139','T035'),
  ('T153','T036'),
  ('T028','T037'),
  ('T029','T038'),
  ('T030','T039'),
  ('T031','T040'),
  ('T032','T041'),
  ('T105','T042'),
  ('T033','T043'),
  ('T034','T044'),
  ('T035','T045'),
  ('T036','T046'),
  ('T037','T047'),
  ('T038','T048'),
  ('T039','T049'),
  ('T040','T050'),
  ('T041','T051'),
  ('T042','T052'),
  ('T043','T053'),
  ('T140','T054'),
  ('T141','T055'),
  ('T142','T056'),
  ('T044','T057'),
  ('T045','T058'),
  ('T046','T059'),
  ('T047','T060'),
  ('T048','T061'),
  ('T049','T062'),
  ('T066','T063'),
  ('T067','T064'),
  ('T152','T065'),
  ('T050','T066'),
  ('T051','T067'),
  ('T052','T068'),
  ('T155','T069'),
  ('T053','T071'),
  ('T054','T072'),
  ('T055','T073'),
  ('T056','T074'),
  ('T058','T075'),
  ('T059','T076'),
  ('T060','T077'),
  ('T061','T078'),
  ('T062','T079'),
  ('T063','T080'),
  ('T064','T081'),
  ('T065','T082'),
  ('T068','T083'),
  ('T069','T084'),
  ('T070','T085'),
  ('T156','T086'),
  ('T157','T087'),
  ('T071','T088'),
  ('T072','T089'),
  ('T073','T090'),
  ('T074','T091'),
  ('T075','T092'),
  ('T076','T093'),
  ('T077','T094'),
  ('T079','T095'),
  ('T110','T096'),
  ('T081','T097'),
  ('T148','T098'),
  ('T149','T099'),
  ('T082','T100'),
  ('T083','T101'),
  ('T084','T102'),
  ('T085','T103'),
  ('T086','T106'),
  ('T087','T107'),
  ('T088','T108'),
  ('T091','T109'),
  ('T151','T110'),
  ('T089','T111'),
  ('T090','T112'),
  ('T093','T113'),
  ('T094','T114'),
  ('T095','T115'),
  ('T096','T116'),
  ('T097','T117'),
  ('T098','T118'),
  ('T138','T119'),
  ('T099','T120'),
  ('T100','T121'),
  ('T101','T122'),
  ('T102','T123'),
  ('T103','T124'),
  ('T154','T125'),
  ('T106','T126'),
  ('T108','T127'),
  ('T109','T128'),
  ('T113','T129'),
  ('T114','T130'),
  ('T115','T131'),
  ('T116','T132'),
  ('T117','T135'),
  ('T118','T136'),
  ('T119','T137'),
  ('T121','T138'),
  ('T122','T139'),
  ('T123','T140'),
  ('T127','T142'),
  ('T130','T143'),
  ('T131','T144'),
  ('T133','T145'),
  ('T134','T146'),
  ('T135','T147'),
  ('T143','T149');
  UPDATE app.tema t SET codigo = 'X' || m.novo FROM mapa m WHERE replace(t.codigo,'-','') = m.velho;
  UPDATE app.tema SET codigo = 'T-' || substr(codigo, 3) WHERE codigo LIKE 'XT%';
  INSERT INTO app.migracao_aplicada VALUES ('renumeracao_2026-11-19');
  RAISE NOTICE 'renumeracao de 19/11/2026 aplicada';
END $$;
SELECT count(*) AS temas FROM app.tema;
COMMIT;
\echo 'reestruturacao dos temas (19/11/2026): pronto'
