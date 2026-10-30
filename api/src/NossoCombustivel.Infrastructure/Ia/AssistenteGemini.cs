using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NossoCombustivel.Application.Ia;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Infrastructure.Ia;

public sealed class AssistenteGemini(HttpClient http, IOptions<OpcoesGemini> opcoes, ILogger<AssistenteGemini> log) : IAssistenteIa
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    public bool Disponivel => !string.IsNullOrWhiteSpace(opcoes.Value.Chave);

    public async Task<CapacidadeEstimada?> EstimarCapacidadeAsync(VeiculoConsultado veiculo, CancellationToken cancelamento)
    {
        var tipo = veiculo.TipoVeiculo == TipoVeiculo.Moto ? "moto" : "carro";
        var ano = veiculo.Ano is null ? "" : $", ano modelo {veiculo.Ano}";
        var instrucao =
            "Você é especialista em ficha técnica de veículos vendidos no Brasil.\n" +
            $"Veículo: {tipo} {veiculo.Marca} {veiculo.Modelo}{ano}.\n" +
            $"Tipo de energia: {veiculo.TipoEnergia}.\n" +
            "Informe a capacidade nominal do tanque de combustível em litros e a capacidade útil da bateria de tração em kWh.\n" +
            "Use null no que o veículo não tiver: carro só a combustão não tem bateria de tração e elétrico puro não tem tanque.\n" +
            "Use null também quando não tiver segurança razoável sobre o valor. Não invente.";
        var esquema = new JsonObject
        {
            ["type"] = "OBJECT",
            ["properties"] = new JsonObject
            {
                ["tanqueL"] = Numero(),
                ["bateriaKwh"] = Numero()
            },
            ["required"] = new JsonArray("tanqueL", "bateriaKwh")
        };
        var texto = await GerarAsync([new JsonObject { ["text"] = instrucao }], esquema, cancelamento);
        return texto is null ? null : JsonSerializer.Deserialize<CapacidadeEstimada>(texto, Json);
    }

    public async Task<LeituraFoto?> LerFotoAsync(byte[] imagem, string tipoMime, TipoLeitura tipo, CancellationToken cancelamento)
    {
        var instrucao = tipo == TipoLeitura.Abastecimento
            ? "A foto é do visor de uma bomba de combustível, de um comprovante de posto ou do painel de um veículo, no Brasil.\n" +
              "Extraia os litros abastecidos, o preço por litro em reais, o valor total em reais, o odômetro em km " +
              "(só se aparecer o painel) e o combustível.\n" +
              "Use null no que não aparecer com clareza. Não calcule nem invente valores que não estejam visíveis."
            : "A foto é da tela de um carregador de veículo elétrico, de um aplicativo de recarga, de um comprovante ou do painel do veículo, no Brasil.\n" +
              "Extraia a energia em kWh, o preço por kWh em reais, o valor total em reais e o odômetro em km (só se aparecer o painel).\n" +
              "Use null no que não aparecer com clareza. Não calcule nem invente valores que não estejam visíveis.";
        var esquema = new JsonObject
        {
            ["type"] = "OBJECT",
            ["properties"] = new JsonObject
            {
                ["litros"] = Numero(),
                ["precoLitro"] = Numero(),
                ["kwh"] = Numero(),
                ["precoKwh"] = Numero(),
                ["valorTotal"] = Numero(),
                ["odometro"] = new JsonObject { ["type"] = "INTEGER", ["nullable"] = true },
                ["combustivel"] = new JsonObject
                {
                    ["type"] = "STRING",
                    ["nullable"] = true,
                    ["enum"] = new JsonArray("gasolina", "etanol", "dieselS10", "dieselS500", "gnv")
                }
            }
        };
        JsonNode[] partes =
        [
            new JsonObject { ["text"] = instrucao },
            new JsonObject
            {
                ["inline_data"] = new JsonObject { ["mime_type"] = tipoMime, ["data"] = Convert.ToBase64String(imagem) }
            }
        ];
        var texto = await GerarAsync(partes, esquema, cancelamento);
        if (texto is null) return null;
        var bruta = JsonSerializer.Deserialize<LeituraBruta>(texto, Json);
        if (bruta is null) return null;
        return new LeituraFoto(
            Positivo(bruta.Litros),
            Positivo(bruta.PrecoLitro),
            Positivo(bruta.Kwh),
            Positivo(bruta.PrecoKwh),
            Positivo(bruta.ValorTotal),
            bruta.Odometro is > 0 ? bruta.Odometro : null,
            Enum.TryParse<Combustivel>(bruta.Combustivel, ignoreCase: true, out var combustivel) ? combustivel : null);
    }

    private async Task<string?> GerarAsync(JsonNode[] partes, JsonObject esquema, CancellationToken cancelamento)
    {
        var corpo = new JsonObject
        {
            ["contents"] = new JsonArray(new JsonObject { ["parts"] = new JsonArray(partes) }),
            ["generationConfig"] = new JsonObject
            {
                ["temperature"] = 0,
                ["responseMimeType"] = "application/json",
                ["responseSchema"] = esquema
            }
        };
        using var requisicao = new HttpRequestMessage(HttpMethod.Post, $"models/{opcoes.Value.Modelo}:generateContent")
        {
            Content = JsonContent.Create(corpo)
        };
        requisicao.Headers.Add("x-goog-api-key", opcoes.Value.Chave);

        try
        {
            using var resposta = await http.SendAsync(requisicao, cancelamento);
            if (!resposta.IsSuccessStatusCode)
            {
                log.LogWarning("Gemini respondeu {Status}: {Corpo}", (int)resposta.StatusCode,
                    await resposta.Content.ReadAsStringAsync(cancelamento));
                return null;
            }
            var json = await resposta.Content.ReadFromJsonAsync<JsonNode>(cancelamento);
            return json?["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.GetValue<string>();
        }
        catch (Exception erro) when (erro is HttpRequestException or TaskCanceledException or JsonException)
        {
            log.LogWarning(erro, "Falha ao chamar o Gemini");
            return null;
        }
    }

    private static JsonObject Numero() => new() { ["type"] = "NUMBER", ["nullable"] = true };

    private static decimal? Positivo(decimal? valor) => valor is > 0 ? valor : null;

    private sealed record LeituraBruta(
        decimal? Litros, decimal? PrecoLitro, decimal? Kwh, decimal? PrecoKwh, decimal? ValorTotal, int? Odometro, string? Combustivel);
}
