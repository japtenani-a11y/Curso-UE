-- ============================================================
-- 100_fusao_temas_v1.0.sql
-- OBJETIVO: decisao da coordenacao de 18/11/2026 (fundir antes de ampliar). Cinco temas passam a fazer parte de outro:
--   T078 (fechamento do ciclo clinico)              -> T077 (caso integrador transversal e fechamento do ciclo)
--   T144 (limites de escopo e transferencia)        -> T143 (governanca, limites de escopo e transferencia)
--   T145 (burnout, segunda vitima e apoio)          -> T135 (desenvolvimento docente, mentoria, burnout e apoio)
--   T146 (retirada de dreno, paracentese, toracocentese) -> T081 (procedimentos a beira-leito)
--   T147 (peritoneostomia como procedimento)        -> T009 (peritoneostomia: instalacao, cuidados e retirada)
-- O que muda: as fontes ja guardadas, os pedidos de "Avise-me" e as variantes de termo do tema fundido passam para o tema
-- que o recebe; depois o tema fundido e apagado. Os titulos novos e os temas T151 a T158 vem do SQL 53.
-- Seguranca: se o tema fundido ja tiver material, questoes, ondas, notas ou presenca, NADA e feito com ele (aviso na
-- tela), para a coordenacao decidir.
-- Pode ser rodado mais de uma vez. Para desfazer: rodar de novo o SQL 53 antigo (os temas voltam, sem as fontes movidas).
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE r RECORD; v_old BIGINT; v_new BIGINT; n INT;
BEGIN
  FOR r IN SELECT * FROM (VALUES ('T078','T077'),('T144','T143'),('T145','T135'),('T146','T081'),('T147','T009')) v(velho, novo) LOOP
    SELECT tema_id INTO v_old FROM app.tema WHERE replace(codigo,'-','') = r.velho;
    SELECT tema_id INTO v_new FROM app.tema WHERE replace(codigo,'-','') = r.novo;
    IF v_old IS NULL THEN CONTINUE; END IF;              -- ja fundido
    IF v_new IS NULL THEN RAISE NOTICE 'tema % nao existe: % nao foi fundido', r.novo, r.velho; CONTINUE; END IF;
    SELECT (SELECT count(*) FROM conteudo.artefato WHERE tema_id = v_old) + (SELECT count(*) FROM app.item WHERE tema_id = v_old)
         + (SELECT count(*) FROM app.onda_instancia WHERE tema_id = v_old) + (SELECT count(*) FROM app.nota_teste WHERE tema_id = v_old)
         + (SELECT count(*) FROM app.presenca WHERE tema_id = v_old) + (SELECT count(*) FROM app.caso_teste WHERE tema_id = v_old)
      INTO n;
    IF n > 0 THEN RAISE NOTICE '% ja tem material, questoes, ondas ou presenca (% registros): nao foi fundido em %', r.velho, n, r.novo; CONTINUE; END IF;
    -- fontes: passam para o tema que recebe (a mesma fonte ja guardada nele fica uma vez so)
    UPDATE conteudo.fonte f SET tema_id = v_new
     WHERE f.tema_id = v_old AND (f.sha256 IS NULL OR NOT EXISTS (SELECT 1 FROM conteudo.fonte g WHERE g.tema_id = v_new AND g.sha256 = f.sha256));
    DELETE FROM conteudo.fonte WHERE tema_id = v_old;
    INSERT INTO app.tema_interesse (pessoa_id, tema_id, criado_em, avisado_em)
      SELECT pessoa_id, v_new, criado_em, avisado_em FROM app.tema_interesse WHERE tema_id = v_old ON CONFLICT DO NOTHING;
    UPDATE conteudo.termo_variante SET tema_id = v_new WHERE tema_id = v_old;
    UPDATE maestro.execucao_motor SET tema_id = v_new WHERE tema_id = v_old;
    UPDATE maestro.job SET tema_id = v_new WHERE tema_id = v_old;
    DELETE FROM app.tema WHERE tema_id = v_old;
    RAISE NOTICE '% fundido em %', r.velho, r.novo;
  END LOOP;
END $$;
SELECT count(*) AS temas FROM app.tema;
COMMIT;
\echo 'fusao de temas (18/11/2026): pronto'
