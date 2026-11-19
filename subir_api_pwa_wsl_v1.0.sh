#!/usr/bin/env bash
# ============================================================
# subir_api_pwa_wsl_v1.0.sh
# OBJETIVO: no WSL, gerar a API e o PWA, instalar a tela de revisao
# do curador, ligar os dois em modo de teste local e conferir que o
# curador enxerga os rascunhos do T001.
# USO:   bash subir_api_pwa_wsl_v1.0.sh <SENHA_DO_BANCO> [RAIZ]
#        bash subir_api_pwa_wsl_v1.0.sh parar [RAIZ]
# Rode de dentro da pasta do projeto (onde estao os scripts 06, 07...).
# Modo de TESTE LOCAL: login sem Google (ALLOW_TEST_LOGIN=1). Nao usar em producao.
# ============================================================
set -uo pipefail
PW="${1:?uso: bash subir_api_pwa_wsl_v1.0.sh <SENHA_DO_BANCO> [RAIZ]}"
RAIZ="${2:-./programa-cut}"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
AQUI="$(pwd)"
falhar() { echo; echo "ERRO: $*"; exit 1; }

parar() {
  for n in api pwa notificador ponte respondedor; do  # respondedor: so para desligar o de versoes antigas
    if [ -f "$RAIZ/logs/$n.pid" ]; then
      kill "$(cat "$RAIZ/logs/$n.pid")" 2>/dev/null && echo "parado: $n"
      rm -f "$RAIZ/logs/$n.pid"
    fi
  done
  pkill -f "tsx src/main.ts" 2>/dev/null; pkill -f "tsx src/notificador.ts" 2>/dev/null; pkill -f "tsx src/respondedor.ts" 2>/dev/null; pkill -f "ponte_coordenacao_v1.0.sh" 2>/dev/null; pkill -f "vite" 2>/dev/null; true
}
if [ "$PW" = "parar" ]; then parar; echo "API e PWA parados."; exit 0; fi

[ -f 06_scaffolding_v1.0.sh ] || falhar "rode este script de dentro da pasta do projeto (onde esta o 06_scaffolding_v1.0.sh)."
for f in 32_revisao_v1.0.sql 33_carga_afirmacoes_T001_v1.0.sql 32_revisao_curador_v1.0.sh; do
  [ -f "$f" ] || falhar "arquivo $f nao encontrado nesta pasta. Descompacte o atualizacao_revisao.zip aqui."
done
command -v node >/dev/null || falhar "node nao instalado."
command -v psql >/dev/null || falhar "psql nao instalado."
mkdir -p "$RAIZ/logs"; RABS="$(cd "$RAIZ" && pwd)"

echo "[1/7] Gerando o codigo da API e do PWA..."
if [ ! -f "$RAIZ/api/src/main.ts" ]; then bash 06_scaffolding_v1.0.sh "$RAIZ" > "$RAIZ/logs/gerar.log" 2>&1 || falhar "06 falhou; veja $RAIZ/logs/gerar.log"; fi
if [ ! -f "$RAIZ/.api_pwa_gerado" ]; then
  for s in 07_implementacao_oauth_v1.0.sh 08a_implementacao_aluno_core_v1.0.sh 08b_implementacao_aluno_resto_v1.0.sh \
           09_implementacao_preceptor_v1.0.sh 10_implementacao_curador_v1.0.sh 11_implementacao_pesquisa_conteudo_v1.0.sh \
           24_pwa_telas_restantes_v1.0.sh 27b_seguranca_api_v1.0.sh; do
    [ -f "$s" ] || falhar "script $s nao encontrado."
    bash "$s" "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "$s falhou; veja $RAIZ/logs/gerar.log"
  done
  touch "$RAIZ/.api_pwa_gerado"
