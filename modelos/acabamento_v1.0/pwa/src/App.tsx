import { Routes, Route, Navigate } from 'react-router-dom';
import { SessaoProvider, REVISORES } from './lib/sessao.js';
import { Layout } from './components/Layout.js';
import { Login } from './pages/Login.js';
import { Inicio } from './pages/Inicio.js';
import { AlunoHome } from './pages/aluno/Home.js';
import { Leitura } from './pages/aluno/Leitura.js';
import { Testes } from './pages/aluno/Testes.js';
import { Contato } from './pages/aluno/Contato.js';
import { PreceptorHome } from './pages/preceptor/Home.js';
import { CuradorHome } from './pages/curador/Home.js';
import { CuradorRevisao } from './pages/curador/Revisao.js';
import { PesquisaHome } from './pages/pesquisa/Home.js';

export function App() {
  return (
    <SessaoProvider>
      <Routes>
        <Route path="/" element={<Inicio />} />
        <Route path="/login" element={<Login />} />
        <Route path="/aluno/contato" element={<Layout proteger={false}><Contato /></Layout>} />
        <Route path="/aluno/testes/*" element={<Layout><Testes /></Layout>} />
        <Route path="/aluno/leitura/*" element={<Layout><Leitura /></Layout>} />
        <Route path="/aluno/*" element={<Layout><AlunoHome /></Layout>} />
        <Route path="/curador/previa/*" element={<Layout papeis={REVISORES}><Leitura /></Layout>} />
        <Route path="/curador/revisao/*" element={<Layout papeis={REVISORES}><CuradorRevisao /></Layout>} />
        <Route path="/curador/*" element={<Layout papeis={REVISORES} proteger={false}><CuradorHome /></Layout>} />
        <Route path="/preceptor/*" element={<Layout proteger={false}><PreceptorHome /></Layout>} />
        <Route path="/pesquisa/*" element={<Layout proteger={false}><PesquisaHome /></Layout>} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </SessaoProvider>
  );
}
