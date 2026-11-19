# Gera o PDF da diretriz clinica de um tema (peca "protocolo") com a identidade do CUT (Design System "CUT").
# Usa so o texto da peca: nada e acrescentado alem da capa (tema, versao, data) e do cabecalho/rodape.
# USO: python3 ferramentas/diretriz_pdf.py conteudo/T001/pecas/protocolo.md [saida.pdf]
# Precisa de: python3-markdown, Playwright com Chromium (ja no WSL do curso) e, para o fluxograma, mmdc (Mermaid CLI);
# sem mmdc, o fluxograma sai como texto.
import sys, os, re, html, subprocess, tempfile, base64, datetime
import markdown

AQUI = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
arq = sys.argv[1]
saida = sys.argv[2] if len(sys.argv) > 2 else re.sub(r'\.md$', '.pdf', arq)
md = open(arq, encoding='utf-8').read()

# ---- partes fixas ----
# o titulo e a primeira linha que comeca com "# " (a faixa RASCUNHO pode vir antes dela)
h = re.search(r'(?m)^#\s+(.+)$', md)
linha_titulo = h.group(1).strip() if h else md.strip().split('\n', 1)[0].lstrip('# ')
m = re.match(r'(T\d{3})\s*[—-]\s*(.+)', linha_titulo)
codigo, titulo = (m.group(1), m.group(2).strip()) if m else ('', linha_titulo)
titulo = re.sub(r'^(Proposta de )?([Dd]iretriz clínica|[Gg]uia de atendimento):\s*', '', titulo)
titulo = titulo[:1].upper() + titulo[1:]
versao = re.search(r'versão ([\d.]+), (\d{2}/\d{2}/\d{4})', md)
versao_txt = f'Versão {versao.group(1)} · {versao.group(2)}' if versao else datetime.date.today().strftime('%d/%m/%Y')
rascunho = bool(re.search(r'(?im)^>\s*RASCUNHO', md))
corpo = (md[:h.start()] + md[h.end():]) if h else (md.split('\n', 1)[1] if '\n' in md else '')
corpo = re.sub(r'(?m)^>\s*RASCUNHO[^\n]*\n', '', corpo)
# A diretriz do curso e sempre PROPOSTA (decisao de 19/11/2026): a faixa vai para a capa e o rodape, nao some.
corpo = re.sub(r'(?m)^>\s*PROPOSTA[^\n]*\n', '', corpo)

# ---- fluxograma: mermaid -> SVG ----
def mermaid_svg(cod):
    try:
        d = tempfile.mkdtemp()
        open(f'{d}/f.mmd', 'w').write(cod)
        cfg = f'{d}/c.json'
        open(cfg, 'w').write('{"theme":"neutral","themeVariables":{"fontFamily":"Inter, Helvetica Neue, Arial, sans-serif","primaryColor":"#F4F5F7","primaryBorderColor":"#0E1726","lineColor":"#0E1726","fontSize":"14px"}}')
        subprocess.run(['mmdc', '-i', f'{d}/f.mmd', '-o', f'{d}/f.svg', '-c', cfg, '-b', 'white'], check=True, capture_output=True, timeout=120)
        return open(f'{d}/f.svg', encoding='utf-8').read()
    except Exception:
        return None
def troca_mermaid(mo):
    svg = mermaid_svg(mo.group(1))
    if svg: svg = re.sub(r'style="max-width:[^"]*"', '', svg, count=1)
    return ('\n<div class="fluxo">' + svg + '</div>\n') if svg else ('\n<pre class="fluxo-txt">' + html.escape(mo.group(1)) + '</pre>\n')
corpo = re.sub(r'```mermaid\n(.*?)```', troca_mermaid, corpo, flags=re.S)

