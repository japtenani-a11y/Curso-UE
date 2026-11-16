-- ============================================================
-- 89_coordenacao_agentes_v1.0.sql
-- OBJETIVO: rotina da coordenacao com agentes que PROPOEM e uma pessoa da coordenacao que DECIDE.
--  Agentes: duvidas (responder em ate 24 h), pecas (pre-revisao de formato, didatica e texto), conteudo (parecer
--  sugerido para cada afirmacao, com a fonte), atrasados (painel semanal e lembretes) e indicadores (lancamento mensal).
--  - app.coord_pacote(agente): o que o agente precisa, exportado pela ponte (ponte_coordenacao_v1.0.sh) para a pasta
--    CUT_coordenacao\entrada do Windows. Inclui as ultimas decisoes da coordenacao sobre esse agente (o que foi vetado e
--    por que), para ele nao repetir o erro.
--  - app.coord_receber(json): a ponte grava as propostas que o agente deixou em CUT_coordenacao\propostas.
--  - app.decidir_proposta(id, aprovar|alterar|vetar, texto editado, motivo): so a coordenacao; ao aprovar, o sistema
--    executa (publica a resposta, registra o parecer, envia o lembrete, lanca o indicador).
--  - app.painel_propostas(), app.painel_agentes(): aba "Para revisar" do painel e o desempenho de cada agente.
--  O agente nunca escreve no banco: so a ponte grava propostas, e nada chega ao aluno sem a aprovacao de uma pessoa.
-- PRE-REQUISITO: 58, 85, 88. Pode ser rodado mais de uma vez.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.proposta_agente (
  proposta_id   BIGSERIAL PRIMARY KEY,
  agente        TEXT NOT NULL,
  tipo          TEXT NOT NULL,
  alvo          JSONB NOT NULL DEFAULT '{}'::jsonb,
  titulo        TEXT NOT NULL,
  proposta      JSONB NOT NULL,
  justificativa TEXT,
  fontes        JSONB NOT NULL DEFAULT '[]'::jsonb,
  confianca     TEXT CHECK (confianca IN ('alta', 'media', 'baixa')),
  rodada        TEXT,
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT now(),
  status        TEXT NOT NULL DEFAULT 'aguardando' CHECK (status IN ('aguardando', 'aprovada', 'alterada', 'vetada', 'substituida')),
  decisao       JSONB,
  motivo        TEXT,
  decidido_por  BIGINT REFERENCES app.pessoa (pessoa_id),
  decidido_em   TIMESTAMPTZ,
  erro_execucao TEXT
);
ALTER TABLE app.proposta_agente DROP CONSTRAINT IF EXISTS proposta_agente_agente_check;
ALTER TABLE app.proposta_agente ADD CONSTRAINT proposta_agente_agente_check
  CHECK (agente IN ('duvidas', 'pecas', 'conteudo', 'atrasados', 'indicadores', 'fontes'));
CREATE INDEX IF NOT EXISTS ix_proposta_status ON app.proposta_agente (status, agente, criado_em);
CREATE INDEX IF NOT EXISTS ix_proposta_alvo ON app.proposta_agente USING gin (alvo);
REVOKE ALL ON app.proposta_agente FROM PUBLIC;

-- Tipos de proposta aceitos de cada agente
CREATE OR REPLACE FUNCTION app.coord_tipo_valido(p_agente TEXT, p_tipo TEXT) RETURNS BOOLEAN
LANGUAGE sql IMMUTABLE AS $$
  SELECT (p_agente, p_tipo) IN (('duvidas', 'resposta'), ('duvidas', 'alerta'), ('pecas', 'pre_revisao'),
          ('conteudo', 'parecer'), ('atrasados', 'relatorio'), ('atrasados', 'lembrete'),
          ('indicadores', 'lancamento'), ('indicadores', 'pendencia'), ('fontes', 'fonte')) $$;

