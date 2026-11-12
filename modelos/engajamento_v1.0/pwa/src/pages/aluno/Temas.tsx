import { useEffect, useMemo, useState } from 'react';
import { apiGet, apiPost } from '../../lib/api.js';

interface Tema { codigo: string; titulo: string; modulo: string | null; dificuldade: number; papel: string; ordem: number | null;
  data_d0: string | null; d0_proprio: boolean; etapa: number; testes_feitos: number; tem_conteudo: boolean }

const quando = (s: string) => new Date(s).toLocaleString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', year: '2-digit', hour: '2-digit', minute: '2-digit' });
const ERROS: Record<string, string> = {
  data_invalida: 'Escolha uma data entre 2 horas e 400 dias a partir de agora.',
  tema_ja_iniciado: 'Você já começou este tema; a data não pode mais mudar.',
  tema_principal_tem_data_do_grupo: 'Este tema é principal e segue a data do grupo.',
};

export function Temas() {
  const [temas, setTemas] = useState<Tema[] | null>(null);
  const [filtro, setFiltro] = useState('');
  const [escolha, setEscolha] = useState<Record<string, string>>({});
  const [msg, setMsg] = useState<string | null>(null);
  const carregar = () => apiGet<{ temas: Tema[] }>('/eng/catalogo').then((d) => setTemas(d.temas)).catch(() => setMsg('Não foi possível carregar os temas.'));
  useEffect(() => { carregar(); }, []);

  const principais = useMemo(() => (temas ?? []).filter((t) => t.papel === 'nuclear'), [temas]);
  const opcionais = useMemo(() => (temas ?? []).filter((t) => t.papel !== 'nuclear' &&
    (filtro === '' || `${t.codigo} ${t.titulo} ${t.modulo}`.toLowerCase().includes(filtro.toLowerCase()))), [temas, filtro]);

  async function agendar(codigo: string) {
    const v = escolha[codigo]; if (!v) return;
    try { await apiPost(`/eng/temas/${codigo.replace('-', '')}/agendar`, { d0: new Date(v).toISOString() }); setMsg(`${codigo}: agendado. O pré-teste inicial já aparece em Testes.`); carregar(); }
    catch (e) {
      const cod = e instanceof Error && /422/.test(e.message) ? 'data_invalida' : '';
      setMsg(ERROS[cod] ?? 'Não foi possível agendar. Confira a data.');
    }
  }
  if (!temas) return <p className="carregando">{msg ?? 'Carregando…'}</p>;
  return (
    <section>
      <h1>Temas do programa</h1>
      {msg && <p className="faixa-aviso" role="status">{msg}</p>}
      <h2>Principais ({principais.length})</h2>
      <p>Uma reunião por semana, às quintas às 20h (Google Meet), na ordem de dificuldade.</p>
      <div className="tabela-rolavel"><table className="tabela">
        <thead><tr><th>#</th><th>Tema</th><th>Grau</th><th>Reunião</th><th>Testes feitos</th></tr></thead>
        <tbody>{principais.map((t) => (
          <tr key={t.codigo}>
            <td>{t.ordem}</td>
            <td>{t.tem_conteudo || t.codigo === 'T-001' ? <a href={`/aluno/testes/${t.codigo.replace('-', '')}`}>{t.codigo} {t.titulo}</a> : <span>{t.codigo} {t.titulo}</span>}</td>
            <td>{t.dificuldade}</td>
            <td>{t.data_d0 ? quando(t.data_d0) : 'a definir'}</td>
            <td>{t.testes_feitos}/6</td>
          </tr>))}</tbody>
      </table></div>
      <h2>Opcionais ({(temas ?? []).length - principais.length})</h2>
      <p>Escolha a data (D0) em que quer estudar o tema: o pré-teste abre 15 dias antes, o pré-teste 2 fecha 1 hora antes do D0 e os pós-testes seguem D+15, D+45 e D+90.</p>
      <input className="busca" placeholder="Buscar tema ou módulo" value={filtro} onChange={(e) => setFiltro(e.target.value)} aria-label="Buscar tema" />
      <div className="tabela-rolavel"><table className="tabela">
        <thead><tr><th>Tema</th><th>Módulo</th><th>Grau</th><th>Meu D0</th></tr></thead>
        <tbody>{opcionais.map((t) => (
          <tr key={t.codigo}>
            <td>{t.codigo} {t.titulo}{t.papel === 'complementar' && <span className="rotulo" style={{ marginLeft: 6 }}>recomendado</span>}</td>
            <td>{t.modulo}</td>
            <td>{t.dificuldade}</td>
            <td>{t.d0_proprio && t.data_d0 ? <span>{quando(t.data_d0)}{t.testes_feitos === 0 && ' · '}</span> : null}
              {t.testes_feitos === 0 && (
                <span className="agendar">
                  <input type="datetime-local" aria-label={`D0 de ${t.codigo}`} value={escolha[t.codigo] ?? ''} onChange={(e) => setEscolha({ ...escolha, [t.codigo]: e.target.value })} />
                  <button type="button" className="botao discreto" disabled={!escolha[t.codigo]} onClick={() => agendar(t.codigo)}>{t.d0_proprio ? 'Mudar' : 'Agendar'}</button>
                </span>)}
            </td>
          </tr>))}</tbody>
      </table></div>
      {!temas.some((t) => t.papel !== 'nuclear' && t.tem_conteudo) && <p className="faixa-aviso">O material dos temas opcionais ainda está em produção; o agendamento já fica registrado.</p>}
    </section>
  );
}
