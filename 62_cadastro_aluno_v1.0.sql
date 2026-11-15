-- 62_cadastro_aluno_v1.0.sql
-- Inscricao do aluno no curso, ficha cadastral e termos (versionados, com historico de aceites).
--  - Primeiro login com Google de um e-mail novo: cria a pessoa e a ficha em "rascunho" (se a inscricao estiver aberta).
--  - Faculdade (onde faz ou onde se formou) e local da residencia (onde faz ou onde fez) tem lista de sugestoes no app.
--  - O aluno preenche a ficha e aceita os termos obrigatorios (uso/confidencialidade/seguranca e privacidade);
--    o TCLE de pesquisa e a autorizacao de divulgacao sao OPCIONAIS e podem ser revogados a qualquer momento
--    (a participacao no curso nao depende deles).
--  - A ficha enviada fica "pendente"; a coordenacao aprova ou recusa (e-mail aos curadores e ao aluno).
--  - Ao aprovar, o ano de residencia (R1...R6), a especialidade e a turma (ano de ingresso) passam a valer
--    para testes, ranking e painel.
--  - Enquanto nao estiver aprovado com os termos obrigatorios aceitos, o aluno nao acessa material nem testes.
-- OS TEXTOS DOS TERMOS SAO MINUTAS: revisar com o CEP e o setor juridico antes de abrir para os alunos.
-- Pre-requisito: 27, 45, 55, 58 e 60. Pode ser rodado mais de uma vez (nova versao de termo: mudar a versao abaixo).
\set ON_ERROR_STOP on
BEGIN;

-- ---------- configuracao ----------
CREATE TABLE IF NOT EXISTS app.config_curso (
  chave TEXT PRIMARY KEY,
  valor TEXT NOT NULL);
INSERT INTO app.config_curso VALUES ('inscricao_aberta', 'sim') ON CONFLICT (chave) DO NOTHING;

-- ---------- ficha ----------
CREATE TABLE IF NOT EXISTS app.ficha_aluno (
  pessoa_id             BIGINT PRIMARY KEY REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  celular               TEXT CHECK (celular IS NULL OR celular ~ '^\+[1-9][0-9]{9,14}$'),
  situacao              TEXT CHECK (situacao IN ('graduacao','residencia','formado')),
  semestre              SMALLINT CHECK (semestre BETWEEN 7 AND 12),
  ano_formatura         SMALLINT CHECK (ano_formatura BETWEEN 1960 AND 2100),
  faculdade             TEXT CHECK (length(faculdade) <= 200),
  especialidade         TEXT CHECK (especialidade IN ('cirurgia_geral','cirurgia_urgencia_trauma','medicina_emergencia','outra_cirurgica')),
  especialidade_outra   TEXT CHECK (length(especialidade_outra) <= 120),
  instituicao_residencia TEXT CHECK (length(instituicao_residencia) <= 200),
  ano_ingresso_residencia SMALLINT CHECK (ano_ingresso_residencia BETWEEN 1990 AND 2100),
  termino_previsto      DATE,
  status                TEXT NOT NULL DEFAULT 'rascunho' CHECK (status IN ('rascunho','pendente','aprovado','recusado')),
  motivo_status         TEXT CHECK (length(motivo_status) <= 1000),
  decidido_por          BIGINT REFERENCES app.pessoa(pessoa_id),
  decidido_em           TIMESTAMPTZ,
  enviado_em            TIMESTAMPTZ,
  criado_em             TIMESTAMPTZ NOT NULL DEFAULT now(),
  atualizado_em         TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE app.ficha_aluno ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pol_ficha_propria ON app.ficha_aluno;
CREATE POLICY pol_ficha_propria ON app.ficha_aluno FOR SELECT TO api_rw USING (pessoa_id = app.pessoa_atual());
GRANT SELECT ON app.ficha_aluno TO api_rw;

-- ---------- termos ----------
ALTER TABLE app.ficha_aluno ADD COLUMN IF NOT EXISTS confirmado_em TIMESTAMPTZ;
COMMENT ON COLUMN app.ficha_aluno.confirmado_em IS 'ultima vez que o aluno salvou/confirmou a ficha (confirmacao anual em marco)';

-- Regras de aprovacao automatica: dominio de e-mail (ex.: usp.br) ou e-mail exato (lista de residentes).
CREATE TABLE IF NOT EXISTS app.regra_aprovacao (
  tipo  TEXT NOT NULL CHECK (tipo IN ('dominio','email')),
  valor TEXT NOT NULL CHECK (valor = lower(valor) AND length(valor) BETWEEN 3 AND 200),
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tipo, valor));
GRANT SELECT ON app.regra_aprovacao TO api_rw;

