using System.Globalization;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NossoCombustivel.Application.Postos;
using NossoCombustivel.Domain.Postos;

namespace NossoCombustivel.Infrastructure.Postos;

public sealed class OpcoesOverpass
{
    public const string Secao = "Overpass";

    public string[] Enderecos { get; set; } =
    [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.private.coffee/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter"
    ];

    public int SegundosPorTentativa { get; set; } = 10;
    public int SegundosNoTotal { get; set; } = 25;
}

public sealed class BuscaPostosOverpass(HttpClient http, IOptions<OpcoesOverpass> opcoes, ILogger<BuscaPostosOverpass> log) : IBuscaPostos
{
    private static readonly TimeSpan EsperaEntreTentativas = TimeSpan.FromSeconds(1);

    public OrigemPosto Origem => OrigemPosto.OpenStreetMap;

    public async Task<IReadOnlyList<PostoEncontrado>> BuscarProximosAsync(
        double latitude, double longitude, int raioMetros, CancellationToken cancelamento)
    {
        var consulta = Consulta(latitude, longitude, raioMetros);
        var config = opcoes.Value;
        using var prazo = CancellationTokenSource.CreateLinkedTokenSource(cancelamento);
        prazo.CancelAfter(TimeSpan.FromSeconds(config.SegundosNoTotal));

        for (var tentativa = 0; !prazo.IsCancellationRequested; tentativa++)
        {
            var endereco = config.Enderecos[tentativa % config.Enderecos.Length];
            using var limite = CancellationTokenSource.CreateLinkedTokenSource(prazo.Token);
            limite.CancelAfter(TimeSpan.FromSeconds(config.SegundosPorTentativa));
            try
            {
                using var resposta = await http.PostAsync(endereco,
                    new FormUrlEncodedContent([new KeyValuePair<string, string>("data", consulta)]), limite.Token);
                if (resposta.IsSuccessStatusCode)
                {
                    await using var corpo = await resposta.Content.ReadAsStreamAsync(limite.Token);
                    using var json = await JsonDocument.ParseAsync(corpo, cancellationToken: limite.Token);
                    return Ler(json.RootElement);
                }
                log.LogWarning("Overpass {Endereco} respondeu {Status}", endereco, (int)resposta.StatusCode);
            }
            catch (Exception erro) when (erro is HttpRequestException or JsonException or OperationCanceledException
                                             && !cancelamento.IsCancellationRequested)
            {
                log.LogWarning("Overpass {Endereco} falhou: {Erro}", endereco, erro.GetType().Name);
            }

            try
            {
                await Task.Delay(EsperaEntreTentativas, prazo.Token);
            }
            catch (OperationCanceledException) when (!cancelamento.IsCancellationRequested)
            {
            }
        }

        cancelamento.ThrowIfCancellationRequested();
        throw new BuscaPostosIndisponivelException();
    }

    public static string Consulta(double latitude, double longitude, int raioMetros)
    {
        var grausLatitude = raioMetros / 111_320d;
        var grausLongitude = raioMetros / (111_320d * Math.Max(Math.Cos(latitude * Math.PI / 180), 0.01));
        return string.Create(CultureInfo.InvariantCulture,
            $"[out:json][timeout:25][bbox:{latitude - grausLatitude:F5},{longitude - grausLongitude:F5},{latitude + grausLatitude:F5},{longitude + grausLongitude:F5}];nwr[\"amenity\"=\"fuel\"];out center tags;");
    }

    public static IReadOnlyList<PostoEncontrado> Ler(JsonElement raiz)
    {
        var postos = new List<PostoEncontrado>();
        if (!raiz.TryGetProperty("elements", out var elementos))
            return postos;

        foreach (var elemento in elementos.EnumerateArray())
        {
            var tipo = elemento.GetProperty("type").GetString();
            var id = elemento.GetProperty("id").GetInt64();
            var coordenadas = elemento.TryGetProperty("center", out var centro) ? centro : elemento;
            if (!coordenadas.TryGetProperty("lat", out var lat) || !coordenadas.TryGetProperty("lon", out var lon))
                continue;

            var tags = elemento.TryGetProperty("tags", out var t) ? t : default;
            var bandeira = Tag(tags, "brand") ?? Tag(tags, "operator");
            var nome = Tag(tags, "name") ?? bandeira ?? "Posto sem nome";
            postos.Add(new PostoEncontrado(
                OrigemPosto.OpenStreetMap,
                $"{tipo}/{id}",
                nome,
                bandeira,
                Endereco(tags),
                lat.GetDouble(),
                lon.GetDouble()));
        }
        return postos;
    }

    private static string? Endereco(JsonElement tags)
    {
        var rua = Tag(tags, "addr:street");
        if (rua is null)
            return null;
        var numero = Tag(tags, "addr:housenumber");
        var bairro = Tag(tags, "addr:suburb");
        var endereco = numero is null ? rua : $"{rua}, {numero}";
        return bairro is null ? endereco : $"{endereco} - {bairro}";
    }

    private static string? Tag(JsonElement tags, string nome) =>
        tags.ValueKind == JsonValueKind.Object && tags.TryGetProperty(nome, out var valor) && !string.IsNullOrWhiteSpace(valor.GetString())
            ? valor.GetString()!.Trim()
            : null;
}