-- Ultimas decisoes sobre o agente: o retorno que ele le antes de trabalhar
CREATE OR REPLACE FUNCTION app.coord_retorno(p_agente TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app AS $$
  SELECT coalesce(jsonb_agg(x ORDER BY x->>'decidido_em' DESC), '[]'::jsonb) FROM (
    SELECT jsonb_build_object('tipo', tipo, 'alvo', alvo, 'titulo', titulo, 'status', status, 'motivo', motivo, 'decidido_em', decidido_em,
             'proposta', proposta, 'versao_final', CASE WHEN status = 'alterada' THEN decisao END) AS x
      FROM app.proposta_agente WHERE agente = p_agente AND status IN ('aprovada', 'alterada', 'vetada')
     ORDER BY (status <> 'aprovada') DESC, decidido_em DESC LIMIT 40) s $$;

CREATE OR REPLACE FUNCTION app.coord_tem_proposta(p_agente TEXT, p_chave TEXT, p_valor TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app AS $$
  SELECT EXISTS (SELECT 1 FROM app.proposta_agente WHERE agente = p_agente AND alvo ->> p_chave = p_valor
                    AND status IN ('aguardando', 'aprovada', 'alterada')) $$;

-- Trecho da fonte em volta da citacao literal (para o agente conferir sem ler o artigo inteiro)
CREATE OR REPLACE FUNCTION app.coord_trecho_fonte(p_texto TEXT, p_trecho TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$
  -- espacos, quebras de linha e hifenizacao do PDF normalizados antes de procurar o inicio da citacao
  WITH n AS (SELECT regexp_replace(regexp_replace(coalesce(p_texto, ''), '-\s*\n\s*', '', 'g'), '\s+', ' ', 'g') AS t,
                    lower(left(regexp_replace(coalesce(p_trecho, ''), '\s+', ' ', 'g'), 50)) AS q)
  SELECT CASE WHEN p_texto IS NULL OR length(q) < 10 OR position(q IN lower(t)) = 0 THEN NULL
              ELSE substr(t, greatest(1, position(q IN lower(t)) - 1200), 2800) END FROM n $$;

-- ---------- revisao uma vez por texto (decisao da coordenacao, 16/11/2026) ----------
-- O parecer dado a uma afirmacao vale para as copias identicas (mesmo texto e mesma fonte) nas outras pecas do mesmo tema,
-- em nome da mesma pessoa, com a origem anotada no comentario. Vale para o revisor na tela de revisao e para a
-- coordenacao ao aprovar a sugestao do agente.
CREATE OR REPLACE FUNCTION conteudo.fn_parecer_replica() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, conteudo, app AS $fn$
BEGIN
  IF pg_trigger_depth() > 1 OR coalesce(NEW.afirmacao_codigo, '') = '' THEN RETURN NEW; END IF;
  INSERT INTO conteudo.parecer_revisao (artefato_id, afirmacao_codigo, pessoa_id, decisao, comentario)
  SELECT f2.artefato_id, f2.codigo, NEW.pessoa_id, NEW.decisao,
         left(concat_ws(' ', NEW.comentario, '[mesmo parecer dado em ' || app.nome_material(a.tipo::text) || ', ' || NEW.afirmacao_codigo || ']'), 4000)
    FROM conteudo.afirmacao f JOIN conteudo.artefato a ON a.artefato_id = f.artefato_id
    JOIN conteudo.artefato a2 ON a2.tema_id = a.tema_id AND a2.status::text IN ('rascunho', 'publicado')
    JOIN conteudo.afirmacao f2 ON f2.artefato_id = a2.artefato_id AND f2.texto = f.texto
                              AND coalesce(f2.fonte_arquivo, '') = coalesce(f.fonte_arquivo, '')
   WHERE f.artefato_id = NEW.artefato_id AND f.codigo = NEW.afirmacao_codigo
     AND NOT (f2.artefato_id = NEW.artefato_id AND f2.codigo = NEW.afirmacao_codigo)
  ON CONFLICT (artefato_id, afirmacao_codigo, pessoa_id)
  DO UPDATE SET decisao = EXCLUDED.decisao, comentario = EXCLUDED.comentario, criado_em = now();
  RETURN NEW;
END $fn$;
DROP TRIGGER IF EXISTS tg_parecer_replica ON conteudo.parecer_revisao;
CREATE TRIGGER tg_parecer_replica AFTER INSERT OR UPDATE OF decisao, comentario ON conteudo.parecer_revisao
  FOR EACH ROW EXECUTE FUNCTION conteudo.fn_parecer_replica();

-- Data da aula do tema: a agenda planejada (92_prazos_producao) ou, sem ela, a abertura do pos-teste D0.
CREATE OR REPLACE FUNCTION app.data_aula_planejada(p_tema BIGINT) RETURNS TIMESTAMPTZ
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, app AS $fn$
DECLARE d TIMESTAMPTZ;
BEGIN
  IF to_regclass('app.aula_planejada') IS NOT NULL THEN
    EXECUTE 'SELECT (data + time ''20:00'') AT TIME ZONE ''America/Sao_Paulo'' FROM app.aula_planejada WHERE tema_id = $1' INTO d USING p_tema;
  END IF;
  RETURN coalesce(d, (SELECT min(o.data_abertura) FROM app.onda_instancia o WHERE o.tema_id = p_tema AND o.teste_num = 3 AND o.pessoa_id IS NULL));
END $fn$;

-- ---------- fontes recebidas (triador de fontes) ----------
-- A coordenacao solta PDFs em CUT_coordenacao\fontes_novas. A ponte extrai o texto, confere se ha dado de paciente,
-- guarda o PDF em fontes_recebidas\F<8 letras do sha>_nome.pdf e registra aqui. O triador le, identifica a referencia
-- (PubMed), a camada e TODOS os temas em que a fonte serve (inclusive os que ainda serao produzidos). Aprovada a
-- triagem, a fonte entra em conteudo.fonte uma vez para cada tema, com o texto integral.
CREATE TABLE IF NOT EXISTS app.fonte_recebida (
  fonte_recebida_id BIGSERIAL PRIMARY KEY,
  sha256        TEXT NOT NULL UNIQUE,
  ref           TEXT NOT NULL UNIQUE,      -- F + 8 primeiros caracteres do sha: o codigo que as afirmacoes citam
  nome_original TEXT NOT NULL,
  arquivo       TEXT NOT NULL,             -- nome em fontes_recebidas
  texto         TEXT,
  caracteres    INT,
  recebido_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  status        TEXT NOT NULL DEFAULT 'nova' CHECK (status IN ('nova', 'guardada', 'recusada')),
  temas         TEXT[],
  triado_em     TIMESTAMPTZ);
REVOKE ALL ON app.fonte_recebida FROM PUBLIC;

CREATE OR REPLACE FUNCTION app.coord_registrar_fonte(p_sha TEXT, p_nome TEXT, p_arquivo TEXT, p_texto TEXT) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, app AS $fn$
DECLARE r TEXT;
BEGIN
  SELECT ref INTO r FROM app.fonte_recebida WHERE sha256 = p_sha;
  IF r IS NOT NULL THEN RETURN r || ' (ja recebida)'; END IF;
  r := 'F' || left(p_sha, 8);
  INSERT INTO app.fonte_recebida (sha256, ref, nome_original, arquivo, texto, caracteres)
  VALUES (p_sha, r, left(p_nome, 300), left(p_arquivo, 300), nullif(p_texto, ''), length(p_texto));
  RETURN r;
END $fn$;

-- ---------- pacote de cada agente ----------
CREATE OR REPLACE FUNCTION app.coord_pacote(p_agente TEXT) RETURNS JSONB
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE dados JSONB;
BEGIN
  IF p_agente = 'duvidas' THEN
    WITH d AS (
      SELECT m.mensagem_id, m.tema_id, t.codigo AS tema, m.ferramenta, m.texto, m.criado_em,
             round(extract(epoch FROM now() - m.criado_em) / 3600)::int AS horas_esperando, (app.perfil_aluno(m.pessoa_id)).ano AS ano
        FROM app.mensagem_aluno m LEFT JOIN app.tema t ON t.tema_id = m.tema_id
       WHERE m.tipo = 'duvida' AND m.resposta IS NULL AND NOT app.coord_tem_proposta('duvidas', 'mensagem_id', m.mensagem_id::text)
       ORDER BY m.criado_em LIMIT 30)
    SELECT jsonb_build_object(
      'duvidas', coalesce((SELECT jsonb_agg(to_jsonb(d) - 'tema_id') FROM d), '[]'),
      'material', coalesce((SELECT jsonb_agg(jsonb_build_object('tema', tm.codigo, 'tipo', a.tipo, 'titulo', a.titulo, 'corpo', left(a.corpo, 15000)))
          FROM (SELECT DISTINCT ON (tema_id, tipo) * FROM conteudo.artefato WHERE status::text = 'publicado'
                  AND tipo::text IN ('objetivos', 'resumo_basico', 'resumo', 'sintese_evidencia', 'protocolo', 'aula', 'caso')
                ORDER BY tema_id, tipo, versao DESC) a JOIN app.tema tm ON tm.tema_id = a.tema_id
         WHERE a.tema_id IN (SELECT tema_id FROM d)), '[]'),
      'sem_resposta_24h', (SELECT count(*) FROM app.mensagem_aluno m WHERE m.tipo = 'duvida' AND m.resposta IS NULL
                             AND m.criado_em < now() - interval '24 hours'),
      'catalogo_temas', coalesce((SELECT jsonb_agg(jsonb_build_object('tema', tm.codigo, 'titulo', tm.titulo) ORDER BY tm.codigo)
          FROM app.tema tm WHERE EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = tm.tema_id AND a.status::text = 'publicado')), '[]'),
      'respondidas_antes', coalesce((SELECT jsonb_agg(jsonb_build_object('tema', t.codigo, 'pergunta', m.texto, 'resposta', m.resposta))
          FROM (SELECT * FROM app.mensagem_aluno WHERE tipo = 'duvida' AND resposta IS NOT NULL AND tema_id IN (SELECT tema_id FROM d)
                 ORDER BY respondida_em DESC LIMIT 15) m LEFT JOIN app.tema t ON t.tema_id = m.tema_id), '[]'))
      INTO dados;

  ELSIF p_agente = 'pecas' THEN
    SELECT jsonb_build_object('pecas', coalesce(jsonb_agg(jsonb_build_object(
             'artefato_id', a.artefato_id, 'tema', tm.codigo, 'titulo_tema', tm.titulo, 'tipo', a.tipo, 'versao', a.versao, 'titulo', a.titulo,
             'nome_material', app.nome_material(a.tipo::text), 'corpo', left(a.corpo, 40000),
             'aula_em', (SELECT min(o.data_abertura) FROM app.onda_instancia o WHERE o.tema_id = a.tema_id AND o.teste_num = 3 AND o.pessoa_id IS NULL),
             'objetivos_do_tema', (SELECT left(x.corpo, 12000) FROM conteudo.artefato x WHERE x.tema_id = a.tema_id AND x.tipo::text = 'objetivos'
                                    AND x.status::text IN ('publicado', 'rascunho') ORDER BY x.versao DESC LIMIT 1),
             'essencial_antes_da_aula_min', (SELECT sum(t.minutos) FROM (SELECT DISTINCT ON (y.tipo) y.artefato_id, y.tipo FROM conteudo.artefato y
                                    WHERE y.tema_id = a.tema_id AND y.status::text IN ('publicado', 'rascunho') AND app.etapa_do_material(y.tipo::text) = 2
                                    ORDER BY y.tipo, y.versao DESC) u CROSS JOIN LATERAL app.tempo_peca(u.artefato_id) t WHERE t.nivel = 'essencial'),
             'formato', app.formato_peca(a.artefato_id), 'tempo', (SELECT to_jsonb(x) FROM app.tempo_peca(a.artefato_id) x),
             -- peça da aula (aula, slides, caso): o material de antes da aula, para conferir que a aula não o repete
             'material_antes_da_aula', CASE WHEN app.etapa_do_material(a.tipo::text) = 3 THEN (
                SELECT jsonb_agg(jsonb_build_object('tipo', u.tipo, 'corpo', left(u.corpo, 15000)) ORDER BY u.tipo)
                  FROM (SELECT DISTINCT ON (y.tipo) y.tipo::text AS tipo, y.corpo FROM conteudo.artefato y
                         WHERE y.tema_id = a.tema_id AND y.status::text IN ('publicado', 'rascunho') AND app.etapa_do_material(y.tipo::text) = 2
                         ORDER BY y.tipo, y.versao DESC) u) END,
             'publicada_anterior', (SELECT left(p.corpo, 40000) FROM conteudo.artefato p WHERE p.tema_id = a.tema_id AND p.tipo = a.tipo
                                     AND p.status::text = 'publicado' ORDER BY p.versao DESC LIMIT 1))
             ORDER BY (SELECT min(o.data_abertura) FROM app.onda_instancia o WHERE o.tema_id = a.tema_id AND o.teste_num = 3 AND o.pessoa_id IS NULL) NULLS LAST,
                      tm.codigo, a.tipo), '[]'))
      INTO dados
      FROM (SELECT DISTINCT ON (tema_id, tipo) * FROM conteudo.artefato WHERE status::text = 'rascunho' ORDER BY tema_id, tipo, versao DESC) a
      JOIN app.tema tm ON tm.tema_id = a.tema_id
     WHERE NOT app.coord_tem_proposta('pecas', 'artefato_id', a.artefato_id::text);

  ELSIF p_agente = 'conteudo' THEN
    -- Uma entrada por TEXTO de afirmacao (a mesma afirmacao aparece em varias pecas do tema): o parecer dado a ela vale
    -- para todas as copias (gatilho tg_parecer_replica). Ate 120 textos por rodada, do tema com aula mais proxima.
    WITH pend AS (
      SELECT f.*, a.tema_id, a.tipo, a.versao, a.status::text AS status_peca, tm.codigo AS tema,
             app.data_aula_planejada(a.tema_id) AS aula
        FROM conteudo.afirmacao f JOIN conteudo.artefato a ON a.artefato_id = f.artefato_id
        JOIN app.tema tm ON tm.tema_id = a.tema_id
       WHERE a.status::text IN ('rascunho', 'publicado')
         AND NOT EXISTS (SELECT 1 FROM conteudo.parecer_revisao p WHERE p.artefato_id = f.artefato_id AND p.afirmacao_codigo = f.codigo)),
    grupo AS (
      SELECT DISTINCT ON (tema_id, texto, coalesce(fonte_arquivo, '')) *,
             count(*) OVER (PARTITION BY tema_id, texto, coalesce(fonte_arquivo, '')) AS ocorrencias,
             (SELECT array_agg(DISTINCT app.nome_material(x.tipo::text)) FROM pend x
               WHERE x.tema_id = pend.tema_id AND x.texto = pend.texto AND coalesce(x.fonte_arquivo, '') = coalesce(pend.fonte_arquivo, '')) AS pecas
        FROM pend
       ORDER BY tema_id, texto, coalesce(fonte_arquivo, ''), (status_peca = 'rascunho') DESC, artefato_id),
    escolha AS (
      SELECT g.* FROM grupo g
       WHERE NOT EXISTS (
         SELECT 1 FROM app.proposta_agente pa
           JOIN conteudo.afirmacao f2 ON f2.artefato_id = (pa.alvo ->> 'artefato_id')::bigint AND f2.codigo = pa.alvo ->> 'afirmacao_codigo'
           JOIN conteudo.artefato a2 ON a2.artefato_id = f2.artefato_id
          WHERE pa.agente = 'conteudo' AND pa.status IN ('aguardando', 'aprovada', 'alterada')
            AND a2.tema_id = g.tema_id AND f2.texto = g.texto AND coalesce(f2.fonte_arquivo, '') = coalesce(g.fonte_arquivo, ''))
       ORDER BY g.aula NULLS LAST, g.tema, g.codigo LIMIT 120)
    SELECT jsonb_build_object(
      'textos_pendentes_total', (SELECT count(*) FROM grupo),
      'afirmacoes', coalesce((SELECT jsonb_agg(jsonb_build_object(
          'artefato_id', p.artefato_id, 'tema', p.tema, 'aula_em', p.aula, 'peca', app.nome_material(p.tipo::text), 'versao', p.versao,
          'status_peca', p.status_peca, 'ocorrencias', p.ocorrencias, 'aparece_em', to_jsonb(p.pecas),
          'afirmacao_codigo', p.codigo, 'texto', p.texto, 'fonte_arquivo', p.fonte_arquivo, 'trecho_literal', p.trecho_literal,
          'fonte', (SELECT jsonb_build_object('titulo', fo.titulo, 'autores', fo.autores, 'ano', fo.ano, 'doi', fo.doi, 'pmid', fo.pmid,
                            'camada', fo.camada, 'arquivo', fo.arquivo_origem,
                            'contexto', app.coord_trecho_fonte(fo.texto_integral, p.trecho_literal),
                            'trecho_encontrado', app.coord_trecho_fonte(fo.texto_integral, p.trecho_literal) IS NOT NULL)
                      FROM conteudo.fonte fo
                     WHERE fo.tema_id = p.tema_id AND p.fonte_arquivo <> '' AND fo.arquivo_origem ILIKE '%' || p.fonte_arquivo || '%' LIMIT 1))
          ORDER BY p.aula NULLS LAST, p.tema, p.codigo) FROM escolha p), '[]'),
      'referencias_do_tema', coalesce((SELECT jsonb_agg(jsonb_build_object('tema', tm.codigo, 'camada', fo.camada, 'titulo', fo.titulo,
          'ano', fo.ano, 'doi', fo.doi, 'pmid', fo.pmid, 'arquivo', fo.arquivo_origem, 'tem_texto', fo.texto_integral IS NOT NULL))
          FROM conteudo.fonte fo JOIN app.tema tm ON tm.tema_id = fo.tema_id WHERE fo.tema_id IN (SELECT tema_id FROM escolha)), '[]'))
      INTO dados;

  ELSIF p_agente = 'atrasados' THEN
    WITH al AS (
      SELECT p.pessoa_id, split_part(p.nome_completo, ' ', 1) AS primeiro_nome, (app.perfil_aluno(p.pessoa_id)).ano AS ano
        FROM app.pessoa p WHERE app.eh_aluno_ativo(p.pessoa_id) AND NOT app.eh_equipe(p.pessoa_id)),
    ondas AS (
      SELECT al.pessoa_id, tm.codigo AS tema, o.teste_num, app.nome_teste(o.teste_num) AS teste, o.data_fechamento,
             app.onda_respondivel(o.onda_id) AS respondivel
        FROM al CROSS JOIN app.onda_instancia o JOIN app.tema tm ON tm.tema_id = o.tema_id
       WHERE o.tema_id IS NOT NULL AND o.onda_id = app.onda_da_pessoa(al.pessoa_id, o.tema_id, o.teste_num)
         AND app.teste_liberado(al.pessoa_id, o.tema_id, o.teste_num)
         AND o.data_fechamento BETWEEN now() - interval '45 days' AND now() + interval '3 days'
         AND NOT app.teste_submetido(al.pessoa_id, o.tema_id, o.teste_num))
    SELECT jsonb_build_object('semana', to_char(now(), 'IYYY-"S"IW'), 'alunos_ativos', (SELECT count(*) FROM al),
      'alunos', coalesce((SELECT jsonb_agg(jsonb_build_object(
          'pessoa_id', al.pessoa_id, 'primeiro_nome', al.primeiro_nome, 'ano', al.ano, 'simulado', app.eh_simulado(al.pessoa_id),
          'aceita_email', coalesce((SELECT c.aceita_email FROM app.contato_aluno c WHERE c.pessoa_id = al.pessoa_id), false),
          'avisos_celular', EXISTS (SELECT 1 FROM app.push_inscricao pi WHERE pi.pessoa_id = al.pessoa_id AND pi.ativo),
          'ultimo_envio', (SELECT max(t.submetida_em) FROM app.tentativa t WHERE t.pessoa_id = al.pessoa_id),
          'pendencias', (SELECT jsonb_agg(jsonb_build_object('tema', o.tema, 'teste', o.teste, 'prazo', o.data_fechamento,
                                 'situacao', CASE WHEN o.data_fechamento > now() THEN 'vence em breve' WHEN o.respondivel THEN 'atrasado, ainda dá para fazer' ELSE 'perdido' END)
                                 ORDER BY o.data_fechamento) FROM ondas o WHERE o.pessoa_id = al.pessoa_id)))
          FROM al WHERE EXISTS (SELECT 1 FROM ondas o WHERE o.pessoa_id = al.pessoa_id)), '[]'),
      'ja_lembrados_na_semana', coalesce((SELECT jsonb_agg(DISTINCT (alvo ->> 'pessoa_id')) FROM app.proposta_agente
          WHERE agente = 'atrasados' AND tipo = 'lembrete' AND alvo ->> 'semana' = to_char(now(), 'IYYY-"S"IW')), '[]'))
      INTO dados;

  ELSIF p_agente = 'indicadores' THEN
    SELECT jsonb_build_object(
      'indicadores', (SELECT jsonb_agg(jsonb_build_object('codigo', c, 'nome', app.nome_indicador(c)))
                        FROM unnest(ARRAY['via_aerea_registrada', 'temperatura_admissao', 'aquecimento_iniciado', 'terciaria_registrada',
                                          'lider_definido', 'torniquete_horario']) c),
      'registrados', coalesce((SELECT jsonb_agg(jsonb_build_object('indicador', indicador, 'mes', mes, 'numerador', numerador,
                        'denominador', denominador, 'fonte', fonte) ORDER BY indicador, mes) FROM app.indicador_clinico), '[]'),
      'mes_a_lancar', to_char(date_trunc('month', now()) - interval '1 month', 'YYYY-MM-01'),
      'inicio_da_serie', '2026-12-01')
      INTO dados;
  ELSIF p_agente = 'fontes' THEN
    SELECT jsonb_build_object(
      'fontes', coalesce((SELECT jsonb_agg(jsonb_build_object(
          'fonte_recebida_id', r.fonte_recebida_id, 'ref', r.ref, 'nome_original', r.nome_original,
          'arquivo', 'fontes_recebidas/' || r.arquivo, 'caracteres', r.caracteres, 'recebido_em', r.recebido_em,
          'inicio', left(r.texto, 12000), 'fim', CASE WHEN length(r.texto) > 16000 THEN right(r.texto, 4000) END,
          'ja_no_banco_em', (SELECT jsonb_agg(DISTINCT t.codigo) FROM conteudo.fonte f JOIN app.tema t ON t.tema_id = f.tema_id WHERE f.sha256 = r.sha256))
          ORDER BY r.recebido_em)
          FROM (SELECT * FROM app.fonte_recebida WHERE status = 'nova'
                   AND NOT app.coord_tem_proposta('fontes', 'fonte_recebida_id', fonte_recebida_id::text)
                   AND NOT app.coord_tem_proposta('fontes', 'sha256', sha256)
                 ORDER BY recebido_em LIMIT 15) r), '[]'),
      'catalogo_temas', (SELECT jsonb_agg(jsonb_build_object('tema', t.codigo, 'titulo', t.titulo, 'modulo', t.modulo,
          'papel', t.papel_curricular, 'aula', (SELECT ap.data FROM app.aula_planejada ap WHERE ap.tema_id = t.tema_id),
          'fontes_atuais', (SELECT count(*) FROM conteudo.fonte f WHERE f.tema_id = t.tema_id)) ORDER BY t.codigo)
          FROM app.tema t),
      'fontes_novas_total', (SELECT count(*) FROM app.fonte_recebida WHERE status = 'nova'))
      INTO dados;
  ELSIF p_agente = 'supervisor' THEN
    -- Prazos dos temas (92) e o placar de cada agente: o supervisor nao propoe, so avisa.
    SELECT jsonb_build_object(
      'prazos', CASE WHEN to_regprocedure('app.prazos_temas_base()') IS NULL THEN '[]'::jsonb ELSE
        (SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY x.aula), '[]') FROM app.prazos_temas_base() x
          WHERE x.situacao <> 'publicado' AND (x.aula <= current_date + 120 OR x.situacao LIKE '%atrasada%')) END,
      'placar_7_dias', (SELECT coalesce(jsonb_object_agg(g.ag, jsonb_build_object(
          'aguardando', (SELECT count(*) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'aguardando'),
          'mais_antiga_horas', (SELECT round(extract(epoch FROM now() - min(p.criado_em)) / 3600) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'aguardando'),
          'aprovadas', (SELECT count(*) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'aprovada' AND p.decidido_em > now() - interval '7 days'),
          'alteradas', (SELECT count(*) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'alterada' AND p.decidido_em > now() - interval '7 days'),
          'vetadas', (SELECT count(*) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'vetada' AND p.decidido_em > now() - interval '7 days'))), '{}')
          FROM unnest(ARRAY['duvidas', 'conteudo', 'pecas', 'atrasados', 'indicadores', 'fontes']) g(ag)),
      'duvidas_sem_resposta_24h', (SELECT count(*) FROM app.mensagem_aluno m WHERE m.tipo = 'duvida' AND m.resposta IS NULL
                                    AND m.criado_em < now() - interval '24 hours'))
      INTO dados;
  ELSE
    RAISE EXCEPTION 'agente_desconhecido';
  END IF;
  RETURN jsonb_build_object('agente', p_agente, 'gerado_em', now(), 'formato', 1,
           'decisoes_recentes', app.coord_retorno(p_agente),
           'aguardando_sua_revisao', (SELECT count(*) FROM app.proposta_agente WHERE agente = p_agente AND status = 'aguardando')) || dados;
