using Microsoft.EntityFrameworkCore;
using NossoCombustivel.Application.Sincronizacao;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class RepositorioSincronizacao(NossoCombustivelDbContext banco) : IRepositorioSincronizacao
{
    public Task<List<Veiculo>> ObterVeiculosAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento) =>
        banco.Veiculos.Where(v => ids.Contains(v.Id)).ToListAsync(cancelamento);

    public Task<List<Abastecimento>> ObterAbastecimentosAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento) =>
        banco.Abastecimentos.Where(a => ids.Contains(a.Id)).ToListAsync(cancelamento);

    public Task<List<Recarga>> ObterRecargasAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento) =>
        banco.Recargas.Where(r => ids.Contains(r.Id)).ToListAsync(cancelamento);

    public async Task<HashSet<Guid>> IdsDosVeiculosDoUsuarioAsync(Guid usuarioId, CancellationToken cancelamento) =>
        (await banco.Veiculos.Where(v => v.DonoId == usuarioId).Select(v => v.Id).ToListAsync(cancelamento)).ToHashSet();

    public Task<List<Veiculo>> VeiculosAlteradosAsync(Guid usuarioId, DateTimeOffset? desde, CancellationToken cancelamento) =>
        banco.Veiculos.AsNoTracking()
            .Where(v => v.DonoId == usuarioId && (desde == null || v.SincronizadoEm > desde))
            .ToListAsync(cancelamento);

    public Task<List<Abastecimento>> AbastecimentosAlteradosAsync(IReadOnlyCollection<Guid> veiculoIds, DateTimeOffset? desde, CancellationToken cancelamento) =>
        banco.Abastecimentos.AsNoTracking()
            .Where(a => veiculoIds.Contains(a.VeiculoId) && (desde == null || a.SincronizadoEm > desde))
            .ToListAsync(cancelamento);

    public Task<List<Recarga>> RecargasAlteradasAsync(IReadOnlyCollection<Guid> veiculoIds, DateTimeOffset? desde, CancellationToken cancelamento) =>
        banco.Recargas.AsNoTracking()
            .Where(r => veiculoIds.Contains(r.VeiculoId) && (desde == null || r.SincronizadoEm > desde))
            .ToListAsync(cancelamento);

    public void Adicionar(Veiculo veiculo) => banco.Veiculos.Add(veiculo);

    public void Adicionar(RegistroEnergia registro) => banco.Add(registro);

    public Task SalvarAsync(CancellationToken cancelamento) => banco.SaveChangesAsync(cancelamento);
}
