#!/usr/bin/env bash
# ============================================================
# 46_notificacoes_app_v1.0.sh
# OBJETIVO: lembretes dos testes tambem por e-mail e WhatsApp, alem do aviso no aplicativo.
#  - API: rota /contato (o aluno ve e grava e-mail de aviso, WhatsApp e o consentimento de cada canal)
#  - API: enviador api/src/notificador.ts (npm run notificar): a cada 5 minutos gera os lembretes,
#    poe na fila e envia por SMTP (e-mail) e pela API oficial do WhatsApp (WhatsApp Cloud API, Meta).
#    Sem credenciais, ou com NOTIFICAR_MODO=simular, so registra no log o que seria enviado.
#  - PWA: tela /aluno/contato e link na pagina inicial do aluno
# Credenciais so em variaveis de ambiente (SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM,
# WHATSAPP_TOKEN, WHATSAPP_PHONE_ID, WHATSAPP_TEMPLATE). Nunca em arquivo do repositorio.
# USO: bash 46_notificacoes_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 40 e 44 (scripts) e, no banco, 45_notificacoes_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 46_notificacoes_app_v1.0.sh <pasta programa-cut>}"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/teste.ts" ] || { echo "ERRO: rode antes o 40_testes_aluno_v1.0.sh"; exit 1; }
command -v node >/dev/null || { echo "ERRO: node nao encontrado"; exit 1; }

# ---------- API: routes/contato.ts ----------
cat > "$API/routes/contato.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const contatoRouter = Router();

// Versao do texto de consentimento mostrado na tela (guardada junto com o aceite).
export const VERSAO_TERMO = 'lembretes-v1 (12/11/2026)';

type Req = { pessoaId?: number; body: unknown };

// Aceita (16) 99999-0000, 16999990000, +55 16 99999 0000 ... e devolve +5516999990000.
export function normalizarWhatsapp(x: unknown): string | null | 'invalido' {
  if (x == null || String(x).trim() === '') return null;
  const s = String(x).trim();
  let d = s.replace(/\D/g, '');
  if (!s.startsWith('+') && (d.length === 10 || d.length === 11)) d = '55' + d;
  return /^[1-9][0-9]{9,14}$/.test(d) ? '+' + d : 'invalido';
}

function emailValido(x: unknown): string | null | 'invalido' {
  if (x == null || String(x).trim() === '') return null;
  const s = String(x).trim().toLowerCase();
  return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(s) ? s : 'invalido';
}

contatoRouter.get('/', async (req, res, next) => {
  try {
    const p = (req as unknown as Req).pessoaId;
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const dados = await withMaestro(null, async (client) => {
      const c = await client.query(
        `SELECT email_aviso, whatsapp, aceita_email, aceita_whatsapp, consentimento_em, versao_termo
           FROM app.contato_aluno WHERE pessoa_id = $1`, [p]);
      const e = await client.query(`SELECT email_primario::text AS email FROM app.pessoa WHERE pessoa_id = $1`, [p]);
      return { contato: c.rows[0] ?? null, email_cadastro: e.rows[0]?.email ?? null };
    });
    res.json({ ...dados, versao_termo_atual: VERSAO_TERMO });
  } catch (err) { next(err); }
});

contatoRouter.post('/', async (req, res, next) => {
  try {
    const p = (req as unknown as Req).pessoaId;
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const b = (req.body ?? {}) as { email_aviso?: string; whatsapp?: string; aceita_email?: boolean; aceita_whatsapp?: boolean };
    const email = emailValido(b.email_aviso);
    const zap = normalizarWhatsapp(b.whatsapp);
    if (email === 'invalido') { res.status(422).json({ erro: 'email_invalido' }); return; }
    if (zap === 'invalido') { res.status(422).json({ erro: 'whatsapp_invalido' }); return; }
    const aceitaEmail = b.aceita_email === true;
    const aceitaZap = b.aceita_whatsapp === true;
    if (aceitaZap && !zap) { res.status(422).json({ erro: 'whatsapp_obrigatorio' }); return; }
    await withMaestro(null, async (client) => {
      await client.query(
        `INSERT INTO app.contato_aluno (pessoa_id, email_aviso, whatsapp, aceita_email, aceita_whatsapp, consentimento_em, versao_termo, atualizado_em)
         VALUES ($1, $2, $3, $4, $5, CASE WHEN $4 OR $5 THEN now() END, CASE WHEN $4 OR $5 THEN $6 END, now())
         ON CONFLICT (pessoa_id) DO UPDATE SET
           email_aviso = EXCLUDED.email_aviso, whatsapp = EXCLUDED.whatsapp,
           aceita_email = EXCLUDED.aceita_email, aceita_whatsapp = EXCLUDED.aceita_whatsapp,
           consentimento_em = CASE
             WHEN (EXCLUDED.aceita_email AND NOT app.contato_aluno.aceita_email)
               OR (EXCLUDED.aceita_whatsapp AND NOT app.contato_aluno.aceita_whatsapp) THEN now()
             WHEN EXCLUDED.aceita_email OR EXCLUDED.aceita_whatsapp THEN app.contato_aluno.consentimento_em
             ELSE NULL END,
           versao_termo = CASE WHEN EXCLUDED.aceita_email OR EXCLUDED.aceita_whatsapp THEN $6 ELSE NULL END,
           atualizado_em = now()`,
        [p, email, zap, aceitaEmail, aceitaZap, VERSAO_TERMO]);
    });
    res.json({ ok: true, email_aviso: email, whatsapp: zap, aceita_email: aceitaEmail, aceita_whatsapp: aceitaZap });
  } catch (err) { next(err); }
});
EOF
echo "criado: api/src/routes/contato.ts"