END $$;

-- ---------- propostas que chegam da pasta ----------
CREATE OR REPLACE FUNCTION app.coord_receber(p JSONB) RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, app AS $$
DECLARE
  ag TEXT := p ->> 'agente';
  x JSONB;
  n INT := 0;
BEGIN
  IF ag IS NULL OR ag NOT IN ('duvidas', 'pecas', 'conteudo', 'atrasados', 'indicadores', 'fontes') OR jsonb_typeof(p -> 'propostas') <> 'array' THEN
    RAISE EXCEPTION 'arquivo_de_propostas_invalido: agente desconhecido ou sem a lista "propostas"';
  END IF;
  FOR x IN SELECT * FROM jsonb_array_elements(p -> 'propostas') LOOP
    IF NOT app.coord_tipo_valido(ag, x ->> 'tipo') THEN RAISE EXCEPTION 'tipo_invalido: % / %', ag, x ->> 'tipo'; END IF;
    IF coalesce(x ->> 'titulo', '') = '' OR jsonb_typeof(x -> 'proposta') <> 'object' THEN RAISE EXCEPTION 'proposta_sem_titulo_ou_conteudo'; END IF;
    -- nova proposta para o mesmo alvo substitui a que ainda aguardava
    UPDATE app.proposta_agente SET status = 'substituida'
     WHERE agente = ag AND tipo = x ->> 'tipo' AND alvo = coalesce(x -> 'alvo', '{}'::jsonb) AND status = 'aguardando';
    INSERT INTO app.proposta_agente (agente, tipo, alvo, titulo, proposta, justificativa, fontes, confianca, rodada)
    VALUES (ag, x ->> 'tipo', coalesce(x -> 'alvo', '{}'::jsonb), left(x ->> 'titulo', 300), x -> 'proposta',
            left(x ->> 'justificativa', 4000), coalesce(x -> 'fontes', '[]'::jsonb),
            CASE WHEN x ->> 'confianca' IN ('alta', 'media', 'baixa') THEN x ->> 'confianca' END, left(p ->> 'rodada', 60));
    n := n + 1;
  END LOOP;
  RETURN n;
