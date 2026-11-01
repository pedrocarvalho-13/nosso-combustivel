using Microsoft.EntityFrameworkCore;
using NossoCombustivel.Application.Postos;
using NossoCombustivel.Domain.Postos;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class AreaBuscada
{
    public required string Chave { get; init; }
    public DateTimeOffset BuscadoEm { get; set; }
}

public sealed class RepositorioPostos(NossoCombustivelDbContext banco) : IRepositorioPostos
{
    public Task<List<Posto>> ObterAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento) =>
        banco.Postos.AsNoTracking().Where(p => ids.Contains(p.Id)).ToListAsync(cancelamento);

    public Task<List<Posto>> ObterPorExternosAsync(OrigemPosto origem, IReadOnlyCollection<string> idsExternos, CancellationToken cancelamento) =>
        banco.Postos.Where(p => p.Origem == origem && idsExternos.Contains(p.IdExterno!)).ToListAsync(cancelamento);

    public Task<List<Posto>> NaAreaAsync(
        TipoPosto tipo, double latitudeMin, double latitudeMax, double longitudeMin, double longitudeMax, CancellationToken cancelamento) =>
        banco.Postos.AsNoTracking()
            .Where(p => p.Tipo == tipo && p.Latitude >= latitudeMin && p.Latitude <= latitudeMax && p.Longitude >= longitudeMin && p.Longitude <= longitudeMax)
            .ToListAsync(cancelamento);

    public Task<List<PrecoDoPosto>> PrecosDesdeAsync(IReadOnlyCollection<Guid> postoIds, DateTimeOffset desde, CancellationToken cancelamento) =>
        banco.Abastecimentos.AsNoTracking()
            .Where(a => a.PostoId != null && postoIds.Contains(a.PostoId.Value) && a.ExcluidoEm == null && a.Data >= desde)
            .Select(a => new PrecoDoPosto(a.PostoId!.Value, a.Combustivel, a.TipoGasolina, a.PrecoLitro, a.Data))
            .ToListAsync(cancelamento);

    public Task<bool> AreaBuscadaDesdeAsync(string chave, DateTimeOffset desde, CancellationToken cancelamento) =>
        banco.AreasBuscadas.AnyAsync(a => a.Chave == chave && a.BuscadoEm >= desde, cancelamento);

    public async Task MarcarAreaBuscadaAsync(string chave, DateTimeOffset quando, CancellationToken cancelamento)
    {
        var area = await banco.AreasBuscadas.FindAsync([chave], cancelamento);
        if (area is null)
            banco.AreasBuscadas.Add(new AreaBuscada { Chave = chave, BuscadoEm = quando });
        else
            area.BuscadoEm = quando;
    }

    public void Adicionar(Posto posto) => banco.Postos.Add(posto);

    public Task SalvarAsync(CancellationToken cancelamento) => banco.SaveChangesAsync(cancelamento);
}