fi
bash 32_revisao_curador_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "32_revisao_curador falhou; veja $RAIZ/logs/gerar.log"
if [ -f 34_leitura_aluno_v1.0.sh ]; then bash 34_leitura_aluno_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "34_leitura_aluno falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 40_testes_aluno_v1.0.sh ]; then bash 40_testes_aluno_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "40_testes_aluno falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 44_lembretes_app_v1.0.sh ]; then bash 44_lembretes_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "44_lembretes_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 46_notificacoes_app_v1.0.sh ]; then bash 46_notificacoes_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "46_notificacoes_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 51_acabamento_app_v1.0.sh ]; then bash 51_acabamento_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "51_acabamento_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 56_engajamento_app_v1.0.sh ]; then bash 56_engajamento_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "56_engajamento_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 61_jornada_app_v1.0.sh ]; then bash 61_jornada_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "61_jornada_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 63_cadastro_app_v1.0.sh ]; then bash 63_cadastro_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "63_cadastro_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 67_comunidade_app_v1.0.sh ]; then bash 67_comunidade_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "67_comunidade_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 69_estudo_app_v1.0.sh ]; then bash 69_estudo_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "69_estudo_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 74_extras_app_v1.0.sh ]; then bash 74_extras_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "74_extras_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 75_arvore_app_v1.0.sh ]; then bash 75_arvore_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "75_arvore_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 76_certeza_app_v1.0.sh ]; then bash 76_certeza_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "76_certeza_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 77_tema_cut_app_v1.0.sh ]; then bash 77_tema_cut_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "77_tema_cut_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 78_perfis_app_v1.0.sh ]; then bash 78_perfis_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "78_perfis_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 80_textos_app_v1.0.sh ]; then bash 80_textos_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "80_textos_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 81_sequencia_app_v1.0.sh ]; then bash 81_sequencia_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "81_sequencia_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 82_interativo_app_v1.0.sh ]; then bash 82_interativo_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "82_interativo_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 83_ajustes_app_v1.0.sh ]; then bash 83_ajustes_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "83_ajustes_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 85_estudo_app_v1.0.sh ]; then bash 85_estudo_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "85_estudo_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 87_analise_painel_app_v1.0.sh ]; then bash 87_analise_painel_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "87_analise_painel_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 88_formato_coordenacao_app_v1.0.sh ]; then bash 88_formato_coordenacao_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "88_formato_coordenacao_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 95_entrada_email_app_v1.0.sh ]; then bash 95_entrada_email_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "95_entrada_email_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 97_aprovar_sugeridas_app_v1.0.sh ]; then bash 97_aprovar_sugeridas_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "97_aprovar_sugeridas_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 98_embaralhar_ancoras_app_v1.0.sh ]; then bash 98_embaralhar_ancoras_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "98_embaralhar_ancoras_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 102_revisao_inicio_app_v1.0.sh ]; then bash 102_revisao_inicio_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "102_revisao_inicio_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 103_acesso_equipe_app_v1.0.sh ]; then bash 103_acesso_equipe_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "103_acesso_equipe_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 104_meu_material_app_v1.0.sh ]; then bash 104_meu_material_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "104_meu_material_app falhou; veja $RAIZ/logs/gerar.log"; fi
if [ -f 105_aulas_app_v1.0.sh ]; then bash 105_aulas_app_v1.0.sh "$RAIZ" >> "$RAIZ/logs/gerar.log" 2>&1 || falhar "105_aulas_app falhou; veja $RAIZ/logs/gerar.log"; fi
python3 -c "import pandas, scipy, matplotlib" 2>/dev/null || echo "      aviso: o relatorio de analise do painel precisa do Python com pandas, scipy e matplotlib. Rode uma vez: bash instalar_python_analise_v1.0.sh"
# Conferencia: a tela gerada tem de ser a do CUT (se aparecer a antiga, faltou o git pull ou algum script nao rodou)
grep -q "CUT · Curso" "$RAIZ/pwa/index.html" || falhar "a tela nova do CUT nao foi gerada; descompacte o zip mais novo por cima da pasta e rode de novo este script"
echo "versao instalada: $(cat VERSAO.txt 2>/dev/null || git log -1 --format='%h %cd' --date=format:'%d/%m %H:%M' 2>/dev/null || echo 'desconhecida')"
echo "      ok"

