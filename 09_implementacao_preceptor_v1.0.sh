linha_sql
#!/usr/bin/env bash
# ============================================================
# 09_implementacao_preceptor_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: implementar as rotas do preceptor: modulos, tarefas,
# verificacao e alunos.
#
# USO: bash 09_implementacao_preceptor_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0, 07_implementacao_oauth_v1.0.
#
# CORRECAO v4.6: o codigo 23514 (violacao de CHECK) agora
# retorna 422, conforme o contrato. Antes retornava 403.
# ============================================================

set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== IMPLEMENTACAO PRECEPTOR v1.0 ==="""

"cat > ""$RAIZ/api/src/routes/preceptor.ts"" <<'EOF'"
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const preceptorRouter = Router();

preceptorRouter.get('/modulos', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const modulos = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT m.modulo_id, m.codigo, m.nome, m.ordem,
                pm.carga_maxima,
                (SELECT count(*) FROM app.tarefa t WHERE t.modulo_id = m.modulo_id) AS n_tarefas
           FROM app.preceptor_modulo pm
           JOIN app.modulo m ON m.modulo_id = pm.modulo_id
          WHERE pm.preceptor_id = $1 AND pm.revogado_em IS NULL
          ORDER BY m.ordem`,
        [pessoaId],
      );
      return rows;
    });

    res.json({ modulos });
  } catch (err) {
    next(err);
  }
});

preceptorRouter.get('/modulos/:moduloId/tarefas', async (req, res, next) => {
  try {
    const moduloId = Number(req.params.moduloId);

    const tarefas = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT t.tarefa_id, t.tipo, t.descricao, t.prazo, t.status,
                p.nome_completo AS aluno,
                (SELECT v.conforme FROM app.verificacao v
                  WHERE v.tarefa_id = t.tarefa_id
                  ORDER BY v.verificado_em DESC LIMIT 1) AS conforme
           FROM app.tarefa t
           JOIN app.pessoa p ON p.pessoa_id = t.pessoa_id
          WHERE t.modulo_id = $1
          ORDER BY t.prazo NULLS LAST, t.criado_em`,
        [moduloId],
      );
      return rows;
    });

    res.json({ tarefas });
  } catch (err) {
    next(err);
  }
});

preceptorRouter.post('/tarefas/:tarefaId/verificar', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    const tarefaId = Number(req.params.tarefaId);
    const { parecer, conforme } = req.body as { parecer?: string; conforme?: boolean };

    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }
    if (!parecer || typeof conforme !== 'boolean') {
      res.status(400).json({ erro: 'parametros_ausentes' });
      return;
    }

    await withMaestro(null, async (client) => {
      await client.query(
        `INSERT INTO app.verificacao (tarefa_id, preceptor_id, parecer, conforme)
         VALUES ($1, $2, $3, $4)`,
        [tarefaId, pessoaId, parecer, conforme],
      );

      await client.query(
        `UPDATE app.tarefa
            SET status = $2
          WHERE tarefa_id = $1`,
        [tarefaId, conforme ? 'verificada' : 'rejeitada'],
      );
    });

    res.status(201).json({ ok: true });
  } catch (err) {
    next(err);
  }
});

preceptorRouter.get('/alunos', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }

    const alunos = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT DISTINCT p.pessoa_id, p.nome_completo, p.email_primario,
                pa.grau,
                (SELECT count(*) FROM app.tarefa t
                  WHERE t.pessoa_id = p.pessoa_id AND t.status = 'pendente') AS tarefas_pendentes
           FROM app.preceptor_modulo pm
           JOIN app.modulo m ON m.modulo_id = pm.modulo_id
           JOIN app.modulo_tema mt ON mt.modulo_id = m.modulo_id
           JOIN app.tema te ON te.tema_id = mt.tema_id
           JOIN app.ciclo c ON c.ciclo_id = te.ciclo_id
           JOIN app.posicao_anual pa ON pa.ano_letivo = c.ano_ingresso AND pa.perfil_id = 6
           JOIN app.pessoa p ON p.pessoa_id = pa.pessoa_id
          WHERE pm.preceptor_id = $1 AND pm.revogado_em IS NULL
          ORDER BY p.nome_completo`,
        [pessoaId],
      );
      return rows;
    });

    res.json({ alunos });
  } catch (err) {
    next(err);
  }
});

preceptorRouter.get('/alunos/:alunoId/progresso', async (req, res, next) => {
  try {
    const alunoId = Number(req.params.alunoId);

    const progresso = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT oi.onda_codigo,
                count(r.resposta_id) AS respondidas,
                count(*) FILTER (WHERE a.eh_correta) AS acertos,
                t.submetida_em
           FROM app.tentativa t
           JOIN app.onda_instancia oi ON oi.onda_id = t.onda_id
           LEFT JOIN app.resposta r ON r.tentativa_id = t.tentativa_id
           LEFT JOIN app.alternativa a ON a.alternativa_id = r.alternativa_id
          WHERE t.pessoa_id = $1
          GROUP BY oi.onda_codigo, oi.ordem_onda, t.submetida_em
          ORDER BY oi.ordem_onda`,
        [alunoId],
      );
      return rows;
    });

    res.json({ progresso });
  } catch (err) {
    next(err);
  }
});
EOF

"echo ""=== IMPLEMENTACAO PRECEPTOR CONCLUIDA ==="""
"echo ""Verifique: ls $RAIZ/api/src/routes/preceptor.ts"""
