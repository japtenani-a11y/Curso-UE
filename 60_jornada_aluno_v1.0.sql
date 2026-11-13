-- 60_jornada_aluno_v1.0.sql
-- Jornada do aluno em cada tema, pendencias, avaliacao ampliada e painel de pesquisa.
--
-- (1) Liberacao (substitui a regra do 38/54):
--     Etapa 1  D-15: pre-teste inicial (aviso "acesso aberto" por e-mail).
--     Etapa 2  apos enviar o pre-teste inicial: material pre-aula (objetivos, resumo basico, podcast, caso base)
--              e pre-teste 2, que fecha 1 hora antes do D0.
--     Etapa 3  a partir do D0 (hora da aula), com o pre-teste inicial feito: material da aula (aula, slides, caso)
--              e pos-teste D0. Quem perdeu o prazo do pre-teste 2 segue normalmente (pre-teste 2 fica como perdido).
--     Etapa 4  apos enviar o pos-teste D0: material pos-aula (sintese de evidencia, resumo executivo, mapa,
--              flashcards, protocolo, checklists, simulados) e pos-testes D+15, D+45 e D+90 nas datas.
--     Gabarito: so depois de enviar o teste (regra da API, inalterada).
-- (2) Avisos de abertura (dias_apos = 0): pre-teste inicial em D-15, pos-teste D0 na aula e pos-testes D+15,
--     D+45 e D+90, para quem ja tem o teste liberado e nao respondeu (janela de 7 dias, depois vem o lembrete).
-- (3) Avaliacao ampliada: adequacao, grau de dificuldade, utilidade e materiais usados.
-- (4) app.jornada_tema, app.calendario_aulas, app.pendencias: telas do aluno.
-- (5) Painel (admin, curador, data_steward, pesquisador): notas, avaliacoes, duvidas e uso, com turma
--     (= ano de entrada no programa) e especialidade. Pesquisador ve codigo do participante, nao o nome.
-- Pre-requisito: 38, 43, 45, 54, 55 e 58. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) liberacao ----------
CREATE OR REPLACE FUNCTION app.d0_da_pessoa(p_pessoa BIGINT, p_tema BIGINT) RETURNS TIMESTAMPTZ
LANGUAGE sql STABLE AS $$
  SELECT o.data_abertura FROM app.onda_instancia o WHERE o.onda_id = app.onda_da_pessoa(p_pessoa, p_tema, 3::smallint) $$;

CREATE OR REPLACE FUNCTION app.etapa_liberada(p_pessoa BIGINT, p_tema BIGINT) RETURNS INT
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 1::smallint) THEN 1
    WHEN coalesce(now() < app.d0_da_pessoa(p_pessoa, p_tema), true) THEN 2
    WHEN NOT app.teste_submetido(p_pessoa, p_tema, 3::smallint) THEN 3
    ELSE 4 END $$;

CREATE OR REPLACE FUNCTION app.etapa_do_material(p_tipo TEXT) RETURNS INT
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE
    WHEN p_tipo IN ('objetivos','resumo_basico','podcast_roteiro','caso_base') THEN 2
    WHEN p_tipo IN ('aula','slides','caso') THEN 3
    WHEN p_tipo IN ('sintese_evidencia','resumo','mapa','flashcard','protocolo','checklist','simulado') THEN 4
    ELSE NULL END $$;
GRANT EXECUTE ON FUNCTION app.d0_da_pessoa(BIGINT, BIGINT), app.etapa_liberada(BIGINT, BIGINT), app.etapa_do_material(TEXT) TO api_rw;

