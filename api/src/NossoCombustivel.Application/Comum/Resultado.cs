namespace NossoCombustivel.Application.Comum;

public enum TipoErro
{
    Validacao,
    Conflito,
    NaoAutorizado,
    NaoEncontrado,
    Indisponivel
}

public sealed record ErroAplicacao(TipoErro Tipo, string Mensagem);

public sealed class Resultado<T>
{
    private Resultado(T? valor, ErroAplicacao? erro)
    {
        Valor = valor;
        Erro = erro;
    }

    public T? Valor { get; }
    public ErroAplicacao? Erro { get; }
    public bool Sucesso => Erro is null;

    public static Resultado<T> Ok(T valor) => new(valor, null);

    public static Resultado<T> Falha(TipoErro tipo, string mensagem) => new(default, new ErroAplicacao(tipo, mensagem));

    public static Resultado<T> Falha(ErroAplicacao erro) => new(default, erro);
}
