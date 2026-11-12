-- 54_temas_opcionais_v1.0.sql
-- Temas opcionais (complementar e eletivo): o residente escolhe o D0 e o sistema passa a trabalhar a partir dele.
--  - ondas pessoais: app.onda_instancia.pessoa_id (NULL = onda do grupo, nos 39 temas principais)
--  - app.agendar_tema_opcional(codigo, d0): cria as 6 ondas do residente logado
--      pre-teste inicial: abre agora (ou D-15, se for mais tarde) | pre-teste 2: fecha 1 hora antes do D0
--      pos-teste D0, D+15, D+45, D+90 | tudo aberto ate D+180 | pode reagendar enquanto nao respondeu nada
--  - app.catalogo_temas(): os 147 temas com data (aula do grupo ou D0 escolhido) e a etapa da pessoa
--  - prazo e lembretes passam a considerar as ondas pessoais
-- Pre-requisito: 38, 43 e 53. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- agenda das aulas do grupo (preenchida pelo 48 no servidor)
CREATE TABLE IF NOT EXISTS app.agenda_aula (
  ciclo_id   BIGINT NOT NULL,
  ordem      SMALLINT NOT NULL,
  data_hora  TIMESTAMPTZ NOT NULL,
  tema_id    BIGINT REFERENCES app.tema(tema_id) ON DELETE SET NULL,
  link_meet  TEXT,
  PRIMARY KEY (ciclo_id, ordem),
  UNIQUE (ciclo_id, data_hora));
GRANT SELECT ON app.agenda_aula TO api_rw;

ALTER TABLE app.onda_instancia ADD COLUMN IF NOT EXISTS pessoa_id BIGINT REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE;
DROP INDEX IF EXISTS app.uq_onda_tema_teste;
CREATE UNIQUE INDEX IF NOT EXISTS uq_onda_tema_teste_grupo ON app.onda_instancia (tema_id, teste_num)
  WHERE tema_id IS NOT NULL AND pessoa_id IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_onda_tema_teste_pessoa ON app.onda_instancia (tema_id, teste_num, pessoa_id)
  WHERE tema_id IS NOT NULL AND pessoa_id IS NOT NULL;

-- Prazo vencido, olhando a onda que vale para a pessoa (a pessoal, se houver; senao a do grupo).
CREATE OR REPLACE FUNCTION app.onda_da_pessoa(p_pessoa BIGINT, p_tema BIGINT, p_teste SMALLINT) RETURNS BIGINT
LANGUAGE sql STABLE AS $$
  SELECT o.onda_id FROM app.onda_instancia o
   WHERE o.tema_id = p_tema AND o.teste_num = p_teste AND (o.pessoa_id IS NULL OR o.pessoa_id = p_pessoa)
   ORDER BY o.pessoa_id NULLS LAST LIMIT 1 $$;

CREATE OR REPLACE FUNCTION app.prazo_vencido(p_pessoa BIGINT, p_tema BIGINT, p_teste SMALLINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
  SELECT coalesce((SELECT o.data_fechamento <= now() FROM app.onda_instancia o
                    WHERE o.onda_id = app.onda_da_pessoa(p_pessoa, p_tema, p_teste)), false) $$;

CREATE OR REPLACE FUNCTION app.etapa_liberada(p_pessoa BIGINT, p_tema BIGINT) RETURNS INT
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint) THEN 1
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 2::smallint)
         AND NOT app.prazo_vencido(p_pessoa, p_tema, 2::smallint) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 3::smallint) THEN 3
    ELSE 4 END $$;

