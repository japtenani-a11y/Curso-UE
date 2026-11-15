# Atualização v2j: jornada do aluno e painel de dados

## O que muda

**Entradas do aluno (tela inicial)**
- **Pendências**: testes liberados que faltam e avaliações que faltam (do tema, de cada peça liberada e de cada teste enviado), separados por tema. A avaliação abre ali mesmo.
- **Calendário de aulas**: as 39 aulas do grupo (quintas, 20h) e as datas que o aluno escolheu nos opcionais. Clicar leva ao tema.
- **Temas por módulo**: escolhe o módulo, depois o tema.

**Tela do tema** (`/aluno/tema/T001`): quatro fases, com o estado de cada teste e de cada peça.

| Fase | Quando abre | O que o aluno recebe |
|---|---|---|
| Abertura | D-15 (com aviso por e-mail) | Pré-teste inicial |
| Pré-aula | Ao enviar o pré-teste inicial | Objetivos, resumo básico, podcast, caso base e pré-teste 2 (até 1 hora antes da aula) |
| Aula | No D0, com o pré-teste inicial feito | Aula, slides, caso e pós-teste D0. Quem perdeu o prazo do pré-teste 2 segue normalmente |
| Pós-aula | Ao enviar o pós-teste D0 | Síntese de evidência, resumo executivo, mapa, flashcards, protocolo, checklists, simulados; pós-testes em D+15, D+45 e D+90 (com aviso por e-mail) |

- O gabarito continua aparecendo só depois do envio do teste.
- Nos temas opcionais, o aluno escolhe a data (D0) na própria tela do tema, e tudo passa a contar a partir dela.

**Avaliação ampliada** (NPS 0–10 e escalas 1–5):
- Escalas de qualidade: qualidade, apresentação, clareza, objetividade, adequação ao nível e importância.
- Escalas de dosagem, em que 3 = adequado: dificuldade, profundidade e tempo exigido.
- Utilidade (sim, em parte, não) e minutos gastos.
- Nos testes, também a frequência dos testes.
- Na avaliação geral do tema, também quais materiais o aluno usou.

**Painel "Dados e gráficos"** (`/painel`), para coordenação, curadores, data steward e pesquisadores:
- Evolução da média de acertos do pré-teste inicial ao D+90, agrupada por turma (ano de entrada), especialidade, ano de residência ou aluno, com ganho (D0 − pré) e retenção (D+90 − D0). Dá para filtrar por tema.
- NPS de cada peça e de cada teste, e médias de satisfação.
- Tabelas de notas, avaliações, dúvidas e feedback, e uso do material, cada uma com botão **Baixar CSV** (abre no Excel).
- O pesquisador vê o código do participante; a coordenação vê o nome.

## Passo a passo

1. Baixe `T001_v2j.zip` para a pasta Downloads do Windows.
2. No Ubuntu, desligue o servidor, descompacte o zip e rode o `subir`:
   ```bash
   cd ~/Curso-UE
   bash 50_servidor_revisao_v1.0.sh parar
   unzip -o /mnt/c/Users/japt7/Downloads/T001_v2j.zip -d ~/Curso-UE
   bash subir_api_pwa_wsl_v1.0.sh SUA_SENHA
   ```
3. Confira o passo 6 da saída. Além das linhas de antes, devem aparecer:
   - tela do tema T001: 6 testes
   - pendências: 200
   - aluno no painel: 403
   - curador baixando as notas do painel (CSV): 200
4. Teste em `http://localhost:5173/login`:
   - `r1.teste@setup.local` (aluno): Início → Pendências, Calendário, Temas → T-001.
   - `japtenani@gmail.com` (coordenador): menu **Dados e gráficos**.
5. Coloque o servidor no ar de novo:
   ```bash
   bash 50_servidor_revisao_v1.0.sh SUA_SENHA
   ```

> No teste local, as datas do T001 são de teste: a aula já "passou" e os prazos vão até 2027. As datas reais entram com o `48_agenda_aulas_v1.0.sql`, quando o programa abrir.
