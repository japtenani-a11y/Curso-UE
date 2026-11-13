-- 48_agenda_aulas_v1.0.sql
-- Agenda das aulas do ciclo 2027-2028 (reunioes semanais, quintas-feiras as 20h, Google Meet).
--  Inicio 04/03/2027; termino previsto 24/02/2028; recesso de 17/11/2027 a 07/01/2028.
--  Sem aula: feriado na quinta; vespera de feriado (sexta); quinta logo depois de feriado na quarta.
--  Feriados considerados: nacionais, do estado de Sao Paulo, municipal de Ribeirao Preto (19/06)
--  e pontos facultativos do servico publico (Carnaval, Cinzas, Corpus Christi, Dia do Servidor,
--  vesperas de Natal e Ano-Novo). Fonte da lista de 2027: proximoferiado.net (Ribeirao Preto, 2027).
--  Entram so os 39 temas principais (nuclear, ver 53), na ordem de dificuldade (ordem_principal).
--  Os demais temas sao opcionais: cada residente escolhe o D0 (54).
-- Pre-requisito: 43 (agendar_ondas_tema) e 53 (temas). RODAR SO NO SERVIDOR: move as ondas do T001 para 2027. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.feriado (
  data   DATE PRIMARY KEY,
  nome   TEXT NOT NULL,
  esfera TEXT NOT NULL CHECK (esfera IN ('nacional','estadual','municipal','ponto_facultativo')));

INSERT INTO app.feriado (data, nome, esfera) VALUES
 ('2027-01-01','Confraternização Universal','nacional'),
 ('2027-02-08','Carnaval','ponto_facultativo'),
 ('2027-02-09','Carnaval','ponto_facultativo'),
 ('2027-02-10','Quarta-feira de Cinzas','ponto_facultativo'),
 ('2027-03-26','Sexta-feira Santa','nacional'),
 ('2027-04-21','Tiradentes','nacional'),
 ('2027-05-01','Dia do Trabalho','nacional'),
 ('2027-05-27','Corpus Christi','ponto_facultativo'),
 ('2027-06-19','Aniversário de Ribeirão Preto','municipal'),
 ('2027-07-09','Revolução Constitucionalista de 1932','estadual'),
 ('2027-09-07','Independência do Brasil','nacional'),
 ('2027-10-12','Nossa Senhora Aparecida','nacional'),
 ('2027-10-28','Dia do Servidor Público','ponto_facultativo'),
 ('2027-11-02','Finados','nacional'),
 ('2027-11-15','Proclamação da República','nacional'),
 ('2027-11-20','Dia da Consciência Negra','nacional'),
 ('2027-12-24','Véspera de Natal','ponto_facultativo'),
 ('2027-12-25','Natal','nacional'),
 ('2027-12-31','Véspera de Ano-Novo','ponto_facultativo'),
 ('2028-01-01','Confraternização Universal','nacional'),
 ('2028-02-28','Carnaval','ponto_facultativo'),
 ('2028-02-29','Carnaval','ponto_facultativo')
ON CONFLICT (data) DO UPDATE SET nome = EXCLUDED.nome, esfera = EXCLUDED.esfera;

CREATE TABLE IF NOT EXISTS app.agenda_aula (
  ciclo_id   BIGINT NOT NULL,
  ordem      SMALLINT NOT NULL,
  data_hora  TIMESTAMPTZ NOT NULL,
  tema_id    BIGINT REFERENCES app.tema(tema_id) ON DELETE SET NULL,
  link_meet  TEXT,
  PRIMARY KEY (ciclo_id, ordem),
  UNIQUE (ciclo_id, data_hora));
GRANT SELECT ON app.feriado, app.agenda_aula TO api_rw;

-- Datas sem aula no periodo, com o motivo (para conferencia).
CREATE OR REPLACE FUNCTION app.quintas_sem_aula(p_inicio DATE, p_fim DATE, p_rec_ini DATE, p_rec_fim DATE)
RETURNS TABLE (data DATE, motivo TEXT) LANGUAGE sql STABLE AS $$
  SELECT d::date,
         CASE WHEN d::date BETWEEN p_rec_ini AND p_rec_fim THEN 'recesso'
              WHEN f0.data IS NOT NULL THEN 'feriado: ' || f0.nome
              WHEN f1.data IS NOT NULL THEN 'véspera de feriado: ' || f1.nome
              ELSE 'quinta após feriado na quarta: ' || fm.nome END
    FROM generate_series(p_inicio, p_fim, interval '7 days') d
    LEFT JOIN app.feriado f0 ON f0.data = d::date
    LEFT JOIN app.feriado f1 ON f1.data = d::date + 1
    LEFT JOIN app.feriado fm ON fm.data = d::date - 1
   WHERE d::date BETWEEN p_rec_ini AND p_rec_fim OR f0.data IS NOT NULL OR f1.data IS NOT NULL OR fm.data IS NOT NULL $$;

