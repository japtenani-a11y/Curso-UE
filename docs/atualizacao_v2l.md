# Atualização v2l — árvore de temas, mural, presença, certificado, estudo dirigido e cópia de segurança

## Como instalar
1. Copie o zip `T001_v2l.zip` de Downloads para `~/Curso-UE` e descompacte por cima (`unzip -o`).
2. Rode `bash subir_api_pwa_wsl_v1.0.sh` como sempre. Ele aplica os SQL novos (65, 66, 68) e os scripts do app (67, 69).
3. Confira no fim: `arvore de temas: 150`, `mural do aluno: 200`, `estudo dirigido do aluno: 200`.
4. Apague à mão, se ainda existirem, os arquivos antigos `57_configurar_ia*`.

## O que entrou
- **Árvore de temas (65):** 178 relações mãe→filho. Um filho pode ter várias mães e uma mãe libera vários filhos.
  Há 8 temas órfãos (livres): T048, T058, T064, T065, T068, T069, T107, T112. Um tema bloqueado não abre e não
  pode ser agendado até as mães estarem concluídas (pós-teste D0 enviado). Telas: /aluno/arvore e o cadeado em Temas.
- **Mural (66):** avisos, documentos (até 10 MB) e questionários, com e-mail opcional aos alunos.
- **Presença (66):** código de 6 letras gerado na aula (vale até 30 min após o fim). O aluno cola o código ou o link
  em "Resgatar presença". O relatório do Meet (CSV) também conta: ≥ 50% dos 90 min já vale presença.
- **Certificado (66):** temas concluídos, horas e % de presença, com código de verificação pública.
- **Tela do preceptor, análise das questões, resumo semanal (segunda), e-mail de aniversário, aprovação automática por
  domínio ou lista, confirmação anual em março, ranking anônimo** (só o próprio nome aparece).
- **Estudo dirigido (68 + 69), em /aluno/estudo:**
  - *Simulado sob medida:* o aluno escolhe temas, faixa de dificuldade (ajustada ao ano dele) e número de questões.
    O sistema sorteia só entre questões de testes que ele **já enviou**, então nada de teste futuro vaza. Gabarito e
    justificativas aparecem na entrega. Não conta para nota nem ranking.
  - *Flashcards:* deck com os cards do curso (liberados depois da aula), os próprios e os dos colegas;
    "Eu sabia / Preciso rever" fica registrado e permite rever só os difíceis.
  - *Criar flashcard:* com a caixa de compartilhar marcada, o card vai **na hora, sem revisor**, para todos os
    participantes do tema, com o selo "Feito por aluno · nome" ou o apelido que o aluno escolher.
    A coordenação vê todos em /curador/flashcards e pode ocultar um card se houver erro grave.
  - O painel de dados ganhou o uso do estudo dirigido (`app.painel_estudo()`).

## Menus e telas iniciais revisados
- **Computador:** o menu cabe numa linha só. Ficam à vista os itens principais; o resto vai para **Mais ▾**.
- **Celular:** o topo ocupa uma linha (o Sair fica em "Mais"). A barra de baixo continua com os 3 atalhos principais.
- **Aluno:**
  - Resumo do progresso logo abaixo do "Olá" (temas concluídos, horas e presença).
  - O calendário vazio agora explica que as datas aparecem quando a coordenação publicar.
  - 8 entradas em grade: Temas, Estudo dirigido, Árvore, Desempenho, Presença, Dúvidas, Meus dados e Ajuda.
- **Coordenação (curador, admin e data steward):**
  - 8 indicadores: inscrições, dúvidas, revisão, alunos, alunos sem acesso há 14 dias, questões com alerta,
    flashcards dos alunos e respostas no mural.
  - Atalho para os flashcards dos alunos.
- **Preceptor:**
  - 4 indicadores: residentes, abaixo do esperado, com pendências e sem acesso.
  - Linhas em destaque na tabela; menu com Mural e Ajuda.
- **Pesquisador:** Ajuda no menu.

