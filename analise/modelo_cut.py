# modelo_cut.py
# Modelo principal do plano de analise do CUT, em Python puro (numpy e scipy):
# regressao logistica do acerto em cada questao, ajustada pelo grupo de ano e pela dificuldade da questao, com erro
# padrao robusto agrupado por participante (equivale a uma GEE com correlacao de trabalho independente). Assim as
# varias respostas da mesma pessoa nao sao tratadas como independentes.
# Contrastes do plano: D0 x pre-teste 1 (H1), D+90 x pre-teste 1 (H2), pre-teste 2 x pre-teste 1 (H3), com Holm.
import numpy as np
import pandas as pd
from scipy import stats

def grupo_ano(a):
    a = str(a)
    if a in ('R1', 'R2', 'R3'): return a
    if a == 'graduacao': return 'graduação'
    return 'R+'   # R4 a R6, egressos, preceptores

def matriz(df, ondas=True, dias=False, certeza=False):
    """Monta X (com intercepto) e os nomes das colunas. Referencias: pre-teste 1, R1, certeza 'chutei'."""
    cols = {'intercepto': np.ones(len(df))}
    if ondas:
        for o, n in [(2, 'pré-teste 2'), (3, 'D0'), (4, 'D+15'), (5, 'D+45'), (6, 'D+90')]:
            if (df['onda'] == o).any(): cols[n] = (df['onda'] == o).astype(float).values
    if dias:
        cols['por 30 dias desde a aula'] = (df['dias_da_aula'].astype(float) / 30).values
    g = df['ano'].map(grupo_ano)
    for n in ['R2', 'R3', 'R+', 'graduação']:
        if (g == n).any() and (g != n).any(): cols[f'ano {n} (× R1)'] = (g == n).astype(float).values
    d = df['dificuldade'].astype(float)
    if d.notna().all() and d.nunique() > 1: cols['dificuldade (por grau)'] = (d - d.mean()).values
    if certeza:
        c = df['certeza'].astype(float)
        cols['acho que sim (× chutei)'] = (c == 2).astype(float).values
        cols['tenho certeza (× chutei)'] = (c == 3).astype(float).values
    X = np.column_stack(list(cols.values()))
    return X, list(cols.keys())

def ajustar(X, y, max_iter=100, tol=1e-10):
    """Regressao logistica por IRLS (Newton-Raphson). Devolve beta e se convergiu."""
    beta = np.zeros(X.shape[1])
    for _ in range(max_iter):
        eta = np.clip(X @ beta, -30, 30); p = 1 / (1 + np.exp(-eta)); w = p * (1 - p)
        H = X.T @ (X * w[:, None]); g = X.T @ (y - p)
        passo = np.linalg.solve(H + 1e-9 * np.eye(len(beta)), g)
        beta += passo
        if np.max(np.abs(passo)) < tol: return beta, True
    return beta, False

def robusta(X, y, beta, grupos):
    """Covariancia sanduiche agrupada por participante, com correcao G/(G-1)."""
    p = 1 / (1 + np.exp(-np.clip(X @ beta, -30, 30))); w = p * (1 - p)
    Hinv = np.linalg.inv(X.T @ (X * w[:, None]))
    meio = np.zeros((X.shape[1], X.shape[1])); G = 0
    for gid in pd.unique(grupos):
        m = grupos == gid; s = X[m].T @ (y[m] - p[m]); meio += np.outer(s, s); G += 1
    return Hinv @ meio @ Hinv * (G / max(G - 1, 1)), G

def holm(pvals):
    p = np.asarray(pvals, float); ordem = np.argsort(p); m = len(p); adj = np.empty(m); atual = 0
    for k, i in enumerate(ordem):
        atual = max(atual, min(1, (m - k) * p[i])); adj[i] = atual
    return adj

def tabela_or(beta, cov, nomes, G, so=None):
    se = np.sqrt(np.diag(cov)); z = beta / se
    gl = max(G - 1, 1)   # t com G-1 graus de liberdade: mais conservador com poucos participantes
    p = 2 * stats.t.sf(np.abs(z), gl); q = stats.t.ppf(0.975, gl)
    linhas = []
    for i, n in enumerate(nomes):
        if n == 'intercepto' or (so and n not in so): continue
        linhas.append({'termo': n, 'razão de chances': np.exp(beta[i]), 'IC 95%': f'{np.exp(beta[i] - q * se[i]):.2f} a {np.exp(beta[i] + q * se[i]):.2f}', 'p': p[i]})
    return pd.DataFrame(linhas)

def modelo_principal(df):
    """H1-H3: acerto ~ onda + grupo de ano + dificuldade, erro padrao agrupado por participante."""
    X, nomes = matriz(df); y = df['correta'].astype(float).values
    beta, ok = ajustar(X, y); cov, G = robusta(X, y, beta, df['participante'].values)
    tab = tabela_or(beta, cov, nomes, G)
    hip = {'D0': 'H1: D0 × pré-teste 1', 'D+90': 'H2: D+90 × pré-teste 1', 'pré-teste 2': 'H3: pré-teste 2 × pré-teste 1'}
    conf = tab[tab['termo'].isin(hip)].copy()
    conf['hipótese'] = conf['termo'].map(hip); conf['p (Holm)'] = holm(conf['p'].values) if len(conf) else []
    # diferenca em pontos percentuais, na media das covariaveis (escala que o curso usa: 10 pontos = efeito minimo)
    pp = {}
    Xm = X.mean(axis=0)
    for o in ['pré-teste 2', 'D0', 'D+90']:
        if o not in nomes: continue
        a = Xm.copy(); b = Xm.copy()
        for n in ['pré-teste 2', 'D0', 'D+15', 'D+45', 'D+90']:
            if n in nomes: a[nomes.index(n)] = 0; b[nomes.index(n)] = 0
        b[nomes.index(o)] = 1
        pp[o] = 100 * (1 / (1 + np.exp(-(b @ beta))) - 1 / (1 + np.exp(-(a @ beta))))
    conf['diferença (pontos %)'] = conf['termo'].map(pp)
    return conf[['hipótese', 'razão de chances', 'IC 95%', 'diferença (pontos %)', 'p', 'p (Holm)']], tab, G, ok

def modelo_retencao(df):
    """H4: nas ondas D0 a D+90, acerto ~ dias desde a aula + grupo de ano + dificuldade."""
    d = df[df['onda'] >= 3].dropna(subset=['dias_da_aula'])
    if d['participante'].nunique() < 2 or len(d) < 20: return None, 0
    X, nomes = matriz(d, ondas=False, dias=True); y = d['correta'].astype(float).values
    beta, _ = ajustar(X, y); cov, G = robusta(X, y, beta, d['participante'].values)
    return tabela_or(beta, cov, nomes, G), G

def modelo_certeza(df):
    """H5: o acerto e maior quando a certeza marcada e maior? (ajustado por onda, ano e dificuldade)"""
    d = df.dropna(subset=['certeza'])
    if d['participante'].nunique() < 2 or d['certeza'].nunique() < 2: return None, 0
    X, nomes = matriz(d, certeza=True); y = d['correta'].astype(float).values
    beta, _ = ajustar(X, y); cov, G = robusta(X, y, beta, d['participante'].values)
    return tabela_or(beta, cov, nomes, G, so=['acho que sim (× chutei)', 'tenho certeza (× chutei)']), G
