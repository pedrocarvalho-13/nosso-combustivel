using System.Security.Claims;
using Microsoft.IdentityModel.JsonWebTokens;
using NossoCombustivel.Application.Sincronizacao;

namespace NossoCombustivel.Api.Endpoints;

public static class SincronizacaoEndpoints
{
    public static IEndpointRouteBuilder MapSincronizacao(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/sync").RequireAuthorization();

        grupo.MapGet("/", (DateTimeOffset? desde, ClaimsPrincipal usuario, ServicoSincronizacao servico, CancellationToken cancelamento) =>
            servico.BuscarAsync(UsuarioId(usuario), desde, cancelamento));

        grupo.MapPost("/", (LoteSync lote, ClaimsPrincipal usuario, ServicoSincronizacao servico, CancellationToken cancelamento) =>
            servico.EnviarAsync(UsuarioId(usuario), lote, cancelamento));

        return app;
    }

    private static Guid UsuarioId(ClaimsPrincipal usuario) => Guid.Parse(usuario.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
}
