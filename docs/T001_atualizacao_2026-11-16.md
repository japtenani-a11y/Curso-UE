# T001 · Atualização de 16/11/2026

Nova versão de todo o material do T001, em rascunho, na pasta `conteudo/T001/` (formato do importador).

## O que mudou

| Peça | Mudança |
|---|---|
| Objetivos | Um objetivo de aula por perfil (técnica e anatomia); citações das fontes novas |
| Resumo básico | Consenso de 2025 (circulação antes da via aérea invasiva), tamponamento, pulsos, instável não vai à TC |
| Podcast | Trecho novo sobre o consenso e o REACT-2 |
| Caso base | Duas perguntas novas (posição do torniquete; intubar ou não) |
| Síntese de evidência | Camadas 3 e 5 agora com fonte; disputa CAB contra ABC; REACT-2; seção "O que mata na sala de trauma" |
| Mapa | Ramos novos: ordem, erros que matam |
| Aula (texto) | Reescrita: não repete a teoria. Oito seções de decisão, técnica e anatomia |
| Slides | Reescritos: 15 slides com fala, sobre o caso, hemorragia externa, torniquete, pelve, acesso, tórax, via aérea cirúrgica, destino e erro |
| Caso da aula | Novo: fratura de pelve em choque, com seis pontos de decisão |
| Resumo executivo, checklist, flashcards | Atualizados com a técnica da aula |
| Protocolo | Passos de hemorragia, via aérea e circulação detalhados; protocolo de transfusão maciça do Hospital de Base; indicadores |

## Fontes

- 59 afirmações novas, cada uma com o trecho literal conferido no texto da fonte: 163 no total.
- Diretriz e consenso (G1 a G11): WSES-PTS 2025, protocolo AAST/ACS-COT de ressuscitação de controle de danos, indicadores da WSES.
- Artigos (A48 a A56): REACT-2, Gruen 2006, Teixeira 2007, Tignanelli 2018, Demetriades 2004.
- Livro-texto (D42 a D75): Mattox 9ª ed., capítulos 10, 13, 14, 18, 28, 39 e 45; manual do European Trauma Course, capítulo 1.
- Protocolo e ficha do serviço (P16 a P21): transfusão maciça do Hospital de Base; ficha da sala de trauma.

## Questões

- 193 questões: as 170 anteriores, 20 novas sobre o conteúdo da aula (uma por perfil nos testes 3 a 6) e 3 âncoras.
- Alternativas reescritas para ficarem de tamanho parecido. A correta era a mais longa em 87% das questões e, em média, 2,75 vezes maior que as erradas; agora é a mais longa em 20% (o esperado ao acaso) e 1,14 vez maior.
- O sentido de cada alternativa foi mantido, para as justificativas continuarem válidas. As alternativas reescritas precisam da leitura de um revisor.

## Como gravar

```
cd ~/Curso-UE
bash fontes_do_tema_v1.0.sh T001 SENHA
bash importar_tema_v1.0.sh T001 SENHA
bash importar_tema_v1.0.sh T001 SENHA --aplicar
```

As peças entram em rascunho, como versão nova. O que está publicado continua valendo até a revisão e a publicação.

## Depois de gravar

**Aproveitar os pareceres e limpar as questões de exemplo** (`94_aproveitar_pareceres_v1.0.sql`):

```
PGPASSWORD=SENHA psql -h localhost -U postgres -d programa -v tema=T001 -f 94_aproveitar_pareceres_v1.0.sql
```

- Copia cada parecer já dado nas versões anteriores para a afirmação idêntica (mesmo texto e mesma fonte) da versão nova, em nome do mesmo revisor. Sobram para revisar só as afirmações novas ou alteradas.
- Remove as questões de exemplo da instalação ("Item 1: qual a conduta inicial..."), se nunca foram respondidas.

**Imagens dos slides novos.** O baralho visual dos 15 slides está em `conteudo/T001/slides/imagens_v3/` (gerado por `ferramentas/T001/gerar_deck_v3.py`). Os slides 3, 6, 8 e 12 têm esquemas (pulsos e pressão, posição do torniquete, cinta pélvica, membrana cricotireóidea). As imagens só vão para o aplicativo depois de a peça de slides nova ser publicada, porque o número de cada imagem precisa bater com o slide:

```
mkdir -p ~/Curso-UE/programa-cut/slides/T001
rm -f ~/Curso-UE/programa-cut/slides/T001/slide_*.png
cp ~/Curso-UE/conteudo/T001/slides/imagens_v3/slide_*.png ~/Curso-UE/programa-cut/slides/T001/
```

**Áudio do podcast e das falas dos slides** (precisa da chave do Google em `~/.config/curso-ue/tts.env`; ver `docs/podcast_audio.md`):

```
python3 gerar_podcast_audio_v1.0.py T001 --rascunho            # ouvir antes de publicar (T001_rascunho.mp3)
python3 gerar_podcast_audio_v1.0.py T001 --slides --rascunho   # falas dos slides, para conferir
```

Depois de publicar o roteiro e os slides, gerar as versões que o aplicativo mostra:

```
python3 gerar_podcast_audio_v1.0.py T001
python3 gerar_podcast_audio_v1.0.py T001 --slides
```

