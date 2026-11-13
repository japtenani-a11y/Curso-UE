#!/usr/bin/env bash
# ============================================================
# 32_revisao_curador_v1.0.sh
# OBJETIVO: acrescentar a API e ao PWA a tela de revisao de
# rascunhos (texto do artefato + afirmacoes com trecho literal +
# parecer correto / erro leve / erro critico por revisor).
# Tambem cria routes/sistema.ts, que o main.ts importa e nenhum
# script anterior gerava.
# USO: bash 32_revisao_curador_v1.0.sh ./programa-cut
# PRE-REQUISITO: 06 a 11, 24, 27b (pastas api/ e pwa/ geradas);
#                banco com 32_revisao_v1.0.sql.
# Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 32_revisao_curador_v1.0.sh <pasta programa-cut>}"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/main.ts" ] || { echo "ERRO: $API/main.ts nao existe. Rode os scripts 06 a 11 antes."; exit 1; }
[ -f "$PWA/App.tsx" ] || { echo "ERRO: $PWA/App.tsx nao existe. Rode os scripts 06 a 11 antes."; exit 1; }

# ---------- API: routes/sistema.ts (so se faltar) ----------
if [ ! -f "$API/routes/sistema.ts" ]; then
cat > "$API/routes/sistema.ts" <<'EOF'
import { Router } from 'express';
import { pool } from '../db/pool.js';

export const sistemaRouter = Router();

sistemaRouter.get('/versao', (_req, res) => {
  res.json({ api: '1.0.0', revisao: '1.0' });
});

sistemaRouter.get('/status', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok' });
  } catch {
    res.status(503).json({ status: 'erro' });
  }
});
EOF
echo "criado: api/src/routes/sistema.ts"
fi

# ---------- API: routes/revisao.ts ----------
cat > "$API/routes/revisao.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';
import { requireRole } from '../middleware/role.js';

export const revisaoRouter = Router();

const REVISORES = ['admin', 'data_steward', 'curador', 'preceptor'];
const DECISOES = ['correto', 'erro_leve', 'erro_critico'];

revisaoRouter.use(requireRole(REVISORES));

// Rascunho mais recente de cada tipo do tema, com afirmacoes e pareceres.
revisaoRouter.get('/temas/:codigo', async (req, res, next) => {
  try {
    const codigo = String(req.params.codigo).replace(/-/g, '').toUpperCase();
    const pessoaId = (req as { pessoaId?: number }).pessoaId ?? 0;

    const dados = await withMaestro(null, async (client) => {
      const tema = await client.query(
        `SELECT tema_id, codigo, titulo FROM app.tema WHERE upper(replace(codigo, '-', '')) = $1`,
        [codigo],
      );
      if (tema.rows.length === 0) return null;
      const temaId = tema.rows[0].tema_id;

      const artefatos = await client.query(
        `SELECT a.artefato_id, a.tipo, a.versao, a.status, a.titulo, a.corpo,
                coalesce((SELECT json_agg(json_build_object(
                            'codigo', f.codigo, 'texto', f.texto,
                            'fonte_arquivo', f.fonte_arquivo, 'trecho_literal', f.trecho_literal)
                          ORDER BY (substring(f.codigo from '[0-9]+'))::int)
                     FROM conteudo.afirmacao f WHERE f.artefato_id = a.artefato_id), '[]'::json) AS afirmacoes,
                coalesce((SELECT json_agg(json_build_object(
                            'afirmacao_codigo', p.afirmacao_codigo, 'decisao', p.decisao,
                            'comentario', p.comentario, 'meu', p.pessoa_id = $2,
                            'revisor', pe.nome_completo)
                          ORDER BY p.criado_em)
                     FROM conteudo.parecer_revisao p
                     JOIN app.pessoa pe ON pe.pessoa_id = p.pessoa_id
                    WHERE p.artefato_id = a.artefato_id), '[]'::json) AS pareceres
           FROM conteudo.artefato a
          WHERE a.tema_id = $1 AND a.status = 'rascunho'
            AND a.versao = (SELECT max(x.versao) FROM conteudo.artefato x
                             WHERE x.tema_id = a.tema_id AND x.tipo = a.tipo AND x.status = 'rascunho')
          ORDER BY a.tipo`,
        [temaId, pessoaId],
      );
      return { tema: tema.rows[0], artefatos: artefatos.rows };
    });

    if (!dados) {
      res.status(404).json({ erro: 'tema_nao_encontrado' });
      return;
    }
    res.json(dados);
  } catch (err) {
    next(err);
  }
});

