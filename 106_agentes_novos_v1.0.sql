-- 106 · Agentes novos (decisão da coordenação de 19/11/2026): planejador de liberação (semanal), análise das ondas (mensal)
-- e supervisor propondo lacunas (banco de projetos) e indicadores (catálogo). Idempotente.
-- Aprovar uma proposta "liberacao" libera o tema para o produtor: a ponte acrescenta a linha em producao\liberados.csv.

ALTER TABLE app.proposta_agente DROP CONSTRAINT IF EXISTS proposta_agente_agente_check;
ALTER TABLE app.proposta_agente ADD CONSTRAINT proposta_agente_agente_check
  CHECK (agente = ANY (ARRAY['duvidas','pecas','conteudo','atrasados','indicadores','fontes','planejador','ondas','supervisor']));

CREATE OR REPLACE FUNCTION app.coord_tipo_valido(p_agente TEXT, p_tipo TEXT) RETURNS BOOLEAN
LANGUAGE sql IMMUTABLE AS $$
  SELECT (p_agente, p_tipo) IN (('duvidas', 'resposta'), ('duvidas', 'alerta'), ('pecas', 'pre_revisao'),
          ('conteudo', 'parecer'), ('atrasados', 'relatorio'), ('atrasados', 'lembrete'),
          ('indicadores', 'lancamento'), ('indicadores', 'pendencia'), ('fontes', 'fonte'),
          ('planejador', 'liberacao'), ('planejador', 'relatorio'), ('ondas', 'ajuste'), ('ondas', 'relatorio'),
          ('supervisor', 'projeto'), ('supervisor', 'indicador')) $$;

