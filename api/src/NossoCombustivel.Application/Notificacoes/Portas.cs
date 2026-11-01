namespace NossoCombustivel.Application.Notificacoes;

public sealed record InscricaoPush(string Endpoint, string P256dh, string Auth);

public sealed record MensagemPush(string Titulo, string Corpo, string? Rota);

public enum ResultadoEnvioPush
{
    Enviado,
    InscricaoExpirada,
    Falhou
}

public interface IEnviadorPush
{
    string? ChavePublica { get; }
    Task<ResultadoEnvioPush> EnviarAsync(InscricaoPush inscricao, MensagemPush mensagem, CancellationToken cancelamento);
}

public interface IRepositorioInscricoes
{
    Task SalvarAsync(Guid usuarioId, InscricaoPush inscricao, string? aparelho, CancellationToken cancelamento);
    Task RemoverAsync(Guid usuarioId, string endpoint, CancellationToken cancelamento);
    Task<List<InscricaoPush>> DoUsuarioAsync(Guid usuarioId, CancellationToken cancelamento);
    Task MarcarEnviadoAsync(IReadOnlyCollection<string> endpoints, CancellationToken cancelamento);
}
