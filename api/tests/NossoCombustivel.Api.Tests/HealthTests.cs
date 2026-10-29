using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace NossoCombustivel.Api.Tests;

public class HealthTests(WebApplicationFactory<Program> fabrica) : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Health_responde_ok_sem_consultar_o_banco()
    {
        var cliente = fabrica.CreateClient();

        var resposta = await cliente.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, resposta.StatusCode);
    }
}
