using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Domain.Tests.Registros;

public class SincronizacaoDominioTests
{
    private static readonly DateTimeOffset Base = new(2026, 10, 29, 12, 0, 0, TimeSpan.Zero);

    private static DadosAbastecimento Dados(decimal litros = 40m, DateTimeOffset? atualizadoEm = null) =>
        new(Base, 48326, Combustivel.Etanol, litros, 4.19m, 167.60m, true, "Posto Avenida", atualizadoEm ?? Base, null);

    [Fact]
    public void Alteracao_mais_nova_vence()
    {
        var abastecimento = Abastecimento.Criar(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), Dados(), Base, Base);

        var aplicou = abastecimento.Aplicar(Dados(litros: 38.2m, atualizadoEm: Base.AddMinutes(5)), Base.AddMinutes(6));

        Assert.True(aplicou);
        Assert.Equal(38.2m, abastecimento.Litros);
    }

    [Fact]
    public void Alteracao_mais_antiga_e_ignorada()
    {
        var abastecimento = Abastecimento.Criar(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), Dados(atualizadoEm: Base.AddMinutes(5)), Base, Base);

        var aplicou = abastecimento.Aplicar(Dados(litros: 10m, atualizadoEm: Base), Base.AddMinutes(6));

        Assert.False(aplicou);
        Assert.Equal(40m, abastecimento.Litros);
    }

    [Fact]
    public void Litros_negativos_sao_recusados()
    {
        Assert.Throws<ExcecaoDeDominio>(() =>
            Abastecimento.Criar(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), Dados(litros: -1m), Base, Base));
    }

    [Fact]
    public void Carro_que_abastece_precisa_de_combustivel()
    {
        var dados = new DadosVeiculo("Civic", "Honda", "Civic", 2021, null, TipoEnergia.Combustao, [], 50m, null, 47000, Base, null);

        Assert.Throws<ExcecaoDeDominio>(() => Veiculo.Criar(Guid.NewGuid(), Guid.NewGuid(), dados, Base, Base));
    }

    [Fact]
    public void Carro_guarda_a_lista_de_combustiveis()
    {
        var dados = new DadosVeiculo("Civic", "Honda", "Civic", 2021, null, TipoEnergia.Combustao,
            [Combustivel.Gasolina, Combustivel.Etanol], 50m, null, 47000, Base, null);

        var veiculo = Veiculo.Criar(Guid.NewGuid(), Guid.NewGuid(), dados, Base, Base);

        Assert.Equal([Combustivel.Gasolina, Combustivel.Etanol], veiculo.ListaCombustiveis);
    }
}
