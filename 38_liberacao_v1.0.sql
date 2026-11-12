-- 38_liberacao_v1.0.sql
-- Liberacao progressiva do tema para o aluno.
--   Etapa 1: so o pre-teste inicial (teste 1).
--   Etapa 2: material pre-reuniao + pre-teste 2      (libera ao submeter o teste 1)
--   Etapa 3: material da reuniao + pos-teste D0      (libera ao submeter o teste 2)
--   Etapa 4: material pos-reuniao + pos-testes D+15, D+45, D+90 (libera ao submeter o teste 3)
-- O gabarito de um teste so e liberado depois que o aluno submete aquele teste (rota da API).
-- Pre-requisito: 37_banco_questoes_v1.0.sql. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE app.onda_instancia
  ADD COLUMN IF NOT EXISTS tema_id BIGINT REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS teste_num SMALLINT;
ALTER TABLE app.onda_instancia DROP CONSTRAINT IF EXISTS onda_teste_check;
ALTER TABLE app.onda_instancia ADD CONSTRAINT onda_teste_check CHECK (teste_num IS NULL OR teste_num BETWEEN 1 AND 6);
CREATE UNIQUE INDEX IF NOT EXISTS uq_onda_tema_teste ON app.onda_instancia (tema_id, teste_num) WHERE tema_id IS NOT NULL;

-- Perfil de questoes a partir do grau mais recente da pessoa (NULL se o grau nao estiver cadastrado).
CREATE OR REPLACE FUNCTION app.perfil_da_pessoa(p_pessoa BIGINT) RETURNS TEXT
LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN g IS NULL THEN NULL ELSE app.perfil_questoes(g) END
    FROM (SELECT (SELECT pa.grau FROM app.posicao_anual pa
                   WHERE pa.pessoa_id = p_pessoa AND pa.ativo
                   ORDER BY pa.ano_letivo DESC LIMIT 1) AS g) x $$;

-- O aluno submeteu o teste n do tema?
CREATE OR REPLACE FUNCTION app.teste_submetido(p_pessoa BIGINT, p_tema BIGINT, p_teste SMALLINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM app.tentativa t JOIN app.onda_instancia o USING (onda_id)
                  WHERE t.pessoa_id = p_pessoa AND o.tema_id = p_tema AND o.teste_num = p_teste
                    AND t.submetida_em IS NOT NULL) $$;

-- Etapa liberada (1 a 4), sempre em sequencia.
CREATE OR REPLACE FUNCTION app.etapa_liberada(p_pessoa BIGINT, p_tema BIGINT) RETURNS INT
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint) THEN 1
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 2::smallint) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 3::smallint) THEN 3
    ELSE 4 END $$;

-- Em que etapa cada tipo de material e liberado (NULL = nunca vai ao aluno pela leitura).
CREATE OR REPLACE FUNCTION app.etapa_do_material(p_tipo TEXT) RETURNS INT
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE
    WHEN p_tipo IN ('objetivos','resumo_basico','podcast_roteiro','caso_base','sintese_evidencia',
                    'resumo','mapa','flashcard','protocolo','checklist') THEN 2
    WHEN p_tipo IN ('aula','caso','slides') THEN 3
    ELSE NULL END $$;

-- O teste n esta liberado para o aluno? (teste 1 sempre; teste 2 na etapa 2; teste 3 na etapa 3; 4 a 6 na etapa 4)
CREATE OR REPLACE FUNCTION app.teste_liberado(p_pessoa BIGINT, p_tema BIGINT, p_teste SMALLINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
  SELECT app.etapa_liberada(p_pessoa, p_tema) >= CASE WHEN p_teste <= 3 THEN p_teste ELSE 4 END $$;

GRANT EXECUTE ON FUNCTION app.perfil_da_pessoa(BIGINT), app.teste_submetido(BIGINT,BIGINT,SMALLINT),
  app.etapa_liberada(BIGINT,BIGINT), app.etapa_do_material(TEXT), app.teste_liberado(BIGINT,BIGINT,SMALLINT),
  app.perfil_questoes(app.grau_enum) TO api_rw;

COMMIT;
\echo 'liberacao progressiva: funcoes prontas'
