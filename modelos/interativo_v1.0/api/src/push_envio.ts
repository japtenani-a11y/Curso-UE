import crypto from 'node:crypto';

// Envio de avisos no celular (Web Push) sem biblioteca externa: so o "sinal", sem conteudo, assinado com a chave
// VAPID do curso. Ao receber o sinal, o aplicativo busca o texto do aviso no servidor (rota /push/pendentes).
// As chaves ficam em ~/.config/curso-ue/push.env (gerar com: npm run chaves-push), nunca no codigo.
const PUB = process.env.VAPID_PUBLIC ?? '';
const PRIV = process.env.VAPID_PRIVATE ?? '';
const SUJEITO = process.env.VAPID_SUBJECT ?? 'mailto:coordenacao@cut.invalid';

export const pushConfigurado = (): boolean => Boolean(PUB && PRIV);
export const chavePublica = (): string => PUB;
const b64u = (b: Buffer): string => b.toString('base64url');

function chavePrivada(): crypto.KeyObject {
  const pub = Buffer.from(PUB, 'base64url'); // 65 bytes: 0x04 | x | y
  return crypto.createPrivateKey({ key: { kty: 'EC', crv: 'P-256', d: PRIV, x: b64u(pub.subarray(1, 33)), y: b64u(pub.subarray(33, 65)) }, format: 'jwk' });
}

// Token VAPID (RFC 8292): JWT ES256 com o servico de push como "aud".
export function jwtVapid(endpoint: string, agora = Date.now()): string {
  const h = b64u(Buffer.from(JSON.stringify({ typ: 'JWT', alg: 'ES256' })));
  const p = b64u(Buffer.from(JSON.stringify({ aud: new URL(endpoint).origin, exp: Math.floor(agora / 1000) + 12 * 3600, sub: SUJEITO })));
  const assinatura = crypto.sign('sha256', Buffer.from(`${h}.${p}`), { key: chavePrivada(), dsaEncoding: 'ieee-p1363' });
  return `${h}.${p}.${b64u(assinatura)}`;
}

// 'expirado' = o aparelho cancelou ou trocou a inscricao (desativar no banco)
export async function enviarSinal(endpoint: string): Promise<'ok' | 'expirado'> {
  if (!/^https:\/\//.test(endpoint)) return 'expirado';
  const r = await fetch(endpoint, {
    method: 'POST', body: '',
    headers: { TTL: '86400', Urgency: 'normal', Authorization: `vapid t=${jwtVapid(endpoint)}, k=${PUB}` },
  });
  if (r.status === 404 || r.status === 410) return 'expirado';
  if (!r.ok) throw new Error(`servico de push respondeu ${r.status}: ${(await r.text()).slice(0, 200)}`);
  return 'ok';
}
