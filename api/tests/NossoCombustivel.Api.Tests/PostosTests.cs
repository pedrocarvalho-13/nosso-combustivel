using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using NossoCombustivel.Api.Endpoints;
using NossoCombustivel.Application.Postos;
using NossoCombustivel.Application.Sincronizacao;
using NossoCombustivel.Domain.Postos;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;
using NossoCombustivel.Infrastructure.Postos;

namespace NossoCombustivel.Api.Tests;

public sealed class BuscaPostosFalsa : IBuscaPostos
{
    public int Chamadas { get; private set; }
    public bool Fora { get; set; }
    public List<PostoEncontrado> Postos { get; } = [];

    public OrigemPosto Origem => OrigemPosto.OpenStreetMap;

    public Task<IReadOnlyList<PostoEncontrado>> BuscarProximosAsync(
        TipoPosto tipo, double latitude, double longitude, int raioMetros, CancellationToken cancelamento)
    {
        Chamadas++;
        if (Fora) throw new BuscaPostosIndisponivelException();
        return Task.FromResult<IReadOnlyList<PostoEncontrado>>(Postos.Where(p => p.Tipo == tipo).ToList());
    }
}

public sealed class FabricaApiComPostos : IDisposable
{
    public BuscaPostosFalsa Busca { get; } = new();
    public FabricaApi Fabrica { get; } = new();

    public HttpClient CriarCliente() => Fabrica
        .WithWebHostBuilder(builder => builder.ConfigureServices(services =>
        {
            services.RemoveAll<IBuscaPostos>();
            services.AddSingleton<IBuscaPostos>(Busca);
        }))
        .CreateClient();

    public void Dispose() => Fabrica.Dispose();
}

