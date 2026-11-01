using System.Globalization;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using NossoCombustivel.Application.Postos;
using NossoCombustivel.Domain.Postos;

namespace NossoCombustivel.Infrastructure.Postos;

public sealed class BuscaPostosNominatim(HttpClient http, ILogger<BuscaPostosNominatim> log) : IBuscaPostos
{
    public const string Endereco = "https://nominatim.openstreetmap.org/";

    public OrigemPosto Origem => OrigemPosto.OpenStreetMap;

    public async Task<IReadOnlyList<PostoEncontrado>> BuscarProximosAsync(
        double latitude, double longitude, int raioMetros, CancellationToken cancelamento)
    {
        try
        {
            using var resposta = await http.GetAsync(Caminho(latitude, longitude, raioMetros), cancelamento);
            if (!resposta.IsSuccessStatusCode)
            {
                log.LogWarning("Nominatim respondeu {Status}", (int)resposta.StatusCode);
                throw new BuscaPostosIndisponivelException();
            }
            await using var corpo = await resposta.Content.ReadAsStreamAsync(cancelamento);
            using var json = await JsonDocument.ParseAsync(corpo, cancellationToken: cancelamento);
            return Ler(json.RootElement);
        }
        catch (Exception erro) when (erro is HttpRequestException or JsonException
                                         || (erro is TaskCanceledException && !cancelamento.IsCancellationRequested))
        {
            log.LogWarning("Nominatim falhou: {Erro}", erro.GetType().Name);
            throw new BuscaPostosIndisponivelException();
        }
    }

    public static string Caminho(double latitude, double longitude, int raioMetros)
    {
        var grausLatitude = raioMetros / 111_320d;
        var grausLongitude = raioMetros / (111_320d * Math.Max(Math.Cos(latitude * Math.PI / 180), 0.01));
        return string.Create(CultureInfo.InvariantCulture,
            $"search?amenity=fuel&viewbox={longitude - grausLongitude:F5},{latitude + grausLatitude:F5},{longitude + grausLongitude:F5},{latitude - grausLatitude:F5}&bounded=1&format=jsonv2&limit=40&addressdetails=1&extratags=1");
    }

    public static IReadOnlyList<PostoEncontrado> Ler(JsonElement raiz)
    {
        var postos = new List<PostoEncontrado>();
        if (raiz.ValueKind != JsonValueKind.Array)
            return postos;

        foreach (var item in raiz.EnumerateArray())
        {
            var tipo = Texto(item, "osm_type");
            if (tipo is null || !item.TryGetProperty("osm_id", out var id))
                continue;
            if (!double.TryParse(Texto(item, "lat"), CultureInfo.InvariantCulture, out var lat) ||
                !double.TryParse(Texto(item, "lon"), CultureInfo.InvariantCulture, out var lon))
                continue;

            var extras = item.TryGetProperty("extratags", out var e) && e.ValueKind == JsonValueKind.Object ? e : default;
            var bandeira = Texto(extras, "brand") ?? Texto(extras, "operator");
            var nome = Texto(item, "name") ?? bandeira ?? "Posto sem nome";
            var endereco = item.TryGetProperty("address", out var a) && a.ValueKind == JsonValueKind.Object ? a : default;
            postos.Add(new PostoEncontrado(
                OrigemPosto.OpenStreetMap, $"{tipo}/{id.GetInt64()}", nome, bandeira, MontarEndereco(endereco), lat, lon));
        }
        return postos;
    }

    private static string? MontarEndereco(JsonElement endereco)
    {
        var rua = Texto(endereco, "road");
        if (rua is null)
            return null;
        var numero = Texto(endereco, "house_number");
        var bairro = Texto(endereco, "suburb");
        var linha = numero is null ? rua : $"{rua}, {numero}";
        return bairro is null ? linha : $"{linha} - {bairro}";
    }

    private static string? Texto(JsonElement objeto, string nome) =>
        objeto.ValueKind == JsonValueKind.Object && objeto.TryGetProperty(nome, out var valor)
            && valor.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(valor.GetString())
            ? valor.GetString()!.Trim()
            : null;
}

public sealed class BuscaPostosComReserva(BuscaPostosNominatim principal, BuscaPostosOverpass reserva) : IBuscaPostos
{
    public OrigemPosto Origem => OrigemPosto.OpenStreetMap;

    public async Task<IReadOnlyList<PostoEncontrado>> BuscarProximosAsync(
        double latitude, double longitude, int raioMetros, CancellationToken cancelamento)
    {
        try
        {
            return await principal.BuscarProximosAsync(latitude, longitude, raioMetros, cancelamento);
        }
        catch (BuscaPostosIndisponivelException)
        {
            return await reserva.BuscarProximosAsync(latitude, longitude, raioMetros, cancelamento);
        }
    }
}
