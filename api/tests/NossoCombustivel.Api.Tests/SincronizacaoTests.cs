using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using NossoCombustivel.Api.Endpoints;
using NossoCombustivel.Application.Sincronizacao;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Api.Tests;

public class SincronizacaoTests(FabricaApi fabrica) : IClassFixture<FabricaApi>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) }
    };

    private static readonly DateTimeOffset Base = new(2026, 10, 29, 12, 0, 0, TimeSpan.Zero);

    private async Task<HttpClient> ClienteLogadoAsync()
    {
        var cliente = fabrica.CreateClient();
        var resposta = await cliente.PostAsJsonAsync("/contas",
            new CadastroRequisicao("Pedro", $"sync-{Guid.NewGuid():N}@exemplo.com", "senha123"));
        var sessao = (await resposta.Content.ReadFromJsonAsync<SessaoResposta>())!;
        cliente.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", sessao.TokenAcesso);
        return cliente;
    }

    private static VeiculoSync Carro(Guid id, string apelido = "Meu Hilux", DateTimeOffset? atualizadoEm = null) => new(
        id, apelido, "Toyota", "Hilux CD SRX 2.8 Diesel", 2024, "002165-4", TipoEnergia.Combustao,
        [Combustivel.DieselS10, Combustivel.DieselS500], 80m, null, 32540, Base, atualizadoEm ?? Base, null);

    private static AbastecimentoSync Abastecimento(Guid id, Guid veiculoId, decimal litros = 60m) => new(
        id, veiculoId, Base, 32600, Combustivel.DieselS10, litros, 6.09m, 365.40m, true, null, Base, Base, null);

    private static async Task<RespostaEnvio> EnviarAsync(HttpClient cliente, LoteSync lote)
    {
        var resposta = await cliente.PostAsJsonAsync("/sync", lote, Json);
        Assert.Equal(HttpStatusCode.OK, resposta.StatusCode);
        return (await resposta.Content.ReadFromJsonAsync<RespostaEnvio>(Json))!;
    }

    private static async Task<RespostaBusca> BuscarAsync(HttpClient cliente, DateTimeOffset? desde = null)
    {
        var url = desde is null ? "/sync" : $"/sync?desde={Uri.EscapeDataString(desde.Value.ToString("O"))}";
        return (await cliente.GetFromJsonAsync<RespostaBusca>(url, Json))!;
    }

    [Fact]
    public async Task Sincronizacao_exige_login()
    {
        var resposta = await fabrica.CreateClient().GetAsync("/sync");

        Assert.Equal(HttpStatusCode.Unauthorized, resposta.StatusCode);
    }

    [Fact]
    public async Task O_que_sobe_de_um_aparelho_desce_no_outro()
    {
        var cliente = await ClienteLogadoAsync();
        var carroId = Guid.CreateVersion7();

        var envio = await EnviarAsync(cliente, new LoteSync([Carro(carroId)], [Abastecimento(Guid.CreateVersion7(), carroId)], []));
        var busca = await BuscarAsync(cliente);

        Assert.Empty(envio.Rejeitados);
        Assert.Equal("Meu Hilux", busca.Alteracoes.Veiculos.Single().Apelido);
        Assert.Equal([Combustivel.DieselS10, Combustivel.DieselS500], busca.Alteracoes.Veiculos.Single().Combustiveis);
        Assert.Equal(365.40m, busca.Alteracoes.Abastecimentos.Single().ValorTotal);
    }

    [Fact]
    public async Task Moto_sobe_e_desce_como_moto()
    {
        var cliente = await ClienteLogadoAsync();
        var motoId = Guid.CreateVersion7();
        var moto = Carro(motoId, "CG do dia a dia") with { TipoVeiculo = TipoVeiculo.Moto, Combustiveis = [Combustivel.Gasolina] };

        await EnviarAsync(cliente, new LoteSync([moto], [], []));
        var busca = await BuscarAsync(cliente);

        Assert.Equal(TipoVeiculo.Moto, busca.Alteracoes.Veiculos.Single().TipoVeiculo);
    }

    [Fact]
    public async Task Busca_com_cursor_traz_so_o_que_mudou_depois()
    {
        var cliente = await ClienteLogadoAsync();
        var carroId = Guid.CreateVersion7();
        await EnviarAsync(cliente, new LoteSync([Carro(carroId)], [], []));
        var primeira = await BuscarAsync(cliente);

        await Task.Delay(TimeSpan.FromMilliseconds(50));
        var segunda = await BuscarAsync(cliente, primeira.Cursor.AddSeconds(10));

        Assert.Single(primeira.Alteracoes.Veiculos);
        Assert.Empty(segunda.Alteracoes.Veiculos);
    }

    [Fact]
    public async Task Alteracao_mais_antiga_nao_sobrescreve_a_mais_nova()
    {
        var cliente = await ClienteLogadoAsync();
        var carroId = Guid.CreateVersion7();
        await EnviarAsync(cliente, new LoteSync([Carro(carroId, "Nome novo", Base.AddMinutes(10))], [], []));

        await EnviarAsync(cliente, new LoteSync([Carro(carroId, "Nome antigo", Base.AddMinutes(1))], [], []));
        var busca = await BuscarAsync(cliente);

        Assert.Equal("Nome novo", busca.Alteracoes.Veiculos.Single().Apelido);
    }

    [Fact]
    public async Task Registro_invalido_e_recusado_sem_travar_os_outros()
    {
        var cliente = await ClienteLogadoAsync();
        var carroId = Guid.CreateVersion7();
        var invalido = Guid.CreateVersion7();

        var envio = await EnviarAsync(cliente, new LoteSync(
            [Carro(carroId)],
            [Abastecimento(Guid.CreateVersion7(), carroId), Abastecimento(invalido, carroId, litros: -5m)],
            []));
        var busca = await BuscarAsync(cliente);

        Assert.Equal(invalido, envio.Rejeitados.Single().Id);
        Assert.Single(busca.Alteracoes.Abastecimentos);
    }

    [Fact]
    public async Task Uma_conta_nao_ve_nem_altera_o_carro_da_outra()
    {
        var dono = await ClienteLogadoAsync();
        var intruso = await ClienteLogadoAsync();
        var carroId = Guid.CreateVersion7();
        await EnviarAsync(dono, new LoteSync([Carro(carroId)], [], []));

        var envio = await EnviarAsync(intruso, new LoteSync(
            [Carro(carroId, "Roubado", Base.AddHours(1))],
            [Abastecimento(Guid.CreateVersion7(), carroId)],
            []));
        var buscaIntruso = await BuscarAsync(intruso);
        var buscaDono = await BuscarAsync(dono);

        Assert.Equal(2, envio.Rejeitados.Count);
        Assert.Empty(buscaIntruso.Alteracoes.Veiculos);
        Assert.Equal("Meu Hilux", buscaDono.Alteracoes.Veiculos.Single().Apelido);
        Assert.Empty(buscaDono.Alteracoes.Abastecimentos);
    }
}