-- Nomes usados nas telas.
CREATE OR REPLACE FUNCTION app.nome_teste(p_n SMALLINT) RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT (ARRAY['Pré-teste inicial','Pré-teste 2','Pós-teste D0','Pós-teste D+15','Pós-teste D+45','Pós-teste D+90'])[p_n] $$;
CREATE OR REPLACE FUNCTION app.nome_material(p_tipo TEXT) RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p_tipo
    WHEN 'objetivos' THEN 'Objetivos' WHEN 'resumo_basico' THEN 'Resumo básico' WHEN 'podcast_roteiro' THEN 'Podcast'
    WHEN 'caso_base' THEN 'Caso base' WHEN 'aula' THEN 'Aula' WHEN 'slides' THEN 'Slides' WHEN 'caso' THEN 'Caso da aula'
    WHEN 'sintese_evidencia' THEN 'Síntese de evidência' WHEN 'resumo' THEN 'Resumo executivo' WHEN 'mapa' THEN 'Mapa conceitual'
    WHEN 'flashcard' THEN 'Flashcards' WHEN 'protocolo' THEN 'Protocolo' WHEN 'checklist' THEN 'Checklists'
    WHEN 'simulado' THEN 'Simulados' ELSE p_tipo END $$;
GRANT EXECUTE ON FUNCTION app.nome_teste(SMALLINT), app.nome_material(TEXT) TO api_rw;

-- ---------- (2) avisos de abertura ----------
ALTER TABLE app.lembrete DROP CONSTRAINT IF EXISTS lembrete_dias_apos_check;
ALTER TABLE app.lembrete ADD CONSTRAINT lembrete_dias_apos_check CHECK (dias_apos IN (-1, 0, 7, 14, 28, 60));

CREATE OR REPLACE FUNCTION app.gerar_lembretes_para(p_pessoa BIGINT) RETURNS INT
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH ondas AS (
    SELECT o.* FROM app.onda_instancia o
     WHERE o.tema_id IS NOT NULL
       AND o.onda_id = app.onda_da_pessoa(p_pessoa, o.tema_id, o.teste_num)
       AND (o.pessoa_id = p_pessoa OR EXISTS (SELECT 1 FROM app.tema t WHERE t.tema_id = o.tema_id AND t.papel_curricular = 'nuclear'))
       AND NOT app.teste_submetido(p_pessoa, o.tema_id, o.teste_num)),
  novos AS (
    INSERT INTO app.lembrete (pessoa_id, onda_id, dias_apos)
    SELECT p_pessoa, o.onda_id, d.dias
      FROM ondas o CROSS JOIN (VALUES (7),(14),(28),(60)) d(dias)
     WHERE o.teste_num BETWEEN 3 AND 6
       AND o.data_abertura + make_interval(days => d.dias) <= now()
       AND app.teste_liberado(p_pessoa, o.tema_id, o.teste_num)
    UNION ALL
    SELECT p_pessoa, o.onda_id, -1 FROM ondas o
     WHERE o.teste_num = 2
       AND now() >= o.data_fechamento - interval '24 hours' AND now() < o.data_fechamento
       AND app.teste_liberado(p_pessoa, o.tema_id, o.teste_num)
    UNION ALL
    SELECT p_pessoa, o.onda_id, 0 FROM ondas o
     WHERE o.teste_num IN (1, 3, 4, 5, 6)
       AND o.data_abertura <= now() AND now() < o.data_abertura + interval '7 days'
       AND (o.data_fechamento IS NULL OR now() < o.data_fechamento)
       AND app.teste_liberado(p_pessoa, o.tema_id, o.teste_num)
    ON CONFLICT (pessoa_id, onda_id, dias_apos) DO NOTHING
    RETURNING 1)
  SELECT count(*)::int FROM novos $$;

