import { useEffect, useState } from 'react';

// Calibracao devolvida ao aluno: quanto ele acerta quando marca cada nivel de certeza.
// Bem calibrado: "tenho certeza" acerta quase sempre; "chutei" acerta pouco. A leitura vem com uma frase pratica.
const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';
interface Nivel { certeza: number; respostas: number; acertos: number }
interface Cal { niveis: Nivel[]; erros_com_certeza: number; total: number }
const NOME = ['', 'Chutei', 'Acho que sim', 'Tenho certeza'];

function leitura(c: Cal): string {
  const n3 = c.niveis.find((n) => n.certeza === 3); const n1 = c.niveis.find((n) => n.certeza === 1);
  const p3 = n3 && n3.respostas >= 5 ? n3.acertos / n3.respostas : null;
  const p1 = n1 && n1.respostas >= 5 ? n1.acertos / n1.respostas : null;
  if (c.total < 15) return 'Ainda são poucas respostas para dizer algo. A leitura fica confiável a partir de umas 30.';
  if (p3 !== null && p3 < 0.8) return 'Quando você marca "tenho certeza", erra mais do que deveria. Antes de marcar certeza, pergunte-se de onde vem essa certeza; e releia o gabarito das questões em que errou com certeza.';
  if (p1 !== null && p1 > 0.6) return 'Você acerta bastante quando acha que chutou: sabe mais do que imagina. Vale confiar um pouco mais no seu raciocínio.';
  return 'A sua certeza acompanha bem o seu acerto. Continue marcando com honestidade: é isso que mostra onde estudar.';
}

export function MinhaCalibracao() {
  const [c, setC] = useState<Cal | null>(null);
  useEffect(() => {
    fetch(`${API_BASE}/leitura/calibracao`, { credentials: 'include' }).then((r) => (r.ok ? r.json() : null)).then(setC).catch(() => setC(null));
  }, []);
  if (!c || c.total === 0) return null;
  return (
    <section className="int-cal" aria-labelledby="cal-tit">
      <h2 id="cal-tit">A sua certeza</h2>
      <p className="int-nota">Quanto você acerta em cada nível de certeza marcado nos testes ({c.total} respostas).</p>
      <div className="int-cal-barras">
        {[1, 2, 3].map((k) => {
          const n = c.niveis.find((x) => x.certeza === k);
          const pct = n && n.respostas ? Math.round((100 * n.acertos) / n.respostas) : null;
          return (
            <div key={k} className="int-cal-linha">
              <span className="int-cal-nome">{NOME[k]}</span>
              <span className="int-cal-trilho" aria-hidden="true"><i style={{ width: `${pct ?? 0}%` }} /></span>
              <span className="int-cal-num">{pct === null ? '—' : `${pct}%`}<small> de {n?.respostas ?? 0}</small></span>
            </div>
          );
        })}
      </div>
      {c.erros_com_certeza > 0 && <p><strong>{c.erros_com_certeza}</strong> {c.erros_com_certeza === 1 ? 'erro' : 'erros'} com "tenho certeza": são os que mais vale rever.</p>}
      <p>{leitura(c)}</p>
    </section>
  );
}
