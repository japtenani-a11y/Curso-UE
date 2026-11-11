linha_sql
-- ============================================================
-- 22_correcao_maestro_job_e_role_v4.5.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.5 / 10-11-2026
--
-- OBJETIVO: corrigir tres defeitos identificados na v4.4:
--   D-A: maestro.job nao tinha coluna skill_codigo, o que
--        impedia o executor de consumir a fila por skill.
--   D-B: a constraint de unicidade de maestro.job era por
--        (tema_id, fase), o que impedia duas skills da mesma
--        fase rodarem em paralelo.
--   D-C: ops.auditoria nao tinha RLS, permitindo leitura por
--        qualquer role.
--
-- PRE-REQUISITO: 01_instalar_v4.4, 18_setup_skills_v4.4,
--                20_agendador_gatilhos_v4.4.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 22_correcao_maestro_job_e_role_v4.5.sql
--
-- IDEMPOTENTE: pode ser executado mais de uma vez sem efeito
-- colateral. Cada alteracao verifica existencia antes.
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== CORRECAO MAESTRO JOB E ROLE v4.5 ==='

BEGIN;

-- D-A: ADICIONAR skill_codigo A maestro.job

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_schema = 'maestro' AND table_name = 'job' AND column_name = 'skill_codigo'
  ) THEN
    ALTER TABLE maestro.job ADD COLUMN skill_codigo TEXT;
    RAISE NOTICE 'D-A: coluna skill_codigo adicionada a maestro.job';
  ELSE
    RAISE NOTICE 'D-A: coluna skill_codigo ja existe em maestro.job';
  END IF;
END $$;

-- Preencher skill_codigo para jobs existentes (fallback: fase)
UPDATE maestro.job
   SET skill_codigo = coalesce(skill_codigo, 'SK-01')
 WHERE skill_codigo IS NULL;

-- Tornar NOT NULL apos preenchimento
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_schema = 'maestro' AND table_name = 'job'
       AND column_name = 'skill_codigo' AND is_nullable = 'YES'
  ) THEN
    ALTER TABLE maestro.job ALTER COLUMN skill_codigo SET NOT NULL;
    RAISE NOTICE 'D-A: skill_codigo agora NOT NULL';
  END IF;
END $$;

-- FK para ops.skill_definicao
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'fk_job_skill_codigo'
  ) THEN
    ALTER TABLE maestro.job
      ADD CONSTRAINT fk_job_skill_codigo
      FOREIGN KEY (skill_codigo) REFERENCES ops.skill_definicao(codigo) ON DELETE RESTRICT;
    RAISE NOTICE 'D-A: FK fk_job_skill_codigo criada';
  END IF;
END $$;

-- Indice para consumo da fila por skill
CREATE INDEX IF NOT EXISTS ix_job_skill_pendente
  ON maestro.job (skill_codigo, prioridade)
  WHERE estado = 'pendente';

-- D-B: AJUSTAR CONSTRAINT DE UNICIDADE

DO $$
DECLARE
  v_constraint TEXT;
BEGIN
  SELECT conname INTO v_constraint
    FROM pg_constraint
   WHERE conrelid = 'maestro.job'::regclass
     AND contype = 'u'
     AND pg_get_constraintdef(oid) LIKE '%tema_id%fase%';

  IF v_constraint IS NOT NULL THEN
    EXECUTE format('ALTER TABLE maestro.job DROP CONSTRAINT %I', v_constraint);
    RAISE NOTICE 'D-B: constraint antiga % removida', v_constraint;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'uq_job_tema_skill_estado'
  ) THEN
    ALTER TABLE maestro.job
      ADD CONSTRAINT uq_job_tema_skill_estado
      UNIQUE (tema_id, skill_codigo, estado);
    RAISE NOTICE 'D-B: constraint uq_job_tema_skill_estado criada';
  END IF;
END $$;

-- D-C: RLS EM ops.auditoria

ALTER TABLE ops.auditoria ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_auditoria_leitura ON ops.auditoria;
CREATE POLICY pol_auditoria_leitura ON ops.auditoria FOR SELECT
  USING (app.role_atual() IN ('admin','data_steward'));

