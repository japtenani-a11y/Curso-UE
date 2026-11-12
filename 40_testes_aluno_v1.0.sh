#!/usr/bin/env bash
# ============================================================
# 40_testes_aluno_v1.0.sh
# OBJETIVO: o aluno faz os testes do tema no aplicativo, com liberacao progressiva:
#  - rota /teste: lista os 6 testes do tema, abre o teste (caso + questoes do perfil
#    do aluno), grava respostas, submete e so entao mostra o gabarito comentado
#    (grau, taxa de acerto esperada, justificativa de cada alternativa).
#  - rota /leitura: o aluno so ve o material da etapa liberada.
#  - corrige a rota antiga /aluno/tentativas/:id/feedback, que mostrava o gabarito
#    antes de o teste ser submetido, e filtra as questoes pelo perfil do aluno.
#  - PWA: tela /aluno/testes/T001 e aviso de etapa na leitura.
# USO: bash 40_testes_aluno_v1.0.sh ./programa-cut
# PRE-REQUISITO: 32 e 34 (scripts) e, no banco, 37 e 38. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 40_testes_aluno_v1.0.sh <pasta programa-cut>}"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/leitura.ts" ] || { echo "ERRO: rode antes o 34_leitura_aluno_v1.0.sh"; exit 1; }
command -v python3 >/dev/null || { echo "ERRO: python3 nao encontrado"; exit 1; }

# ---------- API: routes/teste.ts ----------
cat > "$API/routes/teste.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const testeRouter = Router();

const GRAUS = ['Muito fácil', 'Fácil', 'Média', 'Difícil', 'Muito difícil', 'Extrema'];
const TAXAS = ['acima de 90%', '75% a 90%', '50% a 75%', '30% a 50%', '15% a 30%', 'abaixo de 15%'];
// A questao fixa tem grau diferente por perfil (mesmo enunciado, experiencia diferente).
const GRAU_FIXA: Record<string, number> = { graduacao: 3, R1: 2, R2: 1, R3: 1, 'R+': 1 };

type Req = { pessoaId?: number; params: Record<string, string>; body: unknown };

function pessoa(req: Req): number | null {
  return req.pessoaId ?? null;
}

// Lista os testes do tema com a situacao de cada um para o aluno.
testeRouter.get('/temas/:codigo', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const codigo = String(req.params.codigo).replace(/-/g, '').toUpperCase();
    const dados = await withMaestro(null, async (client) => {
      const tema = await client.query(
        `SELECT tema_id, codigo, titulo, app.etapa_liberada($2, tema_id) AS etapa, app.perfil_da_pessoa($2) AS perfil
           FROM app.tema WHERE upper(replace(codigo, '-', '')) = $1`, [codigo, p]);
      if (tema.rows.length === 0) return null;
      const t = tema.rows[0];
      const testes = await client.query(
        `SELECT o.onda_id, o.teste_num, o.onda_codigo, o.data_abertura, o.data_fechamento, o.status,
                app.teste_liberado($2, o.tema_id, o.teste_num) AS liberado, app.onda_respondivel(o.onda_id) AS respondivel,
                (SELECT tt.submetida_em FROM app.tentativa tt WHERE tt.onda_id = o.onda_id AND tt.pessoa_id = $2) AS submetida_em
           FROM app.onda_instancia o WHERE o.tema_id = $1 ORDER BY o.teste_num`, [t.tema_id, p]);
      return { tema: t, testes: testes.rows };
    });
    if (!dados) { res.status(404).json({ erro: 'tema_nao_encontrado' }); return; }
    res.json(dados);
  } catch (err) { next(err); }
});

