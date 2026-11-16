#!/usr/bin/env bash
# ============================================================
# ponte_coordenacao_v1.0.sh
# OBJETIVO: levar ao Windows o que os agentes da coordenacao precisam e trazer de volta as propostas deles.
#  A cada 10 minutos:
#   1. grava em CUT_coordenacao\entrada\<agente>.json o pacote de cada agente (app.coord_pacote);
#   2. le os arquivos que os agentes deixaram em CUT_coordenacao\propostas\, grava no banco como propostas
#      aguardando a sua decisao (app.coord_receber) e move cada arquivo para processadas\ (ou com_erro\, com o motivo).
#  Os agentes nao tem acesso ao banco: so a esta pasta. Nada chega ao aluno sem a decisao na aba "Para revisar".
# USO: o subir_api_pwa_wsl_v1.0.sh liga a ponte sozinho. Para uma rodada so, a mao:
#   DATABASE_URL=postgresql://api_rw:SENHA@localhost:5432/programa bash ponte_coordenacao_v1.0.sh --uma-vez
# PASTA: C:\Users\<voce>\CUT_coordenacao (fora do OneDrive de proposito: tem texto de duvidas e primeiro nome de aluno).
#   Para mudar: COORD_DIR=/mnt/c/... bash ponte_coordenacao_v1.0.sh
# ============================================================
set -uo pipefail
: "${DATABASE_URL:?defina DATABASE_URL (a mesma conexao da API)}"
INTERVALO="${COORD_INTERVALO:-600}"
if [ -z "${COORD_DIR:-}" ]; then
  WINHOME="$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')"
  if [ -n "$WINHOME" ] && command -v wslpath >/dev/null; then COORD_DIR="$(wslpath "$WINHOME")/CUT_coordenacao"
  else COORD_DIR="$HOME/CUT_coordenacao"; fi
fi
mkdir -p "$COORD_DIR"/{entrada,propostas,processadas,com_erro,indicadores,relatorios,referencia,fontes_novas,fontes_recebidas,fontes_recusadas}
AQUI="$(cd "$(dirname "$0")" && pwd)"
# regras que os agentes consultam (copiadas a cada ligacao da ponte, para ficarem sempre na versao instalada)
for d in formato_das_pecas.md coordenacao_agentes.md; do [ -f "$AQUI/docs/$d" ] && cp -f "$AQUI/docs/$d" "$COORD_DIR/referencia/"; done
# modelo da planilha de indicadores: so totais do mes
[ -f "$COORD_DIR/indicadores/MODELO_totais.csv" ] || printf '%s\n' \
  'mes;indicador;numerador;denominador;fonte' \
  '2026-12;via_aerea_registrada;;;registro de trauma' '2026-12;temperatura_admissao;;;registro de trauma' \
  '2026-12;aquecimento_iniciado;;;registro de trauma' '2026-12;terciaria_registrada;;;registro de trauma' \
  '2026-12;lider_definido;;;registro de trauma' '2026-12;torniquete_horario;;;registro de trauma' > "$COORD_DIR/indicadores/MODELO_totais.csv"
PSQL=(psql "$DATABASE_URL" -X -q -At -v ON_ERROR_STOP=1)

if [ ! -f "$COORD_DIR/LEIA-ME.txt" ]; then
  cat > "$COORD_DIR/LEIA-ME.txt" <<'TXT'
CUT - pasta da coordenacao com agentes

entrada\      o CUT grava aqui, a cada 10 minutos, o que cada agente precisa (nao edite).
propostas\    os agentes gravam aqui as propostas; o CUT leva para a aba "Para revisar" do painel.
processadas\  propostas ja levadas ao painel.
com_erro\     propostas recusadas (fora do formato); o motivo esta no arquivo .erro.txt ao lado.
indicadores\  salve aqui a planilha do mes SO COM TOTAIS, copiando o MODELO_totais.csv (mes;indicador;numerador;denominador;fonte).
              Nunca nome, prontuario, data de nascimento ou qualquer dado de paciente.
