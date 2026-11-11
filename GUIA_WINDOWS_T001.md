# Rodar o T001 no Windows (via WSL)

Testado: a ordem de instalacao abaixo roda sem erro num PostgreSQL 16 vazio (banco, 75 fontes do T001 e 12 jobs).
Ainda nao testado: a chamada real ao modelo e a verificacao no PubMed (precisam das suas chaves e de internet).

## 1. Instalar o WSL (uma vez)
PowerShell **como administrador**: `wsl --install -d Ubuntu-24.04`. Reinicie, abra "Ubuntu" no menu Iniciar e crie usuario/senha.

## 2. Instalar as ferramentas (no Ubuntu)
```
sudo apt update
sudo apt install -y postgresql postgresql-client poppler-utils python3 git unzip curl
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
sudo service postgresql start
```

## 3. Copiar o projeto e as fontes para dentro do Ubuntu
No Windows, suas pastas ficam em `/mnt/c/Users/SEU_USUARIO/...`. Exemplo:
```
cp -r /mnt/c/Users/SEU_USUARIO/CAMINHO/Curso-UE ~/Curso-UE
mkdir -p ~/fontes_zip && unzip /mnt/c/Users/SEU_USUARIO/Downloads/T001_fontes.zip -d ~/fontes_zip
```
(o zip cria `~/fontes_zip/T001/`). Confira: `ls ~/fontes_zip/T001 | head`.

## 4. Criar o banco e instalar (uma vez)
```
cd ~/Curso-UE
sudo -u postgres createdb programa
export PGUSER=postgres PGHOST=/var/run/postgresql   # se pedir senha, use: sudo -u postgres psql ...
for f in 01_instalar_v4.4_linhas 03_setup_minimo_v4.3_linhas 04_setup_resposta_e_pesquisa_v4.3.sql 05_setup_preceptor_e_curador_v4.4.sql 12_setup_conteudo_minimo_v4.4.sql 13_setup_pesquisador_v4.4.sql 16_setup_prompts_fase_v4.4.sql 18_setup_skills_v4.4.sql 19_setup_design_tokens_v4.4.sql 20_agendador_gatilhos_v4.4.sql 22_correcao_maestro_job_e_role_v4.5.sql 23_correcao_defeitos_v4.6.sql; do
  sudo -u postgres psql -d programa -v ON_ERROR_STOP=1 -q -f $f || break
done
sudo -u postgres psql -d programa -v ON_ERROR_STOP=1 -q -v api_pw=TROQUE1 -v maestro_pw=TROQUE2 -v metabase_pw=TROQUE3 -f 27_correcoes_seguranca_v1.0.sql
sudo -u postgres psql -d programa -v ON_ERROR_STOP=1 -q -f 28_texto_integral_fontes_v1.0.sql
sudo -u postgres psql -d programa -v ON_ERROR_STOP=1 -q -f 29_carga_fontes_v1.0.sql
bash 06_scaffolding_v1.0.sh ./programa-cut && bash 17_scaffolding_executor_v1.0.sh ./programa-cut && bash 22b_patch_executor_v1.1.sh ./programa-cut
```
Troque `TROQUE1/2/3` por senhas suas (anote a do `maestro_pw`).

## 5. Variaveis e execucao (so no terminal)
```
export ANTHROPIC_API_KEY="..."        # chave nova
export ANTHROPIC_MODEL="claude-sonnet-5-5"
export NCBI_API_KEY="..."             # opcional
export MAESTRO_DATABASE_URL="postgres://maestro_rw:TROQUE2@localhost:5432/programa"
export DATABASE_URL="postgres://postgres@/programa?host=/var/run/postgresql"
bash rodar_T001_v1.0.sh ./programa-cut ~/fontes_zip 45
```
Se o `psql` do passo 5 pedir senha do usuario `postgres`, rode como: `sudo -u postgres psql ...` ou defina uma senha para ele.
Para `localhost:5432` aceitar o `maestro_rw` com senha, o `pg_hba.conf` do Ubuntu normalmente ja usa `scram-sha-256` para 127.0.0.1.
