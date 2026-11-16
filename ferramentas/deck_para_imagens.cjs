// Converte um deck (conteudo/<TEMA>/slides/project: deck.json + slides/*.html) em imagens slide_NN.png, sem as notas.
// USO: NODE_PATH=$(npm root -g) node ferramentas/deck_para_imagens.cjs conteudo/T001/slides/project conteudo/T001/slides/imagens
const { chromium } = require('playwright'); const fs = require('fs'); const path = require('path');
(async () => {
  const [dir, out] = process.argv.slice(2);
  const deck = JSON.parse(fs.readFileSync(path.join(dir, 'deck.json'), 'utf8'));
  const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 1920, height: 1080 } });
  let n = 0;
  for (const id of deck.order) {
    n++;
    const sec = fs.readFileSync(path.join(dir, 'slides', id + '.html'), 'utf8');
    await p.setContent(`<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;width:1920px;height:1080px;overflow:hidden} section{position:relative;box-sizing:border-box;width:1920px;height:1080px;margin:0} *{box-sizing:border-box} p,h1,h2,h3,ul,ol{margin:0} aside{display:none !important}</style></head><body>${sec}</body></html>`, { waitUntil: 'load' });
    await p.waitForTimeout(150);
    await p.screenshot({ path: path.join(out, `slide_${String(n).padStart(2, '0')}.png`) });
  }
  await b.close(); console.log(n);
})();
