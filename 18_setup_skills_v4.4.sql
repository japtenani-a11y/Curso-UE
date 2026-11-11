linha_sql	
	
-- ============================================================	
-- 18_setup_skills_v4.4.sql	
-- Sistema de Producao Curricular e Coleta Cientifica	
-- Programa de Cirurgia de Urgencia e Trauma	
-- Versao 4.4 / 10-11-2026	
--	
-- OBJETIVO: registrar as 117 skills do sistema, com codigo,	
-- familia, volume, nome, descricao e contrato de entrada/saida.	
-- As skills sao a unidade de trabalho do executor.	
--	
-- PRE-REQUISITO: 01_instalar_v4.4.	
--	
-- USO: psql -d programa_v44 -v ON_ERROR_STOP=1 -f 18_setup_skills_v4.4.sql	
--	
-- CORRECAO v4.6: familia agora tem CHECK. PK-05 e SK-19 tinham	
"-- nome identico; PK-05 renomeada para ""Gestao de qualidade do"	
"-- curso"" e SK-19 mantida como ""Simulado do tema""."	
-- ============================================================	
	
\set ON_ERROR_STOP on	
\echo '=== SETUP SKILLS v4.4 ==='	
	
BEGIN	
	
CREATE TABLE IF NOT EXISTS ops.skill_definicao (	
  skill_definicao_id BIGSERIAL PRIMARY KEY,	
  codigo TEXT NOT NULL UNIQUE,	
  familia TEXT NOT NULL CHECK (familia IN ('SK','PK','RS','PS','AV','PG','DC','EN','GV','DS')),	
  volume SMALLINT NOT NULL CHECK (volume BETWEEN 1 AND 3),	
  nome TEXT NOT NULL,	
  descricao TEXT NOT NULL,	
  entrada TEXT,	
  saida TEXT,	
  gate_codigo TEXT,	
  ativo BOOLEAN NOT NULL DEFAULT true,	
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now()	
)	
	
CREATE INDEX IF NOT EXISTS ix_skill_familia ON ops.skill_definicao (familia, codigo);	
	
