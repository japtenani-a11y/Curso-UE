#!/usr/bin/env bash
# ============================================================
# 44_lembretes_app_v1.0.sh
# OBJETIVO: mostrar ao aluno os lembretes de pos-teste pendente (7, 14, 28 e 60 dias apos a data)
# e abrir automaticamente as ondas cuja data chegou.
#  - API: GET /teste/lembretes (gera e lista os lembretes da pessoa) e POST /teste/lembretes/:id/lido
#  - PWA: aviso no topo da pagina inicial do aluno, com link para os testes
# USO: bash 44_lembretes_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 40_testes_aluno_v1.0.sh e, no banco, 43_calendario_lembretes_v1.0.sql. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 44_lembretes_app_v1.0.sh <pasta programa-cut>}"
API="$RAIZ/api/src"; PWA="$RAIZ/pwa/src"
[ -f "$API/routes/teste.ts" ] || { echo "ERRO: rode antes o 40_testes_aluno_v1.0.sh"; exit 1; }

if ! grep -q "/lembretes'" "$API/routes/teste.ts"; then
cat >> "$API/routes/teste.ts" <<'EOF'

// Lembretes de pos-teste pendente da pessoa logada (gera os que faltam e lista os nao lidos).
testeRouter.get('/lembretes', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const lembretes = await withMaestro(null, async (client) => {
      await client.query('SELECT app.abrir_ondas_do_dia()');
      await client.query('SELECT app.gerar_lembretes_pessoa()');
      const { rows } = await client.query(
        `SELECT l.lembrete_id, l.dias_apos, o.teste_num, o.data_abertura, t.codigo AS tema, t.titulo
           FROM app.lembrete l
           JOIN app.onda_instancia o ON o.onda_id = l.onda_id
           JOIN app.tema t ON t.tema_id = o.tema_id
          WHERE l.lido_em IS NULL AND NOT app.teste_submetido(l.pessoa_id, o.tema_id, o.teste_num)
          ORDER BY l.dias_apos DESC, o.data_abertura`);
      return rows;
    });
    res.json({ lembretes });
  } catch (err) { next(err); }
});

testeRouter.post('/lembretes/:id/lido', async (req, res, next) => {
  try {
    const p = pessoa(req as unknown as Req);
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    await withMaestro(null, async (client) => {
      await client.query('UPDATE app.lembrete SET lido_em = now() WHERE lembrete_id = $1', [Number(req.params.id)]);
    });
    res.json({ ok: true });
  } catch (err) { next(err); }
});
EOF
echo "atualizado: api/src/routes/teste.ts (lembretes)"
fi

mkdir -p "$PWA/components"
cat > "$PWA/components/Lembretes.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet, apiPost } from '../lib/api.js';

interface Lembrete { lembrete_id: number; dias_apos: number; teste_num: number; tema: string; titulo: string }
const NOMES = ['', 'Pré-teste inicial', 'Pré-teste 2', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90'];

export function Lembretes() {
  const [lista, setLista] = useState<Lembrete[]>([]);
  useEffect(() => {
    apiGet<{ lembretes: Lembrete[] }>('/teste/lembretes').then((d) => setLista(d.lembretes)).catch(() => setLista([]));
  }, []);
  async function dispensar(id: number) {
    try { await apiPost(`/teste/lembretes/${id}/lido`, {}); } catch { /* segue */ }
    setLista(lista.filter((l) => l.lembrete_id !== id));
  }
  if (lista.length === 0) return null;
  return (
    <div style={{ background: '#fff3cd', border: '1px solid #d9a400', borderRadius: 8, padding: '8px 12px', margin: '8px 0', fontFamily: 'system-ui, sans-serif' }}>
      {lista.map((l) => (
        <p key={l.lembrete_id} style={{ margin: '4px 0' }}>
          {NOMES[l.teste_num]} de {l.tema} pendente há {l.dias_apos} dias.{' '}
          <a href={`/aluno/testes/${l.tema.replace('-', '')}`}>Responder agora</a>{' '}
          <button type="button" onClick={() => dispensar(l.lembrete_id)} style={{ marginLeft: 8 }}>Dispensar</button>
        </p>
      ))}
    </div>
  );
}
EOF
echo "criado: pwa/src/components/Lembretes.tsx"

if ! grep -q "components/Lembretes.js" "$PWA/pages/aluno/Home.tsx"; then
  sed -i "0,/^import /s#^import #import { Lembretes } from '../../components/Lembretes.js';\nimport #" "$PWA/pages/aluno/Home.tsx"
  sed -i 's#^\( *\)<h1>Minhas ondas</h1>#\1<Lembretes />\n\1<h1>Minhas ondas</h1>#' "$PWA/pages/aluno/Home.tsx"
  grep -q "<Lembretes />" "$PWA/pages/aluno/Home.tsx" || { echo "ERRO: nao consegui inserir os lembretes na pagina inicial"; exit 1; }
  echo "atualizado: pwa/src/pages/aluno/Home.tsx"
fi
echo "=== lembretes instalados ==="
