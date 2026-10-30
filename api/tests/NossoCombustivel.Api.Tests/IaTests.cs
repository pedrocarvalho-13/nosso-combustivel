using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using NossoCombustivel.Api.Endpoints;
using NossoCombustivel.Application.Ia;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Api.Tests;

public sealed class AssistenteFalso : IAssistenteIa
{
    public int ChamadasCapacidade { get; private set; }
    public bool Disponivel { get; set; } = true;
    public bool Ocupada { get; set; }
    public CapacidadeEstimada? Capacidade { get; set; } = new(55m, null);
    public LeituraFoto? Leitura { get; set; } = new(40.5m, 6.19m, null, null, 250.70m, null, Combustivel.Gasolina);

    public Task<CapacidadeEstimada?> EstimarCapacidadeAsync(VeiculoConsultado veiculo, CancellationToken cancelamento)
    {
        ChamadasCapacidade++;
        return Task.FromResult(Capacidade);
    }

    public Task<LeituraFoto?> LerFotoAsync(byte[] imagem, string tipoMime, TipoLeitura tipo, CancellationToken cancelamento) =>
        Ocupada ? throw new IaIndisponivelException() : Task.FromResult(Leitura);
}

public sealed class FabricaApiComIa : IDisposable
{
    public AssistenteFalso Assistente { get; } = new();
    public FabricaApi Fabrica { get; }

    public FabricaApiComIa()
    {
        Fabrica = new FabricaApi();
    }

    public HttpClient CriarCliente() => Fabrica
        .WithWebHostBuilder(builder => builder.ConfigureServices(services =>
        {
            services.RemoveAll<IAssistenteIa>();
            services.AddSingleton<IAssistenteIa>(Assistente);
        }))
        .CreateClient();

    public void Dispose() => Fabrica.Dispose();
}

public class IaTests(FabricaApiComIa fabrica) : IClassFixture<FabricaApiComIa>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) }
    };

    private async Task<HttpClient> ClienteLogadoAsync()
    {
        var cliente = fabrica.CriarCliente();
        var resposta = await cliente.PostAsJsonAsync("/contas",
            new CadastroRequisicao("Pedro", $"ia-{Guid.NewGuid():N}@exemplo.com", "senha123"));
        var sessao = (await resposta.Content.ReadFromJsonAsync<SessaoResposta>())!;
        cliente.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", sessao.TokenAcesso);
        return cliente;
    }

    private static CapacidadeRequisicao Onix(string codigoFipe) =>
        new(TipoVeiculo.Carro, "GM - Chevrolet", "Onix 1.0 Turbo", 2024, codigoFipe, TipoEnergia.Combustao);

    [Fact]
    public async Task Capacidade_exige_login()
    {
        var resposta = await fabrica.CriarCliente().PostAsJsonAsync("/ia/capacidade", Onix("004466-1"), Json);
        Assert.Equal(HttpStatusCode.Unauthorized, resposta.StatusCode);
    }

    [Fact]
    public async Task Capacidade_repetida_vem_do_banco_sem_chamar_a_ia_de_novo()
    {
        var cliente = await ClienteLogadoAsync();
        var antes = fabrica.Assistente.ChamadasCapacidade;

        var primeira = await cliente.PostAsJsonAsync("/ia/capacidade", Onix("004466-2"), Json);
        var segunda = await cliente.PostAsJsonAsync("/ia/capacidade", Onix("004466-2"), Json);

        Assert.Equal(HttpStatusCode.OK, primeira.StatusCode);
        Assert.Equal(HttpStatusCode.OK, segunda.StatusCode);
        var corpo = await segunda.Content.ReadFromJsonAsync<CapacidadeResposta>(Json);
        Assert.Equal(55m, corpo!.CapacidadeTanqueL);
        Assert.Null(corpo.CapacidadeBateriaKwh);
        Assert.Equal(antes + 1, fabrica.Assistente.ChamadasCapacidade);
    }

    [Fact]
    public async Task Sem_fipe_a_mesma_marca_e_modelo_escritos_diferente_usam_o_banco()
    {
        var cliente = await ClienteLogadoAsync();
        var antes = fabrica.Assistente.ChamadasCapacidade;

        await cliente.PostAsJsonAsync("/ia/capacidade",
            new CapacidadeRequisicao(TipoVeiculo.Moto, "Honda", "CG 160 Titan", 2023, null, TipoEnergia.Combustao), Json);
        var segunda = await cliente.PostAsJsonAsync("/ia/capacidade",
            new CapacidadeRequisicao(TipoVeiculo.Moto, " honda ", "cg  160 titan", 2023, null, TipoEnergia.Combustao), Json);

        Assert.Equal(HttpStatusCode.OK, segunda.StatusCode);
        Assert.Equal(antes + 1, fabrica.Assistente.ChamadasCapacidade);
    }

    [Fact]
    public async Task Leitura_de_foto_devolve_os_valores()
    {
        var cliente = await ClienteLogadoAsync();
        var foto = Convert.ToBase64String([1, 2, 3, 4]);

        var resposta = await cliente.PostAsJsonAsync("/ia/leitura",
            new LeituraRequisicao(TipoLeitura.Abastecimento, foto, "image/jpeg"), Json);

        Assert.Equal(HttpStatusCode.OK, resposta.StatusCode);
        var leitura = await resposta.Content.ReadFromJsonAsync<LeituraFoto>(Json);
        Assert.Equal(40.5m, leitura!.Litros);
        Assert.Equal(Combustivel.Gasolina, leitura.Combustivel);
    }

    [Fact]
    public async Task Leitura_recusa_formato_que_nao_e_imagem()
    {
        var cliente = await ClienteLogadoAsync();

        var resposta = await cliente.PostAsJsonAsync("/ia/leitura",
            new LeituraRequisicao(TipoLeitura.Abastecimento, Convert.ToBase64String([1]), "application/pdf"), Json);

        Assert.Equal(HttpStatusCode.BadRequest, resposta.StatusCode);
    }

    [Fact]
    public async Task Leitura_com_a_ia_ocupada_avisa_para_tentar_de_novo()
    {
        var cliente = await ClienteLogadoAsync();
        fabrica.Assistente.Ocupada = true;
        try
        {
            var resposta = await cliente.PostAsJsonAsync("/ia/leitura",
                new LeituraRequisicao(TipoLeitura.Abastecimento, Convert.ToBase64String([1, 2]), "image/jpeg"), Json);

            Assert.Equal(HttpStatusCode.ServiceUnavailable, resposta.StatusCode);
            Assert.Contains("ocupada", await resposta.Content.ReadAsStringAsync());
        }
        finally
        {
            fabrica.Assistente.Ocupada = false;
        }
    }
}
