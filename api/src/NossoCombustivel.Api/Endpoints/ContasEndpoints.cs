using System.Security.Claims;
using Microsoft.IdentityModel.JsonWebTokens;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Contas;

namespace NossoCombustivel.Api.Endpoints;

public sealed record CadastroRequisicao(string Nome, string Email, string Senha);

public sealed record EntrarRequisicao(string Email, string Senha);

public sealed record RefreshRequisicao(string RefreshToken);

public sealed record UsuarioResposta(Guid Id, string Nome, string Email);

public sealed record SessaoResposta(UsuarioResposta Usuario, string TokenAcesso, DateTimeOffset AcessoExpiraEm, string RefreshToken);

public static class ContasEndpoints
{
    public static IEndpointRouteBuilder MapContas(this IEndpointRouteBuilder app)
    {
        app.MapPost("/contas", async (CadastroRequisicao requisicao, ServicoSessoes servico, CancellationToken cancelamento) =>
        {
            var resultado = await servico.CadastrarAsync(requisicao.Nome, requisicao.Email, requisicao.Senha, cancelamento);
            return resultado.Sucesso
                ? Results.Created("/contas/eu", ParaResposta(resultado.Valor!))
                : ParaProblema(resultado.Erro!);
        });

        app.MapPost("/sessoes", async (EntrarRequisicao requisicao, ServicoSessoes servico, CancellationToken cancelamento) =>
        {
            var resultado = await servico.EntrarAsync(requisicao.Email, requisicao.Senha, cancelamento);
            return resultado.Sucesso ? Results.Ok(ParaResposta(resultado.Valor!)) : ParaProblema(resultado.Erro!);
        });

        app.MapPost("/sessoes/renovar", async (RefreshRequisicao requisicao, ServicoSessoes servico, CancellationToken cancelamento) =>
        {
            var resultado = await servico.RenovarAsync(requisicao.RefreshToken, cancelamento);
            return resultado.Sucesso ? Results.Ok(ParaResposta(resultado.Valor!)) : ParaProblema(resultado.Erro!);
        });

        app.MapPost("/sessoes/sair", async (RefreshRequisicao requisicao, ServicoSessoes servico, CancellationToken cancelamento) =>
        {
            await servico.SairAsync(requisicao.RefreshToken, cancelamento);
            return Results.NoContent();
        });

        app.MapGet("/contas/eu", (ClaimsPrincipal usuario) => Results.Ok(new UsuarioResposta(
            Guid.Parse(usuario.FindFirstValue(JwtRegisteredClaimNames.Sub)!),
            usuario.FindFirstValue(JwtRegisteredClaimNames.Name)!,
            usuario.FindFirstValue(JwtRegisteredClaimNames.Email)!)))
            .RequireAuthorization();

        return app;
    }

    private static SessaoResposta ParaResposta(RespostaSessao sessao) => new(
        new UsuarioResposta(sessao.Usuario.Id, sessao.Usuario.Nome, sessao.Usuario.Email),
        sessao.TokenAcesso,
        sessao.AcessoExpiraEm,
        sessao.RefreshToken);

    private static IResult ParaProblema(ErroAplicacao erro) => Results.Problem(
        title: erro.Mensagem,
        statusCode: erro.Tipo switch
        {
            TipoErro.Validacao => StatusCodes.Status400BadRequest,
            TipoErro.Conflito => StatusCodes.Status409Conflict,
            TipoErro.NaoAutorizado => StatusCodes.Status401Unauthorized,
            _ => StatusCodes.Status500InternalServerError
        });
}
