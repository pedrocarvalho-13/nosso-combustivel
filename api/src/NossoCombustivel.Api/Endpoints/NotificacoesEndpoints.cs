using System.Security.Claims;
using Microsoft.IdentityModel.JsonWebTokens;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Notificacoes;

namespace NossoCombustivel.Api.Endpoints;

public sealed record ChavePushResposta(string ChavePublica);

public sealed record InscricaoRequisicao(string Endpoint, string P256dh, string Auth, string? Aparelho);

public sealed record CancelamentoRequisicao(string Endpoint);

public static class NotificacoesEndpoints
{
    public static IEndpointRouteBuilder MapNotificacoes(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/notificacoes").RequireAuthorization();

        grupo.MapGet("/chave", (ServicoNotificacoes servico) =>
        {
            var resultado = servico.ChavePublica();
            return resultado.Sucesso ? Results.Ok(new ChavePushResposta(resultado.Valor!)) : ParaProblema(resultado.Erro!);
        });

        grupo.MapPost("/inscricao", async (
            InscricaoRequisicao requisicao, ClaimsPrincipal usuario, ServicoNotificacoes servico, CancellationToken cancelamento) =>
        {
            var resultado = await servico.InscreverAsync(UsuarioId(usuario),
                new InscricaoPush(requisicao.Endpoint, requisicao.P256dh, requisicao.Auth), requisicao.Aparelho, cancelamento);
            return resultado.Sucesso ? Results.NoContent() : ParaProblema(resultado.Erro!);
        });

        grupo.MapPost("/cancelamento", async (
            CancelamentoRequisicao requisicao, ClaimsPrincipal usuario, ServicoNotificacoes servico, CancellationToken cancelamento) =>
        {
            await servico.CancelarAsync(UsuarioId(usuario), requisicao.Endpoint, cancelamento);
            return Results.NoContent();
        });

        grupo.MapPost("/teste", async (ClaimsPrincipal usuario, ServicoNotificacoes servico, CancellationToken cancelamento) =>
        {
            var resultado = await servico.EnviarTesteAsync(UsuarioId(usuario), cancelamento);
            return resultado.Sucesso ? Results.Ok(resultado.Valor) : ParaProblema(resultado.Erro!);
        }).RequireRateLimiting(IaEndpoints.PoliticaLimite);

        return app;
    }

    private static Guid UsuarioId(ClaimsPrincipal usuario) => Guid.Parse(usuario.FindFirstValue(JwtRegisteredClaimNames.Sub)!);

    private static IResult ParaProblema(ErroAplicacao erro) => Results.Problem(
        title: erro.Mensagem,
        statusCode: erro.Tipo switch
        {
            TipoErro.Validacao => StatusCodes.Status400BadRequest,
            TipoErro.NaoEncontrado => StatusCodes.Status422UnprocessableEntity,
            TipoErro.Indisponivel => StatusCodes.Status503ServiceUnavailable,
            _ => StatusCodes.Status500InternalServerError
        });
}