-- FAMILIA SK (19 skills de geracao de conteudo)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('SK-01','SK',1,'Busca de evidencia','Localiza fontes nas cinco camadas com identificador verificavel.','tema_id','fontes[]','G_EVI_BUSCA'),	
('SK-02','SK',1,'Sintese de evidencia','Consolida as fontes em tres secoes: consenso, disputa, lacuna.','fontes[]','sintese','G_EVI_SINTESE'),	
('SK-03','SK',1,'Cobertura de evidencia','Verifica os minimos por camada.','fontes[]','relatorio','G_EVI_COBERTURA'),	
('SK-04','SK',1,'Objetivos de aprendizagem','Formula de 5 a 9 objetivos observaveis em quatro tipos.','sintese','objetivos[]','G_OBJ_COMPLETUDE'),	
('SK-05','SK',1,'Itens de avaliacao','Constroi itens com 7 itens e 5 alternativas.','objetivos[]','itens[]','G_INS_ESTRUTURA'),	
('SK-06','SK',1,'Gabarito comentado','Justifica cada alternativa em cinco categorias de distrator.','itens[]','gabarito','G_INS_GABARITO'),	
('SK-07','SK',1,'Distribuicao de dificuldade','Distribui dificuldade e declara a ancora.','itens[]','distribuicao','G_INS_DIFICULDADE'),	
('SK-08','SK',1,'Artefato didatico','Produz o artefato com cinco secoes obrigatorias.','sintese','artefato','G_DID_ESTRUTURA'),	
('SK-09','SK',1,'Aula com controversia','Produz a aula com quatro marcadores literais de disputa.','sintese','aula','G_DID_CONTROVERSIA'),	
('SK-10','SK',1,'Caso clinico com desfecho','Constroi o caso com desfecho e prazo.','objetivos[]','caso','G_DID_CASO'),	
('SK-11','SK',1,'Caso clinico com complicacao','Constroi o caso com complicacao e conduta.','objetivos[]','caso','G_DID_CASO'),	
('SK-12','SK',1,'Resumo executivo','Produz o resumo com cinco secoes.','artefato','resumo','G_DID_ESTRUTURA'),	
('SK-13','SK',1,'Protocolo assistencial','Redige o protocolo com quinze secoes.','sintese','protocolo','G_PRO_QUINZE'),	
('SK-14','SK',1,'Auditoria do tema','Verifica cobertura de objetivos e consistencia entre artefatos.','artefatos[]','relatorio','G_QA_CHECKLIST'),	
('SK-15','SK',1,'Normalizacao terminologica','Garante termo unico por conceito.','artefatos[]','relatorio','G_QA_TERMOS'),	
('SK-16','SK',1,'Registro factual','Garante conteudo factual identico entre artefatos.','artefatos[]','relatorio','G_QA_REGISTRO'),	
('SK-17','SK',1,'Mapa conceitual','Produz o mapa conceitual do tema.','sintese','mapa',NULL),	
('SK-18','SK',1,'Flashcards','Produz os flashcards do tema.','sintese','flashcards',NULL),	
('SK-19','SK',1,'Simulado do tema','Produz o simulado do tema.','itens[]','simulado',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA PK (39 skills de plataforma, curso, site, dados, gestao, manutencao)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('PK-01','PK',2,'Desenho instrucional','Converte matriz de competencias em estrutura curricular.','matriz','estrutura',NULL),	
('PK-02','PK',2,'Sequenciamento de temas','Ordena temas por pre-requisito e distribui dificuldade.','temas[]','sequencia',NULL),	
('PK-03','PK',2,'Matriz de competencias','Define competencias por grau e papel curricular.','ciclo_id','matriz',NULL),	
('PK-04','PK',2,'Carga horaria','Distribui carga horaria por tema e semana.','estrutura','carga',NULL),	
('PK-05','PK',2,'Gestao de qualidade do curso','Consolida indicadores de qualidade do curso.','ciclo_id','painel',NULL),	
('PK-06','PK',2,'Calendario de ondas','Gera calendario sem sobreposicao e sem feriado.','ciclo_id','calendario',NULL),	
('PK-07','PK',2,'Ementa publica','Deriva a ementa publica do desenho instrucional.','estrutura','ementa',NULL),	
('PK-08','PK',2,'Publicacao de artefato','Publica artefato com checklist conforme e URL canonica.','artefato_id','url',NULL),	
('PK-09','PK',2,'Estruturacao de navegacao','Gera menu, breadcrumb, busca e indice.','artefatos[]','navegacao',NULL),	
('PK-10','PK',2,'Auditoria de acessibilidade','Audita WCAG 2.2 AA com elemento afetado.','url','relatorio',NULL),	
('PK-11','PK',2,'SEO','Verifica metadados e indexacao.','url','relatorio',NULL),	
('PK-12','PK',2,'Performance web','Mede Core Web Vitals em mobile e desktop.','url','metricas',NULL),	
('PK-13','PK',2,'Versionamento de artefato','Versiona artefato com diff e rollback.','artefato_id','versao',NULL),	
('PK-14','PK',2,'Ingestao de fonte','Ingere fonte com identificador e trecho literal.','fonte','fonte_id',NULL),	
('PK-15','PK',2,'Integridade referencial','Verifica integridade referencial entre fontes.','tema_id','relatorio',NULL),	
('PK-16','PK',2,'Exportacao de dado','Exporta dado com k-anonimato e trilha.','dataset','arquivo',NULL),	
('PK-17','PK',2,'Anonimizacao','Aplica k-anonimato ao dataset de pesquisa.','dataset','dataset',NULL),	
('PK-18','PK',2,'Reconciliacao app-pesquisa','Verifica divergencia entre app e pesquisa.','ciclo_id','relatorio',NULL),	
('PK-19','PK',2,'Importacao de aluno','Importa aluno com validacao de e-mail e CPF.','arquivo','alunos[]',NULL),	
('PK-20','PK',2,'Importacao de preceptor','Importa preceptor com validacao de designacao.','arquivo','preceptores[]',NULL),	
('PK-21','PK',2,'Backup e restauracao','Executa backup e testa restauracao.','banco','relatorio',NULL),	
('PK-22','PK',2,'Designacao de papel','Registra designacao com aprovador e vigencia.','pessoa_id','designacao',NULL),	
('PK-23','PK',2,'Convite de usuario','Emite convite com token de uso unico.','email','convite',NULL),	
('PK-24','PK',2,'Auditoria de acesso','Registra e revisa acesso a dado sensivel.','periodo','relatorio',NULL),	
('PK-25','PK',2,'Medicao de custo','Atribui consumo de token a tema e sinaliza anomalia.','periodo','custo',NULL),	
('PK-26','PK',2,'Painel de qualidade','Consolida os 14 gates em taxa de aprovacao e tendencia.','periodo','painel',NULL),	
('PK-27','PK',2,'Alocacao de preceptores','Aloca preceptores por modulo respeitando carga maxima.','ciclo_id','alocacao',NULL),	
('PK-28','PK',2,'Gestao de feriados','Registra feriados e bloqueia janela de onda.','ano','feriados[]',NULL),	
('PK-29','PK',2,'Deteccao de obsolescencia','Verifica retratacao de fonte e atualizacao de diretriz.','fonte_id','alerta',NULL),	
('PK-30','PK',2,'Correcao de erro factual','Corrige erro com versionamento e notificacao.','artefato_id','correcao',NULL),	
('PK-31','PK',2,'Varredura de integridade','Detecta FK orfa, CHECK violada, artefato sem bloco.','banco','relatorio',NULL),	
('PK-32','PK',2,'Gestao de tema','Cria, edita e congela tema.','tema','tema_id',NULL),	
('PK-33','PK',2,'Revisao anual','Orquestra a revisao completa do curso.','ciclo_id','relatorio',NULL),	
('PK-34','PK',2,'Gestao de ciclo','Cria e congela ciclo letivo.','ano','ciclo_id',NULL),	
('PK-35','PK',2,'Gestao de modulo','Cria e vincula modulo a tema.','modulo','modulo_id',NULL),	
('PK-36','PK',2,'Coleta de feedback','Coleta e consolida feedback do aluno.','tema_id','feedback',NULL),	
('PK-37','PK',2,'Relatorio de gestao','Consolida producao, qualidade, custo, adesao e retencao.','periodo','relatorio',NULL),	
('PK-38','PK',2,'Teste de regressao de conteudo','Verifica que correcao nao quebrou artefato dependente.','correcao_id','relatorio',NULL),	
('PK-39','PK',2,'Gestao de usuario','Cria, edita e desativa usuario.','pessoa','pessoa_id',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA RS (14 skills de pesquisa cientifica)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('RS-01','RS',3,'Pergunta de pesquisa','Formula pergunta com PICO e desfecho primario.','tema','pergunta',NULL),	
('RS-02','RS',3,'Revisao de literatura','Executa busca sistematica em multiplas bases.','pergunta','artigos[]',NULL),	
('RS-03','RS',3,'Triagem','Aplica criterios de inclusao e exclusao.','artigos[]','selecionados[]',NULL),	
('RS-04','RS',3,'Extracao de dados','Extrai dados dos estudos selecionados.','selecionados[]','dataset',NULL),	
('RS-05','RS',3,'Analise estatistica','Escolhe o teste adequado e verifica pressupostos.','dataset','resultado',NULL),	
('RS-06','RS',3,'Redacao IMRAD','Redige o manuscrito em IMRAD.','resultado','manuscrito',NULL),	
('RS-07','RS',3,'Avaliacao de risco de vies','Aplica ferramenta de risco de vies.','artigos[]','avaliacao',NULL),	
('RS-08','RS',3,'Resposta a revisor','Redige carta ponto a ponto com trecho alterado.','comentarios[]','carta',NULL),	
('RS-09','RS',3,'Checklist de relato','Verifica aderencia a CONSORT, STROBE, PRISMA.','manuscrito','relatorio',NULL),	
('RS-10','RS',3,'Meta-analise','Executa meta-analise com heterogeneidade.','dataset','resultado',NULL),	
('RS-11','RS',3,'Avaliacao de qualidade','Avalia qualidade metodologica dos estudos.','artigos[]','avaliacao',NULL),	
('RS-12','RS',3,'Normalizacao de referencias','Normaliza referencias e detecta citacao orfa.','manuscrito','referencias',NULL),	
('RS-13','RS',3,'Verificacao de plagio','Verifica similaridade e detecta plagio.','manuscrito','relatorio',NULL),	
('RS-14','RS',3,'Submissao','Prepara o pacote de submissao.','manuscrito','pacote',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA PS (8 skills de psicometria)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('PS-01','PS',3,'Analise de itens','Calcula dificuldade, discriminacao e ponto-bisserial.','onda_id','analise',NULL),	
('PS-02','PS',3,'Analise de distratores','Verifica se cada distrator foi escolhido.','onda_id','analise',NULL),	
('PS-03','PS',3,'Confiabilidade','Calcula alfa de Cronbach e KR-20.','onda_id','coeficiente',NULL),	
('PS-04','PS',3,'Analise fatorial','Executa analise fatorial confirmatoria.','ciclo_id','cargas',NULL),	
('PS-05','PS',3,'DIF','Detecta funcionamento diferencial do item.','ciclo_id','relatorio',NULL),	
('PS-06','PS',3,'Equiparacao','Equipara ondas por Teoria de Resposta ao Item.','ciclo_id','parametros',NULL),	
('PS-07','PS',3,'Curva de retencao','Calcula a curva de retencao por coorte.','coorte_id','curva',NULL),	
('PS-08','PS',3,'Sinalizacao de item problematico','Sinaliza item com discriminacao negativa ou nula.','onda_id','alertas[]',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA AV (7 skills de avaliacao e feedback)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('AV-01','AV',3,'Correcao de prova','Corrige prova e calcula nota.','tentativa_id','nota',NULL),	
('AV-02','AV',3,'Analise de desempenho','Analisa desempenho por constructo.','tentativa_id','relatorio',NULL),	
('AV-03','AV',3,'Feedback individual','Redige devolutiva individual.','tentativa_id','feedback',NULL),	
('AV-04','AV',3,'Feedback coletivo','Redige devolutiva coletiva por onda.','onda_id','feedback',NULL),	
('AV-05','AV',3,'Avaliacao de competencia','Avalia competencia com evidencia rastreavel.','pessoa_id','avaliacao',NULL),	
('AV-06','AV',3,'Avaliacao de preceptor','Avalia desempenho do preceptor.','preceptor_id','avaliacao',NULL),	
('AV-07','AV',3,'Parecer de competencia','Redige parecer final com nivel atingido.','ciclo_id','parecer',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA PG (7 skills de pos-graduacao)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('PG-01','PG',3,'Orientacao','Acompanha o orientando no cronograma.','orientando_id','plano',NULL),	
('PG-02','PG',3,'Projeto de pesquisa','Redige o projeto de pesquisa.','pergunta','projeto',NULL),	
('PG-03','PG',3,'Qualificacao','Prepara a banca de qualificacao.','projeto','parecer',NULL),	
('PG-04','PG',3,'Defesa','Prepara a banca de defesa.','manuscrito','parecer',NULL),	
('PG-05','PG',3,'Cronograma','Gera cronograma de mestrado ou doutorado.','orientando_id','cronograma',NULL),	
('PG-06','PG',3,'Derivacao de artigo','Deriva artigo da dissertacao ou tese.','tese','artigo',NULL),	
('PG-07','PG',3,'Relatorio CAPES','Consolida o relatorio CAPES do quadrienio.','periodo','relatorio',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA DC (6 skills de disseminacao)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('DC-01','DC',3,'Post para redes','Produz post para rede social.','artefato_id','post',NULL),	
('DC-02','DC',3,'Newsletter','Produz a newsletter do programa.','periodo','newsletter',NULL),	
('DC-03','DC',3,'Podcast','Produz o roteiro do podcast.','tema_id','roteiro',NULL),	
('DC-04','DC',3,'Video','Produz o roteiro do video.','tema_id','roteiro',NULL),	
('DC-05','DC',3,'Apresentacao','Produz a apresentacao do tema.','tema_id','slides',NULL),	
('DC-06','DC',3,'Divulgacao cientifica','Traduz o artigo para o publico leigo.','artigo','texto',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA EN (8 skills de engenharia)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('EN-01','EN',3,'Verificacao de tipos','Executa typecheck nos tres pacotes.','codigo','relatorio',NULL),	
('EN-02','EN',3,'Teste unitario','Executa a suite de testes unitarios.','codigo','relatorio',NULL),	
('EN-03','EN',3,'Teste de carga','Simula 40 alunos simultaneos na janela de onda.','api','relatorio',NULL),	
('EN-04','EN',3,'Observabilidade','Instrumenta log estruturado com request_id e latencia.','api','metricas',NULL),	
('EN-05','EN',3,'Migracao de banco','Executa migracao com rollback.','migracao','relatorio',NULL),	
('EN-06','EN',3,'Deploy','Executa deploy com health check.','release','relatorio',NULL),	
('EN-07','EN',3,'Revisao de seguranca','Verifica OWASP Top 10 no codigo.','codigo','relatorio',NULL),	
('EN-08','EN',3,'Conformidade LGPD','Verifica base legal, minimizacao e trilha por tabela.','banco','relatorio',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA GV (5 skills de governanca)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('GV-01','GV',3,'Relatorio CAPES','Consolida producao por discente no quadrienio.','periodo','relatorio',NULL),	
('GV-02','GV',3,'Politica de acesso','Define e revisa a politica de acesso.','perfil','politica',NULL),	
('GV-03','GV',3,'Comite de etica','Prepara a submissao ao comite de etica.','projeto','parecer',NULL),	
('GV-04','GV',3,'Auditoria anual','Executa a auditoria anual do sistema.','ano','relatorio',NULL),	
('GV-05','GV',3,'Plano de contingencia','Documenta o plano de contingencia.','sistema','plano',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- FAMILIA DS (4 skills de design visual)	
INSERT INTO ops.skill_definicao (codigo, familia, volume, nome, descricao, entrada, saida, gate_codigo) VALUES	
('DS-01','DS',3,'Sistema de design tokens','Define os 57 tokens visuais.','sistema','tokens[]',NULL),	
('DS-02','DS',3,'Assinatura visual','Define as 12 assinaturas por tipo de artefato.','tipo_artefato','assinatura',NULL),	
('DS-03','DS',3,'Template de artefato','Gera template por canal (HTML, LaTeX, slide, audio).','artefato_id','template',NULL),	
('DS-04','DS',3,'Auditoria visual','Audita artefato publicado contra o sistema.','artefato_id','relatorio',NULL)	
ON CONFLICT (codigo) DO UPDATE	
   SET familia = EXCLUDED.familia, volume = EXCLUDED.volume, nome = EXCLUDED.nome,	
       descricao = EXCLUDED.descricao, entrada = EXCLUDED.entrada, saida = EXCLUDED.saida,	
       gate_codigo = EXCLUDED.gate_codigo	
	
-- CONFERENCIA	
\echo '--- Conferencia ---'	
	
SELECT 'total de skills: ' || count(*) FROM ops.skill_definicao	
	
SELECT familia, count(*) AS n	
  FROM ops.skill_definicao	
 GROUP BY familia	
 ORDER BY familia	
	
SELECT 'FALHA: total <> 117' WHERE (SELECT count(*) FROM ops.skill_definicao) <> 117	
	
SELECT 'FALHA: familia sem CHECK' WHERE NOT EXISTS (	
  SELECT 1 FROM pg_constraint c	
    JOIN pg_class t ON t.oid = c.conrelid	
   WHERE t.relname = 'skill_definicao' AND c.contype = 'c' AND pg_get_constraintdef(c.oid) LIKE '%familia%'	
)	
	
\echo '=== SETUP SKILLS CONCLUIDO ==='	
	
COMMIT	
