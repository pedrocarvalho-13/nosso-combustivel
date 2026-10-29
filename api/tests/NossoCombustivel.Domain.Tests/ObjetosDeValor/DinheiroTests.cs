using NossoCombustivel.Domain.ObjetosDeValor;

namespace NossoCombustivel.Domain.Tests.ObjetosDeValor;

public class DinheiroTests
{
    [Fact]
    public void Nao_aceita_valor_negativo()
    {
        Assert.Throws<ExcecaoDeDominio>(() => new Dinheiro(-0.01m));
    }

    [Fact]
    public void Arredonda_para_centavos()
    {
        Assert.Equal(160.06m, new Dinheiro(160.058m).Valor);
    }

    [Fact]
    public void Soma_dois_valores()
    {
        var total = new Dinheiro(160.06m) + new Dinheiro(157.25m);

        Assert.Equal(317.31m, total.Valor);
    }
}
