using NossoCombustivel.Domain.ObjetosDeValor;

namespace NossoCombustivel.Domain.Tests.ObjetosDeValor;

public class OdometroTests
{
    [Fact]
    public void Nao_aceita_leitura_negativa()
    {
        Assert.Throws<ExcecaoDeDominio>(() => new Odometro(-1));
    }

    [Fact]
    public void Calcula_distancia_desde_a_leitura_anterior()
    {
        var anterior = new Odometro(47_982);
        var atual = new Odometro(48_326);

        Assert.Equal(344, atual.DistanciaDesde(anterior));
    }

    [Fact]
    public void Nao_aceita_leitura_menor_que_a_anterior()
    {
        var anterior = new Odometro(48_326);
        var atual = new Odometro(47_982);

        Assert.Throws<ExcecaoDeDominio>(() => atual.DistanciaDesde(anterior));
    }
}
