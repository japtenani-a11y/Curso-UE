# Gera o deck visual da aula do T001 (versao de 16/11/2026) a partir de conteudo/T001/pecas/slides.md:
# conteudo/T001/slides/project_v3 (deck.json + slides/*.html). Cada slide: titulo, itens, rodape com as fontes e as notas
# (<aside>). Quatro slides ganham um esquema simples (pulsos, torniquete, cinta pelvica, membrana cricotireoidea).
# USO: python3 ferramentas/T001/gerar_deck_v3.py   (depois: node ferramentas/deck_para_imagens.cjs ... para as imagens)
import html, json, os, re
RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MD = os.path.join(RAIZ, 'conteudo/T001/pecas/slides.md')
OUT = os.path.join(RAIZ, 'conteudo/T001/slides/project_v3')

AZUL, CREME, TINTA, AMBAR, CINZA, LINHA, VERDE, VERM = '#14213D', '#FBFBF8', '#14213D', '#F2B65A', '#5B6675', '#DDE2E9', '#2F7D4F', '#B42318'
SERIF = "'Source Serif 4', Georgia, serif"; SANS = "'IBM Plex Sans', Arial, sans-serif"
e = html.escape

def ler():
    s = open(MD, encoding='utf-8').read()
    slides, secao = [], ''
    for bloco in re.split(r'\n(?=### Slide |## )', s):
        if bloco.startswith('## '): secao = bloco[3:].split('\n')[0].strip(); continue
        m = re.match(r'### Slide (\d+)\. (.+)', bloco)
        if not m: continue
        itens = re.findall(r'^- (.+)$', bloco, re.M)
        rod = re.search(r'^\*(T001 ·.+)\*$', bloco, re.M)
        nota = re.search(r'> \*\*Nota do apresentador:\*\* (.+)', bloco)
        fala = re.search(r'> \*\*Fala:\*\* (.+)', bloco)
        slides.append({'n': int(m.group(1)), 'titulo': m.group(2).strip(), 'itens': itens, 'secao': secao,
                       'rodape': rod.group(1) if rod else '', 'nota': nota.group(1) if nota else '', 'fala': fala.group(1) if fala else ''})
    return slides

# ---------------- esquemas (SVG, sem texto pequeno demais) ----------------
def svg_pulsos():
    faixas = [('Carotídeo', 60, 70), ('Femoral', 70, 80), ('Radial', 90, 100), ('Pedioso', 100, 110)]
    x0, larg = 160, 470; esc = lambda v: x0 + (v - 40) / 80 * larg
    out = [f'<svg viewBox="0 0 760 420" width="760" height="420" xmlns="http://www.w3.org/2000/svg" font-family="IBM Plex Sans, Arial">']
    for i, (nome, a, b) in enumerate(faixas):
        y = 40 + i * 88
        out.append(f'<text x="0" y="{y + 34}" font-size="28" fill="{TINTA}">{nome}</text>')
        out.append(f'<rect x="{x0}" y="{y + 8}" width="{larg}" height="36" rx="8" fill="#EEF1F5"/>')
        fim = esc(b) if nome != 'Pedioso' else esc(120)
        out.append(f'<rect x="{esc(a)}" y="{y + 8}" width="{fim - esc(a)}" height="36" rx="8" fill="#1F4E79"/>')
        rot = f'{a}–{b}' if nome != 'Pedioso' else '> 100'
        out.append(f'<text x="{fim + 12}" y="{y + 36}" font-size="26" fill="{TINTA}">{rot}</text>')
    for v in (40, 60, 80, 100, 120):
        out.append(f'<text x="{esc(v) - 18}" y="410" font-size="22" fill="{CINZA}">{v}</text>')
    out.append(f'<text x="{x0}" y="380" font-size="22" fill="{CINZA}">PAS aproximada (mmHg) · dado pouco estudado</text></svg>')
    return ''.join(out)

def svg_torniquete():
    o = [f'<svg viewBox="0 0 760 420" width="760" height="420" xmlns="http://www.w3.org/2000/svg" font-family="IBM Plex Sans, Arial">']
    o.append(f'<rect x="40" y="170" width="680" height="90" rx="45" fill="#E8D9C8" stroke="#B9A48C" stroke-width="3"/>')
    o.append(f'<circle cx="360" cy="215" r="58" fill="none" stroke="{CINZA}" stroke-width="4" stroke-dasharray="10 8"/>')
    o.append(f'<text x="300" y="150" font-size="26" fill="{CINZA}">articulação</text>')
    o.append(f'<ellipse cx="600" cy="215" rx="38" ry="26" fill="{VERM}"/>')
    o.append(f'<text x="560" y="310" font-size="26" fill="{VERM}">lesão</text>')
    o.append(f'<rect x="488" y="160" width="34" height="110" rx="6" fill="{VERDE}"/>')
    o.append(f'<text x="420" y="340" font-size="26" fill="{VERDE}">torniquete: acima da lesão,</text>')
    o.append(f'<text x="420" y="372" font-size="26" fill="{VERDE}">o mais perto dela</text>')
    o.append(f'<line x1="330" y1="190" x2="390" y2="240" stroke="{VERM}" stroke-width="6"/><line x1="390" y1="190" x2="330" y2="240" stroke="{VERM}" stroke-width="6"/>')
    o.append(f'<text x="40" y="60" font-size="24" fill="{CINZA}">proximal</text><text x="620" y="60" font-size="24" fill="{CINZA}">distal</text>')
    o.append(f'<line x1="150" y1="52" x2="600" y2="52" stroke="{CINZA}" stroke-width="2" marker-end="url(#s)"/>')
    o.append(f'<defs><marker id="s" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="{CINZA}"/></marker></defs>')
    o.append('</svg>'); return ''.join(o)

