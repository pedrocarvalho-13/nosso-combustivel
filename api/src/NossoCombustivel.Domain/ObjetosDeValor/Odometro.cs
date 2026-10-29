namespace NossoCombustivel.Domain.ObjetosDeValor;

public sealed record Odometro
{
    public int Km { get; }

    public Odometro(int km)
    {
        if (km < 0)
            throw new ExcecaoDeDominio("O odômetro não pode ser negativo.");

        Km = km;
    }

    public int DistanciaDesde(Odometro anterior)
    {
        if (anterior.Km > Km)
            throw new ExcecaoDeDominio("A leitura do odômetro não pode ser menor que a anterior.");

        return Km - anterior.Km;
    }
}
