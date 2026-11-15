
-- ============================================================
-- 16_setup_prompts_fase_v4.4.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.4 / 10-11-2026
--
-- OBJETIVO: registrar os 6 prompts de fase e os 20 prompts de
-- tema. Os prompts de fase sao usados pelo executor para
-- orientar a geracao. Os prompts de tema sao especificos por
-- tipo de artefato.
--
-- PRE-REQUISITO: 01_instalar_v4.4.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 16_setup_prompts_fase_v4.4.sql
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== SETUP PROMPTS DE FASE v4.4 ==='

BEGIN;

-- 6 PROMPTS DE FASE
INSERT INTO conteudo.prompt (slug, familia, skill_codigo, conteudo, max_tokens, temperatura) VALUES
('fase_evidencia', 'fase', 'SK-01',
 'Voce e um pesquisador senior em cirurgia de urgencia e trauma. Localize fontes nas cinco camadas: (1) historico (textos classicos e edicoes antigas, como ATLS de edicoes anteriores), (2) livro-texto (Mattox/Trauma, Sabiston, Birolini, ATLS vigente), (3) protocolo institucional (HCFMRP/UE), (4) revisao da literatura dos ultimos 10 anos (revisoes sistematicas, ensaios, coortes), (5) diretriz (de sociedades nacionais e internacionais). Para cada fonte, registre titulo, autores, ano, DOI ou PMID e um trecho literal que sustente a afirmacao. Nao invente referencia. Se nao encontrar fonte em uma camada, declare a ausencia.',
 4000, 0.2),

('fase_objetivos', 'fase', 'SK-04',
 'A partir da sintese de evidencia, formule de 5 a 9 objetivos de aprendizagem. Cada objetivo deve ter verbo observavel (reconhecer, indicar, executar, interpretar, decidir), condicao de execucao e criterio de desempenho. Classifique cada objetivo em um dos quatro tipos: conhecimento, habilidade, atitude, raciocinio clinico.',
 2000, 0.3),

('fase_instrumento', 'fase', 'SK-05',
 'Construa itens de multipla escolha com 5 alternativas. Cada item deve ter enunciado com caso clinico, uma unica alternativa correta e quatro distratores, cada um em uma categoria distinta: erro conceitual, erro de calculo, erro de conduta, erro de indicacao, erro tecnico. Declare a ancora (fonte que sustenta o gabarito).',
 3000, 0.3),

('fase_didatico', 'fase', 'SK-08',
 'Produza o artefato didatico com cinco secoes obrigatorias: (1) por que importa, (2) o que a evidencia diz, (3) como se faz, (4) o que da errado, (5) o que levar para o plantao. Use linguagem direta, sem jargao nao explicado. Cite a fonte em cada afirmacao factual.',
 4000, 0.4),

('fase_protocolo', 'fase', 'SK-13',
 'Redija o protocolo assistencial com quinze secoes: titulo, objetivo, populacao-alvo, definicoes, criterios de inclusao, criterios de exclusao, avaliacao inicial, conduta passo a passo, materiais necessarios, complicacoes esperadas, manejo das complicacoes, criterios de transferencia, criterios de alta, indicadores de qualidade, referencias.',
 5000, 0.3),

('fase_qa', 'fase', 'SK-14',
 'Audite o conjunto de artefatos do tema. Verifique: (1) todo objetivo declarado e avaliado por ao menos um item; (2) todo item tem gabarito com ancora; (3) nao ha contradicao entre artefatos; (4) todo numero citado e identico entre artefatos; (5) todo termo tecnico e usado de forma consistente. Reporte cada inconsistencia com localizacao exata.',
 3000, 0.2)
ON CONFLICT (slug) DO UPDATE
   SET familia = EXCLUDED.familia,
       skill_codigo = EXCLUDED.skill_codigo,
       conteudo = EXCLUDED.conteudo,
       max_tokens = EXCLUDED.max_tokens,
       temperatura = EXCLUDED.temperatura;

-- 20 PROMPTS DE TEMA
INSERT INTO conteudo.prompt (slug, familia, skill_codigo, conteudo, max_tokens, temperatura) VALUES
('P-01', 'tema', 'SK-01', 'Busque evidencia sobre o tema com foco em diretriz internacional.', 3000, 0.2),
('P-02', 'tema', 'SK-02', 'Sintetize a evidencia em tres secoes: consenso, disputa, lacuna.', 3000, 0.3),
('P-03', 'tema', 'SK-03', 'Verifique a cobertura das cinco camadas de fonte.', 1500, 0.1),
('P-04', 'tema', 'SK-04', 'Formule objetivos de aprendizagem observaveis.', 2000, 0.3),
('P-05', 'tema', 'SK-05', 'Construa itens de multipla escolha com cinco alternativas.', 3000, 0.3),
('P-06', 'tema', 'SK-06', 'Elabore o gabarito comentado com justificativa por alternativa.', 2500, 0.3),
('P-07', 'tema', 'SK-07', 'Distribua a dificuldade dos itens e declare a ancora.', 1500, 0.2),
('P-08', 'tema', 'SK-08', 'Produza o artefato didatico com cinco secoes.', 4000, 0.4),
('P-09', 'tema', 'SK-09', 'Identifique a controversia real e produza a aula com quatro marcadores.', 3500, 0.4),
('P-10', 'tema', 'SK-10', 'Construa o caso clinico com desfecho e prazo.', 3000, 0.4),
('P-11', 'tema', 'SK-11', 'Construa o caso clinico com complicacao e conduta.', 3000, 0.4),
('P-12', 'tema', 'SK-12', 'Produza o resumo executivo com cinco secoes.', 2000, 0.3),
('P-13', 'tema', 'SK-13', 'Redija o protocolo assistencial com quinze secoes.', 5000, 0.3),
('P-14', 'tema', 'SK-14', 'Audite o conjunto de artefatos do tema.', 3000, 0.2),
('P-15', 'tema', 'SK-15', 'Normalize a terminologia entre artefatos.', 2000, 0.2),
('P-16', 'tema', 'SK-16', 'Verifique o registro factual identico entre artefatos.', 2000, 0.2),
('P-17', 'tema', 'SK-17', 'Produza o mapa conceitual do tema.', 2500, 0.3),
('P-18', 'tema', 'SK-18', 'Produza os flashcards do tema.', 2000, 0.3),
('P-19', 'tema', 'SK-19', 'Produza o simulado do tema.', 3000, 0.3),
('P-20', 'tema', 'SK-14', 'Consolide o relatorio final de qualidade do tema.', 2500, 0.2)
ON CONFLICT (slug) DO UPDATE
   SET familia = EXCLUDED.familia,
       skill_codigo = EXCLUDED.skill_codigo,
       conteudo = EXCLUDED.conteudo,
       max_tokens = EXCLUDED.max_tokens,
       temperatura = EXCLUDED.temperatura;

-- CONFERENCIA
\echo '--- Conferencia ---'

SELECT 'prompts de fase: ' || count(*) FROM conteudo.prompt WHERE slug LIKE 'fase_%';
SELECT 'prompts de tema: ' || count(*) FROM conteudo.prompt WHERE slug LIKE 'P-%';
SELECT 'total de prompts: ' || count(*) FROM conteudo.prompt;

\echo '=== SETUP PROMPTS DE FASE CONCLUIDO ==='

COMMIT;