-- Confirmacao anual: a partir de 1o de marco, quem nao confirmou a ficha no ano corrente precisa confirmar.
CREATE OR REPLACE FUNCTION app.precisa_confirmar_ano(p_pessoa BIGINT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce((SELECT f.status = 'aprovado'
                      AND current_date >= make_date(extract(year FROM current_date)::int, 3, 1)
                      AND coalesce(f.confirmado_em, f.decidido_em, f.enviado_em) < make_date(extract(year FROM current_date)::int, 3, 1)
                     FROM app.ficha_aluno f WHERE f.pessoa_id = p_pessoa), false) $$;

CREATE OR REPLACE FUNCTION app.aprovacao_automatica(p_email TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT EXISTS (SELECT 1 FROM app.regra_aprovacao r
                  WHERE (r.tipo = 'email' AND r.valor = lower(p_email))
                     OR (r.tipo = 'dominio' AND (lower(p_email) LIKE '%@' || r.valor OR lower(p_email) LIKE '%.' || r.valor))) $$;

CREATE TABLE IF NOT EXISTS app.termo (
  codigo      TEXT NOT NULL CHECK (codigo IN ('uso','privacidade','pesquisa','divulgacao')),
  versao      TEXT NOT NULL,
  titulo      TEXT NOT NULL,
  resumo      TEXT NOT NULL,
  texto       TEXT NOT NULL,
  obrigatorio BOOLEAN NOT NULL,
  vigente     BOOLEAN NOT NULL DEFAULT true,
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (codigo, versao));
GRANT SELECT ON app.termo TO api_rw;

-- Historico de aceites (so insercao): o ultimo registro de cada termo e o que vale.
CREATE TABLE IF NOT EXISTS app.aceite_termo (
  aceite_id  BIGSERIAL PRIMARY KEY,
  pessoa_id  BIGINT NOT NULL REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE,
  codigo     TEXT NOT NULL,
  versao     TEXT NOT NULL,
  aceito     BOOLEAN NOT NULL,
  ip         INET,
  user_agent TEXT,
  em         TIMESTAMPTZ NOT NULL DEFAULT now(),
  FOREIGN KEY (codigo, versao) REFERENCES app.termo(codigo, versao));
CREATE INDEX IF NOT EXISTS ix_aceite_pessoa ON app.aceite_termo (pessoa_id, codigo, em DESC);
REVOKE UPDATE, DELETE, TRUNCATE ON app.aceite_termo FROM api_rw;

-- Notificacoes ligadas a inscricao (aviso aos curadores e resposta ao aluno).
ALTER TABLE app.notificacao_saida ADD COLUMN IF NOT EXISTS inscricao_pessoa_id BIGINT REFERENCES app.pessoa(pessoa_id) ON DELETE CASCADE;

-- Textos (minutas). Para publicar uma nova versao: troque a versao e rode de novo; a anterior deixa de ser vigente
-- e os alunos precisam aceitar de novo os termos obrigatorios.
CREATE TEMP TABLE termo_novo (LIKE app.termo INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO termo_novo (codigo, versao, titulo, resumo, obrigatorio, texto) VALUES
('uso', 'v1-2026-11', 'Termo de uso, confidencialidade e segurança',
 'Regras de uso da plataforma, sigilo do conteúdo e dos casos, proibição de dados de pacientes e registro das ações para segurança.',
 true, $t$
**Programa de Cirurgia de Urgência e Trauma — Termo de uso, confidencialidade e segurança (versão v1-2026-11)**

Ao se inscrever, você declara que leu e concorda com as regras abaixo.

**1. Sobre o curso e a responsabilidade pelo conteúdo.** O programa é uma atividade educacional idealizada e coordenada pela equipe responsável pelo curso, que se responsabiliza pelo conteúdo publicado: ele é elaborado a partir das fontes citadas em cada material e revisado por cirurgiões antes da publicação. O conteúdo tem finalidade exclusivamente educacional, reflete as evidências disponíveis na data da revisão e não substitui o julgamento clínico, a supervisão do seu serviço nem os protocolos da instituição onde você atua. Casos e dados de pacientes apresentados no curso são fictícios ou desidentificados.

**2. Sua conta.** O acesso é pessoal e intransferível, feito com a sua conta Google. Não compartilhe o acesso. Você é responsável pelas ações feitas na sua conta e deve avisar a coordenação se suspeitar de uso indevido.

**3. Confidencialidade e propriedade do conteúdo.** Aulas, casos, testes, gabaritos, slides, áudios e demais materiais são de uso exclusivo dos participantes. É proibido copiar, gravar, fotografar, imprimir, baixar, reproduzir, publicar ou repassar o conteúdo, inteiro ou em parte, a qualquer pessoa ou plataforma, inclusive grupos de mensagens e ferramentas de inteligência artificial, sem autorização por escrito da coordenação. As telas levam marca d'água com seu nome, e-mail, data e hora.

**4. Dados de pacientes.** É proibido inserir na plataforma (dúvidas, comentários, feedback ou qualquer campo) dados que identifiquem pacientes: nome, iniciais, prontuário, registro, data de nascimento, endereço, imagens, laudos ou qualquer combinação que permita a identificação. Discuta casos reais apenas de forma totalmente desidentificada, respeitando o sigilo profissional e a LGPD.

**5. Conduta.** Mensagens devem ser respeitosas e relacionadas ao curso. A resposta dos testes é individual; não compartilhe respostas nem gabaritos.

**6. Registro de segurança (tudo o que é feito e dito na plataforma).** Para proteger o conteúdo, os participantes e a integridade das avaliações, a plataforma registra automaticamente: entradas e saídas (data, hora, endereço IP e navegador), cada material e teste aberto, respostas e tempo de resposta, avaliações, dúvidas, feedback e respostas recebidas, aceites destes termos e tentativas de acesso não permitidas. Esses registros ficam guardados de forma segura, com acesso restrito à coordenação, e podem ser usados para investigar uso indevido e cumprir obrigações legais. Acesso automatizado ou em volume anormal é bloqueado.

**7. Descumprimento.** O descumprimento destas regras pode levar à suspensão ou ao cancelamento do acesso, sem prejuízo das medidas legais cabíveis (inclusive por violação de direitos autorais e de sigilo).

**8. Alterações.** Mudanças relevantes neste termo geram nova versão, e você será solicitado a aceitá-la para continuar.

Contato da coordenação: [e-mail institucional do curso].
$t$),
('privacidade', 'v1-2026-11', 'Aviso de privacidade e proteção de dados (LGPD)',
 'Quais dados pessoais coletamos, para quê, com quem compartilhamos, por quanto tempo guardamos, como protegemos e quais são os seus direitos.',
 true, $t$
**Aviso de privacidade e proteção de dados — Lei 13.709/2018 (versão v1-2026-11)**

**Controlador:** [instituição/coordenação responsável pelo curso]. **Contato para assuntos de dados pessoais:** [e-mail do encarregado ou da coordenação].

**1. Dados que coletamos.**
- Cadastro: nome, e-mail, data de nascimento, celular, situação acadêmica (semestre ou ano de formatura, faculdade), especialidade, instituição, ano de ingresso e término previsto da residência.
- Uso do curso: respostas e notas dos testes, tempo de resposta e de leitura, materiais acessados, avaliações (NPS e satisfação), dúvidas, feedback e mensagens.
- Dados técnicos e de segurança: data, hora, endereço IP, navegador e registros de acesso.

**2. Para que usamos e com qual base legal.**
- Executar o curso (acesso, liberação de material, testes, gabaritos, lembretes, ranking, certificação): execução do contrato e procedimentos preliminares (art. 7º, V).
- Segurança da plataforma, prevenção de fraude e proteção do conteúdo: legítimo interesse (art. 7º, IX) e cumprimento de obrigação legal (art. 7º, II).
- Acompanhamento pedagógico e melhoria do curso pela coordenação: legítimo interesse (art. 7º, IX).
- Pesquisa científica e divulgação: somente com o seu consentimento específico e opcional, nos termos próprios (art. 7º, I e IV).

**3. Compartilhamento.** Não vendemos nem cedemos seus dados. Eles são tratados pela coordenação e pelos curadores do curso e por prestadores necessários ao funcionamento (hospedagem, login do Google, envio de e-mail), que atuam sob nossas instruções. O ranking mostra apenas a sua posição para você mesmo; publicações científicas usam dados agregados ou pseudonimizados, nunca identificados.

**4. Por quanto tempo.** Durante a sua participação e por até 5 anos após o término do ciclo do curso (ou pelo prazo exigido em lei ou pelo protocolo de pesquisa aprovado), depois são eliminados ou anonimizados. Registros de acesso são guardados por pelo menos 6 meses.

**5. Como protegemos.** Conexão criptografada (HTTPS), acesso por login individual, controle de permissões por papel e por linha no banco de dados, pseudonimização para pesquisa, registro de acessos e cópias de segurança. Em caso de incidente de segurança relevante, você e a ANPD serão comunicados conforme a lei.

**6. Seus direitos (art. 18).** Confirmar o tratamento, acessar, corrigir, pedir anonimização, bloqueio ou eliminação de dados desnecessários, portabilidade, informação sobre compartilhamento e revogar consentimentos. A ficha pode ser corrigida em "Meus dados"; os demais pedidos podem ser feitos pelo contato acima ou pelo botão de solicitação na mesma tela.
$t$),
('pesquisa', 'v1-2026-11', 'TCLE — uso dos seus dados em pesquisa científica (opcional)',
 'Autoriza, de forma voluntária e revogável, o uso dos dados gerados por você no curso em pesquisas científicas, sem identificação.',
 false, $t$
**Termo de Consentimento Livre e Esclarecido — pesquisa científica (versão v1-2026-11)**
*Minuta: o texto definitivo deve seguir o protocolo aprovado pelo Comitê de Ética em Pesquisa (Resoluções CNS 466/2012 e 510/2016).*

**Título provisório:** Avaliação de um programa educacional estruturado em cirurgia de urgência e trauma para residentes e estudantes de medicina.
**Pesquisador responsável:** [nome, instituição, e-mail e telefone]. **CEP:** [Comitê de Ética em Pesquisa — endereço, telefone e e-mail].

**1. Por que você está sendo convidado.** Você participa do programa, e queremos estudar o aprendizado, a retenção do conhecimento e a satisfação com o método.

**2. O que será usado.** Os dados que o curso já gera: respostas e notas dos testes (pré e pós), tempo de resposta e de leitura, materiais acessados, avaliações de satisfação (NPS), dúvidas e feedback, e dados da ficha (idade, situação acadêmica, especialidade, ano de residência). Nenhuma atividade extra é exigida.

**3. Participação voluntária.** Aceitar ou não é uma escolha livre. Recusar ou retirar o consentimento, a qualquer momento e sem justificativa, não traz qualquer prejuízo à sua participação no curso, à sua avaliação, à sua residência ou à sua relação com os preceptores e a instituição. A retirada vale para os dados ainda não analisados.

**4. Sigilo.** Para análise, seu nome é substituído por um código. Os resultados serão publicados apenas de forma agregada, sem qualquer informação que permita identificá-lo. O acesso aos dados identificados é restrito à coordenação.

**5. Riscos e benefícios.** O risco principal é a quebra de sigilo, minimizada pela pseudonimização, pelo controle de acesso e pelo armazenamento seguro. Pode haver desconforto ao ver seu desempenho comparado, o que é mitigado por resultados apenas agregados. Não há benefício direto garantido; o benefício esperado é melhorar o ensino de cirurgia de urgência e trauma.

**6. Custos e ressarcimento.** Não há custo nem pagamento pela participação. Você tem direito a indenização por eventuais danos decorrentes da pesquisa, nos termos da legislação.

**7. Guarda dos dados.** Por 5 anos após o término da pesquisa, depois eliminados ou anonimizados.

**8. Dúvidas.** Fale com o pesquisador responsável ou com o CEP nos contatos acima. Você pode baixar e guardar uma cópia deste termo.

Ao marcar "Aceito", você declara que entendeu as informações e concorda, voluntariamente, em participar.
$t$),
('divulgacao', 'v1-2026-11', 'Autorização de divulgação (opcional)',
 'Autoriza o uso de resultados agregados e de comentários anônimos na divulgação do curso (apresentações, congressos, redes e materiais institucionais).',
 false, $t$
**Autorização de divulgação (versão v1-2026-11)**

Autorizo, de forma voluntária, gratuita e revogável, que os idealizadores do programa utilizem, na divulgação do curso (apresentações, congressos, relatórios, materiais institucionais e redes sociais):
- resultados agregados de desempenho e satisfação dos quais meus dados façam parte, sem identificação;
- trechos de comentários e avaliações que eu escrever, sempre sem nome, foto ou qualquer dado que me identifique.

Esta autorização **não** inclui o uso do meu nome, imagem ou voz, que dependerá de autorização específica e por escrito. Recusar ou revogar esta autorização não traz qualquer prejuízo à minha participação no curso. A revogação vale para usos futuros.
$t$);

UPDATE app.termo t SET vigente = false
  FROM termo_novo n WHERE t.codigo = n.codigo AND t.versao <> n.versao AND t.vigente;
INSERT INTO app.termo (codigo, versao, titulo, resumo, texto, obrigatorio, vigente)
SELECT codigo, versao, titulo, resumo, texto, obrigatorio, true FROM termo_novo
ON CONFLICT (codigo, versao) DO UPDATE SET titulo = EXCLUDED.titulo, resumo = EXCLUDED.resumo, texto = EXCLUDED.texto,
  obrigatorio = EXCLUDED.obrigatorio, vigente = true;

-- ---------- funcoes ----------
CREATE OR REPLACE FUNCTION app.aceite_vigente(p_pessoa BIGINT, p_codigo TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce((SELECT a.aceito FROM app.aceite_termo a JOIN app.termo t ON t.codigo = a.codigo AND t.versao = a.versao AND t.vigente
                    WHERE a.pessoa_id = p_pessoa AND a.codigo = p_codigo ORDER BY a.em DESC, a.aceite_id DESC LIMIT 1), false) $$;

-- O aluno pode usar o curso? (outros papeis: sempre)
CREATE OR REPLACE FUNCTION app.cadastro_ok() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT CASE
    WHEN app.pessoa_atual() IS NULL THEN false
    WHEN EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = app.pessoa_atual()
                  AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)) THEN true
    ELSE coalesce((SELECT f.status = 'aprovado' FROM app.ficha_aluno f WHERE f.pessoa_id = app.pessoa_atual()), false)
         AND NOT app.precisa_confirmar_ano(app.pessoa_atual())
         AND NOT EXISTS (SELECT 1 FROM app.termo t WHERE t.vigente AND t.obrigatorio
                          AND NOT app.aceite_vigente(app.pessoa_atual(), t.codigo))
  END $$;

CREATE OR REPLACE FUNCTION app.rotulo_especialidade(p TEXT, p_outra TEXT) RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p WHEN 'cirurgia_geral' THEN 'Cirurgia Geral' WHEN 'cirurgia_urgencia_trauma' THEN 'Cirurgia de Urgência e Trauma'
                WHEN 'medicina_emergencia' THEN 'Medicina de Emergência'
                WHEN 'outra_cirurgica' THEN coalesce('Outra cirúrgica: ' || nullif(trim(p_outra), ''), 'Outra especialidade cirúrgica')
                ELSE NULL END $$;

-- Grau (R1...R6, graduacao, egresso) a partir da ficha.
CREATE OR REPLACE FUNCTION app.grau_da_ficha(f app.ficha_aluno) RETURNS app.grau_enum LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN f.situacao = 'graduacao' THEN 'graduacao'::app.grau_enum
    WHEN f.situacao = 'residencia' AND f.ano_ingresso_residencia IS NOT NULL
         AND (f.termino_previsto IS NULL OR f.termino_previsto >= current_date)
      THEN ('R' || least(6, greatest(1, extract(year FROM current_date)::int - f.ano_ingresso_residencia + 1)))::app.grau_enum
    ELSE 'egresso'::app.grau_enum END $$;

-- Login com Google: devolve o token; e-mail novo vira inscricao em rascunho (se a inscricao estiver aberta).
CREATE OR REPLACE FUNCTION app.fn_sessao_google_inscricao(p_email TEXT, p_nome TEXT, p_ip INET, p_ua TEXT)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v_id BIGINT;
BEGIN
  SELECT pessoa_id INTO v_id FROM app.pessoa WHERE lower(email_primario::text) = lower(p_email);
  IF v_id IS NULL THEN
    IF coalesce((SELECT valor FROM app.config_curso WHERE chave = 'inscricao_aberta'), 'nao') <> 'sim' THEN RETURN NULL; END IF;
    INSERT INTO app.pessoa (nome_completo, email_primario)
    VALUES (coalesce(nullif(left(trim(p_nome), 200), ''), split_part(p_email, '@', 1)), lower(p_email))
    RETURNING pessoa_id INTO v_id;
    INSERT INTO app.ficha_aluno (pessoa_id) VALUES (v_id) ON CONFLICT DO NOTHING;
  END IF;
  RETURN app.fn_sessao_google(p_email, p_ip, p_ua);
END $$;
REVOKE EXECUTE ON FUNCTION app.fn_sessao_google_inscricao(TEXT, TEXT, INET, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.fn_sessao_google_inscricao(TEXT, TEXT, INET, TEXT) TO api_rw;

-- Ficha e termos da pessoa logada.
CREATE OR REPLACE FUNCTION app.minha_ficha() RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT jsonb_build_object(
    'nome', p.nome_completo, 'email', p.email_primario::text, 'data_nascimento', p.data_nascimento,
    'ficha', coalesce(to_jsonb(f) - 'pessoa_id' - 'decidido_por', jsonb_build_object('status', 'rascunho')),
    'precisa_ficha', NOT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p.pessoa_id
                                  AND d.vigencia_inicio <= current_date AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date)),
    'cadastro_ok', app.cadastro_ok(),
    'confirmar_ano', app.precisa_confirmar_ano(p.pessoa_id),
    'termos', (SELECT jsonb_agg(jsonb_build_object('codigo', t.codigo, 'versao', t.versao, 'titulo', t.titulo, 'resumo', t.resumo,
                                                   'texto', t.texto, 'obrigatorio', t.obrigatorio,
                                                   'aceito', app.aceite_vigente(p.pessoa_id, t.codigo),
                                                   'aceito_em', (SELECT max(a.em) FROM app.aceite_termo a WHERE a.pessoa_id = p.pessoa_id
                                                                   AND a.codigo = t.codigo AND a.versao = t.versao AND a.aceito))
                                ORDER BY array_position(ARRAY['uso','privacidade','pesquisa','divulgacao'], t.codigo))
                 FROM app.termo t WHERE t.vigente))
    FROM app.pessoa p LEFT JOIN app.ficha_aluno f ON f.pessoa_id = p.pessoa_id
   WHERE p.pessoa_id = app.pessoa_atual() $$;

-- Grava a ficha e os aceites. Valida tudo aqui (a API so repassa). Devolve o status.
CREATE OR REPLACE FUNCTION app.salvar_ficha(p JSONB, p_ip INET, p_ua TEXT) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE
  v_id BIGINT := app.pessoa_atual(); v_nasc DATE; v_sit TEXT := p->>'situacao'; v_status TEXT; v_novo BOOLEAN;
  v_term DATE; t RECORD;
BEGIN
  IF v_id IS NULL THEN RAISE EXCEPTION 'sem_sessao'; END IF;
  IF length(trim(coalesce(p->>'nome', ''))) < 5 OR position(' ' IN trim(p->>'nome')) = 0 THEN RAISE EXCEPTION 'campo:nome'; END IF;
  BEGIN v_nasc := (p->>'data_nascimento')::date; EXCEPTION WHEN others THEN RAISE EXCEPTION 'campo:data_nascimento'; END;
  IF v_nasc IS NULL OR v_nasc < DATE '1940-01-01' OR v_nasc > current_date - interval '16 years' THEN RAISE EXCEPTION 'campo:data_nascimento'; END IF;
  IF coalesce(p->>'celular', '') !~ '^\+[1-9][0-9]{9,14}$' THEN RAISE EXCEPTION 'campo:celular'; END IF;
  IF v_sit NOT IN ('graduacao','residencia','formado') OR v_sit IS NULL THEN RAISE EXCEPTION 'campo:situacao'; END IF;
  IF v_sit = 'graduacao' AND coalesce((p->>'semestre')::int, 0) NOT BETWEEN 7 AND 12 THEN RAISE EXCEPTION 'campo:semestre'; END IF;
  IF length(trim(coalesce(p->>'faculdade', ''))) < 3 THEN RAISE EXCEPTION 'campo:faculdade'; END IF;
  IF v_sit = 'residencia' AND length(trim(coalesce(p->>'instituicao_residencia', ''))) < 3 THEN RAISE EXCEPTION 'campo:instituicao_residencia'; END IF;
  IF v_sit <> 'graduacao' AND coalesce((p->>'ano_formatura')::int, 0) NOT BETWEEN 1960 AND extract(year FROM current_date)::int THEN
    RAISE EXCEPTION 'campo:ano_formatura'; END IF;
  IF v_sit <> 'graduacao' AND coalesce(p->>'especialidade', '') NOT IN ('cirurgia_geral','cirurgia_urgencia_trauma','medicina_emergencia','outra_cirurgica') THEN
    RAISE EXCEPTION 'campo:especialidade'; END IF;
  IF v_sit <> 'graduacao' AND p->>'especialidade' = 'outra_cirurgica' AND length(trim(coalesce(p->>'especialidade_outra', ''))) < 3 THEN
    RAISE EXCEPTION 'campo:especialidade_outra'; END IF;
  IF v_sit = 'residencia' THEN
    IF coalesce((p->>'ano_ingresso_residencia')::int, 0) NOT BETWEEN 1990 AND extract(year FROM current_date)::int + 1 THEN
      RAISE EXCEPTION 'campo:ano_ingresso_residencia'; END IF;
    BEGIN v_term := (p->>'termino_previsto')::date; EXCEPTION WHEN others THEN RAISE EXCEPTION 'campo:termino_previsto'; END;
    IF v_term IS NULL OR extract(year FROM v_term) < (p->>'ano_ingresso_residencia')::int THEN RAISE EXCEPTION 'campo:termino_previsto'; END IF;
  END IF;
  -- termos obrigatorios
  FOR t IN SELECT codigo, versao, obrigatorio FROM app.termo WHERE vigente LOOP
    IF t.obrigatorio AND coalesce((p->'aceites'->>t.codigo)::boolean, false) IS NOT TRUE THEN RAISE EXCEPTION 'termo:%', t.codigo; END IF;
  END LOOP;

  UPDATE app.pessoa SET nome_completo = left(trim(p->>'nome'), 200), data_nascimento = v_nasc, atualizado_em = now()
   WHERE pessoa_id = v_id;
  SELECT status INTO v_status FROM app.ficha_aluno WHERE pessoa_id = v_id;
  v_novo := v_status IS NULL OR v_status IN ('rascunho','recusado');
  INSERT INTO app.ficha_aluno (pessoa_id, celular, situacao, semestre, ano_formatura, faculdade, especialidade, especialidade_outra,
                               instituicao_residencia, ano_ingresso_residencia, termino_previsto, status, enviado_em, atualizado_em)
  VALUES (v_id, p->>'celular', v_sit,
          CASE WHEN v_sit = 'graduacao' THEN (p->>'semestre')::smallint END,
          CASE WHEN v_sit <> 'graduacao' THEN (p->>'ano_formatura')::smallint END,
          nullif(left(trim(coalesce(p->>'faculdade', '')), 200), ''),
          CASE WHEN v_sit <> 'graduacao' THEN p->>'especialidade' END,
          CASE WHEN v_sit <> 'graduacao' AND p->>'especialidade' = 'outra_cirurgica' THEN left(trim(p->>'especialidade_outra'), 120) END,
          CASE WHEN v_sit IN ('residencia','formado') THEN nullif(left(trim(coalesce(p->>'instituicao_residencia', '')), 200), '') END,
          CASE WHEN v_sit = 'residencia' THEN (p->>'ano_ingresso_residencia')::smallint END,
          CASE WHEN v_sit = 'residencia' THEN v_term END,
          'pendente', now(), now())
  ON CONFLICT (pessoa_id) DO UPDATE SET
    celular = EXCLUDED.celular, situacao = EXCLUDED.situacao, semestre = EXCLUDED.semestre, ano_formatura = EXCLUDED.ano_formatura,
    faculdade = EXCLUDED.faculdade, especialidade = EXCLUDED.especialidade, especialidade_outra = EXCLUDED.especialidade_outra,
    instituicao_residencia = EXCLUDED.instituicao_residencia, ano_ingresso_residencia = EXCLUDED.ano_ingresso_residencia,
    termino_previsto = EXCLUDED.termino_previsto, atualizado_em = now(), confirmado_em = now(),
    status = CASE WHEN app.ficha_aluno.status = 'aprovado' THEN 'aprovado' ELSE 'pendente' END,
    enviado_em = CASE WHEN app.ficha_aluno.status = 'aprovado' THEN app.ficha_aluno.enviado_em ELSE now() END;

  -- aceites: grava so o que mudou
  FOR t IN SELECT codigo, versao FROM app.termo WHERE vigente LOOP
    IF p->'aceites' ? t.codigo AND (p->'aceites'->>t.codigo)::boolean IS DISTINCT FROM app.aceite_vigente(v_id, t.codigo)
       OR (p->'aceites' ? t.codigo AND NOT EXISTS (SELECT 1 FROM app.aceite_termo a WHERE a.pessoa_id = v_id AND a.codigo = t.codigo AND a.versao = t.versao)) THEN
      INSERT INTO app.aceite_termo (pessoa_id, codigo, versao, aceito, ip, user_agent)
      VALUES (v_id, t.codigo, t.versao, (p->'aceites'->>t.codigo)::boolean, p_ip, left(p_ua, 300));
    END IF;
  END LOOP;

  UPDATE app.ficha_aluno SET confirmado_em = now() WHERE pessoa_id = v_id;

  -- aprovacao automatica (dominio ou e-mail cadastrado pela coordenacao)
  IF v_novo AND app.aprovacao_automatica((SELECT email_primario::text FROM app.pessoa WHERE pessoa_id = v_id)) THEN
    UPDATE app.ficha_aluno SET status = 'aprovado', decidido_em = now(), motivo_status = 'aprovação automática' WHERE pessoa_id = v_id;
    PERFORM app.atualizar_posicao(v_id);
    INSERT INTO app.notificacao_saida (inscricao_pessoa_id, pessoa_id, canal, destino, assunto, corpo, parametros)
    SELECT v_id, v_id, 'email', p2.email_primario::text, 'Inscrição aprovada — Programa de Cirurgia de Urgência e Trauma',
           'Sua inscrição foi aprovada. Você já pode acessar o calendário, os temas e os testes.',
           jsonb_build_object('caminho', '/aluno', 'rotulo_link', 'Abrir o curso',
                              'rodape', 'Você recebe esta mensagem porque se inscreveu no Programa de Cirurgia de Urgência e Trauma.')
      FROM app.pessoa p2 WHERE p2.pessoa_id = v_id;
    v_novo := false;
  END IF;

  -- se ja aprovado, mantem ano/especialidade em dia
  IF v_status = 'aprovado' THEN PERFORM app.atualizar_posicao(v_id); END IF;

  -- aviso aos curadores na primeira vez (ou reenvio apos recusa)
  IF v_novo THEN
    INSERT INTO app.notificacao_saida (inscricao_pessoa_id, pessoa_id, canal, destino, assunto, corpo, parametros)
    SELECT v_id, d.pessoa_id, 'email', pc.email_primario::text,
           'Nova inscrição no curso: ' || left(trim(p->>'nome'), 80),
           left(trim(p->>'nome'), 200) || ' (' || (SELECT email_primario::text FROM app.pessoa WHERE pessoa_id = v_id) || ') enviou a ficha de inscrição'
             || CASE v_sit WHEN 'graduacao' THEN ' — graduação, ' || (p->>'semestre') || 'º semestre.'
                           WHEN 'residencia' THEN ' — residência em ' || app.rotulo_especialidade(p->>'especialidade', p->>'especialidade_outra')
                                                || ', ingresso em ' || (p->>'ano_ingresso_residencia') || '.'
                           ELSE ' — médico formado em ' || (p->>'ano_formatura') || '.' END
             || E'\n\nAprove ou recuse pelo aplicativo, na tela Inscrições.',
           jsonb_build_object('caminho', '/curador/inscricoes', 'rotulo_link', 'Abrir inscrições',
                              'rodape', 'Você recebe este aviso por ser curador ou coordenador do Programa de Cirurgia de Urgência e Trauma.')
      FROM app.designacao d JOIN app.pessoa pc ON pc.pessoa_id = d.pessoa_id
     WHERE d.papel IN ('admin','curador') AND d.vigencia_inicio <= current_date
       AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= current_date);
  END IF;
  RETURN (SELECT status FROM app.ficha_aluno WHERE pessoa_id = v_id);
