import json,re,sys,hashlib,random
sys.path.insert(0,'/tmp/w21')
import testes_a,testes_b,testes_c,testes_d,doutrina
S=json.load(open('/home/claude/japtenani-a11y/curso-ue/conteudo/T001/T001_sintese_evidencia.json'))
AF={a['id']:a for a in S['afirmacoes']}
for i,f,t,tr in doutrina.D: AF[i]={'id':i,'texto':t,'fonte_arquivo':f,'trecho_literal':tr}
CASOS={**testes_a.CASOS,**testes_b.CASOS,**testes_c.CASOS}
TESTES={**testes_a.TESTES,**testes_b.TESTES,**testes_c.TESTES}
import testes_d
for (t,p,i),q in testes_d.OVERRIDE.items():
    TESTES[t][p][i]=q
PERFIS=['Graduação','R1','R2','R3','R+']
NOMES={1:'Pré-teste inicial',2:'Pré-teste após o conhecimento básico',3:'Pós-teste D0',4:'Pós-teste D+15',5:'Pós-teste D+45',6:'Pós-teste D+90'}
GRAUS=['Muito fácil','Fácil','Média','Difícil','Muito difícil','Extrema']
TAXA=['acima de 90%','75% a 90%','50% a 75%','30% a 50%','15% a 30%','abaixo de 15%']
ALVO={'Graduação':[1,2,2,3,3,3],'R1':[2,3,3,3,4,4],'R2':[3,3,4,4,4,5],'R3':[3,4,4,5,5,5],'R+':[4,4,5,5,6,6]}
GRAU_FIXA={'Graduação':3,'R1':2,'R2':1,'R3':1,'R+':1}
CAT={'CO':'erro conceitual','CD':'erro de conduta','IN':'erro de indicação','TE':'erro técnico'}
LET='ABCDE'
norm=lambda x:x.replace('.',',')
erros=[]
def padrao(g,n):
    p=[g-1,g,g,g+1] if n==4 else [g-1,g-1,g,g,g+1,g+1]
    return [min(6,max(1,x)) for x in p]
def embaralhar(q,chave):
    en,alts,c,js,cats,anc=q
    idx=list(range(5)); random.Random(int(hashlib.md5(chave.encode()).hexdigest(),16)).shuffle(idx)
    return en,[alts[i] for i in idx],idx.index(c),[js[i] for i in idx],[cats[i] for i in idx],anc
def checar(q,nome):
    en,alts,c,js,cats,anc=q
    if len(alts)!=5 or len(js)!=5 or len(cats)!=5: erros.append((nome,'tamanho'))
    if sorted(cats)!=sorted(['OK','CO','CD','IN','TE']) or cats[c]!='OK': erros.append((nome,'categorias',cats,c))
    for a in anc:
        if a not in AF: erros.append((nome,'ancora',a))
    pool=norm(' '.join(AF[a]['texto']+' '+AF[a]['trecho_literal'] for a in anc if a in AF))
    txt=re.sub(r"caso \d|Caso \d|\b[AD]\d+\b","",alts[c]+' '+js[c])
    nums=[n for n in set(re.findall(r"\d+(?:[.,]\d+)?",txt)) if norm(n) not in pool]
    if nums: erros.append((nome,'numero',nums))
banco=[]
md_t={};md_g={}
for t in range(1,7):
    cas=CASOS[t]
    for p in PERFIS:
        qs=TESTES[t][p]; n=len(qs)
        if n!=(4 if t==1 else 6): erros.append((t,p,'n',n))
        graus=padrao(ALVO[p][t-1],n)
        lista=[('FIXA',testes_a.FIXA,GRAU_FIXA[p])]+[(f'T{t}-{p}-{i+1}',q,graus[i]) for i,q in enumerate(qs)]
        for qid,q,g in lista:
            checar(q,qid)
            e=embaralhar(q,qid+p+str(t))
            banco.append({'teste':t,'nome_teste':NOMES[t],'perfil':p,'id':qid if qid!='FIXA' else 'FIXA','fixa':qid=='FIXA','caso':None if qid=='FIXA' else t,
              'grau':g,'grau_nome':GRAUS[g-1],'taxa_esperada':TAXA[g-1],'enunciado':e[0],'alternativas':e[1],'correta':LET[e[2]],
              'justificativas':e[3],'categorias':[('correta' if x=='OK' else CAT[x]) for x in e[4]],'ancoras':e[5]})
json.dump(banco,open('/tmp/w21/banco.json','w'),ensure_ascii=False,indent=1)
from collections import Counter
print('questoes no banco',len(banco),'| unicas',len({(b['id'],b['perfil']) for b in banco if not b['fixa']})+1)
print('gabarito por letra',Counter(b['correta'] for b in banco))
print('graus',Counter(b['grau_nome'] for b in banco if not b['fixa']))
print('ERROS',len(erros)); [print(x) for x in erros[:40]]
