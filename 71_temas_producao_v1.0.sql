-- 71_temas_producao_v1.0.sql
-- Temas em producao e avisos de tema novo.
--  (1) Mural: espaco "Temas novos no site". Quando um tema recebe a PRIMEIRA peca publicada, o sistema publica
--      sozinho um aviso no mural (categoria novo_tema) e manda e-mail para quem pediu "Avise-me" naquele tema.
--  (2) "Avise-me quando publicar": o residente que abre um tema ainda em producao pode pedir o aviso.
--  (3) Fila de producao para a coordenacao: o que falta produzir, em que ordem, e quantos alunos esperam cada tema.
-- Pre-requisito: 53, 60, 65, 66. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;

-- ---------- (1) mural com categoria e tema ----------
ALTER TABLE app.mural ADD COLUMN IF NOT EXISTS categoria TEXT;
ALTER TABLE app.mural ADD COLUMN IF NOT EXISTS tema_id BIGINT REFERENCES app.tema(tema_id) ON DELETE SET NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_mural_novo_tema ON app.mural (tema_id) WHERE categoria = 'novo_tema';

CREATE OR REPLACE FUNCTION app.mural_lista() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
      'id', m.mural_id, 'tipo', m.tipo, 'titulo', m.titulo, 'corpo', m.corpo, 'fixado', m.fixado, 'publico', m.publico,
      'publicado_em', m.publicado_em, 'expira_em', m.expira_em, 'arquivo_nome', m.arquivo_nome,
      'categoria', m.categoria, 'tema', (SELECT t.codigo FROM app.tema t WHERE t.tema_id = m.tema_id),
      'lido', EXISTS (SELECT 1 FROM app.mural_leitura l WHERE l.mural_id = m.mural_id AND l.pessoa_id = app.pessoa_atual()),
      'respondido', EXISTS (SELECT 1 FROM app.mural_resposta r WHERE r.mural_id = m.mural_id AND r.pessoa_id = app.pessoa_atual()),
      'minhas_respostas', (SELECT r.respostas FROM app.mural_resposta r WHERE r.mural_id = m.mural_id AND r.pessoa_id = app.pessoa_atual()),
      'n_respostas', CASE WHEN app.eh_revisor() THEN (SELECT count(*) FROM app.mural_resposta r WHERE r.mural_id = m.mural_id) END,
      'perguntas', (SELECT jsonb_agg(jsonb_build_object('ordem', q.ordem, 'texto', q.texto, 'tipo', q.tipo, 'opcoes', q.opcoes,
                                                        'obrigatoria', q.obrigatoria) ORDER BY q.ordem)
                      FROM app.mural_pergunta q WHERE q.mural_id = m.mural_id))
      ORDER BY m.fixado DESC, m.publicado_em DESC), '[]'::jsonb)
    FROM app.mural m
   WHERE app.pessoa_atual() IS NOT NULL AND NOT m.arquivado
     AND (m.expira_em IS NULL OR m.expira_em > now() OR app.eh_revisor())
     AND (app.eh_revisor() OR m.publico IN ('alunos','todos')) $$;

-- ---------- (2) avise-me ----------
CREATE TABLE IF NOT EXISTS app.tema_interesse (
  pessoa_id BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id   BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  avisado_em TIMESTAMPTZ,
  PRIMARY KEY (pessoa_id, tema_id));

CREATE OR REPLACE FUNCTION app.tema_publicado(p_tema BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  SELECT EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = p_tema AND a.status = 'publicado') $$;

-- Situacao de producao de um tema para a pessoa logada.
CREATE OR REPLACE FUNCTION app.situacao_producao(p_codigo TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  SELECT jsonb_build_object('codigo', t.codigo, 'publicado', app.tema_publicado(t.tema_id),
    'em_revisao', EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status IN ('rascunho','revisao','aprovado')),
    'avisar', EXISTS (SELECT 1 FROM app.tema_interesse i WHERE i.tema_id = t.tema_id AND i.pessoa_id = app.pessoa_atual() AND i.avisado_em IS NULL),
    'interessados', (SELECT count(*) FROM app.tema_interesse i WHERE i.tema_id = t.tema_id AND i.avisado_em IS NULL))
    FROM app.tema t WHERE replace(t.codigo,'-','') = replace(upper(p_codigo),'-','') AND app.pessoa_atual() IS NOT NULL $$;