END $$;

-- Posicao anual (grau e especialidade) a partir da ficha aprovada.
CREATE OR REPLACE FUNCTION app.atualizar_posicao(p_pessoa BIGINT) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE f app.ficha_aluno; v_perfil SMALLINT;
BEGIN
  SELECT * INTO f FROM app.ficha_aluno WHERE pessoa_id = p_pessoa;
  IF f.pessoa_id IS NULL OR f.status <> 'aprovado' THEN RETURN; END IF;
  SELECT perfil_id INTO v_perfil FROM app.perfil WHERE codigo = 'aluno';
  UPDATE app.posicao_anual SET ativo = false WHERE pessoa_id = p_pessoa AND ano_letivo <> extract(year FROM current_date)::smallint AND ativo;
  INSERT INTO app.posicao_anual (pessoa_id, perfil_id, ano_letivo, grau, ativo, especialidade)
  VALUES (p_pessoa, v_perfil, extract(year FROM current_date)::smallint, app.grau_da_ficha(f), true,
          app.rotulo_especialidade(f.especialidade, f.especialidade_outra))
  ON CONFLICT (pessoa_id, ano_letivo, perfil_id) DO UPDATE SET grau = EXCLUDED.grau, especialidade = EXCLUDED.especialidade, ativo = true;
