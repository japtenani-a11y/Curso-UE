
-- ============================================================
-- 19_setup_design_tokens_v4.4.sql
-- Sistema de Producao Curricular e Coleta Cientifica
-- Programa de Cirurgia de Urgencia e Trauma
-- Versao 4.4 / 10-11-2026
--
-- OBJETIVO: registrar os 57 design tokens em 7 categorias e as
-- 12 assinaturas visuais por tipo de artefato. Serve para o
-- DS-03 gerar template e o DS-04 auditar.
--
-- PRE-REQUISITO: 01_instalar_v4.4.
--
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 19_setup_design_tokens_v4.4.sql
--
-- CORRECAO v4.6: design_token agora tem RLS. fn_contraste_wcag
-- valida formato de cor antes de calcular.
-- ============================================================

\set ON_ERROR_STOP on
\echo '=== SETUP DESIGN TOKENS v4.4 ==='

BEGIN;

-- 57 TOKENS EM 7 CATEGORIAS

-- COR (12)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('cor','primaria','#1E3A5F','Azul institucional principal'),
('cor','primaria_clara','#2E5A8F','Variante clara da primaria'),
('cor','primaria_escura','#0F1F33','Variante escura da primaria'),
('cor','acento','#C8963E','Dourado de destaque'),
('cor','sucesso','#2E7D32','Verde de confirmacao'),
('cor','alerta','#F57C00','Laranja de atencao'),
('cor','erro','#C62828','Vermelho de erro'),
('cor','info','#0277BD','Azul de informacao'),
('cor','neutro_100','#FFFFFF','Branco puro'),
('cor','neutro_200','#F5F5F5','Cinza muito claro'),
('cor','neutro_700','#424242','Cinza escuro'),
('cor','neutro_900','#121212','Quase preto')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- TIPOGRAFIA (10)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('tipografia','familia_titulo','Source Serif 4','Fonte serifada para titulos'),
('tipografia','familia_corpo','Inter','Fonte sans para corpo'),
('tipografia','familia_mono','JetBrains Mono','Fonte monoespacada para codigo'),
('tipografia','escala_12','12px','Legenda'),
('tipografia','escala_14','14px','Corpo pequeno'),
('tipografia','escala_16','16px','Corpo padrao'),
('tipografia','escala_20','20px','Subtitulo'),
('tipografia','escala_28','28px','Titulo de secao'),
('tipografia','escala_40','40px','Titulo de capitulo'),
('tipografia','escala_56','56px','Titulo de capa')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- ESPACAMENTO (8)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('espacamento','esp_4','4px','Espaco minimo'),
('espacamento','esp_8','8px','Espaco pequeno'),
('espacamento','esp_12','12px','Espaco medio-pequeno'),
('espacamento','esp_16','16px','Espaco medio'),
('espacamento','esp_24','24px','Espaco medio-grande'),
('espacamento','esp_32','32px','Espaco grande'),
('espacamento','esp_48','48px','Espaco muito grande'),
('espacamento','esp_64','64px','Espaco maximo')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- RAIO (6)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('raio','raio_none','0','Sem arredondamento'),
('raio','raio_sm','4px','Arredondamento pequeno'),
('raio','raio_md','8px','Arredondamento medio'),
('raio','raio_lg','16px','Arredondamento grande'),
('raio','raio_xl','24px','Arredondamento muito grande'),
('raio','raio_full','9999px','Arredondamento total')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- SOMBRA (5)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('sombra','sombra_none','none','Sem sombra'),
('sombra','sombra_sm','0 1px 2px rgba(0,0,0,0.05)','Sombra sutil'),
('sombra','sombra_md','0 4px 6px rgba(0,0,0,0.1)','Sombra media'),
('sombra','sombra_lg','0 10px 15px rgba(0,0,0,0.1)','Sombra grande'),
('sombra','sombra_xl','0 20px 25px rgba(0,0,0,0.15)','Sombra maxima')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- MOVIMENTO (6)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('movimento','dur_rapida','150ms','Duracao rapida'),
('movimento','dur_media','250ms','Duracao media'),
('movimento','dur_lenta','400ms','Duracao lenta'),
('movimento','ease_padrao','cubic-bezier(0.4, 0, 0.2, 1)','Curva padrao'),
('movimento','ease_entrada','cubic-bezier(0, 0, 0.2, 1)','Curva de entrada'),
('movimento','ease_saida','cubic-bezier(0.4, 0, 1, 1)','Curva de saida')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- ACESSIBILIDADE (10)
INSERT INTO conteudo.design_token (categoria, nome, valor, descricao) VALUES
('acessibilidade','contraste_minimo_texto','4.5','WCAG AA texto normal'),
('acessibilidade','contraste_minimo_texto_grande','3.0','WCAG AA texto grande'),
('acessibilidade','contraste_minimo_ui','3.0','WCAG AA componente de UI'),
('acessibilidade','foco_visivel','2px solid #C8963E','Anel de foco'),
('acessibilidade','alvo_minimo','44px','Tamanho minimo de alvo'),
('acessibilidade','espaco_linha','1.6','Altura de linha'),
('acessibilidade','espaco_paragrafo','1.5em','Espaco entre paragrafos'),
('acessibilidade','largura_maxima_texto','72ch','Largura maxima de linha'),
('acessibilidade','reducao_movimento','prefers-reduced-motion','Respeita preferencia'),
('acessibilidade','idioma','pt-BR','Idioma do documento')
ON CONFLICT (categoria, nome) DO UPDATE SET valor = EXCLUDED.valor, descricao = EXCLUDED.descricao;

