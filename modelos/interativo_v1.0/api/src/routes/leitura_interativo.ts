import type { Router } from 'express';
import fs from 'node:fs';
import path from 'node:path';
import { withMaestro } from '../db/transaction.js';

// Rotas do material interativo, acrescentadas ao /leitura:
//   GET  /leitura/estado/:codigo          tudo o que o aluno guardou no tema (respostas, checklist, onde parou)
//   PUT  /leitura/estado/:codigo/:peca    grava o estado de uma peca ({ estado, em }); regras no banco (82)
//   GET  /leitura/continuar               ultima peca estudada (cartao "Continuar de onde parou" do Inicio)
//   GET  /leitura/slides/:codigo          quais imagens e audios de slide existem para o tema
//   GET  /leitura/slides/:codigo/:arquivo slide_NN.png ou slide_NN.mp3 (so com login e com a aula liberada)
// Imagens e audios ficam em programa-cut/slides/<CODIGO>/ (fora do GitHub e fora da pasta publica do aplicativo).
const REVISORES = ['admin', 'data_steward', 'curador', 'preceptor', 'docente'];
const ERROS: Record<string, number> = { sem_sessao: 401, nao_liberado: 403, tema_nao_encontrado: 404 };

function pastaSlides(codigo: string): string {
  return path.join(path.resolve(process.env.SLIDES_DIR ?? path.join(process.cwd(), '..', 'slides')), codigo);
}
function cod(x: unknown): string { return String(x).replace(/[^A-Za-z0-9]/g, '').toUpperCase(); }

export function registrarInterativo(router: Router): void {
  router.get('/estado/:codigo', async (req, res, next) => {
    try {
      const r = req as { pessoaId?: number };
      if (!r.pessoaId) { res.status(401).json({ erro: 'sem_sessao' }); return; }
      const e = await withMaestro(null, async (c) => (await c.query('SELECT app.estado_tema($1) AS e', [cod(req.params.codigo)])).rows[0]?.e ?? {});
      res.setHeader('Cache-Control', 'no-store');
      res.json({ estado: e });
    } catch (err) { next(err); }
  });

  router.put('/estado/:codigo/:peca', async (req, res, next) => {
    try {
      const r = req as { pessoaId?: number };
      if (!r.pessoaId) { res.status(401).json({ erro: 'sem_sessao' }); return; }
      const peca = String(req.params.peca);
      if (!/^[a-z_]{2,30}$/.test(peca)) { res.status(400).json({ erro: 'peca_invalida' }); return; }
      const corpo = (req.body ?? {}) as { estado?: unknown; em?: string };
      if (typeof corpo.estado !== 'object' || corpo.estado === null || Array.isArray(corpo.estado)) { res.status(400).json({ erro: 'estado_invalido' }); return; }
      const em = corpo.em && !Number.isNaN(Date.parse(corpo.em)) ? corpo.em : new Date().toISOString();
      const gravado = await withMaestro(null, async (c) =>
        (await c.query('SELECT app.salvar_estado($1, $2, $3::jsonb, $4::timestamptz) AS e', [cod(req.params.codigo), peca, JSON.stringify(corpo.estado), em])).rows[0]?.e);
      res.json({ estado: gravado });
    } catch (err) {
      const m = String((err as Error).message ?? '');
      const k = Object.keys(ERROS).find((x) => m.includes(x));
      if (k) { res.status(ERROS[k]!).json({ erro: k }); return; }
      next(err);
    }
  });

  router.get('/continuar', async (req, res, next) => {
    try {
      const r = req as { pessoaId?: number };
      if (!r.pessoaId) { res.status(401).json({ erro: 'sem_sessao' }); return; }
      const linha = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.continuar_estudo()')).rows[0] ?? null);
      res.setHeader('Cache-Control', 'no-store');
      res.json({ continuar: linha });
    } catch (err) { next(err); }
  });

  async function podeVerSlides(pessoaId: number, papel: string | undefined, codigo: string): Promise<boolean> {
    if (REVISORES.includes(papel ?? '')) return true;
    return withMaestro(null, async (c) => (await c.query(
      `SELECT app.etapa_liberada($2, tema_id) >= 3 AS ok FROM app.tema WHERE upper(replace(codigo, '-', '')) = $1`,
      [codigo, pessoaId])).rows[0]?.ok === true);
  }

  router.get('/slides/:codigo', async (req, res, next) => {
    try {
      const r = req as { pessoaId?: number; papel?: string };
      if (!r.pessoaId) { res.status(401).json({ erro: 'sem_sessao' }); return; }
      const codigo = cod(req.params.codigo);
      if (!(await podeVerSlides(r.pessoaId, r.papel, codigo))) { res.status(403).json({ erro: 'nao_liberado' }); return; }
      const dir = pastaSlides(codigo);
      const nomes = fs.existsSync(dir) ? fs.readdirSync(dir) : [];
      const num = (ext: string) => nomes.map((n) => n.match(new RegExp(`^slide_(\\d{2,3})\\.${ext}$`))?.[1]).filter(Boolean).map(Number).sort((a, b) => a - b);
      res.setHeader('Cache-Control', 'no-store');
      res.json({ imagens: num('png'), audios: num('mp3') });
    } catch (err) { next(err); }
  });

  router.get('/slides/:codigo/:arquivo', async (req, res, next) => {
    try {
      const r = req as { pessoaId?: number; papel?: string };
      if (!r.pessoaId) { res.status(401).end(); return; }
      const codigo = cod(req.params.codigo);
      const arquivo = String(req.params.arquivo);
      if (!/^slide_\d{2,3}\.(png|mp3)$/.test(arquivo)) { res.status(400).end(); return; }
      if (!(await podeVerSlides(r.pessoaId, r.papel, codigo))) { res.status(403).end(); return; }
      const arq = path.join(pastaSlides(codigo), arquivo);
      if (!fs.existsSync(arq)) { res.status(404).end(); return; }
      res.setHeader('Cross-Origin-Resource-Policy', 'same-site');
      res.setHeader('Cache-Control', 'private, max-age=3600');
      res.sendFile(arq);
    } catch (err) { next(err); }
  });
}
