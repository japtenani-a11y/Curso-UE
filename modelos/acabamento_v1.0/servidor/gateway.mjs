// Porta unica do servidor de revisao: entrega o aplicativo (pwa/dist) e repassa /api/* para a API.
// Uso: node gateway.mjs <pasta pwa/dist> [porta=8080] [api=http://127.0.0.1:3000]
// Sem dependencias. Acrescenta os cabecalhos de seguranca e bloqueia indexacao e enquadramento.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const DIST = path.resolve(process.argv[2] ?? './pwa/dist');
const PORTA = Number(process.argv[3] ?? 8080);
const API = new URL(process.argv[4] ?? 'http://127.0.0.1:3000');
const TIPOS = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml',
  '.json': 'application/json', '.webmanifest': 'application/manifest+json', '.txt': 'text/plain; charset=utf-8', '.png': 'image/png', '.ico': 'image/x-icon' };

const SEGURANCA = {
  'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'",
  'Strict-Transport-Security': 'max-age=31536000',
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'Referrer-Policy': 'no-referrer',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=(), payment=(), usb=()',
  'Cross-Origin-Opener-Policy': 'same-origin',
  'X-Robots-Tag': 'noindex, nofollow, noarchive',
};

function arquivo(res, alvo, cache) {
  const ext = path.extname(alvo);
  res.writeHead(200, { ...SEGURANCA, 'Content-Type': TIPOS[ext] ?? 'application/octet-stream', 'Cache-Control': cache });
  fs.createReadStream(alvo).pipe(res);
}

http.createServer((req, res) => {
  const url = new URL(req.url ?? '/', 'http://x');
  if (url.pathname === '/api' || url.pathname.startsWith('/api/')) {
    const destino = url.pathname.slice(4) || '/';
    const ip = (req.socket.remoteAddress ?? '').replace(/^::ffff:/, '');
    const proxy = http.request({ hostname: API.hostname, port: API.port, method: req.method, path: destino + url.search,
      headers: { ...req.headers, host: API.host, 'x-forwarded-for': req.headers['x-forwarded-for'] ?? ip, 'x-forwarded-proto': 'https' } }, (r) => {
      res.writeHead(r.statusCode ?? 502, { ...r.headers, ...SEGURANCA });
      r.pipe(res);
    });
    proxy.on('error', () => { res.writeHead(502, SEGURANCA); res.end('API fora do ar'); });
    req.pipe(proxy);
    return;
  }
  const limpo = path.normalize(decodeURIComponent(url.pathname)).replace(/^(\.\.[/\\])+/, '');
  const alvo = path.join(DIST, limpo);
  if (alvo.startsWith(DIST) && fs.existsSync(alvo) && fs.statSync(alvo).isFile()) {
    arquivo(res, alvo, limpo.startsWith('/assets/') ? 'public, max-age=31536000, immutable' : 'no-cache');
    return;
  }
  arquivo(res, path.join(DIST, 'index.html'), 'no-cache'); // rotas do aplicativo (SPA)
}).listen(PORTA, '127.0.0.1', () => console.log(`gateway em http://127.0.0.1:${PORTA} (aplicativo: ${DIST}; API: ${API.href})`));