END $$;

-- Inscricoes para a coordenacao.
CREATE OR REPLACE FUNCTION app.inscricoes(p_status TEXT DEFAULT 'pendente') RETURNS JSONB
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'pessoa_id', p.pessoa_id, 'nome', p.nome_completo, 'email', p.email_primario::text, 'data_nascimento', p.data_nascimento,
           'ficha', to_jsonb(f) - 'pessoa_id', 'grau', app.grau_da_ficha(f),
           'especialidade_rotulo', app.rotulo_especialidade(f.especialidade, f.especialidade_outra),
           'decidido_por_nome', (SELECT nome_completo FROM app.pessoa WHERE pessoa_id = f.decidido_por),
           'termos', (SELECT jsonb_object_agg(t.codigo, app.aceite_vigente(p.pessoa_id, t.codigo)) FROM app.termo t WHERE t.vigente))
         ORDER BY f.enviado_em DESC NULLS LAST), '[]'::jsonb)
    FROM app.ficha_aluno f JOIN app.pessoa p ON p.pessoa_id = f.pessoa_id
   WHERE app.eh_revisor() AND (p_status = 'todas' OR f.status = p_status) $$;

CREATE OR REPLACE FUNCTION app.decidir_inscricao(p_pessoa BIGINT, p_aprovar BOOLEAN, p_motivo TEXT) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
DECLARE v TEXT;
BEGIN
  IF NOT app.eh_revisor() THEN RAISE EXCEPTION 'proibido'; END IF;
  UPDATE app.ficha_aluno SET status = CASE WHEN p_aprovar THEN 'aprovado' ELSE 'recusado' END,
         motivo_status = left(nullif(trim(coalesce(p_motivo, '')), ''), 1000),
         decidido_por = app.pessoa_atual(), decidido_em = now(), atualizado_em = now()
   WHERE pessoa_id = p_pessoa AND status IN ('pendente','recusado','aprovado') RETURNING status INTO v;
  IF v IS NULL THEN RAISE EXCEPTION 'inscricao_nao_encontrada'; END IF;
  IF p_aprovar THEN PERFORM app.atualizar_posicao(p_pessoa); END IF;
  INSERT INTO app.notificacao_saida (inscricao_pessoa_id, pessoa_id, canal, destino, assunto, corpo, parametros)
  SELECT p_pessoa, p_pessoa, 'email', p.email_primario::text,
         CASE WHEN p_aprovar THEN 'Inscrição aprovada — Programa de Cirurgia de Urgência e Trauma'
              ELSE 'Inscrição não aprovada — Programa de Cirurgia de Urgência e Trauma' END,
         CASE WHEN p_aprovar THEN 'Sua inscrição foi aprovada. Você já pode acessar o calendário, os temas e os testes.'
              ELSE 'Sua inscrição não foi aprovada' || coalesce(': ' || nullif(trim(p_motivo), ''), '.')
                   || ' Você pode corrigir a ficha e enviar de novo.' END,
         jsonb_build_object('caminho', CASE WHEN p_aprovar THEN '/aluno' ELSE '/cadastro' END, 'rotulo_link', 'Abrir o curso',
                            'rodape', 'Você recebe esta mensagem porque se inscreveu no Programa de Cirurgia de Urgência e Trauma.')
    FROM app.pessoa p WHERE p.pessoa_id = p_pessoa;
  RETURN v;
