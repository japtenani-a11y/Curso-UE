# Avisos no celular (web push)

O residente pode receber no celular o aviso de que um tema abriu e de que um prazo vai fechar. São os mesmos lembretes
do e-mail, para quem ligar os avisos.

**Como funciona**
- O servidor manda ao celular só um sinal, sem texto. Ao receber o sinal, o aplicativo busca o texto do aviso no
  servidor, com o login do aluno. Assim o conteúdo não passa pelo serviço de push do Google ou da Apple.
- O aluno liga os avisos em Lembretes ("Ativar avisos neste aparelho") ou no convite que aparece no Início. Ele pode
  desligar a qualquer momento.
- Só funciona com o aplicativo publicado num endereço https. No iPhone, só com o aplicativo instalado na tela de início
  (iOS 16.4 ou mais novo).

**Ligar no servidor (uma vez só)**

No WSL, depois de instalar a versão nova:

```bash
cd ~/Curso-UE/programa-cut/api && npm run chaves-push
cd ~/Curso-UE && bash subir_api_pwa_wsl_v1.0.sh SENHA
```

O primeiro comando grava as chaves em `~/.config/curso-ue/push.env`, fora do projeto, com leitura só sua.

- Não troque as chaves depois que os alunos ligarem os avisos: a troca desliga todas as inscrições.
- Não envie esse arquivo a ninguém.

**Testar**
- O enviador de lembretes (`npm run notificar`) passa a mandar também o canal "push".
- No modo simulado (padrão), só registra no log.
- Para enviar de fato, use `NOTIFICAR_MODO=enviar`, como no e-mail.