## Pendências para a revisão

- Os trechos do Mattox não são conferidos pelo importador (o livro não está no banco): o revisor confere no capítulo.
- A extrapolação do consenso de 2025 ao trauma fechado com possível TCE está marcada no caso da aula como ponto de cautela.
- Gruen 2006 e Teixeira 2007 têm mais de dez anos.

## Correções depois da auditoria de 16/11 (CUT_v2z7)

- **Vetos da coordenação:**
  - A39 (TC de corpo inteiro no choque) e A5 (tamanho do ensaio ADVANCE TRAUMA) saíram do material e das questões. A questão T3-R3-2 foi trocada por uma sobre os critérios de pan-TC do protocolo [P2].
  - Torniquete (A23, A24) passou a controvérsia, com a segunda meta-análise (Ko 2024, A57 e A58; PMID 38504263).
  - Hemotórax (D68): o critério de volume vale para o paciente estável; no instável, decide a clínica [D26, P9].
  - P5: os critérios completos de TCE moderado a grave do protocolo de imagem.
- **Erros leves corrigidos no texto das peças:** A11, A18, A22, A32, D44, D46, D75, P13.
- **Pré-revisões "ajustar" aplicadas:**
  - Aula: indutor e dose no choque [D78, D79], janelas abdominais do FAST [D80], passos e material da cricotireoidostomia [D76, D77], atividade do R+ sobre o minuto do erro, menos repetição da teoria. A técnica da drenagem e os marcos do intraósseo foram remetidos aos temas T-013 e T-081.
  - Caso da aula: 4 pontos em 15 minutos, dicas sem a resposta, supervisão à distância.
  - Caso base: 25 minutos, sinais de choque, perguntas sobre cinta, exposição e AMPLA, e "Onde está a resposta".
  - Checklist: itens de uma ação só, MIST, Glasgow ≤8, reavaliação e avaliação secundária.
  - Flashcards: 4 cartões de evidência (R+) e o resto de conduta.
  - Banco de questões: refeito a partir das questões atuais (contagem por teste, faixas sem sobreposição, sem "ATLS vigente").
- **Publicar** tira a faixa "RASCUNHO" do início dos testes e gabaritos (97).
- **Script 94** aproveita os pareceres de qualquer versão anterior, inclusive rascunho, para as afirmações idênticas da versão nova.
- **Slides:** 6 (torniquete) e 11 (tórax) com as fontes novas; imagens refeitas.

Instalar: unzip; subir; `bash importar_tema_v1.0.sh T001 SENHA` (confere) e `--aplicar`; depois
`PGPASSWORD=SENHA psql -h localhost -U postgres -d programa -v tema=T001 -f 94_aproveitar_pareceres_v1.0.sql`.
Os agentes revisam só os textos novos ou alterados. O áudio do podcast precisa ser gerado de novo.

## Banco de questões e peças depois da pré-revisão (CUT_v2z8)

Este pacote inclui tudo da v2z7. Quem ainda não instalou a v2z7 instala só este.

- **Questões (questoes.json), 169 de 193 reescritas:**
  - as alternativas absurdas ("Nada", "Nenhum", "Zero", "Esperar", "Punição", "Endoscopia") viraram erros plausíveis;
  - toda alternativa, certa ou errada, tem explicação de uma ou duas frases com o código da fonte, e as âncoras de cada questão são os códigos citados;
  - a letra da correta foi embaralhada para ficar equilibrada dentro de cada teste e perfil (antes, havia testes com a mesma letra em 6 de 10 questões e perfis sem nenhuma resposta E);
  - T5-Graduação-4, que repetia a T5-Graduação-1, virou uma questão sobre o reexame completo [D18, D19, D30];
  - T4-R2-5 citava uma concordância com a TC que não está nas fontes; passou a perguntar a proporção de alargamento da sínfise [A35];
  - saíram números sem fonte em três questões (T5-R+-7, T5-R3-7 e T6-R+-7).
- **Gabaritos:** o importador não repete mais "Correta:" depois de "correta".
- **Objetivos:** cada objetivo agora tem condição e critério.
- **Síntese de evidência:** saiu a marcação interna sobre o ATLS 11, cada item da disputa mostra o desenho do estudo, e o tempo de leitura bate com o do sistema.
- **Resumo, resumo básico e protocolo:**
  - tempo de leitura corrigido (6, 5 e o calculado pelo sistema);
  - FAST negativo no hipotenso com trauma fechado: repetir ou aspirar [D63];
  - escores de transfusão maciça: "por ora, a experiência provavelmente decide melhor" [D34];
  - a frase sem fonte sobre murmúrio ausente saiu do resumo básico;
  - as referências do protocolo passam a listar G4, G6 e G11.
- **Aula e checklist:** a mesma correção do FAST [D63].
- **Importação:** ao gravar, as pré-revisões que esperam decisão sobre uma versão antiga da mesma peça passam a "substituída", com o motivo registrado. Não são vetadas, porque veto vira regra para o agente. Os pareceres de conteúdo continuam valendo e são copiados pelo script 94.

Instalar como na v2z7: unzip; subir; `bash importar_tema_v1.0.sh T001 SENHA` (confere) e `--aplicar`; depois o script 94.
