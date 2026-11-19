-- 82_interativo_v1.0.sql
-- Estado do material por aluno (decisao da coordenacao em 15/11/2026):
--  - caso da aula interativo: em cada ponto de decisao o aluno escreve a conduta e marca a certeza ANTES de ver a
--    discussao; depois compara e marca se a conduta dele foi parecida, em parte ou diferente. A resposta de um ponto
--    fica travada depois que a discussao daquele ponto foi aberta. Concluido o caso, ele pode refazer: a tentativa
--    concluida fica guardada em "anteriores" e nao muda mais;
--  - caso base: as respostas as perguntas do fim sao salvas e so podem mudar ate a hora da aula; depois da aula ficam
--    so para leitura, e o aluno pode escrever ao lado "o que eu responderia agora";
--  - checklist: itens marcados;
--  - onde parou: peca aberta, posicao do texto, slide, tempo do audio (podcast e slides) e velocidade.
-- Um registro por pessoa, tema e peca (peca '_tema' guarda a ultima peca aberta do tema). O aplicativo guarda tambem
-- no aparelho e manda de novo quando a internet volta; vale o registro mais recente pela hora do aparelho.
-- Pre-requisito: 60, 81. Pode ser rodado mais de uma vez.
-- DESFAZER: DROP FUNCTION app.salvar_estado, app.estado_tema, app.continuar_estudo; DROP TABLE app.estado_material;
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE IF NOT EXISTS app.estado_material (
  pessoa_id     BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  tema_id       BIGINT NOT NULL REFERENCES app.tema(tema_id) ON DELETE CASCADE,
  peca          TEXT   NOT NULL CHECK (peca ~ '^[a-z_]{2,30}$'),
  estado        JSONB  NOT NULL DEFAULT '{}'::jsonb CHECK (octet_length(estado::text) <= 200000),
  cliente_em    TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (pessoa_id, tema_id, peca));
REVOKE ALL ON app.estado_material FROM PUBLIC;
COMMENT ON TABLE app.estado_material IS 'respostas do caso da aula e do caso base, checklist marcado e posicao de estudo (onde parou), por aluno';

CREATE OR REPLACE FUNCTION app.salvar_estado(p_codigo TEXT, p_peca TEXT, p_estado JSONB, p_cliente_em TIMESTAMPTZ)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_p BIGINT := app.pessoa_atual(); v_t BIGINT; v_etapa INT; v_old app.estado_material%ROWTYPE; v_novo JSONB := coalesce(p_estado, '{}'::jsonb);
        k TEXT; v_ant JSONB; v_quando TIMESTAMPTZ := least(coalesce(p_cliente_em, now()), now());