CREATE TABLE IF NOT EXISTS app.liberacao_producao (
  tema         TEXT PRIMARY KEY,
  liberado_em  DATE NOT NULL,
  proposta_id  BIGINT,
  registrado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION app.fn_liberacao_aprovada() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, app AS $$
DECLARE f JSONB; t TEXT; d DATE;
BEGIN
  IF NEW.tipo = 'liberacao' AND NEW.status IN ('aprovada', 'alterada') AND OLD.status = 'aguardando' THEN
    f := coalesce(NEW.decisao, NEW.proposta);
    t := upper(replace(trim(coalesce(f ->> 'tema', NEW.alvo ->> 'tema', '')), '-', ''));
    IF t ~ '^T[0-9]{3}$' THEN
      BEGIN d := nullif(f ->> 'data', '')::date; EXCEPTION WHEN others THEN d := NULL; END;
      INSERT INTO app.liberacao_producao (tema, liberado_em, proposta_id) VALUES (t, coalesce(d, current_date), NEW.proposta_id)
      ON CONFLICT (tema) DO NOTHING;
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_liberacao_aprovada ON app.proposta_agente;
CREATE TRIGGER tg_liberacao_aprovada AFTER UPDATE OF status ON app.proposta_agente
  FOR EACH ROW EXECUTE FUNCTION app.fn_liberacao_aprovada();

-- Pacote dos agentes, com os novos; os antigos continuam em app.coord_pacote
CREATE OR REPLACE FUNCTION app.coord_pacote_v2(p_agente TEXT) RETURNS JSONB
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE dados JSONB;
BEGIN
  IF p_agente = 'planejador' THEN
    SELECT jsonb_build_object(
      'regra', 'produção pronta 6 semanas antes da aula; revisão concluída e publicado 3 semanas antes; o produtor leva cerca de 8 dias (15 sessões, 2 por dia) por tema',
      'temas', CASE WHEN to_regprocedure('app.prazos_temas_base()') IS NULL THEN '[]'::jsonb ELSE
        (SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY x.aula NULLS LAST), '[]') FROM app.prazos_temas_base() x
          WHERE x.aula IS NULL OR x.aula <= current_date + 240) END,
      'liberados_pelo_painel', (SELECT coalesce(jsonb_agg(jsonb_build_object('tema', tema, 'liberado_em', liberado_em) ORDER BY liberado_em), '[]')
                                 FROM app.liberacao_producao))
      INTO dados;
  ELSIF p_agente = 'ondas' THEN
    -- só agregados, sem nenhum dado de aluno; contas simuladas fora
    WITH r AS (
      SELECT i.item_id, i.codigo, i.teste_num, t.codigo AS tema, o.onda_codigo, x.alternativa_id, x.certeza, al.eh_correta, al.ordem
        FROM app.resposta x
        JOIN app.tentativa tt ON tt.tentativa_id = x.tentativa_id AND tt.submetida_em IS NOT NULL
        JOIN app.onda_instancia o ON o.onda_id = tt.onda_id
        JOIN app.item i ON i.item_id = x.item_id
        JOIN app.tema t ON t.tema_id = i.tema_id
        JOIN app.alternativa al ON al.alternativa_id = x.alternativa_id
       WHERE NOT app.eh_simulado(tt.pessoa_id) AND tt.submetida_em > now() - interval '180 days')
    SELECT jsonb_build_object(
      'analise_itens', (SELECT coalesce(jsonb_agg(to_jsonb(a)), '[]') FROM app.analise_itens(false) a),
      'distratores', (SELECT coalesce(jsonb_agg(jsonb_build_object('tema', tema, 'item', codigo, 'teste', teste_num, 'alternativa', ordem,
                         'correta', eh_correta, 'escolhas', n, 'com_certeza_alta', n3)), '[]')
                       FROM (SELECT tema, codigo, teste_num, ordem, eh_correta, count(*) n, count(*) FILTER (WHERE certeza = 3) n3
                               FROM r GROUP BY 1, 2, 3, 4, 5) d),
      'erro_com_certeza_alta', (SELECT coalesce(jsonb_agg(jsonb_build_object('tema', tema, 'item', codigo, 'teste', teste_num,
                         'respostas', n, 'erros_com_tenho_certeza', e3, 'pct', round(100.0 * e3 / n, 1)) ORDER BY e3 DESC), '[]')
                       FROM (SELECT tema, codigo, teste_num, count(*) n, count(*) FILTER (WHERE NOT eh_correta AND certeza = 3) e3
                               FROM r GROUP BY 1, 2, 3) z WHERE e3 > 0),
      'minimo_respostas_para_concluir', 20)
      INTO dados;
  ELSIF p_agente = 'supervisor' THEN
    dados := app.coord_pacote('supervisor') - 'agente' - 'gerado_em' - 'formato' - 'decisoes_recentes' - 'aguardando_sua_revisao';
    dados := dados || jsonb_build_object('guias_publicados', (
      SELECT coalesce(jsonb_agg(jsonb_build_object('tema', t.codigo, 'versao', a.versao,
               'lacunas', substring(a.corpo FROM '## Limitações e lacunas(.*?)(\n## |$)'),
               'indicadores', substring(a.corpo FROM '## Indicadores de qualidade(.*?)(\n## |$)'))), '[]')
        FROM (SELECT DISTINCT ON (tema_id) * FROM conteudo.artefato WHERE tipo::text = 'protocolo' AND status::text = 'publicado'
               ORDER BY tema_id, versao DESC) a JOIN app.tema t ON t.tema_id = a.tema_id));
  ELSE
    RETURN app.coord_pacote(p_agente);
  END IF;
  RETURN jsonb_build_object('agente', p_agente, 'gerado_em', now(), 'formato', 1,
           'decisoes_recentes', app.coord_retorno(p_agente),
           'aguardando_sua_revisao', (SELECT count(*) FROM app.proposta_agente WHERE agente = p_agente AND status = 'aguardando')) || dados;
END $$;

-- A ponte lê por aqui os temas liberados pelo painel, para acrescentar em producao\liberados.csv
CREATE OR REPLACE FUNCTION app.coord_liberados() RETURNS TABLE(tema TEXT, liberado_em DATE)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app AS $$
  SELECT tema, liberado_em FROM app.liberacao_producao ORDER BY liberado_em, tema $$;