CREATE OR REPLACE FUNCTION app.texto_lembrete(p_lembrete BIGINT)
RETURNS TABLE (assunto TEXT, corpo TEXT, parametros JSONB)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT
    CASE WHEN l.dias_apos = -1 THEN 'Prazo do ' || n.nome || ' de ' || t.codigo || ' termina em breve'
         WHEN l.dias_apos = 0 AND o.teste_num = 1 THEN t.codigo || ': acesso aberto — pré-teste inicial disponível'
         WHEN l.dias_apos = 0 AND o.teste_num = 3 THEN t.codigo || ': material da aula e pós-teste D0 liberados'
         WHEN l.dias_apos = 0 THEN t.codigo || ': ' || n.nome || ' disponível'
         ELSE n.nome || ' de ' || t.codigo || ' pendente' END,
    CASE WHEN l.dias_apos = -1
         THEN 'O ' || n.nome || ' de ' || t.codigo || ' (' || t.titulo || ') fecha em '
              || to_char(o.data_fechamento AT TIME ZONE 'America/Sao_Paulo', 'DD/MM "às" HH24:MI')
              || ', 1 hora antes da aula. Leva de 10 a 15 minutos.'
         WHEN l.dias_apos = 0 AND o.teste_num = 1
         THEN 'O tema ' || t.codigo || ' (' || t.titulo || ') está aberto. A aula é em '
              || coalesce(to_char(app.d0_da_pessoa(l.pessoa_id, t.tema_id) AT TIME ZONE 'America/Sao_Paulo', 'DD/MM/YYYY "às" HH24:MI'), 'data a definir')
              || '. Comece pelo pré-teste inicial: ao enviá-lo, você recebe o material pré-aula e o pré-teste 2.'
         WHEN l.dias_apos = 0 AND o.teste_num = 3
         THEN 'A aula de ' || t.codigo || ' (' || t.titulo || ') começou: o material da aula e o pós-teste D0 estão liberados. '
              || 'Ao enviar o pós-teste D0, você recebe o material pós-aula.'
         WHEN l.dias_apos = 0
         THEN 'O ' || n.nome || ' de ' || t.codigo || ' (' || t.titulo || ') está disponível. Leva de 10 a 15 minutos.'
         ELSE 'O ' || n.nome || ' de ' || t.codigo || ' (' || t.titulo || ') está pendente há '
              || l.dias_apos || ' dias. Leva de 10 a 15 minutos.' END,
    jsonb_build_object('nome', p.nome_completo, 'teste', n.nome, 'tema', t.codigo, 'titulo', t.titulo,
                       'dias_apos', l.dias_apos,
                       'prazo', to_char(o.data_fechamento AT TIME ZONE 'America/Sao_Paulo', 'DD/MM HH24:MI'),
                       'caminho', '/aluno/tema/' || replace(t.codigo, '-', ''),
                       'rotulo_link', CASE WHEN l.dias_apos = 0 THEN 'Abrir o tema' ELSE 'Responder agora' END)
    FROM app.lembrete l
    JOIN app.pessoa p ON p.pessoa_id = l.pessoa_id
    JOIN app.onda_instancia o ON o.onda_id = l.onda_id
    JOIN app.tema t ON t.tema_id = o.tema_id
    JOIN (VALUES (1,'pré-teste inicial'),(2,'pré-teste 2'),(3,'pós-teste D0'),(4,'pós-teste D+15'),
                 (5,'pós-teste D+45'),(6,'pós-teste D+90')) n(num, nome) ON n.num = o.teste_num
   WHERE l.lembrete_id = p_lembrete $$;

-- ---------- (3) avaliacao ampliada ----------
ALTER TABLE app.avaliacao ADD COLUMN IF NOT EXISTS adequacao SMALLINT CHECK (adequacao BETWEEN 1 AND 5);
ALTER TABLE app.avaliacao ADD COLUMN IF NOT EXISTS dificuldade SMALLINT CHECK (dificuldade BETWEEN 1 AND 5);
ALTER TABLE app.avaliacao ADD COLUMN IF NOT EXISTS utilidade SMALLINT CHECK (utilidade BETWEEN 1 AND 3);  -- 1 sim, 2 em parte, 3 nao
ALTER TABLE app.avaliacao ADD COLUMN IF NOT EXISTS materiais_usados TEXT[];
COMMENT ON COLUMN app.avaliacao.utilidade IS '1 = sim, 2 = em parte, 3 = nao';
COMMENT ON COLUMN app.avaliacao.materiais_usados IS 'avaliacao do tema: tipos de material que o aluno usou';