# ---------- API: enviador ----------
cat > "$API/notificador.ts" <<'EOF'
// Enviador de lembretes por e-mail e WhatsApp.
// Uso: npm run notificar            (fica rodando; a cada NOTIFICAR_INTERVALO_MIN minutos, padrao 5)
//      npm run notificar -- --uma-vez  (roda uma vez e sai; serve para agendar no cron do servidor)
//      npm run notificar -- --teste-email voce@exemplo.com  (manda um e-mail de teste e sai)
// NOTIFICAR_MODO=simular (padrao) so registra no log; NOTIFICAR_MODO=enviar envia de fato pelos
// canais com credenciais nas variaveis de ambiente.
import nodemailer from 'nodemailer';
import { withMaestro } from './db/transaction.js';
import { logger } from './db/logger.js';

interface Msg { notificacao_id: number; canal: string; destino: string; assunto: string; corpo: string; parametros: Record<string, unknown> }

const env = process.env;
const MODO = env.NOTIFICAR_MODO === 'enviar' ? 'enviar' : 'simular';
const APP_URL = (env.APP_URL ?? 'http://localhost:5173').replace(/\/$/, '');
const INTERVALO_MS = Math.max(1, Number(env.NOTIFICAR_INTERVALO_MIN ?? 5)) * 60_000;
const EMAIL_OK = Boolean(env.SMTP_HOST && env.SMTP_FROM);
const ZAP_OK = Boolean(env.WHATSAPP_TOKEN && env.WHATSAPP_PHONE_ID && env.WHATSAPP_TEMPLATE);

const canais: string[] = MODO === 'simular' ? ['email', 'whatsapp']
  : [EMAIL_OK ? 'email' : '', ZAP_OK ? 'whatsapp' : ''].filter(Boolean);

const transporte = EMAIL_OK ? nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: Number(env.SMTP_PORT ?? 587),
  secure: Number(env.SMTP_PORT ?? 587) === 465,
  auth: env.SMTP_USER ? { user: env.SMTP_USER, pass: env.SMTP_PASS ?? '' } : undefined,
}) : null;

function link(m: Msg): string { return APP_URL + String(m.parametros.caminho ?? '/aluno'); }

async function enviarEmail(m: Msg): Promise<void> {
  if (!transporte) throw new Error('SMTP nao configurado');
  await transporte.sendMail({
    from: env.SMTP_FROM, to: m.destino, subject: m.assunto,
    text: `${m.corpo}\n\nResponder agora: ${link(m)}\n\n—\nVocê recebe este aviso porque autorizou lembretes por e-mail no Programa de Cirurgia de Urgência e Trauma. Para parar, desmarque em ${APP_URL}/aluno/contato`,
  });
}

// Mensagem iniciada pela instituicao no WhatsApp exige modelo (template) aprovado pela Meta.
// Modelo sugerido (4 variaveis, idioma pt_BR), ver docs/notificacoes_v1.0.md:
//   "Lembrete do Programa de Cirurgia de Urgência e Trauma: {{1}} do tema {{2}}. {{3}} Responda em: {{4}}"
async function enviarWhatsapp(m: Msg): Promise<void> {
  const versao = env.WHATSAPP_API_VERSAO ?? 'v21.0';
  const pr = m.parametros;
  const situacao = Number(pr.dias_apos) === -1 ? `Prazo: até ${String(pr.prazo)} (1 hora antes da aula).` : `Pendente há ${String(pr.dias_apos)} dias.`;
  const r = await fetch(`https://graph.facebook.com/${versao}/${env.WHATSAPP_PHONE_ID}/messages`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${env.WHATSAPP_TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      messaging_product: 'whatsapp', to: m.destino.replace(/^\+/, ''), type: 'template',
      template: {
        name: env.WHATSAPP_TEMPLATE, language: { code: env.WHATSAPP_IDIOMA ?? 'pt_BR' },
        components: [{ type: 'body', parameters: [String(pr.teste), String(pr.tema), situacao, link(m)].map((text) => ({ type: 'text', text })) }],
      },
    }),
  });
  if (!r.ok) throw new Error(`WhatsApp respondeu ${r.status}: ${(await r.text()).slice(0, 300)}`);
}