public class PostosTests(FabricaApiComPostos fabrica) : IClassFixture<FabricaApiComPostos>
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase) }
    };

    private async Task<HttpClient> ClienteLogadoAsync()
    {
        var cliente = fabrica.CriarCliente();
        var resposta = await cliente.PostAsJsonAsync("/contas",
            new CadastroRequisicao("Pedro", $"postos-{Guid.NewGuid():N}@exemplo.com", "senha123"));
        var sessao = (await resposta.Content.ReadFromJsonAsync<SessaoResposta>())!;
        cliente.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", sessao.TokenAcesso);
        return cliente;
    }

    private static PostoEncontrado Encontrado(
        string id, string nome, double latitude, double longitude, string? bandeira = null, TipoPosto tipo = TipoPosto.Combustivel) =>
        new(tipo, OrigemPosto.OpenStreetMap, id, nome, bandeira, null, latitude, longitude);

    private static async Task<PostosProximos> ProximosAsync(
        HttpClient cliente, double latitude, double longitude, int raio = 1500, string tipo = "combustivel")
    {
        var url = FormattableString.Invariant($"/postos/proximos?lat={latitude}&lng={longitude}&raio={raio}&tipo={tipo}");
        return (await cliente.GetFromJsonAsync<PostosProximos>(url, Json))!;
    }

    [Fact]
    public async Task Postos_exigem_login()
    {
        var resposta = await fabrica.CriarCliente().GetAsync("/postos/proximos?lat=-23.5&lng=-46.6");
        Assert.Equal(HttpStatusCode.Unauthorized, resposta.StatusCode);
    }

    [Fact]
    public async Task Proximos_vem_ordenados_pela_distancia_e_a_mesma_area_nao_busca_de_novo()
    {
        var cliente = await ClienteLogadoAsync();
        fabrica.Busca.Postos.Clear();
        fabrica.Busca.Postos.AddRange([
            Encontrado("node/2", "Posto Longe", -10.0090, -40.0000),
            Encontrado("node/1", "Posto Perto", -10.0010, -40.0000, "Shell") with { Horario = "Mo-Su 06:00-22:00" },
            Encontrado("node/3", "Fora do raio", -10.0500, -40.0000)
        ]);
        var antes = fabrica.Busca.Chamadas;

        var primeira = await ProximosAsync(cliente, -10.0, -40.0);
        var segunda = await ProximosAsync(cliente, -10.0, -40.0);

        Assert.True(primeira.BuscaCompleta);
        Assert.Equal(["Posto Perto", "Posto Longe"], primeira.Postos.Select(p => p.Nome));
        Assert.Equal("Shell", primeira.Postos[0].Bandeira);
        Assert.Equal("Mo-Su 06:00-22:00", primeira.Postos[0].Horario);
        Assert.InRange(primeira.Postos[0].DistanciaMetros, 100, 120);
        Assert.Equal(primeira.Postos.Select(p => p.Id), segunda.Postos.Select(p => p.Id));
        Assert.Equal(antes + 1, fabrica.Busca.Chamadas);
    }

    [Fact]
    public async Task Busca_fora_do_ar_ainda_devolve_o_que_ja_esta_no_banco()
    {
        var cliente = await ClienteLogadoAsync();
        var cadastrado = await cliente.PostAsJsonAsync("/postos", new CadastroPostoRequisicao("Auto Posto da Esquina", "Ipiranga", -11.0, -41.0), Json);
        fabrica.Busca.Fora = true;

        try
        {
            var proximos = await ProximosAsync(cliente, -11.0, -41.0);

            Assert.Equal(HttpStatusCode.OK, cadastrado.StatusCode);
            Assert.False(proximos.BuscaCompleta);
            Assert.Equal("Auto Posto da Esquina", proximos.Postos.Single().Nome);
        }
        finally
        {
            fabrica.Busca.Fora = false;
        }
    }

    [Fact]
    public async Task Cadastro_repetido_no_mesmo_lugar_devolve_o_mesmo_posto()
    {
        var cliente = await ClienteLogadoAsync();

        var primeiro = await (await cliente.PostAsJsonAsync("/postos", new CadastroPostoRequisicao("Posto Boa Viagem", null, -12.0, -42.0), Json))
            .Content.ReadFromJsonAsync<PostoProximo>(Json);
        var segundo = await (await cliente.PostAsJsonAsync("/postos", new CadastroPostoRequisicao(" posto  boa viagem ", null, -12.0002, -42.0), Json))
            .Content.ReadFromJsonAsync<PostoProximo>(Json);

        Assert.Equal(primeiro!.Id, segundo!.Id);
    }

    [Fact]
    public async Task Cadastro_sem_nome_e_recusado()
    {
        var cliente = await ClienteLogadoAsync();

        var resposta = await cliente.PostAsJsonAsync("/postos", new CadastroPostoRequisicao("  ", null, -13.0, -43.0), Json);

        Assert.Equal(HttpStatusCode.BadRequest, resposta.StatusCode);
    }

    [Fact]
    public async Task Abastecimento_com_posto_desce_com_o_posto_na_sincronizacao()
    {
        var cliente = await ClienteLogadoAsync();
        var posto = await (await cliente.PostAsJsonAsync("/postos", new CadastroPostoRequisicao("Posto do Sync", "BR", -14.0, -44.0), Json))
            .Content.ReadFromJsonAsync<PostoProximo>(Json);
        var carroId = Guid.CreateVersion7();
        var quando = new DateTimeOffset(2026, 10, 31, 12, 0, 0, TimeSpan.Zero);
        var carro = new VeiculoSync(carroId, "Celta", "GM", "Celta", 2010, null, TipoEnergia.Combustao,
            [Combustivel.Gasolina], 54m, null, 90000, quando, quando, null);
        var abastecimento = new AbastecimentoSync(Guid.CreateVersion7(), carroId, quando, 90100, Combustivel.Gasolina,
            20m, 6.5m, 130m, false, null, quando, quando, null, PostoId: posto!.Id, TipoGasolina: TipoGasolina.Aditivada);

        await cliente.PostAsJsonAsync("/sync", new LoteSync([carro], [abastecimento], []), Json);
        var busca = (await cliente.GetFromJsonAsync<RespostaBusca>("/sync", Json))!;

        Assert.Equal(posto.Id, busca.Alteracoes.Abastecimentos.Single().PostoId);
        Assert.Equal("Posto do Sync", busca.Alteracoes.Postos!.Single().Nome);

        var proximos = await ProximosAsync(cliente, -14.0, -44.0);
        var preco = proximos.Postos.Single().Precos!.Single();
        Assert.Equal((Combustivel.Gasolina, 6.5m, TipoGasolina.Aditivada), (preco.Combustivel, preco.PrecoLitro, preco.TipoGasolina));
        Assert.Equal(TipoGasolina.Aditivada, busca.Alteracoes.Abastecimentos.Single().TipoGasolina);
    }

    [Fact]
    public void Overpass_le_postos_com_nome_bandeira_endereco_e_centro_de_area()
    {
        using var json = JsonDocument.Parse("""
            {"elements":[
              {"type":"node","id":10,"lat":-23.5,"lon":-46.6,"tags":{"amenity":"fuel","name":"Posto Sol","brand":"Shell","addr:street":"Rua A","addr:housenumber":"12","addr:suburb":"Centro"}},
              {"type":"way","id":20,"center":{"lat":-23.51,"lon":-46.61},"tags":{"amenity":"fuel","operator":"Petrobras"}},
              {"type":"node","id":30,"lat":-23.52,"lon":-46.62}
            ]}
            """);

        var postos = BuscaPostosOverpass.Ler(json.RootElement);

        Assert.Equal(3, postos.Count);
        Assert.Equal(new PostoEncontrado(TipoPosto.Combustivel, OrigemPosto.OpenStreetMap, "node/10", "Posto Sol", "Shell", "Rua A, 12 - Centro", -23.5, -46.6), postos[0]);
        Assert.Equal(("way/20", "Petrobras", -23.51), (postos[1].IdExterno, postos[1].Nome, postos[1].Latitude));
        Assert.Equal("Posto sem nome", postos[2].Nome);
    }

    [Fact]
    public void Nominatim_le_postos_com_bandeira_e_endereco()
    {
        using var json = JsonDocument.Parse("""
            [
              {"osm_type":"way","osm_id":414735742,"lat":"-23.5601","lon":"-46.6550","name":"Ipiranga",
               "address":{"road":"Rua Augusta","house_number":"100","suburb":"Consolação"},"extratags":{"brand":"Ipiranga","opening_hours":"24/7"}},
              {"osm_type":"node","osm_id":5,"lat":"-23.57","lon":"-46.66","extratags":{"operator":"Petrobras"}},
              {"osm_type":"node","osm_id":6,"lat":"x","lon":"-46.66"}
            ]
            """);

        var postos = BuscaPostosNominatim.Ler(json.RootElement);

        Assert.Equal(2, postos.Count);
        Assert.Equal(new PostoEncontrado(TipoPosto.Combustivel, OrigemPosto.OpenStreetMap, "way/414735742", "Ipiranga", "Ipiranga", "Rua Augusta, 100 - Consolação", -23.5601, -46.6550, "24/7"), postos[0]);
        Assert.Equal(("node/5", "Petrobras", null), (postos[1].IdExterno, postos[1].Nome, postos[1].Endereco));
    }

    [Fact]
    public async Task Eletropostos_e_postos_de_combustivel_vem_separados()
    {
        var cliente = await ClienteLogadoAsync();
        fabrica.Busca.Postos.Clear();
        fabrica.Busca.Postos.AddRange([
            Encontrado("node/50", "Posto Gasolina", -15.0010, -45.0000),
            Encontrado("node/51", "Carregador Rapido", -15.0020, -45.0000, tipo: TipoPosto.Eletroposto)
        ]);

        var combustivel = await ProximosAsync(cliente, -15.0, -45.0);
        var eletro = await ProximosAsync(cliente, -15.0, -45.0, tipo: "eletroposto");

        Assert.Equal(["Posto Gasolina"], combustivel.Postos.Select(p => p.Nome));
        Assert.Equal(["Carregador Rapido"], eletro.Postos.Select(p => p.Nome));
    }
}
