-- 59_aviso_revisao_v1.0.sql
-- Atualiza o aviso no topo dos rascunhos para a regra nova: basta a aprovacao de 1 revisor.
-- Troca so o texto do aviso, na mesma versao: os pareceres ja dados continuam valendo.
-- Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;
UPDATE conteudo.artefato
   SET corpo = replace(corpo, 'RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico).',
                       'RASCUNHO para revisão: basta a aprovação de 1 cirurgião do trauma (tolerância: 5% de erro leve, zero crítico).')
 WHERE status = 'rascunho' AND corpo LIKE '%revisão por 3 cirurgiões do trauma%';
SELECT count(*) AS rascunhos_com_aviso_antigo FROM conteudo.artefato
 WHERE status = 'rascunho' AND corpo LIKE '%revisão por 3 cirurgiões%';
COMMIT;
\echo 'aviso dos rascunhos atualizado'