echo "[2/7] Preparando o banco (tabelas de revisao e afirmacoes do T001)..."
export PGPASSWORD="$PW"
SQL="psql -h $HOST -p $PORTA -U postgres -d programa -v ON_ERROR_STOP=1 -q"
# lista de revisores (e-mails) fica fora do repositorio, so neste computador
REV="$HOME/.config/curso-ue/revisores.csv"
if [ -f "$REV" ]; then SQL="$SQL -v revisores=$REV"; else echo "      aviso: $REV nao existe; revisores nao alterados (veja docs/servidor_revisao_v1.0.md)"; fi
$SQL -f 32_revisao_v1.0.sql > "$RAIZ/logs/banco.log" 2>&1 || falhar "32_revisao_v1.0.sql falhou; veja $RAIZ/logs/banco.log"
if [ -f 35_caso_T001_v2.sql ]; then $SQL -f 35_caso_T001_v2.sql >> "$RAIZ/logs/banco.log" 2>&1 || falhar "35_caso_T001_v2.sql falhou; veja $RAIZ/logs/banco.log"; fi
V2=$($SQL -At -c "SELECT count(*) FROM conteudo.artefato WHERE tipo='caso_base'")
if [ "$V2" = "0" ]; then $SQL -f 33_carga_afirmacoes_T001_v1.0.sql >> "$RAIZ/logs/banco.log" 2>&1 || falhar "33_carga_afirmacoes falhou; veja $RAIZ/logs/banco.log"; fi
for f in 37_banco_questoes_v1.0.sql 38_liberacao_v1.0.sql 39_ondas_teste_T001_v1.0.sql 43_calendario_lembretes_v1.0.sql 45_notificacoes_v1.0.sql 47_camadas_evidencia_v1.0.sql 49_revisores_v1.0.sql 101_reestruturacao_temas_v1.0.sql 53_temas_programa_v1.0.sql 100_fusao_temas_v1.0.sql 54_temas_opcionais_v1.0.sql 55_avaliacao_ranking_v1.0.sql 58_duvidas_publicacao_v1.0.sql 59_aviso_revisao_v1.0.sql 60_jornada_aluno_v1.0.sql 62_cadastro_aluno_v1.0.sql 64_nota_esperada_v1.0.sql 65_arvore_temas_v1.0.sql 66_mural_presenca_v1.0.sql 68_estudo_dirigido_v1.0.sql 71_temas_producao_v1.0.sql 72_sintese_pesquisa_v1.0.sql 73_extras_v1.0.sql 76_certeza_questao_v1.0.sql 78_perfis_v1.0.sql 79_aluno_para_todos_v1.0.sql 81_sequencia_material_v1.0.sql 82_interativo_v1.0.sql 83_ajustes_v2p_v1.0.sql 84_falas_slides_T001_v1.0.sql 85_estudo_pesquisa_v1.0.sql 86_dicas_caso_T001_v1.0.sql 88_formato_tempo_v1.0.sql 89_coordenacao_agentes_v1.0.sql 92_prazos_producao_v1.0.sql 95_entrada_por_email_v1.0.sql 97_aprovar_sugeridas_v1.0.sql 99_producao_agente_v1.0.sql 103_acesso_equipe_v1.0.sql 104_meu_material_v1.0.sql 105_temas_liberados_v1.0.sql; do
  # depois que o T001 passou pelo importador (questoes com codigo T001-T1-...), o banco de questoes antigo (37) e as
  # ondas de teste (39) nao sao recarregados: recriariam as questoes antigas ao lado das novas
  if [ "$f" = 37_banco_questoes_v1.0.sql ] || [ "$f" = 39_ondas_teste_T001_v1.0.sql ]; then
    IMP=$($SQL -At -c "SELECT count(*) FROM app.item WHERE codigo LIKE 'T001-T_-%'" 2>/dev/null || echo 0)
    [ "${IMP:-0}" != "0" ] && continue
  fi
  if [ -f "$f" ]; then $SQL -f "$f" >> "$RAIZ/logs/banco.log" 2>&1 || falhar "$f falhou; veja $RAIZ/logs/banco.log"; fi
