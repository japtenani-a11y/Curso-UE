linha_sql
#!/usr/bin/env bash
# ============================================================
# 24_pwa_telas_restantes_v1.0.sh
# Sistema de Producao Curricular e Coleta Cientifica
# Programa de Cirurgia de Urgencia e Trauma
# Versao 1.0 / 10-11-2026
#
# OBJETIVO: criar as telas restantes do PWA: preceptor, curador
# e pesquisa, mais o componente GraficoRetencao.
#
# USO: bash 24_pwa_telas_restantes_v1.0.sh ./programa-cut
#
# PRE-REQUISITO: 06_scaffolding_v1.0.
#
# CORRECAO v4.6: GraficoRetencao consome design tokens e exibe
# intervalo de confianca. Antes usava cor hardcoded e nao
# exibia IC.
# ============================================================
set -euo pipefail

"RAIZ=""${1:-./programa-cut}"""

"echo ""=== PWA TELAS RESTANTES v1.0 ==="""

"mkdir -p ""$RAIZ""/pwa/src/pages/{aluno,preceptor,curador,pesquisa}"
"mkdir -p ""$RAIZ""/pwa/src/components"

"cat > ""$RAIZ/pwa/src/pages/aluno/Home.tsx"" <<'EOF'"
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Onda {
  onda_id: number;
  onda_codigo: string;
  ordem_onda: number;
  status: string;
  n_itens: number;
  submetida_em: string | null;
}

export function AlunoHome() {
  const [ondas, setOndas] = useState<Onda[]>([]);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    apiGet<{ ondas: Onda[] }>('/aluno/ondas')
      .then((d) => setOndas(d.ondas))
      .catch(() => setErro('Falha ao carregar ondas'));
  }, []);

"  if (erro) return <p role=""alert"">{erro}</p>;"

  return (
    <section>
      <h1>Minhas ondas</h1>
      <ul>
        {ondas.map((o) => (
          <li key={o.onda_id}>
            <strong>{o.onda_codigo}</strong> — {o.n_itens} itens —{' '}
            {o.submetida_em ? 'submetida' : 'pendente'}
          </li>
        ))}
      </ul>
    </section>
  );
}
EOF

"cat > ""$RAIZ/pwa/src/pages/preceptor/Home.tsx"" <<'EOF'"
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Modulo {
  modulo_id: number;
  codigo: string;
  nome: string;
  n_tarefas: number;
}

export function PreceptorHome() {
  const [modulos, setModulos] = useState<Modulo[]>([]);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    apiGet<{ modulos: Modulo[] }>('/preceptor/modulos')
      .then((d) => setModulos(d.modulos))
      .catch(() => setErro('Falha ao carregar modulos'));
  }, []);

"  if (erro) return <p role=""alert"">{erro}</p>;"

  return (
    <section>
      <h1>Meus modulos</h1>
      <ul>
        {modulos.map((m) => (
          <li key={m.modulo_id}>
            <strong>{m.codigo}</strong> — {m.nome} — {m.n_tarefas} tarefas
          </li>
        ))}
      </ul>
    </section>
  );
}
EOF

"cat > ""$RAIZ/pwa/src/pages/curador/Home.tsx"" <<'EOF'"
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';

interface Tema {
  tema_id: number;
  codigo: string;
  titulo: string;
  n_publicados: number;
  n_rascunhos: number;
}

interface Gate {
  gate_codigo: string;
  aprovados: number;
  reprovados: number;
  total: number;
  taxa: number | null;
}

export function CuradorHome() {
  const [temas, setTemas] = useState<Tema[]>([]);
  const [gates, setGates] = useState<Gate[]>([]);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([
      apiGet<{ temas: Tema[] }>('/curador/temas'),
      apiGet<{ gates: Gate[] }>('/curador/gates'),
    ])
      .then(([t, g]) => {
        setTemas(t.temas);
        setGates(g.gates);
      })
      .catch(() => setErro('Falha ao carregar dados do curador'));
  }, []);