export async function rodadaDeEnvio(): Promise<{ fila: number; enviadas: number; erros: number }> {
  const fila = await withMaestro(null, async (c) => (await c.query('SELECT app.enfileirar_notificacoes() AS n')).rows[0].n as number);
  if (canais.length === 0) return { fila, enviadas: 0, erros: 0 };
  const msgs = await withMaestro(null, async (c) =>
    (await c.query('SELECT * FROM app.notificacoes_reservar($1, 50)', [canais])).rows as Msg[]);
  let enviadas = 0; let erros = 0;
  for (const m of msgs) {
    let situacao = 'enviada'; let erro: string | null = null;
    try {
      if (MODO === 'simular') {
        situacao = 'simulada';
        logger.info({ canal: m.canal, destino: m.destino.replace(/.(?=.{4})/g, '*'), assunto: m.assunto }, 'notificacao simulada');
      } else if (m.canal === 'email') await enviarEmail(m);
      else await enviarWhatsapp(m);
      enviadas++;
    } catch (e) {
      situacao = 'erro'; erro = e instanceof Error ? e.message : String(e); erros++;
      logger.warn({ canal: m.canal, notificacao: m.notificacao_id, erro }, 'falha no envio');
    }
    await withMaestro(null, async (c) => { await c.query('SELECT app.notificacao_resultado($1, $2, $3)', [m.notificacao_id, situacao, erro]); });
  }
  return { fila, enviadas, erros };
}

async function principal(): Promise<void> {
  const iTeste = process.argv.indexOf('--teste-email');
  if (iTeste > 0) {
    const para = process.argv[iTeste + 1] ?? env.SMTP_USER ?? '';
    try {
      await enviarEmail({ notificacao_id: 0, canal: 'email', destino: para, assunto: 'Teste de envio do Programa de Cirurgia de Urgência e Trauma',
        corpo: 'Se você recebeu esta mensagem, o envio de lembretes por e-mail está funcionando.', parametros: { caminho: '/aluno' } });
      console.log(`e-mail de teste enviado para ${para}`);
      process.exit(0);
    } catch (e) { console.error(`falha no envio: ${e instanceof Error ? e.message : String(e)}`); process.exit(1); }
  }
  logger.info({ modo: MODO, canais, email_configurado: EMAIL_OK, whatsapp_configurado: ZAP_OK }, 'enviador de lembretes iniciado');
  const umaVez = process.argv.includes('--uma-vez');
  for (;;) {
    try { logger.info(await rodadaDeEnvio(), 'rodada de envio'); }
    catch (e) { logger.error({ erro: e instanceof Error ? e.message : String(e) }, 'rodada de envio falhou'); }
    if (umaVez) break;
    await new Promise((r) => setTimeout(r, INTERVALO_MS));
  }
  process.exit(0);
}

principal();
EOF
echo "criado: api/src/notificador.ts"

# ---------- API: registrar /contato, dependencia e script ----------
if ! grep -q "contatoRouter" "$API/main.ts"; then
  sed -i "s#^import { testeRouter } from './routes/teste.js';#import { testeRouter } from './routes/teste.js';\nimport { contatoRouter } from './routes/contato.js';#" "$API/main.ts"
  sed -i "s#^app.use('/teste', testeRouter);#app.use('/teste', testeRouter);\napp.use('/contato', contatoRouter);#" "$API/main.ts"
  grep -q "app.use('/contato', contatoRouter)" "$API/main.ts" || { echo "ERRO: nao consegui registrar /contato no main.ts"; exit 1; }
  echo "atualizado: api/src/main.ts (/contato)"
fi
node - "$RAIZ/api/package.json" <<'JS'
const fs = require('fs'); const p = process.argv[2]; const j = JSON.parse(fs.readFileSync(p, 'utf8'));
j.dependencies = j.dependencies || {}; j.devDependencies = j.devDependencies || {}; j.scripts = j.scripts || {};
j.dependencies.nodemailer = j.dependencies.nodemailer || '6.9.16';
j.devDependencies['@types/nodemailer'] = j.devDependencies['@types/nodemailer'] || '6.4.17';
j.scripts.notificar = 'tsx src/notificador.ts';
fs.writeFileSync(p, JSON.stringify(j, null, 2) + '\n');
console.log('atualizado: api/package.json (nodemailer e npm run notificar; rode npm install)');
JS