# ---- recomendacoes viram caixas (componente CaixaEvidencia, variante CONDUTA para as fortes) ----
def caixa(mo):
    bloco = mo.group(0).strip()
    linhas = bloco.split('\n')
    cab = re.match(r'\*\*Recomendação (\d+)\.\*\*\s*(.*)', linhas[0])
    n, texto = cab.group(1), cab.group(2)
    campos = {}
    for l in linhas[1:]:
        k = re.match(r'(Força|Origem|Justificativa|Na prática|Divergência):\s*(.*)', l)
        if k: campos[k.group(1)] = k.group(2)
        elif campos: last = list(campos)[-1]; campos[last] += ' ' + l
    forca = campos.get('Força', '')
    forte = forca.lower().startswith('forte')
    md_in = lambda t: markdown.markdown(t).replace('<p>', '').replace('</p>', '')
    h = [f'<div class="caixa{" conduta" if forte else ""}"><div class="rotulo">{"CONDUTA · " if forte else ""}RECOMENDAÇÃO {n}</div>',
         f'<p class="rec">{md_in(texto)}</p>', f'<p class="grau">Força: {html.escape(forca).replace(" | ", " · ")}</p>']
    for k in ('Origem', 'Justificativa', 'Na prática', 'Divergência'):
        if k in campos: h.append(f'<p class="campo"><span>{k}</span> {md_in(campos[k])}</p>')
    h.append('</div>')
    return '\n' + ''.join(h) + '\n'
corpo = re.sub(r'(?ms)^\*\*Recomendação \d+\.\*\*.*?(?=\n\n|\Z)', caixa, corpo)

# ---- lista logo depois de um paragrafo: o markdown exige linha em branco ----
corpo = re.sub(r'(?m)^(?!\s*(?:- |\* |\d+\. |\||<|>|#))(.+)\n(- )', r'\1\n\n\2', corpo)

# ---- secoes numeradas ----
n_sec = [0]
def secao(mo):
    n_sec[0] += 1
    return f'\n<h2><span class="num">{n_sec[0]:02d}</span> {html.escape(mo.group(1))}</h2>\n'
corpo = re.sub(r'(?m)^## (.+)$', secao, corpo)
html_corpo = markdown.markdown(corpo, extensions=['tables'])
html_corpo = html_corpo.replace('[ ]', '<span class="cx"></span>')

def logo():
    for p in ('modelos/marca_cut_v1.0/public/cut_horizontal_claro.svg', 'programa-cut/pwa/public/cut_horizontal_claro.svg'):
        f = os.path.join(AQUI, p)
        if os.path.exists(f): return 'data:image/svg+xml;base64,' + base64.b64encode(open(f, 'rb').read()).decode()
    return None
lg = logo()
marca = f'<img class="logo" src="{lg}" alt="CUT">' if lg else '<div class="logo-txt">CUT</div>'

