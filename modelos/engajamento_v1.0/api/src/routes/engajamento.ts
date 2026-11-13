import { Router } from 'express';
import type { Request } from 'express';
import { withMaestro } from '../db/transaction.js';

// Temas (catalogo e D0 dos opcionais), avaliacao (NPS e satisfacao), duvidas e feedback,
// uso do material, notas, ranking e consentimento de pesquisa. Tudo da pessoa logada (RLS).
export const engajamentoRouter = Router();

const pessoa = (req: Request) => (req as Request & { pessoaId?: number }).pessoaId ?? null;
const FERRAMENTA = /^[a-z_0-9]{2,40}$/;
const ESCALAS = ['apresentacao', 'complexidade', 'conteudo', 'objetividade', 'clareza', 'tempo_gasto', 'frequencia_testes', 'importancia'] as const;
const FILTROS = ['geral', 'especialidade', 'ano', 'subgrupo'];
export const VERSAO_TCLE = 'tcle-v1 (12/11/2026)';

function int(v: unknown, min: number, max: number): number | null {
  if (v === null || v === undefined || v === '') return null;
  const n = Math.round(Number(v));
  return Number.isFinite(n) && n >= min && n <= max ? n : null;
}

engajamentoRouter.use((req, res, next) => {
  if (!pessoa(req)) { res.status(401).json({ erro: 'sem_sessao' }); return; }
  next();
});

engajamentoRouter.get('/catalogo', async (_req, res, next) => {
  try {
    const temas = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.catalogo_temas()')).rows);
    res.json({ temas });
  } catch (err) { next(err); }
});

engajamentoRouter.post('/temas/:codigo/agendar', async (req, res, next) => {
  try {
    const d0 = new Date(String((req.body as { d0?: string }).d0 ?? ''));
    if (Number.isNaN(d0.getTime())) { res.status(422).json({ erro: 'data_invalida' }); return; }
    const ondas = await withMaestro(null, async (c) =>
      (await c.query('SELECT * FROM app.agendar_tema_opcional($1, $2)', [String(req.params.codigo), d0.toISOString()])).rows);
    res.json({ ok: true, ondas });
  } catch (err) {
    const m = err instanceof Error ? err.message : '';
    const conhecido = ['tema_nao_encontrado', 'tema_principal_tem_data_do_grupo', 'data_invalida', 'tema_ja_iniciado'].find((k) => m.includes(k));
    if (conhecido) { res.status(422).json({ erro: conhecido }); return; }
    next(err);
  }
});

engajamentoRouter.get('/avaliacoes', async (req, res, next) => {
  try {
    const tema = String(req.query.tema ?? '');
    const rows = await withMaestro(null, async (c) => (await c.query(
      `SELECT a.ferramenta, a.nps, a.apresentacao, a.complexidade, a.conteudo, a.objetividade, a.clareza, a.tempo_gasto,
              a.frequencia_testes, a.importancia, a.minutos_gastos, a.comentario
         FROM app.avaliacao a LEFT JOIN app.tema t ON t.tema_id = a.tema_id
        WHERE ($1 = '' AND a.tema_id IS NULL) OR upper(replace(t.codigo,'-','')) = upper(replace($1,'-',''))`, [tema])).rows);
    res.json({ avaliacoes: rows });
  } catch (err) { next(err); }
});

engajamentoRouter.post('/avaliacoes', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const ferramenta = String(b.ferramenta ?? '');
    if (!FERRAMENTA.test(ferramenta)) { res.status(422).json({ erro: 'ferramenta_invalida' }); return; }
    const valores = ESCALAS.map((k) => int(b[k], 1, 5));
    const nps = int(b.nps, 0, 10);
    const minutos = int(b.minutos_gastos, 0, 600);
    const comentario = typeof b.comentario === 'string' ? b.comentario.slice(0, 2000) : null;
    const tema = typeof b.tema === 'string' && b.tema ? b.tema : null;
    await withMaestro(null, async (c) => {
      await c.query(
        `INSERT INTO app.avaliacao (pessoa_id, tema_id, ferramenta, nps, apresentacao, complexidade, conteudo, objetividade,
                                    clareza, tempo_gasto, frequencia_testes, importancia, minutos_gastos, comentario)
         SELECT app.pessoa_atual(), (SELECT tema_id FROM app.tema WHERE upper(replace(codigo,'-','')) = upper(replace($1,'-',''))),
                $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
         ON CONFLICT (pessoa_id, coalesce(tema_id, 0), ferramenta) DO UPDATE SET
           nps = EXCLUDED.nps, apresentacao = EXCLUDED.apresentacao, complexidade = EXCLUDED.complexidade,
           conteudo = EXCLUDED.conteudo, objetividade = EXCLUDED.objetividade, clareza = EXCLUDED.clareza,
           tempo_gasto = EXCLUDED.tempo_gasto, frequencia_testes = EXCLUDED.frequencia_testes,
           importancia = EXCLUDED.importancia, minutos_gastos = EXCLUDED.minutos_gastos,
           comentario = EXCLUDED.comentario, atualizado_em = now()`,
        [tema ?? '', ferramenta, nps, ...valores, minutos, comentario]);
    });
    res.json({ ok: true });
  } catch (err) { next(err); }
});

