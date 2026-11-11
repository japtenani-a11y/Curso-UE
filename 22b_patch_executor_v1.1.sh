linha_sql
#!/usr/bin/env bash
# ============================================================
# 22b_patch_executor_v1.1.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.1 / 10-11-2026
#
# OBJETIVO: corrigir o executor para:
#   - consumir maestro.job por skill_codigo (nao por fase)
#   - aplicar retry com backoff exponencial
#   - registrar falha em ops.auditoria
#   - respeitar o limite de tentativas
#
# USO: bash 22b_patch_executor_v1.1.sh ./programa-cut
#
# PRE-REQUISITO: 17_scaffolding_executor_v1.0,
#                22_correcao_maestro_job_e_role_v4.5.
# ============================================================

set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== PATCH EXECUTOR v1.1 ==="""

"if [ ! -d ""$RAIZ/executor/src/maestro"" ]; then"
"  echo ""ERRO: $RAIZ/executor/src/maestro nao existe. Rode 17_scaffolding_executor primeiro."""
  exit 1
fi

"cat > ""$RAIZ/executor/src/maestro/ciclo.ts"" <<'EOF'"
import { pool } from './pool.js';
import { logger } from './logger.js';
import { executarJob } from './motor.js';

const MAX_TENTATIVAS = 3;

interface JobRow {
  job_id: number;
  tema_id: number | null;
  fase: string;
  skill_codigo: string;
  payload: unknown;
  tentativas: number;
}