// Abre o teste: caso + questoes do perfil do aluno, sem gabarito.
testeRouter.get('/ondas/:ondaId', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const ondaId = Number(req.params.ondaId);
    const dados = await withMaestro(null, async (client) => {
      const o = await client.query(
        `SELECT o.onda_id, o.tema_id, o.teste_num, o.status, o.data_fechamento, app.onda_respondivel(o.onda_id) AS respondivel,
                app.teste_liberado($2, o.tema_id, o.teste_num) AS liberado,
                app.perfil_da_pessoa($2) AS perfil
           FROM app.onda_instancia o WHERE o.onda_id = $1 AND o.tema_id IS NOT NULL`, [ondaId, p]);
      const onda = o.rows[0];
      if (!onda) return { erro: 'onda_nao_encontrada', status: 404 };
      if (!onda.liberado) return { erro: 'teste_bloqueado', status: 403 };
      if (!onda.respondivel) return { erro: 'onda_fechada', status: 409 };
      if (!onda.perfil) return { erro: 'perfil_nao_cadastrado', status: 409 };
      const tent = await client.query(
        `INSERT INTO app.tentativa (onda_id, pessoa_id) VALUES ($1, $2)
         ON CONFLICT (onda_id, pessoa_id) DO UPDATE SET iniciada_em = app.tentativa.iniciada_em
         RETURNING tentativa_id, submetida_em`, [ondaId, p]);
      const caso = await client.query(
        `SELECT titulo, texto FROM app.caso_teste WHERE tema_id = $1 AND teste_num = $2`, [onda.tema_id, onda.teste_num]);
      const itens = await client.query(
        `SELECT i.item_id, i.enunciado, i.fixa, s.ordem_apresentada,
                json_agg(json_build_object('alternativa_id', a.alternativa_id, 'ordem', a.ordem, 'texto', a.texto) ORDER BY a.ordem) AS alternativas,
                (SELECT r.alternativa_id FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id) AS resposta
           FROM app.item_selecionado s
           JOIN app.item i ON i.item_id = s.item_id
           JOIN app.alternativa a ON a.item_id = i.item_id
          WHERE s.onda_id = $1 AND (i.fixa OR i.perfil = $2)
          GROUP BY i.item_id, i.enunciado, i.fixa, s.ordem_apresentada
          ORDER BY i.fixa DESC, s.ordem_apresentada`, [ondaId, onda.perfil, tent.rows[0].tentativa_id]);
      return { teste_num: onda.teste_num, perfil: onda.perfil, tentativa: tent.rows[0], caso: caso.rows[0] ?? null, itens: itens.rows };
    });
    if ('erro' in dados) { res.status(dados.status ?? 400).json({ erro: dados.erro }); return; }
    res.json(dados);
  } catch (err) { next(err); }
});

// Grava respostas e, se pedido, submete. Depois de submetido, nada muda.
testeRouter.post('/ondas/:ondaId/respostas', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const ondaId = Number(req.params.ondaId);
    const corpo = req.body as { respostas?: { item_id: number; alternativa_id: number; tempo_resposta_ms?: number }[]; submeter?: boolean };
    const respostas = Array.isArray(corpo.respostas) ? corpo.respostas.slice(0, 20) : [];
    const r = await withMaestro(null, async (client) => {
      const t = await client.query(
        `SELECT t.tentativa_id, t.submetida_em, app.perfil_da_pessoa($2) AS perfil, app.onda_respondivel(t.onda_id) AS respondivel
           FROM app.tentativa t WHERE t.onda_id = $1 AND t.pessoa_id = $2`, [ondaId, p]);
      const tent = t.rows[0];
      if (!tent) return { erro: 'teste_nao_iniciado', status: 409 };
      if (!tent.submetida_em && !tent.respondivel) return { erro: 'prazo_encerrado', status: 409 };
      if (tent.submetida_em) return { erro: 'teste_ja_submetido', status: 409 };
      for (const x of respostas) {
        await client.query(
          `INSERT INTO app.resposta (tentativa_id, item_id, alternativa_id, tempo_resposta_ms)
           SELECT $1, i.item_id, a.alternativa_id, $5
             FROM app.item_selecionado s
             JOIN app.item i ON i.item_id = s.item_id AND (i.fixa OR i.perfil = $6)
             JOIN app.alternativa a ON a.item_id = i.item_id AND a.alternativa_id = $4
            WHERE s.onda_id = $2 AND i.item_id = $3
           ON CONFLICT (tentativa_id, item_id) DO UPDATE SET alternativa_id = EXCLUDED.alternativa_id,
                  tempo_resposta_ms = EXCLUDED.tempo_resposta_ms, respondida_em = now()`,
          [tent.tentativa_id, ondaId, Number(x.item_id), Number(x.alternativa_id),
           x.tempo_resposta_ms == null ? null : Math.max(0, Math.round(Number(x.tempo_resposta_ms))), tent.perfil]);
      }
      if (corpo.submeter) {
        const falta = await client.query(
          `SELECT count(*)::int AS n FROM app.item_selecionado s JOIN app.item i ON i.item_id = s.item_id
            WHERE s.onda_id = $1 AND (i.fixa OR i.perfil = $2)
              AND NOT EXISTS (SELECT 1 FROM app.resposta r WHERE r.tentativa_id = $3 AND r.item_id = i.item_id)`,
          [ondaId, tent.perfil, tent.tentativa_id]);
        if (falta.rows[0].n > 0) return { erro: 'faltam_respostas', status: 422, faltam: falta.rows[0].n };
        await client.query(`UPDATE app.tentativa SET submetida_em = now() WHERE tentativa_id = $1 AND submetida_em IS NULL`, [tent.tentativa_id]);
      }
      return { ok: true, submetido: Boolean(corpo.submeter) };
    });
    if ('erro' in r) { res.status(r.status ?? 400).json(r); return; }
    res.json(r);
  } catch (err) { next(err); }
});