## 150 temas, árvore e produção
- **T136, T137 e T138 aprovados em 13/11/2026** (opcionais; pastas criadas no Drive, dentro do módulo de cada um):
  - T136 Trauma penetrante: balística, ferimento por arma branca e manejo não operatório seletivo
    (módulo Trauma abdominal, recomendado, grau 4). Mães: T001 e T021.
  - T137 Trauma no idoso e no paciente anticoagulado: queda da própria altura, reversão e limites de investimento
    (módulo Reanimação, recomendado, grau 3). Mães: T001 e T012.
  - T138 Trauma na gestante: prioridades maternas, avaliação fetal e cesárea perimortem
    (módulo Ginecologia e obstetrícia, opcional, grau 4). Mães: T001, T004 e T095.
- Árvore: 150 temas, 185 relações e 8 órfãos. Os 39 principais ficam iguais, portanto o calendário de quintas não muda.
- Buscas PubMed: arquivo único `BUSCAS_PUBMED_150_temas` (txt e pdf). As 147 linhas antigas foram mantidas sem mudança.
  As 3 novas foram validadas em 13/11/2026 (421, 847 e 3.697 registros).
- **Tema em produção:** o residente que abre um tema sem material publicado vê a tela "Conteúdo em produção", com:
  - o botão **Avise-me quando publicar**, que manda e-mail no dia;
  - os temas-mãe que ele já pode adiantar.

  Na lista de temas e na árvore, esses temas aparecem como "em produção".
- **Mural, espaço fixo "Temas novos no site":** quando um tema recebe a primeira peça publicada, o aviso sai sozinho.
- **Fila de produção:** fica em Dados → Fila de produção e no início da coordenação. A ordem é:
  1. os principais, pela data da aula;
  2. os opcionais, pela quantidade de alunos esperando (Avise-me e agendados);
  3. em seguida, pela quantidade de temas que cada um libera na árvore.
- **Síntese de evidência:** ganhou a 5ª seção "Sugestões de temas para trabalho científico/artigos", com 5 ideias
  (modelo do estudo + sugestão). O padrão para os próximos temas está em `docs/padrao_sintese_evidencia_v1.1.md`;
  o T001 recebeu a seção pelo `72`.
- Correção: rodar o `subir` de novo sobre uma instalação existente falhava no 56 e no 61 (eles tentavam ajustar
  telas que o 67 já tinha trocado). Agora pulam esse ajuste.

## Fila de produção, pesquisa, repetição espaçada, certificado por módulo e coleta (73 + 74)
- **Fila de produção de 1 a 150:** fica no aplicativo (Dados → Fila de produção) e se atualiza sozinha. A cópia de hoje
  está em `docs/fila_producao_150.md`. A ordem é:
  1. os 39 principais, na ordem das aulas;
  2. os opcionais com maior taxa de "Avise-me";
  3. o resto por importância: relevância no plantão (1 a 5, por incidência e gravidade), temas que libera na árvore
     e se é recomendado.

  Para ajustar a relevância de um tema: `SELECT app.definir_relevancia('T048', 5);`. O ajuste não é sobrescrito.
- **"Tenho interesse em pesquisar este tema"** aparece no fim da síntese de evidência. O residente escolhe uma das 5 ideias
  e autoriza o contato. A coordenação recebe um e-mail e acompanha tudo em `/curador/pesquisa` (situação, orientador,
  anotações e CSV). O residente vê o andamento na própria síntese.
- **Repetição espaçada:** "Revisão do dia" no Estudo dirigido.
  - Acertou: o card volta em 1 dia, depois em 3, depois em intervalos cada vez maiores.
  - Errou: o card volta em 10 minutos.
- **Certificado por módulo:** fica em Presença e certificado. Sai quando todos os temas do módulo estão concluídos e tem
  verificação pública, como o certificado geral.
- **Coleta de dados:**
  - tempo de leitura por peça (só com a tela visível; para depois de 3 minutos parado);
  - confiança declarada antes de cada teste (0 a 100%), para calcular a calibração (confiança − nota);
  - aplicabilidade na prática 30 dias depois do pós-teste D0: uso no plantão, mudança de conduta, segurança de 1 a 5,
    exemplo e barreira. Aparece em Pendências.

  No painel, ficam nas abas "Calibração e aplicabilidade" e "Tempo de leitura".
- **Buscas PubMed:** o arquivo ganhou a seção "Como nomear os PDFs da curadoria manual"
  (`T001_A07_2023_Silva_PMID37123456.pdf`).

## Árvore revisada e nova tela da árvore (65 + 75), 15/11/2026

