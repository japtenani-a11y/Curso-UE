#!/usr/bin/env python3
# analise_cut_v1.0.py
# Analise descritiva e de qualidade da base de respostas do CUT (aba "Base de análise" do painel, ou
# analise/exportar_base_v1.0.sql). Gera um relatorio HTML com graficos, no padrao do plano de analise
# (docs/plano_analise_preregistro.md). Os modelos confirmatorios (regressao logistica mista) ficam no script R
# do plano (modelo_cut.py: regressao logistica com erro padrao agrupado por participante) entram na secao 5.
# USO:
#   python3 analise/analise_cut_v1.0.py analise/base_respostas.csv                 (so respostas validas)
#   python3 analise/analise_cut_v1.0.py analise/base_respostas.csv --so-simulados  (ensaio com os dados simulados)
# SAIDA: analise/relatorio_cut.html
# Requer: pandas, scipy, matplotlib.
import argparse, base64, io, html, sys
import numpy as np
import pandas as pd
from scipy import stats
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import modelo_cut   # modelo principal do plano (numpy e scipy)

ONDAS = ['Pré-teste 1', 'Pré-teste 2', 'Pós-teste D0', 'Pós-teste D+15', 'Pós-teste D+45', 'Pós-teste D+90']
CURTO = ['Pré 1', 'Pré 2', 'D0', 'D+15', 'D+45', 'D+90']
COR = '#1f3a5f'; COR2 = '#b45309'
RNG = np.random.default_rng(2027)

def ler(caminho):
    df = pd.read_csv(caminho, sep=';', encoding='utf-8-sig')
    for c in ['correta', 'rapida', 'apos_aula', 'equipe', 'simulado', 'consentiu', 'valida']:
        if c in df: df[c] = df[c].astype(str).str.lower().isin(['t', 'true', 'sim', '1'])
    df['onda'] = df['teste_num'].astype(int)
    return df

def fig_b64(fig):
    b = io.BytesIO(); fig.savefig(b, format='png', dpi=140, bbox_inches='tight'); plt.close(fig)
    return '<img alt="" style="max-width:100%" src="data:image/png;base64,' + base64.b64encode(b.getvalue()).decode() + '">'

def tabela(df, casas=1):
    df = df.copy()
    for c in [c for c in df.columns if str(c).startswith('p ') or c == 'p' or str(c).startswith('p (')]:
        df[c] = df[c].map(lambda v: '—' if pd.isna(v) else ('< 0,001' if v < 0.001 else f'{v:.3f}'.replace('.', ',')))
    return df.to_html(index=False, float_format=lambda x: f'{x:.{casas}f}', na_rep='—', border=0, classes='t')

def boot_ic(valores_por_part, n=4000):
    v = np.array(valores_por_part, dtype=float); v = v[~np.isnan(v)]
    if len(v) < 2: return (np.nan, np.nan)
    m = [RNG.choice(v, len(v), replace=True).mean() for _ in range(n)]
    return (np.percentile(m, 2.5), np.percentile(m, 97.5))

