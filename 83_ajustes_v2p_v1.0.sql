-- 83_ajustes_v2p_v1.0.sql
-- Decisoes da coordenacao em 15/11/2026:
--  (1) Pre-teste 2 fora do prazo: quem nao fez ate 1 hora antes da aula recebe a aula no horario, como antes, e
--      continua podendo fazer o pre-teste 2 depois (ate 180 dias apos a aula, como os pos-testes). O que for enviado
--      depois da hora da aula fica marcado "feito depois da aula" (conteudo ja apresentado), na tentativa, na nota e
--      no painel, para separar na analise.
--  (2) Painel: respostas do caso da aula (por ponto e por tentativa) e do caso base (antes e depois da aula).
--  (3) Nome: o nome antigo do programa (por extenso e a sigla antiga) passa a "CUT" no material (todas as versoes).
--      Ficam como estao os registros historicos: termos ja aceitos (versoes antigas) e e-mails ja enviados.
-- Pre-requisito: 38, 55, 60, 64, 82. Pode ser rodado mais de uma vez.
-- DESFAZER: rodar de novo 38 e 64; DROP FUNCTION app.painel_caso, app.painel_caso_base;
--           DROP TRIGGER tg_zz_apos_aula ON app.tentativa; as colunas apos_aula podem ficar.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) pre-teste 2 depois da aula ----------
CREATE OR REPLACE FUNCTION app.onda_respondivel(p_onda BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM app.onda_instancia o
                  WHERE o.onda_id = p_onda AND o.data_abertura <= now()
                    AND ((o.status = 'aberta' AND (o.data_fechamento IS NULL OR now() < o.data_fechamento))
                         OR (o.teste_num = 2 AND o.status IN ('aberta', 'fechada') AND o.data_fechamento <= now()
                             AND now() < coalesce((SELECT d.data_abertura FROM app.onda_instancia d
                                                    WHERE d.tema_id = o.tema_id AND d.teste_num = 3
                                                      AND d.pessoa_id IS NOT DISTINCT FROM o.pessoa_id LIMIT 1),
                                                  o.data_fechamento) + interval '180 days'))) $$;

ALTER TABLE app.tentativa  ADD COLUMN IF NOT EXISTS apos_aula BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE app.nota_teste ADD COLUMN IF NOT EXISTS apos_aula BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN app.tentativa.apos_aula IS 'pre-teste 2 enviado depois da hora da aula (conteudo ja apresentado)';

-- Depois do calculo da nota (tg_nota_no_envio roda antes, pela ordem alfabetica dos gatilhos AFTER).
CREATE OR REPLACE FUNCTION app.fn_marcar_apos_aula() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_tema BIGINT; v_num SMALLINT; v_d0 TIMESTAMPTZ;
BEGIN
  IF NEW.submetida_em IS NULL OR OLD.submetida_em IS NOT NULL THEN RETURN NEW; END IF;
  SELECT o.tema_id, o.teste_num INTO v_tema, v_num FROM app.onda_instancia o WHERE o.onda_id = NEW.onda_id;
  IF v_num IS DISTINCT FROM 2 THEN RETURN NEW; END IF;
  v_d0 := app.d0_da_pessoa(NEW.pessoa_id, v_tema);
  IF v_d0 IS NOT NULL AND NEW.submetida_em >= v_d0 THEN
    UPDATE app.tentativa SET apos_aula = true WHERE tentativa_id = NEW.tentativa_id;
    UPDATE app.nota_teste SET apos_aula = true WHERE tentativa_id = NEW.tentativa_id;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_zz_apos_aula ON app.tentativa;
CREATE TRIGGER tg_zz_apos_aula AFTER UPDATE OF submetida_em ON app.tentativa
  FOR EACH ROW EXECUTE FUNCTION app.fn_marcar_apos_aula();

-- envios ja feitos
UPDATE app.tentativa t SET apos_aula = true
  FROM app.onda_instancia o
 WHERE o.onda_id = t.onda_id AND o.teste_num = 2 AND t.submetida_em IS NOT NULL AND NOT t.apos_aula
   AND t.submetida_em >= app.d0_da_pessoa(t.pessoa_id, o.tema_id);
UPDATE app.nota_teste n SET apos_aula = true FROM app.tentativa t
 WHERE t.tentativa_id = n.tentativa_id AND t.apos_aula AND NOT n.apos_aula;