- A coordenação confirmou os 150 temas e aceitou as 6 sugestões da revisão da árvore. A árvore passou de 185 para 169 ligações:
  - S1: saíram 16 ligações redundantes (o tema já dependia da mesma mãe por outro caminho; nada muda na liberação);
  - S2: T074 (hérnia encarcerada com isquemia) deixou de depender de T139 e abre depois da aula 19, não mais da 36. T041 não entrou como mãe nova porque já vem por T043;
  - S3: T035 (infecção cervical profunda) passou a depender de T002 e T050 e abre depois da aula 22, não mais da 31;
  - S4: T049 (Fournier) passou a depender de T050 e abre depois da aula 22, não mais da 33;
  - S5: T058 (delirium, sedação e analgesia) passou a depender de T053. Ficam 7 temas avulsos.
- A árvore do banco agora informa, para cada tema, a aula e "abre depois da aula N" (S6).
- Nova tela /aluno/arvore (script 75), com três vistas:
  - **Mapa:** arrastar e zoom, com o caminho do tema escolhido em azul (antes) e laranja (depois);
  - **Foco:** o tema no centro, com o que ele exige, o que libera e a ordem de estudo;
  - **Linha do curso:** cada aula de quinta e os temas que abrem depois dela.
  No celular a tela abre na Linha do curso.
- O estilo.css ganhou o bloco "tema CUT (Design System)" com as variáveis --cut-*. É o primeiro passo do arquivo de tema: as telas novas usam só essas variáveis.
- Para instalar: o `subir_api_pwa_wsl_v1.0.sh` já roda o 65 e o 75. Para voltar à tela antiga, rode de novo o 67.

## Certeza em cada questão e nova tela de testes (76), 15/11/2026

- Decisão da coordenação: em cada questão das ondas, o residente marca "Chutei", "Acho que sim" ou "Tenho certeza" antes de ver o gabarito. O teste só é enviado com alternativa e certeza em todas.
- A confiança única de 0 a 100% por teste deixou de ser pedida. Os dados já coletados continuam no painel "Calibração e aplicabilidade".
- Tela de testes no padrão do Design System CUT:
  - uma questão por tela, com "questão 3 de 7" e barra de progresso;
  - cada resposta é salva na hora, e o teste retoma de onde parou;
  - revisão antes de enviar.
- Gabarito:
  - acerto em azul (✓) e erro em laranja (✕), sempre com texto;
  - mostra a certeza marcada e o acerto por nível de certeza;
  - destaca no alto os erros com "tenho certeza".
- As respostas definitivas continuam imutáveis. Enquanto o teste está aberto, elas ficam num rascunho (app.resposta_rascunho) e só vão para app.resposta no envio.
- Painel: nova aba "Certeza por questão", com acerto por nível de certeza e erros com alta certeza, por aluno, tema e teste.
- Corrigido: a contagem de acertos do gabarito comparava códigos em formatos diferentes (texto e número) e podia mostrar zero.
- Sem internet: a resposta fica guardada no aparelho e vai ao servidor quando a conexão volta. Um aviso fixo no alto avisa que está sem conexão, e o envio do teste espera a conexão.
- As mensagens de erro agora dizem o motivo: sem conexão, teste ainda bloqueado, fora do prazo, grau não cadastrado ou sessão expirada.
- Início: os testes pendentes aparecem num cartão em destaque, com o botão "Responder agora" levando direto ao teste e um aviso quando o prazo está perto do fim.
- Todas as telas usam as cores e a fonte do CUT (script 77).
- Para instalar: o `subir_api_pwa_wsl_v1.0.sh` já roda o 76 (banco) e o 76_certeza_app (aplicativo).

## Perfis e funções da equipe (78), 15/11/2026

- **Ao entrar:** quem tem mais de um perfil escolhe com qual quer usar o aplicativo. O administrador pode usar qualquer perfil (administrador, curador, preceptor, pesquisador, responsável pelos dados, aluno). A equipe também pode ver o aplicativo como aluno.
- **Trocar de perfil:** a qualquer momento, em "Meu perfil", que fica no perfil atual ao lado do seu nome, no alto da tela (no celular, em "Mais").
- **Funções da equipe** (em Meu perfil, usando o perfil de Administrador):
  - buscar a pessoa por nome ou e-mail (ela precisa ter entrado ao menos uma vez);
  - atribuir curador, preceptor, pesquisador, responsável pelos dados ou administrador;
  - encerrar uma função. Encerrar não apaga: a função fica no histórico com data de fim, e o curso nunca fica sem administrador.
