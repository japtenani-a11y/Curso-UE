# CUT · Produção de um tema: pasta padrão e importador

Versão 1.0 · 16/11/2026 · `importar_tema_v1.0.sh` e `ferramentas/importar_tema.py`

## O fluxo

0. **Fontes já guardadas.**
   - A coordenação solta os PDFs, a qualquer momento, em `CUT_coordenacao\fontes_novas`.
   - O triador de fontes indica todos os temas em que cada um serve, mesmo os que ainda não foram produzidos. Aprovada a triagem, a fonte fica guardada nesses temas.
   - Antes de produzir, rode `bash fontes_do_tema_v1.0.sh T002 SENHA`. O comando traz para `conteudo/T002/fontes_banco/` o texto de cada fonte e o catálogo `fontes_banco.csv`, com o código para citar (F... ou AAAA_NN).
   - O importador reconhece essas fontes e não as carrega de novo.
1. **Busca e seleção das fontes.**
   - O Claude faz a busca completa: PubMed, diretrizes e livros-texto, nas cinco camadas.
   - A coordenação acrescenta a sua seleção de artigos, com o texto integral (PDF), como no T001.
   - Os dois conjuntos vão para `fontes/`.
2. **Produção.** O Claude escreve as peças, as afirmações e as questões na pasta do tema, no formato abaixo (skill `producao-de-tema-ue-trauma`).
   - O material de antes da aula é a fonte teórica. A aula (texto, slides e caso) não repete essa teoria: aprofunda em discussão de caso clínico, técnica cirúrgica e anatomia cirúrgica (`docs/formato_das_pecas.md`, "O que cada momento ensina").
3. **Conferência.** Rode `bash importar_tema_v1.0.sh T002 SENHA`. Ela confere tudo sem gravar nada e lista erros e avisos.
4. **Gravação.** Rode `bash importar_tema_v1.0.sh T002 SENHA --aplicar`.
   - As peças entram em rascunho, com as afirmações e o trecho da fonte de cada uma.
   - As fontes entram com o texto integral.
   - Entram também os casos dos testes, as questões e as âncoras.
   - Os testes e os gabaritos são gerados a partir das questões.
5. **Revisão.**
   - Os agentes de pré-revisão e de conteúdo começam na manhã seguinte.
   - Os cirurgiões revisores dão os pareceres. Cada texto de afirmação é revisado uma vez, e o parecer vale para todas as peças em que ele aparece.
6. **Publicação** pela tela de revisão, dentro dos prazos.

## Prazos (contados a partir da aula)

| Etapa | Prazo |
|---|---|
| Produção pronta: todas as peças, testes e gabaritos em rascunho | 6 semanas antes da aula |
| Revisão concluída e tudo publicado | 3 semanas antes da aula |
| Pré-teste 1 abre para os alunos | 15 dias antes da aula |

A aba "Prazos de produção" do painel mostra a situação de cada tema, e o supervisor dos agentes avisa todo dia o tema que está atrasado.

## A pasta do tema: `conteudo/T002/`

```
conteudo/T002/
  pecas/            uma peça por arquivo, no formato fixo (docs/formato_das_pecas.md)
    objetivos.md  resumo_basico.md  podcast_roteiro.md  caso_base.md  sintese_evidencia.md  mapa.md
    aula.md  slides.md  caso.md  resumo.md  protocolo.md  checklist.md  flashcard.md
    simulado.md   banco_dificuldade.md      (opcionais)
  afirmacoes.csv    as afirmações que as peças citam como [A1], [D3]...
  fontes.csv        o catálogo das fontes
  fontes/           os PDFs (os da busca e os da seleção da coordenação)
  casos_teste.json  o caso de cada um dos 6 testes
  questoes.json     todas as questões, com as âncoras
```

### afirmacoes.csv (separador `;`)

