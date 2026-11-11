#!/usr/bin/env bash
# ============================================================
# 11_implementacao_pesquisa_conteudo_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: implementar as rotas de pesquisa (coortes, curva de
# retencao, analise psicometrica) e de conteudo publico
# (artefatos publicados).
#
# USO: bash 11_implementacao_pesquisa_conteudo_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0, 07_implementacao_oauth_v1.0.
# ============================================================
set -euo pipefail

RAIZ="${1:-./programa-cut}"

echo "=== IMPLEMENTACAO PESQUISA E CONTEUDO v1.0 ==="

cat > "$RAIZ/api/src/routes/pesquisa.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const pesquisaRouter = Router();

pesquisaRouter.get('/coortes', async (_req, res, next) => {
  try {
    const coortes = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT c.coorte_id, c.ano_ingresso, c.n_participantes, c.trilha_dominante,
                (SELECT count(*) FROM pesquisa.participante p WHERE p.coorte_id = c.coorte_id) AS n_ativos
           FROM pesquisa.coorte c
          ORDER BY c.ano_ingresso DESC`,
      );
      return rows;
    });

    res.json({ coortes });
  } catch (err) {
    next(err);
  }
});

pesquisaRouter.get('/coortes/:coorteId/retencao', async (req, res, next) => {
  try {
    const coorteId = Number(req.params.coorteId);

    const pontos = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT onda_codigo, ordem_onda, n, p_medio
           FROM pesquisa.v_curva_retencao
          WHERE coorte_id = $1
          ORDER BY ordem_onda NULLS LAST, onda_codigo`,
        [coorteId],
      );
      return rows;
    });

    res.json({ pontos });
  } catch (err) {
    next(err);
  }
});

pesquisaRouter.get('/ondas/:ondaId/itens', async (req, res, next) => {
  try {
    const ondaId = Number(req.params.ondaId);

    const itens = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT ai.item_id, i.enunciado, ai.p, ai.r, ai.n,
                (SELECT count(*) FROM pesquisa.analise_distrator ad
                  WHERE ad.onda_id = ai.onda_id
                    AND ad.alternativa_id IN (SELECT alternativa_id FROM app.alternativa WHERE item_id = ai.item_id)
                    AND ad.classificacao = 'nula') AS n_distratores_nulos
           FROM pesquisa.analise_item ai
           JOIN app.item i ON i.item_id = ai.item_id
          WHERE ai.onda_id = $1
          ORDER BY ai.r ASC NULLS LAST`,
        [ondaId],
      );
      return rows;
    });

    res.json({ itens });
  } catch (err) {
    next(err);
  }
});

pesquisaRouter.get('/ondas/:ondaId/distratores', async (req, res, next) => {
  try {
    const ondaId = Number(req.params.ondaId);

    const distratores = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT ad.alternativa_id, a.item_id, a.ordem, a.texto, a.eh_correta,
                ad.frequencia, ad.classificacao
           FROM pesquisa.analise_distrator ad
           JOIN app.alternativa a ON a.alternativa_id = ad.alternativa_id
          WHERE ad.onda_id = $1
          ORDER BY a.item_id, a.ordem`,
        [ondaId],
      );
      return rows;
    });

    res.json({ distratores });
  } catch (err) {
    next(err);
  }
});

pesquisaRouter.get('/ondas/:ondaId/confiabilidade', async (req, res, next) => {
  try {
    const ondaId = Number(req.params.ondaId);

    const confiabilidade = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT count(*) AS n_itens,
                count(DISTINCT r.tentativa_id) AS n_respondentes,
                round(avg(ai.p), 4) AS p_medio,
                round(avg(ai.r), 4) AS r_medio
           FROM pesquisa.analise_item ai
           LEFT JOIN app.resposta r ON r.item_id = ai.item_id
          WHERE ai.onda_id = $1`,
        [ondaId],
      );
      return rows[0] ?? null;
    });

    res.json(confiabilidade);
  } catch (err) {
    next(err);
  }
});

pesquisaRouter.get('/alertas', async (_req, res, next) => {
  try {
    const alertas = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT ai.onda_id, ai.item_id, i.enunciado, ai.p, ai.r, ai.n,
                CASE
                  WHEN ai.r < 0 THEN 'critico'
                  WHEN ai.r < 0.2 THEN 'atencao'
                  ELSE 'ok'
                END AS severidade
           FROM pesquisa.analise_item ai
           JOIN app.item i ON i.item_id = ai.item_id
          WHERE ai.r < 0.2
          ORDER BY ai.r ASC`,
      );
      return rows;
    });

    res.json({ alertas });
  } catch (err) {
    next(err);
  }
});
EOF

cat > "$RAIZ/api/src/routes/conteudo.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const conteudoRouter = Router();

conteudoRouter.get('/temas/:temaId/artefatos', async (req, res, next) => {
  try {
    const temaId = Number(req.params.temaId);

    const artefatos = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT artefato_id, tipo, versao, titulo, publicado_em
           FROM conteudo.v_artefato_publicado
          WHERE tema_id = $1
          ORDER BY tipo`,
        [temaId],
      );
      return rows;
    });

    res.json({ artefatos });
  } catch (err) {
    next(err);
  }
});

conteudoRouter.get('/artefatos/:artefatoId', async (req, res, next) => {
  try {
    const artefatoId = Number(req.params.artefatoId);

    const artefato = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT a.artefato_id, a.tema_id, a.tipo, a.versao, a.titulo, a.corpo,
                a.publicado_em,
                (SELECT json_agg(json_build_object(
                          'ordem', b.ordem,
                          'tipo', b.tipo,
                          'conteudo', b.conteudo
                        ) ORDER BY b.ordem)
                   FROM conteudo.bloco b WHERE b.artefato_id = a.artefato_id) AS blocos
           FROM conteudo.artefato a
          WHERE a.artefato_id = $1 AND a.status = 'publicado'`,
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

conteudoRouter.get('/design-tokens', async (_req, res, next) => {
  try {
    const tokens = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT categoria, nome, valor, descricao
           FROM conteudo.design_token
          ORDER BY categoria, nome`,
      );
      return rows;
    });

    res.json({ tokens });
  } catch (err) {
    next(err);
  }
});

conteudoRouter.get('/assinaturas', async (_req, res, next) => {
  try {
    const assinaturas = await withMaestro(null, async (client) => {
      const { rows } = await client.query(
        `SELECT tipo_artefato, descricao, tokens_obrigatorios
           FROM conteudo.assinatura_artefato
          ORDER BY tipo_artefato`,
      );
      return rows;
    });

    res.json({ assinaturas });
  } catch (err) {
    next(err);
  }
});
EOF

echo "=== IMPLEMENTACAO PESQUISA E CONTEUDO CONCLUIDA ==="
echo "Verifique: ls $RAIZ/api/src/routes/pesquisa.ts $RAIZ/api/src/routes/conteudo.ts"