- **Segurança:** trocar de perfil nunca dá mais acesso do que a pessoa tem; usando o perfil de aluno, você vê só o que um aluno vê.
- **Google Cloud com o nome CUT:** veja `docs/google_cloud_cut.md`.

## Parte do aluno para todos e especialidade não cirúrgica (79 + 62), 15/11/2026

- Quem está no curso, inclusive a equipe usando o perfil de Aluno, responde os testes normalmente. O nível das questões vem do ano de residência do cadastro; sem ano cadastrado, as questões são as de R+ (antes, os testes ficavam indisponíveis).
- Cadastro: nova opção de especialidade, "Outra especialidade não cirúrgica", que também pede "Qual especialidade?".

## Identidade do CUT em todo o sistema, 15/11/2026

- **Nome:** "CUT · Curso de Cirurgia Geral, Urgência e Trauma" no título, no app instalado (nome curto "CUT"), no login, no topo, na página pública, no certificado, no calendário assinado e nos e-mails (remetente "CUT").
- **Logos do Design System:**
  - ícone pequeno e a palavra CUT no topo;
  - logo vertical no login;
  - logo horizontal no certificado;
  - ícones PNG para instalar no celular.
  O app instalado troca o ícone sozinho na próxima abertura, porque o cache foi renovado.
- **Termos na versão v2-2026-11 com o nome CUT.** A versão anterior deixa de valer e cada pessoa aceita de novo os termos obrigatórios no próximo acesso. Como ainda não há residentes, ninguém da turma precisa reaceitar.
- **O conteúdo do tema T001** (roteiro do podcast, rodapés) fica como está: é material do curso. Para trocar, edite a próxima versão do material.
- **E-mail:** o remetente só muda se você rodar de novo o `52_configurar_email_v1.0.sh`.

## Ajuste que só dá para fazer à mão no Google Agenda (entrada sem aprovação)
1. Abra o Google Agenda no computador e clique na aula de quinta (20:00).
2. Clique no ícone de engrenagem ao lado de "Participar com o Google Meet" (Opções do organizador).
3. Em **Acesso à reunião**, escolha **Aberto** (ninguém precisa pedir para entrar). Salve.
   Vale para todas as repetições do evento. Isso não pode ser ligado pela API.

> O **relatório de presença do Meet** (CSV com entrada e saída) só é gerado em contas Google Workspace
> (por exemplo, a conta institucional). Na conta Gmail pessoal ele pode não aparecer. Nesse caso, a presença
> continua funcionando pelo código resgatado na aula.

## Cópia de segurança diária no Google Drive (70)
1. `sudo apt install -y gnupg`
2. `bash 70_backup_drive_v1.0.sh configurar` e escolha uma frase-senha longa. Guarde-a fora do computador.
   Sem ela a cópia não abre.
3. No Google Drive para computador: Preferências → Meu computador → Adicionar pasta → `C:\Users\japt7\CursoUE_backups`.
4. `bash 70_backup_drive_v1.0.sh` faz a primeira cópia. `bash 70_backup_drive_v1.0.sh testar` confere se ela restaura.
5. `bash 70_backup_drive_v1.0.sh agendar` mostra a linha para o PowerShell. Ela agenda a cópia todo dia às 03:17.
   O computador precisa estar ligado nesse horário.
- O arquivo vai cifrado (AES-256): o Google só guarda um arquivo ilegível. As cópias são mantidas por 30 dias.

## Cloudflare Tunnel (troca do ngrok, quando quiser)
- O túnel é **gratuito**, mas exige um **domínio próprio** (ex.: um `.com.br` no registro.br, cerca de R$ 40/ano).
  O "quick tunnel" (trycloudflare.com) muda de endereço a cada vez e não serve para o login Google.
- O computador continua precisando ficar ligado. A vantagem é um endereço fixo e profissional, sem a tela de aviso
  do ngrok, que atrapalha a verificação da marca no Google.
