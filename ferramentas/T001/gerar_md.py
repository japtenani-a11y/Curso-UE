import json,re,sys,os
sys.path.insert(0,'/tmp/w21')
exec(open('montar_testes.py').read().split('banco=[]')[0])
import pecas1
b=json.load(open('banco.json'))
OUT='/home/claude/japtenani-a11y/curso-ue/conteudo/T001/v2'; os.makedirs(OUT,exist_ok=True)
AV="> RASCUNHO para revisão por 3 cirurgiões do trauma (tolerância: 5% erro leve / 0 crítico). [A#] = artigo da revisão (camada 4); [D#] = Mattox, Trauma 9ª ed. (camada 2). Casos e dados de pacientes são fictícios.\n\n"
def salvar(tipo,titulo,corpo,ids):
    ids=sorted(set(ids),key=lambda x:(x[0],int(x[1:])))
    o={"tema":"T001","tipo":tipo,"titulo":titulo,"status":"rascunho","versao_padrao":"guia v0.1 (12/11/2026)","gerado_por":"Claude, geração manual fora do executor","corpo":corpo,"afirmacoes":[AF[i] for i in ids]}
    json.dump(o,open(f"{OUT}/T001_{tipo}.json","w"),ensure_ascii=False,indent=1); open(f"{OUT}/T001_{tipo}.md","w").write(corpo)
refs=lambda c: re.findall(r"\b[AD]\d+\b",c)
for k,(tit,c) in pecas1.P.items():
    corpo=AV+c.strip()+"\n"; salvar(k,tit,corpo,[i for i in refs(c) if i in AF])
for t in range(1,7):
    qs=[q for q in b if q['teste']==t]
    prova=[f"# T001 — {NOMES[t]}\n",f"Tempo estimado: {'cerca de 10' if t==1 else '10 a 15'} minutos. Múltipla escolha, 5 alternativas, uma correta. A questão 1 é a questão fixa do tema; as demais partem do {CASOS[t][0].lower()}.\n",f"**{CASOS[t][0]}.** {CASOS[t][1]}\n"]
    gab=[f"# T001 — Gabarito comentado: {NOMES[t]}\n","Liberado ao aluno só depois de ele responder o teste. Para cada questão: resposta, grau de dificuldade, taxa de acerto esperada para o perfil, justificativa de cada alternativa e âncora na fonte.\n"]
    for p in PERFIS:
        prova.append(f"\n## Perfil {p}\n"); gab.append(f"\n## Perfil {p}\n")
        for n,q in enumerate([q for q in qs if q['perfil']==p],1):
            prova.append(f"**{n}.** {q['enunciado']}\n"+"\n".join(f"- {LET[i]}) {a}" for i,a in enumerate(q['alternativas']))+"\n")
            gab.append(f"**{n}. Resposta {q['correta']}** · grau {q['grau_nome']} · taxa de acerto esperada {q['taxa_esperada']} · âncora {', '.join(q['ancoras'])}\n"+"\n".join(f"- {LET[i]}) {'**correta**' if c=='correta' else c}: {re.sub(r'^Correta[:.;]?\s*','',j) if c=='correta' else j}" for i,(j,c) in enumerate(zip(q['justificativas'],q['categorias'])))+"\n")
    ids=[a for q in qs for a in q['ancoras']]
    salvar(f"teste_{t}",NOMES[t],AV+"\n".join(prova),ids)
    salvar(f"gabarito_{t}",f"Gabarito comentado — {NOMES[t]}",AV+"\n".join(gab),ids)
# banco e simulado
json.dump(b,open(f"{OUT}/T001_banco_questoes.json","w"),ensure_ascii=False,indent=1)
mat=["# T001 — Banco de questões e distribuição de dificuldade\n","Questões por perfil e teste com o grau-alvo de cada onda. O grau cresce com a onda e com a experiência do perfil. Dentro de cada teste, as questões variam um grau abaixo e um acima do alvo.\n","| Perfil | Pré-teste inicial | Pré-teste 2 | Pós D0 | Pós D+15 | Pós D+45 | Pós D+90 | Questão fixa |","| --- | --- | --- | --- | --- | --- | --- | --- |"]
for p in PERFIS: mat.append(f"| {p} | "+" | ".join(GRAUS[g-1] for g in ALVO[p])+f" | {GRAUS[GRAU_FIXA[p]-1]} |")
from collections import Counter
mat.append("\n| Grau | Taxa de acerto esperada | Questões no banco |\n| --- | --- | --- |")
cnt=Counter(q['grau_nome'] for q in b if not q['fixa'])
for g,t in zip(GRAUS,TAXA): mat.append(f"| {g} | {t} | {cnt.get(g,0)} |")
mat.append(f"\nTotal: {len({(q['id'],q['perfil']) for q in b if not q['fixa']})} questões de caso e 1 questão fixa (igual para todos os perfis). O simulado opcional de cada aluno é formado pelas questões dos outros perfis, que ele não recebe nos testes.\n\nA questão fixa tem grau diferente por perfil porque o mesmo enunciado é mais fácil para quem tem mais experiência.")
salvar("banco_dificuldade","Banco de questões e distribuição de dificuldade",AV+"\n".join(mat),[a for q in b for a in q['ancoras']])

V1='/home/claude/japtenani-a11y/curso-ue/conteudo/T001'
for tipo,tit,trocas in [('podcast_roteiro','Roteiro de podcast',[('A ideia é que o sangramento externo que mata em minutos passa à frente da via aérea. [DOUTRINA – confirmar na camada 2]','A ideia é que o sangramento externo que mata em minutos passa à frente da via aérea. [D2, D4]')]),
  ('checklist','Checklists',[('- [ ] D — Avaliação neurológica registrada **[DOUTRINA – confirmar na camada 2]**','- [ ] D — Glasgow registrado na chegada e repetido [D16]'),('**Em até 24 h** (prazo: **[DOUTRINA – confirmar na camada 2]**)','**Depois da ressuscitação e das intervenções** [D31]')]),
  ('mapa','Mapa conceitual',[]),('flashcard','Flashcards',[])]:
    c=open(f'{V1}/T001_{tipo}.md').read()
    c=AV+c.split('\n\n',1)[1]
    for x,y in trocas:
        assert x in c,(tipo,x); c=c.replace(x,y)
    assert 'DOUTRINA – confirmar na camada 2' not in c,tipo
    salvar(tipo,tit,c,[i for i in refs(c) if i in AF])
print(len(os.listdir(OUT)),'arquivos')