doc = f'''<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>{html.escape(codigo)} · Proposta de guia de atendimento</title>
<style>
:root {{ --brand:#0E1726; --incision:#D7263D; --text:#0E1726; --text-muted:#5B6473; --surface:#FFFFFF; --surface-sunken:#F4F5F7;
  --surface-raised:#FFFFFF; --line:#DDE1E7; --line-strong:#7C8594; --correct:#174A85;
  --sans: Inter, "Helvetica Neue", Arial, sans-serif; --space-2:8px; --space-3:12px; --space-4:16px; --space-5:24px; --space-6:32px; --space-8:64px;
  --radius-sm:6px; --radius-lg:16px; }}
@page {{ size: A4; margin: 22mm 18mm 20mm 18mm; }}
* {{ box-sizing: border-box; -webkit-print-color-adjust: exact; print-color-adjust: exact; }}
body {{ font-family: var(--sans); color: var(--text); font-size: 10.5pt; line-height: 1.5; margin: 0; }}
.capa {{ height: 253mm; display: flex; flex-direction: column; break-after: page; }}
.capa .topo {{ padding: var(--space-5) 0; }}
.capa .logo {{ width: 62mm; }}
.capa .bloco {{ flex: 1; background: var(--brand); color: #F3F5F8; border-radius: var(--radius-lg); padding: var(--space-8) var(--space-6); display: flex; flex-direction: column; justify-content: flex-end; }}
.capa .rot {{ font-size: 9pt; font-weight: 600; letter-spacing: 1.5px; color: #F25C6B; }}
.capa h1 {{ font-size: 30pt; line-height: 1.12; font-weight: 800; margin: var(--space-4) 0; }}
.capa .ver {{ font-size: 10pt; color: #A9B2C0; }}
.capa .aviso {{ margin-top: var(--space-5); font-size: 9pt; color: #A9B2C0; border-top: 1px solid #2A3343; padding-top: var(--space-3); }}
h2 {{ font-size: 15pt; font-weight: 700; margin: var(--space-6) 0 var(--space-3); break-after: avoid; }}
h2 .num {{ color: var(--incision); margin-right: 6px; }}
p, li {{ margin: 0 0 var(--space-2); }}
ul {{ padding-left: 18px; }}
table {{ border-collapse: collapse; width: 100%; margin: var(--space-3) 0; font-size: 9.5pt; break-inside: auto; }}
th {{ text-align: left; border-bottom: 1.5px solid var(--text); padding: 4px 6px; }}
td {{ border-bottom: 1px solid var(--line); padding: 4px 6px; vertical-align: top; }}
tr {{ break-inside: avoid; }}
.caixa {{ border: 1px solid var(--line-strong); background: var(--surface-raised); border-radius: var(--radius-lg); padding: var(--space-4); margin: var(--space-3) 0; break-inside: avoid; }}
.caixa .rotulo {{ font-size: 8pt; font-weight: 600; letter-spacing: 1.5px; color: var(--text-muted); margin-bottom: 4px; }}
.caixa.conduta .rotulo {{ color: var(--incision); }}
.caixa .rec {{ font-weight: 600; font-size: 11pt; }}
.caixa .grau {{ display: inline-block; background: var(--surface-sunken); border-radius: var(--radius-sm); padding: 2px 8px; font-size: 9pt; font-weight: 600; }}
.caixa .campo span {{ font-weight: 600; }}
.fluxo {{ text-align: center; margin: var(--space-4) 0; break-inside: avoid; }}
.fluxo svg {{ height: 205mm !important; width: auto !important; max-width: 100% !important; }}
.fluxo-txt {{ font-size: 8pt; background: var(--surface-sunken); padding: var(--space-3); white-space: pre-wrap; }}
.cx {{ display: inline-block; width: 10px; height: 10px; border: 1.5px solid var(--line-strong); border-radius: 2px; margin-right: 4px; }}
code {{ font-size: 9pt; }}
</style></head><body>
<section class="capa"><div class="topo">{marca}</div>
<div class="bloco"><div class="rot">PROPOSTA · GUIA DE ATENDIMENTO · {html.escape(codigo)}</div><h1>{html.escape(titulo)}</h1>
<div class="ver">{html.escape(versao_txt)} · Diretriz clínica, fluxo e regulação, qualidade e segurança do paciente · Proposta do curso CUT, adaptável a cada serviço</div>
<div class="aviso">Proposta para avaliação da diretoria e validação pelas equipes listadas na seção "Equipes para validação". Não é norma vigente nem diretriz validada.</div>
{'<div class="aviso">RASCUNHO: revisão do conteúdo em andamento.</div>' if rascunho else ''}</div></section>
{html_corpo}
</body></html>'''

tmp_html = re.sub(r'\.pdf$', '.html', saida)
open(tmp_html, 'w', encoding='utf-8').write(doc)
from playwright.sync_api import sync_playwright
rod = f'<div style="font-family:Inter,Arial,sans-serif;font-size:7.5pt;color:#5B6473;width:100%;padding:0 18mm;display:flex;justify-content:space-between"><span>CUT · {html.escape(codigo)} · Proposta de guia de atendimento, não validada{" · RASCUNHO" if rascunho else ""}</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>'
with sync_playwright() as p:
    b = p.chromium.launch(); pg = b.new_page()
    pg.goto('file://' + os.path.abspath(tmp_html)); pg.wait_for_timeout(300)
    pg.pdf(path=saida, format='A4', print_background=True, display_header_footer=True,
           header_template='<div></div>', footer_template=rod, margin={'top': '22mm', 'bottom': '20mm', 'left': '18mm', 'right': '18mm'})
    b.close()
print(saida)