done
N=$($SQL -At -c "SELECT count(*) FROM conteudo.afirmacao")
# pecas do T001 em qualquer situacao (rascunho, aprovada ou publicada): depois da revisao elas deixam de ser rascunho
R=$($SQL -At -c "SELECT count(*) FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' AND a.status::text <> 'arquivado'")
T=$($SQL -At -c "SELECT count(*) FROM pg_proc WHERE proname='fn_sessao_teste'")
echo "      pecas do T001 (rascunho, aprovadas ou publicadas): $R | afirmacoes carregadas: $N"
[ "$R" -ge 12 ] || falhar "as pecas do T001 nao estao no banco. Rode antes o 31_importar_T001_rascunhos_v1.0.sql."
[ "$T" -ge 1 ] || falhar "funcao de login de teste (fn_sessao_teste) nao existe no banco."
[ -n "${SO_PREPARAR:-}" ] && { echo "SO_PREPARAR: parando antes de instalar pacotes."; exit 0; }

echo "[3/7] Instalando pacotes da API e do PWA (pode levar alguns minutos)..."
(cd "$RAIZ/api" && npm install --no-audit --no-fund > "$RABS/logs/npm_api.log" 2>&1) || falhar "npm install da API falhou; veja $RAIZ/logs/npm_api.log"
(cd "$RAIZ/pwa" && npm install --no-audit --no-fund > "$RABS/logs/npm_pwa.log" 2>&1) || falhar "npm install do PWA falhou; veja $RAIZ/logs/npm_pwa.log"
echo "      ok"

echo "[4/7] Conferindo o codigo (tipos)..."
(cd "$RAIZ/api" && npx tsc --noEmit > "$RABS/logs/tipos_api.log" 2>&1); EA=$(grep -c "error TS" "$RAIZ/logs/tipos_api.log" || true)
(cd "$RAIZ/pwa" && npx tsc --noEmit > "$RABS/logs/tipos_pwa.log" 2>&1); EP=$(grep -c "error TS" "$RAIZ/logs/tipos_pwa.log" || true)
echo "      erros de tipo -> API: $EA | PWA: $EP  (nao impedem o teste; se houver, me envie os arquivos logs/tipos_*.log)"

echo "[5/7] Ligando a API (porta 3000)..."
parar >/dev/null 2>&1
PUSHENV="$HOME/.config/curso-ue/push.env"   # chaves dos avisos no celular (npm run chaves-push), fora do projeto
EMAILENV="$HOME/.config/curso-ue/email.env"   # conta de e-mail (52_configurar_email): lembretes e link de entrada
( set -a; [ -f "$PUSHENV" ] && . "$PUSHENV"; [ -f "$EMAILENV" ] && . "$EMAILENV"; set +a; cd "$RAIZ/api" && DATABASE_URL="postgresql://api_rw:$PW@$HOST:$PORTA/programa" PORT=3000 NODE_ENV=teste_local \
  ALLOW_TEST_LOGIN=1 APP_URL=http://localhost:5173 CORS_ORIGINS=http://localhost:5173 LOG_LEVEL=info \
  nohup setsid npx tsx src/main.ts > "$RABS/logs/api.log" 2>&1 & echo $! > "$RABS/logs/api.pid" )
OK=""; for i in $(seq 1 30); do sleep 1; curl -s http://localhost:3000/health | grep -q '"db":"ok"' && { OK=1; break; }; done
[ -n "$OK" ] || { tail -20 "$RAIZ/logs/api.log"; falhar "a API nao respondeu; as ultimas linhas do log estao acima ($RAIZ/logs/api.log)."; }
echo "      ok"