"  if (erro) return <p role=""alert"">{erro}</p>;"

  return (
    <section>
      <h1>Painel do curador</h1>

      <h2>Temas</h2>
      <table>
        <thead>
          <tr>
            <th>Codigo</th>
            <th>Titulo</th>
            <th>Publicados</th>
            <th>Rascunhos</th>
          </tr>
        </thead>
        <tbody>
          {temas.map((t) => (
            <tr key={t.tema_id}>
              <td>{t.codigo}</td>
              <td>{t.titulo}</td>
              <td>{t.n_publicados}</td>
              <td>{t.n_rascunhos}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>Gates</h2>
      <table>
        <thead>
          <tr>
            <th>Gate</th>
            <th>Aprovados</th>
            <th>Reprovados</th>
            <th>Taxa</th>
          </tr>
        </thead>
        <tbody>
          {gates.map((g) => (
            <tr key={g.gate_codigo}>
              <td>{g.gate_codigo}</td>
              <td>{g.aprovados}</td>
              <td>{g.reprovados}</td>
              <td>{g.taxa ?? '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  );
}
EOF

"cat > ""$RAIZ/pwa/src/pages/pesquisa/Home.tsx"" <<'EOF'"
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { GraficoRetencao, type PontoRetencao } from '../../components/GraficoRetencao.js';

interface Coorte {
  coorte_id: number;
  ano_ingresso: number;
  n_participantes: number;
}

export function PesquisaHome() {
  const [coortes, setCoortes] = useState<Coorte[]>([]);
  const [pontos, setPontos] = useState<PontoRetencao[]>([]);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    apiGet<{ coortes: Coorte[] }>('/pesquisa/coortes')
      .then(async (d) => {
        setCoortes(d.coortes);
        const primeira = d.coortes[0];
        if (primeira) {
          const r = await apiGet<{ pontos: PontoRetencao[] }>(
            `/pesquisa/coortes/${primeira.coorte_id}/retencao`,
          );
          setPontos(r.pontos);
        }
      })
      .catch(() => setErro('Falha ao carregar dados de pesquisa'));
  }, []);

"  if (erro) return <p role=""alert"">{erro}</p>;"

  return (
    <section>
      <h1>Pesquisa</h1>
      <p>Coortes: {coortes.length}</p>
      <GraficoRetencao pontos={pontos} />
    </section>
  );
}
EOF

"cat > ""$RAIZ/pwa/src/components/GraficoRetencao.tsx"" <<'EOF'"
export interface PontoRetencao {
  onda_codigo: string;
  ordem_onda: number | null;
  n: number;
  p_medio: number;
}

interface Props {
  pontos: PontoRetencao[];
}

const LARGURA = 480;
const ALTURA = 240;
const MARGEM = { topo: 20, direita: 20, baixo: 40, esquerda: 50 };

function ic95(p: number, n: number): { inferior: number; superior: number } {
  if (n <= 0) return { inferior: p, superior: p };
  const erro = 1.96 * Math.sqrt((p * (1 - p)) / n);
  return {
    inferior: Math.max(0, p - erro),
    superior: Math.min(1, p + erro),
  };
}

export function GraficoRetencao({ pontos }: Props) {
  if (pontos.length === 0) {
    return <p>Sem dados de retencao.</p>;
  }

  const larguraUtil = LARGURA - MARGEM.esquerda - MARGEM.direita;
  const alturaUtil = ALTURA - MARGEM.topo - MARGEM.baixo;

  const x = (i: number): number =>
    MARGEM.esquerda + (pontos.length === 1 ? larguraUtil / 2 : (i / (pontos.length - 1)) * larguraUtil);

  const y = (v: number): number => MARGEM.topo + (1 - v) * alturaUtil;

  const linha = pontos
    .map((p, i) => `${i === 0 ? 'M' : 'L'} ${x(i).toFixed(1)} ${y(p.p_medio).toFixed(1)}`)
    .join(' ');

  return (
    <figure>
      <svg
        width={LARGURA}
        height={ALTURA}
"        role=""img"""
"        aria-label=""Curva de retencao por onda"""
        style={{ background: 'var(--cor-neutro-100, #FFFFFF)' }}
      >
        <line
          x1={MARGEM.esquerda}
          y1={y(0)}
          x2={LARGURA - MARGEM.direita}
          y2={y(0)}
"          stroke=""var(--cor-neutro-700, #424242)"""
          strokeWidth={1}
        />
        <line
          x1={MARGEM.esquerda}
          y1={y(1)}
          x2={LARGURA - MARGEM.direita}
          y2={y(1)}
"          stroke=""var(--cor-neutro-700, #424242)"""
          strokeWidth={1}
        />

        {pontos.map((p, i) => {
          const { inferior, superior } = ic95(p.p_medio, p.n);
          return (
            <line
              key={`ic-${p.onda_codigo}`}
              x1={x(i)}
              y1={y(inferior)}
              x2={x(i)}
              y2={y(superior)}
"              stroke=""var(--cor-acento, #C8963E)"""
              strokeWidth={2}
              opacity={0.5}
            />
          );
        })}

"        <path d={linha} fill=""none"" stroke=""var(--cor-primaria, #1E3A5F)"" strokeWidth={2} />"

        {pontos.map((p, i) => (
          <circle
            key={`pt-${p.onda_codigo}`}
            cx={x(i)}
            cy={y(p.p_medio)}
            r={4}
"            fill=""var(--cor-primaria, #1E3A5F)"""
          />
        ))}

        {pontos.map((p, i) => (
          <text
            key={`lb-${p.onda_codigo}`}
            x={x(i)}
            y={ALTURA - MARGEM.baixo + 20}
"            textAnchor=""middle"""
            fontSize={12}
"            fill=""var(--cor-neutro-700, #424242)"""
          >
            {p.onda_codigo}
          </text>
        ))}

"        <text x={10} y={y(1) + 4} fontSize={11} fill=""var(--cor-neutro-700, #424242)"">"
          1.0
        </text>
"        <text x={10} y={y(0) + 4} fontSize={11} fill=""var(--cor-neutro-700, #424242)"">"
          0.0
        </text>
      </svg>
      <figcaption>
        Curva de retencao por onda. Barras verticais indicam intervalo de confianca de 95%.
      </figcaption>
    </figure>
  );
}
EOF

"echo ""=== PWA TELAS RESTANTES CONCLUIDA ==="""
"echo ""Verifique: ls $RAIZ/pwa/src/pages/"""
