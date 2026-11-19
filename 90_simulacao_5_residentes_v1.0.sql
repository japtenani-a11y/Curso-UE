-- 90_simulacao_5_residentes_v1.0.sql
-- DADOS SIMULADOS para desenvolvimento (telas, painel, analises). NAO SAO DADOS DE PESQUISA.
-- Cria 5 residentes ficticios (e-mails @simulado.local, nomes comecando com "SIMULADO") e simula o T001 inteiro, com a aula
-- em 13/08/2026 (quinta, 20h), de modo que todas as ondas (pre-teste 1 ao D+90) ja passaram:
--   respostas com certeza e tempo, notas, caso base, caso da aula (com uma segunda tentativa), checklist, onde parou,
--   tempo de leitura, uso do material, avaliacoes, aplicabilidade, duvidas, presenca, termos e consentimento.
-- Perfis (para gerar padroes diferentes nos graficos):
--   Ana     R1 Cirurgia Geral        estudiosa, faz tudo no prazo, certeza bem calibrada
--   Bruno   R1 Medicina de Emergencia deixa para depois: pre-teste 2 depois da aula, respostas rapidas demais, nao faz o D+90
--   Carla   R2 Cirurgia Geral        confiante demais: muito "tenho certeza" errado; refaz o caso da aula
--   Diego   R3 Cirurgia do Trauma    bom e estavel, esquece pouco
--   Elisa   R4 (R+) Cirurgia Geral   muito boa, mas insegura (marca "chutei" e "acho que sim"); nao aceita a pesquisa
-- Sorteio fixo (setseed): rodar de novo num banco limpo gera os mesmos dados. Se ja houver simulacao, nada e feito.
-- Pre-requisito: todos os scripts ate o 84 e o T001 com questoes (37/39). Nao entra no subir: rode a mao.
-- USO:    psql -h localhost -U postgres -d programa -f 90_simulacao_5_residentes_v1.0.sql
-- APAGAR: psql -h localhost -U postgres -d programa -f 91_apagar_simulacao_v1.0.sql   (antes de abrir o curso)
-- Nenhum e-mail e enviado: os simulados nao autorizam e-mails e o aviso de duvida fica desligado durante a carga.
\set ON_ERROR_STOP on
BEGIN;
SELECT setseed(0.2027);
ALTER TABLE app.mensagem_aluno DISABLE TRIGGER tg_duvida_avisar;
ALTER TABLE app.mensagem_aluno DISABLE TRIGGER tg_feedback_registrado;
CREATE TEMP TABLE sim_it (item_id BIGINT, ordem SMALLINT, chance NUMERIC, chave NUMERIC, acerta BOOLEAN) ON COMMIT DROP;

