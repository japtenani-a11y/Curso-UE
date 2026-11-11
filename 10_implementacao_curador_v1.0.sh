linha_sql
#!/usr/bin/env bash
# ============================================================
# 10_implementacao_curador_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: implementar as rotas do curador: temas, artefatos,
# checklist, publicacao, fontes e auditoria.
#
# USO: bash 10_implementacao_curador_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0, 07_implementacao_oauth_v1.0.
# ============================================================
set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== IMPLEMENTACAO CURADOR v1.0 ==="""

"cat > ""$RAIZ/api/src/routes/curador.ts"" <<'EOF'"
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const curadorRouter = Router();

curadorRouter.get('/temas', async (req, res, next) => {
  try {
    const temas = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT t.tema_id, t.codigo, t.titulo, t.grau, t.carga_horaria, t.dificuldade,
                c.ano_ingresso,
                (SELECT count(*) FROM conteudo.artefato a
                  WHERE a.tema_id = t.tema_id AND a.status = 'publicado') AS n_publicados,
                (SELECT count(*) FROM conteudo.artefato a
                  WHERE a.tema_id = t.tema_id AND a.status = 'rascunho') AS n_rascunhos
           FROM app.tema t
           JOIN app.ciclo c ON c.ciclo_id = t.ciclo_id
          ORDER BY c.ano_ingresso DESC, t.codigo`,
      );
      return rows;
    });

    res.json({ temas });
  } catch (err) {
    next(err);
  }
});

curadorRouter.get('/temas/:temaId/artefatos', async (req, res, next) => {
  try {
    const temaId = Number(req.params.temaId);

    const artefatos = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT a.artefato_id, a.tipo, a.versao, a.status, a.titulo,
                a.checklist_conforme, a.publicado_em, a.revisado_em,
                (SELECT count(*) FROM conteudo.bloco b WHERE b.artefato_id = a.artefato_id) AS n_blocos,
                (SELECT count(*) FROM conteudo.checklist_item ci
                  WHERE ci.artefato_id = a.artefato_id AND ci.obrigatorio AND NOT ci.conforme) AS n_pendentes
           FROM conteudo.artefato a
          WHERE a.tema_id = $1
          ORDER BY a.tipo, a.versao DESC`,
        [temaId],
      );
      return rows;
    });

    res.json({ artefatos });
  } catch (err) {
    next(err);
  }
});

curadorRouter.get('/artefatos/:artefatoId', async (req, res, next) => {
  try {
    const artefatoId = Number(req.params.artefatoId);

    const artefato = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT a.*,
                (SELECT json_agg(json_build_object(
                          'bloco_id', b.bloco_id,
                          'ordem', b.ordem,
                          'tipo', b.tipo,
                          'conteudo', b.conteudo
                        ) ORDER BY b.ordem)
                   FROM conteudo.bloco b WHERE b.artefato_id = a.artefato_id) AS blocos,
                (SELECT json_agg(json_build_object(
                          'checklist_item_id', ci.checklist_item_id,
                          'descricao', ci.descricao,
                          'conforme', ci.conforme,
                          'obrigatorio', ci.obrigatorio
                        ) ORDER BY ci.checklist_item_id)
                   FROM conteudo.checklist_item ci WHERE ci.artefato_id = a.artefato_id) AS checklist
           FROM conteudo.artefato a
          WHERE a.artefato_id = $1`,
        [artefatoId],
      );
      return rows[0] ?? null;
    });

    if (!artefato) {
      res.status(404).json({ erro: 'artefato_nao_encontrado' });
      return;
    }

    res.json(artefato);
  } catch (err) {
    next(err);
  }
});

curadorRouter.patch('/artefatos/:artefatoId/checklist/:itemId', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    const artefatoId = Number(req.params.artefatoId);
    const itemId = Number(req.params.itemId);
    const { conforme } = req.body as { conforme?: boolean };

    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }
    if (typeof conforme !== 'boolean') {
      res.status(400).json({ erro: 'parametro_conforme_obrigatorio' });
      return;
    }

    await withMaestro(null, async (client) => {
      await client.query(
        `UPDATE conteudo.checklist_item
            SET conforme = $1, verificado_por = $2, verificado_em = now()
          WHERE checklist_item_id = $3 AND artefato_id = $4`,
        [conforme, pessoaId, itemId, artefatoId],
      );

      await client.query(
        `UPDATE conteudo.artefato a
            SET checklist_conforme = NOT EXISTS (
                  SELECT 1 FROM conteudo.checklist_item ci
                   WHERE ci.artefato_id = a.artefato_id
                     AND ci.obrigatorio AND NOT ci.conforme
                )
          WHERE a.artefato_id = $1`,
        [artefatoId],
      );
    });

    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

curadorRouter.post('/artefatos/:artefatoId/publicar', async (req, res, next) => {
  try {
    const artefatoId = Number(req.params.artefatoId);

    const publicado = await withMaestro(null, async (client) => {
      const { rows } = await client.query<{ publicado_em: string }>(
        `UPDATE conteudo.artefato
            SET status = 'publicado', publicado_em = now()
          WHERE artefato_id = $1 AND checklist_conforme
          RETURNING publicado_em`,
        [artefatoId],
      );
      return rows[0] ?? null;
    });

    if (!publicado) {
      res.status(422).json({
        erro: 'checklist_incompleto',
        detalhe: 'Artefato nao pode ser publicado sem checklist conforme.',
      });
      return;
    }

    res.json({ ok: true, publicado_em: publicado.publicado_em });
  } catch (err) {
    next(err);
  }
});

curadorRouter.get('/temas/:temaId/fontes', async (req, res, next) => {
  try {
    const temaId = Number(req.params.temaId);

    const fontes = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT fonte_id, camada, titulo, autores, ano, doi, pmid, url,
                (trecho_literal IS NOT NULL) AS tem_trecho
           FROM conteudo.fonte
          WHERE tema_id = $1
          ORDER BY camada, ano DESC`,
        [temaId],
      );
      return rows;
    });

    res.json({ fontes });
  } catch (err) {
    next(err);
  }
});

curadorRouter.get('/temas/:temaId/auditoria', async (req, res, next) => {
  try {
    const temaId = Number(req.params.temaId);

    const auditoria = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT 'artefato_sem_bloco' AS tipo, a.artefato_id, a.titulo AS detalhe
           FROM conteudo.artefato a
          WHERE a.tema_id = $1 AND a.status = 'publicado'
            AND NOT EXISTS (SELECT 1 FROM conteudo.bloco b WHERE b.artefato_id = a.artefato_id)
         UNION ALL
         SELECT 'fonte_sem_identificador', f.fonte_id, f.titulo
           FROM conteudo.fonte f
          WHERE f.tema_id = $1 AND f.doi IS NULL AND f.pmid IS NULL
         UNION ALL
         SELECT 'termo_variante_nao_resolvido', tv.termo_variante_id, tv.termo_variante
           FROM conteudo.termo_variante tv
          WHERE tv.tema_id = $1 AND NOT tv.resolvido`,
        [temaId],
      );
      return rows;
    });

    res.json({ auditoria, total: auditoria.length });
  } catch (err) {
    next(err);
  }
});

curadorRouter.get('/gates', async (req, res, next) => {
  try {
    const gates = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT gate_codigo,
                count(*) FILTER (WHERE estado = 'aprovado') AS aprovados,
                count(*) FILTER (WHERE estado = 'reprovado') AS reprovados,
                count(*) AS total,
                round(100.0 * count(*) FILTER (WHERE estado = 'aprovado') / nullif(count(*), 0), 1) AS taxa
           FROM maestro.gate_resultado
          WHERE ocorrido_em >= now() - interval '8 weeks'
          GROUP BY gate_codigo
          ORDER BY taxa ASC NULLS LAST`,
      );
      return rows;
    });

    res.json({ gates });
  } catch (err) {
    next(err);
  }
});
EOF

"echo ""=== IMPLEMENTACAO CURADOR CONCLUIDA ==="""
"echo ""Verifique: ls $RAIZ/api/src/routes/curador.ts"""
