# Gera a versao em texto dos slides da aula (conteudo/T001/slides/project) para ir ao aplicativo e a revisao.
# Cada slide: titulo, texto visivel, fontes do rodape e as notas do apresentador (<aside>).
import json,re,html,os
RAIZ=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
D=os.path.join(RAIZ,'conteudo/T001/slides/project')
def limpo(s): return re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>',' ',s))).strip()
def slides_md():
    deck=json.load(open(f'{D}/deck.json'))
    inicio={v['start']:v['description'] for v in deck['sections'].values()}
    out=["# T001 — Slides da aula","Versão em texto dos 17 slides da aula, com as notas do apresentador. A apresentação visual é projetada na reunião.\n"]
    for n,sid in enumerate(deck['order'],1):
        h=open(f'{D}/slides/{sid}.html').read()
        if sid in inicio: out.append(f"\n## {inicio[sid]}\n")
        nota=re.search(r'<aside>(.*?)</aside>',h,re.S); h2=re.sub(r'<aside>.*?</aside>','',h,flags=re.S)
        rod=re.findall(r'<p style="position:absolute[^"]*">(.*?)</p>',h2,re.S); h2=re.sub(r'<p style="position:absolute[^"]*">.*?</p>','',h2,flags=re.S)
        tit=re.search(r'<h[12][^>]*>(.*?)</h[12]>',h2,re.S)
        t=limpo(tit.group(1)) if tit else sid
        if tit: h2=h2.replace(tit.group(0),'',1)
        partes=[limpo(x) for x in re.findall(r'<(?:h3|p|li|td|th|span)[^>]*>(.*?)</(?:h3|p|li|td|th|span)>',h2,re.S)]
        partes=[x for x in partes if x]
        out.append(f"### Slide {n}. {t}")
        if partes: out.append("\n".join(f"- {x}" for x in partes))
        if rod: out.append(f"\n*{limpo(rod[0])}*")
        if nota: out.append(f"\n> **Nota do apresentador:** {limpo(nota.group(1))}")
        out.append("")
    return "\n".join(out)
if __name__=='__main__': print(slides_md())
