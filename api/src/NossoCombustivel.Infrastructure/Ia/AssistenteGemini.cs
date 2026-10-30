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
        var instrucao = tipo == TipoLeitura.Abastecimento ? InstrucaoAbastecimento : InstrucaoRecarga;
        var esquema = new JsonObject
        {
            ["type"] = "OBJECT",
            ["properties"] = new JsonObject
            {
                ["descricao"] = new JsonObject { ["type"] = "STRING" },
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
            },
            ["propertyOrdering"] = new JsonArray(
                "descricao", "litros", "precoLitro", "kwh", "precoKwh", "valorTotal", "odometro", "combustivel")
        };
        JsonNode[] partes =
        [
            new JsonObject { ["text"] = instrucao },
            new JsonObject
            {
                ["inline_data"] = new JsonObject { ["mime_type"] = tipoMime, ["data"] = Convert.ToBase64String(imagem) }
            }
        ];
        var texto = await GerarAsync(partes, esquema, cancelamento, altaResolucao: true);
        if (texto is null) return null;
        var bruta = JsonSerializer.Deserialize<LeituraBruta>(texto, Json);
        if (bruta is null) return null;
        log.LogInformation("Leitura de foto ({Tipo}): {Descricao}", tipo, bruta.Descricao);
        return new LeituraFoto(
            Positivo(bruta.Litros),
            Positivo(bruta.PrecoLitro),
            Positivo(bruta.Kwh),
            Positivo(bruta.PrecoKwh),
            Positivo(bruta.ValorTotal),
            bruta.Odometro is > 0 ? bruta.Odometro : null,
            Enum.TryParse<Combustivel>(bruta.Combustivel, ignoreCase: true, out var combustivel) ? combustivel : null);
    }

    private async Task<string?> GerarAsync(
        JsonNode[] partes, JsonObject esquema, CancellationToken cancelamento, bool altaResolucao = false)
    {
        var configuracao = new JsonObject
        {
            ["temperature"] = 0,
            ["responseMimeType"] = "application/json",
            ["responseSchema"] = esquema
        };
        if (altaResolucao) configuracao["mediaResolution"] = "MEDIA_RESOLUTION_HIGH";
        var corpo = new JsonObject
        {
            ["contents"] = new JsonArray(new JsonObject { ["parts"] = new JsonArray(partes) }),
            ["generationConfig"] = configuracao
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

    private const string InstrucaoAbastecimento = """
        Leia a foto de um abastecimento feito no Brasil. Ela pode ser do visor da bomba, do comprovante do posto ou do painel do veículo.
        Visor da bomba: normalmente tem três mostradores de dígitos luminosos, cada um com um rótulo impresso ao lado ou acima.
        - "Total a pagar", "Valor", "R$" ou "Importe": o valor total em reais, com 2 casas decimais.
        - "Litros", "Volume" ou "L": a quantidade abastecida, normalmente com 2 ou 3 casas decimais.
        - "Preço por litro", "R$/L" ou "Preço/L": quase sempre com 3 casas decimais, entre R$ 3,000 e R$ 9,000.
        Ignore o encerrante ou totalizador (contador acumulado da bomba, com muitos dígitos e sem vírgula) e qualquer número de bico ou de bomba.
        Os mostradores usam vírgula ou ponto como separador decimal; quando o separador não aparecer, use as casas decimais típicas acima.
        Confira a coerência: litros vezes preço por litro deve dar o valor total, com diferença de poucos centavos.
        Comprovante: procure as linhas de quantidade em litros, valor unitário e valor total.
        Painel do veículo: leia só o odômetro total em km, não o parcial (trip).
        Em descricao, diga em uma frase quais rótulos e números você leu em cada mostrador.
        Use null no que não estiver visível com clareza. Não invente valores.
        """;

    private const string InstrucaoRecarga = """
        Leia a foto de uma recarga de veículo elétrico feita no Brasil. Ela pode ser da tela de um carregador, de um aplicativo de recarga, de um comprovante ou do painel do veículo.
        Extraia a energia entregue em kWh, o preço por kWh em reais (normalmente entre R$ 0,50 e R$ 4,00), o valor total em reais e o odômetro total em km (só se aparecer o painel; ignore o parcial).
        Ignore percentuais de bateria, tempo de recarga e potência em kW.
        Confira a coerência: kWh vezes preço por kWh deve dar o valor total.
        Em descricao, diga em uma frase quais rótulos e números você leu.
        Use null no que não estiver visível com clareza. Não invente valores.
        """;

    private static JsonObject Numero() => new() { ["type"] = "NUMBER", ["nullable"] = true };

    private static decimal? Positivo(decimal? valor) => valor is > 0 ? valor : null;

    private sealed record LeituraBruta(
        string? Descricao,
        decimal? Litros, decimal? PrecoLitro, decimal? Kwh, decimal? PrecoKwh, decimal? ValorTotal, int? Odometro, string? Combustivel);
}
