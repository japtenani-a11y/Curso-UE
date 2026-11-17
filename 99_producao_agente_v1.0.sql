-- ============================================================
-- 99_producao_agente_v1.0.sql
-- OBJETIVO: deixar a ponte gravar no banco, em RASCUNHO, o material que o agente produtor deixa em
--   CUT_coordenacao\producao\<TEMA>\ (importador em modo parcial). A ponte usa o papel maestro_rw, que ja escreve
--   pecas, afirmacoes e fontes (SQL 22 e 27) e nao publica nada. Aqui ele ganha so o que falta: marcar como
--   "substituida" a pre-revisao de uma peca que acabou de ganhar versao nova.
-- O que o papel continua sem poder: publicar (a publicacao exige o checklist e a decisao na tela de revisao),
--   mexer em questoes que alunos responderam, ler dados de alunos.
-- Pode ser rodado mais de uma vez. Para desfazer: REVOKE UPDATE (status, decidido_em, motivo) ON app.proposta_agente FROM maestro_rw;
-- ============================================================
\set ON_ERROR_STOP on
GRANT SELECT ON app.proposta_agente TO maestro_rw;
GRANT UPDATE (status, decidido_em, motivo) ON app.proposta_agente TO maestro_rw;
GRANT EXECUTE ON FUNCTION conteudo.conferir_formato(text, text), conteudo.erros_formato(text, text) TO maestro_rw;
