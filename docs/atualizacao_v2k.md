# Atualização v2k: inscrição do aluno, termos e nota esperada

Esta versão inclui também tudo da v2j (jornada do aluno e painel). Se você ainda não instalou a v2j, basta instalar esta.

## O que muda

**Inscrição pelo próprio aluno**
- O aluno entra com a conta Google. Se o e-mail for novo, a inscrição é criada e ele cai na tela **Inscrição no curso**.
- Ele não vê material, testes nem temas até a inscrição ser aprovada.
- Ficha:
  - nome, data de nascimento, e-mail (o da conta Google, não editável) e celular;
  - situação: estudante de graduação (semestre do 7º ao 12º), médico residente ou médico formado fora da residência;
  - onde faz a faculdade (graduandos) ou onde se formou e o ano de formatura, com lista de sugestões: as 69 escolas médicas do estado de SP e as principais públicas dos outros estados. Se a faculdade não estiver na lista, o aluno digita o nome;
  - especialidade: cirurgia geral, cirurgia de urgência e trauma, medicina de emergência ou outra cirúrgica (com campo "qual");
  - para residentes: onde faz a residência (lista de hospitais, aceita outro nome digitado), ano de ingresso e data prevista de término;
  - para médicos formados: onde fez a residência, se fez.
- Termos, cada um com o texto completo e uma cópia para baixar:
  - **Termo de uso, confidencialidade e segurança** (obrigatório): responsabilidade pelo conteúdo, conta pessoal, proibição de copiar, gravar ou repassar o material, proibição de dados de pacientes, conduta, e registro de tudo o que é feito e escrito na plataforma;
  - **Aviso de privacidade (LGPD)** (obrigatório): dados coletados, finalidades e bases legais, compartilhamento, prazo de guarda, segurança e direitos do titular;
  - **TCLE de pesquisa** e **Autorização de divulgação** (opcionais): recusar não muda nada na participação, e o aluno pode mudar de ideia quando quiser.
- Cada aceite fica registrado com data, hora, IP e versão do termo. Se um termo obrigatório mudar de versão, todos precisam aceitar de novo.
- A tela **Meus dados** traz a ficha, os termos, os lembretes e os pedidos LGPD (cópia, correção ou exclusão dos dados), que vão para a coordenação.

**Inscrições (curadores e coordenação)**
- Cada inscrição nova gera e-mail para você, a Aline e o Jorge.
- No menu **Inscrições** dá para aprovar, recusar (com motivo, que vai por e-mail ao aluno) ou suspender o acesso.
- Ao aprovar, o ano de residência (R1…R6, calculado pelo ano de ingresso), a especialidade e a turma passam a valer para as questões, o ranking e o painel.

**Nota esperada e comparativos**
- Depois de cada gabarito, o aluno vê quatro notas: a dele, a esperada para o perfil dele, a média de todos e a média do subgrupo (mesmo ano de residência e mesma especialidade).
- A nota esperada vem do grau de cada questão ajustado ao ano do aluno: uma questão "média" para o R1 conta como "fácil" para o R2.
- A taxa usada para cada grau é o ponto médio da faixa do banco de questões:

  | Grau | Taxa usada |
  |---|---|
  | Muito fácil | 95% |
  | Fácil | 82,5% |
  | Média | 62,5% |
  | Difícil | 40% |
  | Muito difícil | 22,5% |
  | Extrema | 7,5% |

- As médias de grupo só aparecem com 3 ou mais alunos, para que ninguém deduza a nota de um colega.
- O gráfico de evolução com as quatro linhas aparece em **Desempenho** (por tema ou na média dos temas) e na tela do tema.
- No painel, o gráfico ganha as linhas tracejadas "Média de todos" e "Nota esperada", e a planilha de notas ganha a coluna `esperado`.

## Antes de abrir para os alunos

1. **Revise os textos dos termos.** São minutas. Preencha os campos entre colchetes (contato da coordenação, instituição responsável, pesquisador responsável, contatos do CEP). O texto final do TCLE deve ser o aprovado pelo CEP. Para trocar um texto, edite o `62_cadastro_aluno_v1.0.sql`, mude a versão (ex.: `v2-2027-01`) e rode o `subir` de novo.
2. **Publique o app no Google.** No Google Cloud, em Tela de consentimento OAuth (ou Público-alvo), clique em **Publicar aplicativo**. Enquanto o app está "Em teste", só os e-mails da lista de usuários de teste conseguem entrar. Com os escopos que usamos (nome e e-mail), o Google não exige verificação.
3. **Para fechar as inscrições:**
   ```bash
   psql "postgresql://postgres:SUA_SENHA@localhost:5432/programa" -c "UPDATE app.config_curso SET valor='nao' WHERE chave='inscricao_aberta'"
   ```

## Passo a passo

1. Baixe `T001_v2k.zip` para a pasta Downloads do Windows.
2. No Ubuntu, desligue o servidor, descompacte o zip e rode o `subir`:
   ```bash
   cd ~/Curso-UE
   bash 50_servidor_revisao_v1.0.sh parar
   unzip -o /mnt/c/Users/japt7/Downloads/T001_v2k.zip -d ~/Curso-UE
   bash subir_api_pwa_wsl_v1.0.sh SUA_SENHA
   ```
3. Confira o passo 6 da saída. Além das linhas de antes, devem aparecer:
   - aluno de teste com inscrição aprovada: 1
   - aluno abrindo inscrições: 403
4. Coloque o servidor no ar de novo:
   ```bash
   bash 50_servidor_revisao_v1.0.sh SUA_SENHA
   ```
5. Para testar a inscrição de verdade, entre no endereço do ngrok com uma conta Google que não esteja cadastrada. Enquanto o app do Google estiver "Em teste", essa conta precisa estar na lista de usuários de teste.
