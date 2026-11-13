-- 47_camadas_evidencia_v1.0.sql
-- Corrige a definicao das cinco camadas de evidencia nos prompts ja gravados no banco,
-- conforme decidido em 12/11/2026: 1 historico | 2 livro-texto | 3 protocolo institucional |
-- 4 revisao dos ultimos 10 anos | 5 diretriz. Pode ser rodado mais de uma vez.
\set ON_ERROR_STOP on
BEGIN;
UPDATE conteudo.prompt
   SET conteudo = replace(conteudo,
     'Localize fontes nas cinco camadas: (1) diretriz internacional, (2) diretriz nacional, (3) revisao sistematica, (4) ensaio clinico, (5) consenso de sociedade.',
     'Localize fontes nas cinco camadas: (1) historico (textos classicos e edicoes antigas, como ATLS de edicoes anteriores), (2) livro-texto (Mattox/Trauma, Sabiston, Birolini, ATLS vigente), (3) protocolo institucional (HCFMRP/UE), (4) revisao da literatura dos ultimos 10 anos (revisoes sistematicas, ensaios, coortes), (5) diretriz (de sociedades nacionais e internacionais).')
 WHERE slug = 'fase_evidencia';
COMMENT ON COLUMN conteudo.fonte.camada IS
  '1 historico | 2 livro-texto | 3 protocolo institucional | 4 revisao dos ultimos 10 anos | 5 diretriz';
SELECT slug, position('(1) historico' in conteudo) > 0 AS camadas_corrigidas FROM conteudo.prompt WHERE slug = 'fase_evidencia';
COMMIT;
