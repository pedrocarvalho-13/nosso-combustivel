namespace NossoCombustivel.Domain.ObjetosDeValor;

public sealed record Dinheiro
{
    public static readonly Dinheiro Zero = new(0m);

    public decimal Valor { get; }

    public Dinheiro(decimal valor)
    {
        if (valor < 0)
            throw new ExcecaoDeDominio("Um valor em dinheiro não pode ser negativo.");

        Valor = decimal.Round(valor, 2, MidpointRounding.AwayFromZero);
    }

    public static Dinheiro operator +(Dinheiro a, Dinheiro b) => new(a.Valor + b.Valor);
}
