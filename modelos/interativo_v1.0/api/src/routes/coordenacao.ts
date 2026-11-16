import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Aba "Para revisar" do painel: propostas dos agentes da coordenacao (duvidas, conteudo, pecas, atrasados, indicadores).
// So a coordenacao decide. Aprovar executa a acao; alterar aplica a versao editada; vetar exige o motivo, que o agente
// le na rodada seguinte. A regra de quem pode decidir esta no banco (app.decidir_proposta).
export const coordenacaoRouter = Router();
coordenacaoRouter.use(requireRole(['admin', 'curador', 'data_steward']));

coordenacaoRouter.get('/propostas', async (req, res, next) => {
  try {
    const status = req.query.status === 'decididas' ? 'decididas' : 'aguardando';
    const r = await withMaestro(null, async (c) => ({
      propostas: (await c.query('SELECT * FROM app.painel_propostas($1)', [status])).rows,
      agentes: (await c.query('SELECT * FROM app.painel_agentes()')).rows,
    }));
    res.json(r);
  } catch (err) { next(err); }
});

const ERROS = ['so_coordenacao', 'proposta_nao_encontrada', 'proposta_ja_decidida', 'decisao_invalida', 'motivo_obrigatorio',
  'escolha_a_decisao', 'lembrete_sem_texto', 'resposta_curta', 'fonte_nao_encontrada'];

// Aprova de uma vez o que o agente sugere liberar (respostas, lembretes, lancamentos, parecer "aprovar", peca "pronta", fonte); o resto fica para conferir.
// Regra no banco: app.proposta_sugere_liberar e app.aprovar_sugeridas (97).
coordenacaoRouter.post('/propostas/aprovar-sugeridas', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const agente = typeof b.agente === 'string' && /^[a-z_]{2,30}$/.test(b.agente) ? b.agente : null;
    const r = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.aprovar_sugeridas($1)', [agente])).rows[0]);
    res.json({ ok: true, aprovadas: r?.aprovadas ?? 0, com_erro: r?.com_erro ?? 0, ficaram: r?.ficaram ?? 0 });
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    if (m.includes('so_coordenacao')) { res.status(403).json({ erro: 'so_coordenacao' }); return; }
    next(err);
  }
});

coordenacaoRouter.post('/propostas/:id/decidir', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const b = (req.body ?? {}) as Record<string, unknown>;
    const decisao = String(b.decisao ?? '');
    if (!Number.isInteger(id) || id <= 0 || !['aprovar', 'alterar', 'vetar'].includes(decisao)) { res.status(400).json({ erro: 'dados_invalidos' }); return; }
    const final = b.final && typeof b.final === 'object' ? JSON.stringify(b.final) : null;
    if (final && final.length > 20000) { res.status(400).json({ erro: 'texto_longo_demais' }); return; }
    const motivo = b.motivo ? String(b.motivo).slice(0, 2000) : null;
    const r = await withMaestro(null, async (c) => (await c.query('SELECT app.decidir_proposta($1, $2, $3::jsonb, $4) AS status', [id, decisao, final, motivo])).rows[0]);
    res.json({ ok: true, status: r?.status });
  } catch (err) {
    const m = (err as { message?: string }).message ?? '';
    const e = ERROS.find((x) => m.includes(x));
    if (e) { res.status(e === 'so_coordenacao' ? 403 : 422).json({ erro: e, detalhe: m }); return; }
    next(err);
  }
});
