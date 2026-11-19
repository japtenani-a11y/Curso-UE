-- ============================================================
-- 88_formato_tempo_v1.0.sql
-- OBJETIVO:
--  1. Formato fixo de cada peca (docs/formato_das_pecas.md) e conferencia automatica: a peca com erro de formato nao
--     pode ser publicada (o banco recusa). Avisos nao bloqueiam.
--  2. Questoes ancora: conferencia avisa o tema com menos de 2 questoes fixas (iguais nas seis ondas, para todos os anos).
--  3. Tempo de estudo de cada peca: nivel (essencial ou aprofundamento) e minutos estimados; o aluno ve no material.
--  4. Painel: aba "Conferencia dos temas" (formato, ancoras e tempo de cada tema).
-- PRE-REQUISITO: 81, 85. Pode ser rodado mais de uma vez.
-- DESFAZER: DROP TRIGGER tg_artefato_formato ON conteudo.artefato; (o resto nao muda nada do que ja existe)
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE conteudo.artefato ADD COLUMN IF NOT EXISTS nivel TEXT CHECK (nivel IN ('essencial', 'aprofundamento'));
ALTER TABLE conteudo.artefato ADD COLUMN IF NOT EXISTS minutos SMALLINT CHECK (minutos BETWEEN 1 AND 600);
COMMENT ON COLUMN conteudo.artefato.nivel IS 'Em branco: usa app.nivel_padrao(tipo). Preencher so para mudar o padrao da peca.';
COMMENT ON COLUMN conteudo.artefato.minutos IS 'Em branco: usa app.minutos_estimados(tipo, corpo). Preencher so para corrigir a estimativa.';

-- ---------- 1. conferencia de formato ----------
CREATE OR REPLACE FUNCTION conteudo.conferir_formato(p_tipo TEXT, p_corpo TEXT)
RETURNS TABLE (gravidade TEXT, mensagem TEXT)
LANGUAGE plpgsql IMMUTABLE SET search_path = pg_catalog AS $$
DECLARE
  c TEXT := coalesce(p_corpo, '');
  blocos TEXT[];
  b TEXT;
  n INT;
  k INT;
  perfil TEXT;
