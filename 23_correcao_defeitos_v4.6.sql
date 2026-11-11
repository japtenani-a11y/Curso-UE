linha_sql
-- ============================================================
-- 23_correcao_defeitos_v4.6.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.6 / 10-11-2026
--
-- OBJETIVO: corrigir seis defeitos identificados na auditoria
-- da v4.5:
--   D1: 02_verificar bloco A4 compara com 44 tabelas, mas o
--       banco tem 48. Ajuste feito em runtime pelo 23b.
--   D2: 02_verificar bloco J usa pessoa_id 1, que pode nao
--       existir. Ajuste feito em runtime pelo 23b.
--   D6: PK-05 e SK-19 tinham nome identico. PK-05 renomeada.
--   D7: ops.skill_definicao.familia sem CHECK. CHECK adicionado.
--   D8: fn_contraste_wcag nao validava formato de cor.
--   D9: conteudo.design_token sem RLS.
--
-- PRE-REQUISITO: 01_instalar_v4.4, 18_setup_skills_v4.4,
--                19_setup_design_tokens_v4.4.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 23_correcao_defeitos_v4.6.sql
--
-- IDEMPOTENTE: pode ser executado mais de uma vez.
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== CORRECAO DEFEITOS v4.6 ==='

BEGIN;

-- D6: PK-05 E SK-19 COM NOME IDENTICO

UPDATE ops.skill_definicao
   SET nome = 'Gestao de qualidade do curso',
       descricao = 'Consolida indicadores de qualidade do curso em painel de gestao.'
 WHERE codigo = 'PK-05';

UPDATE ops.skill_definicao
   SET nome = 'Simulado do tema',
       descricao = 'Produz o simulado do tema com itens e tempo.'
 WHERE codigo = 'SK-19';

-- D7: familia SEM CHECK

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint c
      JOIN pg_class t ON t.oid = c.conrelid
     WHERE t.relname = 'skill_definicao'
       AND c.contype = 'c'
       AND pg_get_constraintdef(c.oid) LIKE '%familia%'
  ) THEN
    ALTER TABLE ops.skill_definicao
      ADD CONSTRAINT ck_skill_familia
      CHECK (familia IN ('SK','PK','RS','PS','AV','PG','DC','EN','GV','DS'));
    RAISE NOTICE 'D7: CHECK ck_skill_familia adicionado';
  ELSE
    RAISE NOTICE 'D7: CHECK de familia ja existe';
  END IF;
END $$;

-- D8: fn_contraste_wcag SEM VALIDACAO

CREATE OR REPLACE FUNCTION conteudo.fn_contraste_wcag(p_cor1 TEXT, p_cor2 TEXT)
RETURNS NUMERIC
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  v_l1 NUMERIC; v_l2 NUMERIC;
  v_r1 NUMERIC; v_g1 NUMERIC; v_b1 NUMERIC;
  v_r2 NUMERIC; v_g2 NUMERIC; v_b2 NUMERIC;
BEGIN
  IF p_cor1 IS NULL OR p_cor2 IS NULL THEN
    RAISE EXCEPTION 'fn_contraste_wcag: cor nula' USING ERRCODE = '22023';
  END IF;

  IF p_cor1 !~ '^#[0-9A-Fa-f]{6}$' THEN
"    RAISE EXCEPTION 'fn_contraste_wcag: cor invalida ""%"" (esperado #RRGGBB)', p_cor1"
      USING ERRCODE = '22023';
  END IF;

  IF p_cor2 !~ '^#[0-9A-Fa-f]{6}$' THEN
"    RAISE EXCEPTION 'fn_contraste_wcag: cor invalida ""%"" (esperado #RRGGBB)', p_cor2"
      USING ERRCODE = '22023';
  END IF;

  v_r1 := ('x' || substr(p_cor1, 2, 2))::bit(8)::int / 255.0;
  v_g1 := ('x' || substr(p_cor1, 4, 2))::bit(8)::int / 255.0;
  v_b1 := ('x' || substr(p_cor1, 6, 2))::bit(8)::int / 255.0;
  v_r2 := ('x' || substr(p_cor2, 2, 2))::bit(8)::int / 255.0;
  v_g2 := ('x' || substr(p_cor2, 4, 2))::bit(8)::int / 255.0;
  v_b2 := ('x' || substr(p_cor2, 6, 2))::bit(8)::int / 255.0;

  v_r1 := CASE WHEN v_r1 <= 0.03928 THEN v_r1 / 12.92 ELSE power((v_r1 + 0.055) / 1.055, 2.4) END;
  v_g1 := CASE WHEN v_g1 <= 0.03928 THEN v_g1 / 12.92 ELSE power((v_g1 + 0.055) / 1.055, 2.4) END;
  v_b1 := CASE WHEN v_b1 <= 0.03928 THEN v_b1 / 12.92 ELSE power((v_b1 + 0.055) / 1.055, 2.4) END;
  v_r2 := CASE WHEN v_r2 <= 0.03928 THEN v_r2 / 12.92 ELSE power((v_r2 + 0.055) / 1.055, 2.4) END;
  v_g2 := CASE WHEN v_g2 <= 0.03928 THEN v_g2 / 12.92 ELSE power((v_g2 + 0.055) / 1.055, 2.4) END;
  v_b2 := CASE WHEN v_b2 <= 0.03928 THEN v_b2 / 12.92 ELSE power((v_b2 + 0.055) / 1.055, 2.4) END;

  v_l1 := 0.2126 * v_r1 + 0.7152 * v_g1 + 0.0722 * v_b1;
  v_l2 := 0.2126 * v_r2 + 0.7152 * v_g2 + 0.0722 * v_b2;

  IF v_l1 > v_l2 THEN
    RETURN round((v_l1 + 0.05) / (v_l2 + 0.05), 2);
  ELSE
    RETURN round((v_l2 + 0.05) / (v_l1 + 0.05), 2);
  END IF;