def gamma(cert, ok):
    # Goodman-Kruskal gamma entre certeza (1-3) e acerto (0/1): mede se a pessoa tem mais certeza quando acerta
    c = np.asarray(cert); o = np.asarray(ok).astype(int); conc = disc = 0
    for i in range(len(c)):
        dc = c[i] - c[i + 1:]; do = o[i] - o[i + 1:]; s = dc * do
        conc += int((s > 0).sum()); disc += int((s < 0).sum())
    return np.nan if conc + disc == 0 else (conc - disc) / (conc + disc)

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('csv'); ap.add_argument('--so-simulados', action='store_true')
    ap.add_argument('--saida', default='analise/relatorio_cut.html'); a = ap.parse_args()
    bruto = ler(a.csv)
    partes = []

    # ---------- 1. qualidade ----------
    q = pd.DataFrame({
        'critério': ['respostas na base', 'participantes', 'resposta em menos de 3 s', 'pré-teste 2 depois da aula',
                     'equipe respondendo como aluno', 'conta simulada ou de teste', 'sem consentimento'],
        'n': [len(bruto), bruto['participante'].nunique(), int(bruto['rapida'].sum()), int(bruto['apos_aula'].sum()),
              int(bruto['equipe'].sum()), int(bruto['simulado'].sum()), int((~bruto['consentiu']).sum())]})
    q['%'] = 100 * q['n'] / max(len(bruto), 1); q.loc[1, '%'] = np.nan
    if a.so_simulados:
        df = bruto[bruto['simulado'] & ~bruto['rapida'] & ~bruto['apos_aula'] & bruto['consentiu']].copy()
        regra = 'Ensaio com os DADOS SIMULADOS (contas @simulado.local): mesmas regras de exclusão, menos a de conta simulada.'
    else:
        df = bruto[bruto['valida']].copy(); regra = 'Respostas válidas: exclui resposta em menos de 3 s, pré-teste 2 depois da aula, equipe, contas simuladas ou de teste e quem não consentiu.'
    partes.append(f'<h2>1. Qualidade dos dados</h2><p>{regra}</p>{tabela(q)}<p>Respostas analisadas: <b>{len(df)}</b> de {df["participante"].nunique()} participantes.</p>')
    if df.empty:
        partes.append('<p><b>Não há respostas válidas para analisar.</b></p>'); escrever(a, partes); return

    # ---------- 2. curva por onda ----------
    pp = df.groupby(['participante', 'onda'])['correta'].mean().mul(100).unstack('onda')
    linhas = []
    for o in range(1, 7):
        v = pp[o].dropna() if o in pp else pd.Series(dtype=float)
        lo, hi = boot_ic(v.values) if len(v) else (np.nan, np.nan)
        linhas.append({'onda': ONDAS[o - 1], 'participantes': len(v), 'acerto médio (%)': v.mean() if len(v) else np.nan,
                       'IC 95% (bootstrap)': f'{lo:.0f} a {hi:.0f}' if not np.isnan(lo) else '—', 'DP': v.std() if len(v) > 1 else np.nan})
    curva = pd.DataFrame(linhas)
    fig, ax = plt.subplots(figsize=(7, 3.6))
    for p in pp.index: ax.plot([CURTO[o - 1] for o in pp.columns], pp.loc[p].values, color='#9aa5b4', lw=1, alpha=.7)
    ax.plot(CURTO, curva['acerto médio (%)'], color=COR, lw=2.6, marker='o', label='média')
    ax.set_ylim(0, 100); ax.set_ylabel('% de acerto'); ax.grid(axis='y', alpha=.3); ax.spines[['top', 'right']].set_visible(False)
    ax.set_title('Acerto por onda (linhas cinza: cada participante)', fontsize=11)
    partes.append('<h2>2. Aprendizagem e retenção</h2>' + fig_b64(fig) + tabela(curva))

    # ganho e retencao por participante
    g = pd.DataFrame(index=pp.index)
    for o, n in [(1, 'pré 1'), (2, 'pré 2'), (3, 'D0'), (6, 'D+90')]: g[n] = pp[o] if o in pp else np.nan
    g['ganho (D0 − pré 1)'] = g['D0'] - g['pré 1']; g['retido no D+90 (D+90 − pré 1)'] = g['D+90'] - g['pré 1']; g['perda (D0 − D+90)'] = g['D0'] - g['D+90']
    partes.append('<h3>Por participante</h3>' + tabela(g.reset_index(), 0))
    # presenca irregular: quem faz mais ondas acerta diferente de quem faz menos?
    feitas = df.groupby('participante').apply(lambda d: pd.Series({'ondas feitas': d[['tema', 'onda']].drop_duplicates().shape[0],
        'acerto médio (%)': 100 * d['correta'].mean()}), include_groups=False).reset_index()
    feitas['ondas feitas'] = feitas['ondas feitas'].astype(int)
    rho = stats.spearmanr(feitas['ondas feitas'], feitas['acerto médio (%)']).statistic if len(feitas) >= 4 and feitas['ondas feitas'].nunique() > 1 else np.nan
    partes.append('<h3>Ondas feitas e acerto</h3><p>Com presença irregular, quem faz mais ondas pode ser diferente de quem faz menos. '
                  f'Correlação de Spearman entre ondas feitas e acerto médio: {"—" if np.isnan(rho) else f"{rho:.2f}"}.</p>' + tabela(feitas, 0))
    testes = []
    for nome, x, y in [('Material antes da aula (pré 2 × pré 1)', 'pré 2', 'pré 1'), ('Aula (D0 × pré 1)', 'D0', 'pré 1'), ('Retenção (D+90 × pré 1)', 'D+90', 'pré 1'), ('Esquecimento (D+90 × D0)', 'D+90', 'D0')]:
        par = g[[x, y]].dropna(); dif = par[x] - par[y]
        if len(par) >= 3 and dif.abs().sum() > 0:
            w = stats.wilcoxon(par[x], par[y]); testes.append({'comparação': nome, 'n': len(par), 'diferença mediana (pontos)': dif.median(), 'p (Wilcoxon)': w.pvalue})
        else: testes.append({'comparação': nome, 'n': len(par), 'diferença mediana (pontos)': dif.median() if len(par) else np.nan, 'p (Wilcoxon)': np.nan})
    partes.append('<h3>Comparações pareadas (exploratórias)</h3>' + tabela(pd.DataFrame(testes), 2) +
                  '<p class="n">Com poucos participantes, o p não sustenta conclusão. A análise confirmatória é o modelo logístico misto do plano.</p>')

    # ---------- 3. calibracao ----------
    c = df.dropna(subset=['certeza']).copy(); c['certeza'] = c['certeza'].astype(int)
    nomes = {1: 'chutei', 2: 'acho que sim', 3: 'tenho certeza'}
    cal = c.groupby('certeza')['correta'].agg(['count', 'mean']).reset_index()
    cal['certeza'] = cal['certeza'].map(nomes); cal['mean'] *= 100; cal.columns = ['certeza marcada', 'respostas', 'acerto (%)']
    gp = c.groupby('participante').apply(lambda d: pd.Series({'respostas': len(d), 'gamma (certeza × acerto)': gamma(d['certeza'].values, d['correta'].values),
        'acerto com "tenho certeza" (%)': 100 * d.loc[d['certeza'] == 3, 'correta'].mean() if (d['certeza'] == 3).any() else np.nan,
        'erros com "tenho certeza"': int(((d['certeza'] == 3) & ~d['correta']).sum())}), include_groups=False).reset_index()
    gp['respostas'] = gp['respostas'].astype(int); gp['erros com "tenho certeza"'] = gp['erros com "tenho certeza"'].astype(int)
    fig, ax = plt.subplots(figsize=(5.5, 3))
    ax.bar(cal['certeza marcada'], cal['acerto (%)'], color=[COR2, '#64748b', COR]); ax.set_ylim(0, 100); ax.set_ylabel('% de acerto')
    for i, v in enumerate(cal['acerto (%)']): ax.text(i, v + 2, f'{v:.0f}%', ha='center', fontsize=9)
    ax.spines[['top', 'right']].set_visible(False); ax.set_title('Acerto por nível de certeza', fontsize=11)
    partes.append('<h2>3. Calibração da certeza</h2><p>Gamma de Goodman-Kruskal: de −1 a 1; quanto maior, mais a certeza acompanha o acerto (0 = sem relação).</p>'
                  + fig_b64(fig) + tabela(cal) + tabela(gp, 2))
    # calibracao ao longo do curso: antes da aula (ondas 1-2) x depois (3-6)
    c['fase'] = np.where(c['onda'] <= 2, 'antes da aula', 'depois da aula')
    gf = c.groupby(['participante', 'fase']).apply(lambda d: gamma(d['certeza'].values, d['correta'].values), include_groups=False).unstack('fase')
    partes.append('<h3>A calibração muda depois da aula?</h3>' + tabela(gf.reset_index(), 2))

    # ---------- 4. hipercorrecao (exploratoria): questao repetida em todas as ondas ----------
    fixa = df[df['perfil_item'].isna() | (df['perfil_item'].astype(str) == '')].sort_values(['participante', 'onda'])
    linhas = []
    for (p, it), d in fixa.groupby(['participante', 'item']):
        d = d.reset_index(drop=True)
        for i in range(len(d) - 1):
            if not d.loc[i, 'correta']:
                linhas.append({'erro com': 'tenho certeza' if d.loc[i, 'certeza'] == 3 else 'chutei / acho que sim', 'acertou na onda seguinte': bool(d.loc[i + 1, 'correta'])})
    if linhas:
        h = pd.DataFrame(linhas).groupby('erro com')['acertou na onda seguinte'].agg(['count', 'mean']).reset_index()
        h['mean'] *= 100; h.columns = ['erro com', 'erros', 'corrigidos na onda seguinte (%)']
        partes.append('<h2>4. Correção de erros (exploratória)</h2><p>Questão que se repete em todas as ondas: depois de errar, quantos acertam na onda seguinte, conforme a certeza do erro. A hipótese da hipercorreção é que o erro com certeza se corrige mais.</p>' + tabela(h))

    # ---------- 5. modelo principal (plano, secao 5) ----------
    G = df['participante'].nunique()
    sec = ['<h2>5. Modelo principal do plano (H1 a H5)</h2>',
           '<p>Regressão logística do acerto em cada questão, ajustada pelo grupo de ano (R1, R2, R3, R+ e graduação) e pela '
           'dificuldade da questão, com erro padrão agrupado por participante (as respostas da mesma pessoa não contam como '
           'independentes). Intervalos e p usam a distribuição t com participantes − 1 graus de liberdade. '
           'H1 a H3 com correção de Holm. A "diferença" é em pontos percentuais de acerto, na média das outras variáveis; '
           'o efeito mínimo que importa, definido pela coordenação, é de 10 pontos.</p>']
    if G < 2:
        sec.append('<p><b>Menos de 2 participantes: o modelo não pode ser ajustado.</b></p>')
    else:
        if G < 20: sec.append(f'<p class="aviso">Só {G} participantes: o erro padrão agrupado fica instável com menos de uns 20. Leia como demonstração do método, não como resultado.</p>')
        conf, todos, G, ok = modelo_cut.modelo_principal(df)
        sec.append('<h3>Hipóteses principais</h3>' + tabela(conf, 2) + ('' if ok else '<p><b>O ajuste não convergiu.</b></p>'))
        sec.append('<details><summary>Todos os termos do modelo</summary>' + tabela(todos, 2) + '</details>')
        ret, _ = modelo_cut.modelo_retencao(df)
        if ret is not None: sec.append('<h3>H4: retenção do D0 ao D+90</h3><p>Razão de chances por 30 dias desde a aula (abaixo de 1 = esquecimento).</p>' + tabela(ret, 2))
        cer, _ = modelo_cut.modelo_certeza(df)
        if cer is not None: sec.append('<h3>H5: certeza e acerto</h3><p>Chance de acertar quando o aluno marca mais certeza, comparada a "chutei", ajustada por onda, ano e dificuldade.</p>' + tabela(cer, 2))
    partes.append(''.join(sec))

    # ---------- 6. questoes ----------
    tot = df.groupby(['participante', 'onda'])['correta'].transform('sum'); n = df.groupby(['participante', 'onda'])['correta'].transform('count')
    df['resto'] = (tot - df['correta']) / (n - 1).clip(lower=1)
    it = df.groupby(['onda', 'item']).apply(lambda d: pd.Series({'respostas': len(d), 'acerto (%)': 100 * d['correta'].mean(),
        'discriminação (r ponto-bisserial)': d['correta'].astype(int).corr(d['resto']) if d['correta'].nunique() > 1 and d['resto'].nunique() > 1 else np.nan,
        'tempo mediano (s)': d['tempo_s'].median()}), include_groups=False).reset_index()
    it['onda'] = it['onda'].map(lambda o: CURTO[o - 1]); it['respostas'] = it['respostas'].astype(int)
    partes.append('<h2>6. Questões</h2><p>Questões com menos de 10 respostas não permitem julgar dificuldade nem discriminação.</p>' + tabela(it, 2))
    escrever(a, partes, simulado=a.so_simulados)

