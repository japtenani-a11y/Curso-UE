-- exportar_base_v1.0.sql
-- Exporta a base de analise (uma linha por resposta, com as marcas de qualidade) para analise/base_respostas.csv.
-- Mesma base da aba "Base de análise" do painel. Roda como coordenacao (ve o nome); para a analise da pesquisa,
-- prefira o CSV baixado pelo pesquisador no painel (codigo do participante e so quem consentiu).
-- USO (no WSL, em ~/Curso-UE):  psql -h localhost -U postgres -d programa -f analise/exportar_base_v1.0.sql
SELECT set_config('app.role', 'pesquisador', false),
       set_config('app.pessoa_id', (SELECT d.pessoa_id::text FROM app.designacao d WHERE d.papel IN ('pesquisador', 'admin') ORDER BY d.papel = 'pesquisador' DESC LIMIT 1), false);
\copy (SELECT * FROM app.pesquisa_respostas()) TO 'analise/base_respostas.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\echo 'base exportada para analise/base_respostas.csv'
