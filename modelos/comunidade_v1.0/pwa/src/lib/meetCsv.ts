// Le o relatorio de presenca do Google Meet (CSV em ingles ou portugues) e devolve {email, nome, minutos, entrada, saida}.
export interface LinhaMeet { email: string; nome: string; minutos: number; entrada: string | null; saida: string | null }

const sem = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().trim();

function dividir(linha: string, sep: string): string[] {
  const out: string[] = []; let atual = ''; let aspas = false;
  for (let i = 0; i < linha.length; i++) {
    const c = linha[i];
    if (c === '"') { if (aspas && linha[i + 1] === '"') { atual += '"'; i++; } else aspas = !aspas; }
    else if (c === sep && !aspas) { out.push(atual); atual = ''; }
    else atual += c;
  }
  out.push(atual);
  return out.map((x) => x.trim());
}

export function minutosDe(txt: string): number {
  const t = sem(txt);
  const hms = /^(\d+):(\d{1,2})(?::(\d{1,2}))?$/.exec(t);
  if (hms) return Number(hms[1]) * 60 + Number(hms[2]) + Number(hms[3] ?? 0) / 60;
  const h = /(\d+(?:[.,]\d+)?)\s*(h|hr|hrs|hora|horas)\b/.exec(t);
  const m = /(\d+(?:[.,]\d+)?)\s*(m|min|mins|minuto|minutos)\b/.exec(t);
  const s = /(\d+(?:[.,]\d+)?)\s*(s|seg|sec|segundo|segundos)\b/.exec(t);
  const n = (x: RegExpExecArray | null) => (x ? Number((x[1] ?? '0').replace(',', '.')) : 0);
  if (h || m || s) return n(h) * 60 + n(m) + n(s) / 60;
  const num = Number(t.replace(',', '.'));
  return Number.isFinite(num) ? num : 0;
}

function dataDe(txt: string): string | null {
  if (!txt) return null;
  const d = new Date(txt);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

export function lerCsvMeet(conteudo: string): { linhas: LinhaMeet[]; aviso: string | null } {
  const brutas = conteudo.replace(/^﻿/, '').split(/\r?\n/).filter((l) => l.trim());
  // o relatorio as vezes traz linhas de titulo antes do cabecalho: procura a linha com a coluna de e-mail
  const ini = brutas.findIndex((l) => /e-?mail/i.test(l));
  if (ini < 0) return { linhas: [], aviso: 'Não encontrei a coluna de e-mail no arquivo.' };
  const cabecalho = brutas[ini] ?? '';
  const sep = (cabecalho.match(/;/g)?.length ?? 0) > (cabecalho.match(/,/g)?.length ?? 0) ? ';' : ',';
  const cab = dividir(cabecalho, sep).map(sem);
  const col = (...nomes: string[]) => cab.findIndex((c) => nomes.some((n) => c.includes(n)));
  const cEmail = col('mail'), cDur = col('dura'), cEnt = col('entrada', 'joined', 'join', 'inicio'), cSai = col('saida', 'exited', 'left', 'fim');
  const cNome = col('first name', 'nome', 'name', 'participante'), cSob = col('last name', 'sobrenome');
  const linhas: LinhaMeet[] = [];
  for (const l of brutas.slice(ini + 1)) {
    const v = dividir(l, sep);
    const email = (v[cEmail] ?? '').toLowerCase();
    let minutos = cDur >= 0 ? minutosDe(v[cDur] ?? '') : 0;
    const entrada = cEnt >= 0 ? dataDe(v[cEnt] ?? '') : null, saida = cSai >= 0 ? dataDe(v[cSai] ?? '') : null;
    if (!minutos && entrada && saida) minutos = (new Date(saida).getTime() - new Date(entrada).getTime()) / 60_000;
    const nome = [cNome >= 0 ? v[cNome] : '', cSob >= 0 && cSob !== cNome ? v[cSob] : ''].filter(Boolean).join(' ');
    if (email || nome) linhas.push({ email, nome, minutos: Math.max(0, Math.round(minutos * 10) / 10), entrada, saida });
  }
  return { linhas, aviso: cDur < 0 && cEnt < 0 ? 'Não encontrei a duração nem os horários: confira o arquivo.' : null };
}
