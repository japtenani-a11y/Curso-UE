#!/usr/bin/env bash
# ============================================================
# 93_apagar_respostas_teste_v1.0.sh
# OBJETIVO: apagar TODAS as respostas e atividades de aluno gravadas ate agora (todas foram testes), deixando o banco
#   limpo para a abertura do curso. Decisao da coordenacao em 16/11/2026.
#   Apaga: pessoas simuladas (@simulado.local, script 91) e, de todos os usuarios: testes enviados e respostas, rascunhos
#   de teste, notas, revisao espacada, simulados e flashcards do estudo dirigido, estado do material (caso, caso base,
#   checklist, onde parou), tempo de leitura e uso do material, avaliacoes (NPS), aplicabilidade, presenca, duvidas e
#   feedback, respostas do mural, fila de e-mails e avisos, e as propostas dos agentes da coordenacao.
#   NAO apaga: contas, perfis, fichas, funcoes da equipe, termos aceitos, consentimento, temas, pecas, questoes,
#   pareceres de revisao, fontes, indicadores clinicos e o registro de acesso (seguranca).
#   Antes de apagar, faz uma copia completa do banco em ~/CursoUE_backups.
# USO: bash 93_apagar_respostas_teste_v1.0.sh SENHA      (mostra o que sera apagado e pede para digitar APAGAR)
# RODAR UMA VEZ, a mao. Nao faz parte do subir.
# ============================================================
set -uo pipefail
PW="${1:?uso: bash 93_apagar_respostas_teste_v1.0.sh SENHA}"
HOST="${PGHOST_TESTE:-localhost}"; PORTA="${PGPORT_TESTE:-5432}"
export PGPASSWORD="$PW"
SQL=(psql -h "$HOST" -p "$PORTA" -U postgres -d programa -v ON_ERROR_STOP=1 -q)
AQUI="$(cd "$(dirname "$0")" && pwd)"
TABELAS="resposta tentativa resposta_rascunho nota_teste item_revisao simulado_resposta simulado_aluno flashcard_revisao estado_material leitura_tempo uso_material avaliacao aplicabilidade presenca mensagem_aluno mural_resposta mural_leitura confianca_teste notificacao_saida proposta_agente"

echo "O que existe hoje (sera apagado):"
for t in $TABELAS; do
  n=$("${SQL[@]}" -At -c "SELECT CASE WHEN to_regclass('app.$t') IS NULL THEN '-' ELSE (SELECT count(*)::text FROM app.$t) END" 2>/dev/null || echo '?')
  printf '  %-20s %s\n' "$t" "$n"
done
echo "  pessoas simuladas    $("${SQL[@]}" -At -c "SELECT count(*) FROM app.pessoa WHERE email_primario::text LIKE '%@simulado.local'")"
echo
read -r -p "Digite APAGAR para continuar (qualquer outra coisa cancela): " OK
[ "$OK" = "APAGAR" ] || { echo "Cancelado. Nada foi apagado."; exit 0; }

mkdir -p "$HOME/CursoUE_backups"; COPIA="$HOME/CursoUE_backups/antes_de_apagar_respostas_$(date +%Y%m%d_%H%M).dump"
echo "Copia de seguranca: $COPIA"
pg_dump -h "$HOST" -p "$PORTA" -U postgres -Fc programa > "$COPIA" || { echo "ERRO: a copia falhou. Nada foi apagado."; exit 1; }

[ -f "$AQUI/91_apagar_simulacao_v1.0.sql" ] && { "${SQL[@]}" -f "$AQUI/91_apagar_simulacao_v1.0.sql" || { echo "ERRO no 91. Nada mais foi apagado."; exit 1; }; }

"${SQL[@]}" <<'E' || { echo "ERRO: nada foi apagado nesta etapa (a transacao foi desfeita)."; exit 1; }
BEGIN;
ALTER TABLE app.resposta DISABLE TRIGGER tg_resposta_imutavel;
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['resposta', 'resposta_rascunho', 'nota_teste', 'tentativa', 'item_revisao', 'simulado_resposta', 'simulado_aluno',
                           'flashcard_revisao', 'estado_material', 'leitura_tempo', 'uso_material', 'avaliacao', 'aplicabilidade', 'presenca',
                           'notificacao_saida', 'mensagem_aluno', 'mural_resposta', 'mural_leitura', 'confianca_teste', 'proposta_agente'] LOOP
    IF to_regclass('app.' || t) IS NOT NULL THEN EXECUTE format('DELETE FROM app.%I', t); END IF;
  END LOOP;
END $$;
ALTER TABLE app.resposta ENABLE TRIGGER tg_resposta_imutavel;
COMMIT;
E
echo "Pronto: respostas e atividades de teste apagadas. Para voltar atras: pg_restore -c -d programa \"$COPIA\""
