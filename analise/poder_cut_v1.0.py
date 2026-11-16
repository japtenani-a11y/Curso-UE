# poder_cut_v1.0.py: poder por simulacao do plano de analise do CUT (secao 6). USO: python3 analise/poder_cut_v1.0.py
# Poder por simulacao (aproximacao conservadora do modelo misto): media por aluno da diferenca entre ondas, teste t pareado.
import numpy as np
from scipy import stats
rng = np.random.default_rng(7)
def logit(p): return np.log(p/(1-p))
def sim(n_alunos, n_temas, efeito_pp, base=0.55, itens=7, p_onda=0.6, sd_aluno=0.6, sd_tema=0.4, sd_item=0.5, reps=1000):
    ok = 0
    d_logit = logit(base + efeito_pp/100) - logit(base)
    for _ in range(reps):
        a = rng.normal(0, sd_aluno, n_alunos); t = rng.normal(0, sd_tema, n_temas)
        difs = []
        for i in range(n_alunos):
            ds = []
            for j in range(n_temas):
                if rng.random() > p_onda or rng.random() > p_onda: continue   # faltou a uma das duas ondas
                b = rng.normal(0, sd_item, (2, itens))
                p0 = 1/(1+np.exp(-(logit(base) + a[i] + t[j] + b[0]))); p1 = 1/(1+np.exp(-(logit(base) + d_logit + a[i] + t[j] + b[1])))
                ds.append((rng.random(itens) < p1).mean() - (rng.random(itens) < p0).mean())
            if ds: difs.append(np.mean(ds))
        if len(difs) >= 3 and stats.ttest_1samp(difs, 0).pvalue < 0.05/3: ok += 1
    return ok / reps
for temas in (1, 3, 10, 39):
    for ef in (10, 5):
        print(f'temas={temas:2d} efeito={ef:2d} pp  poder={sim(40, temas, ef, reps=400):.2f}')