- Passos:
  1. Crie a conta grátis no Cloudflare e adicione o domínio. Troque os servidores DNS no registro.br pelos 2 que o
     Cloudflare indicar. Pode levar algumas horas.
  2. No WSL: instale o `cloudflared` (pacote .deb do site da Cloudflare).
  3. Rode `cloudflared tunnel login`, depois `cloudflared tunnel create curso-ue`, depois
     `cloudflared tunnel route dns curso-ue curso.SEUDOMINIO.com.br`.
  4. Crie `~/.cloudflared/config.yml` apontando o túnel para `http://localhost:8080` e rode
     `cloudflared tunnel run curso-ue` no lugar do ngrok.
  5. No Google Cloud (credencial OAuth e tela de consentimento), troque o endereço do ngrok pelo novo:
     origem, `…/api/auth/callback`, página inicial, privacidade, termos e domínio autorizado.
     Ajuste também `APP_URL` e `CORS_ORIGINS` no .env.

## Sequência de entrega do material (81) e textos revisados (80) — CUT_v2n

- D-15: só o pré-teste 1.
- Ao enviar o pré-teste 1: objetivos de aprendizagem (abre na parte do ano do aluno), resumo básico, podcast (roteiro e
  áudio), caso base, síntese de evidência, mapa conceitual e pré-teste 2.
- Com o pré-teste 2 enviado e na hora da aula: aula, slides, caso da aula e pós-teste D0. Quem perdeu o prazo do
  pré-teste 2 (1 hora antes da aula) recebe esta etapa na hora da aula.
- Ao enviar o pós-teste D0: resumo executivo, protocolo assistencial, checklists, flashcards e banco de questões.
- D+15, D+45 e D+90: os pós-testes seguintes, nas datas.
- "Pré-teste inicial" passa a "Pré-teste 1"; "Simulados" passa a "Banco de questões".
- Áudio do podcast: veja `docs/podcast_audio.md`.
- 80 aplica `modelos/textos_v1.0/textos.json` (textos das telas em linguagem mais simples).
- A seção "Instalar" da Ajuda deixou de quebrar o texto em pedaços (CSS `.passos`).

## Material interativo (82) — CUT_v2o

- Caso da aula: em cada ponto de decisão, o aluno escreve a conduta e marca a certeza antes de abrir a discussão. A
  resposta daquele ponto fica registrada. Depois ele compara ("parecida", "em parte", "diferente"). Conduta diferente
  marcada com "tenho certeza" recebe destaque. No fim: desfecho e resumo das respostas.
- Caso base: respostas às perguntas do fim, salvas no site; podem mudar até a hora da aula. Depois da aula ficam só
  para leitura, com um campo ao lado para "o que eu responderia agora".
- Mapa conceitual: ramos em cartões que abrem e fecham, com o modo "Testar-me" (esconde os itens até o aluno tocar).
- Checklist: itens clicáveis, com contagem; as marcações ficam salvas.
- Slides: aula e caso, com fala em texto e áudio por slide, avanço automático sincronizado e velocidade de 1x a 2x.
  Imagens do deck e áudios: `docs/podcast_audio.md`.
- Podcast: velocidade de 1x a 2x e retomada do ponto em que parou.
- Onde parou: peça aberta, posição do texto, ponto do caso, slide e tempo do áudio, guardados no aparelho e no
  servidor. Sem internet, vão quando a conexão volta. O Início mostra "Continuar de onde parou".

## Ajustes CUT_v2p (83, 84)

- Pré-teste 2 fora do prazo: a aula abre no horário mesmo sem ele, e o aluno ainda pode fazer o pré-teste 2 depois
  (até 180 dias após a aula). O que for enviado depois da hora da aula fica marcado na tentativa e na nota, e aparece
  no painel de notas, coluna "observacao", como "feito depois da aula (conteúdo já apresentado)".
- Caso da aula: depois de concluir, o aluno pode refazer. A tentativa anterior fica guardada e aparece ao lado, ponto
  a ponto.
- Painel: abas "Caso da aula" (conduta, certeza e comparação por ponto e por tentativa; alerta quando a conduta foi
  diferente e marcada com "tenho certeza") e "Caso base" (resposta antes e depois da aula). O pesquisador vê o código
  do participante, e a coordenação vê o nome.
- Slides do T001:
  - nova versão em rascunho, com uma "Fala" para o aluno em cada slide (texto em
    `conteudo/T001/v3/T001_slides_falas.md`; precisa de revisão antes de publicar e de gerar o áudio);
  - as imagens do deck (`conteudo/T001/slides/imagens`) entram no aplicativo.
