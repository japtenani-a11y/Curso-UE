-- 85_estudo_pesquisa_v1.0.sql
-- Pedido da coordenacao em 16/11/2026: experiencia do aluno, teoria de aprendizagem e coleta para pesquisa.
--  (1) Situacao de cada peca do tema para o aluno: "feito", "visto" ou nada (abas agrupadas por etapa).
--  (2) Proxima acao: a coisa mais importante a fazer agora (cartao do Inicio).
--  (3) Repeticao espacada nas questoes ja vistas (caixas de Leitner: 1, 3, 7, 16, 35 e 90 dias; os flashcards ja tem
--      a sua desde o 73); revisao do dia; simulado "revisao" (questoes vencidas) e "misturado" (temas concluidos, intercalados).
--      Questao errada num teste, ou acertada sem certeza, volta antes; errar num simulado volta para a caixa 1.
--  (4) Calibracao devolvida ao aluno: quanto ele acerta quando marca cada nivel de certeza.
--  (5) Pesquisa: base por resposta com marcas de qualidade (resposta rapida demais, equipe, simulado, sem
--      consentimento, pre-teste 2 depois da aula, aula vista ao vivo ou depois); analise das questoes so com
--      dados validos (dificuldade, discriminacao ponto-bisserial, certeza e tempo); indicadores clinicos agregados
--      (numerador e denominador por mes, digitados pela coordenacao, nunca dado de paciente).
--  (6) Avisos no celular (web push): inscricoes por aparelho e canal 'push' na fila de notificacoes.
-- Pre-requisito: 45, 60, 68, 76, 81, 82, 83. Pode ser rodado mais de uma vez.
-- DESFAZER: rodar de novo 45 e 68 (montar_simulado); DROP das tabelas novas (item_revisao, indicador_clinico, push_inscricao) e das funcoes.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) situacao das pecas ----------
CREATE OR REPLACE FUNCTION app.situacao_pecas(p_codigo TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH t AS (SELECT tema_id FROM app.tema WHERE upper(replace(codigo, '-', '')) = upper(replace(p_codigo, '-', ''))),
  v AS (SELECT DISTINCT l.tipo FROM app.leitura_tempo l, t WHERE l.pessoa_id = app.pessoa_atual() AND l.tema_id = t.tema_id
        UNION SELECT DISTINCT u.tipo FROM app.uso_material u, t WHERE u.pessoa_id = app.pessoa_atual() AND u.tema_id = t.tema_id
        UNION SELECT e.peca FROM app.estado_material e, t WHERE e.pessoa_id = app.pessoa_atual() AND e.tema_id = t.tema_id AND e.peca <> '_tema'),
  f AS (SELECT e.peca FROM app.estado_material e, t
         WHERE e.pessoa_id = app.pessoa_atual() AND e.tema_id = t.tema_id
           AND ((e.peca = 'caso' AND (e.estado ->> 'fim') = 'true')
             OR (e.peca = 'caso_base' AND EXISTS (SELECT 1 FROM jsonb_each_text(CASE WHEN jsonb_typeof(e.estado -> 'respostas') = 'object' THEN e.estado -> 'respostas' ELSE '{}' END) x WHERE trim(x.value) <> ''))
             OR (e.peca = 'checklist' AND EXISTS (SELECT 1 FROM jsonb_each_text(CASE WHEN jsonb_typeof(e.estado -> 'marcados') = 'object' THEN e.estado -> 'marcados' ELSE '{}' END) x WHERE x.value = 'true'))))
  SELECT coalesce(jsonb_object_agg(v.tipo, CASE WHEN v.tipo IN (SELECT peca FROM f) THEN 'feito' ELSE 'visto' END), '{}'::jsonb) FROM v $$;

-- ---------- (3) repeticao espacada ----------
CREATE TABLE IF NOT EXISTS app.item_revisao (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  item_id   BIGINT NOT NULL REFERENCES app.item(item_id) ON DELETE CASCADE,
  caixa     SMALLINT NOT NULL DEFAULT 1,
  proxima   TIMESTAMPTZ NOT NULL,
  ultima    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (pessoa_id, item_id));
REVOKE ALL ON app.item_revisao FROM PUBLIC;

-- intervalo de cada caixa, em dias
CREATE OR REPLACE FUNCTION app.intervalo_caixa(p_caixa INT) RETURNS INTERVAL LANGUAGE sql IMMUTABLE AS $$
  SELECT make_interval(days => (ARRAY[1, 3, 7, 16, 35, 90])[greatest(1, least(6, p_caixa))]) $$;

-- questao vista num teste: errada volta amanha; certa com duvida em 3 dias; certa com certeza em 7
CREATE OR REPLACE FUNCTION app.fn_semear_revisao() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NEW.submetida_em IS NULL OR OLD.submetida_em IS NOT NULL THEN RETURN NEW; END IF;
  INSERT INTO app.item_revisao (pessoa_id, item_id, caixa, proxima, ultima)
  SELECT NEW.pessoa_id, r.item_id, x.c, NEW.submetida_em + app.intervalo_caixa(x.c), NEW.submetida_em
    FROM app.resposta r JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id,
         LATERAL (SELECT CASE WHEN NOT a.eh_correta THEN 1 WHEN coalesce(r.certeza, 2) < 3 THEN 2 ELSE 3 END AS c) x
   WHERE r.tentativa_id = NEW.tentativa_id
  ON CONFLICT (pessoa_id, item_id) DO UPDATE
     SET caixa = least(app.item_revisao.caixa, EXCLUDED.caixa), proxima = least(app.item_revisao.proxima, EXCLUDED.proxima), ultima = EXCLUDED.ultima;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_zzz_semear_revisao ON app.tentativa;
CREATE TRIGGER tg_zzz_semear_revisao AFTER UPDATE OF submetida_em ON app.tentativa FOR EACH ROW EXECUTE FUNCTION app.fn_semear_revisao();
-- testes ja enviados
INSERT INTO app.item_revisao (pessoa_id, item_id, caixa, proxima, ultima)
SELECT t.pessoa_id, r.item_id, min(CASE WHEN NOT a.eh_correta THEN 1 WHEN coalesce(r.certeza, 2) < 3 THEN 2 ELSE 3 END),
       min(t.submetida_em + app.intervalo_caixa(CASE WHEN NOT a.eh_correta THEN 1 WHEN coalesce(r.certeza, 2) < 3 THEN 2 ELSE 3 END)), max(t.submetida_em)
  FROM app.tentativa t JOIN app.resposta r ON r.tentativa_id = t.tentativa_id JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
 WHERE t.submetida_em IS NOT NULL
 GROUP BY t.pessoa_id, r.item_id
ON CONFLICT (pessoa_id, item_id) DO NOTHING;

-- resposta no simulado move a questao de caixa
CREATE OR REPLACE FUNCTION app.fn_revisao_simulado() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_p BIGINT; v_c INT;
BEGIN
  IF NEW.correta IS NULL THEN RETURN NEW; END IF;
  SELECT pessoa_id INTO v_p FROM app.simulado_aluno WHERE simulado_id = NEW.simulado_id;
  SELECT caixa INTO v_c FROM app.item_revisao WHERE pessoa_id = v_p AND item_id = NEW.item_id;
  v_c := CASE WHEN NEW.correta THEN least(6, coalesce(v_c, 1) + 1) ELSE 1 END;
  INSERT INTO app.item_revisao (pessoa_id, item_id, caixa, proxima, ultima)
  VALUES (v_p, NEW.item_id, v_c, now() + app.intervalo_caixa(v_c), now())
  ON CONFLICT (pessoa_id, item_id) DO UPDATE SET caixa = EXCLUDED.caixa, proxima = EXCLUDED.proxima, ultima = now();
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_revisao_simulado ON app.simulado_resposta;
CREATE TRIGGER tg_revisao_simulado AFTER INSERT OR UPDATE OF correta ON app.simulado_resposta FOR EACH ROW EXECUTE FUNCTION app.fn_revisao_simulado();

-- quanto ha para revisar hoje
CREATE OR REPLACE FUNCTION app.revisao_do_dia() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object(
    'questoes', (SELECT count(*) FROM app.item_revisao r JOIN app.questoes_estudo(app.pessoa_atual()) q ON q.item_id = r.item_id
                  WHERE r.pessoa_id = app.pessoa_atual() AND r.proxima <= now()),
    'cartoes', (SELECT coalesce((d->>'vencidos')::int, 0) + coalesce((d->>'novos')::int, 0) FROM app.flashcards_devidos() d),
    'temas_concluidos', (SELECT count(DISTINCT q.tema_id) FROM app.questoes_estudo(app.pessoa_atual()) q)) $$;

-- Simulado: modos "revisao" (questoes vencidas, temas intercalados) e "misturado" (todos os temas ja vistos,
-- intercalados); sem modo, como antes (filtros de tema e grau).
CREATE OR REPLACE FUNCTION app.montar_simulado(p JSONB) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_p BIGINT := app.pessoa_atual(); v_itens BIGINT[]; v_id BIGINT;
        v_min INT := greatest(1, least(6, coalesce((p->>'grau_min')::int, 1)));
        v_max INT := greatest(1, least(6, coalesce((p->>'grau_max')::int, 6)));
        v_n INT := greatest(1, least(60, coalesce((p->>'quantidade')::int, 10)));
        v_modo TEXT := coalesce(p->>'modo', '');
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT array_agg(item_id ORDER BY rodada, sorteio) INTO v_itens FROM (
    SELECT q.item_id, random() AS sorteio,
           CASE WHEN v_modo IN ('revisao', 'misturado') THEN row_number() OVER (PARTITION BY q.tema_id ORDER BY coalesce(r.proxima, now()), random()) ELSE 1 END AS rodada
      FROM app.questoes_estudo(v_p) q JOIN app.tema t ON t.tema_id = q.tema_id
      LEFT JOIN app.item_revisao r ON r.pessoa_id = v_p AND r.item_id = q.item_id
     WHERE (v_modo IN ('revisao', 'misturado') OR q.grau BETWEEN least(v_min, v_max) AND greatest(v_min, v_max))
       AND (v_modo <> 'revisao' OR r.proxima <= now())
       AND (v_modo IN ('revisao', 'misturado') OR jsonb_array_length(coalesce(p->'temas', '[]')) = 0
            OR replace(t.codigo, '-', '') IN (SELECT replace(upper(x), '-', '') FROM jsonb_array_elements_text(p->'temas') x))
     ORDER BY 3, 2 LIMIT v_n) s;
  IF v_itens IS NULL THEN RAISE EXCEPTION 'sem_questoes'; END IF;
  INSERT INTO app.simulado_aluno (pessoa_id, filtros, itens) VALUES (v_p, p, v_itens) RETURNING simulado_id INTO v_id;
  RETURN app.simulado_ver(v_id);
END $$;

-- ---------- (2) proxima acao ----------
-- Ordem: aula acontecendo agora; teste com prazo nos proximos 3 dias; continuar o que estudou nos ultimos 3 dias;
-- outro teste disponivel; revisao do dia; proxima aula.
CREATE OR REPLACE FUNCTION app.proxima_acao() RETURNS JSONB
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE c RECORD; t RECORD; k RECORD; rv JSONB; n INT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RETURN NULL; END IF;
  SELECT * INTO c FROM app.calendario_aulas() a WHERE a.data_hora BETWEEN now() - interval '2 hours' AND now() + interval '15 minutes'
   ORDER BY a.data_hora LIMIT 1;
  IF FOUND THEN RETURN jsonb_build_object('tipo', 'aula', 'codigo', c.codigo, 'titulo', c.titulo, 'quando', c.data_hora,
    'texto', 'A aula de ' || c.codigo || ' é agora', 'botao', 'Abrir o tema', 'link', '/aluno/tema/' || replace(c.codigo, '-', '')); END IF;
  SELECT * INTO t FROM app.pendencias() x WHERE x.tipo = 'teste' ORDER BY x.prazo NULLS LAST, x.d0 LIMIT 1;
  IF FOUND AND t.prazo > now() AND t.prazo < now() + interval '3 days' THEN RETURN jsonb_build_object('tipo', 'teste', 'urgente', true, 'codigo', t.codigo,
    'titulo', t.titulo, 'prazo', t.prazo, 'texto', 'Faça o ' || lower(t.nome) || ' de ' || t.codigo, 'botao', 'Responder agora',
    'link', '/aluno/testes/' || replace(t.codigo, '-', '')); END IF;
  SELECT * INTO k FROM app.continuar_estudo() x WHERE x.em > now() - interval '3 days';
  IF FOUND THEN RETURN jsonb_build_object('tipo', 'continuar', 'codigo', k.codigo, 'titulo', k.titulo,
    'texto', 'Continue de onde parou: ' || k.nome || ' de ' || k.codigo, 'botao', 'Continuar',
    'link', '/aluno/leitura/' || replace(k.codigo, '-', '') || '?peca=' || k.peca); END IF;
  IF t.codigo IS NOT NULL THEN RETURN jsonb_build_object('tipo', 'teste', 'urgente', false, 'codigo', t.codigo, 'titulo', t.titulo,
    'prazo', t.prazo, 'texto', 'Faça o ' || lower(t.nome) || ' de ' || t.codigo || CASE WHEN t.prazo <= now() THEN ' (fora do prazo, mas ainda dá)' ELSE '' END,
    'botao', 'Responder',
    'link', '/aluno/testes/' || replace(t.codigo, '-', '')); END IF;
  rv := app.revisao_do_dia(); n := coalesce((rv ->> 'questoes')::int, 0) + coalesce((rv ->> 'cartoes')::int, 0);
  IF n > 0 THEN RETURN jsonb_build_object('tipo', 'revisao', 'questoes', rv -> 'questoes', 'cartoes', rv -> 'cartoes',
    'texto', 'Revisão do dia: ' || (rv ->> 'questoes') || ' questões e ' || (rv ->> 'cartoes') || ' cartões', 'botao', 'Revisar',
    'link', '/aluno/estudo?aba=simulado&modo=revisao'); END IF;
  SELECT * INTO c FROM app.calendario_aulas() a WHERE a.data_hora > now() ORDER BY a.data_hora LIMIT 1;
  IF FOUND THEN RETURN jsonb_build_object('tipo', 'proxima_aula', 'codigo', c.codigo, 'titulo', c.titulo, 'quando', c.data_hora,
    'texto', 'Próxima aula: ' || c.codigo, 'botao', 'Ver o tema', 'link', '/aluno/tema/' || replace(c.codigo, '-', '')); END IF;
  RETURN NULL;
END $$;

-- ---------- (4) calibracao do aluno ----------
CREATE OR REPLACE FUNCTION app.minha_calibracao() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH r AS (
    SELECT r.certeza, a.eh_correta AS ok FROM app.resposta r JOIN app.tentativa t ON t.tentativa_id = r.tentativa_id
      JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
     WHERE t.pessoa_id = app.pessoa_atual() AND t.submetida_em IS NOT NULL AND r.certeza IS NOT NULL)
  SELECT jsonb_build_object(
    'niveis', coalesce((SELECT jsonb_agg(jsonb_build_object('certeza', c, 'respostas', n, 'acertos', k) ORDER BY c)
                          FROM (SELECT certeza AS c, count(*) AS n, count(*) FILTER (WHERE ok) AS k FROM r GROUP BY certeza) x), '[]'::jsonb),
    'erros_com_certeza', (SELECT count(*) FROM r WHERE certeza = 3 AND NOT ok),
    'total', (SELECT count(*) FROM r)) $$;

-- ---------- (5) pesquisa ----------
CREATE OR REPLACE FUNCTION app.eh_equipe(p_pessoa BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p_pessoa) $$;
CREATE OR REPLACE FUNCTION app.eh_simulado(p_pessoa BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT EXISTS (SELECT 1 FROM app.pessoa p WHERE p.pessoa_id = p_pessoa AND p.email_primario::text ~ '@(simulado|setup|exemplo)\.local$') $$;
-- como a pessoa viu a aula: ao vivo (presenca registrada), depois (abriu aula ou slides) ou sem registro
CREATE OR REPLACE FUNCTION app.como_viu_aula(p_pessoa BIGINT, p_tema BIGINT) RETURNS TEXT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT CASE WHEN EXISTS (SELECT 1 FROM app.presenca pr WHERE pr.pessoa_id = p_pessoa AND pr.tema_id = p_tema
                            AND (pr.por_codigo OR pr.manual OR coalesce(pr.minutos_meet, 0) > 0)) THEN 'ao vivo'
              WHEN EXISTS (SELECT 1 FROM app.leitura_tempo l WHERE l.pessoa_id = p_pessoa AND l.tema_id = p_tema AND l.tipo IN ('aula', 'slides')) THEN 'depois'
              ELSE 'sem registro' END $$;

-- Base de analise: uma linha por resposta enviada, com as marcas para incluir ou excluir na analise.
DROP FUNCTION IF EXISTS app.pesquisa_respostas();
CREATE FUNCTION app.pesquisa_respostas()
RETURNS TABLE (participante TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, teste_num SMALLINT, teste TEXT,
               dias_da_aula NUMERIC, item TEXT, perfil_item TEXT, dificuldade SMALLINT, correta BOOLEAN, certeza SMALLINT,
               tempo_s NUMERIC, rapida BOOLEAN, apos_aula BOOLEAN, aula TEXT, equipe BOOLEAN, simulado BOOLEAN,
               consentiu BOOLEAN, valida BOOLEAN, enviada_em TIMESTAMPTZ, fixa BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(t.pessoa_id), pf.ano, pf.especialidade, pf.turma, tm.codigo, o.teste_num, app.nome_teste(o.teste_num),
         round(extract(epoch FROM t.submetida_em - app.d0_da_pessoa(t.pessoa_id, o.tema_id)) / 86400, 1),
         i.codigo, i.perfil, i.dificuldade, a.eh_correta, r.certeza,
         round(r.tempo_resposta_ms / 1000.0, 1), coalesce(r.tempo_resposta_ms < 3000, false), t.apos_aula,
         app.como_viu_aula(t.pessoa_id, o.tema_id), app.eh_equipe(t.pessoa_id), app.eh_simulado(t.pessoa_id),
         coalesce(c.aceito, false),
         NOT coalesce(r.tempo_resposta_ms < 3000, false) AND NOT t.apos_aula AND NOT app.eh_equipe(t.pessoa_id)
           AND NOT app.eh_simulado(t.pessoa_id) AND coalesce(c.aceito, false),
         t.submetida_em, i.fixa   -- fixa: questao ancora, igual nas seis ondas e para todos os anos
    FROM app.resposta r JOIN app.tentativa t ON t.tentativa_id = r.tentativa_id AND t.submetida_em IS NOT NULL
    JOIN app.onda_instancia o ON o.onda_id = t.onda_id JOIN app.tema tm ON tm.tema_id = o.tema_id
    JOIN app.item i ON i.item_id = r.item_id JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
    LEFT JOIN app.consentimento_pesquisa c ON c.pessoa_id = t.pessoa_id
    CROSS JOIN LATERAL app.perfil_aluno(t.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
     -- o pesquisador so recebe quem consentiu
     AND (app.papel_painel() <> 'pesquisador' OR coalesce(c.aceito, false))
   ORDER BY 1, 5, 6, i.codigo $$;

-- Analise das questoes: so respostas validas da primeira vez que a pessoa viu a questao.
-- Discriminacao ponto-bisserial corrigida (acerto na questao x nota no resto do teste).
DROP FUNCTION IF EXISTS app.analise_itens();
DROP FUNCTION IF EXISTS app.analise_itens(BOOLEAN);
CREATE FUNCTION app.analise_itens(p_incluir_simulados BOOLEAN DEFAULT false)
RETURNS TABLE (tema TEXT, teste TEXT, item TEXT, perfil TEXT, dificuldade SMALLINT, respostas INT, acerto_pct NUMERIC,
               discriminacao NUMERIC, certeza_media NUMERIC, acerto_com_certeza_pct NUMERIC, tempo_mediano_s NUMERIC, situacao TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH b AS (
    SELECT t.tentativa_id, t.pessoa_id, o.tema_id, o.teste_num, r.item_id, a.eh_correta::int AS ok, r.certeza, r.tempo_resposta_ms
      FROM app.resposta r JOIN app.tentativa t ON t.tentativa_id = r.tentativa_id AND t.submetida_em IS NOT NULL
      JOIN app.onda_instancia o ON o.onda_id = t.onda_id JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
     WHERE coalesce(r.tempo_resposta_ms, 99999) >= 3000 AND NOT t.apos_aula
       AND NOT app.eh_equipe(t.pessoa_id) AND (p_incluir_simulados OR NOT app.eh_simulado(t.pessoa_id))),
  tot AS (SELECT tentativa_id, sum(ok) AS s, count(*) AS n FROM b GROUP BY tentativa_id),
  x AS (SELECT b.*, (tot.s - b.ok)::numeric / greatest(tot.n - 1, 1) AS resto FROM b JOIN tot USING (tentativa_id)),
  e AS (SELECT item_id, teste_num, count(*)::int AS n, avg(ok) AS p, corr(ok, resto) AS rpb, avg(certeza) AS cm,
               avg(ok) FILTER (WHERE certeza = 3) AS p3, percentile_cont(0.5) WITHIN GROUP (ORDER BY tempo_resposta_ms) / 1000 AS tm
          FROM x GROUP BY item_id, teste_num)
  SELECT tm.codigo, app.nome_teste(e.teste_num), i.codigo, i.perfil, i.dificuldade, e.n, round(100 * e.p, 0), round(e.rpb::numeric, 2),
         round(e.cm, 2), round(100 * e.p3, 0), round(e.tm::numeric, 0),
         CASE WHEN e.n < 10 THEN 'poucas respostas (menos de 10)'
              WHEN e.p > 0.9 THEN 'fácil demais'
              WHEN e.p < 0.2 THEN 'difícil demais: conferir gabarito'
              WHEN e.rpb IS NULL OR e.rpb < 0.2 THEN 'discrimina mal'
              WHEN e.p3 IS NOT NULL AND e.p3 < 0.5 THEN 'muito erro com certeza: rever o ensino'
              ELSE 'ok' END
    FROM e JOIN app.item i ON i.item_id = e.item_id JOIN app.tema tm ON tm.tema_id = i.tema_id
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY 1, e.teste_num, 3 $$;

-- Indicadores da pratica clinica (Kirkpatrick nivel 3): totais do mes digitados pela coordenacao a partir do
-- registro de trauma do servico. So numeros agregados; nunca dado de paciente.
CREATE TABLE IF NOT EXISTS app.indicador_clinico (
  indicador TEXT NOT NULL CHECK (indicador ~ '^[a-z_]{3,40}$'),
  mes       DATE NOT NULL CHECK (extract(day FROM mes) = 1),
  numerador INT NOT NULL CHECK (numerador >= 0),
  denominador INT NOT NULL CHECK (denominador > 0 AND denominador >= numerador),
  fonte     TEXT CHECK (length(fonte) <= 200),
  registrado_por BIGINT REFERENCES app.pessoa(pessoa_id),
  registrado_em  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (indicador, mes));
REVOKE ALL ON app.indicador_clinico FROM PUBLIC;
CREATE OR REPLACE FUNCTION app.nome_indicador(p TEXT) RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p WHEN 'via_aerea_registrada' THEN 'Via aérea avaliada e registrada na admissão'
                WHEN 'temperatura_admissao' THEN 'Temperatura medida na admissão'
                WHEN 'aquecimento_iniciado' THEN 'Aquecimento iniciado na sala de trauma'
                WHEN 'terciaria_registrada' THEN 'Avaliação terciária registrada'
                WHEN 'lider_definido' THEN 'Líder da equipe definido antes da chegada'
                WHEN 'torniquete_horario' THEN 'Horário do torniquete registrado'
                ELSE p END $$;
CREATE OR REPLACE FUNCTION app.salvar_indicador(p_indicador TEXT, p_mes DATE, p_num INT, p_den INT, p_fonte TEXT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF app.role_atual() NOT IN ('admin', 'curador', 'data_steward') THEN RAISE EXCEPTION 'so_coordenacao' USING ERRCODE = '42501'; END IF;
  INSERT INTO app.indicador_clinico (indicador, mes, numerador, denominador, fonte, registrado_por)
  VALUES (p_indicador, date_trunc('month', p_mes)::date, p_num, p_den, left(p_fonte, 200), app.pessoa_atual())
  ON CONFLICT (indicador, mes) DO UPDATE SET numerador = EXCLUDED.numerador, denominador = EXCLUDED.denominador,
     fonte = EXCLUDED.fonte, registrado_por = EXCLUDED.registrado_por, registrado_em = now();
END $$;
DROP FUNCTION IF EXISTS app.painel_indicadores();
CREATE FUNCTION app.painel_indicadores()
RETURNS TABLE (indicador TEXT, codigo TEXT, mes DATE, numerador INT, denominador INT, pct NUMERIC, fonte TEXT, registrado_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.nome_indicador(indicador), indicador, mes, numerador, denominador, round(100.0 * numerador / denominador, 1), fonte, registrado_em
    FROM app.indicador_clinico WHERE app.papel_painel() IS NOT NULL ORDER BY indicador, mes $$;

-- ---------- (6) avisos no celular ----------
CREATE TABLE IF NOT EXISTS app.push_inscricao (
  endpoint   TEXT PRIMARY KEY CHECK (endpoint ~ '^https://' AND length(endpoint) <= 1000),
  pessoa_id  BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  aparelho   TEXT CHECK (length(aparelho) <= 200),
  ativo      BOOLEAN NOT NULL DEFAULT true,
  criado_em  TIMESTAMPTZ NOT NULL DEFAULT now(),
  ultimo_envio TIMESTAMPTZ);
REVOKE ALL ON app.push_inscricao FROM PUBLIC;
ALTER TABLE app.notificacao_saida ADD COLUMN IF NOT EXISTS exibida_em TIMESTAMPTZ;
ALTER TABLE app.notificacao_saida DROP CONSTRAINT IF EXISTS notificacao_saida_canal_check;
ALTER TABLE app.notificacao_saida ADD CONSTRAINT notificacao_saida_canal_check CHECK (canal = ANY (ARRAY['email', 'whatsapp', 'push']));

CREATE OR REPLACE FUNCTION app.push_inscrever(p_endpoint TEXT, p_aparelho TEXT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  INSERT INTO app.push_inscricao (endpoint, pessoa_id, aparelho) SELECT p_endpoint, app.pessoa_atual(), left(p_aparelho, 200)
   WHERE app.pessoa_atual() IS NOT NULL
  ON CONFLICT (endpoint) DO UPDATE SET pessoa_id = EXCLUDED.pessoa_id, aparelho = EXCLUDED.aparelho, ativo = true $$;
CREATE OR REPLACE FUNCTION app.push_cancelar(p_endpoint TEXT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  UPDATE app.push_inscricao SET ativo = false WHERE endpoint = p_endpoint AND pessoa_id = app.pessoa_atual() $$;
CREATE OR REPLACE FUNCTION app.push_situacao() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object('aparelhos', count(*)) FROM app.push_inscricao WHERE pessoa_id = app.pessoa_atual() AND ativo $$;
-- para o enviador: aparelhos ativos de uma pessoa, e desativar um aparelho que o servico de push recusou
CREATE OR REPLACE FUNCTION app.push_destinos(p_pessoa BIGINT) RETURNS TABLE (endpoint TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT endpoint FROM app.push_inscricao WHERE pessoa_id = p_pessoa AND ativo $$;
CREATE OR REPLACE FUNCTION app.push_desativar(p_endpoint TEXT) RETURNS VOID
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  UPDATE app.push_inscricao SET ativo = false WHERE endpoint = p_endpoint $$;
-- os mesmos lembretes do e-mail, para quem tem aparelho inscrito (destino = pessoa)
CREATE OR REPLACE FUNCTION app.enfileirar_push() RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v INT;
BEGIN
  INSERT INTO app.notificacao_saida (lembrete_id, pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT l.lembrete_id, l.pessoa_id, 'push', 'pessoa:' || l.pessoa_id, x.assunto, x.corpo, x.parametros
    FROM app.lembrete l JOIN app.onda_instancia o ON o.onda_id = l.onda_id
    CROSS JOIN LATERAL app.texto_lembrete(l.lembrete_id) x
   WHERE EXISTS (SELECT 1 FROM app.push_inscricao pi WHERE pi.pessoa_id = l.pessoa_id AND pi.ativo)
     AND l.lido_em IS NULL AND NOT app.teste_submetido(l.pessoa_id, o.tema_id, o.teste_num)
     AND (l.dias_apos <> -1 OR now() < o.data_fechamento)
     AND l.criado_em > now() - interval '3 days'
  ON CONFLICT (lembrete_id, canal) DO NOTHING;
  GET DIAGNOSTICS v = ROW_COUNT;
  RETURN v;
END $$;
-- o aparelho, ao receber o aviso, busca o texto (assim o conteudo nao passa pelo servico de push)
CREATE OR REPLACE FUNCTION app.push_pendentes() RETURNS TABLE (titulo TEXT, texto TEXT, caminho TEXT)
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH s AS (
    UPDATE app.notificacao_saida SET exibida_em = now()
     WHERE canal = 'push' AND pessoa_id = app.pessoa_atual() AND status IN ('enviada', 'simulada') AND exibida_em IS NULL
       AND enviado_em > now() - interval '2 days'
    RETURNING assunto, corpo, parametros)
  SELECT assunto, left(corpo, 240), coalesce(parametros ->> 'caminho', '/aluno') FROM s $$;

REVOKE EXECUTE ON FUNCTION app.proxima_acao(), app.situacao_pecas(TEXT), app.revisao_do_dia(), app.minha_calibracao(),
  app.pesquisa_respostas(), app.analise_itens(BOOLEAN), app.salvar_indicador(TEXT, DATE, INT, INT, TEXT), app.painel_indicadores(),
  app.push_inscrever(TEXT, TEXT), app.push_cancelar(TEXT), app.push_situacao(), app.push_destinos(BIGINT), app.push_desativar(TEXT),
  app.enfileirar_push(), app.push_pendentes() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.proxima_acao(), app.situacao_pecas(TEXT), app.revisao_do_dia(), app.minha_calibracao(),
  app.pesquisa_respostas(), app.analise_itens(BOOLEAN), app.salvar_indicador(TEXT, DATE, INT, INT, TEXT), app.painel_indicadores(),
  app.push_inscrever(TEXT, TEXT), app.push_cancelar(TEXT), app.push_situacao(), app.push_destinos(BIGINT), app.push_desativar(TEXT),
  app.enfileirar_push(), app.push_pendentes(), app.intervalo_caixa(INT), app.eh_equipe(BIGINT), app.eh_simulado(BIGINT),
  app.como_viu_aula(BIGINT, BIGINT) TO api_rw;

COMMIT;
\echo 'estudo e pesquisa (85): pronto'