DO $$
DECLARE
  -- email, nome, grau, especialidade (ficha), especialidade (texto), theta, ganho, esquece, vies_certeza, pct_rapido,
  -- pre2_atrasado, pula_d90, leitura (0-1), nps, consente
  perfis JSONB := '[
    {"k":"ana","nome":"SIMULADO Ana Ribeiro","grau":"R1","esp":"cirurgia_geral","espt":"Cirurgia Geral","ingresso":2026,"theta":-0.3,"ganho":1.1,"esquece":0.6,"vies":0.0,"rapido":0.0,"pre2_atraso":false,"pula_d90":false,"leitura":0.95,"nps":9,"consente":true},
    {"k":"bruno","nome":"SIMULADO Bruno Teixeira","grau":"R1","esp":"medicina_emergencia","espt":"Medicina de Emergência","ingresso":2026,"theta":-0.6,"ganho":0.7,"esquece":1.4,"vies":0.05,"rapido":0.22,"pre2_atraso":true,"pula_d90":true,"leitura":0.35,"nps":6,"consente":true},
    {"k":"carla","nome":"SIMULADO Carla Mendes","grau":"R2","esp":"cirurgia_geral","espt":"Cirurgia Geral","ingresso":2025,"theta":0.0,"ganho":0.9,"esquece":1.0,"vies":0.35,"rapido":0.03,"pre2_atraso":false,"pula_d90":false,"leitura":0.6,"nps":8,"consente":true},
    {"k":"diego","nome":"SIMULADO Diego Albuquerque","grau":"R3","esp":"cirurgia_urgencia_trauma","espt":"Cirurgia do Trauma","ingresso":2024,"theta":0.5,"ganho":0.9,"esquece":0.4,"vies":0.05,"rapido":0.0,"pre2_atraso":false,"pula_d90":false,"leitura":0.8,"nps":10,"consente":true},
    {"k":"elisa","nome":"SIMULADO Elisa Fonseca","grau":"R4","esp":"cirurgia_geral","espt":"Cirurgia Geral","ingresso":2023,"theta":1.0,"ganho":0.6,"esquece":0.3,"vies":-0.35,"rapido":0.0,"pre2_atraso":false,"pula_d90":false,"leitura":0.7,"nps":9,"consente":false}
  ]'::jsonb;
  -- condutas no caso da aula (6 pontos): [boa, errada]
  condutas JSONB := '[
    ["Controlo o sangramento primeiro (CAB): reviso o torniquete e comprimo a ferida antes da via aérea.", "Começo pela via aérea e coloco colar; depois vejo o sangramento."],
    ["Agitação pode ser choque: avalio perfusão antes de sedar; se precisar intubar, faço exame neurológico antes.", "Sedo para conseguir examinar com calma."],
    ["Oxigênio guiado pela saturação; eFAST negativo não encerra: sigo investigando o tórax.", "eFAST negativo, então não tem pneumotórax; sigo para o abdome."],
    ["Meço a pressão manualmente e não decido por um número; a pele fria preocupa.", "PA 104/66, melhorou; posso reduzir o volume."],
    ["Aqueço com mantas, ar forçado e fluido aquecido antes e durante a ida à TC.", "Levo direto para a TC e aqueço depois."],
    ["Faço avaliação terciária: examino de novo e peço radiografia do punho.", "A TC já foi normal; prescrevo analgésico."]
  ]'::jsonb;
  respostas_cb JSONB := '[
    ["O R2 lidera até o assistente chegar; nos 8 minutos, distribuo funções, preparo torniquete e aquecimento.", "Quem chegar primeiro; espero o assistente."],
    ["Pela coxa: sangramento externo grave vem antes da via aérea, porque ela fala.", "Via aérea primeiro, sempre."],
    ["Preocupa: agitação pode ser choque.", "Tranquiliza, está consciente e falando."],
    ["Não: o aparelho automático pode errar no choque; meço manualmente.", "Sim, 118/76 é normal."],
    ["Oxigênio conforme a saturação; com 95% não é obrigatório.", "Sim, todo trauma grave recebe oxigênio."],
    ["Torniquete; risco de lesão e mais amputação, mas pode salvar a vida.", "Pinçar o vaso na ferida."],
    ["Não: todos falando ao mesmo tempo; deveria ser MIST, com a equipe ouvindo, em até 1 minuto.", "Sim, foi rápida."]
  ]'::jsonb;
  p JSONB; v_p BIGINT; v_tema BIGINT; v_ciclo BIGINT; v_d0 TIMESTAMPTZ := '2026-08-13 20:00:00-03'; v_dia DATE := '2026-08-13';
  v_onda BIGINT; v_t BIGINT; n INT; ts TIMESTAMPTZ; tdi TIMESTAMPTZ; it RECORD; th NUMERIC; pr NUMERIC; acerta BOOLEAN;
  alt BIGINT; cer INT; ms INT; sc NUMERIC; ordem INT; k INT; pontos JSONB; ant JSONB; cmp TEXT; boa BOOLEAN;
  ganhos NUMERIC[] := ARRAY[-0.8, 0.0, 1.3, 1.05, 0.8, 0.6]; perdas NUMERIC[] := ARRAY[0, 0, 0, 0.2, 0.4, 0.6];
  pecas TEXT[] := ARRAY['objetivos','resumo_basico','podcast_roteiro','caso_base','sintese_evidencia','mapa','aula','slides','caso','resumo','protocolo','checklist','flashcard','simulado'];