- Nome: "CUT" no lugar do nome antigo do programa, no material (todas as versões), nas telas e nos scripts. Os termos
  já aceitos e os e-mails já enviados ficam como estavam, porque são registro histórico.

## Dados simulados (90 e 91) — CUT_v2q

- `90_simulacao_5_residentes_v1.0.sql`: 5 residentes fictícios (nomes "SIMULADO …", e-mails @simulado.local), com o
  T001 inteiro e aula em 13/08/2026. Não entra no subir; roda à mão. Perfis:
  - Ana, R1, estudiosa;
  - Bruno, R1, faz o pré-teste 2 depois da aula, responde rápido demais e não faz o D+90;
  - Carla, R2, confiante demais, refaz o caso;
  - Diego, R3, estável;
  - Elisa, R4, muito boa mas insegura, e não aceita a pesquisa.
- `91_apagar_simulacao_v1.0.sql`: apaga tudo o que é simulado. Rodar antes de abrir o curso.

## Experiência do aluno, aprendizagem e pesquisa (85, 86) — CUT_v2r

- **Leitura do tema:** peças agrupadas em "Antes da aula", "Aula" e "Depois da aula", com a marca de visto ou feito.
- **Início:** "O que fazer agora", uma ação em destaque, na ordem:
  1. aula agora;
  2. teste com prazo em até 3 dias;
  3. continuar o que estudou;
  4. outro teste;
  5. revisão do dia;
  6. próxima aula.
- **Avisos no celular:** veja `docs/avisos_celular.md`.
- **Acessibilidade:** as telas novas passaram por checagem automática (nome dos controles, contraste, área de toque e
  largura de 320 px). Foi corrigido o seletor de temas do estudo dirigido, que passava da tela no celular.
- **Revisão espaçada das questões** (os flashcards já tinham desde o 73): a questão errada volta em 1 dia; depois
  em 3, 7, 16, 35 e 90 dias. O estudo dirigido ganhou "Revisão do dia" e o simulado misturado.
- **Desempenho:** "A sua certeza" mostra o acerto em cada nível de certeza, com uma leitura do que fazer.
- **Caso da aula:**
  - depois de abrir a discussão, o aluno escreve em uma frase por que a conduta é essa;
  - graduação, R1 e R2 podem pedir uma dica em cada ponto (dicas do T001 em rascunho, script 86).
- **Pesquisa:**
  - base por resposta com as marcas de qualidade;
  - análise das questões só com dados válidos;
  - indicadores clínicos mensais;
  - dicionário de dados (`docs/dicionario_dados_pesquisa.md`);
  - plano de análise (`docs/plano_analise_preregistro.md`);
  - script de análise (`analise/`).

## Relatório de análise no painel (87) — CUT_v2s

- `instalar_python_analise_v1.0.sh`: instala o Python com pandas, scipy e matplotlib (pelo apt, pede a senha do WSL) e
  testa o relatório. Rodar uma vez.
- Painel, primeira aba, cartão "Relatório de análise":
  - "Gerar com os dados válidos": monta a base atual e roda o plano de análise, com o modelo principal;
  - "Ensaio com os dados simulados".
- O relatório abre numa aba nova. Quem tem perfil de pesquisador recebe só quem consentiu, por código.

## Formato, âncoras, tempo de estudo e agentes da coordenação (88, 89) — CUT_v2u

- **Formato fixo das peças** (`docs/formato_das_pecas.md`):
  - o banco recusa publicar peça com erro de formato;
  - a revisão e a prévia mostram a conferência;
  - aba "Conferência dos temas" no painel.
- **Questões âncora:**
  - política de 2 a 3 por tema;
  - coluna `fixa` na base de análise;
  - análise de sensibilidade só com as âncoras no relatório.
- **Tempo de estudo:** cada peça mostra "Essencial" ou "Aprofundamento" e os minutos; cada grupo mostra o tempo essencial.
- **Telas antigas no Design System:** a tela de lembretes e as telas de leitura e de revisão estão sem cor nem fonte fixas.
- **Agentes da coordenação** (`docs/coordenacao_agentes.md`):
  - ponte com a pasta `CUT_coordenacao` do Windows;
  - aba "Para revisar" do painel, com aprovar, aprovar com alteração e vetar, e o desempenho de cada agente.
- Python: os avisos do pandas (FutureWarning) no relatório foram retirados.