| Coluna | O que é |
|---|---|
| codigo | A1, A2... (artigo); D1... (livro-texto); P1... (protocolo); H1... (histórico); G1... (diretriz) |
| texto | O que a peça afirma, em português |
| fonte_arquivo | O pedaço do nome do arquivo da fonte que a identifica, como `2024_01` para `T002_2024_01_titulo.pdf`. Para livro, um identificador como `Mattox9_cap12`. |
| trecho_literal | O trecho exato da fonte, na língua original, que sustenta a afirmação |

Cada peça recebe as afirmações que cita no texto. Cada teste e cada gabarito recebem as âncoras das suas questões.

### fontes.csv (separador `;`)

`arquivo;titulo;autores;ano;doi;pmid;camada`

- **arquivo:** o nome do arquivo em `fontes/`, sempre começando por `T002_AAAA_NN_`. Fica vazio para um livro sem PDF.
- **camada:**
  - 1: histórico;
  - 2: livro-texto;
  - 3: protocolo institucional;
  - 4: literatura dos últimos 10 anos;
  - 5: diretriz.

A seleção da coordenação entra aqui do mesmo jeito: basta pôr o PDF em `fontes/` e uma linha no `fontes.csv`.

Uma fonte que o triador guardou em outro tema pode ser citada pelo código (F e oito letras) em `fonte_arquivo`: ao gravar, o importador a guarda também neste tema.

O ATLS 11 não entra como fonte com texto: é citado só pela seção.

Nunca coloque nesta pasta arquivo com dado de paciente.

### casos_teste.json

```json
{"1": {"titulo": "Caso 1", "texto": "Mulher de 45 anos..."}, "2": {...}, ..., "6": {...}}
```

### questoes.json

```json
[
 {"id": "FIXA-1", "fixa": true, "grau": 2, "enunciado": "...",
  "alternativas": ["...", "...", "...", "...", "..."], "correta": "B",
  "justificativas": ["...", "...", "...", "...", "..."],
  "categorias": ["erro conceitual", "correta", "erro de conduta", "erro de indicação", "erro técnico"],
  "ancoras": ["A3", "D2"]},
 {"id": "T1-R1-1", "fixa": false, "perfil": "R1", "teste": 1, "grau": 2, "taxa_esperada": "75% a 90%", "...": "..."}
]
```

**Âncoras.**
- De 2 a 3 por tema (`"fixa": true`), sem perfil e sem teste.
- Aparecem nas seis ondas, para todos os anos.
- Recebem os códigos `T002-FIXA-1`, `T002-FIXA-2`...

**Demais questões.**
- Perfil: Graduação, R1, R2, R3 ou R+.
- Teste: de 1 a 6.
- Grau: de 1 a 6.
- Ao menos 4 questões por perfil em cada teste.

**Categorias.** Exatamente uma "correta". As outras quatro são "erro conceitual", "erro de conduta", "erro de indicação" ou "erro técnico".

**O que o importador recusa:**
- peça que falta ou fora do formato;
- questão sem 5 alternativas, ou com a letra correta que não bate com a categoria;
- tema sem nenhuma âncora;
- teste sem caso;
- fonte listada sem o arquivo.

**O que o importador avisa:**
- trecho literal que não está no texto da fonte;
- afirmação citada que não está no CSV;
- só 1 âncora;
- menos de 4 questões num perfil;
- a mesma letra correta em mais de 40% de um teste;
- a correta bem mais longa que as outras alternativas.

**Por que o tamanho da alternativa correta importa.** Quando a correta é sempre a mais longa, o aluno acerta sem saber, e o teste deixa de medir o que deveria. No banco atual do T001, a correta é a mais longa em 149 das 171 questões.

## O que não muda numa nova importação

- Uma peça igual à que já está no banco não vira versão nova.
- Uma questão que já tem resposta de aluno não é alterada.
- Nada é apagado.
- As questões novas entram nas ondas de teste que o tema já tem; as que já estavam não mudam de ordem.