def escrever(a, partes, simulado=False):
    aviso = ('<p class="aviso"><b>DADOS SIMULADOS.</b> Cinco residentes fictícios, gerados para testar o sistema e o plano de análise. '
             'Nenhum número deste relatório descreve residentes reais.</p>') if simulado else ''
    doc = f'''<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Análise CUT</title><style>
body{{font-family:Inter,system-ui,sans-serif;color:#0e1726;max-width:960px;margin:0 auto;padding:16px;line-height:1.5;background:#fff}}
h1{{font-size:24px}} h2{{font-size:19px;margin-top:28px;border-top:1px solid #dde2e9;padding-top:16px}} h3{{font-size:16px}}
table.t{{border-collapse:collapse;margin:8px 0 14px;font-size:14px;display:block;overflow-x:auto}} .t th,.t td{{border-bottom:1px solid #dde2e9;padding:5px 10px;text-align:left}}
.t th{{background:#f3f5f8}} .aviso{{background:#fdecdc;border:1px solid #b45309;padding:10px 12px;border-radius:8px}} .n{{color:#5b6675;font-size:13px}}
</style></head><body><h1>CUT · Análise das ondas de teste</h1>{aviso}{''.join(partes)}
<p class="n">Gerado por analise/analise_cut_v1.0.py. Plano: docs/plano_analise_preregistro.md.</p></body></html>'''
    open(a.saida, 'w', encoding='utf-8').write(doc); print(f'relatorio: {a.saida}')

if __name__ == '__main__':
    main()