def svg_cinta():
    osso, borda = '#F1ECE3', '#9C8C76'
    o = [f'<svg viewBox="0 0 760 500" width="760" height="500" xmlns="http://www.w3.org/2000/svg" font-family="IBM Plex Sans, Arial">']
    def lado(sx):  # hemipelve e femur proximal; sx=1 lado esquerdo da imagem, -1 espelho em x=380
        m = lambda x: x if sx == 1 else 760 - x
        P = lambda pts: ' '.join(f'{m(x)},{y}' for x, y in pts)
        o.append(f'<path d="M{m(335)},118 C{m(270)},70 {m(165)},70 {m(132)},118 C{m(112)},160 {m(140)},222 {m(200)},262 L{m(240)},296 L{m(298)},250 L{m(335)},200 Z" fill="{osso}" stroke="{borda}" stroke-width="3"/>')
        o.append(f'<path d="M{m(250)},300 C{m(258)},352 {m(305)},382 {m(372)},374 L{m(372)},332 C{m(322)},332 {m(292)},312 {m(282)},292 Z" fill="{osso}" stroke="{borda}" stroke-width="3"/>')
        o.append(f'<ellipse cx="{m(312)}" cy="338" rx="22" ry="17" fill="#FFFFFF" stroke="{borda}" stroke-width="2"/>')
        o.append(f'<polygon points="{P([(222, 282), (246, 300), (182, 344), (160, 322)])}" fill="{osso}" stroke="{borda}" stroke-width="3"/>')
        o.append(f'<circle cx="{m(236)}" cy="292" r="26" fill="{osso}" stroke="{borda}" stroke-width="3"/>')
        o.append(f'<ellipse cx="{m(160)}" cy="332" rx="24" ry="20" fill="{osso}" stroke="{borda}" stroke-width="3"/>')
        o.append(f'<polygon points="{P([(150, 340), (184, 340), (196, 440), (166, 440)])}" fill="{osso}" stroke="{borda}" stroke-width="3"/>')
    lado(1); lado(-1)
    o.append(f'<path d="M335,110 L425,110 L410,240 L380,266 L350,240 Z" fill="#E3D9CA" stroke="{borda}" stroke-width="2"/>')
    o.append(f'<rect x="372" y="330" width="16" height="46" rx="4" fill="#E3D9CA" stroke="{borda}" stroke-width="2"/>')
    o.append(f'<rect x="100" y="84" width="560" height="22" rx="8" fill="{VERM}" opacity="0.8"/>')
    o.append(f'<text x="100" y="60" font-size="26" fill="{VERM}">nas cristas ilíacas: não</text>')
    o.append(f'<rect x="108" y="318" width="544" height="28" rx="8" fill="{VERDE}" opacity="0.8"/>')
    o.append(f'<text x="250" y="482" font-size="26" fill="{VERDE}">nos trocânteres maiores: sim</text>')
    o.append(f'<text x="560" y="40" font-size="20" fill="{CINZA}">esquema frontal</text>')
    o.append('</svg>'); return ''.join(o)

def svg_crico():
    o = [f'<svg viewBox="0 0 760 460" width="760" height="460" xmlns="http://www.w3.org/2000/svg" font-family="IBM Plex Sans, Arial">']
    o.append(f'<path d="M260 40 L500 40 L460 170 L300 170 Z" fill="#E6EDF5" stroke="#1F4E79" stroke-width="3"/>')
    o.append(f'<text x="520" y="110" font-size="26" fill="{TINTA}">cartilagem tireoide</text>')
    o.append(f'<rect x="305" y="178" width="150" height="34" fill="{AMBAR}"/>')
    o.append(f'<text x="470" y="204" font-size="26" fill="#8A5A00">membrana cricotireóidea</text>')
    o.append(f'<rect x="300" y="218" width="160" height="44" rx="10" fill="#E6EDF5" stroke="#1F4E79" stroke-width="3"/>')
    o.append(f'<text x="475" y="250" font-size="26" fill="{TINTA}">cartilagem cricoide</text>')
    for i in range(4):
        o.append(f'<rect x="315" y="{276 + i * 38}" width="130" height="26" rx="10" fill="#F4F6F9" stroke="#8FA3BA" stroke-width="2"/>')
    o.append(f'<text x="475" y="330" font-size="24" fill="{CINZA}">traqueia</text>')
    o.append(f'<line x1="200" y1="140" x2="200" y2="250" stroke="{VERM}" stroke-width="6"/>')
    o.append(f'<text x="40" y="200" font-size="24" fill="{VERM}">pele: vertical</text>')
    o.append(f'<line x1="320" y1="195" x2="440" y2="195" stroke="{VERM}" stroke-width="5" stroke-dasharray="12 6"/>')
    o.append(f'<text x="40" y="430" font-size="22" fill="{CINZA}">vista anterior, esquema fora de escala</text>')
    o.append('</svg>'); return ''.join(o)

