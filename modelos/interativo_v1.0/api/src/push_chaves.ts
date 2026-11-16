// Gera as chaves VAPID dos avisos no celular e grava em ~/.config/curso-ue/push.env (so leitura do dono).
// USO: npm run chaves-push     (nao troca chaves que ja existem: trocar invalida as inscricoes dos alunos)
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const dir = path.join(os.homedir(), '.config', 'curso-ue');
const arq = path.join(dir, 'push.env');
if (fs.existsSync(arq)) {
  console.log(`Ja existem chaves em ${arq}. Nada foi trocado.`);
} else {
  const { privateKey, publicKey } = crypto.generateKeyPairSync('ec', { namedCurve: 'prime256v1' });
  const jpriv = privateKey.export({ format: 'jwk' }); const jpub = publicKey.export({ format: 'jwk' });
  const pub = Buffer.concat([Buffer.from([4]), Buffer.from(String(jpub.x), 'base64url'), Buffer.from(String(jpub.y), 'base64url')]).toString('base64url');
  fs.mkdirSync(dir, { recursive: true, mode: 0o700 });
  fs.writeFileSync(arq, `VAPID_PUBLIC=${pub}\nVAPID_PRIVATE=${String(jpriv.d)}\nVAPID_SUBJECT=mailto:coordenacao@cut.invalid\n`, { mode: 0o600 });
  console.log(`Chaves gravadas em ${arq} (so voce le). Reinicie com o subir para os avisos no celular funcionarem.`);
}