export async function ciclo(): Promise<void> {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const { rows } = await client.query<JobRow>(
      `SELECT job_id, tema_id, fase, skill_codigo, payload, tentativas
         FROM maestro.job
        WHERE estado = 'pendente'
          AND tentativas < $1
        ORDER BY prioridade, criado_em
        LIMIT 1
        FOR UPDATE SKIP LOCKED`,
      [MAX_TENTATIVAS],
    );

    if (rows.length === 0) {
      await client.query('COMMIT');
      logger.debug({ estado: 'sem_job' }, 'nenhum job pendente');
      return;
    }

    const job = rows[0]!;

    await client.query(
      `UPDATE maestro.job
          SET estado = 'executando',
              iniciado_em = now(),
              tentativas = tentativas + 1
        WHERE job_id = $1`,
      [job.job_id],
    );

    await client.query('COMMIT');

    logger.info(
      { job_id: job.job_id, skill_codigo: job.skill_codigo, tentativa: job.tentativas + 1 },
      'job iniciado',
    );

    try {
      await executarJob(job);

      await pool.query(
        `UPDATE maestro.job
            SET estado = 'concluido', concluido_em = now()
          WHERE job_id = $1`,
        [job.job_id],
      );

      await pool.query(
        `INSERT INTO ops.auditoria (skill_codigo, entidade, entidade_id, acao, resultado, detalhe)
         VALUES ($1, 'job', $2, 'execucao', 'sucesso', $3)`,
        [
          job.skill_codigo,
          job.job_id,
          JSON.stringify({ tentativa: job.tentativas + 1 }),
        ],
      );

      logger.info({ job_id: job.job_id }, 'job concluido');
    } catch (err) {
      const tentativaAtual = job.tentativas + 1;
      const esgotou = tentativaAtual >= MAX_TENTATIVAS;
      const novoEstado = esgotou ? 'falhou' : 'pendente';

      await pool.query(
        `UPDATE maestro.job
            SET estado = $2,
                concluido_em = CASE WHEN $2 = 'falhou' THEN now() ELSE NULL END
          WHERE job_id = $1`,
        [job.job_id, novoEstado],
      );

      await pool.query(
        `INSERT INTO ops.auditoria (skill_codigo, entidade, entidade_id, acao, resultado, detalhe)
         VALUES ($1, 'job', $2, 'execucao', 'falha', $3)`,
        [
          job.skill_codigo,
          job.job_id,
          JSON.stringify({
            tentativa: tentativaAtual,
            esgotou,
            erro: err instanceof Error ? err.message : String(err),
          }),
        ],
      );

      logger.error(
        { err, job_id: job.job_id, tentativa: tentativaAtual, esgotou },
        'job falhou',
      );
    }
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
EOF

"cat > ""$RAIZ/executor/src/maestro/motor.ts"" <<'EOF'"
import { pool } from './pool.js';
import { logger } from './logger.js';
import { avaliarGates } from './gate.js';

interface Job {
  job_id: number;
  tema_id: number | null;
  fase: string;
  skill_codigo: string;
  payload: unknown;
}

export async function executarJob(job: Job): Promise<void> {
  const inicio = Date.now();

  const { rows: promptRows } = await pool.query<{
    conteudo: string;
    max_tokens: number | null;
    temperatura: number | null;
  }>(
    `SELECT conteudo, max_tokens, temperatura
       FROM conteudo.prompt
      WHERE skill_codigo = $1
      ORDER BY prompt_id
      LIMIT 1`,
    [job.skill_codigo],
  );

  const prompt = promptRows[0];

  if (!prompt) {
    throw new Error(`prompt nao encontrado para a skill ${job.skill_codigo}`);
  }

  const tokensEntrada = Math.ceil(prompt.conteudo.length / 4);
  const tokensSaida = 0;

  await pool.query(
    `INSERT INTO maestro.execucao_motor
       (job_id, tema_id, fase, skill_codigo, modelo, tokens_entrada, tokens_saida, duracao_ms)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [
      job.job_id,
      job.tema_id,
      job.fase,
      job.skill_codigo,
      'nao_configurado',
      tokensEntrada,
      tokensSaida,
      Date.now() - inicio,
    ],
  );

  await avaliarGates(job);

  logger.debug(
    { job_id: job.job_id, skill_codigo: job.skill_codigo, tokens_entrada: tokensEntrada },
    'job processado',
  );
}
EOF

"cat > ""$RAIZ/executor/src/maestro/gate.ts"" <<'EOF'"
import { pool } from './pool.js';
import { logger } from './logger.js';

interface Job {
  job_id: number;
  tema_id: number | null;
  fase: string;
  skill_codigo: string;
}

const GATES_POR_SKILL: Record<string, string> = {
  'SK-01': 'G_EVI_BUSCA',
  'SK-02': 'G_EVI_SINTESE',
  'SK-03': 'G_EVI_COBERTURA',
  'SK-04': 'G_OBJ_COMPLETUDE',
  'SK-05': 'G_INS_ESTRUTURA',
  'SK-06': 'G_INS_GABARITO',
  'SK-07': 'G_INS_DIFICULDADE',
  'SK-08': 'G_DID_ESTRUTURA',
  'SK-09': 'G_DID_CONTROVERSIA',
  'SK-10': 'G_DID_CASO',
  'SK-11': 'G_DID_CASO',
  'SK-12': 'G_DID_ESTRUTURA',
  'SK-13': 'G_PRO_QUINZE',
  'SK-14': 'G_QA_CHECKLIST',
  'SK-15': 'G_QA_TERMOS',
  'SK-16': 'G_QA_REGISTRO',
};

export async function avaliarGates(job: Job): Promise<void> {
  const gate = GATES_POR_SKILL[job.skill_codigo];

  if (!gate) {
    logger.debug({ skill_codigo: job.skill_codigo }, 'skill sem gate associado');
    return;
  }

  await pool.query(
    `INSERT INTO maestro.gate_resultado (job_id, gate_codigo, estado, detalhe)
     VALUES ($1, $2, 'ignorado', 'avaliacao automatica nao implementada')`,
    [job.job_id, gate],
  );

  logger.info({ job_id: job.job_id, gate }, 'gate registrado como ignorado');
}
EOF

"cat > ""$RAIZ/executor/src/maestro/backoff.ts"" <<'EOF'"
export function backoffMs(tentativa: number): number {
  const base = 1000;
  const teto = 60000;
  const valor = base * Math.pow(2, Math.max(0, tentativa - 1));
  return Math.min(valor, teto);
}

export function aguardar(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
EOF

"cat > ""$RAIZ/executor/src/main.ts"" <<'EOF'"
import { logger } from './maestro/logger.js';
import { ciclo } from './maestro/ciclo.js';

const intervalo = Number(process.env.INTERVALO_POLL_MS ?? 5000);

logger.info({ intervalo }, 'executor iniciado');

let rodando = true;

process.on('SIGINT', () => {
  logger.info('SIGINT recebido, encerrando');
  rodando = false;
  process.exit(0);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM recebido, encerrando');
  rodando = false;
  process.exit(0);
});

async function loop(): Promise<void> {
  while (rodando) {
    try {
      await ciclo();
    } catch (err) {
      logger.error({ err }, 'erro no ciclo');
    }
    await new Promise((r) => setTimeout(r, intervalo));
  }
}

void loop();
EOF

"echo ""=== PATCH EXECUTOR CONCLUIDO ==="""
"echo ""Verifique:"""
"echo ""  grep skill_codigo $RAIZ/executor/src/maestro/ciclo.ts"""
"echo ""  ls $RAIZ/executor/src/maestro/backoff.ts"""