// Gabarito comentado: so depois de o aluno submeter este teste.
testeRouter.get('/ondas/:ondaId/gabarito', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const ondaId = Number(req.params.ondaId);
    const dados = await withMaestro(null, async (client) => {
      const t = await client.query(
        `SELECT t.tentativa_id, t.submetida_em, app.perfil_da_pessoa($2) AS perfil
           FROM app.tentativa t WHERE t.onda_id = $1 AND t.pessoa_id = $2`, [ondaId, p]);
      const tent = t.rows[0];
      if (!tent || !tent.submetida_em) return null;
      const itens = await client.query(
        `SELECT i.item_id, i.enunciado, i.fixa, i.dificuldade, i.ancora, r.alternativa_id AS escolhida,
                json_agg(json_build_object('alternativa_id', a.alternativa_id, 'ordem', a.ordem, 'texto', a.texto,
                         'correta', a.eh_correta, 'categoria', a.categoria_distrator, 'justificativa', a.justificativa) ORDER BY a.ordem) AS alternativas
           FROM app.resposta r
           JOIN app.item i ON i.item_id = r.item_id
           JOIN app.alternativa a ON a.item_id = i.item_id
          WHERE r.tentativa_id = $1
          GROUP BY i.item_id, i.enunciado, i.fixa, i.dificuldade, i.ancora, r.alternativa_id
          ORDER BY i.fixa DESC, i.item_id`, [tent.tentativa_id]);
      return { perfil: tent.perfil, itens: itens.rows };
    });
    if (!dados) { res.status(403).json({ erro: 'gabarito_bloqueado', detalhe: 'responda e envie o teste antes' }); return; }
    const itens = dados.itens.map((i: { fixa: boolean; dificuldade: number }) => {
      const g = i.fixa ? (GRAU_FIXA[String(dados.perfil)] ?? i.dificuldade) : i.dificuldade;
      return { ...i, grau: GRAUS[g - 1] ?? null, taxa_esperada: TAXAS[g - 1] ?? null };
    });
    res.json({ perfil: dados.perfil, itens });
  } catch (err) { next(err); }
});
EOF
echo "criado: api/src/routes/teste.ts"

# ---------- API: leitura.ts por etapa ----------
cat > "$API/routes/leitura.ts" <<'EOF'
import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

export const leituraRouter = Router();

const REVISORES = ['admin', 'data_steward', 'curador', 'preceptor'];
const TIPOS = ['objetivos', 'resumo_basico', 'podcast_roteiro', 'caso_base', 'sintese_evidencia', 'resumo', 'mapa',
  'flashcard', 'protocolo', 'checklist', 'aula', 'slides', 'caso'];