engajamentoRouter.get('/mensagens', async (_req, res, next) => {
  try {
    const rows = await withMaestro(null, async (c) => (await c.query(
      `SELECT m.mensagem_id, t.codigo AS tema, m.ferramenta, m.tipo, m.texto, m.status, m.resposta, m.util,
              m.criado_em, m.respondida_em
         FROM app.mensagem_aluno m LEFT JOIN app.tema t ON t.tema_id = m.tema_id
        ORDER BY m.criado_em DESC LIMIT 200`)).rows);
    res.json({ mensagens: rows });
  } catch (err) { next(err); }
});

engajamentoRouter.post('/mensagens', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as { tema?: string; ferramenta?: string; tipo?: string; texto?: string };
    const tipo = b.tipo === 'feedback' ? 'feedback' : 'duvida';
    const texto = String(b.texto ?? '').trim().slice(0, 4000);
    if (texto.length < 3) { res.status(422).json({ erro: 'texto_curto' }); return; }
    const ferramenta = b.ferramenta && FERRAMENTA.test(b.ferramenta) ? b.ferramenta : null;
    const r = await withMaestro(null, async (c) => (await c.query(
      `INSERT INTO app.mensagem_aluno (pessoa_id, tema_id, ferramenta, tipo, texto)
       SELECT app.pessoa_atual(), (SELECT tema_id FROM app.tema WHERE upper(replace(codigo,'-','')) = upper(replace($1,'-',''))), $2, $3, $4
       RETURNING mensagem_id, status`, [b.tema ?? '', ferramenta, tipo, texto])).rows[0]);
    res.json({ ok: true, ...r });
  } catch (err) { next(err); }
});

engajamentoRouter.post('/mensagens/:id/util', async (req, res, next) => {
  try {
    const util = (req.body as { util?: boolean }).util === true;
    await withMaestro(null, async (c) => { await c.query('UPDATE app.mensagem_aluno SET util = $2 WHERE mensagem_id = $1', [Number(req.params.id), util]); });
    res.json({ ok: true });
  } catch (err) { next(err); }
});

engajamentoRouter.post('/uso', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as { tema?: string; tipo?: string; segundos?: number };
    const s = int(b.segundos, 1, 7200);
    if (!s || !b.tipo || !FERRAMENTA.test(b.tipo)) { res.json({ ok: false }); return; }
    await withMaestro(null, async (c) => {
      await c.query(
        `INSERT INTO app.uso_material (pessoa_id, tema_id, tipo, segundos)
         SELECT app.pessoa_atual(), t.tema_id, $2, $3 FROM app.tema t WHERE upper(replace(t.codigo,'-','')) = upper(replace($1,'-',''))`,
        [b.tema ?? '', b.tipo, s]);
    });
    res.json({ ok: true });
  } catch (err) { next(err); }
});

engajamentoRouter.get('/notas', async (_req, res, next) => {
  try {
    const notas = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.minhas_notas()')).rows);
    res.json({ notas });
  } catch (err) { next(err); }
});

engajamentoRouter.get('/ranking', async (req, res, next) => {
  try {
    const filtro = FILTROS.includes(String(req.query.filtro)) ? String(req.query.filtro) : 'geral';
    const tema = req.query.tema ? String(req.query.tema) : null;
    const linhas = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.ranking($1, $2)', [filtro, tema])).rows);
    res.json({ filtro, linhas });
  } catch (err) { next(err); }
});

engajamentoRouter.get('/consentimento', async (_req, res, next) => {
  try {
    const r = await withMaestro(null, async (c) => (await c.query('SELECT aceito, versao_tcle, em FROM app.consentimento_pesquisa')).rows[0] ?? null);
    res.json({ consentimento: r, versao_atual: VERSAO_TCLE });
  } catch (err) { next(err); }
});

engajamentoRouter.post('/consentimento', async (req, res, next) => {
  try {
    const aceito = (req.body as { aceito?: boolean }).aceito === true;
    await withMaestro(null, async (c) => {
      await c.query(
        `INSERT INTO app.consentimento_pesquisa (pessoa_id, aceito, versao_tcle) VALUES (app.pessoa_atual(), $1, $2)
         ON CONFLICT (pessoa_id) DO UPDATE SET aceito = EXCLUDED.aceito, versao_tcle = EXCLUDED.versao_tcle, em = now()`, [aceito, VERSAO_TCLE]);
    });
    res.json({ ok: true, aceito });
  } catch (err) { next(err); }
});
