# Atualização T001 v2f + v2g (passo a passo)

Tudo no WSL (Ubuntu), dentro de `~/Curso-UE`. Senha do banco: a mesma de sempre.

1. Baixe `T001_v2g.zip` para a pasta Downloads do Windows.
2. Descompacte por cima do projeto (o `-o` substitui sem perguntar):
   ```bash
   cd ~/Curso-UE
   unzip -o /mnt/c/Users/japt7/Downloads/T001_v2g.zip -d ~/Curso-UE
   ```
3. Atualize o conteúdo do T001 no banco (camadas 1 e 5, ATLS, slides em texto):
   ```bash
   psql "postgresql://postgres:SUA_SENHA_DO_BANCO@localhost:5432/programa" -f 36_importar_T001_v2.sql
   ```
4. Gere, instale e teste tudo de uma vez:
   ```bash
   bash subir_api_pwa_wsl_v1.0.sh SUA_SENHA_DO_BANCO
   ```
   No passo 6 devem aparecer: curador enxerga 26 rascunhos · prévia 13 · 6 testes · gabarito 403 · contato 200 · WhatsApp 422 · catálogo 147 · ranking 200.
5. Abra `http://localhost:5173/login` e entre (só no teste local) como:
   - `r1.teste@setup.local` (aluno): Início, Temas, Testes, Desempenho, Dúvidas;
   - `japtenani@gmail.com` (coordenador): Revisão e Prévia.
6. E-mail dos lembretes: crie a senha de app em myaccount.google.com/apppasswords e rode `bash 52_configurar_email_v1.0.sh`. Depois rode de novo o passo 4.
7. Respostas das dúvidas por IA: crie uma chave NOVA em console.anthropic.com e rode `bash 57_configurar_ia_v1.0.sh`. Depois rode de novo o passo 4.
8. Servidor para os revisores (internet, login do Google): siga `docs/servidor_revisao_v1.0.md` (ngrok + credencial do Google, uma vez) e rode `bash 50_servidor_revisao_v1.0.sh SUA_SENHA_DO_BANCO`. Para desligar: `bash 50_servidor_revisao_v1.0.sh parar`.
9. Só quando for abrir para os alunos (não agora): `psql "postgresql://postgres:SUA_SENHA_DO_BANCO@localhost:5432/programa" -f 48_agenda_aulas_v1.0.sql` coloca os 39 temas principais nas quintas de 2027–2028 (isso tira os testes do T001 do modo de teste local).

Se algo falhar, envie os arquivos `programa-cut/logs/gerar.log`, `banco.log`, `tipos_api.log` e `tipos_pwa.log`.