// Aluno: versao publicada mais recente de cada tipo, so ate a etapa liberada.
// Revisor com ?previa=1: rascunho mais recente de cada tipo, sem travas.
leituraRouter.get('/temas/:codigo', async (req, res, next) => {
  try {
    const r = req as { pessoaId?: number; papel?: string };
    if (!r.pessoaId) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const previa = req.query.previa === '1';
    if (previa && !REVISORES.includes(r.papel ?? '')) {
      res.status(403).json({ erro: 'proibido', detalhe: 'previa so para revisores' }); return;
    }
    const codigo = String(req.params.codigo).replace(/-/g, '').toUpperCase();
    const status = previa ? 'rascunho' : 'publicado';
    const dados = await withMaestro(null, async (client) => {
      const tema = await client.query(
        `SELECT tema_id, codigo, titulo, app.etapa_liberada($2, tema_id) AS etapa
           FROM app.tema WHERE upper(replace(codigo, '-', '')) = $1`, [codigo, r.pessoaId]);
      if (tema.rows.length === 0) return null;
      const t = tema.rows[0];
      const etapa = previa ? 4 : Number(t.etapa);
      const artefatos = await client.query(
        `SELECT a.artefato_id, a.tipo::text AS tipo, a.versao, a.titulo, a.corpo, app.etapa_do_material(a.tipo::text) AS etapa
           FROM conteudo.artefato a
          WHERE a.tema_id = $1 AND a.status::text = $2 AND a.tipo::text = ANY ($3)
            AND a.versao = (SELECT max(x.versao) FROM conteudo.artefato x
                             WHERE x.tema_id = a.tema_id AND x.tipo = a.tipo AND x.status::text = $2)
          ORDER BY array_position($3, a.tipo::text)`, [t.tema_id, status, TIPOS]);
      const liberados = artefatos.rows.filter((a: { etapa: number | null }) => a.etapa !== null && a.etapa <= etapa);
      const bloqueados = artefatos.rows.length - liberados.length;
      return { tema: { codigo: t.codigo, titulo: t.titulo }, previa, etapa, bloqueados, artefatos: liberados };
    });
    if (!dados) { res.status(404).json({ erro: 'tema_nao_encontrado' }); return; }
    res.json(dados);
  } catch (err) { next(err); }
});
EOF
echo "atualizado: api/src/routes/leitura.ts"

# ---------- API: registrar /teste e corrigir rotas antigas do aluno ----------
if ! grep -q "testeRouter" "$API/main.ts"; then
  sed -i "s#^import { leituraRouter } from './routes/leitura.js';#import { leituraRouter } from './routes/leitura.js';\nimport { testeRouter } from './routes/teste.js';#" "$API/main.ts"
  sed -i "s#^app.use('/leitura', leituraRouter);#app.use('/leitura', leituraRouter);\napp.use('/teste', testeRouter);#" "$API/main.ts"
  grep -q "app.use('/teste', testeRouter)" "$API/main.ts" || { echo "ERRO: nao consegui registrar /teste no main.ts"; exit 1; }
fi
python3 - "$API/routes/aluno.ts" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read(); mudou=False
a="""          WHERE t.tentativa_id = $1
          GROUP BY i.item_id, i.enunciado, ise.ordem_apresentada"""
b="""          WHERE t.tentativa_id = $1
            AND (i.fixa OR i.perfil IS NULL OR i.perfil = app.perfil_da_pessoa(t.pessoa_id))
          GROUP BY i.item_id, i.enunciado, ise.ordem_apresentada"""
if a in s and b not in s: s=s.replace(a,b); mudou=True
c="""           LEFT JOIN app.alternativa ga ON ga.alternativa_id = i.gabarito_alternativa_id
          WHERE r.tentativa_id = $1"""
d="""           LEFT JOIN app.alternativa ga ON ga.alternativa_id = i.gabarito_alternativa_id
           JOIN app.tentativa tt ON tt.tentativa_id = r.tentativa_id
          WHERE r.tentativa_id = $1 AND tt.submetida_em IS NOT NULL"""
if c in s and d not in s: s=s.replace(c,d); mudou=True
if b not in s or d not in s: sys.exit("ERRO: nao encontrei as consultas esperadas em aluno.ts")
open(p,'w').write(s); print("atualizado: api/src/routes/aluno.ts" if mudou else "aluno.ts ja corrigido")
PY

