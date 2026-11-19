#!/usr/bin/env bash
# ============================================================
# 104_meu_material_app_v1.0.sh
# OBJETIVO (pedido da coordenacao em 19/11/2026): quadro "Meu material" no Inicio do aluno, logo no topo, com todo
# o material liberado para ele, de todos os temas, em duas abas: "Novo" (ainda nao aberto) e "Ja visto".
# Cada linha abre a peca direto (/aluno/leitura/TEMA?peca=tipo). Precisa do 104_meu_material_v1.0.sql.
# Roda depois dos outros scripts *_app. Pode ser rodado mais de uma vez.
# USO: bash 104_meu_material_app_v1.0.sh [RAIZ]
# ============================================================
set -euo pipefail
RAIZ="${1:-./programa-cut}"
PWA="$RAIZ/pwa/src"; API="$RAIZ/api/src"
[ -f "$API/routes/jornada.ts" ] && [ -f "$PWA/pages/aluno/Home.tsx" ] || { echo "ERRO: codigo gerado nao encontrado em $RAIZ"; exit 1; }

python3 - "$API/routes/jornada.ts" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if "'/meu-material'" not in s:
    marca = "jornadaRouter.get('/pendencias',"
    assert marca in s, 'jornada.ts mudou'
    novo = """jornadaRouter.get('/meu-material', async (_req, res, next) => {
  try {
    const itens = await withMaestro(null, async (c) => (await c.query('SELECT * FROM app.meu_material()')).rows);
    res.json({ itens });
  } catch (err) { next(err); }
});

"""
    s = s.replace(marca, novo + marca, 1)
    open(p, 'w').write(s)
EOF

cat > "$PWA/components/MeuMaterial.tsx" <<'EOF'
import { useEffect, useState } from 'react';
import { apiGet } from '../lib/api.js';

interface Peca { codigo: string; titulo: string; tipo: string; publicado_em: string | null; visto: boolean; ultimo_acesso: string | null }

const NOME: Record<string, string> = {
  objetivos: 'Objetivos', resumo_basico: 'Resumo básico', podcast_roteiro: 'Podcast', caso_base: 'Caso base',
  sintese_evidencia: 'Síntese da evidência', mapa: 'Mapa conceitual', aula: 'Aula', slides: 'Slides', caso: 'Caso da aula',
  resumo: 'Resumo executivo', protocolo: 'Protocolo', checklist: 'Checklist', flashcard: 'Flashcards', simulado: 'Simulado',
};
const MOSTRAR = 8;

// Inicio do aluno: todo o material ja liberado, em "Novo" e "Ja visto", com acesso direto a cada peca.
export function MeuMaterial() {
  const [itens, setItens] = useState<Peca[] | null>(null);
  const [aba, setAba] = useState<'novo' | 'visto'>('novo');
  const [todos, setTodos] = useState(false);
  useEffect(() => { apiGet<{ itens: Peca[] }>('/jornada/meu-material').then((d) => setItens(d.itens)).catch(() => setItens([])); }, []);
  if (itens === null) return null;
  const novos = itens.filter((i) => !i.visto), vistos = itens.filter((i) => i.visto);
  const lista = aba === 'novo' ? novos : vistos;
  const mostrar = todos ? lista : lista.slice(0, MOSTRAR);
  return (
    <article className="cartao-app meu-material" aria-labelledby="meu-material-titulo">
      <span className="rotulo" id="meu-material-titulo">Meu material</span>
      {itens.length === 0 ? (
        <p>O material de cada tema aparece aqui assim que for liberado para você (depois do pré-teste 1 do tema).</p>
      ) : (<>
        <div className="abas" role="tablist" style={{ display: 'flex', gap: 8, margin: '6px 0 10px', flexWrap: 'wrap' }}>
          <button type="button" role="tab" aria-selected={aba === 'novo'} className={`botao${aba === 'novo' ? '' : ' discreto'}`}
            onClick={() => { setAba('novo'); setTodos(false); }}>Novo ({novos.length})</button>
          <button type="button" role="tab" aria-selected={aba === 'visto'} className={`botao${aba === 'visto' ? '' : ' discreto'}`}
            onClick={() => { setAba('visto'); setTodos(false); }}>Já visto ({vistos.length})</button>
        </div>
        {lista.length === 0 ? (
          <p>{aba === 'novo' ? 'Você já abriu todo o material liberado até agora.' : 'Você ainda não abriu nenhuma peça.'}</p>
        ) : (
          <ul className="lista-temas">
            {mostrar.map((i) => (
              <li key={`${i.codigo}-${i.tipo}`}>
                <a href={`/aluno/leitura/${i.codigo}?peca=${i.tipo}`}>
                  <span className="cod">{i.codigo}</span>
                  <span className="tit">{NOME[i.tipo] ?? i.tipo} · {i.titulo}</span>
                  <span className={`selo ${i.visto ? 'eletivo' : 'nuclear'}`}>{i.visto ? 'visto' : 'novo'}</span>
                  <span className="sit" />
                </a>
              </li>
            ))}
          </ul>
        )}
        {lista.length > MOSTRAR && (
          <p><button type="button" className="botao discreto" onClick={() => setTodos(!todos)}>
            {todos ? 'Mostrar menos' : `Mostrar todos (${lista.length})`}</button></p>
        )}
      </>)}
    </article>
  );
}
EOF

python3 - "$PWA/pages/aluno/Home.tsx" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
if 'MeuMaterial' not in s:
    a = "import { ProximaAcao } from '../../components/leitura/ProximaAcao.js';\n"
    b = "      <ProximaAcao />\n"
    assert a in s and b in s, 'Home.tsx mudou'
    s = s.replace(a, a + "import { MeuMaterial } from '../../components/MeuMaterial.js';\n", 1)
    s = s.replace(b, b + "      <MeuMaterial />\n", 1)
    open(p, 'w').write(s)
EOF
echo "meu material no Inicio do aluno: pronto"
