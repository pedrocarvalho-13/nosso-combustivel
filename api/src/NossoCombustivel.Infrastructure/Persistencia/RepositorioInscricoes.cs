using Microsoft.EntityFrameworkCore;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Notificacoes;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class InscricaoPushLinha
{
    public Guid Id { get; init; }
    public Guid UsuarioId { get; set; }
    public required string Endpoint { get; init; }
    public required string P256dh { get; set; }
    public required string Auth { get; set; }
    public string? Aparelho { get; set; }
    public DateTimeOffset CriadoEm { get; init; }
    public DateTimeOffset AtualizadoEm { get; set; }
    public DateTimeOffset? UltimoEnvioEm { get; set; }
}

public sealed class RepositorioInscricoes(NossoCombustivelDbContext banco, IRelogio relogio) : IRepositorioInscricoes
{
    public async Task SalvarAsync(Guid usuarioId, InscricaoPush inscricao, string? aparelho, CancellationToken cancelamento)
    {
        var agora = relogio.Agora;
        var linha = await banco.InscricoesPush.FirstOrDefaultAsync(i => i.Endpoint == inscricao.Endpoint, cancelamento);
        if (linha is null)
        {
            banco.InscricoesPush.Add(new InscricaoPushLinha
            {
                Id = Guid.CreateVersion7(),
                UsuarioId = usuarioId,
                Endpoint = inscricao.Endpoint,
                P256dh = inscricao.P256dh,
                Auth = inscricao.Auth,
                Aparelho = aparelho,
                CriadoEm = agora,
                AtualizadoEm = agora
            });
        }
        else
        {
            linha.UsuarioId = usuarioId;
            linha.P256dh = inscricao.P256dh;
            linha.Auth = inscricao.Auth;
            linha.Aparelho = aparelho;
            linha.AtualizadoEm = agora;
        }
        await banco.SaveChangesAsync(cancelamento);
    }

    public Task RemoverAsync(Guid usuarioId, string endpoint, CancellationToken cancelamento) =>
        banco.InscricoesPush.Where(i => i.UsuarioId == usuarioId && i.Endpoint == endpoint).ExecuteDeleteAsync(cancelamento);

    public Task<List<InscricaoPush>> DoUsuarioAsync(Guid usuarioId, CancellationToken cancelamento) =>
        banco.InscricoesPush.AsNoTracking()
            .Where(i => i.UsuarioId == usuarioId)
            .Select(i => new InscricaoPush(i.Endpoint, i.P256dh, i.Auth))
            .ToListAsync(cancelamento);

    public async Task MarcarEnviadoAsync(IReadOnlyCollection<string> endpoints, CancellationToken cancelamento)
    {
        var agora = relogio.Agora;
        await banco.InscricoesPush.Where(i => endpoints.Contains(i.Endpoint))
            .ExecuteUpdateAsync(s => s.SetProperty(i => i.UltimoEnvioEm, agora), cancelamento);
    }
}