FIG = {3: svg_pulsos, 6: svg_torniquete, 8: svg_cinta, 12: svg_crico}

def rodape(txt, cor):
    return f'<p style="position:absolute;left:128px;bottom:64px;width:1664px;font-size:24px;color:{cor}">{e(txt)}</p>'

def secao(s, cor=AMBAR):
    return f'<p style="font-size:26px;font-weight:600;color:{cor};letter-spacing:2px;text-transform:uppercase">{e(s)}</p>'

def html_slide(s):
    sid = f's{s["n"]:02d}'
    aside = f'<aside>{e(s["nota"])}</aside>'
    if s['n'] == 1:
        return (f'<section id="{sid}" data-transition="fade" style="background:{AZUL};color:{CREME};font-family:{SANS};padding:128px 128px 160px;'
                f'display:flex;flex-direction:column;justify-content:space-between;gap:48px">'
                f'<p style="font-size:32px;font-weight:600;color:{AMBAR};letter-spacing:2px;text-transform:uppercase">{e(s["itens"][0])}</p>'
                f'<div style="display:flex;flex-direction:column;gap:32px"><h1 style="font-family:{SERIF};font-size:120px;font-weight:600;line-height:1.05">{e(s["titulo"])}</h1>'
                + ''.join(f'<p style="font-size:44px;line-height:1.3;color:#C9D6E8">{e(x)}</p>' for x in s['itens'][1:]) +
                f'</div>{rodape("Rascunho para revisão pelos preceptores · conteúdo ainda não aprovado", "#C9D6E8")}{aside}</section>')
    escuro = s['n'] in (4, 14)
    fundo, cor, sub = (AZUL, CREME, '#C9D6E8') if escuro else (CREME, TINTA, CINZA)
    fig = FIG.get(s['n'])
    itens = ''.join(
        f'<li style="font-size:{36 if fig else 40}px;line-height:1.3;padding-left:8px">{e(x)}</li>' for x in s['itens'])
    lista = f'<ul style="display:flex;flex-direction:column;gap:22px;padding-left:44px;list-style:square">{itens}</ul>'
    corpo = (f'<div style="display:flex;gap:56px;align-items:center"><div style="flex:1">{lista}</div>'
             f'<div style="flex:0 0 760px;background:#FFFFFF;border:1px solid {LINHA};border-radius:16px;padding:16px">{fig()}</div></div>') if fig else lista
    return (f'<section id="{sid}" data-transition="fade" style="background:{fundo};color:{cor};font-family:{SANS};padding:112px 128px 160px;'
            f'display:flex;flex-direction:column;gap:44px">{secao(s["secao"].split(":")[0] if s["secao"] else "", AMBAR if escuro else "#1F4E79")}'
            f'<h2 style="font-family:{SERIF};font-size:68px;font-weight:600;line-height:1.1">{e(s["titulo"])}</h2>{corpo}'
            f'{rodape(s["rodape"], sub)}{aside}</section>')

def main():
    slides = ler()
    assert [s['n'] for s in slides] == list(range(1, len(slides) + 1))
    os.makedirs(os.path.join(OUT, 'slides'), exist_ok=True)
    ordem, secoes, vista = [], {}, set()
    for s in slides:
        sid = f's{s["n"]:02d}'; ordem.append(sid)
        open(os.path.join(OUT, 'slides', sid + '.html'), 'w', encoding='utf-8').write(html_slide(s) + '\n')
        if s['secao'] not in vista:
            vista.add(s['secao']); secoes[f'sec{len(secoes) + 1}'] = {'description': s['secao'], 'start': sid}
    deck = {'v': 4, 'lists': 'css', 'title': 'T001 — Da teoria à mesa: caso, técnica e anatomia (aula, 16/11/2026)', 'order': ordem,
            'cover': ordem[0], 'sections': secoes,
            'faces': {'source-serif-4': {'family': 'Source Serif 4', 'href': 'https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400..700&display=swap'},
                      'ibm-plex-sans': {'family': 'IBM Plex Sans', 'href': 'https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&display=swap'}},
            'designSystems': []}
    json.dump(deck, open(os.path.join(OUT, 'deck.json'), 'w', encoding='utf-8'), ensure_ascii=False)
    print(len(slides), 'slides em', OUT)

if __name__ == '__main__': main()