# ---------- PWA: tela de contato ----------
cat > "$PWA/pages/aluno/Contato.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

interface Contato { email_aviso: string | null; whatsapp: string | null; aceita_email: boolean; aceita_whatsapp: boolean; consentimento_em: string | null }
interface Resposta { contato: Contato | null; email_cadastro: string | null; versao_termo_atual: string }


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

  if (!d) return <p>{msg ?? 'Carregando…'}</p>;
  const st = { fontFamily: 'system-ui, sans-serif', maxWidth: 640, margin: '0 auto', padding: 16, color: '#1c2430' };
  const campo = { display: 'block', width: '100%', padding: 8, fontSize: 16, margin: '4px 0 12px', border: '1px solid #c5ccd6', borderRadius: 6 };
  return (
    <section style={st}>
      <h1 style={{ fontSize: 20 }}>Lembretes dos testes</h1>
      <p>Além do aviso no aplicativo, você pode receber os lembretes por e-mail e WhatsApp: pré-teste 2 perto do prazo (que termina 1 hora antes da aula) e pós-testes pendentes.</p>
      <label>E-mail para os avisos (em branco usa o do cadastro: {d.email_cadastro ?? '—'})
        <input style={campo} type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder={d.email_cadastro ?? ''} />
      </label>
      <label>WhatsApp (com DDD)
        <input style={campo} type="tel" value={zap} onChange={(e) => setZap(e.target.value)} placeholder="(16) 99999-0000" />
      </label>
      <label style={{ display: 'block', margin: '8px 0' }}>
        <input type="checkbox" checked={aEmail} onChange={(e) => setAEmail(e.target.checked)} /> Autorizo lembretes por e-mail
      </label>
      <label style={{ display: 'block', margin: '8px 0' }}>
        <input type="checkbox" checked={aZap} onChange={(e) => setAZap(e.target.checked)} /> Autorizo lembretes por WhatsApp
      </label>
      <p style={{ fontSize: 13, color: '#5b6675' }}>
        Seus dados de contato são usados só para estes lembretes do Programa. Você pode retirar a autorização a qualquer momento nesta tela.
        Termo {d.versao_termo_atual}{d.contato?.consentimento_em ? ` · autorizado em ${new Date(d.contato.consentimento_em).toLocaleDateString('pt-BR')}` : ''}.
      </p>
      {msg && <p role="status" style={{ background: '#eaf1f8', padding: 8, borderRadius: 6 }}>{msg}</p>}
      <button type="button" onClick={salvar} style={{ border: '1px solid #1f4e79', background: '#1f4e79', color: '#fff', borderRadius: 6, padding: '8px 14px', fontSize: 15 }}>Salvar</button>{' '}
      <a href="/aluno">Voltar</a>
    </section>
  );
}
EOF
echo "criado: pwa/src/pages/aluno/Contato.tsx"

if ! grep -q "pages/aluno/Contato.js" "$PWA/App.tsx"; then
  sed -i "s#^import { Testes } from './pages/aluno/Testes.js';#import { Testes } from './pages/aluno/Testes.js';\nimport { Contato } from './pages/aluno/Contato.js';#" "$PWA/App.tsx"
  sed -i "s#^\( *\)<Route path=\"/aluno/testes/\*\" element={<Testes />} />#\1<Route path=\"/aluno/contato\" element={<Contato />} />\n\1<Route path=\"/aluno/testes/*\" element={<Testes />} />#" "$PWA/App.tsx"
  grep -q 'path="/aluno/contato"' "$PWA/App.tsx" || { echo "ERRO: nao consegui registrar a rota de contato"; exit 1; }
  echo "atualizado: pwa/src/App.tsx (/aluno/contato)"
fi
if ! grep -q "/aluno/contato" "$PWA/pages/aluno/Home.tsx"; then
  sed -i 's#<a href="/aluno/testes/T001">Testes do tema T001</a>#<a href="/aluno/testes/T001">Testes do tema T001</a> · <a href="/aluno/contato">Lembretes por e-mail e WhatsApp</a>#' "$PWA/pages/aluno/Home.tsx"
  grep -q "/aluno/contato" "$PWA/pages/aluno/Home.tsx" || { echo "ERRO: nao consegui inserir o link de contato na pagina inicial"; exit 1; }
  echo "atualizado: pwa/src/pages/aluno/Home.tsx"
fi
echo "=== notificacoes por e-mail e WhatsApp instaladas (modo simulado ate haver credenciais) ==="
