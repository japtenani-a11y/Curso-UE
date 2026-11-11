-- 28: texto integral das fontes (base dos verificadores de citacao literal e numero)
BEGIN;
ALTER TABLE conteudo.fonte ADD COLUMN IF NOT EXISTS texto_integral TEXT;
COMMENT ON COLUMN conteudo.fonte.texto_integral IS 'Texto extraido do PDF da fonte; os verificadores comparam citacoes contra ele';
COMMIT;
