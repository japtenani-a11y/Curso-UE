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
O Ubuntu enxerga o Windows em `/mnt/c/...`. Com o ZIP do projeto e o `T001_fontes.zip` em `C:\Users\japt7\Downloads`:
```
unzip -q /mnt/c/Users/japt7/Downloads/Curso-UE-executor-v2.zip -d ~
ls ~                       # veja o nome da pasta criada (ex.: Curso-UE-executor-v2)
cd ~/Curso-UE-executor-v2  # ajuste ao nome que apareceu
mkdir -p ~/fontes_zip && unzip -q /mnt/c/Users/japt7/Downloads/T001_fontes.zip -d ~/fontes_zip
ls ~/fontes_zip/T001 | head -3
```

## 4. Criar o banco e instalar (uma vez) — um unico comando
Dentro da pasta do projeto:
```
bash instalar_banco_wsl_v1.0.sh japt1992 ./programa-cut
```
(`japt1992` e a senha do banco local de teste; vale para postgres, api_rw, maestro_rw e metabase_ro.)
Se o arquivo `instalar_banco_wsl_v1.0.sh` nao existir na sua pasta, baixe de novo o ZIP da branch executor-v2 ou copie o arquivo enviado no chat para dentro dela.
Nao use `sudo -u postgres psql -f arquivo`: o usuario postgres nao le arquivos da sua pasta pessoal ("permission denied").

## 5. Variaveis e execucao (so no terminal)
```
export ANTHROPIC_API_KEY="..."        # chave nova
export ANTHROPIC_MODEL="claude-sonnet-5-5"
export NCBI_API_KEY="..."             # opcional
export MAESTRO_DATABASE_URL="postgresql://maestro_rw:japt1992@localhost:5432/programa"
export DATABASE_URL="postgresql://postgres:japt1992@localhost:5432/programa"
bash rodar_T001_v1.0.sh ./programa-cut ~/fontes_zip 45
```