END $$;

-- ---------- decisao da coordenacao ----------
CREATE OR REPLACE FUNCTION app.decidir_proposta(p_id BIGINT, p_decisao TEXT, p_final JSONB DEFAULT NULL, p_motivo TEXT DEFAULT NULL)
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE
  pr app.proposta_agente;
  f JSONB;
  dec TEXT;
  pid BIGINT;
  v_sha TEXT; v_texto TEXT; v_arquivo TEXT; v_nome TEXT;
BEGIN
  IF app.role_atual() NOT IN ('admin', 'curador', 'data_steward') THEN RAISE EXCEPTION 'so_coordenacao' USING ERRCODE = '42501'; END IF;
  SELECT * INTO pr FROM app.proposta_agente WHERE proposta_id = p_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'proposta_nao_encontrada'; END IF;
  IF pr.status <> 'aguardando' THEN RAISE EXCEPTION 'proposta_ja_decidida'; END IF;
  IF p_decisao NOT IN ('aprovar', 'alterar', 'vetar') THEN RAISE EXCEPTION 'decisao_invalida'; END IF;

  IF p_decisao = 'vetar' THEN
    IF length(trim(coalesce(p_motivo, ''))) < 5 THEN RAISE EXCEPTION 'motivo_obrigatorio'; END IF;
    UPDATE app.proposta_agente SET status = 'vetada', motivo = left(p_motivo, 2000), decidido_por = app.pessoa_atual(), decidido_em = now()
     WHERE proposta_id = p_id;
    RETURN 'vetada';
  END IF;

  f := CASE WHEN p_decisao = 'alterar' THEN pr.proposta || coalesce(p_final, '{}'::jsonb) ELSE pr.proposta END;

  IF pr.tipo = 'resposta' THEN
    PERFORM app.responder_duvida((pr.alvo ->> 'mensagem_id')::bigint, f ->> 'texto');
    UPDATE app.mensagem_aluno SET resposta_ia = pr.proposta ->> 'texto', modelo_ia = 'agente:duvidas'
     WHERE mensagem_id = (pr.alvo ->> 'mensagem_id')::bigint;

  ELSIF pr.tipo = 'parecer' THEN
    dec := f ->> 'decisao';
    IF dec IS NULL AND f ->> 'sugestao' = 'aprovar' THEN dec := 'correto'; END IF;
    IF dec IN ('correto', 'erro_leve', 'erro_critico') THEN
      INSERT INTO conteudo.parecer_revisao (artefato_id, afirmacao_codigo, pessoa_id, decisao, comentario)
      VALUES ((pr.alvo ->> 'artefato_id')::bigint, pr.alvo ->> 'afirmacao_codigo', app.pessoa_atual(), dec,
              left(concat_ws(' ', f ->> 'comentario', '[parecer sugerido pelo agente revisor e conferido pela coordenação]'), 4000))
      ON CONFLICT (artefato_id, afirmacao_codigo, pessoa_id)
      DO UPDATE SET decisao = EXCLUDED.decisao, comentario = EXCLUDED.comentario, criado_em = now();
    ELSIF p_decisao = 'alterar' OR f ->> 'sugestao' <> 'conferir' THEN
      RAISE EXCEPTION 'escolha_a_decisao: correto, erro_leve ou erro_critico';
    END IF;
    -- "conferir melhor" aprovado sem decisao: fica anotado; o parecer e dado na tela de revisao, depois de conferir

  ELSIF pr.tipo = 'lembrete' THEN
    pid := (pr.alvo ->> 'pessoa_id')::bigint;
    IF length(trim(coalesce(f ->> 'texto', ''))) < 10 THEN RAISE EXCEPTION 'lembrete_sem_texto'; END IF;
    INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
    SELECT pid, 'email', coalesce(c.email_aviso, p.email_primario::text), left(coalesce(f ->> 'assunto', 'CUT: testes pendentes'), 150),
           f ->> 'texto', jsonb_build_object('caminho', '/aluno/testes', 'rotulo_link', 'Abrir os testes', 'proposta_id', p_id)
      FROM app.pessoa p JOIN app.contato_aluno c ON c.pessoa_id = p.pessoa_id AND c.aceita_email WHERE p.pessoa_id = pid;
    INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
    SELECT pid, 'push', 'pessoa:' || pid, left(coalesce(f ->> 'assunto', 'CUT: testes pendentes'), 80), left(f ->> 'texto', 240),
           jsonb_build_object('caminho', '/aluno/testes', 'proposta_id', p_id)
     WHERE EXISTS (SELECT 1 FROM app.push_inscricao pi WHERE pi.pessoa_id = pid AND pi.ativo);

  ELSIF pr.tipo = 'fonte' THEN
    -- alvo: a fonte recebida (fonte_recebida_id) ou um arquivo pelo sha256: recebido pela ponte ou ja guardado em
    -- outro tema (por exemplo, as fontes do T001 que servem a outros temas)
    v_sha := coalesce((SELECT r.sha256 FROM app.fonte_recebida r WHERE r.fonte_recebida_id = (pr.alvo ->> 'fonte_recebida_id')::bigint),
                      pr.alvo ->> 'sha256');
    IF coalesce((f ->> 'recusar')::boolean, false) THEN
      -- recusada (dado de paciente, ilegivel ou fora do escopo): o texto e apagado
      UPDATE app.fonte_recebida SET status = 'recusada', texto = NULL, triado_em = now() WHERE sha256 = v_sha;
    ELSE
      SELECT r.texto, 'RECEBIDAS/' || r.arquivo, r.nome_original INTO v_texto, v_arquivo, v_nome FROM app.fonte_recebida r WHERE r.sha256 = v_sha;
      IF NOT FOUND THEN
        SELECT x.texto_integral, x.arquivo_origem, x.titulo INTO v_texto, v_arquivo, v_nome
          FROM conteudo.fonte x WHERE x.sha256 = v_sha ORDER BY x.texto_integral IS NULL, x.fonte_id LIMIT 1;
        IF NOT FOUND THEN
          RAISE EXCEPTION 'fonte_nao_encontrada: o arquivo ainda nao chegou pela ponte (aguarde 10 minutos) ou nao esta no banco';
        END IF;
      END IF;
      INSERT INTO conteudo.fonte (tema_id, camada, titulo, autores, ano, doi, pmid, url, texto_integral, arquivo_origem, sha256,
                                  camada_confirmada, tema_confirmado)
      SELECT t.tema_id, (f ->> 'camada')::smallint, left(coalesce(f ->> 'titulo', v_nome), 500), left(f ->> 'autores', 500),
             nullif(f ->> 'ano', '')::smallint, nullif(f ->> 'doi', ''), nullif(f ->> 'pmid', ''), nullif(f ->> 'url', ''),
             v_texto, v_arquivo, v_sha, true, true
        FROM (SELECT DISTINCT upper(trim(x)) AS cod FROM unnest(
               CASE WHEN f ? 'temas_texto' THEN regexp_split_to_array(f ->> 'temas_texto', '[,;\s]+')
                    ELSE ARRAY(SELECT e ->> 'tema' FROM jsonb_array_elements(f -> 'temas') e) END) x WHERE trim(x) <> '') c
        JOIN app.tema t ON replace(t.codigo, '-', '') = replace(c.cod, '-', '')
       WHERE NOT EXISTS (SELECT 1 FROM conteudo.fonte x WHERE x.tema_id = t.tema_id AND x.sha256 = v_sha);
      UPDATE app.fonte_recebida r SET status = 'guardada', triado_em = now(),
             temas = (SELECT array_agg(DISTINCT t.codigo ORDER BY t.codigo) FROM conteudo.fonte x JOIN app.tema t ON t.tema_id = x.tema_id WHERE x.sha256 = r.sha256)
       WHERE r.sha256 = v_sha;
    END IF;

  ELSIF pr.tipo = 'lancamento' THEN
    PERFORM app.salvar_indicador(pr.alvo ->> 'indicador', (pr.alvo ->> 'mes')::date, (f ->> 'numerador')::int, (f ->> 'denominador')::int,
                                 coalesce(f ->> 'fonte', 'agente de indicadores'));
  END IF;
  -- alerta, pre_revisao, relatorio, pendencia: a aprovacao registra que a coordenacao leu e concorda

  UPDATE app.proposta_agente SET status = CASE WHEN p_decisao = 'alterar' THEN 'alterada' ELSE 'aprovada' END,
         decisao = CASE WHEN p_decisao = 'alterar' THEN f END, motivo = nullif(left(p_motivo, 2000), ''),
         decidido_por = app.pessoa_atual(), decidido_em = now()
   WHERE proposta_id = p_id;
  RETURN CASE WHEN p_decisao = 'alterar' THEN 'alterada' ELSE 'aprovada' END;
