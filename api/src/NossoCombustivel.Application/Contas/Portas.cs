using NossoCombustivel.Application.Comum;

namespace NossoCombustivel.Application.Contas;

public sealed record UsuarioConta(Guid Id, string Nome, string Email);

public sealed record TokenAcesso(string Token, DateTimeOffset ExpiraEm);

public sealed record SessaoArmazenada(Guid UsuarioId, DateTimeOffset ExpiraEm, bool Revogada);

public interface IServicoContas
{
    Task<Resultado<UsuarioConta>> CriarAsync(string nome, string email, string senha, CancellationToken cancelamento);
    Task<UsuarioConta?> ValidarCredenciaisAsync(string email, string senha, CancellationToken cancelamento);
    Task<UsuarioConta?> ObterAsync(Guid id, CancellationToken cancelamento);
}

public interface IEmissorTokens
{
    TokenAcesso Emitir(UsuarioConta usuario);
}

public interface IRepositorioSessoes
{
    Task SalvarAsync(Guid usuarioId, string tokenHash, DateTimeOffset expiraEm, CancellationToken cancelamento);
    Task<SessaoArmazenada?> ObterAsync(string tokenHash, CancellationToken cancelamento);
    Task RevogarAsync(string tokenHash, CancellationToken cancelamento);
}
