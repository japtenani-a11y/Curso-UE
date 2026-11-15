import { Router } from 'express';
import { withMaestro } from '../db/transaction.js';

// Rotas publicas extras: verificacao de certificado e agenda (.ics) pelo link pessoal.
export const publicoExtraRouter = Router();

publicoExtraRouter.get('/certificado/:codigo', async (req, res, next) => {
  try {
    const c = await withMaestro(null, async (x) => (await x.query('SELECT app.verificar_certificado($1) AS c', [String(req.params.codigo).slice(0, 20)])).rows[0]?.c);
    if (!c) { res.status(404).json({ erro: 'certificado_nao_encontrado' }); return; }
    res.json(c);
  } catch (err) { next(err); }
});

const ics = (s: string) => s.replace(/\\/g, '\\\\').replace(/;/g, '\;').replace(/,/g, '\\,').replace(/\r?\n/g, '\\n');
const dt = (d: Date) => d.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '');
const dobra = (l: string) => { const out: string[] = []; let s = l; while (s.length > 74) { out.push(s.slice(0, 74)); s = ' ' + s.slice(74); } out.push(s); return out.join('\r\n'); };

publicoExtraRouter.get('/agenda/:token', async (req, res, next) => {
  try {
    const token = String(req.params.token).replace(/\.ics$/, '');
    const ev = await withMaestro(null, async (x) => (await x.query('SELECT * FROM app.agenda_por_token($1)', [token])).rows as
      { uid: string; inicio: Date; titulo: string; descricao: string; link: string | null }[]);
    const durMin = 90;
    const linhas = ['BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//Programa CUT//Agenda//PT', 'CALSCALE:GREGORIAN', 'METHOD:PUBLISH',
      'X-WR-CALNAME:Programa de Cirurgia de Urgência e Trauma', 'X-WR-TIMEZONE:America/Sao_Paulo'];
    for (const e of ev) {
      const ini = new Date(e.inicio); const fim = new Date(ini.getTime() + durMin * 60_000);
      linhas.push('BEGIN:VEVENT', `UID:${e.uid}`, `DTSTAMP:${dt(new Date())}`, `DTSTART:${dt(ini)}`, `DTEND:${dt(fim)}`,
        `SUMMARY:${ics(e.titulo)}`, `DESCRIPTION:${ics(e.descricao + (e.link ? `\nGoogle Meet: ${e.link}` : ''))}`);
      if (e.link) linhas.push(`LOCATION:${ics(e.link)}`, `URL:${e.link}`);
      linhas.push('BEGIN:VALARM', 'TRIGGER:-PT1H', 'ACTION:DISPLAY', 'DESCRIPTION:Aula em 1 hora', 'END:VALARM', 'END:VEVENT');
    }
    linhas.push('END:VCALENDAR');
    res.setHeader('Content-Type', 'text/calendar; charset=utf-8');
    res.setHeader('Content-Disposition', 'inline; filename="programa-cut.ics"');
    res.setHeader('Cache-Control', 'private, max-age=600');
    res.send(linhas.map(dobra).join('\r\n'));
  } catch (err) { next(err); }
});
