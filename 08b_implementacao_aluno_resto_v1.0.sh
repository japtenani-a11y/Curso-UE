#!/usr/bin/env bash
# ============================================================
# 08b_implementacao_aluno_resto_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: completar as rotas do aluno: resultado, feedback,
# progresso e historico. Este script SOBRESCREVE o arquivo
# aluno.ts criado pelo 08a.
#
# USO: bash 08b_implementacao_aluno_resto_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 08a_implementacao_aluno_core_v1.0.
#
# ATENCAO: rodar SEMPRE depois do 08a. Nunca em paralelo.
# ============================================================

set -euo pipefail

RAIZ="${1:-./programa-cut}"

echo "=== IMPLEMENTACAO ALUNO RESTO v1.0 ==="

cat > "$RAIZ/api/src/routes/aluno.ts" <<'EOF'
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

alunoRouter.get('/tentativas/:tentativaId/resultado', async (req, res, next) => {
  try {
    const tentativaId = Number(req.params.tentativaId);

    const resultado = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT count(*) AS total,
                count(*) FILTER (WHERE a.eh_correta) AS acertos,
                round(100.0 * count(*) FILTER (WHERE a.eh_correta) / nullif(count(*), 0), 1) AS percentual
           FROM app.resposta r
           JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
          WHERE r.tentativa_id = $1`,
        [tentativaId],
      );
      return rows[0] ?? null;
    });

    res.json(resultado);
  } catch (err) {
    next(err);
  }
});

alunoRouter.get('/tentativas/:tentativaId/feedback', async (req, res, next) => {
  try {
    const tentativaId = Number(req.params.tentativaId);

    const feedback = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT i.item_id, i.enunciado,
                a.texto AS alternativa_escolhida,
                a.eh_correta,
                ga.texto AS alternativa_correta,
                i.ancora
           FROM app.resposta r
           JOIN app.item i ON i.item_id = r.item_id
           JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
           LEFT JOIN app.alternativa ga ON ga.alternativa_id = i.gabarito_alternativa_id
          WHERE r.tentativa_id = $1
          ORDER BY r.ordem_apresentada`,
        [tentativaId],
      );
      return rows;
    });

    res.json({ feedback });
  } catch (err) {
    next(err);
  }
});

alunoRouter.get('/progresso', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const progresso = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT oi.onda_codigo,
                count(r.resposta_id) AS respondidas,
                (SELECT count(*) FROM app.item_selecionado ise WHERE ise.onda_id = oi.onda_id) AS total,
                t.submetida_em
           FROM app.tentativa t
           JOIN app.onda_instancia oi ON oi.onda_id = t.onda_id
           LEFT JOIN app.resposta r ON r.tentativa_id = t.tentativa_id
          WHERE t.pessoa_id = $1
          GROUP BY oi.onda_codigo, oi.onda_id, t.submetida_em
          ORDER BY oi.ordem_onda`,
        [pessoaId],
      );
      return rows;
    });

    res.json({ progresso });
  } catch (err) {
    next(err);
  }
});

alunoRouter.get('/historico', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const historico = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT oi.onda_codigo, t.iniciada_em, t.submetida_em,
                count(r.resposta_id) AS respondidas,
                count(*) FILTER (WHERE a.eh_correta) AS acertos
           FROM app.tentativa t
           JOIN app.onda_instancia oi ON oi.onda_id = t.onda_id
           LEFT JOIN app.resposta r ON r.tentativa_id = t.tentativa_id
           LEFT JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
          WHERE t.pessoa_id = $1
          GROUP BY oi.onda_codigo, oi.ordem_onda, t.iniciada_em, t.submetida_em
          ORDER BY oi.ordem_onda`,
        [pessoaId],
      );
      return rows;
    });

    res.json({ historico });
  } catch (err) {
    next(err);
  }
});
EOF

echo "=== IMPLEMENTACAO ALUNO RESTO CONCLUIDA ==="
echo "Verifique: wc -l $RAIZ/api/src/routes/aluno.ts"
