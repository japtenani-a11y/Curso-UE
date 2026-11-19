import { AvisosCelular } from '../../components/leitura/AvisosCelular.js';
import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

// Lembretes dos testes: e-mail (e WhatsApp, quando ligado) e avisos no celular.
// Estilo so com as classes e variaveis do Design System CUT (estilo_interativo.css: .tela-form), sem cor fixa.
interface Contato { email_aviso: string | null; whatsapp: string | null; aceita_email: boolean; aceita_whatsapp: boolean; consentimento_em: string | null }
interface Resposta { contato: Contato | null; email_cadastro: string | null; versao_termo_atual: string }

const MOSTRAR_ZAP = import.meta.env.VITE_WHATSAPP === '1';

export function Contato() {
  const [d, setD] = useState<Resposta | null>(null);
  const [email, setEmail] = useState('');
  const [zap, setZap] = useState('');
  const [aEmail, setAEmail] = useState(false);
  const [aZap, setAZap] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  useEffect(() => {
    apiGet<Resposta>('/contato').then((r) => {
      setD(r);
      setEmail(r.contato?.email_aviso ?? ''); setZap(r.contato?.whatsapp ?? '');
      setAEmail(r.contato?.aceita_email ?? false); setAZap(r.contato?.aceita_whatsapp ?? false);
    }).catch(() => setMsg('Não foi possível carregar seus dados de contato.'));
  }, []);

  async function salvar() {
    setMsg(null);
    try {
      await apiPost('/contato', { email_aviso: email, whatsapp: zap, aceita_email: aEmail, aceita_whatsapp: aZap });
      setMsg('Preferências salvas.');
    } catch (e) {
      const dados = e instanceof Error && e.message.includes('422');
      setMsg(dados ? 'Confira os dados: e-mail válido e WhatsApp com DDD, por exemplo (16) 99999-0000. Para autorizar o WhatsApp, o número é obrigatório.'
                   : 'Não foi possível salvar agora. Tente de novo.');
    }
  }

  if (!d) return <section className="tela-form"><p>{msg ?? 'Carregando…'}</p></section>;
  return (
    <section className="tela-form">
      <h1>Lembretes dos testes</h1>
      <p>Além do aviso no aplicativo, você pode receber os lembretes também por e-mail: pré-teste 2 perto do prazo (que termina 1 hora antes da aula) e pós-testes pendentes.</p>
      <label className="campo-rotulo">E-mail para os avisos (em branco, usa o do cadastro: {d.email_cadastro ?? '—'})
        <input className="campo" type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder={d.email_cadastro ?? ''} />
      </label>
      {MOSTRAR_ZAP && <label className="campo-rotulo">WhatsApp (com DDD)
        <input className="campo" type="tel" value={zap} onChange={(e) => setZap(e.target.value)} placeholder="(16) 99999-0000" />
      </label>}
      <label className="opcao">
        <input type="checkbox" checked={aEmail} onChange={(e) => setAEmail(e.target.checked)} /> Autorizo lembretes por e-mail
      </label>
      {MOSTRAR_ZAP && <label className="opcao">
        <input type="checkbox" checked={aZap} onChange={(e) => setAZap(e.target.checked)} /> Autorizo lembretes por WhatsApp
      </label>}
      <p className="nota">
        Seus dados de contato são usados só para estes lembretes do curso. Você pode retirar a autorização a qualquer momento nesta tela.
        Termo {d.versao_termo_atual}{d.contato?.consentimento_em ? ` · autorizado em ${new Date(d.contato.consentimento_em).toLocaleDateString('pt-BR')}` : ''}.
      </p>
      {msg && <p role="status" className="status">{msg}</p>}
      <div className="acoes">
        <button type="button" className="botao" onClick={salvar}>Salvar preferências</button>
        <a href="/aluno">Voltar ao início</a>
      </div>
      <AvisosCelular />
    </section>
  );
}
