-- 49_revisores_v1.0.sql
-- Cadastra quem entra no servidor de revisao com o login do Google (coordenador = admin; revisores = curador).
-- Os e-mails NAO ficam no repositorio: vem do arquivo ~/.config/curso-ue/revisores.csv, so no computador da
-- coordenacao, com uma linha por pessoa no formato   email;nome;papel;substitui
--   papel: admin ou curador. substitui: e-mail antigo da mesma pessoa (opcional) - o cadastro antigo recebe o e-mail
--   novo e guarda os pareceres; se os dois ja existem, o antigo perde o papel.
-- Quem chama passa o caminho:  psql ... -v revisores="$HOME/.config/curso-ue/revisores.csv" -f 49_revisores_v1.0.sql
-- Sem o arquivo, nenhum revisor e cadastrado ou alterado (os ja cadastrados continuam).
-- O login do Google so abre sessao para e-mails cadastrados aqui (app.fn_sessao_google). Cada e-mail precisa ser uma
-- Conta Google. Tambem registra cada acesso as telas de conteudo (app.acesso_conteudo), para rastrear vazamento.
-- Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

CREATE TEMP TABLE rev (email TEXT, nome TEXT, papel TEXT, substitui TEXT) ON COMMIT DROP;
\if :{?revisores}
  \set copia '\\copy rev FROM ' :'revisores' ' WITH (FORMAT csv, DELIMITER '';'')'
  :copia
\else
  \echo 'aviso: sem a variavel revisores (arquivo ~/.config/curso-ue/revisores.csv): revisores nao alterados'
\endif
UPDATE rev SET email = lower(trim(email)), papel = lower(trim(papel)), substitui = nullif(lower(trim(coalesce(substitui, ''))), '');
DELETE FROM rev WHERE email IS NULL OR email !~ '^[^@;\s]+@[^@;\s]+$' OR papel NOT IN ('admin', 'curador');

-- Troca de e-mail da mesma pessoa
UPDATE app.pessoa p SET email_primario = r.email, nome_completo = coalesce(nullif(trim(r.nome), ''), p.nome_completo)
  FROM rev r
 WHERE r.substitui IS NOT NULL AND lower(p.email_primario::text) = r.substitui
   AND NOT EXISTS (SELECT 1 FROM app.pessoa q WHERE lower(q.email_primario::text) = r.email);
UPDATE app.designacao d SET vigencia_fim = current_date
  FROM app.pessoa p, rev r
 WHERE p.pessoa_id = d.pessoa_id AND r.substitui IS NOT NULL AND lower(p.email_primario::text) = r.substitui
   AND d.vigencia_fim IS NULL;

INSERT INTO app.pessoa (nome_completo, email_primario)
  SELECT coalesce(nullif(trim(nome), ''), email), email FROM rev
ON CONFLICT (email_primario) DO NOTHING;

INSERT INTO app.designacao (pessoa_id, papel, vigencia_inicio)
SELECT p.pessoa_id, r.papel, DATE '2026-11-01'
  FROM rev r JOIN app.pessoa p ON lower(p.email_primario::text) = r.email
 WHERE NOT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p.pessoa_id AND d.papel::text = r.papel);

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

SELECT p.email_primario, d.papel, coalesce(d.vigencia_fim::text, 'vigente') AS situacao
  FROM app.designacao d JOIN app.pessoa p USING (pessoa_id)
 WHERE lower(p.email_primario::text) IN (SELECT email FROM rev UNION SELECT substitui FROM rev);
COMMIT;
\echo 'revisores cadastrados'