CREATE OR REPLACE FUNCTION app.avisar_tema(p_codigo TEXT, p_ativo BOOLEAN) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v BIGINT;
BEGIN
  IF app.pessoa_atual() IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  SELECT tema_id INTO v FROM app.tema WHERE replace(codigo,'-','') = replace(upper(p_codigo),'-','');
  IF v IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  IF p_ativo THEN
    INSERT INTO app.tema_interesse (pessoa_id, tema_id) VALUES (app.pessoa_atual(), v)
    ON CONFLICT (pessoa_id, tema_id) DO UPDATE SET avisado_em = NULL, criado_em = now();
  ELSE
    DELETE FROM app.tema_interesse WHERE pessoa_id = app.pessoa_atual() AND tema_id = v;
  END IF;
END $$;

-- Primeira peca publicada de um tema: aviso no mural e e-mail para quem pediu.
CREATE OR REPLACE FUNCTION app.fn_tema_novo_publicado() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE t app.tema%ROWTYPE; v_mural BIGINT;
BEGIN
  IF NEW.status <> 'publicado' OR (TG_OP = 'UPDATE' AND OLD.status = 'publicado') THEN RETURN NEW; END IF;
  IF EXISTS (SELECT 1 FROM conteudo.artefato a WHERE a.tema_id = NEW.tema_id AND a.status = 'publicado' AND a.artefato_id <> NEW.artefato_id) THEN
    RETURN NEW;
  END IF;
  SELECT * INTO t FROM app.tema WHERE tema_id = NEW.tema_id;
  INSERT INTO app.mural (tipo, titulo, corpo, publico, categoria, tema_id)
  VALUES ('aviso', 'Tema novo no site: ' || t.codigo || ' — ' || left(t.titulo, 150),
          'O material do tema **' || t.codigo || ' — ' || t.titulo || '** foi publicado. Abra o tema em /aluno/tema/'
          || replace(t.codigo, '-', '') || ' para ver as peças, os testes e, se for um tema opcional, agendar o seu D0.',
          'alunos', 'novo_tema', t.tema_id)
  ON CONFLICT DO NOTHING RETURNING mural_id INTO v_mural;
  INSERT INTO app.notificacao_saida (pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT i.pessoa_id, 'email', coalesce(c.email_aviso, pe.email_primario::text),
         'Publicado: ' || t.codigo || ' — ' || left(t.titulo, 100),
         'Você pediu para ser avisado quando este tema fosse publicado. O material de ' || t.codigo || ' — ' || t.titulo
           || ' já está no site.',
         jsonb_build_object('caminho', '/aluno/tema/' || replace(t.codigo, '-', ''), 'rotulo_link', 'Abrir o tema',
                            'rodape', 'Você recebe este aviso porque clicou em "Avise-me" neste tema.')
    FROM app.tema_interesse i JOIN app.pessoa pe ON pe.pessoa_id = i.pessoa_id
    LEFT JOIN app.contato_aluno c ON c.pessoa_id = i.pessoa_id
   WHERE i.tema_id = t.tema_id AND i.avisado_em IS NULL AND coalesce(c.aceita_email, true);
  UPDATE app.tema_interesse SET avisado_em = now() WHERE tema_id = t.tema_id AND avisado_em IS NULL;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_tema_novo_publicado ON conteudo.artefato;
CREATE TRIGGER tg_tema_novo_publicado AFTER INSERT OR UPDATE OF status ON conteudo.artefato
  FOR EACH ROW EXECUTE FUNCTION app.fn_tema_novo_publicado();

-- Temas ja publicados antes deste script: entram no espaco "Temas novos" com a data da primeira publicacao
-- (sem e-mail e sem aparecer como novidade para quem ja viu).
INSERT INTO app.mural (tipo, titulo, corpo, publico, categoria, tema_id, publicado_em)
SELECT 'aviso', 'Tema novo no site: ' || t.codigo || ' — ' || left(t.titulo, 150),
       'O material do tema **' || t.codigo || ' — ' || t.titulo || '** está publicado. Abra o tema em /aluno/tema/' || replace(t.codigo, '-', '') || '.',
       'alunos', 'novo_tema', t.tema_id, coalesce(min(a.publicado_em), now())
  FROM app.tema t JOIN conteudo.artefato a ON a.tema_id = t.tema_id AND a.status = 'publicado'
 GROUP BY t.tema_id, t.codigo, t.titulo
ON CONFLICT DO NOTHING;

-- ---------- (3) fila de producao ----------
-- status: publicado | em_revisao (tem peca em rascunho/revisao/aprovada) | nao_iniciado.
-- prioridade: temas principais pela data da aula; depois os opcionais com mais alunos esperando (avise-me + agendados),
-- os que liberam mais temas na arvore e os mais proximos da raiz.
DROP FUNCTION IF EXISTS app.fila_producao();
CREATE FUNCTION app.fila_producao()
RETURNS TABLE (posicao INT, codigo TEXT, titulo TEXT, modulo TEXT, papel TEXT, ordem SMALLINT, status TEXT, pecas_publicadas INT,
               pecas_em_revisao INT, aula_em TIMESTAMPTZ, interessados INT, agendados INT, libera INT, maes TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH RECURSIVE desc_(raiz, tema_id) AS (
    SELECT r.requisito_id, r.tema_id FROM app.tema_requisito r
    UNION SELECT d.raiz, r.tema_id FROM desc_ d JOIN app.tema_requisito r ON r.requisito_id = d.tema_id),
  base AS (
    SELECT t.*,
      (SELECT count(*)::int FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status = 'publicado') AS pub,
      (SELECT count(*)::int FROM conteudo.artefato a WHERE a.tema_id = t.tema_id AND a.status IN ('rascunho','revisao','aprovado')) AS rev,
      (SELECT min(a.data_hora) FROM app.agenda_aula a WHERE a.tema_id = t.tema_id) AS aula,
      (SELECT count(*)::int FROM app.tema_interesse i WHERE i.tema_id = t.tema_id AND i.avisado_em IS NULL) AS inter,
      (SELECT count(DISTINCT o.pessoa_id)::int FROM app.onda_instancia o WHERE o.tema_id = t.tema_id AND o.pessoa_id IS NOT NULL) AS agend,
      (SELECT count(DISTINCT d.tema_id)::int FROM desc_ d WHERE d.raiz = t.tema_id) AS lib,
      (SELECT string_agg(m.codigo, ' ' ORDER BY m.codigo) FROM app.tema_requisito r JOIN app.tema m ON m.tema_id = r.requisito_id
        WHERE r.tema_id = t.tema_id) AS maes_txt
      FROM app.tema t)
  SELECT (row_number() OVER (ORDER BY (b.pub > 0), (b.papel_curricular <> 'nuclear'), b.ordem_principal NULLS LAST,
                                      (b.inter + b.agend) DESC, b.lib DESC, b.papel_curricular, b.dificuldade, b.codigo))::int,
         b.codigo, b.titulo, b.modulo, b.papel_curricular, b.ordem_principal,
         CASE WHEN b.pub > 0 THEN 'publicado' WHEN b.rev > 0 THEN 'em_revisao' ELSE 'nao_iniciado' END,
         b.pub, b.rev, b.aula, b.inter, b.agend, b.lib, b.maes_txt
    FROM base b
   WHERE app.eh_revisor() OR app.papel_painel() IS NOT NULL
   ORDER BY 1 $$;

REVOKE EXECUTE ON FUNCTION app.situacao_producao(TEXT), app.avisar_tema(TEXT, BOOLEAN), app.fila_producao(), app.tema_publicado(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.situacao_producao(TEXT), app.avisar_tema(TEXT, BOOLEAN), app.fila_producao(), app.tema_publicado(BIGINT) TO api_rw;

-- Inicio da coordenacao: quantos temas faltam produzir e quantos alunos esperam algum tema.
CREATE OR REPLACE FUNCTION app.resumo_producao() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object('publicados', count(*) FILTER (WHERE status = 'publicado'),
    'em_revisao', count(*) FILTER (WHERE status = 'em_revisao'), 'nao_iniciados', count(*) FILTER (WHERE status = 'nao_iniciado'),
    'esperando', coalesce(sum(interessados) FILTER (WHERE status <> 'publicado'), 0),
    'proximos', (SELECT jsonb_agg(jsonb_build_object('codigo', f.codigo, 'titulo', f.titulo, 'status', f.status, 'papel', f.papel,
                   'aula_em', f.aula_em, 'interessados', f.interessados) ORDER BY f.posicao)
                   FROM (SELECT * FROM app.fila_producao() WHERE status <> 'publicado' ORDER BY posicao LIMIT 5) f))
    FROM app.fila_producao() WHERE app.eh_revisor() $$;
REVOKE EXECUTE ON FUNCTION app.resumo_producao() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.resumo_producao() TO api_rw;

COMMIT;
\echo 'temas em producao, aviso de tema novo e fila de producao: pronto'
