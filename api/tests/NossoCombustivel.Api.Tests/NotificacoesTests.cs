using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using NossoCombustivel.Api.Endpoints;
using NossoCombustivel.Application.Notificacoes;

namespace NossoCombustivel.Api.Tests;

public sealed class EnviadorFalso : IEnviadorPush
{
    public string? ChavePublica { get; set; } = "BChavePublicaDeTeste";
    public List<(InscricaoPush Inscricao, MensagemPush Mensagem)> Enviadas { get; } = [];
    public HashSet<string> Expiradas { get; } = [];

    public Task<ResultadoEnvioPush> EnviarAsync(InscricaoPush inscricao, MensagemPush mensagem, CancellationToken cancelamento)
    {
        if (Expiradas.Contains(inscricao.Endpoint)) return Task.FromResult(ResultadoEnvioPush.InscricaoExpirada);
        Enviadas.Add((inscricao, mensagem));
        return Task.FromResult(ResultadoEnvioPush.Enviado);
    }
}

public sealed class FabricaApiComPush : IDisposable
{
    public EnviadorFalso Enviador { get; } = new();
    public FabricaApi Fabrica { get; } = new();

    public HttpClient CriarCliente() => Fabrica
        .WithWebHostBuilder(builder => builder.ConfigureServices(services =>
        {
            services.RemoveAll<IEnviadorPush>();
            services.AddSingleton<IEnviadorPush>(Enviador);
        }))
        .CreateClient();

    public void Dispose() => Fabrica.Dispose();
}

public class NotificacoesTests(FabricaApiComPush fabrica) : IClassFixture<FabricaApiComPush>
{
    private async Task<HttpClient> ClienteLogadoAsync()
    {
        var cliente = fabrica.CriarCliente();
        var resposta = await cliente.PostAsJsonAsync("/contas",
            new CadastroRequisicao("Pedro", $"push-{Guid.NewGuid():N}@exemplo.com", "senha123"));
        var sessao = (await resposta.Content.ReadFromJsonAsync<SessaoResposta>())!;
        cliente.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", sessao.TokenAcesso);
        return cliente;
    }

    private static InscricaoRequisicao Inscricao(string sufixo) =>
        new($"https://fcm.googleapis.com/fcm/send/{sufixo}", "BP256dhDeTeste", "authDeTeste", "Chrome no Android");

    [Fact]
    public async Task Chave_exige_login()
    {
        var resposta = await fabrica.CriarCliente().GetAsync("/notificacoes/chave");
        Assert.Equal(HttpStatusCode.Unauthorized, resposta.StatusCode);
    }

    [Fact]
    public async Task Chave_publica_vem_do_servidor()
    {
        var cliente = await ClienteLogadoAsync();

        var resposta = await cliente.GetFromJsonAsync<ChavePushResposta>("/notificacoes/chave");

        Assert.Equal("BChavePublicaDeTeste", resposta!.ChavePublica);
    }

    [Fact]
    public async Task Teste_chega_em_cada_aparelho_inscrito_e_inscricao_repetida_nao_duplica()
    {
        var cliente = await ClienteLogadoAsync();
        var sufixo = Guid.NewGuid().ToString("N");
        await cliente.PostAsJsonAsync("/notificacoes/inscricao", Inscricao($"{sufixo}-a"));
        await cliente.PostAsJsonAsync("/notificacoes/inscricao", Inscricao($"{sufixo}-a"));
        await cliente.PostAsJsonAsync("/notificacoes/inscricao", Inscricao($"{sufixo}-b"));

        var resposta = await cliente.PostAsync("/notificacoes/teste", null);
        var corpo = await resposta.Content.ReadFromJsonAsync<EnvioTeste>();

        Assert.Equal(HttpStatusCode.OK, resposta.StatusCode);
        Assert.Equal(2, corpo!.Enviados);
        Assert.Equal(2, fabrica.Enviador.Enviadas.Count(e => e.Inscricao.Endpoint.Contains(sufixo)));
        Assert.All(fabrica.Enviador.Enviadas, e => Assert.Equal("Pit Garage", e.Mensagem.Titulo));
    }

    [Fact]
    public async Task Inscricao_expirada_sai_da_lista_no_envio()
    {
        var cliente = await ClienteLogadoAsync();
        var sufixo = Guid.NewGuid().ToString("N");
        await cliente.PostAsJsonAsync("/notificacoes/inscricao", Inscricao(sufixo));
        fabrica.Enviador.Expiradas.Add(Inscricao(sufixo).Endpoint);

        var primeira = await cliente.PostAsync("/notificacoes/teste", null);
        var segunda = await cliente.PostAsync("/notificacoes/teste", null);

        Assert.Equal(HttpStatusCode.ServiceUnavailable, primeira.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, segunda.StatusCode);
    }

    [Fact]
    public async Task Cancelar_para_de_enviar_para_o_aparelho()
    {
        var cliente = await ClienteLogadoAsync();
        var inscricao = Inscricao(Guid.NewGuid().ToString("N"));
        await cliente.PostAsJsonAsync("/notificacoes/inscricao", inscricao);

        await cliente.PostAsJsonAsync("/notificacoes/cancelamento", new CancelamentoRequisicao(inscricao.Endpoint));
        var resposta = await cliente.PostAsync("/notificacoes/teste", null);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, resposta.StatusCode);
    }

    [Fact]
    public async Task Endereco_sem_https_e_recusado()
    {
        var cliente = await ClienteLogadoAsync();

        var resposta = await cliente.PostAsJsonAsync("/notificacoes/inscricao",
            new InscricaoRequisicao("http://exemplo.com/push", "a", "b", null));

        Assert.Equal(HttpStatusCode.BadRequest, resposta.StatusCode);
    }
}