END $$;

-- Textos vigentes para as paginas publicas (/privacidade, /termos, /pesquisa), sem login.
CREATE OR REPLACE FUNCTION app.termos_publicos()
RETURNS TABLE (codigo TEXT, versao TEXT, titulo TEXT, resumo TEXT, texto TEXT, obrigatorio BOOLEAN, desde TIMESTAMPTZ)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT t.codigo, t.versao, t.titulo, t.resumo, t.texto, t.obrigatorio, t.criado_em FROM app.termo t WHERE t.vigente
   ORDER BY array_position(ARRAY['uso','privacidade','pesquisa','divulgacao'], t.codigo) $$;
GRANT EXECUTE ON FUNCTION app.termos_publicos() TO api_rw;

REVOKE EXECUTE ON FUNCTION app.aceite_vigente(BIGINT, TEXT), app.minha_ficha(), app.salvar_ficha(JSONB, INET, TEXT),
  app.atualizar_posicao(BIGINT), app.inscricoes(TEXT), app.decidir_inscricao(BIGINT, BOOLEAN, TEXT), app.cadastro_ok() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.minha_ficha(), app.salvar_ficha(JSONB, INET, TEXT), app.inscricoes(TEXT),
  app.decidir_inscricao(BIGINT, BOOLEAN, TEXT), app.cadastro_ok() TO api_rw;