# ---------- PWA: tela de testes ----------
mkdir -p "$PWA/pages/aluno"
cat > "$PWA/pages/aluno/Testes.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

interface Teste { onda_id: number; teste_num: number; liberado: boolean; respondivel: boolean; submetida_em: string | null; status: string; data_abertura: string; data_fechamento: string }
interface Lista { tema: { codigo: string; titulo: string; etapa: number; perfil: string | null }; testes: Teste[] }
interface Alt { alternativa_id: number; ordem: number; texto: string; correta?: boolean; categoria?: string | null; justificativa?: string | null }
interface Item { item_id: number; enunciado: string; fixa: boolean; alternativas: Alt[]; resposta?: number | null; escolhida?: number; grau?: string; taxa_esperada?: string; ancora?: string }
interface Aberto { teste_num: number; caso: { titulo: string; texto: string } | null; itens: Item[]; tentativa: { submetida_em: string | null } }

const NOMES = ['', 'Pré-teste inicial', 'Pré-teste após o conhecimento básico', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90'];
const LETRAS = 'ABCDE';
const dataHora = (s: string) => new Date(s).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
function situacao(t: Teste): string {
  if (t.submetida_em) return 'Respondido';
  if (!t.liberado) return 'Bloqueado: responda o teste anterior';
  if (!t.respondivel) return new Date(t.data_fechamento) <= new Date() ? 'Prazo encerrado' : `Abre em ${dataHora(t.data_abertura)}`;
  return t.teste_num === 2 ? `Liberado · prazo: até ${dataHora(t.data_fechamento)} (1 hora antes da aula)` : 'Liberado';
}
const CAT: Record<string, string> = { erro_conceitual: 'erro conceitual', erro_conduta: 'erro de conduta', erro_indicacao: 'erro de indicação', erro_tecnico: 'erro técnico', erro_calculo: 'erro de cálculo' };

const CSS = `
.tst{font-family:system-ui,sans-serif;color:#1c2430;max-width:820px;margin:0 auto;padding:16px}
.tst h1{font-size:20px;margin:0 0 4px}.tst h2{font-size:18px}
.tst .linha{display:flex;justify-content:space-between;align-items:center;border:1px solid #dde2e9;border-radius:8px;padding:12px;margin:8px 0;background:#fff;gap:8px}
.tst button{border:1px solid #1f4e79;background:#1f4e79;color:#fff;border-radius:6px;padding:8px 14px;cursor:pointer;font-size:15px}
.tst button.sec{background:#fff;color:#1f4e79}
.tst button:disabled{opacity:.5;cursor:default}
.tst .caso{background:#eaf1f8;border-left:4px solid #1f4e79;padding:12px;border-radius:0 8px 8px 0;margin:12px 0;line-height:1.5}
.tst .q{border:1px solid #dde2e9;border-radius:8px;padding:12px;margin:12px 0;background:#fff}
.tst label{display:block;padding:6px 8px;border-radius:6px;cursor:pointer;margin:4px 0}
.tst label:hover{background:#f3f5f8}
.tst .ok{background:#e6f4ea}.tst .ruim{background:#fdecea}
.tst .meta{font-size:13px;color:#5b6675;margin:6px 0}
.tst .just{font-size:14px;color:#3a4552;margin:2px 0 6px 28px}
.tst .aviso{background:#fff3cd;border:1px solid #d9a400;border-radius:8px;padding:8px 12px}
`;

function codigoDoTema(): string {
  const m = window.location.pathname.match(/testes\/([A-Za-z0-9-]+)/);
  return m?.[1] ?? 'T001';
}

export function Testes() {
  const [lista, setLista] = useState<Lista | null>(null);
  const [aberto, setAberto] = useState<{ ondaId: number; dados: Aberto } | null>(null);
  const [gab, setGab] = useState<{ ondaId: number; itens: Item[] } | null>(null);
  const [marcadas, setMarcadas] = useState<Record<number, number>>({});
  const [inicio, setInicio] = useState<number>(0);
  const [erro, setErro] = useState<string | null>(null);

  function carregar() {
    apiGet<Lista>(`/teste/temas/${codigoDoTema()}`).then(setLista).catch(() => setErro('Não foi possível carregar os testes.'));
  }
  useEffect(carregar, []);

  async function abrir(ondaId: number) {
    setErro(null); setGab(null);
    try {
      const d = await apiGet<Aberto>(`/teste/ondas/${ondaId}`);
      const m: Record<number, number> = {};
      d.itens.forEach((i) => { if (i.resposta) m[i.item_id] = i.resposta; });
      setMarcadas(m); setAberto({ ondaId, dados: d }); setInicio(Date.now());
    } catch { setErro('Este teste não está disponível agora (ainda não liberado, fora do prazo) ou seu perfil (grau) não está cadastrado.'); }
  }

  async function verGabarito(ondaId: number) {
    setErro(null); setAberto(null);
    try { const g = await apiGet<{ itens: Item[] }>(`/teste/ondas/${ondaId}/gabarito`); setGab({ ondaId, itens: g.itens }); }
    catch { setErro('O gabarito só é liberado depois que você envia o teste.'); }
  }

  async function enviar() {
    if (!aberto) return;
    const faltam = aberto.dados.itens.filter((i) => !marcadas[i.item_id]).length;
    if (faltam > 0) { setErro(`Faltam ${faltam} questão(ões).`); return; }
    const porQuestao = Math.round((Date.now() - inicio) / Math.max(1, aberto.dados.itens.length));
    try {
      await apiPost(`/teste/ondas/${aberto.ondaId}/respostas`, {
        respostas: aberto.dados.itens.map((i) => ({ item_id: i.item_id, alternativa_id: marcadas[i.item_id], tempo_resposta_ms: porQuestao })),
        submeter: true,
      });
      const ondaId = aberto.ondaId;
      setAberto(null); carregar(); await verGabarito(ondaId);
    } catch { setErro('Falha ao enviar as respostas. Se o prazo do teste terminou, ele não aceita mais respostas.'); }
  }

  if (!lista) return <p>{erro ?? 'Carregando…'}</p>;

  return (
    <section className="tst">
      <style>{CSS}</style>
      <h1>Testes — {lista.tema.codigo} {lista.tema.titulo}</h1>
      <p><a href={`/aluno/leitura/${lista.tema.codigo.replace('-', '')}`}>Material do tema</a></p>
      {erro && <p className="aviso" role="alert">{erro}</p>}

      {!aberto && !gab && lista.testes.map((t) => (
        <div key={t.onda_id} className="linha">
          <div><strong>{NOMES[t.teste_num]}</strong><div className="meta">
            {situacao(t)}</div></div>
          {t.submetida_em
            ? <button type="button" className="sec" onClick={() => verGabarito(t.onda_id)}>Ver gabarito</button>
            : <button type="button" disabled={!t.liberado || !t.respondivel} onClick={() => abrir(t.onda_id)}>Responder</button>}
        </div>
      ))}

      {aberto && (
        <div>
          <h2>{NOMES[aberto.dados.teste_num]}</h2>
          <p className="meta">Tempo estimado: 10 a 15 minutos. Uma alternativa correta por questão.</p>
          {aberto.dados.itens.map((i, n) => (
            <div key={i.item_id}>
              {n === 1 && aberto.dados.caso && <div className="caso"><strong>{aberto.dados.caso.titulo}.</strong> {aberto.dados.caso.texto}</div>}
              <div className="q">
                <p><strong>{n + 1}.</strong> {i.enunciado}</p>
                {i.alternativas.map((a, k) => (
                  <label key={a.alternativa_id}>
                    <input type="radio" name={`q${i.item_id}`} checked={marcadas[i.item_id] === a.alternativa_id}
                      onChange={() => setMarcadas({ ...marcadas, [i.item_id]: a.alternativa_id })} /> {LETRAS[k]}) {a.texto}
                  </label>
                ))}
              </div>
            </div>
          ))}
          <button type="button" onClick={enviar}>Enviar respostas</button>{' '}
          <button type="button" className="sec" onClick={() => setAberto(null)}>Voltar</button>
        </div>
      )}

      {gab && (
        <div>
          <h2>Gabarito comentado</h2>
          <p className="meta">Acertos: {gab.itens.filter((i) => i.alternativas.some((a) => a.correta && a.alternativa_id === i.escolhida)).length} de {gab.itens.length}</p>
          {gab.itens.map((i, n) => (
            <div key={i.item_id} className="q">
              <p><strong>{n + 1}.</strong> {i.enunciado}</p>
              <p className="meta">Grau: {i.grau} · taxa de acerto esperada para o seu perfil: {i.taxa_esperada} · fonte: {i.ancora}</p>
              {i.alternativas.map((a, k) => (
                <div key={a.alternativa_id}>
                  <label className={a.correta ? 'ok' : a.alternativa_id === i.escolhida ? 'ruim' : ''}>
                    {LETRAS[k]}) {a.texto} {a.correta ? '(correta)' : a.alternativa_id === i.escolhida ? '(sua resposta)' : ''}
                  </label>
                  <p className="just">{a.correta ? '' : `${CAT[a.categoria ?? ''] ?? ''}: `}{a.justificativa}</p>
                </div>
              ))}
            </div>
          ))}
          <button type="button" className="sec" onClick={() => setGab(null)}>Voltar aos testes</button>
        </div>
      )}
    </section>
  );
}
EOF
echo "criado: pwa/src/pages/aluno/Testes.tsx"