END $$;

-- ---------- aba "Para revisar" ----------
DROP FUNCTION IF EXISTS app.painel_propostas(TEXT);
CREATE FUNCTION app.painel_propostas(p_status TEXT DEFAULT 'aguardando')
RETURNS TABLE (proposta_id BIGINT, agente TEXT, tipo TEXT, titulo TEXT, proposta JSONB, justificativa TEXT, fontes JSONB, confianca TEXT,
               criado_em TIMESTAMPTZ, status TEXT, motivo TEXT, decisao JSONB, decidido_em TIMESTAMPTZ, contexto JSONB)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  SELECT pa.proposta_id, pa.agente, pa.tipo, pa.titulo, pa.proposta, pa.justificativa, pa.fontes, pa.confianca, pa.criado_em, pa.status,
         pa.motivo, pa.decisao, pa.decidido_em,
         CASE pa.tipo
           WHEN 'resposta' THEN (SELECT jsonb_build_object('aluno', app.aluno_painel(m.pessoa_id), 'ano', (app.perfil_aluno(m.pessoa_id)).ano,
                                  'tema', t.codigo, 'pergunta', m.texto, 'enviada_em', m.criado_em,
                                  'horas_esperando', round(extract(epoch FROM now() - m.criado_em) / 3600))
                                   FROM app.mensagem_aluno m LEFT JOIN app.tema t ON t.tema_id = m.tema_id WHERE m.mensagem_id = (pa.alvo ->> 'mensagem_id')::bigint)
           WHEN 'alerta' THEN (SELECT jsonb_build_object('pergunta', m.texto) FROM app.mensagem_aluno m WHERE m.mensagem_id = (pa.alvo ->> 'mensagem_id')::bigint)
           WHEN 'parecer' THEN (SELECT jsonb_build_object('tema', t.codigo, 'peca', app.nome_material(a.tipo::text), 'versao', a.versao,
                                  'afirmacao', f.texto, 'trecho_literal', f.trecho_literal, 'fonte_arquivo', f.fonte_arquivo,
                                  'copias', (SELECT count(*) FROM conteudo.afirmacao f3 JOIN conteudo.artefato a3 ON a3.artefato_id = f3.artefato_id
                                              WHERE a3.tema_id = a.tema_id AND a3.status::text IN ('rascunho', 'publicado') AND f3.texto = f.texto))
                                  FROM conteudo.afirmacao f JOIN conteudo.artefato a ON a.artefato_id = f.artefato_id JOIN app.tema t ON t.tema_id = a.tema_id
                                 WHERE f.artefato_id = (pa.alvo ->> 'artefato_id')::bigint AND f.codigo = pa.alvo ->> 'afirmacao_codigo' LIMIT 1)
           WHEN 'pre_revisao' THEN (SELECT jsonb_build_object('tema', t.codigo, 'peca', app.nome_material(a.tipo::text), 'versao', a.versao,
                                  'revisao', '/curador/revisao/' || replace(t.codigo, '-', ''))
                                  FROM conteudo.artefato a JOIN app.tema t ON t.tema_id = a.tema_id WHERE a.artefato_id = (pa.alvo ->> 'artefato_id')::bigint)
           WHEN 'fonte' THEN coalesce(
               (SELECT jsonb_build_object('arquivo', r.nome_original, 'ref', r.ref, 'caracteres', r.caracteres,
                                  'ja_no_banco_em', (SELECT jsonb_agg(DISTINCT t.codigo) FROM conteudo.fonte x JOIN app.tema t ON t.tema_id = x.tema_id WHERE x.sha256 = r.sha256))
                  FROM app.fonte_recebida r WHERE r.fonte_recebida_id = (pa.alvo ->> 'fonte_recebida_id')::bigint
                     OR r.sha256 = pa.alvo ->> 'sha256' LIMIT 1),
               (SELECT jsonb_build_object('arquivo', regexp_replace(min(x.arquivo_origem), '^.*/', ''), 'ref', 'já guardada no banco',
                                  'caracteres', max(length(x.texto_integral)),
                                  'ja_no_banco_em', jsonb_agg(DISTINCT t.codigo))
                  FROM conteudo.fonte x JOIN app.tema t ON t.tema_id = x.tema_id WHERE x.sha256 = pa.alvo ->> 'sha256' HAVING count(*) > 0),
               jsonb_build_object('arquivo', 'ainda não chegou pela ponte (aguarde 10 minutos)'))
           WHEN 'lembrete' THEN (SELECT jsonb_build_object('aluno', app.aluno_painel(p.pessoa_id), 'ano', (app.perfil_aluno(p.pessoa_id)).ano)
                                  FROM app.pessoa p WHERE p.pessoa_id = (pa.alvo ->> 'pessoa_id')::bigint)
           ELSE '{}'::jsonb END
    FROM app.proposta_agente pa
   WHERE app.role_atual() IN ('admin', 'curador', 'data_steward')
     AND ((p_status = 'aguardando' AND pa.status = 'aguardando') OR (p_status = 'decididas' AND pa.status IN ('aprovada', 'alterada', 'vetada')))
   ORDER BY CASE pa.agente WHEN 'duvidas' THEN 1 WHEN 'conteudo' THEN 2 WHEN 'pecas' THEN 3 WHEN 'fontes' THEN 4 WHEN 'atrasados' THEN 5 ELSE 6 END,
            pa.criado_em
   LIMIT 300 $$;

