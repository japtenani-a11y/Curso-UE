linha_sql
#!/usr/bin/env bash
# ============================================================
# 17_scaffolding_executor_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: criar os seis arquivos do executor: main, ciclo,
# motor, gate, logger e pool. O executor consome maestro.job
# por skill_codigo e grava conteudo.artefato como rascunho.
#
# USO: bash 17_scaffolding_executor_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0, 22_correcao_maestro_job_e_role_v4.5.
# ============================================================
set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== SCAFFOLDING EXECUTOR v1.0 ==="""

"mkdir -p ""$RAIZ""/executor/src/{maestro,motor,tipos}"

"cat > ""$RAIZ/executor/src/maestro/pool.ts"" <<'EOF'"
import pg from 'pg';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.MAESTRO_DATABASE_URL,
  max: 5,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on('error', (err) => {
  console.error('Erro inesperado no pool do executor:', err);
});
EOF

"cat > ""$RAIZ/executor/src/maestro/logger.ts"" <<'EOF'"
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  base: { servico: 'executor' },
});
EOF

"cat > ""$RAIZ/executor/src/maestro/ciclo.ts"" <<'EOF'"
import { pool } from './pool.js';
import { logger } from './logger.js';
import { executarJob } from './motor.js';

export async function ciclo(): Promise<void> {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const { rows } = await client.query<{
      job_id: number;
      tema_id: number | null;
      fase: string;
      skill_codigo: string;
      payload: unknown;
    }>(
      `SELECT job_id, tema_id, fase, skill_codigo, payload
         FROM maestro.job
        WHERE estado = 'pendente'
        ORDER BY prioridade, criado_em
        LIMIT 1
        FOR UPDATE SKIP LOCKED`,
    );

    if (rows.length === 0) {
      await client.query('COMMIT');
      logger.debug({ estado: 'sem_job' }, 'nenhum job pendente');
      return;
    }

    const job = rows[0]!;

    await client.query(
      `UPDATE maestro.job
          SET estado = 'executando', iniciado_em = now(), tentativas = tentativas + 1
        WHERE job_id = $1`,
      [job.job_id],
    );

    await client.query('COMMIT');

    logger.info({ job_id: job.job_id, skill_codigo: job.skill_codigo }, 'job iniciado');

    try {
      await executarJob(job);
      await pool.query(
        `UPDATE maestro.job SET estado = 'concluido', concluido_em = now() WHERE job_id = $1`,
        [job.job_id],
      );
      logger.info({ job_id: job.job_id }, 'job concluido');
    } catch (err) {
      await pool.query(
        `UPDATE maestro.job SET estado = 'falhou', concluido_em = now() WHERE job_id = $1`,
        [job.job_id],
      );
      logger.error({ err, job_id: job.job_id }, 'job falhou');
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

  const { rows: promptRows } = await pool.query<{ conteudo: string; max_tokens: number }>(
    `SELECT conteudo, max_tokens
       FROM conteudo.prompt
      WHERE skill_codigo = $1
      ORDER BY prompt_id
      LIMIT 1`,
    [job.skill_codigo],
  );

  const prompt = promptRows[0];

  if (!prompt) {
    logger.warn({ skill_codigo: job.skill_codigo }, 'prompt nao encontrado para a skill');
    return;
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

"cat > ""$RAIZ/executor/src/tipos/job.ts"" <<'EOF'"
export interface Job {
  job_id: number;
  tema_id: number | null;
  fase: string;
  skill_codigo: string;
  estado: 'pendente' | 'executando' | 'concluido' | 'falhou' | 'cancelado';
  prioridade: number;
  payload: unknown;
}

export interface GateResultado {
  gate_codigo: string;
  estado: 'aprovado' | 'reprovado' | 'ignorado';
  detalhe: string | null;
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

"echo ""=== SCAFFOLDING EXECUTOR CONCLUIDO ==="""
"echo ""Verifique: ls $RAIZ/executor/src/maestro/"""