BEGIN
  IF EXISTS (SELECT 1 FROM app.pessoa WHERE email_primario::text LIKE '%@simulado.local') THEN
    RAISE NOTICE 'ja existe simulacao (contas @simulado.local); nada feito. Para refazer, rode antes o 91_apagar_simulacao.'; RETURN;
  END IF;
  SELECT tema_id, ciclo_id INTO v_tema, v_ciclo FROM app.tema WHERE upper(replace(codigo, '-', '')) = 'T001';
  IF v_tema IS NULL THEN RAISE EXCEPTION 'T001 nao encontrado'; END IF;

  FOR p IN SELECT * FROM jsonb_array_elements(perfis) LOOP
    -- pessoa, ano, ficha, termos, consentimento
    INSERT INTO app.pessoa (nome_completo, email_primario) VALUES (p->>'nome', (p->>'k') || '@simulado.local') RETURNING pessoa_id INTO v_p;
    INSERT INTO app.posicao_anual (pessoa_id, perfil_id, ano_letivo, grau, ativo, especialidade)
    VALUES (v_p, (SELECT perfil_id FROM app.perfil WHERE codigo = 'aluno'), 2026, (p->>'grau')::app.grau_enum, true, p->>'espt');
    INSERT INTO app.ficha_aluno (pessoa_id, situacao, faculdade, especialidade, instituicao_residencia, ano_ingresso_residencia, status, decidido_em, enviado_em, confirmado_em)
    VALUES (v_p, 'residencia', 'Faculdade Simulada', p->>'esp', 'Hospital Simulado', (p->>'ingresso')::smallint, 'aprovado', v_d0 - interval '40 days', v_d0 - interval '41 days', v_d0 - interval '40 days');
    INSERT INTO app.aceite_termo (pessoa_id, codigo, versao, aceito, em)
    SELECT v_p, t.codigo, t.versao, true, v_d0 - interval '41 days' FROM app.termo t WHERE t.vigente;
    INSERT INTO app.consentimento_pesquisa (pessoa_id, aceito, versao_tcle, em)
    VALUES (v_p, (p->>'consente')::boolean, 'v2-2026-11', v_d0 - interval '41 days')
    ON CONFLICT (pessoa_id) DO UPDATE SET aceito = EXCLUDED.aceito;

    -- ondas proprias do T001 (mesmas regras do agendamento), aula em 13/08/2026 20h
    INSERT INTO app.onda_instancia (ciclo_id, onda_codigo, ordem_onda, data_abertura, data_fechamento, status, tema_id, teste_num, pessoa_id)
    SELECT v_ciclo, 'T001-' || x.cod || '-SIM' || v_p, 100 + x.n, x.abre, x.fecha,
           (CASE WHEN x.fecha <= now() THEN 'fechada' ELSE 'aberta' END)::app.status_onda, v_tema, x.n, v_p
      FROM (VALUES (1, 'PRE1', (v_dia - 15)::timestamp AT TIME ZONE 'America/Sao_Paulo', (v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo'),
                   (2, 'PRE2', (v_dia - 15)::timestamp AT TIME ZONE 'America/Sao_Paulo', v_d0 - interval '1 hour'),
                   (3, 'POS-D0', v_d0, (v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo'),
                   (4, 'POS-D15', (v_dia + 15)::timestamp AT TIME ZONE 'America/Sao_Paulo', (v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo'),
                   (5, 'POS-D45', (v_dia + 45)::timestamp AT TIME ZONE 'America/Sao_Paulo', (v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo'),
                   (6, 'POS-D90', (v_dia + 90)::timestamp AT TIME ZONE 'America/Sao_Paulo', (v_dia + 180)::timestamp AT TIME ZONE 'America/Sao_Paulo')) x(n, cod, abre, fecha);
    INSERT INTO app.item_selecionado (onda_id, item_id, ordem_apresentada)
    SELECT o.onda_id, i.item_id, row_number() OVER (PARTITION BY o.onda_id ORDER BY i.fixa DESC, i.perfil, i.codigo)::smallint
      FROM app.onda_instancia o JOIN app.item i ON i.tema_id = o.tema_id AND (i.fixa OR i.teste_num = o.teste_num)
     WHERE o.tema_id = v_tema AND o.pessoa_id = v_p
    ON CONFLICT (onda_id, item_id) DO NOTHING;

    -- os 6 testes
    FOR n IN 1..6 LOOP
      CONTINUE WHEN n = 6 AND (p->>'pula_d90')::boolean;
      ts := CASE n
        WHEN 1 THEN (v_dia - 14 + floor(random() * 4)::int)::timestamp AT TIME ZONE 'America/Sao_Paulo' + interval '21 hours' + random() * interval '2 hours'
        WHEN 2 THEN CASE WHEN (p->>'pre2_atraso')::boolean THEN v_d0 + interval '2 days' + random() * interval '3 hours'
                         ELSE v_d0 - interval '2 days' - random() * interval '4 days' END
        WHEN 3 THEN v_d0 + interval '1 hour' + random() * interval '40 minutes'
                    + CASE WHEN (p->>'pre2_atraso')::boolean THEN interval '3 days' ELSE interval '0' END
        WHEN 4 THEN (v_dia + 15 + floor(random() * 4)::int)::timestamp AT TIME ZONE 'America/Sao_Paulo' + interval '20 hours' + random() * interval '3 hours'
        WHEN 5 THEN (v_dia + 45 + floor(random() * 6)::int)::timestamp AT TIME ZONE 'America/Sao_Paulo' + interval '20 hours' + random() * interval '3 hours'
        ELSE (v_dia + 90 + floor(random() * 3)::int)::timestamp AT TIME ZONE 'America/Sao_Paulo' + interval '20 hours' + random() * interval '2 hours' END;
      SELECT onda_id INTO v_onda FROM app.onda_instancia WHERE tema_id = v_tema AND teste_num = n AND pessoa_id = v_p;
      th := (p->>'theta')::numeric + ganhos[n] * (p->>'ganho')::numeric - perdas[n] * (p->>'esquece')::numeric
            -- quem atrasou o pre-teste 2 ja viu a aula
            + CASE WHEN n = 2 AND (p->>'pre2_atraso')::boolean THEN 0.6 ELSE 0 END;
      INSERT INTO app.tentativa (onda_id, pessoa_id, iniciada_em) VALUES (v_onda, v_p, ts) RETURNING tentativa_id INTO v_t;
      tdi := ts; ordem := 0;
      -- quantas acerta segue o esperado pelo nivel (com pouca variacao); quais acerta, as mais faceis com mais chance
      TRUNCATE sim_it;
      INSERT INTO sim_it (item_id, ordem, chance, chave)
      SELECT i.item_id, s.ordem_apresentada, 1 / (1 + exp(-(th - (coalesce(i.dificuldade, 3) - 3.5) * 0.6))), random()
        FROM app.item_selecionado s JOIN app.item i ON i.item_id = s.item_id
       WHERE s.onda_id = v_onda AND (i.fixa OR i.perfil = app.perfil_questoes((p->>'grau')::app.grau_enum));
      k := greatest(0, round((SELECT sum(x.chance) FROM sim_it x) + (random() - 0.5) * 1.2)::int);
      UPDATE sim_it x SET acerta = r.pos <= k
        FROM (SELECT sim_it.item_id, row_number() OVER (ORDER BY sim_it.chance + sim_it.chave * 0.6 DESC) pos FROM sim_it) r WHERE r.item_id = x.item_id;
      FOR it IN SELECT x.item_id, x.ordem AS ordem_apresentada, x.chance AS prob, x.acerta AS certo FROM sim_it x ORDER BY x.ordem LOOP
        pr := it.prob; acerta := it.certo;
        IF acerta THEN alt := (SELECT a.alternativa_id FROM app.alternativa a WHERE a.item_id = it.item_id AND a.eh_correta LIMIT 1);
        ELSE alt := (SELECT a.alternativa_id FROM app.alternativa a WHERE a.item_id = it.item_id AND NOT a.eh_correta ORDER BY random() LIMIT 1); END IF;
        CONTINUE WHEN alt IS NULL;
        -- a certeza acompanha o quanto a pessoa sabe (e o acerto), deslocada pelo vies de cada perfil
        sc := 0.5 * pr + CASE WHEN acerta THEN 0.22 ELSE 0.08 END + (p->>'vies')::numeric + (random() - 0.5) * 0.6;
        cer := CASE WHEN sc > 0.75 THEN 3 WHEN sc > 0.45 THEN 2 ELSE 1 END;
        ms := CASE WHEN random() < (p->>'rapido')::numeric THEN 1200 + floor(random() * 1800)::int
                   ELSE least(300000, greatest(6000, floor(exp(ln(38000) + 0.55 * sqrt(-2 * ln(greatest(random(), 1e-9))) * cos(2 * pi() * random())))::int)) END;
        tdi := tdi + make_interval(secs => ms / 1000.0);
        ordem := ordem + 1;
        INSERT INTO app.resposta (tentativa_id, item_id, alternativa_id, tempo_resposta_ms, ordem_apresentada, respondida_em, certeza)
        VALUES (v_t, it.item_id, alt, ms, it.ordem_apresentada, tdi, cer);
      END LOOP;
      UPDATE app.tentativa SET submetida_em = tdi + interval '20 seconds' WHERE tentativa_id = v_t;
      -- avaliacao do teste
      IF random() < 0.8 THEN
        INSERT INTO app.avaliacao (pessoa_id, tema_id, ferramenta, nps, criado_em, atualizado_em)
        VALUES (v_p, v_tema, 'teste_' || n, least(10, greatest(0, (p->>'nps')::int + floor(random() * 3)::int - 1)), tdi + interval '1 minute', tdi + interval '1 minute');
      END IF;
    END LOOP;

    -- leitura e uso do material (quem le menos abre menos pecas e fica menos tempo)
    FOREACH cmp IN ARRAY pecas LOOP
      CONTINUE WHEN random() > (p->>'leitura')::numeric + 0.1;
      ts := CASE WHEN app.etapa_do_material(cmp) = 2 THEN v_d0 - interval '3 days' WHEN app.etapa_do_material(cmp) = 3 THEN v_d0 + interval '30 minutes'
                 ELSE v_d0 + interval '1 day' END + random() * interval '2 days';
      ms := greatest(20, floor((60 + random() * 540) * ((p->>'leitura')::numeric + 0.2))::int);
      INSERT INTO app.leitura_tempo (pessoa_id, tema_id, tipo, segundos, em) VALUES (v_p, v_tema, cmp, least(3600, ms), ts);
      INSERT INTO app.uso_material (pessoa_id, tema_id, tipo, segundos, em) VALUES (v_p, v_tema, cmp, least(3600, ms), ts);
      IF random() < 0.5 THEN
        INSERT INTO app.avaliacao (pessoa_id, tema_id, ferramenta, nps, utilidade, criado_em, atualizado_em)
        VALUES (v_p, v_tema, cmp, least(10, greatest(0, (p->>'nps')::int + floor(random() * 3)::int - 1)), 1 + floor(random() * 3)::int, ts, ts);
      END IF;
    END LOOP;

    -- caso base: respostas antes da aula (travadas no D0) e, para alguns, "depois da aula"
    pontos := '{}'; ant := '{}';
    FOR k IN 1..7 LOOP
      boa := random() < 1 / (1 + exp(-((p->>'theta')::numeric + 0.3)));
      pontos := pontos || jsonb_build_object(k::text, respostas_cb -> (k - 1) ->> (CASE WHEN boa THEN 0 ELSE 1 END));
      IF (p->>'leitura')::numeric > 0.5 AND NOT boa THEN ant := ant || jsonb_build_object(k::text, 'Depois da aula: ' || (respostas_cb -> (k - 1) ->> 0)); END IF;
    END LOOP;
    INSERT INTO app.estado_material (pessoa_id, tema_id, peca, estado, cliente_em, atualizado_em)
    VALUES (v_p, v_tema, 'caso_base', jsonb_build_object('respostas', pontos, 'depois', ant, 'travado_em', v_d0), v_d0 + interval '2 days', v_d0 + interval '2 days');

    -- caso da aula (Carla refaz: a primeira tentativa fica em "anteriores")
    ant := '[]';
    FOR cer IN 1..(CASE WHEN p->>'k' = 'carla' THEN 2 ELSE 1 END) LOOP
      pontos := '{}';
      FOR k IN 0..5 LOOP
        pr := 1 / (1 + exp(-((p->>'theta')::numeric + 0.4 + (cer - 1) * 1.2)));
        boa := random() < pr;
        sc := pr + (p->>'vies')::numeric + (random() - 0.5) * 0.5;
        cmp := CASE WHEN boa THEN (CASE WHEN random() < 0.75 THEN 'parecida' ELSE 'em_parte' END) ELSE (CASE WHEN random() < 0.7 THEN 'diferente' ELSE 'em_parte' END) END;
        pontos := pontos || jsonb_build_object(k::text, jsonb_build_object('conduta', condutas -> k ->> (CASE WHEN boa THEN 0 ELSE 1 END),
                    'certeza', CASE WHEN sc > 0.78 THEN 3 WHEN sc > 0.45 THEN 2 ELSE 1 END, 'revelado', true, 'comparacao', cmp));
      END LOOP;
      IF cer = 1 AND p->>'k' = 'carla' THEN ant := jsonb_build_array(jsonb_build_object('pontos', pontos, 'concluida_em', v_d0 + interval '1 day'));
      END IF;
    END LOOP;
    INSERT INTO app.estado_material (pessoa_id, tema_id, peca, estado, cliente_em, atualizado_em)
    VALUES (v_p, v_tema, 'caso', jsonb_build_object('pontos', pontos, 'fim', true, 'atual', 5, 'anteriores', ant), v_d0 + interval '3 days', v_d0 + interval '3 days');

    -- checklist e onde parou
    pontos := '{}';
    FOR k IN 1..15 LOOP IF random() < (p->>'leitura')::numeric THEN pontos := pontos || jsonb_build_object(k::text, true); END IF; END LOOP;
    INSERT INTO app.estado_material (pessoa_id, tema_id, peca, estado, cliente_em, atualizado_em)
    VALUES (v_p, v_tema, 'checklist', jsonb_build_object('marcados', pontos), v_d0 + interval '4 days', v_d0 + interval '4 days');
    INSERT INTO app.estado_material (pessoa_id, tema_id, peca, estado, cliente_em, atualizado_em)
    VALUES (v_p, v_tema, '_tema', jsonb_build_object('peca', 'resumo', 'rolagem', jsonb_build_object('resumo', round(random()::numeric, 2))), v_d0 + interval '20 days', v_d0 + interval '20 days');

    -- presenca (Bruno: so pelo relatorio do Meet, metade da aula)
    INSERT INTO app.presenca (pessoa_id, tema_id, aula_em, por_codigo, codigo_em, minutos_meet, manual, atualizado_em)
    VALUES (v_p, v_tema, v_d0, p->>'k' <> 'bruno', CASE WHEN p->>'k' <> 'bruno' THEN v_d0 + interval '50 minutes' END,
            CASE WHEN p->>'k' = 'bruno' THEN 32 ELSE 55 + floor(random() * 5) END, false, v_d0 + interval '1 day');

    -- avaliacao do tema e aplicabilidade (D+15)
    INSERT INTO app.avaliacao (pessoa_id, tema_id, ferramenta, nps, conteudo, adequacao, dificuldade, utilidade, minutos_gastos, comentario, criado_em, atualizado_em)
    VALUES (v_p, v_tema, 'tema', (p->>'nps')::int, least(5, 3 + floor(random() * 3)::int), 3 + floor(random() * 3)::int,
            CASE (p->>'grau') WHEN 'R1' THEN 4 WHEN 'R2' THEN 3 ELSE 2 END, 2 + floor(random() * 2)::int,
            floor(60 + 180 * (p->>'leitura')::numeric)::int,
            CASE p->>'k' WHEN 'bruno' THEN 'Muito material para a semana de plantão.' WHEN 'elisa' THEN 'Gostei da parte de evidência; o caso poderia ser mais difícil para R+.' END,
            v_d0 + interval '5 days', v_d0 + interval '5 days');
    INSERT INTO app.aplicabilidade (pessoa_id, tema_id, usou, mudou_conduta, confianca, exemplo, em)
    VALUES (v_p, v_tema, 1 + floor(random() * 3)::int, random() < 0.6, 2 + floor(random() * 3)::int,
            CASE WHEN random() < 0.6 THEN 'Passei a medir a temperatura na admissão e a aquecer antes da TC.' END, v_d0 + interval '16 days');
  END LOOP;

  -- duvidas e feedback (sem aviso por e-mail)
  INSERT INTO app.mensagem_aluno (pessoa_id, tema_id, ferramenta, tipo, texto, status, criado_em)
  SELECT pessoa_id, v_tema, 'caso', 'duvida', 'No ponto 1, se o torniquete já está há mais de 2 horas, ainda devo manter? (dúvida simulada)', 'nova', '2026-08-15 21:10-03'
    FROM app.pessoa WHERE email_primario::text = 'carla@simulado.local';
  INSERT INTO app.mensagem_aluno (pessoa_id, tema_id, ferramenta, tipo, texto, status, criado_em)
  SELECT pessoa_id, v_tema, 'slides', 'feedback', 'O áudio dos slides em 1,5x ficou ótimo para ouvir no caminho. (feedback simulado)', 'registrada', '2026-08-20 07:40-03'
    FROM app.pessoa WHERE email_primario::text = 'ana@simulado.local';
  RAISE NOTICE 'simulacao criada: 5 residentes ficticios no T001';
END $$;

ALTER TABLE app.mensagem_aluno ENABLE TRIGGER tg_duvida_avisar;
ALTER TABLE app.mensagem_aluno ENABLE TRIGGER tg_feedback_registrado;
COMMIT;
\echo 'simulacao: pronta (dados ficticios; apagar com 91_apagar_simulacao_v1.0.sql)'
