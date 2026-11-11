-- 29: colunas de rastreio das fontes carregadas do Drive
BEGIN;
ALTER TABLE conteudo.fonte ADD COLUMN IF NOT EXISTS texto_integral TEXT;
ALTER TABLE conteudo.fonte ADD COLUMN IF NOT EXISTS arquivo_origem TEXT;
ALTER TABLE conteudo.fonte ADD COLUMN IF NOT EXISTS sha256 TEXT;
ALTER TABLE conteudo.fonte ADD COLUMN IF NOT EXISTS camada_confirmada BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE conteudo.fonte ADD COLUMN IF NOT EXISTS tema_confirmado BOOLEAN NOT NULL DEFAULT false;
CREATE UNIQUE INDEX IF NOT EXISTS uq_fonte_tema_sha ON conteudo.fonte (tema_id, sha256) WHERE sha256 IS NOT NULL;
COMMIT;
