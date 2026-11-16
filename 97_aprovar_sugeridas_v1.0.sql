-- ============================================================
-- 97_aprovar_sugeridas_v1.0.sql
-- OBJETIVO: botão "Aprovar tudo o que os agentes sugerem liberar" na tela Revisão > Para revisar.
-- Aprova de uma vez, como vieram, todas as propostas em que o agente sugere liberar algo:
--   - respostas a dúvidas, lembretes aos alunos e lançamentos de indicadores (decisão da coordenação, 16/11/2026);
--   - parecer do revisor de conteúdo com sugestão "aprovar" (o parecer entra como "correto");
--   - pré-revisão das peças com veredito "pronta";
--   - fontes que o triador não sugere recusar.
-- Ficam para a coordenação, uma a uma: pareceres "conferir melhor" e "reprovar", peças "ajustar" e "refazer",
-- fontes com sugestão de recusa, e os avisos que não liberam nada, só pedem leitura (alertas, pendências e
-- relatórios), para que um alerta sobre um aluno não seja dado como lido sem ninguém ler.
-- Cada aprovação passa pela mesma função do botão "Aprovar" (app.decidir_proposta): mesma regra de quem pode
-- decidir e o mesmo registro. Pode ser rodado mais de uma vez.
-- ============================================================
\set ON_ERROR_STOP on
BEGIN;

-- quais propostas entram no lote (a mesma regra serve para contar na tela e para aprovar)
CREATE OR REPLACE FUNCTION app.proposta_sugere_liberar(p app.proposta_agente)
RETURNS BOOLEAN LANGUAGE sql IMMUTABLE AS $$
  SELECT p.status = 'aguardando' AND (
       p.tipo IN ('resposta', 'lembrete', 'lancamento')
    OR (p.tipo = 'parecer' AND p.proposta ->> 'sugestao' = 'aprovar'
                           AND coalesce(nullif(p.proposta ->> 'decisao', ''), 'correto') = 'correto')
    OR (p.tipo = 'pre_revisao' AND p.proposta ->> 'veredito' = 'pronta')
    OR (p.tipo = 'fonte' AND lower(coalesce(p.proposta ->> 'recusar', 'false')) NOT IN ('true', 'sim', '1')));
$$;

CREATE OR REPLACE FUNCTION app.aprovar_sugeridas(p_agente TEXT DEFAULT NULL)
RETURNS TABLE (aprovadas INT, com_erro INT, ficaram INT)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app, conteudo AS $$
DECLARE r RECORD; v_ok INT := 0; v_erro INT := 0;
BEGIN
  IF app.role_atual() NOT IN ('admin', 'curador', 'data_steward') THEN RAISE EXCEPTION 'so_coordenacao' USING ERRCODE = '42501'; END IF;
  FOR r IN SELECT pa.proposta_id FROM app.proposta_agente pa
            WHERE app.proposta_sugere_liberar(pa) AND (p_agente IS NULL OR pa.agente = p_agente)
            ORDER BY pa.criado_em, pa.proposta_id
  LOOP
    BEGIN
      PERFORM app.decidir_proposta(r.proposta_id, 'aprovar', NULL, NULL);
      UPDATE app.proposta_agente SET motivo = 'aprovada em lote: o agente sugeriu aprovar' WHERE proposta_id = r.proposta_id;
      v_ok := v_ok + 1;
    EXCEPTION WHEN OTHERS THEN
      -- uma proposta com problema (por exemplo, decidida ao mesmo tempo por outra pessoa) não trava as outras
      IF SQLERRM LIKE 'so_coordenacao%' THEN RAISE; END IF;
      v_erro := v_erro + 1;
    END;
  END LOOP;
  RETURN QUERY SELECT v_ok, v_erro,
    (SELECT count(*)::int FROM app.proposta_agente pa WHERE pa.status = 'aguardando' AND (p_agente IS NULL OR pa.agente = p_agente));
END $$;

REVOKE EXECUTE ON FUNCTION app.aprovar_sugeridas(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.aprovar_sugeridas(TEXT) TO api_rw;
GRANT EXECUTE ON FUNCTION app.proposta_sugere_liberar(app.proposta_agente) TO api_rw;

COMMIT;
SELECT 'aprovar em lote o que os agentes sugerem (97): pronto' AS situacao;
