-- 49_revisores_v1.0.sql
-- Cadastra quem entra no servidor de revisao com o login do Google:
--   coordenador (admin): japtenani@gmail.com
--   revisores (curador): aline@sardow.com e jorge.carnesecca@hotmail.com
-- O login do Google so abre sessao para e-mails cadastrados aqui (app.fn_sessao_google).
-- Cada e-mail precisa ser uma Conta Google (um e-mail que nao e Gmail pode virar Conta Google
-- em accounts.google.com, opcao "usar meu endereco de e-mail atual").
-- Tambem registra cada acesso as telas de conteudo (app.acesso_conteudo), para rastrear vazamento.
-- Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

INSERT INTO app.pessoa (nome_completo, email_primario) VALUES
  ('José Pezati', 'japtenani@gmail.com'),
  ('Aline (revisora)', 'aline@sardow.com'),
  ('Jorge Carnesecca (revisor)', 'jorge.carnesecca@hotmail.com')
ON CONFLICT (email_primario) DO NOTHING;

INSERT INTO app.designacao (pessoa_id, papel, vigencia_inicio)
SELECT p.pessoa_id, v.papel, DATE '2026-11-01'
  FROM (VALUES ('japtenani@gmail.com','admin'), ('aline@sardow.com','curador'),
               ('jorge.carnesecca@hotmail.com','curador')) v(email, papel)
  JOIN app.pessoa p ON lower(p.email_primario::text) = v.email
 WHERE NOT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p.pessoa_id AND d.papel = v.papel);

-- Registro de acesso as telas de conteudo (leitura, testes, revisao). So a funcao grava; ninguem le pela API.
CREATE TABLE IF NOT EXISTS app.acesso_conteudo (
  acesso_id  BIGSERIAL PRIMARY KEY,
  pessoa_id  BIGINT REFERENCES app.pessoa(pessoa_id) ON DELETE SET NULL,
  rota       TEXT NOT NULL,
  ip         INET,
  user_agent TEXT,
  em         TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS ix_acesso_pessoa_em ON app.acesso_conteudo (pessoa_id, em);
ALTER TABLE app.acesso_conteudo ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON app.acesso_conteudo FROM PUBLIC;

-- Grava o acesso e devolve quantos acessos a pessoa fez na ultima hora (a API limita o excesso).
CREATE OR REPLACE FUNCTION app.registrar_acesso(p_rota TEXT, p_ip INET, p_ua TEXT) RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.acesso_conteudo (pessoa_id, rota, ip, user_agent)
  VALUES (app.pessoa_atual(), left(p_rota, 200), p_ip, left(p_ua, 300));
  SELECT count(*)::int FROM app.acesso_conteudo
   WHERE pessoa_id = app.pessoa_atual() AND em > now() - interval '1 hour' $$;
REVOKE EXECUTE ON FUNCTION app.registrar_acesso(TEXT, INET, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.registrar_acesso(TEXT, INET, TEXT) TO api_rw;

-- Para o coordenador: quem acessou o que, por dia.
CREATE OR REPLACE VIEW app.vw_acessos_por_dia AS
  SELECT date_trunc('day', a.em)::date AS dia, p.email_primario::text AS email, a.rota, count(*) AS acessos
    FROM app.acesso_conteudo a LEFT JOIN app.pessoa p ON p.pessoa_id = a.pessoa_id
   GROUP BY 1, 2, 3;

-- Titulo do tema com acentos.
UPDATE app.tema SET titulo = 'Avaliação inicial do traumatizado' WHERE replace(codigo,'-','') = 'T001';

-- Arquiva os rascunhos que nao entram na revisao: tipos da versao antiga (item, gabarito, simulado)
-- e versoes anteriores de cada tipo. Nada e apagado; o historico fica com status 'arquivado'.
UPDATE conteudo.artefato a SET status = 'arquivado'
  FROM app.tema t
 WHERE a.tema_id = t.tema_id AND replace(t.codigo,'-','') = 'T001' AND a.status = 'rascunho'
   AND (a.tipo IN ('item','gabarito','simulado')
        OR a.versao < (SELECT max(x.versao) FROM conteudo.artefato x
                        WHERE x.tema_id = a.tema_id AND x.tipo = a.tipo AND x.status = 'rascunho'));

-- Arquiva os 12 artefatos de demonstracao publicados pela instalacao (texto "Conteudo do artefato ..."),
-- para o aluno nao ver material falso enquanto o T001 real esta em revisao.
UPDATE conteudo.artefato a SET status = 'arquivado'
  FROM app.tema t
 WHERE a.tema_id = t.tema_id AND replace(t.codigo,'-','') = 'T001' AND a.status = 'publicado'
   AND a.corpo LIKE 'Conteudo do artefato %' AND length(a.corpo) < 200;

SELECT p.email_primario, d.papel FROM app.designacao d JOIN app.pessoa p USING (pessoa_id)
 WHERE p.email_primario::text IN ('japtenani@gmail.com','aline@sardow.com','jorge.carnesecca@hotmail.com');
COMMIT;
\echo 'revisores cadastrados'
