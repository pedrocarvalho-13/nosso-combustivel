using NossoCombustivel.Application.Ia;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Api.Tests;

public class ConferenciaLeituraTests
{
    private static LeituraFoto Bomba(decimal? litros, decimal? preco, decimal? total) =>
        new(litros, preco, null, null, total, null, Combustivel.Gasolina);

    [Fact]
    public void Leitura_coerente_fica_como_esta()
    {
        var conferida = ConferenciaLeitura.Conferir(Bomba(40.5m, 6.19m, 250.70m), TipoLeitura.Abastecimento);

        Assert.Equal(40.5m, conferida.Litros);
        Assert.Equal(6.19m, conferida.PrecoLitro);
        Assert.Equal(250.70m, conferida.ValorTotal);
    }

    [Fact]
    public void Preco_sem_virgula_volta_para_a_faixa_de_reais()
    {
        var conferida = ConferenciaLeitura.Conferir(Bomba(40.5m, 6190m, 250.70m), TipoLeitura.Abastecimento);

        Assert.Equal(6.19m, conferida.PrecoLitro);
        Assert.Equal(40.5m, conferida.Litros);
    }

    [Fact]
    public void Litros_que_nao_batem_sao_recalculados_pelo_total_e_pelo_preco()
    {
        var conferida = ConferenciaLeitura.Conferir(Bomba(48.5m, 6.19m, 250.70m), TipoLeitura.Abastecimento);

        Assert.Equal(40.501m, conferida.Litros);
    }

    [Fact]
    public void Valor_que_faltou_e_calculado_pelos_outros_dois()
    {
        Assert.Equal(250.70m, ConferenciaLeitura.Conferir(Bomba(40.5m, 6.19m, null), TipoLeitura.Abastecimento).ValorTotal);
        Assert.Equal(40.501m, ConferenciaLeitura.Conferir(Bomba(null, 6.19m, 250.70m), TipoLeitura.Abastecimento).Litros);
        Assert.Equal(6.19m, ConferenciaLeitura.Conferir(Bomba(40.5m, null, 250.70m), TipoLeitura.Abastecimento).PrecoLitro);
    }

    [Fact]
    public void Na_recarga_vale_a_faixa_de_preco_do_kwh()
    {
        var lida = new LeituraFoto(null, null, 30m, 1.2m, 36m, null, null);

        var conferida = ConferenciaLeitura.Conferir(lida, TipoLeitura.Recarga);

        Assert.Equal(30m, conferida.Kwh);
        Assert.Equal(1.2m, conferida.PrecoKwh);
        Assert.Equal(36m, conferida.ValorTotal);
    }

    [Fact]
    public void Foto_do_hodometro_traz_so_a_quilometragem()
    {
        var lida = new LeituraFoto(40m, 6m, null, null, 240m, 52_318, Combustivel.Gasolina);

        var conferida = ConferenciaLeitura.Conferir(lida, TipoLeitura.Hodometro);

        Assert.Equal(new LeituraFoto(null, null, null, null, null, 52_318, null), conferida);
    }

    [Fact]
    public void Foto_da_bomba_nao_traz_hodometro()
    {
        var lida = new LeituraFoto(40.5m, 6.19m, null, null, 250.70m, 52_318, Combustivel.Gasolina);

        Assert.Null(ConferenciaLeitura.Conferir(lida, TipoLeitura.Abastecimento).Odometro);
    }
}
