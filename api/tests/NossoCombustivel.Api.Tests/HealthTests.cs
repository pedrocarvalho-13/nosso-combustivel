using System.Net;

namespace NossoCombustivel.Api.Tests;

public class HealthTests(FabricaApi fabrica) : IClassFixture<FabricaApi>
{
    [Fact]
    public async Task Health_responde_ok_sem_consultar_o_banco()
    {
        var cliente = fabrica.CreateClient();

        var resposta = await cliente.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, resposta.StatusCode);
    }
}