echo "[6/7] Testando: login do curador de teste e leitura dos rascunhos..."
RASC=$($SQL -At -c "SELECT count(*) FROM conteudo.artefato a JOIN app.tema t USING (tema_id) WHERE replace(t.codigo,'-','')='T001' AND a.status='rascunho'" 2>/dev/null || echo 0)
CK="$RAIZ/logs/cookie.txt"; rm -f "$CK"
L=$(curl -s -o /dev/null -w "%{http_code}" -c "$CK" -H "Content-Type: application/json" -d '{"email":"curador.teste@setup.local"}' http://localhost:3000/auth/login)
[ "$L" = "200" ] || { tail -8 "$RAIZ/logs/api.log"; falhar "login de teste respondeu $L (esperado 200)."; }
curl -s -b "$CK" http://localhost:3000/revisao/temas/T001 > "$RAIZ/logs/revisao_T001.json"
node -e '
const d=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));
if(!d.artefatos){console.log("      resposta inesperada: "+JSON.stringify(d).slice(0,200));process.exit(1)}
const af=d.artefatos.reduce((s,a)=>s+a.afirmacoes.length,0);
console.log("      curador enxerga "+d.artefatos.length+" rascunhos e "+af+" afirmacoes");
const esperado=Number(process.argv[2]||0);
if(esperado>0&&d.artefatos.length<Math.min(12,esperado))process.exit(1);
if(esperado===0)console.log("      (o T001 nao tem rascunho: as pecas ja foram aprovadas ou publicadas, e a tela de revisao fica vazia)")' "$RAIZ/logs/revisao_T001.json" "$RASC" || falhar "o curador nao enxergou os rascunhos do T001; veja $RAIZ/logs/revisao_T001.json"
if [ -f 56_engajamento_app_v1.0.sh ]; then
  DC=$(curl -s -o /dev/null -w "%{http_code}" -b "$CK" "http://localhost:3000/curadoria/duvidas")
  PB=$(curl -s -o /dev/null -w "%{http_code}" -b "$CK" -H "Content-Type: application/json" -d '{}' "http://localhost:3000/revisao/artefatos/0/publicar")
  echo "      curador abrindo as duvidas dos alunos: $DC (esperado 200) | publicar sem peca valida: $PB (esperado 400)"
  PN=$(curl -s -o /dev/null -w "%{http_code}" -b "$CK" "http://localhost:3000/painel/notas?formato=csv")
  [ -f 61_jornada_app_v1.0.sh ] && echo "      curador baixando as notas do painel (CSV): $PN (esperado 200)"
fi
S=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/revisao/temas/T001)
echo "      sem login a mesma pagina responde $S (esperado 403)"
if [ -f 34_leitura_aluno_v1.0.sh ]; then
  NP=$(curl -s -b "$CK" "http://localhost:3000/leitura/temas/T001?previa=1" | grep -o '"artefato_id"' | wc -l)
  echo "      previa de leitura para o revisor: $NP artefatos (esperado 13)"
  CA="$RAIZ/logs/cookie_aluno.txt"
  curl -s -o /dev/null -c "$CA" -H "Content-Type: application/json" -d '{"email":"r1.teste@setup.local"}' http://localhost:3000/auth/login
  SA=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/leitura/temas/T001?previa=1")
  echo "      aluno de teste pedindo a previa de rascunhos responde $SA (esperado 403)"
  if [ -f 40_testes_aluno_v1.0.sh ]; then
    curl -s -o /dev/null -c "$CA" -H "Content-Type: application/json" -d '{"email":"r1.teste@setup.local"}' http://localhost:3000/auth/login
    NT=$(curl -s -b "$CA" "http://localhost:3000/teste/temas/T001" | grep -o '"onda_id"' | wc -l)
    GB=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/teste/ondas/999999/gabarito")
    echo "      testes do T001 para o aluno de teste: $NT (esperado 6) | gabarito sem responder: $GB (esperado 403)"
  fi
  if [ -f 46_notificacoes_app_v1.0.sh ]; then
    CT=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/contato")
    ZI=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" -H "Content-Type: application/json" -d '{"whatsapp":"123","aceita_whatsapp":true}' "http://localhost:3000/contato")
    echo "      tela de contato do aluno: $CT (esperado 200) | WhatsApp invalido recusado: $ZI (esperado 422)"
  fi
  if [ -f 56_engajamento_app_v1.0.sh ]; then
    NC=$(curl -s -b "$CA" "http://localhost:3000/eng/catalogo" | grep -o '"codigo"' | wc -l)
    RK=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/eng/ranking?filtro=subgrupo")
    echo "      temas no catalogo do aluno: $NC (esperado 150) | ranking: $RK (esperado 200)"
    DV=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/curadoria/duvidas")
    echo "      aluno abrindo as duvidas da curadoria: $DV (esperado 403)"
  fi
  if [ -f 61_jornada_app_v1.0.sh ]; then
    JT=$(curl -s -b "$CA" "http://localhost:3000/jornada/temas/T001" | grep -o '"num"' | wc -l)
    PD=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/jornada/pendencias")
    PA=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/painel/notas")
    echo "      tela do tema T001: $JT testes (esperado 6) | pendencias: $PD (esperado 200) | aluno no painel: $PA (esperado 403)"
    if [ -f 63_cadastro_app_v1.0.sh ]; then
      CS=$(curl -s -b "$CA" "http://localhost:3000/cadastro/situacao" | grep -o '"ok":true' | wc -l)
      IN=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/inscricoes")
      echo "      aluno de teste com inscricao aprovada: $CS (esperado 1) | aluno abrindo inscricoes: $IN (esperado 403)"
      if [ -f 67_comunidade_app_v1.0.sh ]; then
        AR=$(curl -s -b "$CA" "http://localhost:3000/jornada/arvore" | grep -o '"codigo"' | wc -l)
        MU=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/com/mural")
        echo "      arvore de temas: $AR temas (esperado 150) | mural do aluno: $MU (esperado 200)"
        if [ -f 69_estudo_app_v1.0.sh ]; then
          ES=$(curl -s -o /dev/null -w "%{http_code}" -b "$CA" "http://localhost:3000/estudo/opcoes")
          echo "      estudo dirigido do aluno: $ES (esperado 200)"
        fi
      fi
    fi
  fi
  rm -f "$CA"
