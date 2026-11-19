#!/usr/bin/env bash
# ============================================================
# 107_autorizacao_revisor_app_v1.0.sh
# OBJETIVO (decisão da coordenação de 19/11/2026): na primeira entrada no sistema, o revisor (papel curador) vê o termo de
# autorização e de conflitos de interesse e clica "Autorizo" (sem conflitos ou com a descrição deles). Precisa do
# 107_autorizacao_revisor_v1.0.sql. Roda depois dos outros scripts *_app. Pode ser rodado mais de uma vez.
# USO: bash 107_autorizacao_revisor_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -f "$API/routes/curador.ts" ] && [ -f "$PWA/App.tsx" ] || { echo "ERRO: codigo gerado nao encontrado em $RAIZ"; exit 1; }

python3 - "$API/routes/curador.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if "'/autorizacao'" not in s:
    marca = "curadorRouter.get('/temas',"
    assert marca in s, 'curador.ts mudou'
    novo = """// Termo do revisor (107): situação e registro da autorização, sempre da própria pessoa
curadorRouter.get('/autorizacao', async (req, res, next) => {
  try {
    const p = (req as unknown as { pessoaId?: number }).pessoaId;
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const r = await withMaestro(null, (c) => c.query('SELECT app.autorizacao_revisor_situacao($1) AS s', [p]));
    res.json(r.rows[0]?.s ?? {});
  } catch (err) { next(err); }
});

curadorRouter.post('/autorizacao', async (req, res, next) => {
  try {
    const p = (req as unknown as { pessoaId?: number }).pessoaId;
    if (!p) { res.status(401).json({ erro: 'sem_sessao' }); return; }
    const b = (req.body ?? {}) as { sem_conflitos?: boolean; conflitos?: string };
    const r = await withMaestro(null, (c) => c.query('SELECT app.registrar_autorizacao_revisor($1, $2, $3) AS s',
      [p, b.sem_conflitos !== false, b.conflitos ?? null]));
    res.json(r.rows[0]?.s ?? {});
  } catch (err) {
    const m = String((err as Error).message ?? '');
    if (m.includes('descreva_os_conflitos')) { res.status(400).json({ erro: 'descreva_os_conflitos' }); return; }
    next(err);
  }
});

"""
    s = s.replace(marca, novo + marca, 1)
    open(p, 'w').write(s)
EOF

cat > "$PWA/components/AutorizacaoRevisor.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import { apiGet, apiPost } from '../lib/api.js';

interface Situacao { revisor?: boolean; autorizado?: boolean; versao_termo?: string }

// Termo do revisor: aparece uma vez, para quem é revisor (curador) e ainda não autorizou.
export function AutorizacaoRevisor() {
  const loc = useLocation();
  const [sit, setSit] = useState<Situacao | null>(null);
  const [aceito, setAceito] = useState(false);
  const [semConflitos, setSemConflitos] = useState(true);
  const [conflitos, setConflitos] = useState('');
  const [enviando, setEnviando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    if (sit?.autorizado || !loc.pathname.startsWith('/curador')) return;
    apiGet<Situacao>('/curador/autorizacao').then(setSit).catch(() => undefined);
  }, [loc.pathname]); // eslint-disable-line react-hooks/exhaustive-deps

  if (!sit?.revisor || sit.autorizado) return null;

  async function enviar() {
    setEnviando(true); setErro(null);
    try { setSit(await apiPost<Situacao>('/curador/autorizacao', { sem_conflitos: semConflitos, conflitos })); }
    catch { setErro(semConflitos ? 'Não foi possível registrar. Tente de novo.' : 'Descreva os conflitos (empresa ou instituição e tipo de relação).'); }
    finally { setEnviando(false); }
  }

  return (
    <div role="dialog" aria-modal="true" aria-labelledby="termo-titulo"
      style={{ position: 'fixed', inset: 0, background: 'rgba(14,23,38,0.55)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: 16 }}>
      <article className="cartao-app" style={{ maxWidth: 560, width: '100%', maxHeight: '90vh', overflowY: 'auto' }}>
        <h2 id="termo-titulo">Autorização do revisor</h2>
        <p>Os guias de atendimento do curso trazem, na seção "Grupo de elaboração e conflitos de interesse", o nome de quem revisou.
          Antes de começar, confirme:</p>
        <ul>
          <li>autorizo que meu nome, formação e instituição apareçam no grupo de elaboração dos guias que eu revisar, no aplicativo e no PDF;</li>
          <li>sei que o guia é uma proposta do curso, adaptável a cada serviço, e não é norma institucional até ser aprovado pelo hospital;</li>
          <li>posso retirar a autorização a qualquer momento, pela coordenação; meu nome sai na versão seguinte.</li>
        </ul>
        <label style={{ display: 'flex', gap: 8, alignItems: 'flex-start', margin: '12px 0' }}>
          <input type="checkbox" checked={aceito} onChange={(e) => setAceito(e.target.checked)} style={{ minWidth: 24, minHeight: 24 }} />
          <span>Autorizo, nos termos acima (termo versão {sit.versao_termo}).</span>
        </label>
        <fieldset style={{ border: 0, padding: 0, margin: '8px 0' }}>
          <legend>Conflitos de interesse nos últimos 36 meses (empresas, financiamento, autoria de diretriz citada, cargos)</legend>
          <label style={{ display: 'block', margin: '6px 0' }}>
            <input type="radio" name="conf" checked={semConflitos} onChange={() => setSemConflitos(true)} /> Não tenho conflitos a declarar
          </label>
          <label style={{ display: 'block', margin: '6px 0' }}>
            <input type="radio" name="conf" checked={!semConflitos} onChange={() => setSemConflitos(false)} /> Tenho conflitos:
          </label>
          {!semConflitos && (
            <textarea rows={4} value={conflitos} onChange={(e) => setConflitos(e.target.value)} style={{ width: '100%' }}
              placeholder="Empresa ou instituição, tipo de relação e, se houver, o tema em que o conflito pesa" />
          )}
        </fieldset>
        {erro && <p role="alert">{erro}</p>}
        <button type="button" className="botao" disabled={!aceito || enviando || (!semConflitos && conflitos.trim().length < 5)} onClick={enviar}>
          {enviando ? 'Registrando…' : 'Autorizo e quero começar'}
        </button>
      </article>
    </div>
  );
}
EOF

python3 - "$PWA/App.tsx" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if 'AutorizacaoRevisor' not in s:
    imp = "import { Routes, Route, Navigate } from 'react-router-dom';\n"
    assert imp in s, 'App.tsx mudou (import)'
    s = s.replace(imp, imp + "import { AutorizacaoRevisor } from './components/AutorizacaoRevisor.js';\n", 1)
    assert s.count('    <Routes>') == 1 and s.count('    </Routes>') == 1, 'App.tsx mudou (Routes)'
    s = s.replace('    <Routes>', '    <>\n    <AutorizacaoRevisor />\n    <Routes>', 1).replace('    </Routes>', '    </Routes>\n    </>', 1)
    open(p, 'w').write(s)
EOF
echo "termo do revisor (autorizacao na primeira entrada): pronto"