if ! grep -q "pages/aluno/Testes.js" "$PWA/App.tsx"; then
  sed -i "s#^import { Leitura } from './pages/aluno/Leitura.js';#import { Leitura } from './pages/aluno/Leitura.js';\nimport { Testes } from './pages/aluno/Testes.js';#" "$PWA/App.tsx"
  sed -i "s#^\( *\)<Route path=\"/aluno/leitura/\*\" element={<Leitura />} />#\1<Route path=\"/aluno/testes/*\" element={<Testes />} />\n\1<Route path=\"/aluno/leitura/*\" element={<Leitura />} />#" "$PWA/App.tsx"
  grep -q 'path="/aluno/testes/\*"' "$PWA/App.tsx" || { echo "ERRO: nao consegui registrar a rota de testes"; exit 1; }
fi
if ! grep -q "/aluno/testes/T001" "$PWA/pages/aluno/Home.tsx"; then
  sed -i 's#^\( *\)<p><a href="/aluno/leitura/T001">Material do tema T001</a></p>#\1<p><a href="/aluno/testes/T001">Testes do tema T001</a> · <a href="/aluno/leitura/T001">Material do tema T001</a></p>#' "$PWA/pages/aluno/Home.tsx"
fi
# Leitura: aviso de etapa e link para os testes
python3 - "$PWA/pages/aluno/Leitura.tsx" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
if 'etapa?: number' not in s:
    s=s.replace("interface Resposta { tema: { codigo: string; titulo: string }; previa: boolean; artefatos: Artefato[] }",
                "interface Resposta { tema: { codigo: string; titulo: string }; previa: boolean; artefatos: Artefato[]; etapa?: number; bloqueados?: number }")
    a="""      {!art ? ("""
    b="""      {!dados.previa && (dados.bloqueados ?? 0) > 0 && (
        <div className="faixa">Há material ainda bloqueado. Ele é liberado à medida que você responde os testes: <a href={`/aluno/testes/${dados.tema.codigo.replace('-', '')}`}>ir para os testes</a>.</div>
      )}
      {!art ? ("""
    if a not in s: sys.exit("ERRO: nao encontrei o ponto de insercao em Leitura.tsx")
    s=s.replace(a,b,1)
    s=s.replace("<p>Ainda não há material publicado para este tema.</p>","<p>Nenhum material liberado ainda. Comece pelo <a href={`/aluno/testes/${dados.tema.codigo.replace('-', '')}`}>pré-teste inicial</a>.</p>")
    open(p,'w').write(s); print("atualizado: pwa/src/pages/aluno/Leitura.tsx")
else:
    print("Leitura.tsx ja atualizado")
PY
echo "=== testes do aluno instalados ==="