-- 12 ASSINATURAS DE ARTEFATO
INSERT INTO conteudo.assinatura_artefato (tipo_artefato, descricao, tokens_obrigatorios) VALUES
('sintese_evidencia','Sintese de evidencia com tres secoes e citacao por camada','{"cor":["primaria","neutro_100"],"tipografia":["familia_titulo","escala_28"],"espacamento":["esp_24"]}'),
('objetivos','Lista de objetivos com verbo observavel e criterio','{"cor":["primaria","neutro_100"],"tipografia":["familia_corpo","escala_16"],"espacamento":["esp_16"]}'),
('item','Item de avaliacao com enunciado e cinco alternativas','{"cor":["neutro_100","neutro_900"],"tipografia":["familia_corpo","escala_16"],"espacamento":["esp_16"]}'),
('gabarito','Gabarito comentado com justificativa por alternativa','{"cor":["sucesso","erro"],"tipografia":["familia_corpo","escala_14"],"espacamento":["esp_12"]}'),
('aula','Aula com cinco secoes e marcadores de controversia','{"cor":["primaria","acento"],"tipografia":["familia_titulo","escala_40"],"espacamento":["esp_32"]}'),
('caso','Caso clinico com desfecho e prazo','{"cor":["primaria","alerta"],"tipografia":["familia_corpo","escala_16"],"espacamento":["esp_24"]}'),
('protocolo','Protocolo com quinze secoes numeradas','{"cor":["primaria","neutro_700"],"tipografia":["familia_titulo","escala_28"],"espacamento":["esp_24"]}'),
('checklist','Checklist com marcador de conforme','{"cor":["sucesso","erro","neutro_200"],"tipografia":["familia_corpo","escala_14"],"espacamento":["esp_8"]}'),
('resumo','Resumo executivo com cinco secoes','{"cor":["primaria","neutro_100"],"tipografia":["familia_corpo","escala_16"],"espacamento":["esp_16"]}'),
('mapa','Mapa conceitual com nos e arestas','{"cor":["primaria","acento","neutro_200"],"tipografia":["familia_corpo","escala_14"],"espacamento":["esp_24"]}'),
('flashcard','Flashcard com frente e verso','{"cor":["primaria","neutro_100"],"tipografia":["familia_corpo","escala_20"],"espacamento":["esp_16"]}'),
('simulado','Simulado com itens e tempo','{"cor":["primaria","alerta"],"tipografia":["familia_corpo","escala_16"],"espacamento":["esp_16"]}')
ON CONFLICT (tipo_artefato) DO UPDATE
   SET descricao = EXCLUDED.descricao,
       tokens_obrigatorios = EXCLUDED.tokens_obrigatorios;

-- RLS
ALTER TABLE conteudo.design_token ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_design_token_leitura ON conteudo.design_token;
CREATE POLICY pol_design_token_leitura ON conteudo.design_token FOR SELECT USING (true);

DROP POLICY IF EXISTS pol_design_token_escrita ON conteudo.design_token;
CREATE POLICY pol_design_token_escrita ON conteudo.design_token FOR ALL
  USING (app.role_atual() IN ('admin','data_steward'))
  WITH CHECK (app.role_atual() IN ('admin','data_steward'));

-- CONFERENCIA
\echo '--- Conferencia ---'

SELECT 'total de tokens: ' || count(*) FROM conteudo.design_token;

SELECT categoria, count(*) AS n
  FROM conteudo.design_token
 GROUP BY categoria
 ORDER BY categoria;

SELECT 'assinaturas: ' || count(*) FROM conteudo.assinatura_artefato;

SELECT 'FALHA: total de tokens <> 57' WHERE (SELECT count(*) FROM conteudo.design_token) <> 57;
SELECT 'FALHA: assinaturas <> 12' WHERE (SELECT count(*) FROM conteudo.assinatura_artefato) <> 12;
SELECT 'FALHA: design_token sem RLS' WHERE NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'conteudo.design_token'::regclass);

-- VALIDACAO DE CONTRASTE
\echo '--- Validacao de contraste WCAG ---'

SELECT 'contraste primaria/neutro_100: ' || conteudo.fn_contraste_wcag('#1E3A5F', '#FFFFFF');
SELECT 'contraste neutro_900/neutro_100: ' || conteudo.fn_contraste_wcag('#121212', '#FFFFFF');

\echo '=== SETUP DESIGN TOKENS CONCLUIDO ==='

COMMIT;