DROP POLICY IF EXISTS pol_auditoria_insercao ON ops.auditoria;
CREATE POLICY pol_auditoria_insercao ON ops.auditoria FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS pol_auditoria_metabase ON ops.auditoria;
CREATE POLICY pol_auditoria_metabase ON ops.auditoria FOR SELECT
  TO metabase_ro
  USING (true);

-- ROLE maestro_rw: PERMISSOES

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'maestro_rw') THEN
    CREATE ROLE maestro_rw LOGIN PASSWORD 'trocar_em_producao';
    RAISE NOTICE 'role maestro_rw criada';
  ELSE
    RAISE NOTICE 'role maestro_rw ja existe';
  END IF;
END $$;

GRANT USAGE ON SCHEMA maestro TO maestro_rw;
GRANT USAGE ON SCHEMA conteudo TO maestro_rw;
GRANT USAGE ON SCHEMA app TO maestro_rw;
GRANT USAGE ON SCHEMA ops TO maestro_rw;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA maestro TO maestro_rw;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA conteudo TO maestro_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO maestro_rw;
GRANT INSERT ON ALL TABLES IN SCHEMA ops TO maestro_rw;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA maestro TO maestro_rw;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA conteudo TO maestro_rw;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ops TO maestro_rw;

-- Permissoes futuras (para tabelas criadas depois)
ALTER DEFAULT PRIVILEGES IN SCHEMA maestro GRANT SELECT, INSERT, UPDATE ON TABLES TO maestro_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA conteudo GRANT SELECT, INSERT, UPDATE ON TABLES TO maestro_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA ops GRANT INSERT ON TABLES TO maestro_rw;

-- CONFERENCIA

\echo '--- Conferencia ---'

SELECT 'D-A: skill_codigo existe: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns
                          WHERE table_schema='maestro' AND table_name='job' AND column_name='skill_codigo')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D-A: skill_codigo NOT NULL: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns
                          WHERE table_schema='maestro' AND table_name='job'
                            AND column_name='skill_codigo' AND is_nullable='NO')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D-A: FK fk_job_skill_codigo: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_job_skill_codigo')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D-B: constraint uq_job_tema_skill_estado: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_job_tema_skill_estado')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'D-C: ops.auditoria com RLS: ' ||
       CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE oid='ops.auditoria'::regclass)
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'role maestro_rw existe: ' ||
       CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname='maestro_rw')
            THEN 'SIM' ELSE 'NAO' END;

SELECT 'maestro_rw tem USAGE em app: ' ||
       has_schema_privilege('maestro_rw','app','USAGE')::text;

SELECT 'maestro_rw tem USAGE em maestro: ' ||
       has_schema_privilege('maestro_rw','maestro','USAGE')::text;

SELECT 'maestro_rw tem SELECT em app.tema: ' ||
       has_table_privilege('maestro_rw','app.tema','SELECT')::text;

SELECT 'maestro_rw tem INSERT em maestro.job: ' ||
       has_table_privilege('maestro_rw','maestro.job','INSERT')::text;

-- CRITERIO DE ACEITE

\echo '--- Criterio de aceite ---'

SELECT 'FALHA: skill_codigo ausente'
 WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_schema='maestro' AND table_name='job' AND column_name='skill_codigo');

SELECT 'FALHA: FK fk_job_skill_codigo ausente'
 WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_job_skill_codigo');

SELECT 'FALHA: constraint uq_job_tema_skill_estado ausente'
 WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_job_tema_skill_estado');

SELECT 'FALHA: ops.auditoria sem RLS'
 WHERE NOT (SELECT relrowsecurity FROM pg_class WHERE oid='ops.auditoria'::regclass);

SELECT 'FALHA: maestro_rw sem USAGE em app'
 WHERE NOT has_schema_privilege('maestro_rw','app','USAGE');

SELECT 'FALHA: maestro_rw sem INSERT em maestro.job'
 WHERE NOT has_table_privilege('maestro_rw','maestro.job','INSERT');

\echo '=== CORRECAO MAESTRO JOB E ROLE CONCLUIDA ==='

COMMIT;
