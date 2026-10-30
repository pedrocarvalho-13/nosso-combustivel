using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Ia;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Api.Endpoints;

public sealed record CapacidadeRequisicao(
    TipoVeiculo TipoVeiculo, string Marca, string Modelo, int? Ano, string? CodigoFipe, TipoEnergia TipoEnergia);

public sealed record CapacidadeResposta(decimal? CapacidadeTanqueL, decimal? CapacidadeBateriaKwh);

public sealed record LeituraRequisicao(TipoLeitura Tipo, string ImagemBase64, string TipoMime);

public static class IaEndpoints
{
    public const string PoliticaLimite = "ia";

    public static IEndpointRouteBuilder MapIa(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/ia").RequireAuthorization().RequireRateLimiting(PoliticaLimite);

        grupo.MapPost("/capacidade", async (CapacidadeRequisicao requisicao, ServicoIa servico, CancellationToken cancelamento) =>
        {
            var veiculo = new VeiculoConsultado(
                requisicao.TipoVeiculo, requisicao.Marca, requisicao.Modelo, requisicao.Ano, requisicao.TipoEnergia);
            var resultado = await servico.EstimarCapacidadeAsync(veiculo, requisicao.CodigoFipe, cancelamento);
            return resultado.Sucesso
                ? Results.Ok(new CapacidadeResposta(resultado.Valor!.TanqueL, resultado.Valor.BateriaKwh))
                : ParaProblema(resultado.Erro!);
        });

        grupo.MapPost("/leitura", async (LeituraRequisicao requisicao, ServicoIa servico, CancellationToken cancelamento) =>
        {
            byte[] imagem;
            try
            {
                imagem = Convert.FromBase64String(requisicao.ImagemBase64);
            }
            catch (FormatException)
            {
                return Results.Problem(title: "Foto inválida.", statusCode: StatusCodes.Status400BadRequest);
            }
            var resultado = await servico.LerFotoAsync(imagem, requisicao.TipoMime, requisicao.Tipo, cancelamento);
            return resultado.Sucesso ? Results.Ok(resultado.Valor) : ParaProblema(resultado.Erro!);
        });

        return app;
    }

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