BEGIN
  IF v_p IS NULL THEN RAISE EXCEPTION 'sem_sessao' USING ERRCODE = '42501'; END IF;
  SELECT tema_id INTO v_t FROM app.tema WHERE upper(replace(codigo, '-', '')) = upper(replace(p_codigo, '-', ''));
  IF v_t IS NULL THEN RAISE EXCEPTION 'tema_nao_encontrado'; END IF;
  v_etapa := app.etapa_liberada(v_p, v_t);
  IF p_peca <> '_tema' AND coalesce(app.etapa_do_material(p_peca), 99) > v_etapa THEN
    RAISE EXCEPTION 'nao_liberado' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO v_old FROM app.estado_material WHERE pessoa_id = v_p AND tema_id = v_t AND peca = p_peca;
  -- Registro mais novo ja gravado (outro aparelho, ou envio atrasado de quando estava sem internet): fica o mais novo.
  IF v_old.pessoa_id IS NOT NULL AND v_old.cliente_em > v_quando THEN RETURN v_old.estado; END IF;

  IF p_peca = 'caso_base' THEN
    IF v_etapa >= 3 THEN
      -- depois da aula: as respostas de antes ficam como estavam; so "depois" (o que responderia agora) pode mudar
      v_novo := jsonb_set(v_novo, '{respostas}', coalesce(v_old.estado -> 'respostas', '{}'::jsonb));
      IF v_old.estado ? 'travado_em' THEN v_novo := jsonb_set(v_novo, '{travado_em}', v_old.estado -> 'travado_em');
      ELSE v_novo := jsonb_set(v_novo, '{travado_em}', to_jsonb(now())); END IF;
    ELSE
      v_novo := v_novo - 'depois';
    END IF;
  ELSIF p_peca = 'caso' THEN
    -- tentativas anteriores nunca mudam; "refazer" (so com a tentativa atual concluida) arquiva a atual
    v_ant := coalesce(v_old.estado -> 'anteriores', '[]'::jsonb);
    IF (v_novo ->> 'refazer') = 'true' AND (v_old.estado ->> 'fim') = 'true' THEN
      v_ant := v_ant || jsonb_build_array(jsonb_build_object('pontos', coalesce(v_old.estado -> 'pontos', '{}'::jsonb),
                                                             'concluida_em', v_old.cliente_em));
      v_novo := (v_novo - 'refazer') || jsonb_build_object('anteriores', v_ant);
    ELSE
      v_novo := (v_novo - 'refazer') || jsonb_build_object('anteriores', v_ant);
      -- ponto com discussao ja aberta na tentativa atual: conduta e certeza nao mudam mais (so a comparacao e a explicacao)
      IF jsonb_typeof(v_old.estado -> 'pontos') = 'object' THEN
        IF jsonb_typeof(v_novo -> 'pontos') IS DISTINCT FROM 'object' THEN v_novo := jsonb_set(v_novo, '{pontos}', '{}'::jsonb); END IF;
        FOR k IN SELECT jsonb_object_keys(v_old.estado -> 'pontos') LOOP
          IF (v_old.estado -> 'pontos' -> k ->> 'revelado') = 'true' THEN
            v_novo := jsonb_set(v_novo, ARRAY['pontos', k],
                      (v_old.estado -> 'pontos' -> k) || jsonb_strip_nulls(jsonb_build_object('comparacao', v_novo -> 'pontos' -> k -> 'comparacao',
                                                                         'explicacao', v_novo -> 'pontos' -> k -> 'explicacao')));
          END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;

  INSERT INTO app.estado_material (pessoa_id, tema_id, peca, estado, cliente_em, atualizado_em)
  VALUES (v_p, v_t, p_peca, v_novo, v_quando, now())
  ON CONFLICT (pessoa_id, tema_id, peca) DO UPDATE SET estado = EXCLUDED.estado, cliente_em = EXCLUDED.cliente_em, atualizado_em = now();
  RETURN v_novo;
END $$;

-- Tudo o que a pessoa logada guardou num tema: {peca: {estado, em}}
CREATE OR REPLACE FUNCTION app.estado_tema(p_codigo TEXT) RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_object_agg(e.peca, jsonb_build_object('estado', e.estado, 'em', e.cliente_em)), '{}'::jsonb)
    FROM app.estado_material e JOIN app.tema t ON t.tema_id = e.tema_id
   WHERE e.pessoa_id = app.pessoa_atual() AND upper(replace(t.codigo, '-', '')) = upper(replace(p_codigo, '-', '')) $$;

-- "Continuar de onde parou": a ultima peca aberta pela pessoa logada (registro '_tema' mais recente, com a peca
-- e a posicao do texto) e o estado dessa peca (slide, tempo do audio, ponto do caso). So peca ainda liberada.
CREATE OR REPLACE FUNCTION app.continuar_estudo()
RETURNS TABLE (codigo TEXT, titulo TEXT, peca TEXT, nome TEXT, estado JSONB, em TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT t.codigo, t.titulo, e.estado ->> 'peca', app.nome_material(e.estado ->> 'peca'),
         coalesce(p.estado, '{}'::jsonb), e.cliente_em
    FROM app.estado_material e
    JOIN app.tema t ON t.tema_id = e.tema_id
    LEFT JOIN app.estado_material p ON p.pessoa_id = e.pessoa_id AND p.tema_id = e.tema_id AND p.peca = e.estado ->> 'peca'
   WHERE e.pessoa_id = app.pessoa_atual() AND e.peca = '_tema' AND e.estado ? 'peca'
     AND app.etapa_do_material(e.estado ->> 'peca') <= app.etapa_liberada(e.pessoa_id, e.tema_id)
   ORDER BY e.cliente_em DESC LIMIT 1 $$;

REVOKE EXECUTE ON FUNCTION app.salvar_estado(TEXT, TEXT, JSONB, TIMESTAMPTZ), app.estado_tema(TEXT), app.continuar_estudo() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.salvar_estado(TEXT, TEXT, JSONB, TIMESTAMPTZ), app.estado_tema(TEXT), app.continuar_estudo() TO api_rw;

COMMIT;
\echo 'estado do material por aluno: pronto'