// Grava (ou troca) o parecer do revisor sobre uma afirmacao ou sobre o artefato inteiro.
revisaoRouter.post('/pareceres', async (req, res, next) => {
  try {
    const pessoaId = (req as { pessoaId?: number }).pessoaId;
    const corpo = req.body as {
      artefato_id?: number; afirmacao_codigo?: string; decisao?: string; comentario?: string;
    };
    if (!pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }
    const artefatoId = Number(corpo.artefato_id);
    const decisao = String(corpo.decisao ?? '');
    if (!Number.isInteger(artefatoId) || !DECISOES.includes(decisao)) {
      res.status(400).json({ erro: 'parametros_invalidos' });
      return;
    }
    const afirmacao = String(corpo.afirmacao_codigo ?? '').slice(0, 20);
    const comentario = corpo.comentario ? String(corpo.comentario).slice(0, 4000) : null;

    await withMaestro(null, async (client) => {
      await client.query(
        `INSERT INTO conteudo.parecer_revisao (artefato_id, afirmacao_codigo, pessoa_id, decisao, comentario)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (artefato_id, afirmacao_codigo, pessoa_id)
         DO UPDATE SET decisao = EXCLUDED.decisao, comentario = EXCLUDED.comentario, criado_em = now()`,
        [artefatoId, afirmacao, pessoaId, decisao, comentario],
      );
    });
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});
EOF
echo "criado: api/src/routes/revisao.ts"

# ---------- API: registrar a rota no main.ts ----------
if ! grep -q "revisaoRouter" "$API/main.ts"; then
  sed -i "s#^import { sistemaRouter } from './routes/sistema.js';#import { sistemaRouter } from './routes/sistema.js';\nimport { revisaoRouter } from './routes/revisao.js';#" "$API/main.ts"
  sed -i "s#^app.use('/sistema', sistemaRouter);#app.use('/sistema', sistemaRouter);\napp.use('/revisao', revisaoRouter);#" "$API/main.ts"
  grep -q "app.use('/revisao', revisaoRouter)" "$API/main.ts" || { echo "ERRO: nao consegui registrar /revisao no main.ts"; exit 1; }
  echo "alterado: api/src/main.ts (rota /revisao)"
fi

# ---------- PWA: lib/md.tsx (leitor simples de markdown) ----------
mkdir -p "$PWA/lib" "$PWA/pages/curador"
cat > "$PWA/lib/md.tsx" <<'EOF'
import type { ReactNode } from 'react';

// Leitor simples de markdown: titulos, listas, tabelas, citacoes, blocos de codigo, negrito
// e os codigos [A12] das afirmacoes (clicaveis).
function emLinha(texto: string, aoClicar?: (codigo: string) => void): ReactNode[] {
  const partes = texto.split(/(\*\*[^*]+\*\*|A\d+)/g);
  return partes.map((p, i) => {
    if (/^\*\*[^*]+\*\*$/.test(p)) return <strong key={i}>{p.slice(2, -2)}</strong>;
    if (/^A\d+$/.test(p)) {
      return (
        <button key={i} type="button" className="chip" onClick={() => aoClicar?.(p)}>
          {p}
        </button>
      );
    }
    return <span key={i}>{p}</span>;
  });
}

export function Markdown(props: { texto: string; aoClicar?: (codigo: string) => void }) {
  const linhas = props.texto.split('\n');
  const saida: ReactNode[] = [];
  let i = 0;
  let k = 0;
  while (i < linhas.length) {
    const l = linhas[i] ?? '';
    if (l.startsWith('```')) {
      const bloco: string[] = [];
      i += 1;
      while (i < linhas.length && !(linhas[i] ?? '').startsWith('```')) {
        bloco.push(linhas[i] ?? '');
        i += 1;
      }
      i += 1;
      saida.push(<pre key={k++}>{bloco.join('\n')}</pre>);
      continue;
    }
    if (l.startsWith('|')) {
      const tabela: string[][] = [];
      while (i < linhas.length && (linhas[i] ?? '').startsWith('|')) {
        const cel = (linhas[i] ?? '').split('|').slice(1, -1).map((c) => c.trim());
        if (!cel.every((c) => /^-+$/.test(c))) tabela.push(cel);
        i += 1;
      }
      saida.push(
        <table key={k++}>
          <tbody>
            {tabela.map((lin, a) => (
              <tr key={a}>
                {lin.map((c, b) => (a === 0 ? <th key={b}>{c}</th> : <td key={b}>{emLinha(c, props.aoClicar)}</td>))}
              </tr>
            ))}
          </tbody>
        </table>,
      );
      continue;
    }
    if (/^- /.test(l)) {
      const itens: string[] = [];
      while (i < linhas.length && /^- /.test(linhas[i] ?? '')) {
        itens.push((linhas[i] ?? '').slice(2));
        i += 1;
      }
      saida.push(
        <ul key={k++}>
          {itens.map((t, a) => (
            <li key={a}>{emLinha(t, props.aoClicar)}</li>
          ))}
        </ul>,
      );
      continue;
    }
    if (l.startsWith('### ')) saida.push(<h4 key={k++}>{l.slice(4)}</h4>);
    else if (l.startsWith('## ')) saida.push(<h3 key={k++}>{l.slice(3)}</h3>);
    else if (l.startsWith('# ')) saida.push(<h2 key={k++}>{l.slice(2)}</h2>);
    else if (l.startsWith('> ')) saida.push(<blockquote key={k++}>{emLinha(l.slice(2), props.aoClicar)}</blockquote>);
    else if (l.trim() === '---') saida.push(<hr key={k++} />);
    else if (l.trim() !== '') saida.push(<p key={k++}>{emLinha(l, props.aoClicar)}</p>);
    i += 1;
  }
  return <div className="md">{saida}</div>;
}
EOF

# ---------- PWA: pages/curador/Revisao.tsx ----------
cat > "$PWA/pages/curador/Revisao.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';

interface Afirmacao { codigo: string; texto: string; fonte_arquivo: string | null; trecho_literal: string }
interface Parecer { afirmacao_codigo: string; decisao: string; comentario: string | null; meu: boolean; revisor: string }
interface Artefato {
  artefato_id: number; tipo: string; versao: number; titulo: string; corpo: string;
  afirmacoes: Afirmacao[]; pareceres: Parecer[];
}
interface Resposta { tema: { codigo: string; titulo: string }; artefatos: Artefato[] }

const ROTULO: Record<string, string> = { correto: 'Correto', erro_leve: 'Erro leve', erro_critico: 'Erro crítico' };
const DECISOES = ['correto', 'erro_leve', 'erro_critico'];

const CSS = `
.rev{font-family:system-ui,sans-serif;color:#1c2430;max-width:1100px;margin:0 auto;padding:16px}
.rev h1{font-size:20px;margin:0 0 4px}
.rev .abas{display:flex;flex-wrap:wrap;gap:6px;margin:12px 0}
.rev .aba{border:1px solid #c5ccd6;background:#fff;border-radius:6px;padding:6px 10px;cursor:pointer;font-size:14px}
.rev .aba.ativa{background:#1f4e79;color:#fff;border-color:#1f4e79}
.rev .placar{background:#f3f5f8;border-radius:8px;padding:10px 12px;margin:8px 0;font-size:14px}
.rev .ok{color:#1d6b3a;font-weight:600}.rev .ruim{color:#a32020;font-weight:600}
.rev .md{background:#fff;border:1px solid #dde2e9;border-radius:8px;padding:12px 16px;line-height:1.5}
.rev .md table{border-collapse:collapse;margin:8px 0;font-size:14px}
.rev .md th,.rev .md td{border:1px solid #c5ccd6;padding:4px 8px;text-align:left}
.rev .md pre{background:#f3f5f8;padding:8px;overflow:auto;font-size:13px}
.rev .md blockquote{margin:8px 0;padding:6px 10px;border-left:4px solid #d9a400;background:#fff8e1;font-size:14px}
.rev .chip{border:1px solid #1f4e79;color:#1f4e79;background:#eaf1f8;border-radius:10px;padding:0 6px;font-size:12px;cursor:pointer;margin:0 1px}
.rev .cartao{border:1px solid #dde2e9;border-radius:8px;padding:10px 12px;margin:10px 0;background:#fff}
.rev .cartao.alvo{outline:3px solid #d9a400}
.rev .trecho{background:#f3f5f8;border-left:4px solid #1f4e79;padding:6px 10px;margin:6px 0;font-size:14px;font-style:italic}
.rev .fonte{font-size:12px;color:#5b6675}
.rev .botoes{display:flex;flex-wrap:wrap;gap:6px;margin-top:6px}
.rev .botoes button{border:1px solid #c5ccd6;background:#fff;border-radius:6px;padding:6px 10px;cursor:pointer}
.rev .botoes button.sel-correto{background:#1d6b3a;color:#fff}
.rev .botoes button.sel-erro_leve{background:#d9a400;color:#1c2430}
.rev .botoes button.sel-erro_critico{background:#a32020;color:#fff}
.rev textarea{width:100%;box-sizing:border-box;margin-top:6px;min-height:44px;font:inherit;font-size:14px}
.rev .outros{font-size:13px;color:#5b6675;margin-top:4px}
`;

function codigoDoTema(): string {
  const m = window.location.pathname.match(/revisao\/([A-Za-z0-9-]+)/);
  return m?.[1] ?? 'T001';
}

export function CuradorRevisao() {
  const [dados, setDados] = useState<Resposta | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [ativo, setAtivo] = useState(0);
  const [alvo, setAlvo] = useState<string | null>(null);
  const [rascunho, setRascunho] = useState<Record<string, string>>({});

  function carregar() {
    apiGet<Resposta>(`/revisao/temas/${codigoDoTema()}`)
      .then(setDados)
      .catch(() => setErro('Não foi possível carregar os rascunhos. Verifique se você entrou como curador.'));
  }
  useEffect(carregar, []);

  if (erro) return <p role="alert">{erro}</p>;
  if (!dados) return <p>Carregando…</p>;
  if (dados.artefatos.length === 0) return <p>Não há rascunhos para este tema.</p>;

  const art = dados.artefatos[Math.min(ativo, dados.artefatos.length - 1)] as Artefato;

  function meu(a: Artefato, codigo: string): Parecer | undefined {
    return a.pareceres.find((p) => p.meu && p.afirmacao_codigo === codigo);
  }

  async function gravar(codigo: string, decisao: string) {
    const chave = `${art.artefato_id}:${codigo}`;
    const comentario = rascunho[chave] ?? meu(art, codigo)?.comentario ?? '';
    try {
      await apiPost('/revisao/pareceres', {
        artefato_id: art.artefato_id, afirmacao_codigo: codigo, decisao, comentario,
      });
      carregar();
    } catch {
      setErro('Falha ao gravar o parecer.');
    }
  }

  // Placar do artefato: considera o pior parecer de cada afirmacao entre todos os revisores.
  function placar(a: Artefato) {
    let leves = 0; let criticos = 0; let revisadas = 0;
    for (const f of a.afirmacoes) {
      const ps = a.pareceres.filter((p) => p.afirmacao_codigo === f.codigo);
      if (ps.length === 0) continue;
      revisadas += 1;
      if (ps.some((p) => p.decisao === 'erro_critico')) criticos += 1;
      else if (ps.some((p) => p.decisao === 'erro_leve')) leves += 1;
    }
    const total = a.afirmacoes.length;
    const pct = total > 0 ? (100 * leves) / total : 0;
    return { leves, criticos, revisadas, total, pct, dentro: criticos === 0 && pct <= 5 };
  }

  function irPara(codigo: string) {
    setAlvo(codigo);
    document.getElementById(`af-${codigo}`)?.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  function bloco(codigo: string, titulo: string) {
    const chave = `${art.artefato_id}:${codigo}`;
    const m = meu(art, codigo);
    const outros = art.pareceres.filter((p) => !p.meu && p.afirmacao_codigo === codigo);
    return (
      <div>
        <div className="botoes" role="group" aria-label={titulo}>
          {DECISOES.map((d) => (
            <button key={d} type="button" className={m?.decisao === d ? `sel-${d}` : ''} onClick={() => gravar(codigo, d)}>
              {ROTULO[d]}
            </button>
          ))}
        </div>
        <textarea
          placeholder="Comentário (opcional; grave clicando em uma das decisões)"
          value={rascunho[chave] ?? m?.comentario ?? ''}
          onChange={(e) => setRascunho({ ...rascunho, [chave]: e.target.value })}
        />
        {outros.length > 0 && (
          <div className="outros">
            Outros revisores: {outros.map((p) => `${p.revisor}: ${ROTULO[p.decisao] ?? p.decisao}${p.comentario ? ` — ${p.comentario}` : ''}`).join(' | ')}
          </div>
        )}
      </div>
    );
  }

  const pl = placar(art);

  return (
    <section className="rev">
      <style>{CSS}</style>
      <h1>Revisão de rascunhos — {dados.tema.codigo} {dados.tema.titulo}</h1>
      <div className="abas">
        {dados.artefatos.map((a, i) => {
          const p = placar(a);
          return (
            <button key={a.artefato_id} type="button" className={`aba${i === ativo ? ' ativa' : ''}`} onClick={() => { setAtivo(i); setAlvo(null); }}>
              {a.titulo} ({p.revisadas}/{p.total})
            </button>
          );
        })}
      </div>

      <div className="placar">
        <strong>{art.titulo}</strong> — versão {art.versao}. Afirmações revisadas: {pl.revisadas} de {pl.total}. Erros leves: {pl.leves} ({pl.pct.toFixed(1)}%). Erros críticos: {pl.criticos}.{' '}
        {pl.revisadas < pl.total
          ? <span>Revisão em andamento.</span>
          : pl.dentro
            ? <span className="ok">Dentro da tolerância (até 5% leve, zero crítico).</span>
            : <span className="ruim">Fora da tolerância (até 5% leve, zero crítico).</span>}
      </div>

      <Markdown texto={art.corpo} aoClicar={irPara} />

      <h3>Parecer sobre o artefato inteiro</h3>
      <div className="cartao">{bloco('', 'Parecer geral')}</div>

      <h3>Afirmações e trechos da fonte ({art.afirmacoes.length})</h3>
      {art.afirmacoes.map((f) => (
        <div key={f.codigo} id={`af-${f.codigo}`} className={`cartao${alvo === f.codigo ? ' alvo' : ''}`}>
          <div><strong>{f.codigo}.</strong> {f.texto}</div>
          <div className="trecho">“{f.trecho_literal}”</div>
          <div className="fonte">Fonte: {f.fonte_arquivo ?? 'não informada'}</div>
          {bloco(f.codigo, `Parecer ${f.codigo}`)}
        </div>
      ))}
    </section>
  );
}
EOF
echo "criados: pwa/src/lib/md.tsx e pwa/src/pages/curador/Revisao.tsx"

# ---------- PWA: rota e login ----------
if ! grep -q "CuradorRevisao" "$PWA/App.tsx"; then
  sed -i "s#^import { CuradorHome } from './pages/curador/Home.js';#import { CuradorHome } from './pages/curador/Home.js';\nimport { CuradorRevisao } from './pages/curador/Revisao.js';#" "$PWA/App.tsx"
  sed -i "s#^\( *\)<Route path=\"/curador/\*\" element={<CuradorHome />} />#\1<Route path=\"/curador/revisao/*\" element={<CuradorRevisao />} />\n\1<Route path=\"/curador/*\" element={<CuradorHome />} />#" "$PWA/App.tsx"
  grep -q 'path="/curador/revisao/\*"' "$PWA/App.tsx" || { echo "ERRO: nao consegui registrar a rota no App.tsx"; exit 1; }
  echo "alterado: pwa/src/App.tsx (rota /curador/revisao)"
fi
# login: curador de teste vai direto para a revisao
if grep -q "window.location.href = '/aluno';" "$PWA/pages/Login.tsx"; then
  sed -i "s#window.location.href = '/aluno';#window.location.href = email.includes('curador') ? '/curador/revisao/T001' : '/aluno';#" "$PWA/pages/Login.tsx"
  echo "alterado: pwa/src/pages/Login.tsx"
fi
# ---------- correcoes de tipo em codigo ja existente ----------
sed -i "s#^import pinoHttp from 'pino-http';#import { pinoHttp } from 'pino-http';#" "$API/main.ts"
[ -f "$PWA/vite-env.d.ts" ] || echo '/// <reference types="vite/client" />' > "$PWA/vite-env.d.ts"

echo "=== revisao do curador instalada ==="
