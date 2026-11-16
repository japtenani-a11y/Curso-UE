# Áudio do podcast de cada tema

O aplicativo mostra um player acima do roteiro na peça "Podcast" quando existe o arquivo
`~/Curso-UE/programa-cut/podcast/<CODIGO>.mp3` (exemplo: `T001.mp3`). Sem o arquivo, o aluno vê o aviso
"O áudio deste episódio ainda não está pronto" e lê o roteiro. O áudio só toca para quem entrou no aplicativo e já tem o
tema liberado até o pré-aula. Os áudios não vão para o GitHub.

Há dois caminhos. Pode usar um, outro ou os dois.

## Caminho 1: gravar ou gerar fora e copiar o arquivo

Grave o episódio, ou gere o áudio em outra ferramenta (por exemplo, a visão geral em áudio do NotebookLM a partir do
roteiro). Salve como MP3 com o código do tema, sem hífen, e copie para a pasta:

```bash
mkdir -p ~/Curso-UE/programa-cut/podcast
cp /mnt/c/Users/japt7/Downloads/T001.mp3 ~/Curso-UE/programa-cut/podcast/T001.mp3
```

Não é preciso reiniciar nada: o player aparece na próxima vez que a peça for aberta.

## Caminho 2: gerar automaticamente a partir do roteiro (Google Cloud Text-to-Speech)

O script `gerar_podcast_audio_v1.0.py` lê o roteiro publicado no banco e gera o áudio com duas vozes, uma para cada
personagem (PRECEPTOR e RESIDENTE). Ele usa as linhas que começam com `**PRECEPTOR:**` e `**RESIDENTE:**`, e retira os
códigos de fonte ([A1], [D2]) e as marcas de formatação.

### Uma vez só: chave da API

1. No console do Google Cloud (o mesmo projeto do login), abra **APIs e serviços → Biblioteca**, procure
   **Cloud Text-to-Speech API** e clique em **Ativar**. A API exige conta de faturamento ativa no projeto.
2. Em **APIs e serviços → Credenciais → Criar credenciais → Chave de API**. Depois, em **Restringir chave**, marque só a
   Cloud Text-to-Speech API.
3. No WSL, guarde a chave fora da pasta do projeto. O comando abaixo pede que você cole a chave, e ela não aparece na tela:

```bash
mkdir -p ~/.config/curso-ue && read -rsp "Cole a chave e tecle Enter: " K && echo "GOOGLE_TTS_KEY=$K" > ~/.config/curso-ue/tts.env && chmod 600 ~/.config/curso-ue/tts.env && unset K && echo " ok"
```

Não envie essa chave por e-mail, nem na conversa, nem no GitHub.

### Para gerar

Com o aplicativo instalado e o banco no ar, dentro de `~/Curso-UE`:

```bash
python3 gerar_podcast_audio_v1.0.py T001 --so-texto     # confere o texto que será falado (não gasta nada)
python3 gerar_podcast_audio_v1.0.py T001 --rascunho     # gera T001_rascunho.mp3 para ouvir antes de publicar
python3 gerar_podcast_audio_v1.0.py T001                # gera T001.mp3 a partir do roteiro publicado
python3 gerar_podcast_audio_v1.0.py --todos             # todos os temas com roteiro publicado e ainda sem áudio
```

Se o banco não estiver na porta padrão, ponha antes `PGPORT=5433` (a mesma porta que o subir usa).

As vozes padrão são `pt-BR-Neural2-B` (preceptor) e `pt-BR-Neural2-C` (residente). Para trocar, acrescente ao
`~/.config/curso-ue/tts.env` as linhas `VOZ_PRECEPTOR=...` e `VOZ_RESIDENTE=...`.

**Custo.** Cada roteiro tem de 6 mil a 9 mil caracteres. A cota gratuita das vozes Neural2 é de 1 milhão de caracteres por
mês, então cerca de 100 episódios por mês saem sem custo. Confira o preço vigente na página da Cloud Text-to-Speech antes
de gerar os 150 temas.

**Revisão.** O áudio repete o roteiro como ele está. Corrija o roteiro e publique antes de gerar. O roteiro do T001 ainda
fala "Programa de Cirurgia de Urgência e Trauma" e precisa passar para "CUT".
