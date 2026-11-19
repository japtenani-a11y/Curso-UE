#!/usr/bin/env bash
# ============================================================
# instalar_python_analise_v1.0.sh
# OBJETIVO: deixar o computador do curso pronto para o relatorio de analise (Python com pandas, scipy e matplotlib).
# USO (no WSL, dentro de ~/Curso-UE):  bash instalar_python_analise_v1.0.sh
#   Vai pedir a senha do WSL (a do sudo), porque instala pacotes do sistema pelo apt, o instalador oficial do Ubuntu.
# Pode ser rodado mais de uma vez: se ja estiver tudo instalado, so confere e testa.
# ============================================================
set -euo pipefail
cd "$(dirname "$0")"
echo "[1/3] Conferindo o Python..."
if ! command -v python3 >/dev/null; then sudo apt update && sudo apt install -y python3; fi
python3 --version
echo "[2/3] Conferindo pandas, scipy e matplotlib..."
if python3 -c "import pandas, scipy, matplotlib" 2>/dev/null; then
  echo "      ja instalados"
else
  echo "      instalando pelo apt (pode levar alguns minutos)..."
  sudo apt update
  sudo apt install -y python3-pandas python3-scipy python3-matplotlib
fi
python3 -c "import pandas, scipy, matplotlib; print('      pandas', pandas.__version__, '| scipy', scipy.__version__, '| matplotlib', matplotlib.__version__)"
echo "[3/3] Testando o relatorio com uma base pequena de exemplo..."
T="$(mktemp -d)"
python3 - "$T/base.csv" <<'PY'
import sys, random
random.seed(1); ondas = ['Pré-teste 1','Pré-teste 2','Pós-teste D0','Pós-teste D+15','Pós-teste D+45','Pós-teste D+90']
cols = 'participante;ano;especialidade;turma;tema;teste_num;teste;dias_da_aula;item;perfil_item;dificuldade;correta;certeza;tempo_s;rapida;apos_aula;aula;equipe;simulado;consentiu;valida;enviada_em'
with open(sys.argv[1], 'w', encoding='utf-8') as f:
    f.write(cols + '\n')
    for p in range(6):
        for o in range(1, 7):
            for i in range(7):
                ok = random.random() < [0.5, 0.55, 0.75, 0.65, 0.6, 0.55][o - 1]
                f.write(f'P{p};R1;Cirurgia Geral;2026;T-001;{o};{ondas[o-1]};{[-12,-3,0,15,45,90][o-1]};I{o}-{i};R1;{random.randint(1,6)};{"t" if ok else "f"};{random.randint(1,3)};30;f;f;ao vivo;f;f;t;t;2026-08-01T20:00:00Z\n')
PY
python3 analise/analise_cut_v1.0.py "$T/base.csv" --saida "$T/rel.html" >/dev/null && echo "      relatorio de teste gerado: tudo pronto." || { echo "      o teste falhou; me envie a mensagem acima."; exit 1; }
rm -rf "$T"
echo "Pronto. No painel (primeira aba), use 'Relatório de análise'."
