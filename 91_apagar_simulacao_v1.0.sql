-- 91_apagar_simulacao_v1.0.sql
-- Apaga TODOS os dados simulados (pessoas com e-mail @simulado.local) e tudo o que esta ligado a elas:
-- ondas proprias, tentativas, respostas, notas, estado do material, leitura, avaliacoes, presenca, mensagens, termos.
-- Rodar antes de abrir o curso aos residentes. Nao toca em nenhum outro dado.
-- As respostas sao imutaveis no uso normal; aqui o bloqueio e desligado so durante a limpeza, dentro da transacao.
\set ON_ERROR_STOP on
BEGIN;
CREATE TEMP TABLE sim_p ON COMMIT DROP AS
  SELECT pessoa_id FROM app.pessoa WHERE email_primario::text LIKE '%@simulado.local';
\echo 'pessoas simuladas encontradas:'
SELECT count(*) FROM sim_p;
ALTER TABLE app.resposta DISABLE TRIGGER tg_resposta_imutavel;
DELETE FROM app.resposta WHERE tentativa_id IN (SELECT tentativa_id FROM app.tentativa WHERE pessoa_id IN (SELECT pessoa_id FROM sim_p));
DELETE FROM app.item_selecionado WHERE onda_id IN (SELECT onda_id FROM app.onda_instancia WHERE pessoa_id IN (SELECT pessoa_id FROM sim_p));
DELETE FROM app.pessoa WHERE pessoa_id IN (SELECT pessoa_id FROM sim_p);
ALTER TABLE app.resposta ENABLE TRIGGER tg_resposta_imutavel;
COMMIT;
\echo 'simulacao apagada'
