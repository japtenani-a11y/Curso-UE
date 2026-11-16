#!/usr/bin/env bash
# ============================================================
# 85_estudo_app_v1.0.sh
# OBJETIVO: telas do SQL 85.
#  - Leitura: pecas agrupadas em "Antes da aula", "Aula" e "Depois da aula", com a marca de visto ou feito;
#    o caso da aula recebe o ano do aluno (dicas so para graduacao, R1 e R2).
#  - Inicio: "O que fazer agora" (uma acao em destaque), "Continuar de onde parou" e o convite para os avisos no celular.
#  - Desempenho: "A sua certeza" (acerto por nivel de certeza e o que fazer com isso).
#  - Estudo dirigido: revisao do dia das questoes (repeticao espacada) e simulado misturado de temas.
#  - Lembretes: avisos no celular (ligar e desligar neste aparelho); enviador e service worker com o canal "push".
#  - Painel: abas "Base de análise" (uma linha por resposta, com as marcas de qualidade), "Questões (dados válidos)"
#    e "Indicadores clínicos" (com o formulario para digitar os totais do mes).
# USO: bash 85_estudo_app_v1.0.sh ./programa-cut
# PRE-REQUISITO: 46, 61, 68, 82, 83. Rodar depois do 83. Pode ser rodado mais de uma vez.
# ============================================================
set -euo pipefail
RAIZ="${1:?uso: bash 85_estudo_app_v1.0.sh <pasta programa-cut>}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
M="$AQUI/modelos/interativo_v1.0"
cp "$M/api/src/push_envio.ts" "$M/api/src/push_chaves.ts" "$RAIZ/api/src/"
cp "$M/api/src/routes/push.ts" "$RAIZ/api/src/routes/"
cp "$M"/pwa/src/components/leitura/*.tsx "$RAIZ/pwa/src/components/leitura/"
python3 - "$RAIZ" <<'PY'
import sys, os, json
raiz = sys.argv[1]
def ler(p): return open(p, encoding='utf-8').read()
def gravar(p, s): open(p, 'w', encoding='utf-8').write(s)
def trocar(s, a, b, marca, nome):
    if marca in s: return s
    if a not in s: sys.exit(f"ERRO: nao encontrei o ponto de ajuste em {nome}: {a[:80]}")
    return s.replace(a, b, 1)
def arq(rel): return os.path.join(raiz, rel)

# ---------- API ----------
p = arq('api/src/main.ts'); s = ler(p)
s = trocar(s, "import { leituraRouter } from './routes/leitura.js';", "import { leituraRouter } from './routes/leitura.js';\nimport { pushRouter } from './routes/push.js';", 'pushRouter', 'main.ts')
s = trocar(s, "app.use('/leitura', limite('leitura', 240, 60_000), exigirCadastro, conteudoProtegido, leituraRouter);",
           "app.use('/leitura', limite('leitura', 240, 60_000), exigirCadastro, conteudoProtegido, leituraRouter);\napp.use('/push', limite('push', 60, 60_000), pushRouter);",
           "app.use('/push'", 'main.ts')
gravar(p, s)

p = arq('api/package.json'); j = json.load(open(p, encoding='utf-8'))
j.setdefault('scripts', {})['chaves-push'] = 'tsx src/push_chaves.ts'
open(p, 'w', encoding='utf-8').write(json.dumps(j, indent=2, ensure_ascii=False) + '\n')

p = arq('api/src/routes/leitura.ts'); s = ler(p)
s = trocar(s, "app.perfil_da_pessoa($2) AS perfil\n           FROM app.tema",
           "app.perfil_da_pessoa($2) AS perfil, app.situacao_pecas(codigo) AS situacao\n           FROM app.tema", 'app.situacao_pecas(codigo)', 'leitura.ts')
s = trocar(s, "perfil: t.perfil ?? null, artefatos: liberados };", "perfil: t.perfil ?? null, situacao: t.situacao ?? {}, artefatos: liberados };", 'situacao: t.situacao', 'leitura.ts')
gravar(p, s)

p = arq('api/src/routes/estudo.ts'); s = ler(p)
s = trocar(s, "grau_max: Number(b.grau_max) || 6, quantidade: Number(b.quantidade) || 10 };",
           "grau_max: Number(b.grau_max) || 6, quantidade: Number(b.quantidade) || 10,\n      modo: ['revisao', 'misturado'].includes(String(b.modo)) ? String(b.modo) : undefined };", "['revisao', 'misturado']", 'estudo.ts')
s = trocar(s, "// ---------- simulados ----------", """// ---------- revisao do dia (questoes vencidas e cartoes) ----------
estudoRouter.get('/revisao-do-dia', async (_req, res, next) => {
  try { res.setHeader('Cache-Control', 'no-store'); res.json(await um('SELECT app.revisao_do_dia() AS r')); } catch (e) { erro(e, res, next); }
});

// ---------- simulados ----------""", "'/revisao-do-dia'", 'estudo.ts')
gravar(p, s)

p = arq('api/src/routes/painel.ts'); s = ler(p)
s = trocar(s, "  caso_base: 'SELECT * FROM app.painel_caso_base()',",
           "  caso_base: 'SELECT * FROM app.painel_caso_base()',\n  base: 'SELECT * FROM app.pesquisa_respostas()',\n  itens: 'SELECT * FROM app.analise_itens()',\n  indicadores: 'SELECT * FROM app.painel_indicadores()',",
           'app.pesquisa_respostas()', 'painel.ts')
s = trocar(s, "painelRouter.get('/:conjunto', async (req, res, next) => {", """// Indicadores clinicos: a coordenacao digita o total do mes (o banco recusa quem nao e da coordenacao).
painelRouter.post('/indicadores', async (req, res, next) => {
  try {
    const b = (req.body ?? {}) as Record<string, unknown>;
    const ind = String(b.indicador ?? ''); const mes = String(b.mes ?? '');
    const num = Number(b.numerador); const den = Number(b.denominador);
    if (!/^[a-z_]{3,40}$/.test(ind) || !/^\\d{4}-\\d{2}-01$/.test(mes) || !Number.isInteger(num) || !Number.isInteger(den) || den <= 0 || num < 0 || num > den) {
      res.status(400).json({ erro: 'dados_invalidos' }); return;
    }
    await withMaestro(null, async (c) => { await c.query('SELECT app.salvar_indicador($1, $2::date, $3, $4, $5)', [ind, mes, num, den, String(b.fonte ?? '').slice(0, 200)]); });
    res.json({ ok: true });
  } catch (err) {
    if (String((err as Error).message).includes('so_coordenacao')) { res.status(403).json({ erro: 'so_coordenacao' }); return; }
    next(err);
  }
});

painelRouter.get('/:conjunto', async (req, res, next) => {""", "painelRouter.post('/indicadores'", 'painel.ts')
gravar(p, s)

# enviador: canal push
p = arq('api/src/notificador.ts')
if os.path.exists(p):
    s = ler(p)
    s = trocar(s, "import { logger } from './db/logger.js';", "import { logger } from './db/logger.js';\nimport { enviarSinal, pushConfigurado } from './push_envio.js';", 'push_envio.js', 'notificador.ts')
    s = trocar(s, "const canais: string[] = MODO === 'simular' ? ['email', 'whatsapp']\n  : [EMAIL_OK ? 'email' : '', ZAP_OK ? 'whatsapp' : ''].filter(Boolean);",
               "const canais: string[] = MODO === 'simular' ? ['email', 'whatsapp', 'push']\n  : [EMAIL_OK ? 'email' : '', ZAP_OK ? 'whatsapp' : '', pushConfigurado() ? 'push' : ''].filter(Boolean);",
               "pushConfigurado() ? 'push'", 'notificador.ts')
    s = trocar(s, "export async function rodadaDeEnvio()", """// Avisos no celular: um sinal para cada aparelho ativo da pessoa; aparelho que o servico recusar e desativado.
async function enviarPush(m: Msg): Promise<void> {
  const pessoa = Number(String(m.destino).replace('pessoa:', ''));
  const destinos = await withMaestro(null, async (c) => (await c.query('SELECT endpoint FROM app.push_destinos($1)', [pessoa])).rows as { endpoint: string }[]);
  if (destinos.length === 0) throw new Error('sem aparelho inscrito');
  for (const d of destinos) {
    if (await enviarSinal(d.endpoint) === 'expirado') await withMaestro(null, async (c) => { await c.query('SELECT app.push_desativar($1)', [d.endpoint]); });
  }
}

export async function rodadaDeEnvio()""", 'async function enviarPush', 'notificador.ts')
    s = trocar(s, "  if (canais.length === 0) return { fila, enviadas: 0, erros: 0 };",
               "  await withMaestro(null, async (c) => { await c.query('SELECT app.enfileirar_push()'); });\n  if (canais.length === 0) return { fila, enviadas: 0, erros: 0 };",
               'app.enfileirar_push()', 'notificador.ts')
    s = trocar(s, "      } else if (m.canal === 'email') await enviarEmail(m);\n      else await enviarWhatsapp(m);",
               "      } else if (m.canal === 'email') await enviarEmail(m);\n      else if (m.canal === 'push') await enviarPush(m);\n      else await enviarWhatsapp(m);",
               "m.canal === 'push'", 'notificador.ts')
    gravar(p, s)

# service worker: receber o sinal, buscar o texto e abrir o aplicativo no lugar certo
p = arq('pwa/public/sw.js'); s = ler(p)
if '// avisos no celular' not in s:
    s += """
// avisos no celular: o sinal chega sem conteudo; o texto vem do servidor, com o login do aluno
self.addEventListener('push', (e) => {
  e.waitUntil((async () => {
    let itens = [];
    try {
      const c = await caches.open('cut-config'); const r = await c.match('/__api'); const api = r ? await r.text() : '';
      if (api) { const resp = await fetch(api + '/push/pendentes', { credentials: 'include' }); if (resp.ok) itens = (await resp.json()).avisos || []; }
    } catch (_) { /* sem rede: aviso generico */ }
    if (!itens.length) itens = [{ titulo: 'CUT', texto: 'Você tem um aviso novo no curso.', caminho: '/aluno' }];
    for (const a of itens.slice(0, 3)) {
      await self.registration.showNotification(a.titulo, { body: a.texto, icon: '/icone-192.png', badge: '/icone-192.png', data: { caminho: a.caminho } });
    }
  })());
});
self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  const url = (e.notification.data && e.notification.data.caminho) || '/aluno';
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((ws) => {
    for (const w of ws) { if ('focus' in w) { w.navigate(url); return w.focus(); } }
    return self.clients.openWindow(url);
  }));
});
"""
    gravar(p, s)

# ---------- PWA ----------
p = arq('pwa/src/pages/aluno/Leitura.tsx'); s = ler(p)
s = trocar(s, "import { useMemoriaTema } from '../../components/leitura/Continuar.js';",
           "import { useMemoriaTema } from '../../components/leitura/Continuar.js';\nimport { AbasPorEtapa } from '../../components/leitura/AbasPorEtapa.js';", 'AbasPorEtapa.js', 'Leitura.tsx')
s = trocar(s, "bloqueados?: number; perfil?: string | null }", "bloqueados?: number; perfil?: string | null; situacao?: Record<string, string> }", 'situacao?: Record<string, string>', 'Leitura.tsx')
s = trocar(s, """          <div className="abas">
            {dados.artefatos.map((a, i) => (
              <button key={a.artefato_id} type="button" className={`aba${i === ativo ? ' ativa' : ''}`} onClick={() => setAtivo(i)}>
                {a.titulo}
              </button>
            ))}
          </div>""", """          <AbasPorEtapa pecas={dados.artefatos} ativo={ativo} mudar={setAtivo} situacao={dados.situacao ?? {}} etapa={dados.etapa ?? 1} previa={dados.previa} />""",
           '<AbasPorEtapa pecas=', 'Leitura.tsx')
s = trocar(s, "<CasoInterativo key={`c${art.artefato_id}`} codigo={dados.tema.codigo} corpo={limpar(art.corpo, false)} />",
           "<CasoInterativo key={`c${art.artefato_id}`} codigo={dados.tema.codigo} corpo={limpar(art.corpo, false)} perfil={dados.perfil} />",
           'corpo={limpar(art.corpo, false)} perfil={dados.perfil} />', 'Leitura.tsx')
gravar(p, s)

p = arq('pwa/src/pages/aluno/Home.tsx'); s = ler(p)
s = trocar(s, "import { Continuar } from '../../components/leitura/Continuar.js';", "import { ProximaAcao } from '../../components/leitura/ProximaAcao.js';", 'ProximaAcao.js', 'Home.tsx')
s = trocar(s, "      <Lembretes />\n      <Continuar />\n", "      <ProximaAcao />\n      <Lembretes />\n", '<ProximaAcao />', 'Home.tsx')
gravar(p, s)

p = arq('pwa/src/pages/aluno/Desempenho.tsx'); s = ler(p)
s = trocar(s, "import { EvolucaoAluno } from '../../components/Comparativo.js';",
           "import { EvolucaoAluno } from '../../components/Comparativo.js';\nimport { MinhaCalibracao } from '../../components/leitura/MinhaCalibracao.js';", 'MinhaCalibracao.js', 'Desempenho.tsx')
s = trocar(s, "      <EvolucaoAluno comSeletor />\n", "      <EvolucaoAluno comSeletor />\n      <MinhaCalibracao />\n", '<MinhaCalibracao />', 'Desempenho.tsx')
gravar(p, s)

p = arq('pwa/src/pages/aluno/Estudo.tsx'); s = ler(p)
s = trocar(s, "import { apiGet, apiPost } from '../../lib/api.js';",
           "import { apiGet, apiPost } from '../../lib/api.js';\nimport { RevisaoEspacada } from '../../components/leitura/RevisaoEspacada.js';", 'RevisaoEspacada.js', 'Estudo.tsx')
s = trocar(s, "  async function entregar() {\n    if (!sim) return;", """  async function montarModo(modo: 'revisao' | 'misturado') {
    setOcupado(true); setMsg(null);
    try {
      const s = await apiPost<Simulado>('/estudo/simulados', { modo, quantidade: modo === 'revisao' ? 20 : qtd });
      setSim(s); setResp({}); inicio.current = Date.now(); window.scrollTo(0, 0);
    } catch { setMsg(modo === 'revisao' ? 'Nenhuma questão para revisar hoje.' : 'Ainda não há questões suficientes para misturar.'); }
    setOcupado(false);
  }
  useEffect(() => { if (new URLSearchParams(window.location.search).get('modo') === 'revisao') void montarModo('revisao'); }, []); // eslint-disable-line react-hooks/exhaustive-deps
  async function entregar() {
    if (!sim) return;""", 'async function montarModo', 'Estudo.tsx')
s = trocar(s, """    <div>
      <article className="cartao-app">
        <h2>Montar um simulado</h2>""", """    <div>
      <RevisaoEspacada iniciar={montarModo} ocupado={ocupado} irFlashcards={() => { window.location.href = '/aluno/estudo?aba=flashcards'; }} />
      <article className="cartao-app">
        <h2>Montar um simulado</h2>""", '<RevisaoEspacada iniciar', 'Estudo.tsx')
gravar(p, s)

p = arq('pwa/src/pages/aluno/Contato.tsx'); s = ler(p)
if "AvisosCelular" not in s:
    s = s.replace("import ", "import { AvisosCelular } from '../../components/leitura/AvisosCelular.js';\nimport ", 1)
    s = trocar(s, "      <a href=\"/aluno\">Voltar ao início</a>\n    </section>", "      <a href=\"/aluno\">Voltar ao início</a>\n      <AvisosCelular />\n    </section>", '<AvisosCelular />', 'Contato.tsx')
gravar(p, s)

p = arq('pwa/src/pages/painel/Painel.tsx'); s = ler(p)
s = trocar(s, "| 'caso' | 'caso_base';", "| 'caso' | 'caso_base' | 'base' | 'itens' | 'indicadores';", "| 'indicadores'", 'Painel.tsx')
s = trocar(s, "  { id: 'caso', rotulo: 'Caso da aula' }, { id: 'caso_base', rotulo: 'Caso base' },",
           "  { id: 'caso', rotulo: 'Caso da aula' }, { id: 'caso_base', rotulo: 'Caso base' },\n  { id: 'base', rotulo: 'Base de análise' }, { id: 'itens', rotulo: 'Questões (dados válidos)' }, { id: 'indicadores', rotulo: 'Indicadores clínicos' },",
           "rotulo: 'Indicadores clínicos'", 'Painel.tsx')
s = trocar(s, "import { useEffect, useMemo, useState } from 'react';",
           "import { useEffect, useMemo, useState } from 'react';\nimport { FormIndicador } from '../../components/leitura/FormIndicador.js';", 'FormIndicador.js', 'Painel.tsx')
s = trocar(s, "      {aba !== 'graficos' && (dados[aba] ?", "      {aba === 'indicadores' && <FormIndicador aoSalvar={(linhas) => setDados((x) => ({ ...x, indicadores: linhas as Linha[] }))} />}\n      {aba !== 'graficos' && (dados[aba] ?",
           '<FormIndicador aoSalvar', 'Painel.tsx')
gravar(p, s)
print('85: telas prontas')
PY
