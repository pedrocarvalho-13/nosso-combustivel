using Microsoft.EntityFrameworkCore;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Contas;
using NossoCombustivel.Infrastructure.Persistencia;

namespace NossoCombustivel.Infrastructure.Identidade;

public sealed class RepositorioSessoes(NossoCombustivelDbContext banco, IRelogio relogio) : IRepositorioSessoes
{
    public async Task SalvarAsync(Guid usuarioId, string tokenHash, DateTimeOffset expiraEm, CancellationToken cancelamento)
    {
        banco.Sessoes.Add(new SessaoRefresh
        {
            Id = Guid.CreateVersion7(),
            UsuarioId = usuarioId,
            TokenHash = tokenHash,
            CriadoEm = relogio.Agora,
            ExpiraEm = expiraEm
        });
        await banco.SaveChangesAsync(cancelamento);
    }

    public async Task<SessaoArmazenada?> ObterAsync(string tokenHash, CancellationToken cancelamento)
    {
        var sessao = await banco.Sessoes.AsNoTracking().FirstOrDefaultAsync(s => s.TokenHash == tokenHash, cancelamento);
        return sessao is null ? null : new SessaoArmazenada(sessao.UsuarioId, sessao.ExpiraEm, sessao.RevogadoEm is not null);
    }

    public async Task RevogarAsync(string tokenHash, CancellationToken cancelamento)
    {
        var sessao = await banco.Sessoes.FirstOrDefaultAsync(s => s.TokenHash == tokenHash, cancelamento);
        if (sessao is null || sessao.RevogadoEm is not null)
            return;
        sessao.RevogadoEm = relogio.Agora;
        await banco.SaveChangesAsync(cancelamento);
    }
}
