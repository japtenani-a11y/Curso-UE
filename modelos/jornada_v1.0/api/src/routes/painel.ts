import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

// Painel de acompanhamento e pesquisa: notas, avaliacoes (NPS), duvidas e uso do material.
// Coordenacao (admin, curador, data_steward) ve o nome do aluno; pesquisador ve o codigo do participante.
// Com ?formato=csv devolve o arquivo para planilha (separador ";", UTF-8 com BOM).
export const painelRouter = Router();
painelRouter.use(requireRole(['admin', 'curador', 'data_steward', 'pesquisador']));

const CONSULTAS: Record<string, string> = {
  notas: 'SELECT * FROM app.painel_notas()',
  avaliacoes: 'SELECT * FROM app.painel_avaliacoes()',
  mensagens: 'SELECT * FROM app.painel_mensagens()',
  uso: 'SELECT * FROM app.painel_uso()',
  questoes: 'SELECT * FROM app.painel_questoes()',
  presenca: 'SELECT * FROM app.painel_presenca()',
  estudo: 'SELECT * FROM app.painel_estudo()',
  producao: 'SELECT * FROM app.fila_producao()',
  coleta: 'SELECT * FROM app.painel_coleta()',
  leitura: 'SELECT * FROM app.painel_leitura()',
};

function csv(linhas: Record<string, unknown>[]): string {
  if (linhas.length === 0) return '﻿';
  const cols = Object.keys(linhas[0] as Record<string, unknown>);
  const cel = (v: unknown) => {
    if (v === null || v === undefined) return '';
    const s = v instanceof Date ? v.toISOString() : String(v);
    return /[";\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  return '﻿' + [cols.join(';'), ...linhas.map((l) => cols.map((c) => cel(l[c])).join(';'))].join('\r\n');
}

painelRouter.get('/:conjunto', async (req, res, next) => {
  try {
    const sql = CONSULTAS[String(req.params.conjunto)];
    if (!sql) { res.status(404).json({ erro: 'conjunto_desconhecido' }); return; }
    const { papel, linhas } = await withMaestro(null, async (c) => ({
      papel: (await c.query('SELECT app.papel_painel() AS p')).rows[0]?.p as string | null,
      linhas: (await c.query(sql)).rows as Record<string, unknown>[],
    }));
    if (!papel) { res.status(403).json({ erro: 'proibido' }); return; }
    if (req.query.formato === 'csv') {
      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader('Content-Disposition', `attachment; filename="${String(req.params.conjunto)}_${new Date().toISOString().slice(0, 10)}.csv"`);
      res.send(csv(linhas));
      return;
    }
    res.json({ papel, linhas });
  } catch (err) { next(err); }
});
