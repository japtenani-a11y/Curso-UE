linha_sql
#!/usr/bin/env bash
# ============================================================
# 08a_implementacao_aluno_core_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: implementar as rotas core do aluno: listar ondas,
# iniciar tentativa, responder item, submeter tentativa.
#
# USO: bash 08a_implementacao_aluno_core_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0, 07_implementacao_oauth_v1.0.
#
# ATENCAO: este script cria a versao CORE de aluno.ts. O script
# 08b_implementacao_aluno_resto_v1.0 SOBRESCREVE este arquivo
# com a versao completa. Rodar 08a e depois 08b, nunca em
# paralelo.
# ============================================================

set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== IMPLEMENTACAO ALUNO CORE v1.0 ==="""

"cat > ""$RAIZ/api/src/routes/aluno.ts"" <<'EOF'"
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const alunoRouter = Router();

alunoRouter.get('/ondas', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const ondas = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT oi.onda_id, oi.onda_codigo, oi.ordem_onda,
                oi.data_abertura, oi.data_fechamento, oi.status,
                (SELECT count(*) FROM app.item_selecionado ise
                  WHERE ise.onda_id = oi.onda_id) AS n_itens,
                (SELECT t.submetida_em FROM app.tentativa t
                  WHERE t.onda_id = oi.onda_id AND t.pessoa_id = $1) AS submetida_em
           FROM app.onda_instancia oi
          WHERE oi.status IN ('aberta','fechada')
          ORDER BY oi.ordem_onda`,
        [pessoaId],
      );
      return rows;
    });

    res.json({ ondas });
  } catch (err) {
    next(err);
  }
});

alunoRouter.post('/ondas/:ondaId/tentativa', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    const ondaId = Number(req.params.ondaId);

    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const tentativa = await withMaestro(null, async (client) => {
      const { rows } = await client.query<{ tentativa_id: number }>(
        `INSERT INTO app.tentativa (onda_id, pessoa_id)
         VALUES ($1, $2)
         ON CONFLICT (onda_id, pessoa_id) DO UPDATE
            SET iniciada_em = app.tentativa.iniciada_em
         RETURNING tentativa_id`,
        [ondaId, pessoaId],
      );
      return rows[0] ?? null;
    });

    res.status(201).json({ tentativa_id: tentativa?.tentativa_id });
  } catch (err) {
    next(err);
  }
});

alunoRouter.get('/tentativas/:tentativaId/itens', async (req, res, next) => {
  try {
    const tentativaId = Number(req.params.tentativaId);

    const itens = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT i.item_id, i.enunciado, ise.ordem_apresentada,
                json_agg(json_build_object(
                  'alternativa_id', a.alternativa_id,
                  'ordem', a.ordem,
                  'texto', a.texto
                ) ORDER BY a.ordem) AS alternativas
           FROM app.tentativa t
           JOIN app.item_selecionado ise ON ise.onda_id = t.onda_id
           JOIN app.item i ON i.item_id = ise.item_id
           JOIN app.alternativa a ON a.item_id = i.item_id
          WHERE t.tentativa_id = $1
          GROUP BY i.item_id, i.enunciado, ise.ordem_apresentada
          ORDER BY ise.ordem_apresentada`,
        [tentativaId],
      );
      return rows;
    });

    res.json({ itens });
  } catch (err) {
    next(err);
  }
});

alunoRouter.post('/tentativas/:tentativaId/resposta', async (req, res, next) => {
  try {
    const tentativaId = Number(req.params.tentativaId);
    const { item_id, alternativa_id, tempo_resposta_ms } = req.body as {
      item_id?: number;
      alternativa_id?: number;
      tempo_resposta_ms?: number;
    };

    if (!item_id || !alternativa_id) {
      res.status(400).json({ erro: 'parametros_ausentes' });
      return;
    }

    await withMaestro(null, async (client) => {
      await client.query(
        `INSERT INTO app.resposta (tentativa_id, item_id, alternativa_id, tempo_resposta_ms)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (tentativa_id, item_id) DO NOTHING`,
        [tentativaId, item_id, alternativa_id, tempo_resposta_ms ?? null],
      );
    });

    res.status(201).json({ ok: true });
  } catch (err) {
    next(err);
  }
});

alunoRouter.post('/tentativas/:tentativaId/submeter', async (req, res, next) => {
  try {
    const tentativaId = Number(req.params.tentativaId);

    await withMaestro(null, async (client) => {
      await client.query(
        `UPDATE app.tentativa
            SET submetida_em = now()
          WHERE tentativa_id = $1 AND submetida_em IS NULL`,
        [tentativaId],
      );
    });

    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});
EOF

"echo ""=== IMPLEMENTACAO ALUNO CORE CONCLUIDA ==="""
"echo ""Verifique: ls $RAIZ/api/src/routes/aluno.ts"""
