using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using NossoCombustivel.Application.Comum;

namespace NossoCombustivel.Application.Contas;

public sealed class OpcoesSessao
{
    public int DiasRefreshToken { get; set; } = 60;
}

public sealed record RespostaSessao(UsuarioConta Usuario, string TokenAcesso, DateTimeOffset AcessoExpiraEm, string RefreshToken);

public sealed class ServicoSessoes(
    IServicoContas contas,
    IEmissorTokens emissor,
    IRepositorioSessoes sessoes,
    IRelogio relogio,
    IOptions<OpcoesSessao> opcoes)
{
    private const string CredenciaisInvalidas = "E-mail ou senha incorretos.";
    private const string SessaoExpirada = "Sua sessão expirou. Entre de novo.";

    public async Task<Resultado<RespostaSessao>> CadastrarAsync(string nome, string email, string senha, CancellationToken cancelamento)
    {
        nome = nome.Trim();
        email = email.Trim().ToLowerInvariant();
        if (nome.Length is 0 or > 100)
            return Resultado<RespostaSessao>.Falha(TipoErro.Validacao, "Informe seu nome, com até 100 letras.");
        if (!EmailValido(email))
            return Resultado<RespostaSessao>.Falha(TipoErro.Validacao, "Informe um e-mail válido.");

        var criado = await contas.CriarAsync(nome, email, senha, cancelamento);
        if (!criado.Sucesso)
            return Resultado<RespostaSessao>.Falha(criado.Erro!);

        return Resultado<RespostaSessao>.Ok(await AbrirSessaoAsync(criado.Valor!, cancelamento));
    }

    public async Task<Resultado<RespostaSessao>> EntrarAsync(string email, string senha, CancellationToken cancelamento)
    {
        var usuario = await contas.ValidarCredenciaisAsync(email.Trim().ToLowerInvariant(), senha, cancelamento);
        if (usuario is null)
            return Resultado<RespostaSessao>.Falha(TipoErro.NaoAutorizado, CredenciaisInvalidas);

        return Resultado<RespostaSessao>.Ok(await AbrirSessaoAsync(usuario, cancelamento));
    }

    public async Task<Resultado<RespostaSessao>> RenovarAsync(string refreshToken, CancellationToken cancelamento)
    {
        var hash = Hash(refreshToken);
        var sessao = await sessoes.ObterAsync(hash, cancelamento);
        if (sessao is null || sessao.Revogada || sessao.ExpiraEm <= relogio.Agora)
            return Resultado<RespostaSessao>.Falha(TipoErro.NaoAutorizado, SessaoExpirada);

        var usuario = await contas.ObterAsync(sessao.UsuarioId, cancelamento);
        if (usuario is null)
            return Resultado<RespostaSessao>.Falha(TipoErro.NaoAutorizado, SessaoExpirada);

        await sessoes.RevogarAsync(hash, cancelamento);
        return Resultado<RespostaSessao>.Ok(await AbrirSessaoAsync(usuario, cancelamento));
    }

    public Task SairAsync(string refreshToken, CancellationToken cancelamento) =>
        sessoes.RevogarAsync(Hash(refreshToken), cancelamento);

    private async Task<RespostaSessao> AbrirSessaoAsync(UsuarioConta usuario, CancellationToken cancelamento)
    {
        var acesso = emissor.Emitir(usuario);
        var refreshToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))
            .TrimEnd('=').Replace('+', '-').Replace('/', '_');
        var expiraEm = relogio.Agora.AddDays(opcoes.Value.DiasRefreshToken);
        await sessoes.SalvarAsync(usuario.Id, Hash(refreshToken), expiraEm, cancelamento);
        return new RespostaSessao(usuario, acesso.Token, acesso.ExpiraEm, refreshToken);
    }

    private static string Hash(string token) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));

    private static bool EmailValido(string email) =>
        email.Length <= 256 && MailAddress.TryCreate(email, out var endereco) && endereco.Address == email && email.Contains('.');
}