-- Gera as datas de aula do ciclo (sempre no mesmo dia da semana de p_inicio, na hora p_hora de Brasilia).
CREATE OR REPLACE FUNCTION app.gerar_agenda_aulas(p_ciclo BIGINT, p_inicio DATE, p_fim DATE, p_hora TIME,
                                                  p_rec_ini DATE, p_rec_fim DATE)
RETURNS INT LANGUAGE plpgsql AS $$
DECLARE v INT;
BEGIN
  DELETE FROM app.agenda_aula WHERE ciclo_id = p_ciclo AND tema_id IS NULL;
  INSERT INTO app.agenda_aula (ciclo_id, ordem, data_hora)
  SELECT p_ciclo, row_number() OVER (ORDER BY d)::smallint, ((d::date + p_hora) AT TIME ZONE 'America/Sao_Paulo')
    FROM generate_series(p_inicio, p_fim, interval '7 days') d
   WHERE d::date NOT IN (SELECT data FROM app.quintas_sem_aula(p_inicio, p_fim, p_rec_ini, p_rec_fim))
  ON CONFLICT (ciclo_id, ordem) DO UPDATE SET data_hora = EXCLUDED.data_hora;
  GET DIAGNOSTICS v = ROW_COUNT;
  RETURN v;
END $$;

-- Coloca os temas do ciclo nas datas, em ordem de dificuldade, e agenda as 6 ondas de cada tema.
-- So mexe em datas ainda sem tema; temas ja alocados ficam onde estao.
CREATE OR REPLACE FUNCTION app.alocar_temas_agenda(p_ciclo BIGINT)
RETURNS TABLE (ordem SMALLINT, data_hora TIMESTAMPTZ, tema TEXT, dificuldade SMALLINT)
LANGUAGE plpgsql AS $$
#variable_conflict use_column
BEGIN
  WITH livres AS (
    SELECT a.ordem, row_number() OVER (ORDER BY a.ordem) AS n FROM app.agenda_aula a
     WHERE a.ciclo_id = p_ciclo AND a.tema_id IS NULL),
  pendentes AS (
    SELECT t.tema_id, row_number() OVER (ORDER BY t.ordem_principal, coalesce(t.dificuldade, 3), t.codigo) AS n FROM app.tema t
     WHERE t.ciclo_id = p_ciclo AND t.papel_curricular = 'nuclear'
       AND NOT EXISTS (SELECT 1 FROM app.agenda_aula a WHERE a.tema_id = t.tema_id))
  UPDATE app.agenda_aula a SET tema_id = p.tema_id
    FROM livres l JOIN pendentes p USING (n)
   WHERE a.ciclo_id = p_ciclo AND a.ordem = l.ordem;

  PERFORM app.agendar_ondas_tema(a.tema_id, a.data_hora)
     FROM app.agenda_aula a WHERE a.ciclo_id = p_ciclo AND a.tema_id IS NOT NULL;

  RETURN QUERY
  SELECT a.ordem, a.data_hora, t.codigo, t.dificuldade
    FROM app.agenda_aula a LEFT JOIN app.tema t ON t.tema_id = a.tema_id
   WHERE a.ciclo_id = p_ciclo ORDER BY a.ordem;
END $$;

-- Ciclo do T001: gera as 39 datas e aloca os temas cadastrados.
SELECT app.gerar_agenda_aulas((SELECT ciclo_id FROM app.tema WHERE replace(codigo,'-','') = 'T001'),
       DATE '2027-03-04', DATE '2028-02-24', TIME '20:00', DATE '2027-11-17', DATE '2028-01-07') AS aulas_no_ciclo;
SELECT * FROM app.quintas_sem_aula(DATE '2027-03-04', DATE '2028-02-24', DATE '2027-11-17', DATE '2028-01-07')
 WHERE motivo <> 'recesso';
SELECT * FROM app.alocar_temas_agenda((SELECT ciclo_id FROM app.tema WHERE replace(codigo,'-','') = 'T001'))
 WHERE tema IS NOT NULL;

COMMIT;
\echo 'agenda das aulas 2027-2028: pronta'
