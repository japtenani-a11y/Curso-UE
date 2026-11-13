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
- **T136, T137 e T138 propostos** (opcionais, aprovação pendente; os títulos mudam só no `53_temas_programa_v1.0.sql`):
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