-- Painel de notas (o 64 cria; aqui ganha a coluna "observacao").
DROP FUNCTION IF EXISTS app.painel_notas();
CREATE FUNCTION app.painel_notas()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, teste_num SMALLINT, teste TEXT,
               acertos SMALLINT, total SMALLINT, pct NUMERIC, esperado NUMERIC, nota_ponderada NUMERIC, tempo_s INT,
               submetida_em TIMESTAMPTZ, observacao TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(n.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, n.teste_num, app.nome_teste(n.teste_num),
         n.acertos, n.total, n.pct, n.esperado, n.nota_ponderada, n.tempo_total_s, n.submetida_em,
         CASE WHEN n.apos_aula THEN 'feito depois da aula (conteúdo já apresentado)' END
    FROM app.nota_teste n JOIN app.tema t ON t.tema_id = n.tema_id, LATERAL app.perfil_aluno(n.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY n.submetida_em $$;
REVOKE EXECUTE ON FUNCTION app.painel_notas() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.painel_notas() TO api_rw;

-- ---------- (2) painel: caso da aula e caso base ----------
DROP FUNCTION IF EXISTS app.painel_caso();
CREATE FUNCTION app.painel_caso()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, tentativa INT, ponto INT, conduta TEXT,
               certeza TEXT, comparacao TEXT, discussao_aberta BOOLEAN, alerta BOOLEAN, atualizado_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH e AS (SELECT pessoa_id, tema_id, estado, cliente_em FROM app.estado_material WHERE peca = 'caso'),
  tent AS (
    SELECT e.pessoa_id, e.tema_id, a.ord::int AS n, a.v -> 'pontos' AS pontos, coalesce((a.v ->> 'concluida_em')::timestamptz, e.cliente_em) AS em
      FROM e, jsonb_array_elements(CASE WHEN jsonb_typeof(e.estado -> 'anteriores') = 'array' THEN e.estado -> 'anteriores' ELSE '[]'::jsonb END) WITH ORDINALITY a(v, ord)
    UNION ALL
    SELECT e.pessoa_id, e.tema_id, coalesce(jsonb_array_length(CASE WHEN jsonb_typeof(e.estado -> 'anteriores') = 'array' THEN e.estado -> 'anteriores' END), 0) + 1,
           e.estado -> 'pontos', e.cliente_em
      FROM e)
  SELECT app.aluno_painel(x.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, x.n, p.key::int + 1,
         p.value ->> 'conduta',
         CASE p.value ->> 'certeza' WHEN '1' THEN 'chutei' WHEN '2' THEN 'acho que sim' WHEN '3' THEN 'tenho certeza' END,
         CASE p.value ->> 'comparacao' WHEN 'parecida' THEN 'parecida' WHEN 'em_parte' THEN 'em parte' WHEN 'diferente' THEN 'diferente' END,
         coalesce((p.value ->> 'revelado')::boolean, false),
         (p.value ->> 'certeza') = '3' AND (p.value ->> 'comparacao') = 'diferente',
         x.em
    FROM tent x JOIN app.tema t ON t.tema_id = x.tema_id,
         jsonb_each(CASE WHEN jsonb_typeof(x.pontos) = 'object' THEN x.pontos ELSE '{}'::jsonb END) p,
         LATERAL app.perfil_aluno(x.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL AND p.key ~ '^\d+$'
   ORDER BY 1, 5, 6, 7 $$;

DROP FUNCTION IF EXISTS app.painel_caso_base();
CREATE FUNCTION app.painel_caso_base()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, pergunta INT, antes_da_aula TEXT,
               depois_da_aula TEXT, travado_em TIMESTAMPTZ, atualizado_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH e AS (SELECT pessoa_id, tema_id, estado, cliente_em FROM app.estado_material WHERE peca = 'caso_base'),
  k AS (SELECT e.pessoa_id, e.tema_id, j.key FROM e,
          jsonb_object_keys(CASE WHEN jsonb_typeof(e.estado -> 'respostas') = 'object' THEN e.estado -> 'respostas' ELSE '{}'::jsonb END
                            || CASE WHEN jsonb_typeof(e.estado -> 'depois') = 'object' THEN e.estado -> 'depois' ELSE '{}'::jsonb END) j(key))
  SELECT app.aluno_painel(e.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, k.key::int,
         nullif(trim(e.estado -> 'respostas' ->> k.key), ''), nullif(trim(e.estado -> 'depois' ->> k.key), ''),
         (e.estado ->> 'travado_em')::timestamptz, e.cliente_em
    FROM k JOIN e ON e.pessoa_id = k.pessoa_id AND e.tema_id = k.tema_id
    JOIN app.tema t ON t.tema_id = e.tema_id, LATERAL app.perfil_aluno(e.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL AND k.key ~ '^\d+$'
   ORDER BY 1, 5, 6 $$;
REVOKE EXECUTE ON FUNCTION app.painel_caso(), app.painel_caso_base() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.painel_caso(), app.painel_caso_base() TO api_rw;

-- ---------- (3) nome CUT no material ----------
UPDATE conteudo.artefato
   SET corpo  = regexp_replace(regexp_replace(corpo, 'Programa de Cirurgia de Urg[eê]ncia e Trauma', 'CUT', 'g'), 'UE[ -]TRAUMA( 2027)?', 'CUT', 'g'),
       titulo = regexp_replace(regexp_replace(titulo, 'Programa de Cirurgia de Urg[eê]ncia e Trauma', 'CUT', 'g'), 'UE[ -]TRAUMA( 2027)?', 'CUT', 'g')
 WHERE (corpo ~ 'Programa de Cirurgia de Urg[eê]ncia e Trauma|UE[ -]TRAUMA' OR titulo ~ 'Programa de Cirurgia de Urg[eê]ncia e Trauma|UE[ -]TRAUMA')
   AND NOT (status = 'publicado' AND NOT checklist_conforme);

COMMIT;
\echo 'ajustes v2p (pre-teste 2 depois da aula, painel dos casos, nome CUT): prontos'