relatorios\   resumos que os agentes deixam para leitura (o resumo do dia sai as 7h30).
referencia\   regras que os agentes consultam (formato das pecas, rotina da coordenacao). Nao edite.
fontes_novas\ SOLTE AQUI os PDFs (artigos, diretrizes, capitulos, protocolos, fichas EM BRANCO) para o triador de fontes.
              Ele indica todos os temas em que cada um serve; voce aprova no painel e a fonte fica guardada para esses temas.
fontes_recebidas\  os arquivos ja registrados (F + codigo). fontes_recusadas\  os recusados, com o motivo ao lado.

Os agentes nunca mudam nada sozinhos: tudo passa pela sua decisao no painel (Aprovar, Aprovar com a alteracao, Vetar).
Esta pasta fica fora do OneDrive de proposito. Nao compartilhe.
TXT
fi

rodada() {
  local ok=0 rec=0 err=0 a f n
  shopt -s nullglob
  # fontes soltas pela coordenacao: texto extraido, dado de paciente recusado, PDF guardado e registrado para o triador
  for f in "$COORD_DIR"/fontes_novas/*; do
    [ -f "$f" ] || continue
    if [ $(( $(date +%s) - $(stat -c %Y "$f") )) -lt 30 ]; then continue; fi
    SAIDA_F="$(python3 -I "$AQUI/ferramentas/registrar_fonte.py" "$f" 2>>"$COORD_DIR/entrada/.ponte_erros.log")"
    case "$(printf '%s' "$SAIDA_F" | head -1 | cut -f1)" in
      REGISTRAR)
        DEST="$(printf '%s' "$SAIDA_F" | head -1 | cut -f2)"
        if printf '%s\n' "$SAIDA_F" | tail -n +2 | "${PSQL[@]}" >/dev/null 2>>"$COORD_DIR/entrada/.ponte_erros.log"; then
          mv -f "$f" "$COORD_DIR/fontes_recebidas/$DEST"
        fi ;;
      RECUSAR)
        mv -f "$f" "$COORD_DIR/fontes_recusadas/"
        printf '%s\n' "$(printf '%s' "$SAIDA_F" | head -1 | cut -f2)" > "$COORD_DIR/fontes_recusadas/$(basename "$f").motivo.txt" ;;
    esac
  done
  for a in duvidas pecas conteudo atrasados indicadores supervisor fontes; do
    if "${PSQL[@]}" -c "SELECT app.coord_pacote('$a')" > "$COORD_DIR/entrada/.$a.tmp" 2>> "$COORD_DIR/entrada/.ponte_erros.log"; then
      mv -f "$COORD_DIR/entrada/.$a.tmp" "$COORD_DIR/entrada/$a.json"; ok=$((ok + 1))
    else rm -f "$COORD_DIR/entrada/.$a.tmp"; fi
  done
  for f in "$COORD_DIR"/propostas/*.json; do
    # arquivo ainda sendo gravado pelo agente: espera a proxima rodada
    if [ $(( $(date +%s) - $(stat -c %Y "$f") )) -lt 20 ]; then continue; fi
    if n=$("${PSQL[@]}" -v j="$(cat "$f")" 2>"$f.erro.txt" <<< "SELECT app.coord_receber(:'j'::jsonb);"); then
      rm -f "$f.erro.txt"; mv -f "$f" "$COORD_DIR/processadas/"; rec=$((rec + n))
    else
      mv -f "$f" "$COORD_DIR/com_erro/"; mv -f "$f.erro.txt" "$COORD_DIR/com_erro/$(basename "$f").erro.txt"; err=$((err + 1))
    fi
  done
  printf '{"ultima_rodada":"%s","pacotes_gravados":%s,"propostas_recebidas":%s,"arquivos_com_erro":%s}\n' \
    "$(date -Iseconds)" "$ok" "$rec" "$err" > "$COORD_DIR/entrada/estado.json"
}

if [ "${1:-}" = "--uma-vez" ]; then rodada; cat "$COORD_DIR/entrada/estado.json"; echo "pasta: $COORD_DIR"; exit 0; fi
while true; do rodada; sleep "$INTERVALO"; done