-- TCLE de pesquisa tambem alimenta app.consentimento_pesquisa (usada nas views do schema pesquisa).
CREATE OR REPLACE FUNCTION app.fn_aceite_pesquisa() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, app AS $$
BEGIN
  IF NEW.codigo = 'pesquisa' THEN
    INSERT INTO app.consentimento_pesquisa (pessoa_id, aceito, versao_tcle, em) VALUES (NEW.pessoa_id, NEW.aceito, NEW.versao, NEW.em)
    ON CONFLICT (pessoa_id) DO UPDATE SET aceito = EXCLUDED.aceito, versao_tcle = EXCLUDED.versao_tcle, em = EXCLUDED.em;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS tg_aceite_pesquisa ON app.aceite_termo;
CREATE TRIGGER tg_aceite_pesquisa AFTER INSERT ON app.aceite_termo FOR EACH ROW EXECUTE FUNCTION app.fn_aceite_pesquisa();

-- Painel: turma e especialidade vem da ficha quando existir.
CREATE OR REPLACE FUNCTION app.perfil_aluno(p_pessoa BIGINT, OUT ano TEXT, OUT especialidade TEXT, OUT turma SMALLINT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog, public, app AS $$
  SELECT (SELECT x.grau::text FROM app.posicao_anual x WHERE x.pessoa_id = p_pessoa AND x.ativo ORDER BY x.ano_letivo DESC LIMIT 1),
         coalesce((SELECT app.rotulo_especialidade(f.especialidade, f.especialidade_outra) FROM app.ficha_aluno f WHERE f.pessoa_id = p_pessoa),
                  (SELECT x.especialidade FROM app.posicao_anual x WHERE x.pessoa_id = p_pessoa AND x.especialidade IS NOT NULL ORDER BY x.ano_letivo DESC LIMIT 1)),
         coalesce((SELECT f.ano_ingresso_residencia FROM app.ficha_aluno f WHERE f.pessoa_id = p_pessoa),
                  (SELECT min(x.ano_letivo) FROM app.posicao_anual x WHERE x.pessoa_id = p_pessoa)) $$;

-- Usuarios de teste do ambiente local (@setup.local) e alunos ja existentes sem ficha: ficha aprovada e termos aceitos,
-- para nao travar quem ja usa. (Alunos reais novos passam pelo fluxo normal.)
INSERT INTO app.ficha_aluno (pessoa_id, situacao, status, decidido_em, enviado_em)
SELECT p.pessoa_id, 'residencia', 'aprovado', now(), now() FROM app.pessoa p
 WHERE p.email_primario::text LIKE '%@setup.local'
   AND NOT EXISTS (SELECT 1 FROM app.designacao d WHERE d.pessoa_id = p.pessoa_id)
ON CONFLICT (pessoa_id) DO NOTHING;
INSERT INTO app.aceite_termo (pessoa_id, codigo, versao, aceito)
SELECT f.pessoa_id, t.codigo, t.versao, true FROM app.ficha_aluno f JOIN app.pessoa p USING (pessoa_id), app.termo t
 WHERE p.email_primario::text LIKE '%@setup.local' AND t.vigente AND t.obrigatorio
   AND NOT app.aceite_vigente(f.pessoa_id, t.codigo);

COMMIT;
\echo 'cadastro do aluno, termos e inscricoes: prontos (os textos dos termos sao minutas)'
