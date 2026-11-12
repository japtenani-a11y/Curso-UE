#!/usr/bin/env bash
# ============================================================
# 34_leitura_aluno_v1.0.sh
# OBJETIVO: tela de leitura do material do tema (objetivos, aula,
# resumo, mapa conceitual, flashcards, caso, protocolo, checklist).
# - Aluno ve somente artefatos PUBLICADOS.
# - Revisores tem uma previa dos rascunhos (com faixa de aviso).
# USO: bash 34_leitura_aluno_v1.0.sh ./programa-cut
# PRE-REQUISITO: 32_revisao_curador_v1.0.sh. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 34_leitura_aluno_v1.0.sh <pasta programa-cut>}"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$PWA/lib/md.tsx" ] || { echo "ERRO: rode antes o 32_revisao_curador_v1.0.sh"; exit 1; }

# ---------- API: routes/leitura.ts ----------
cat > "$API/routes/leitura.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const leituraRouter = Router();

const REVISORES = ['admin', 'data_steward', 'curador', 'preceptor'];
const TIPOS = ['objetivos', 'aula', 'resumo', 'mapa', 'flashcard', 'caso', 'protocolo', 'checklist'];

// Material de leitura de um tema. Padrao: versao publicada mais recente de cada tipo.
// Com ?previa=1 (so revisores): rascunho mais recente de cada tipo.
leituraRouter.get('/temas/:codigo', async (req, res, next) => {
  try {
    const r = req as { pessoaId?: number; papel?: string };
    if (!r.pessoaId) {
      res.status(401).json({ erro: 'sem_sessao' });
      return;
    }
    const previa = req.query.previa === '1';
    if (previa && !REVISORES.includes(r.papel ?? '')) {
      res.status(403).json({ erro: 'proibido', detalhe: 'previa so para revisores' });
      return;
    }
    const codigo = String(req.params.codigo).replace(/-/g, '').toUpperCase();
    const status = previa ? 'rascunho' : 'publicado';

    const dados = await withMaestro(null, async (client) => {
      const tema = await client.query(
        `SELECT tema_id, codigo, titulo FROM app.tema WHERE upper(replace(codigo, '-', '')) = $1`,
        [codigo],
      );
      if (tema.rows.length === 0) return null;
      const artefatos = await client.query(
        `SELECT a.artefato_id, a.tipo::text AS tipo, a.versao, a.titulo, a.corpo
           FROM conteudo.artefato a
          WHERE a.tema_id = $1 AND a.status::text = $2 AND a.tipo::text = ANY ($3)
            AND a.versao = (SELECT max(x.versao) FROM conteudo.artefato x
                             WHERE x.tema_id = a.tema_id AND x.tipo = a.tipo AND x.status::text = $2)
          ORDER BY array_position($3, a.tipo::text)`,
        [tema.rows[0].tema_id, status, TIPOS],
      );
      return { tema: tema.rows[0], previa, artefatos: artefatos.rows };
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
EOF
if ! grep -q "leituraRouter" "$API/main.ts"; then
  sed -i "s#^import { revisaoRouter } from './routes/revisao.js';#import { revisaoRouter } from './routes/revisao.js';\nimport { leituraRouter } from './routes/leitura.js';#" "$API/main.ts"
  sed -i "s#^app.use('/revisao', revisaoRouter);#app.use('/revisao', revisaoRouter);\napp.use('/leitura', leituraRouter);#" "$API/main.ts"
  grep -q "app.use('/leitura', leituraRouter)" "$API/main.ts" || { echo "ERRO: nao consegui registrar /leitura no main.ts"; exit 1; }
fi
echo "criado: api/src/routes/leitura.ts"

# ---------- PWA: pages/aluno/Leitura.tsx ----------
mkdir -p "$PWA/pages/aluno"
cat > "$PWA/pages/aluno/Leitura.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet } from '../../lib/api.js';
import { Markdown } from '../../lib/md.js';

interface Artefato { artefato_id: number; tipo: string; versao: number; titulo: string; corpo: string }
interface Resposta { tema: { codigo: string; titulo: string }; previa: boolean; artefatos: Artefato[] }
interface Cartao { frente: string; verso: string }
interface No { nivel: number; texto: string }

const CSS = `
.lei{font-family:system-ui,sans-serif;color:#1c2430;max-width:860px;margin:0 auto;padding:16px}
.lei h1{font-size:20px;margin:0 0 4px}
.lei .faixa{background:#fff3cd;border:1px solid #d9a400;border-radius:8px;padding:8px 12px;margin:10px 0;font-size:14px}
.lei .abas{display:flex;flex-wrap:wrap;gap:6px;margin:12px 0}
.lei .aba{border:1px solid #c5ccd6;background:#fff;border-radius:6px;padding:8px 12px;cursor:pointer;font-size:15px}
.lei .aba.ativa{background:#1f4e79;color:#fff;border-color:#1f4e79}
.lei .md{background:#fff;border:1px solid #dde2e9;border-radius:8px;padding:12px 16px;line-height:1.55}
.lei .md table{border-collapse:collapse;margin:8px 0;font-size:14px;display:block;overflow-x:auto}
.lei .md th,.lei .md td{border:1px solid #c5ccd6;padding:4px 8px;text-align:left}
.lei .md blockquote{margin:8px 0;padding:6px 10px;border-left:4px solid #d9a400;background:#fff8e1;font-size:14px}
.lei .chip{border:0;background:none;color:#5b6675;font-size:12px;padding:0 2px}
.lei .carta{border:1px solid #c5ccd6;border-radius:12px;min-height:160px;padding:20px;margin:12px 0;background:#fff;
  display:flex;align-items:center;justify-content:center;text-align:center;font-size:18px;cursor:pointer;width:100%;font-family:inherit;color:inherit}
.lei .carta.verso{background:#eaf1f8;border-color:#1f4e79}
.lei .nav{display:flex;gap:8px;align-items:center;justify-content:center}
.lei .nav button{border:1px solid #c5ccd6;background:#fff;border-radius:6px;padding:8px 14px;cursor:pointer;font-size:15px}
.lei .mapa{background:#fff;border:1px solid #dde2e9;border-radius:8px;padding:12px 16px}
.lei .no{margin:4px 0;padding:6px 10px;border-left:4px solid #1f4e79;background:#f3f5f8;border-radius:0 6px 6px 0}
.lei .no.n0{background:#1f4e79;color:#fff;font-weight:600;border-radius:6px}
.lei .no.n1{font-weight:600}
.lei .no.n2{border-left-color:#8aa4bf;background:#fff}
`;

function codigoDoTema(): string {
  const m = window.location.pathname.match(/(?:leitura|previa)\/([A-Za-z0-9-]+)/);
  return m?.[1] ?? 'T001';
}

// Texto para o aluno: sem a faixa de rascunho e sem os codigos das afirmacoes.
function limpar(corpo: string, previa: boolean): string {
  if (previa) return corpo;
  return corpo
    .split('\n')
    .filter((l) => !l.startsWith('> RASCUNHO'))
    .join('\n')
    .replace(/\s*\[A\d+(?:,\s*A\d+)*\]/g, '');
}

function cartoes(corpo: string): Cartao[] {
  const saida: Cartao[] = [];
  for (const l of corpo.split('\n')) {
    const c = l.split('|').slice(1, -1).map((x) => x.trim());
    if (c.length === 3 && /^\d+$/.test(c[0] ?? '')) saida.push({ frente: c[1] ?? '', verso: c[2] ?? '' });
  }
  return saida;
}

function nosDoMapa(corpo: string, previa: boolean): No[] {
  const linhas = corpo.split('\n');
  const ini = linhas.findIndex((l) => l.trim() === 'mindmap');
  if (ini < 0) return [];
  const saida: No[] = [];
  for (const l of linhas.slice(ini + 1)) {
    if (l.startsWith('```')) break;
    if (l.trim() === '') continue;
    const recuo = l.length - l.trimStart().length;
    let texto = l.trim().replace(/^root\(\((.*)\)\)$/, '$1');
    if (!previa) texto = texto.replace(/(\s+A\d+)+$/, '');
    saida.push({ nivel: Math.max(0, Math.round(recuo / 2) - 1), texto });
  }
  return saida;
}

function Flashcards(props: { lista: Cartao[] }) {
  const [i, setI] = useState(0);
  const [virado, setVirado] = useState(false);
  const total = props.lista.length;
  const c = props.lista[Math.min(i, total - 1)];
  if (!c) return <p>Sem flashcards.</p>;
  function ir(d: number) {
    setI((i + d + total) % total);
    setVirado(false);
  }
  return (
    <div>
      <button type="button" className={`carta${virado ? ' verso' : ''}`} onClick={() => setVirado(!virado)} aria-live="polite">
        {virado ? c.verso : c.frente}
      </button>
      <div className="nav">
        <button type="button" onClick={() => ir(-1)}>Anterior</button>
        <span>{i + 1} de {total} — toque no cartão para virar</span>
        <button type="button" onClick={() => ir(1)}>Próximo</button>
      </div>
    </div>
  );
}

export function Leitura() {
  const previa = window.location.pathname.includes('/previa/');
  const [dados, setDados] = useState<Resposta | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [ativo, setAtivo] = useState(0);

  useEffect(() => {
    apiGet<Resposta>(`/leitura/temas/${codigoDoTema()}${previa ? '?previa=1' : ''}`)
      .then(setDados)
      .catch(() => setErro('Não foi possível carregar o material. Verifique se você entrou no sistema.'));
  }, []);

  if (erro) return <p role="alert">{erro}</p>;
  if (!dados) return <p>Carregando…</p>;

  const art = dados.artefatos[Math.min(ativo, Math.max(0, dados.artefatos.length - 1))];

  return (
    <section className="lei">
      <style>{CSS}</style>
      <h1>{dados.tema.codigo} — {dados.tema.titulo}</h1>
      {dados.previa && (
        <div className="faixa">PRÉVIA para revisores: rascunhos ainda não aprovados. O aluno não vê esta página.</div>
      )}
      {!art ? (
        <p>Ainda não há material publicado para este tema.</p>
      ) : (
        <div>
          <div className="abas">
            {dados.artefatos.map((a, i) => (
              <button key={a.artefato_id} type="button" className={`aba${i === ativo ? ' ativa' : ''}`} onClick={() => setAtivo(i)}>
                {a.titulo}
              </button>
            ))}
          </div>
          {art.tipo === 'flashcard' && cartoes(art.corpo).length > 0 ? (
            <Flashcards lista={cartoes(limpar(art.corpo, dados.previa))} />
          ) : art.tipo === 'mapa' && nosDoMapa(art.corpo, dados.previa).length > 0 ? (
            <div className="mapa">
              {nosDoMapa(art.corpo, dados.previa).map((n, k) => (
                <div key={k} className={`no n${Math.min(n.nivel, 2)}`} style={{ marginLeft: `${n.nivel * 24}px` }}>
                  {n.texto}
                </div>
              ))}
            </div>
          ) : (
            <Markdown texto={limpar(art.corpo, dados.previa)} />
          )}
        </div>
      )}
    </section>
  );
}
EOF
echo "criado: pwa/src/pages/aluno/Leitura.tsx"

# ---------- PWA: rotas e atalhos ----------
if ! grep -q "pages/aluno/Leitura.js" "$PWA/App.tsx"; then
  sed -i "s#^import { AlunoHome } from './pages/aluno/Home.js';#import { AlunoHome } from './pages/aluno/Home.js';\nimport { Leitura } from './pages/aluno/Leitura.js';#" "$PWA/App.tsx"
  sed -i "s#^\( *\)<Route path=\"/aluno/\*\" element={<AlunoHome />} />#\1<Route path=\"/aluno/leitura/*\" element={<Leitura />} />\n\1<Route path=\"/curador/previa/*\" element={<Leitura />} />\n\1<Route path=\"/aluno/*\" element={<AlunoHome />} />#" "$PWA/App.tsx"
  grep -q 'path="/aluno/leitura/\*"' "$PWA/App.tsx" || { echo "ERRO: nao consegui registrar a rota no App.tsx"; exit 1; }
fi
if ! grep -q "/aluno/leitura/T001" "$PWA/pages/aluno/Home.tsx"; then
  sed -i 's#^\( *\)<h1>Minhas ondas</h1>#\1<p><a href="/aluno/leitura/T001">Material do tema T001</a></p>\n\1<h1>Minhas ondas</h1>#' "$PWA/pages/aluno/Home.tsx"
fi
if ! grep -q "/curador/previa/" "$PWA/pages/curador/Revisao.tsx"; then
  sed -i 's#^\( *\)<div className="abas">#\1<p><a href={`/curador/previa/${dados.tema.codigo.replace("-", "")}`}>Ver como o aluno verá (prévia)</a></p>\n\1<div className="abas">#' "$PWA/pages/curador/Revisao.tsx"
fi
echo "=== tela de leitura instalada ==="
