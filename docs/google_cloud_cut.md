# Google Cloud: o que mudar com o nome CUT (15/11/2026)

Hoje (docs/servidor_revisao_v1.0.md): projeto "Programa CUT", tela de consentimento com o nome
"CUT", público **Externo**, app **Em teste** com 3 usuários de teste,
cliente OAuth "Aplicativo da Web" apontando para o domínio do ngrok.

## Agora (10 minutos, sem risco)

Entre em console.cloud.google.com com a sua conta, selecione o projeto "Programa CUT" e abra
**Google Auth Platform** (nome antigo: APIs e serviços → Tela de consentimento OAuth).

1. **Branding → Nome do app:** `CUT – Curso de Cirurgia Geral, Urgência e Trauma` → Salvar.
   - **Não envie logo agora.** Para mostrar nome e logo na tela de login de um app Externo, o Google pede
     *verificação de marca*. Essa verificação exige um domínio seu, confirmado no Google Search Console, e o
     domínio do ngrok não é seu. Com o app em teste, quem entra vê o aviso "o Google não verificou este app";
     isso é esperado e não impede a entrada.
2. **Branding → Links do app** (se já estiverem preenchidos, só troque o domínio):
   - página inicial: `https://SEU-DOMINIO/`
   - política de privacidade: `https://SEU-DOMINIO/privacidade`
   - termos de serviço: `https://SEU-DOMINIO/termos`
3. **Público-alvo → Usuários de teste:** acrescente o e-mail Google dos 2 ou 3 residentes do teste de uso.
   Enquanto o app estiver "Em teste", só quem está nessa lista consegue entrar (limite de 100 pessoas).
4. Nada muda em **Clientes** (ID e chave secreta) nem no arquivo `~/.config/curso-ue/servidor.env`.

## Antes do lançamento para a turma (quando decidir o endereço definitivo)

1. Ter um domínio próprio: Cloudflare com domínio seu, ou um subdomínio do HC/USP pedido à informática.
2. Verificar esse domínio no Google Search Console, com a mesma conta dona do projeto.
3. No Google Auth Platform: domínio autorizado = o novo; em Clientes, a origem e o redirecionamento
   `https://NOVO-DOMINIO/api/auth/callback`; links do app com o novo domínio. No `.env`: `APP_URL` e `CORS_ORIGINS`.
4. **Público-alvo → Publicar aplicativo.** Com os escopos que usamos (nome e e-mail), não há verificação de
   escopos sensíveis.
5. Se quiser o logo do CUT na tela de login do Google: enviar o ícone (PNG quadrado, 120×120) e pedir a
   verificação de marca no Verification Center. O Google costuma levar alguns dias.

Fontes: https://support.google.com/cloud/answer/15549049 e
https://developers.google.com/identity/protocols/oauth2/production-readiness/brand-verification