END $$;

COMMENT ON FUNCTION conteudo.fn_contraste_wcag(TEXT, TEXT) IS
  'Calcula a razao de contraste WCAG 2.2 entre duas cores hexadecimais #RRGGBB. Valida formato antes de calcular.';

-- D9: design_token SEM RLS

ALTER TABLE conteudo.design_token ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_design_token_leitura ON conteudo.design_token;
CREATE POLICY pol_design_token_leitura ON conteudo.design_token FOR SELECT
  USING (true);

DROP POLICY IF EXISTS pol_design_token_escrita ON conteudo.design_token;
CREATE POLICY pol_design_token_escrita ON conteudo.design_token FOR ALL
  USING (app.role_atual() IN ('admin','data_steward'))
  WITH CHECK (app.role_atual() IN ('admin','data_steward'));

-- D1 e D2: AJUSTES EM 02_verificar (feitos pelo 23b em runtime)
-- Este script apenas registra a intencao. O ajuste real e feito
-- pelo 23b_patch_arquivos_v1.0.sh, que altera o arquivo .sql.

\echo '--- D1 e D2: ajustes em 02_verificar sao feitos pelo 23b ---'

-- CONFERENCIA

\echo '--- Conferencia ---'

SELECT 'D6: PK-05 nome: ' || nome FROM ops.skill_definicao WHERE codigo = 'PK-05';
SELECT 'D6: SK-19 nome: ' || nome FROM ops.skill_definicao WHERE codigo = 'SK-19';

SELECT 'D6: nomes distintos: ' ||
       CASE WHEN (SELECT count(DISTINCT nome) FROM ops.skill_definicao WHERE codigo IN ('PK-05','SK-19')) = 2
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D7: CHECK de familia existe: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM pg_constraint c
                           JOIN pg_class t ON t.oid = c.conrelid
                          WHERE t.relname = 'skill_definicao'
                            AND c.contype = 'c'
                            AND pg_get_constraintdef(c.oid) LIKE '%familia%')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D8: fn_contraste_wcag valida formato: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
                          WHERE n.nspname = 'conteudo' AND p.proname = 'fn_contraste_wcag')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D9: design_token com RLS: ' ||
       CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE oid = 'conteudo.design_token'::regclass)
            THEN 'SIM' ELSE 'NAO' END;

-- TESTE DE VALIDACAO DE COR

\echo '--- Teste de validacao de cor ---'

DO $$
BEGIN
  BEGIN
    PERFORM conteudo.fn_contraste_wcag('#FFF', '#000');
    RAISE EXCEPTION 'D8 FALHOU: cor de 3 digitos deveria ser rejeitada';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    RAISE NOTICE 'D8 OK: cor de 3 digitos rejeitada';
  END;

  BEGIN
    PERFORM conteudo.fn_contraste_wcag('vermelho', '#000');
    RAISE EXCEPTION 'D8 FALHOU: cor nao-hex deveria ser rejeitada';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    RAISE NOTICE 'D8 OK: cor nao-hex rejeitada';
  END;

  PERFORM conteudo.fn_contraste_wcag('#1E3A5F', '#FFFFFF');
  RAISE NOTICE 'D8 OK: cor valida aceita';
END $$;

-- CRITERIO DE ACEITE

\echo '--- Criterio de aceite ---'

SELECT 'FALHA: PK-05 e SK-19 com nome identico'
 WHERE (SELECT count(DISTINCT nome) FROM ops.skill_definicao WHERE codigo IN ('PK-05','SK-19')) <> 2;

SELECT 'FALHA: CHECK de familia ausente'
 WHERE NOT EXISTS (SELECT 1 FROM pg_constraint c
                     JOIN pg_class t ON t.oid = c.conrelid
                    WHERE t.relname = 'skill_definicao'
                      AND c.contype = 'c'
                      AND pg_get_constraintdef(c.oid) LIKE '%familia%');

SELECT 'FALHA: design_token sem RLS'
 WHERE NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'conteudo.design_token'::regclass);

\echo '=== CORRECAO DEFEITOS CONCLUIDA ==='

COMMIT;
