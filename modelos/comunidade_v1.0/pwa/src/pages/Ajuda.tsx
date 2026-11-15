import { useState } from 'react';
import { PassosInstalar } from '../components/Instalar.js';

interface Secao { id: string; titulo: string; corpo: JSX.Element }

const SECOES: Secao[] = [
  { id: 'instalar', titulo: 'Instalar o aplicativo no celular', corpo: <PassosInstalar /> },
  { id: 'funciona', titulo: 'Como o curso funciona', corpo: (<>
    <p>São reuniões semanais às <strong>quintas, 20h, pelo Google Meet</strong>, sempre no mesmo link. Cada tema segue quatro fases:</p>
    <ol>
      <li><strong>Abertura (15 dias antes):</strong> abre o pré-teste inicial. Você recebe um e-mail.</li>
      <li><strong>Pré-aula:</strong> ao enviar o pré-teste inicial, chegam objetivos, resumo básico, podcast, caso base e o pré-teste 2, que fecha <strong>1 hora antes da aula</strong>.</li>
      <li><strong>Aula (D0):</strong> na hora da aula abrem a aula, os slides, o caso e o pós-teste D0.</li>
      <li><strong>Pós-aula:</strong> ao enviar o pós-teste D0, chegam síntese, resumo executivo, mapa, flashcards, protocolo, checklists e simulados. Os pós-testes voltam em D+15, D+45 e D+90.</li>
    </ol>
    <p>O gabarito comentado aparece logo depois de enviar cada teste, com a sua nota, a nota esperada para o seu perfil e a média dos colegas.</p>
  </>) },
  { id: 'temas', titulo: 'Temas principais, opcionais e a árvore', corpo: (<>
    <p><strong>Principais (39):</strong> têm data de aula do grupo, em ordem de dificuldade. <strong>Opcionais:</strong> você escolhe a data (D0) na tela do tema e tudo passa a contar a partir dela.</p>
    <p>Alguns temas dependem de outros: um tema só abre quando os temas “mãe” foram concluídos (pós-teste D0 enviado). Veja o caminho em <a href="/aluno/arvore">Árvore de temas</a>. Temas avulsos não dependem de nenhum outro.</p>
  </>) },
  { id: 'presenca', titulo: 'Presença e certificado', corpo: (<>
    <p>Durante a aula, a coordenação mostra um <strong>código</strong> (ou link). Digite-o em “Resgatar crédito de presença”, no Início. Se esquecer, a presença também vale se o relatório do Google Meet mostrar que você ficou <strong>pelo menos metade da aula</strong> — para isso, entre no Meet com o mesmo e-mail cadastrado.</p>
    <p>O certificado (em <a href="/aluno/aproveitamento">Presença e certificado</a>) traz os temas concluídos, a carga horária e o percentual de presença, com um código de verificação que qualquer pessoa pode conferir.</p>
  </>) },
  { id: 'prazos', titulo: 'Prazos, lembretes e e-mails', corpo: (<>
    <ul>
      <li>O pré-teste 2 fecha 1 hora antes da aula. Se perder o prazo, você segue normalmente para a aula.</li>
      <li>Os pós-testes ficam abertos até 180 dias depois da aula, mas o ideal é fazê-los na data: a ideia é medir o quanto você retém.</li>
      <li>Autorize os e-mails em <a href="/aluno/contato">Lembretes</a>: aviso de abertura, prazo do pré-teste 2, testes atrasados, resumo da semana (segunda, 7h) e respostas das suas dúvidas.</li>
      <li>Se os e-mails não chegarem, procure no spam e marque como “não é spam”.</li>
    </ul>
  </>) },
  { id: 'duvidas', titulo: 'Dúvidas e feedback', corpo: (<>
    <p>No fim de cada peça e de cada gabarito há “Enviar dúvida ou feedback”. As dúvidas vão para a coordenação, que responde no app (e por e-mail, se autorizado). Não escreva dados de pacientes (nome, iniciais, prontuário, datas, imagens).</p>
  </>) },
  { id: 'dados', titulo: 'Seus dados e segurança', corpo: (<>
    <ul>
      <li>Você entra com a sua conta Google; o curso <strong>não guarda nem vê a sua senha</strong>. Ative a verificação em duas etapas na sua conta Google.</li>
      <li>A sessão dura 12 horas. Em computador compartilhado, clique em <strong>Sair</strong> ao terminar.</li>
      <li>As telas de conteúdo levam marca d’água com o seu nome; o material é de uso exclusivo e não pode ser copiado, gravado ou repassado.</li>
      <li>No ranking, os colegas veem só a sua posição, o ano e a especialidade — nunca o seu nome ou a sua nota.</li>
      <li>Participar da pesquisa é opcional e pode ser mudado a qualquer momento em <a href="/cadastro">Meus dados</a>, onde também é possível pedir cópia, correção ou exclusão dos dados. Leia a <a href="/privacidade">política de privacidade</a> e os <a href="/termos">termos de uso</a>.</li>
    </ul>
  </>) },
  { id: 'limites', titulo: 'Limitações conhecidas', corpo: (<>
    <ul>
      <li>É preciso internet para estudar: por segurança, o material não fica salvo no aparelho.</li>
      <li>Copiar, imprimir e o menu do botão direito ficam bloqueados nas telas de conteúdo.</li>
      <li>Algumas datas e prazos dependem do horário de Brasília.</li>
      <li>O conteúdo é educacional: não substitui o julgamento clínico, a supervisão do seu serviço nem os protocolos da sua instituição.</li>
    </ul>
  </>) },
  { id: 'admin', titulo: 'Questões administrativas', corpo: (<>
    <ul>
      <li><strong>Inscrição:</strong> feita pela ficha em Meus dados e aprovada pela coordenação (ou automaticamente para e-mails institucionais cadastrados).</li>
      <li><strong>Atualização anual:</strong> todo mês de março o app pede para você confirmar o ano de residência e a especialidade.</li>
      <li><strong>Troca de e-mail, problemas de acesso ou de certificado:</strong> fale com a coordenação pelo campo de feedback ou pelo contato informado nos termos.</li>
    </ul>
  </>) },
  { id: 'problemas', titulo: 'Algo não funciona?', corpo: (<>
    <ol>
      <li>Atualize a página (no celular: puxe a tela para baixo).</li>
      <li>Saia e entre de novo.</li>
      <li>Confira a internet e se o relógio do aparelho está certo.</li>
      <li>No aviso “Visit Site” do primeiro acesso, clique para continuar (é a proteção do endereço provisório).</li>
      <li>Persistindo, envie um feedback descrevendo o que tentou fazer, o aparelho e o navegador.</li>
    </ol>
  </>) },
];

// Ajuda: funcionamento, instalacao do app, presenca, prazos, dados, limitacoes e questoes administrativas.
export function Ajuda() {
  const [aberta, setAberta] = useState<string | null>(window.location.hash.slice(1) || 'instalar');
  return (
    <section className="ajuda">
      <h1>Ajuda</h1>
      <p>Tudo o que você precisa saber para usar o curso. Toque em um assunto para abrir.</p>
      {SECOES.map((s) => (
        <article key={s.id} id={s.id} className="cartao-app ajuda-secao">
          <h2><button type="button" aria-expanded={aberta === s.id} onClick={() => setAberta(aberta === s.id ? null : s.id)}>{s.titulo}<span aria-hidden="true">{aberta === s.id ? '−' : '+'}</span></button></h2>
          {aberta === s.id && <div className="ajuda-corpo">{s.corpo}</div>}
        </article>
      ))}
    </section>
  );
}
