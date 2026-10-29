using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using NossoCombustivel.Api.Endpoints;

namespace NossoCombustivel.Api.Tests;

public class ContasTests(FabricaApi fabrica) : IClassFixture<FabricaApi>
{
    private readonly HttpClient _cliente = fabrica.CreateClient();

    private static string EmailNovo() => $"teste-{Guid.NewGuid():N}@exemplo.com";

    private async Task<SessaoResposta> CadastrarAsync(string email, string senha = "senha123")
    {
        var resposta = await _cliente.PostAsJsonAsync("/contas", new CadastroRequisicao("Pedro", email, senha));
        Assert.Equal(HttpStatusCode.Created, resposta.StatusCode);
        return (await resposta.Content.ReadFromJsonAsync<SessaoResposta>())!;
    }

    [Fact]
    public async Task Cadastro_devolve_sessao_com_tokens()
    {
        var email = EmailNovo();

        var sessao = await CadastrarAsync(email);

        Assert.Equal(email, sessao.Usuario.Email);
        Assert.False(string.IsNullOrEmpty(sessao.TokenAcesso));
        Assert.False(string.IsNullOrEmpty(sessao.RefreshToken));
    }

    [Fact]
    public async Task Cadastro_com_email_repetido_da_conflito()
    {
        var email = EmailNovo();
        await CadastrarAsync(email);

        var resposta = await _cliente.PostAsJsonAsync("/contas", new CadastroRequisicao("Outro", email, "senha123"));

        Assert.Equal(HttpStatusCode.Conflict, resposta.StatusCode);
    }

    [Fact]
    public async Task Senha_fraca_e_recusada_com_mensagem_em_portugues()
    {
        var resposta = await _cliente.PostAsJsonAsync("/contas", new CadastroRequisicao("Pedro", EmailNovo(), "abc"));

        Assert.Equal(HttpStatusCode.BadRequest, resposta.StatusCode);
        Assert.Contains("pelo menos 8 caracteres", await resposta.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Login_com_senha_errada_nao_autoriza()
    {
        var email = EmailNovo();
        await CadastrarAsync(email);

        var resposta = await _cliente.PostAsJsonAsync("/sessoes", new EntrarRequisicao(email, "errada123"));

        Assert.Equal(HttpStatusCode.Unauthorized, resposta.StatusCode);
    }

    [Fact]
    public async Task Login_aceita_email_com_maiusculas()
    {
        var email = EmailNovo();
        await CadastrarAsync(email);

        var resposta = await _cliente.PostAsJsonAsync("/sessoes", new EntrarRequisicao(email.ToUpperInvariant(), "senha123"));

        Assert.Equal(HttpStatusCode.OK, resposta.StatusCode);
    }

    [Fact]
    public async Task Rota_protegida_exige_token()
    {
        var sem = await _cliente.GetAsync("/contas/eu");
        Assert.Equal(HttpStatusCode.Unauthorized, sem.StatusCode);

        var sessao = await CadastrarAsync(EmailNovo());
        using var requisicao = new HttpRequestMessage(HttpMethod.Get, "/contas/eu");
        requisicao.Headers.Authorization = new AuthenticationHeaderValue("Bearer", sessao.TokenAcesso);
        var com = await _cliente.SendAsync(requisicao);

        Assert.Equal(HttpStatusCode.OK, com.StatusCode);
        Assert.Equal(sessao.Usuario.Id, (await com.Content.ReadFromJsonAsync<UsuarioResposta>())!.Id);
    }

    [Fact]
    public async Task Renovar_troca_o_refresh_token_e_invalida_o_antigo()
    {
        var sessao = await CadastrarAsync(EmailNovo());

        var renovada = await _cliente.PostAsJsonAsync("/sessoes/renovar", new RefreshRequisicao(sessao.RefreshToken));
        var reuso = await _cliente.PostAsJsonAsync("/sessoes/renovar", new RefreshRequisicao(sessao.RefreshToken));

        Assert.Equal(HttpStatusCode.OK, renovada.StatusCode);
        Assert.NotEqual(sessao.RefreshToken, (await renovada.Content.ReadFromJsonAsync<SessaoResposta>())!.RefreshToken);
        Assert.Equal(HttpStatusCode.Unauthorized, reuso.StatusCode);
    }

    [Fact]
    public async Task Sair_invalida_o_refresh_token()
    {
        var sessao = await CadastrarAsync(EmailNovo());

        await _cliente.PostAsJsonAsync("/sessoes/sair", new RefreshRequisicao(sessao.RefreshToken));
        var resposta = await _cliente.PostAsJsonAsync("/sessoes/renovar", new RefreshRequisicao(sessao.RefreshToken));

        Assert.Equal(HttpStatusCode.Unauthorized, resposta.StatusCode);
    }
}
