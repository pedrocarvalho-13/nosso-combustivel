using System.Net;
using System.Text.Json;
using Lib.Net.Http.WebPush;
using Lib.Net.Http.WebPush.Authentication;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NossoCombustivel.Application.Notificacoes;

namespace NossoCombustivel.Infrastructure.Notificacoes;

public sealed class OpcoesVapid
{
    public const string Secao = "Vapid";

    public string Assunto { get; set; } = "mailto:contato@exemplo.com";
    public string? ChavePublica { get; set; }
    public string? ChavePrivada { get; set; }

    public bool Configurado => !string.IsNullOrWhiteSpace(ChavePublica) && !string.IsNullOrWhiteSpace(ChavePrivada);
}

public sealed class EnviadorWebPush(HttpClient http, IOptions<OpcoesVapid> opcoes, ILogger<EnviadorWebPush> registro) : IEnviadorPush
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    public string? ChavePublica => opcoes.Value.Configurado ? opcoes.Value.ChavePublica : null;

    public async Task<ResultadoEnvioPush> EnviarAsync(InscricaoPush inscricao, MensagemPush mensagem, CancellationToken cancelamento)
    {
        var vapid = opcoes.Value;
        if (!vapid.Configurado) return ResultadoEnvioPush.Falhou;

        var cliente = new PushServiceClient(http)
        {
            DefaultAuthentication = new VapidAuthentication(vapid.ChavePublica, vapid.ChavePrivada) { Subject = vapid.Assunto }
        };
        var destino = new PushSubscription
        {
            Endpoint = inscricao.Endpoint,
            Keys = new Dictionary<string, string> { ["p256dh"] = inscricao.P256dh, ["auth"] = inscricao.Auth }
        };
        var conteudo = JsonSerializer.Serialize(new { titulo = mensagem.Titulo, corpo = mensagem.Corpo, rota = mensagem.Rota }, Json);
        try
        {
            await cliente.RequestPushMessageDeliveryAsync(
                destino, new PushMessage(conteudo) { TimeToLive = 86400, Urgency = PushMessageUrgency.Normal }, cancelamento);
            return ResultadoEnvioPush.Enviado;
        }
        catch (PushServiceClientException erro) when (erro.StatusCode is HttpStatusCode.NotFound or HttpStatusCode.Gone)
        {
            return ResultadoEnvioPush.InscricaoExpirada;
        }
        catch (Exception erro) when (erro is PushServiceClientException or HttpRequestException or TaskCanceledException)
        {
            registro.LogWarning(erro, "Falha ao enviar notificação push");
            return ResultadoEnvioPush.Falhou;
        }
    }
}