-- ---------- (4) telas do aluno ----------
-- Tudo o que a tela do tema precisa, para a pessoa logada.
CREATE OR REPLACE FUNCTION app.jornada_tema(p_codigo TEXT) RETURNS JSONB
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE v_p BIGINT := app.pessoa_atual(); t app.tema%ROWTYPE; v JSONB; v_etapa INT; v_tem_onda BOOLEAN;
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT * INTO t FROM app.tema x WHERE upper(replace(x.codigo,'-','')) = upper(replace(p_codigo,'-',''));
  IF t.tema_id IS NULL THEN RETURN NULL; END IF;
  v_etapa := app.etapa_liberada(v_p, t.tema_id);
  v_tem_onda := EXISTS (SELECT 1 FROM app.onda_instancia o WHERE o.onda_id = app.onda_da_pessoa(v_p, t.tema_id, 1::smallint)
                          AND (o.pessoa_id = v_p OR t.papel_curricular = 'nuclear'));
  SELECT jsonb_build_object(
    'codigo', t.codigo, 'titulo', t.titulo, 'modulo', t.modulo, 'papel', t.papel_curricular, 'dificuldade', t.dificuldade,
    'agendado', v_tem_onda,
    'd0', CASE WHEN v_tem_onda THEN app.d0_da_pessoa(v_p, t.tema_id)
               ELSE (SELECT a.data_hora FROM app.agenda_aula a WHERE a.tema_id = t.tema_id LIMIT 1) END,
    'pode_agendar', t.papel_curricular <> 'nuclear' AND NOT EXISTS (
        SELECT 1 FROM app.tentativa tt JOIN app.onda_instancia o USING (onda_id)
         WHERE o.tema_id = t.tema_id AND tt.pessoa_id = v_p AND tt.submetida_em IS NOT NULL),
    'etapa', v_etapa,
    'testes', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'num', n, 'nome', app.nome_teste(n::smallint), 'abre', o.data_abertura, 'fecha', o.data_fechamento,
        'liberado', app.teste_liberado(v_p, t.tema_id, n::smallint),
        'respondivel', app.teste_liberado(v_p, t.tema_id, n::smallint) AND app.onda_respondivel(o.onda_id),
        'feito', app.teste_submetido(v_p, t.tema_id, n::smallint),
        'perdido', NOT app.teste_submetido(v_p, t.tema_id, n::smallint) AND o.data_fechamento <= now(),
        'nota', (SELECT nt.pct FROM app.nota_teste nt WHERE nt.pessoa_id = v_p AND nt.tema_id = t.tema_id AND nt.teste_num = n
                  ORDER BY nt.submetida_em DESC LIMIT 1),
        'avaliado', EXISTS (SELECT 1 FROM app.avaliacao a WHERE a.pessoa_id = v_p AND a.tema_id = t.tema_id AND a.ferramenta = 'teste_' || n))
        ORDER BY n)
      FROM generate_series(1, 6) n
      LEFT JOIN app.onda_instancia o ON v_tem_onda AND o.onda_id = app.onda_da_pessoa(v_p, t.tema_id, n::smallint)), '[]'::jsonb),
    'materiais', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'tipo', m.tipo, 'nome', app.nome_material(m.tipo), 'etapa', app.etapa_do_material(m.tipo),
        'liberado', app.etapa_do_material(m.tipo) <= v_etapa,
        'publicado', EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.tipo::text = m.tipo AND a.status = 'publicado'),
        'usado', EXISTS (SELECT 1 FROM app.uso_material u WHERE u.pessoa_id = v_p AND u.tema_id = t.tema_id AND u.tipo = m.tipo),
        'avaliado', EXISTS (SELECT 1 FROM app.avaliacao a WHERE a.pessoa_id = v_p AND a.tema_id = t.tema_id AND a.ferramenta = m.tipo))
        ORDER BY m.ordem)
      FROM unnest(ARRAY['objetivos','resumo_basico','podcast_roteiro','caso_base','aula','slides','caso','sintese_evidencia',
                        'resumo','mapa','flashcard','protocolo','checklist','simulado']) WITH ORDINALITY m(tipo, ordem)), '[]'::jsonb),
    'tema_avaliado', EXISTS (SELECT 1 FROM app.avaliacao a WHERE a.pessoa_id = v_p AND a.tema_id = t.tema_id AND a.ferramenta = 'tema'))
  INTO v;
  RETURN v;
