using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using NossoCombustivel.Application.Postos;
using NossoCombustivel.Domain.Postos;

namespace NossoCombustivel.Api.Endpoints;

public sealed record CadastroPostoRequisicao(string Nome, string? Bandeira, double Latitude, double Longitude);

public static class PostosEndpoints
{
    public const string PoliticaLimite = "postos";

    public static IEndpointRouteBuilder MapPostos(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/postos").RequireAuthorization().RequireRateLimiting(PoliticaLimite);

        grupo.MapGet("/proximos", async (double lat, double lng, int? raio, ServicoPostos servico, CancellationToken cancelamento) =>
        {
            var resultado = await servico.BuscarProximosAsync(lat, lng, raio, cancelamento);
            return resultado.Sucesso
                ? Results.Ok(resultado.Valor)
                : Results.Problem(title: resultado.Erro!.Mensagem, statusCode: StatusCodes.Status400BadRequest);
        });

        grupo.MapPost("/", async (CadastroPostoRequisicao requisicao, ClaimsPrincipal usuario, ServicoPostos servico, CancellationToken cancelamento) =>
        {
            var dados = new DadosPosto(requisicao.Nome, requisicao.Bandeira, null, requisicao.Latitude, requisicao.Longitude);
            var resultado = await servico.CadastrarAsync(
                Guid.Parse(usuario.FindFirstValue(JwtRegisteredClaimNames.Sub)!), dados, cancelamento);
            return resultado.Sucesso
                ? Results.Ok(resultado.Valor)
                : Results.Problem(title: resultado.Erro!.Mensagem, statusCode: StatusCodes.Status400BadRequest);
        });

        return app;
    }
}
