// Conferencia de formato da peca, so na previa dos revisores: erros impedem a publicacao; avisos nao.
// As regras estao em docs/formato_das_pecas.md e no banco (conteudo.conferir_formato).
interface Item { gravidade: 'erro' | 'aviso'; mensagem: string }

export function FormatoPeca(props: { itens?: Item[] | null }) {
  const itens = props.itens ?? [];
  const erros = itens.filter((i) => i.gravidade === 'erro');
  const avisos = itens.filter((i) => i.gravidade === 'aviso');
  if (!itens.length) return <p className="formato ok" role="status">Formato conferido: a peça segue o padrão.</p>;
  return (
    <div className={`formato ${erros.length ? 'erro' : 'aviso'}`} role="status">
      <strong>{erros.length ? `Não pode ser publicada: ${erros.length} erro${erros.length > 1 ? 's' : ''} de formato` : 'Formato com avisos (pode publicar)'}</strong>
      <ul>
        {erros.map((e, k) => <li key={`e${k}`}><span className="formato-tipo">Erro</span> {e.mensagem}</li>)}
        {avisos.map((e, k) => <li key={`a${k}`}><span className="formato-tipo">Aviso</span> {e.mensagem}</li>)}
      </ul>
    </div>
  );
}