-- Agenda um tema opcional para a pessoa logada.
CREATE OR REPLACE FUNCTION app.agendar_tema_opcional(p_codigo TEXT, p_d0 TIMESTAMPTZ)
RETURNS TABLE (teste SMALLINT, abre TIMESTAMPTZ, fecha TIMESTAMPTZ)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
#variable_conflict use_column
DECLARE
  v_p BIGINT := app.pessoa_atual(); v_tema BIGINT; v_ciclo BIGINT; v_papel TEXT; v_cod TEXT;
  v_dia DATE := (p_d0 AT TIME ZONE 'America/Sao_Paulo')::date;
  v_ini TIMESTAMPTZ;
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT t.tema_id, t.ciclo_id, t.papel_curricular, replace(t.codigo,'-','') INTO v_tema, v_ciclo, v_papel, v_cod
    FROM app.tema t WHERE upper(replace(t.codigo,'-','')) = upper(replace(p_codigo,'-',''));
  IF v_tema IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  IF v_papel = 'nuclear' THEN RAISE EXCEPTION 'tema_principal_tem_data_do_grupo'; END IF;
  IF p_d0 < now() + interval '2 hours' OR p_d0 > now() + interval '400 days' THEN RAISE EXCEPTION 'data_invalida'; END IF;
  IF EXISTS (SELECT 1 FROM app.tentativa tt JOIN app.onda_instancia o USING (onda_id)
              WHERE o.tema_id = v_tema AND o.pessoa_id = v_p AND tt.pessoa_id = v_p) THEN
    RAISE EXCEPTION 'tema_ja_iniciado';
  END IF;
  v_ini := greatest(now(), (v_dia - 15)::timestamp AT TIME ZONE 'America/Sao_Paulo');

  INSERT INTO app.onda_instancia (ciclo_id, onda_codigo, ordem_onda, data_abertura, data_fechamento, status, tema_id, teste_num, pessoa_id)
  SELECT v_ciclo, v_cod || '-' || v.cod || '-P' || v_p, 100 + v.n, v.abre, v.fecha,
         CASE WHEN v.abre <= now() THEN 'aberta' ELSE 'planejada' END::app.status_onda, v_tema, v.n, v_p
    FROM (VALUES
      (1, 'PRE1',    v_ini, ((v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo')),
      (2, 'PRE2',    v_ini, p_d0 - interval '1 hour'),
      (3, 'POS-D0',  p_d0, ((v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo')),
      (4, 'POS-D15', ((v_dia + 15)::timestamp AT TIME ZONE 'America/Sao_Paulo'), ((v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo')),
      (5, 'POS-D45', ((v_dia + 45)::timestamp AT TIME ZONE 'America/Sao_Paulo'), ((v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo')),
      (6, 'POS-D90', ((v_dia + 90)::timestamp AT TIME ZONE 'America/Sao_Paulo'), ((v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo'))
    ) v(n, cod, abre, fecha)
  ON CONFLICT (ciclo_id, onda_codigo) DO UPDATE
     SET data_abertura = EXCLUDED.data_abertura, data_fechamento = EXCLUDED.data_fechamento, status = EXCLUDED.status;

  INSERT INTO app.item_selecionado (onda_id, item_id, ordem_apresentada)
  SELECT o.onda_id, i.item_id, row_number() OVER (PARTITION BY o.onda_id ORDER BY i.fixa DESC, i.perfil, i.codigo)::smallint
    FROM app.onda_instancia o JOIN app.item i ON i.tema_id = o.tema_id AND (i.fixa OR i.teste_num = o.teste_num)
   WHERE o.tema_id = v_tema AND o.pessoa_id = v_p
  ON CONFLICT (onda_id, item_id) DO NOTHING;

  RETURN QUERY SELECT o.teste_num, o.data_abertura, o.data_fechamento FROM app.onda_instancia o
                WHERE o.tema_id = v_tema AND o.pessoa_id = v_p ORDER BY o.teste_num;
END $$;
REVOKE EXECUTE ON FUNCTION app.agendar_tema_opcional(TEXT, TIMESTAMPTZ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.agendar_tema_opcional(TEXT, TIMESTAMPTZ) TO api_rw;

-- Catalogo dos temas para a pessoa logada.
CREATE OR REPLACE FUNCTION app.catalogo_temas()
RETURNS TABLE (codigo TEXT, titulo TEXT, modulo TEXT, dificuldade SMALLINT, papel TEXT, ordem SMALLINT,
               data_d0 TIMESTAMPTZ, d0_proprio BOOLEAN, etapa INT, testes_feitos INT, tem_conteudo BOOLEAN)
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
         EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status = 'publicado')
    FROM app.tema t
   WHERE app.pessoa_atual() IS NOT NULL
   ORDER BY (t.papel_curricular <> 'nuclear'), t.ordem_principal, t.dificuldade, t.codigo $$;
REVOKE EXECUTE ON FUNCTION app.catalogo_temas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.catalogo_temas() TO api_rw;

-- Lembretes: so das ondas que valem para a pessoa.
CREATE OR REPLACE FUNCTION app.gerar_lembretes_para(p_pessoa BIGINT) RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH novos AS (
    INSERT INTO app.lembrete (pessoa_id, onda_id, dias_apos)
    SELECT p_pessoa, o.onda_id, d.dias
      FROM app.onda_instancia o
      CROSS JOIN (VALUES (7),(14),(28),(60)) d(dias)
     WHERE o.tema_id IS NOT NULL AND o.teste_num BETWEEN 3 AND 6
       AND o.onda_id = app.onda_da_pessoa(p_pessoa, o.tema_id, o.teste_num)
       AND o.data_abertura + make_interval(days => d.dias) <= now()
       AND app.teste_liberado(p_pessoa, o.tema_id, o.teste_num)
       AND NOT app.teste_submetido(p_pessoa, o.tema_id, o.teste_num)
       AND (o.pessoa_id = p_pessoa OR EXISTS (SELECT 1 FROM app.tema t WHERE t.tema_id = o.tema_id AND t.papel_curricular = 'nuclear'))
    UNION ALL
    SELECT p_pessoa, o.onda_id, -1
      FROM app.onda_instancia o
     WHERE o.tema_id IS NOT NULL AND o.teste_num = 2
       AND o.onda_id = app.onda_da_pessoa(p_pessoa, o.tema_id, o.teste_num)
       AND now() >= o.data_fechamento - interval '24 hours' AND now() < o.data_fechamento
       AND app.teste_liberado(p_pessoa, o.tema_id, o.teste_num)
       AND NOT app.teste_submetido(p_pessoa, o.tema_id, o.teste_num)
    ON CONFLICT (pessoa_id, onda_id, dias_apos) DO NOTHING
    RETURNING 1)
  SELECT count(*)::int FROM novos $$;

GRANT EXECUTE ON FUNCTION app.onda_da_pessoa(BIGINT,BIGINT,SMALLINT), app.prazo_vencido(BIGINT,BIGINT,SMALLINT) TO api_rw;
COMMIT;
\echo 'temas opcionais com D0 escolhido pelo residente: prontos'