-- Desempenho de cada agente nos ultimos 60 dias: quanto a coordenacao aprova como veio, altera ou veta.
DROP FUNCTION IF EXISTS app.painel_agentes();
CREATE FUNCTION app.painel_agentes()
RETURNS TABLE (agente TEXT, aguardando INT, mais_antiga_horas INT, decididas_60d INT, aprovadas_como_vieram INT, alteradas INT, vetadas INT,
               aprovadas_sem_alteracao_pct NUMERIC, duvidas_sem_resposta_24h INT, ultima_rodada TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app AS $$
  SELECT g.ag,
         (SELECT count(*) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'aguardando')::int,
         (SELECT round(extract(epoch FROM now() - min(p.criado_em)) / 3600) FROM app.proposta_agente p WHERE p.agente = g.ag AND p.status = 'aguardando')::int,
         count(d.*)::int, count(*) FILTER (WHERE d.status = 'aprovada')::int, count(*) FILTER (WHERE d.status = 'alterada')::int,
         count(*) FILTER (WHERE d.status = 'vetada')::int,
         round(100.0 * count(*) FILTER (WHERE d.status = 'aprovada') / nullif(count(d.*), 0), 0),
         CASE WHEN g.ag = 'duvidas' THEN (SELECT count(*) FROM app.mensagem_aluno m WHERE m.tipo = 'duvida' AND m.resposta IS NULL
                                            AND m.criado_em < now() - interval '24 hours')::int END,
         (SELECT max(p.criado_em) FROM app.proposta_agente p WHERE p.agente = g.ag)
    FROM unnest(ARRAY['duvidas', 'conteudo', 'pecas', 'fontes', 'atrasados', 'indicadores']) AS g(ag)
    LEFT JOIN app.proposta_agente d ON d.agente = g.ag AND d.status IN ('aprovada', 'alterada', 'vetada') AND d.decidido_em > now() - interval '60 days'
   WHERE app.role_atual() IN ('admin', 'curador', 'data_steward')
   GROUP BY g.ag ORDER BY array_position(ARRAY['duvidas', 'conteudo', 'pecas', 'fontes', 'atrasados', 'indicadores'], g.ag) $$;

GRANT EXECUTE ON FUNCTION app.coord_registrar_fonte(TEXT, TEXT, TEXT, TEXT), app.data_aula_planejada(BIGINT), app.coord_pacote(TEXT), app.coord_receber(JSONB), app.decidir_proposta(BIGINT, TEXT, JSONB, TEXT),
  app.painel_propostas(TEXT), app.painel_agentes(), app.coord_tipo_valido(TEXT, TEXT), app.coord_retorno(TEXT),
  app.coord_tem_proposta(TEXT, TEXT, TEXT), app.coord_trecho_fonte(TEXT, TEXT) TO api_rw;

COMMIT;
SELECT 'coordenacao com agentes (89): pronto' AS situacao;
