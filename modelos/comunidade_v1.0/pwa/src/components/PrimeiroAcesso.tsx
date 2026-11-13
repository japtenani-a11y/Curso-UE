import { useEffect, useState } from 'react';
import { PassosInstalar, jaInstalado } from './Instalar.js';

const PASSOS: { titulo: string; texto: string; instalar?: boolean }[] = [
  { titulo: 'Como cada tema funciona', texto: 'O tema abre 15 dias antes da aula com o pré-teste inicial. Ao enviá-lo, chegam o material pré-aula e o pré-teste 2 (até 1 hora antes da aula). Na aula (quinta, 20h, Google Meet) abrem a aula, o caso e o pós-teste D0; depois, o material pós-aula e os pós-testes de D+15, D+45 e D+90. Alguns temas dependem de outros: veja a árvore de temas.' },
  { titulo: 'Onde ficam as suas tarefas', texto: 'Em Pendências estão os testes liberados e as avaliações que faltam, com a contagem do prazo. No Início aparecem a próxima aula, o link do Meet e o campo para resgatar o crédito de presença com o código mostrado na aula.' },
  { titulo: 'Instale o curso no celular', texto: '', instalar: true },
  { titulo: 'Lembretes e agenda', texto: 'Em Meus dados → Lembretes, autorize os e-mails: você recebe o aviso de abertura de cada tema, o prazo do pré-teste 2 e um resumo toda segunda-feira. No Calendário, adicione as aulas à sua agenda do Google ou do Outlook com um clique.' },
];

// Tres telas curtas no primeiro acesso (guardado so neste navegador).
export function PrimeiroAcesso() {
  const [passo, setPasso] = useState<number | null>(null);
  useEffect(() => { try { if (!localStorage.getItem('primeiro_acesso_v2')) setPasso(0); } catch { /* sem armazenamento */ } }, []);
  if (passo === null) return null;
  const fim = () => { try { localStorage.setItem('primeiro_acesso_v2', '1'); } catch { /* segue */ } setPasso(null); };
  const p = PASSOS[passo] ?? PASSOS[0]!;
  return (
    <div className="modal-fundo" role="dialog" aria-modal="true" aria-labelledby="pa-titulo">
      <div className="modal cartao-app">
        <span className="rotulo">Bem-vindo · {passo + 1} de {PASSOS.length}</span>
        <h2 id="pa-titulo">{p.titulo}</h2>
        {p.instalar ? (jaInstalado() ? <p>O aplicativo já está instalado neste aparelho.</p> : <PassosInstalar />) : <p>{p.texto}</p>}
        {p.instalar && <p><small>Estas instruções ficam sempre em <a href="/ajuda">Ajuda</a>.</small></p>}
        <div className="pontos" aria-hidden="true">{PASSOS.map((_, i) => <i key={i} className={i === passo ? 'sel' : ''} />)}</div>
        <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end', flexWrap: 'wrap' }}>
          <button type="button" className="botao discreto" onClick={fim}>Pular</button>
          {passo < PASSOS.length - 1
            ? <button type="button" className="botao" onClick={() => setPasso(passo + 1)} autoFocus>Próximo</button>
            : <button type="button" className="botao" onClick={fim} autoFocus>Começar</button>}
        </div>
      </div>
    </div>
  );
}