fi
rm -f "$CK"

if [ -f "$RAIZ/api/src/notificador.ts" ]; then
  EM="$HOME/.config/curso-ue/email.env"
  if [ -f "$EM" ]; then echo "      ligando o enviador de lembretes: e-mail pelo Gmail configurado (so para quem autorizou)"
  else echo "      ligando o enviador de lembretes em modo SIMULADO (configure o e-mail com 52_configurar_email_v1.0.sh)"; fi
  ( set -a; [ -f "$EM" ] && . "$EM"; [ -f "$PUSHENV" ] && . "$PUSHENV"; set +a; cd "$RAIZ/api" && DATABASE_URL="postgresql://api_rw:$PW@$HOST:$PORTA/programa" NODE_ENV=teste_local NOTIFICAR_MODO="${NOTIFICAR_MODO:-simular}" \
    APP_URL=http://localhost:5173 LOG_LEVEL=info nohup setsid npx tsx src/notificador.ts > "$RABS/logs/notificador.log" 2>&1 & echo $! > "$RABS/logs/notificador.pid" )
fi

if [ -f "$AQUI/ponte_coordenacao_v1.0.sh" ]; then
  echo "      ligando a ponte dos agentes da coordenacao (pasta CUT_coordenacao do Windows, a cada 10 minutos)"
  ( DATABASE_URL="postgresql://api_rw:$PW@$HOST:$PORTA/programa" PRODUCAO_URL="postgresql://maestro_rw:$PW@$HOST:$PORTA/programa" nohup setsid bash "$AQUI/ponte_coordenacao_v1.0.sh" > "$RABS/logs/ponte.log" 2>&1 & echo $! > "$RABS/logs/ponte.pid" )
fi

echo "[7/7] Ligando o PWA (porta 5173)..."
( cd "$RAIZ/pwa" && VITE_API_URL=http://localhost:3000 VITE_LOGIN_TESTE=1 nohup setsid npx vite --host 127.0.0.1 --port 5173 --strictPort > "$RABS/logs/pwa.log" 2>&1 & echo $! > "$RABS/logs/pwa.pid" )
OK=""; for i in $(seq 1 30); do sleep 1; curl -s -o /dev/null http://localhost:5173/ && { OK=1; break; }; done
[ -n "$OK" ] || { tail -20 "$RAIZ/logs/pwa.log"; falhar "o PWA nao ligou; as ultimas linhas do log estao acima ($RAIZ/logs/pwa.log)."; }

cat <<FIM

=== PRONTO ===
1. Abra no navegador do Windows:  http://localhost:5173/login
2. Digite o e-mail:               curador.teste@setup.local   e clique em Entrar
3. Voce cai na tela de revisao do T001.

Para desligar tudo:  bash subir_api_pwa_wsl_v1.0.sh parar
Registros (logs):    $RAIZ/logs/
FIM