BEGIN
  -- comum a todas as pecas
  IF length(trim(c)) < 200 THEN
    gravidade := 'erro'; mensagem := 'Peça vazia ou curta demais (menos de 200 caracteres).'; RETURN NEXT; RETURN;
  END IF;
  IF c !~ '(^|\n)# \S' THEN
    gravidade := 'aviso'; mensagem := 'Falta o título da peça (linha começando com "# ").'; RETURN NEXT;
  END IF;
  IF split_part(ltrim(c), E'\n', 1) ~* 'rascunho' THEN
    gravidade := 'aviso'; mensagem := 'A primeira linha ainda diz RASCUNHO: tire a faixa antes de publicar, se a revisão já foi feita.'; RETURN NEXT;
  END IF;
  IF c ~* 'prontu[aá]rio\s*(n[ºo°.]*)?\s*:?\s*\d{4,}' OR c ~ '\d{3}\.\d{3}\.\d{3}-\d{2}' OR c ~* '\mregistro\s+hc\s*:?\s*\d{4,}' THEN
    gravidade := 'erro'; mensagem := 'Parece haver número de prontuário, registro ou CPF. Os casos do curso são fictícios: retire o dado.'; RETURN NEXT;
  END IF;

  IF p_tipo = 'objetivos' THEN
    FOREACH perfil IN ARRAY ARRAY['Graduação', 'R1', 'R2', 'R3', 'R+'] LOOP
      IF position(E'\n## ' || perfil IN E'\n' || c) = 0 THEN
        gravidade := 'erro'; mensagem := format('Falta a seção "## %s": o aluno desse perfil ficaria sem objetivos.', perfil); RETURN NEXT;
      END IF;
    END LOOP;

  ELSIF p_tipo = 'caso' THEN
    blocos := regexp_split_to_array(c, '\n\*\*Ponto de decisão\s*\d+');
    n := coalesce(array_length(blocos, 1), 1) - 1;
    IF n < 2 THEN
      gravidade := 'erro'; mensagem := format('O caso precisa de pelo menos 2 pontos de decisão ("**Ponto de decisão 1 — título**"); tem %s.', n); RETURN NEXT;
    END IF;
    FOR k IN 2 .. coalesce(array_length(blocos, 1), 1) LOOP
      b := blocos[k];
      IF b !~ '\nSitua[çc][ãa]o:' THEN gravidade := 'erro'; mensagem := format('Ponto de decisão %s sem a linha "Situação:".', k - 1); RETURN NEXT; END IF;
      IF b !~ '\nDiscuss[ãa]o:' THEN gravidade := 'erro'; mensagem := format('Ponto de decisão %s sem a linha "Discussão:".', k - 1); RETURN NEXT; END IF;
      IF b !~ '\nDica:' THEN gravidade := 'aviso'; mensagem := format('Ponto de decisão %s sem "Dica:" (ajuda graduação, R1 e R2).', k - 1); RETURN NEXT; END IF;
    END LOOP;
    IF c !~ '\*\*Desfecho' THEN gravidade := 'aviso'; mensagem := 'Falta o "**Desfecho**" no fim do caso.'; RETURN NEXT; END IF;

  ELSIF p_tipo = 'caso_base' THEN
    IF c !~ '\n(\*\*|## )Perguntas[^\n]*\n(\s*\n)*\s*1[.)]' THEN
      gravidade := 'erro'; mensagem := 'Falta o bloco "**Perguntas...**" seguido das perguntas numeradas (1., 2., ...).'; RETURN NEXT;
    END IF;

  ELSIF p_tipo = 'checklist' THEN
    n := (SELECT count(*) FROM regexp_matches(c, '\n\s*- \[ \]', 'g'));
    IF n < 3 THEN gravidade := 'erro'; mensagem := format('O checklist precisa de itens "- [ ] ..." (pelo menos 3); tem %s.', n); RETURN NEXT; END IF;
    IF c !~ '\n\*\*[^*\n]+\*\*\s*\n' THEN gravidade := 'aviso'; mensagem := 'Sem grupos ("**Antes da chegada**" etc.): os itens aparecem numa lista só.'; RETURN NEXT; END IF;

  ELSIF p_tipo = 'slides' THEN
    n := (SELECT count(*) FROM regexp_matches(c, '\n### Slide \d+\.', 'g'));
    IF n < 3 THEN gravidade := 'erro'; mensagem := format('Os slides precisam de títulos "### Slide N. título" (pelo menos 3); tem %s.', n); RETURN NEXT; END IF;
    k := (SELECT count(*) FROM regexp_matches(c, '\n> \*\*Fala:\*\*', 'g'));
    IF k < n THEN
      gravidade := 'aviso'; mensagem := format('%s de %s slides sem "> **Fala:**": esses ficam sem áudio e não avançam sozinhos.', n - k, n); RETURN NEXT;
    END IF;

  ELSIF p_tipo = 'mapa' THEN
    IF c !~ '```mermaid\s*\n\s*mindmap' OR c !~ 'root\(\(' THEN
      gravidade := 'erro'; mensagem := 'O mapa precisa de um bloco ```mermaid com "mindmap" e a raiz "root((...))".'; RETURN NEXT;
    END IF;

  ELSIF p_tipo = 'flashcard' THEN
    n := (SELECT count(*) FROM regexp_matches(c, '\n\|\s*\d+\s*\|[^|\n]+\|[^|\n]+\|', 'g'));
    IF n < 5 THEN gravidade := 'erro'; mensagem := format('Os flashcards precisam de linhas "| n | frente | verso |" (pelo menos 5); tem %s.', n); RETURN NEXT; END IF;

  ELSIF p_tipo = 'podcast_roteiro' THEN
    n := (SELECT count(*) FROM regexp_matches(c, '\n\*\*(PRECEPTOR|RESIDENTE):\*\*', 'g'));
    IF n < 4 THEN gravidade := 'erro'; mensagem := format('O roteiro precisa de falas "**PRECEPTOR:**" e "**RESIDENTE:**" (pelo menos 4); tem %s.', n); RETURN NEXT; END IF;

  ELSIF p_tipo IN ('resumo', 'resumo_basico', 'aula', 'protocolo', 'sintese_evidencia') THEN
    n := (SELECT count(*) FROM regexp_matches(c, '\n## \S', 'g'));
    IF n < 2 THEN gravidade := 'erro'; mensagem := format('A peça precisa de seções "## título" (pelo menos 2); tem %s.', n); RETURN NEXT; END IF;
    IF p_tipo = 'sintese_evidencia' THEN
      FOREACH perfil IN ARRAY ARRAY['Consenso', 'Disputa', 'Lacunas'] LOOP
        IF position(E'\n## ' || perfil IN E'\n' || c) = 0 THEN
          gravidade := 'aviso'; mensagem := format('Falta a seção "## %s" do padrão da síntese de evidência.', perfil); RETURN NEXT;
        END IF;
      END LOOP;
    END IF;
    -- Diretriz clinica do tema (decisao de 19/11/2026, docs/diretriz_do_tema.md). Aviso, para nao travar pecas ja publicadas.
    IF p_tipo = 'protocolo' THEN
      FOREACH perfil IN ARRAY ARRAY['Escopo e população', 'Usuários e cenário', 'Definições', 'Recomendações', 'Fluxograma',
                                    'Quadro-resumo', 'Fluxo de atendimento e regulação', 'Matriz de responsabilidades',
                                    'Indicadores de qualidade', 'Monitoramento e melhoria', 'Segurança do paciente',
                                    'Adaptação local', 'Implantação', 'Exceções', 'Método e fontes', 'Equipes para validação',
                                    'Grupo de elaboração e conflitos de interesse', 'Limitações e lacunas', 'Revisão'] LOOP
        IF position(E'\n## ' || perfil IN E'\n' || c) = 0 THEN
          gravidade := 'aviso'; mensagem := format('Guia de atendimento: falta a seção "## %s".', perfil); RETURN NEXT;
        END IF;
      END LOOP;
      n := (SELECT count(*) FROM regexp_matches(c, '\n\*\*Recomendação \d+', 'g'));
      IF n < 3 THEN gravidade := 'aviso'; mensagem := format('Diretriz: o padrão tem ao menos 3 "**Recomendação N.**"; tem %s.', n); RETURN NEXT; END IF;
      k := (SELECT count(*) FROM regexp_matches(c, '\nForça: ', 'g'));
      IF n > 0 AND k < n THEN gravidade := 'aviso'; mensagem := format('Diretriz: %s recomendações sem a linha "Força: ... | Certeza: ...".', n - k); RETURN NEXT; END IF;
      k := (SELECT count(*) FROM regexp_matches(c, '\nOrigem: ', 'g'));
      IF n > 0 AND k < n THEN gravidade := 'aviso'; mensagem := format('Diretriz: %s recomendações sem a linha "Origem: ..." (diretriz de onde veio).', n - k); RETURN NEXT; END IF;
      IF c !~* '\n>\s*PROPOSTA' THEN gravidade := 'aviso'; mensagem := 'Diretriz: falta a faixa "> PROPOSTA para avaliação da diretoria e validação pelas equipes..." logo abaixo do título (a diretriz é sempre proposta).'; RETURN NEXT; END IF;
      IF c !~* 'nível 5' OR c !~* 'nível 0' THEN gravidade := 'aviso'; mensagem := 'Guia de atendimento: a seção "Implantação" deve trazer os níveis de maturidade 0 a 5 (docs/maturidade_implantacao.md).'; RETURN NEXT; END IF;
      IF c !~* 'passo a passo \(do nível 0 ao nível 5\)' THEN gravidade := 'aviso'; mensagem := 'Guia de atendimento: a execução passo a passo deve ir do nível 0 ao nível 5, com o título "Execução passo a passo (do nível 0 ao nível 5)".'; RETURN NEXT; END IF;
      IF c !~ '```mermaid' THEN gravidade := 'aviso'; mensagem := 'Diretriz: o fluxograma deve vir num bloco ```mermaid (flowchart).'; RETURN NEXT; END IF;
    END IF;

  ELSIF p_tipo ~ '^teste_[1-6]$' THEN
    FOREACH perfil IN ARRAY ARRAY['Graduação', 'R1', 'R2', 'R3', 'R+'] LOOP
      IF position(E'\n## Perfil ' || perfil IN E'\n' || c) = 0 THEN
        gravidade := 'erro'; mensagem := format('Falta a seção "## Perfil %s".', perfil); RETURN NEXT;
      END IF;
    END LOOP;
    blocos := regexp_split_to_array(c, '\n\*\*\d+\.\*\*');
    FOR k IN 2 .. coalesce(array_length(blocos, 1), 1) LOOP
      n := (SELECT count(*) FROM regexp_matches(split_part(blocos[k], E'\n\n', 1) || E'\n' || split_part(blocos[k], E'\n\n', 2), '\n- [A-E]\)', 'g'));
      IF n <> 5 THEN gravidade := 'erro'; mensagem := format('A %sª questão do arquivo tem %s alternativas; o padrão é 5 (A a E).', k - 1, n); RETURN NEXT; END IF;
    END LOOP;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION conteudo.erros_formato(p_tipo TEXT, p_corpo TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT string_agg(mensagem, ' | ') FROM conteudo.conferir_formato(p_tipo, p_corpo) WHERE gravidade = 'erro' $$;

-- O banco recusa publicar peca com erro de formato (avisos passam).
CREATE OR REPLACE FUNCTION conteudo.fn_artefato_formato() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, conteudo AS $$
DECLARE e TEXT;
BEGIN
  IF NEW.status::text = 'publicado'
     AND (TG_OP = 'INSERT' OR OLD.status::text IS DISTINCT FROM 'publicado' OR OLD.corpo IS DISTINCT FROM NEW.corpo) THEN
    e := conteudo.erros_formato(NEW.tipo::text, NEW.corpo);
    IF e IS NOT NULL THEN
      RAISE EXCEPTION 'formato_invalido: %', e
        USING ERRCODE = '23514', HINT = 'Corrija o formato da peça (docs/formato_das_pecas.md) e publique de novo.';
    END IF;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_artefato_formato ON conteudo.artefato;
CREATE TRIGGER tg_artefato_formato BEFORE INSERT OR UPDATE ON conteudo.artefato
  FOR EACH ROW EXECUTE FUNCTION conteudo.fn_artefato_formato();

-- ---------- 3. tempo de estudo ----------
CREATE OR REPLACE FUNCTION app.nivel_padrao(p_tipo TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN p_tipo IN ('objetivos', 'resumo_basico', 'caso_base', 'slides', 'caso', 'resumo', 'checklist') THEN 'essencial'
              WHEN p_tipo IN ('podcast_roteiro', 'sintese_evidencia', 'mapa', 'aula', 'protocolo', 'flashcard', 'simulado') THEN 'aprofundamento' END $$;

-- Estimativa: leitura de estudo a 130 palavras por minuto; fala (slides com fala e podcast) a 150; mais o tempo de responder
-- (3 min por ponto de decisao do caso e por pergunta do caso base; 30 s por flashcard; 1 min por questao do banco).
CREATE OR REPLACE FUNCTION app.minutos_estimados(p_tipo TEXT, p_corpo TEXT) RETURNS INT
LANGUAGE plpgsql IMMUTABLE SET search_path = pg_catalog AS $$
DECLARE
  c TEXT := regexp_replace(coalesce(p_corpo, ''), '^\s*>[^\n]*\n', '');   -- sem a faixa de rascunho
  palavras INT := coalesce(array_length(regexp_split_to_array(trim(c), '\s+'), 1), 0);
  falas TEXT;
  m NUMERIC;
BEGIN
  IF p_tipo = 'slides' THEN
    falas := (SELECT string_agg(x[1], ' ') FROM regexp_matches(c, '\n> \*\*Fala:\*\*([^\n]*)', 'g') x);
    m := CASE WHEN falas IS NULL THEN 1.5 * (SELECT count(*) FROM regexp_matches(c, '\n### Slide \d+\.', 'g'))
              ELSE array_length(regexp_split_to_array(trim(falas), '\s+'), 1) / 150.0 END;
  ELSIF p_tipo = 'podcast_roteiro' THEN m := palavras / 150.0;
  ELSIF p_tipo = 'caso' THEN m := palavras / 130.0 + 3 * (SELECT count(*) FROM regexp_matches(c, '\n\*\*Ponto de decisão', 'g'));
  ELSIF p_tipo = 'caso_base' THEN
    m := palavras / 130.0 + 3 * greatest(1, (SELECT count(*) FROM regexp_matches(substring(c FROM '(?:\*\*|## )Perguntas.*$'), '\n\s*\d+[.)]', 'g')));
  ELSIF p_tipo = 'flashcard' THEN m := 0.5 * (SELECT count(*) FROM regexp_matches(c, '\n\|\s*\d+\s*\|', 'g'));
  ELSIF p_tipo = 'mapa' THEN m := 10;
  ELSIF p_tipo = 'simulado' THEN m := (SELECT count(*) FROM regexp_matches(c, '\n\*\*\d+\.\*\*', 'g'));
  ELSE m := palavras / 130.0;
  END IF;
  RETURN greatest(3, ceil(m))::int;
END $$;

CREATE OR REPLACE FUNCTION app.tempo_peca(p_artefato BIGINT)
RETURNS TABLE (nivel TEXT, minutos INT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app, conteudo AS $$
  SELECT coalesce(a.nivel, app.nivel_padrao(a.tipo::text)), coalesce(a.minutos::int, app.minutos_estimados(a.tipo::text, a.corpo))
    FROM conteudo.artefato a WHERE a.artefato_id = p_artefato $$;

CREATE OR REPLACE FUNCTION app.formato_peca(p_artefato BIGINT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, app, conteudo AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('gravidade', f.gravidade, 'mensagem', f.mensagem) ORDER BY f.gravidade), '[]'::jsonb)
    FROM conteudo.artefato a CROSS JOIN LATERAL conteudo.conferir_formato(a.tipo::text, a.corpo) f
   WHERE a.artefato_id = p_artefato $$;

-- ---------- 4. conferencia dos temas (painel) ----------
-- Para cada tema com alguma peca: a versao mais recente de cada tipo (publicada ou rascunho), seus erros e avisos de
-- formato, as questoes ancora e o tempo essencial antes da aula.
DROP FUNCTION IF EXISTS app.painel_conferencia();
CREATE FUNCTION app.painel_conferencia()
RETURNS TABLE (tema TEXT, titulo TEXT, pecas_publicadas INT, rascunhos INT, erros INT, avisos INT, questoes_ancora INT,
               essencial_antes_min INT, essencial_total_min INT, aprofundamento_min INT, pendencias TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
  WITH ult AS (
    SELECT DISTINCT ON (a.tema_id, a.tipo) a.*
      FROM conteudo.artefato a
     WHERE a.status::text IN ('publicado', 'rascunho') AND app.etapa_do_material(a.tipo::text) IS NOT NULL
     ORDER BY a.tema_id, a.tipo, a.versao DESC),
  pub AS (
    SELECT DISTINCT ON (a.tema_id, a.tipo) a.* FROM conteudo.artefato a
     WHERE a.status::text = 'publicado' AND app.etapa_do_material(a.tipo::text) IS NOT NULL
     ORDER BY a.tema_id, a.tipo, a.versao DESC),
  f AS (SELECT u.tema_id, u.tipo, x.gravidade, x.mensagem FROM ult u CROSS JOIN LATERAL conteudo.conferir_formato(u.tipo::text, u.corpo) x),
  tp AS (SELECT u.tema_id, u.tipo, app.etapa_do_material(u.tipo::text) AS etapa, t.nivel, t.minutos
           FROM ult u CROSS JOIN LATERAL app.tempo_peca(u.artefato_id) t)
  SELECT tm.codigo, tm.titulo,
         (SELECT count(*) FROM pub WHERE pub.tema_id = tm.tema_id)::int,
         (SELECT count(*) FROM ult WHERE ult.tema_id = tm.tema_id AND ult.status::text = 'rascunho')::int,
         (SELECT count(*) FROM f WHERE f.tema_id = tm.tema_id AND f.gravidade = 'erro')::int,
         (SELECT count(*) FROM f WHERE f.tema_id = tm.tema_id AND f.gravidade = 'aviso')::int,
         (SELECT count(*) FROM app.item i WHERE i.tema_id = tm.tema_id AND i.fixa)::int,
         (SELECT sum(minutos) FROM tp WHERE tp.tema_id = tm.tema_id AND tp.nivel = 'essencial' AND tp.etapa = 2)::int,
         (SELECT sum(minutos) FROM tp WHERE tp.tema_id = tm.tema_id AND tp.nivel = 'essencial')::int,
         (SELECT sum(minutos) FROM tp WHERE tp.tema_id = tm.tema_id AND tp.nivel = 'aprofundamento')::int,
         nullif(concat_ws(' · ',
           (SELECT string_agg(app.nome_material(f.tipo::text) || ': ' || f.mensagem, ' · ' ORDER BY f.tipo)
              FROM f WHERE f.tema_id = tm.tema_id AND f.gravidade = 'erro'),
           CASE WHEN (SELECT count(*) FROM app.item i WHERE i.tema_id = tm.tema_id AND i.fixa) < 2
                THEN 'Questões âncora: ' || (SELECT count(*) FROM app.item i WHERE i.tema_id = tm.tema_id AND i.fixa) || ' de 2 a 3 recomendadas' END,
           CASE WHEN (SELECT sum(minutos) FROM tp WHERE tp.tema_id = tm.tema_id AND tp.nivel = 'essencial' AND tp.etapa = 2) > 90
                THEN 'Essencial antes da aula passa de 90 min' END), '')
    FROM app.tema tm
   WHERE EXISTS (SELECT 1 FROM ult WHERE ult.tema_id = tm.tema_id) AND app.papel_painel() IS NOT NULL
   ORDER BY tm.codigo $$;

GRANT EXECUTE ON FUNCTION conteudo.conferir_formato(TEXT, TEXT), conteudo.erros_formato(TEXT, TEXT), app.nivel_padrao(TEXT),
  app.minutos_estimados(TEXT, TEXT), app.tempo_peca(BIGINT), app.formato_peca(BIGINT), app.painel_conferencia() TO api_rw;
GRANT USAGE ON SCHEMA conteudo TO api_rw;

COMMIT;

SELECT 'formato e tempo (88): pronto' AS situacao;
SELECT u.tipo, x.gravidade, left(x.mensagem, 90)
  FROM (SELECT DISTINCT ON (tipo) * FROM conteudo.artefato WHERE status::text = 'publicado' ORDER BY tipo, versao DESC) u
  CROSS JOIN LATERAL conteudo.conferir_formato(u.tipo::text, u.corpo) x WHERE x.gravidade = 'erro';