END $$;

-- Calendario: as aulas do grupo (39 principais) e os D0 que a pessoa escolheu nos opcionais.
CREATE OR REPLACE FUNCTION app.calendario_aulas()
RETURNS TABLE (data_hora TIMESTAMPTZ, codigo TEXT, titulo TEXT, modulo TEXT, papel TEXT, proprio BOOLEAN, etapa INT, testes_feitos INT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  WITH d AS (
    SELECT coalesce((SELECT a.data_hora FROM app.agenda_aula a WHERE a.tema_id = t.tema_id LIMIT 1),
                    (SELECT o.data_abertura FROM app.onda_instancia o WHERE o.tema_id = t.tema_id AND o.teste_num = 3 AND o.pessoa_id IS NULL LIMIT 1)) AS dh,
           t, false AS proprio
      FROM app.tema t WHERE t.papel_curricular = 'nuclear'
    UNION ALL
    SELECT o.data_abertura, t, true
      FROM app.onda_instancia o JOIN app.tema t ON t.tema_id = o.tema_id
     WHERE o.pessoa_id = app.pessoa_atual() AND o.teste_num = 3)
  SELECT d.dh, (d.t).codigo, (d.t).titulo, (d.t).modulo, (d.t).papel_curricular, d.proprio,
         app.etapa_liberada(app.pessoa_atual(), (d.t).tema_id),
         (SELECT count(*)::int FROM app.tentativa tt JOIN app.onda_instancia o USING (onda_id)
           WHERE o.tema_id = (d.t).tema_id AND tt.pessoa_id = app.pessoa_atual() AND tt.submetida_em IS NOT NULL)
    FROM d WHERE d.dh IS NOT NULL AND app.pessoa_atual() IS NOT NULL
   ORDER BY d.dh $$;

-- Pendencias: testes liberados e ainda abertos que a pessoa nao respondeu, e avaliacoes que faltam
-- (do tema, de cada peca liberada e de cada teste enviado), nos temas que ela ja comecou.
CREATE OR REPLACE FUNCTION app.pendencias()
RETURNS TABLE (codigo TEXT, titulo TEXT, tipo TEXT, item TEXT, nome TEXT, prazo TIMESTAMPTZ, d0 TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH p AS (SELECT app.pessoa_atual() AS id),
  ondas AS (
    SELECT o.*, t.codigo, t.titulo FROM app.onda_instancia o JOIN app.tema t ON t.tema_id = o.tema_id, p
     WHERE o.onda_id = app.onda_da_pessoa(p.id, o.tema_id, o.teste_num)
       AND (o.pessoa_id = p.id OR t.papel_curricular = 'nuclear')),
  iniciados AS (
    SELECT DISTINCT o.tema_id FROM app.tentativa tt JOIN app.onda_instancia o USING (onda_id), p
     WHERE tt.pessoa_id = p.id AND tt.submetida_em IS NOT NULL)
  SELECT o.codigo, o.titulo, 'teste', 'teste_' || o.teste_num, app.nome_teste(o.teste_num), o.data_fechamento,
         app.d0_da_pessoa(p.id, o.tema_id)
    FROM ondas o, p
   WHERE app.teste_liberado(p.id, o.tema_id, o.teste_num) AND app.onda_respondivel(o.onda_id)
     AND NOT app.teste_submetido(p.id, o.tema_id, o.teste_num)
  UNION ALL
  SELECT t.codigo, t.titulo, 'avaliacao', 'teste_' || n.n, 'Avaliação do ' || lower(app.nome_teste(n.n::smallint)), NULL,
         app.d0_da_pessoa(p.id, t.tema_id)
    FROM iniciados i JOIN app.tema t ON t.tema_id = i.tema_id, p, generate_series(1, 6) n(n)
   WHERE app.teste_submetido(p.id, t.tema_id, n.n::smallint)
     AND NOT EXISTS (SELECT 1 FROM app.avaliacao a WHERE a.pessoa_id = p.id AND a.tema_id = t.tema_id AND a.ferramenta = 'teste_' || n.n)
  UNION ALL
  SELECT t.codigo, t.titulo, 'avaliacao', m.tipo, 'Avaliação: ' || app.nome_material(m.tipo), NULL, app.d0_da_pessoa(p.id, t.tema_id)
    FROM iniciados i JOIN app.tema t ON t.tema_id = i.tema_id, p,
         LATERAL (SELECT DISTINCT a.tipo::text AS tipo FROM conteudo.artefato a
                   WHERE a.tema_id = t.tema_id AND a.status = 'publicado') m
   WHERE app.etapa_do_material(m.tipo) <= app.etapa_liberada(p.id, t.tema_id)
     AND NOT EXISTS (SELECT 1 FROM app.avaliacao a WHERE a.pessoa_id = p.id AND a.tema_id = t.tema_id AND a.ferramenta = m.tipo)
  UNION ALL
  SELECT t.codigo, t.titulo, 'avaliacao', 'tema', 'Avaliação geral do tema', NULL, app.d0_da_pessoa(p.id, t.tema_id)
    FROM iniciados i JOIN app.tema t ON t.tema_id = i.tema_id, p
   WHERE app.teste_submetido(p.id, t.tema_id, 3::smallint)
     AND NOT EXISTS (SELECT 1 FROM app.avaliacao a WHERE a.pessoa_id = p.id AND a.tema_id = t.tema_id AND a.ferramenta = 'tema')
  ORDER BY 1, 3 DESC, 4 $$;

REVOKE EXECUTE ON FUNCTION app.jornada_tema(TEXT), app.calendario_aulas(), app.pendencias() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.jornada_tema(TEXT), app.calendario_aulas(), app.pendencias() TO api_rw;

-- ---------- (5) painel ----------
CREATE OR REPLACE FUNCTION app.papel_painel() RETURNS TEXT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT d.papel FROM app.designacao d
   WHERE d.pessoa_id = app.pessoa_atual() AND d.papel IN ('admin','curador','data_steward','pesquisador')
     AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)
   ORDER BY array_position(ARRAY['admin','data_steward','curador','pesquisador'], d.papel) LIMIT 1 $$;

-- Quem e o aluno no painel: nome para a coordenacao; codigo para o pesquisador.
CREATE OR REPLACE FUNCTION app.aluno_painel(p_pessoa BIGINT) RETURNS TEXT
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, pesquisa AS $$
  SELECT CASE WHEN app.papel_painel() = 'pesquisador' THEN pesquisa.codigo_participante(p_pessoa)
              ELSE (SELECT nome_completo FROM app.pessoa WHERE pessoa_id = p_pessoa) END $$;

CREATE OR REPLACE FUNCTION app.perfil_aluno(p_pessoa BIGINT, OUT ano TEXT, OUT especialidade TEXT, OUT turma SMALLINT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT (SELECT x.grau::text FROM app.posicao_anual x WHERE x.pessoa_id = p_pessoa AND x.ativo ORDER BY x.ano_letivo DESC LIMIT 1),
         (SELECT x.especialidade FROM app.posicao_anual x WHERE x.pessoa_id = p_pessoa AND x.especialidade IS NOT NULL ORDER BY x.ano_letivo DESC LIMIT 1),
         (SELECT min(x.ano_letivo) FROM app.posicao_anual x WHERE x.pessoa_id = p_pessoa) $$;

CREATE OR REPLACE FUNCTION app.painel_notas()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, teste_num SMALLINT, teste TEXT,
               acertos SMALLINT, total SMALLINT, pct NUMERIC, nota_ponderada NUMERIC, tempo_s INT, submetida_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(n.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, n.teste_num, app.nome_teste(n.teste_num),
         n.acertos, n.total, n.pct, n.nota_ponderada, n.tempo_total_s, n.submetida_em
    FROM app.nota_teste n JOIN app.tema t ON t.tema_id = n.tema_id, LATERAL app.perfil_aluno(n.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY n.submetida_em $$;

CREATE OR REPLACE FUNCTION app.painel_avaliacoes()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, ferramenta TEXT, nps SMALLINT,
               apresentacao SMALLINT, conteudo SMALLINT, objetividade SMALLINT, clareza SMALLINT, complexidade SMALLINT,
               adequacao SMALLINT, dificuldade SMALLINT, importancia SMALLINT, tempo_gasto SMALLINT, frequencia_testes SMALLINT,
               utilidade SMALLINT, minutos_gastos SMALLINT, materiais_usados TEXT, comentario TEXT, atualizado_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(a.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, a.ferramenta, a.nps,
         a.apresentacao, a.conteudo, a.objetividade, a.clareza, a.complexidade, a.adequacao, a.dificuldade, a.importancia,
         a.tempo_gasto, a.frequencia_testes, a.utilidade, a.minutos_gastos, array_to_string(a.materiais_usados, ', '),
         a.comentario, a.atualizado_em
    FROM app.avaliacao a LEFT JOIN app.tema t ON t.tema_id = a.tema_id, LATERAL app.perfil_aluno(a.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY a.atualizado_em $$;

CREATE OR REPLACE FUNCTION app.painel_mensagens()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, ferramenta TEXT, tipo TEXT, texto TEXT,
               resposta TEXT, util BOOLEAN, criado_em TIMESTAMPTZ, respondida_em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(m.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, m.ferramenta, m.tipo, m.texto,
         m.resposta, m.util, m.criado_em, m.respondida_em
    FROM app.mensagem_aluno m LEFT JOIN app.tema t ON t.tema_id = m.tema_id, LATERAL app.perfil_aluno(m.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   ORDER BY m.criado_em $$;

CREATE OR REPLACE FUNCTION app.painel_uso()
RETURNS TABLE (aluno TEXT, ano TEXT, especialidade TEXT, turma SMALLINT, tema TEXT, tipo TEXT, minutos NUMERIC, aberturas INT,
               primeiro TIMESTAMPTZ, ultimo TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT app.aluno_painel(u.pessoa_id), pf.ano, pf.especialidade, pf.turma, t.codigo, u.tipo,
         round(sum(u.segundos) / 60.0, 1), count(*)::int, min(u.em), max(u.em)
    FROM app.uso_material u JOIN app.tema t ON t.tema_id = u.tema_id, LATERAL app.perfil_aluno(u.pessoa_id) pf
   WHERE app.papel_painel() IS NOT NULL
   GROUP BY u.pessoa_id, pf.ano, pf.especialidade, pf.turma, t.codigo, u.tipo
   ORDER BY 5, 1, 6 $$;

REVOKE EXECUTE ON FUNCTION app.papel_painel(), app.aluno_painel(BIGINT), app.perfil_aluno(BIGINT), app.painel_notas(),
  app.painel_avaliacoes(), app.painel_mensagens(), app.painel_uso() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.papel_painel(), app.painel_notas(), app.painel_avaliacoes(), app.painel_mensagens(),
  app.painel_uso() TO api_rw;

COMMIT;
\echo 'jornada do aluno, pendencias, avaliacao ampliada e painel: prontos'
