using Microsoft.EntityFrameworkCore;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Ia;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class CapacidadeVeiculo
{
    public required string Chave { get; init; }
    public TipoVeiculo TipoVeiculo { get; init; }
    public required string Marca { get; init; }
    public required string Modelo { get; init; }
    public int? Ano { get; init; }
    public string? CodigoFipe { get; init; }
    public TipoEnergia TipoEnergia { get; init; }
    public decimal? TanqueL { get; init; }
    public decimal? BateriaKwh { get; init; }
    public DateTimeOffset CriadoEm { get; init; }
}

public sealed class RepositorioCapacidades(NossoCombustivelDbContext banco, IRelogio relogio) : IRepositorioCapacidades
{
    public async Task<CapacidadeEstimada?> ObterAsync(string chave, CancellationToken cancelamento)
    {
        var linha = await banco.Capacidades.AsNoTracking().FirstOrDefaultAsync(c => c.Chave == chave, cancelamento);
        return linha is null ? null : new CapacidadeEstimada(linha.TanqueL, linha.BateriaKwh);
    }

    public async Task SalvarAsync(
        string chave, VeiculoConsultado veiculo, string? codigoFipe, CapacidadeEstimada capacidade, CancellationToken cancelamento)
    {
        banco.Capacidades.Add(new CapacidadeVeiculo
        {
            Chave = chave,
            TipoVeiculo = veiculo.TipoVeiculo,
            Marca = veiculo.Marca.Trim(),
            Modelo = veiculo.Modelo.Trim(),
            Ano = veiculo.Ano,
            CodigoFipe = string.IsNullOrWhiteSpace(codigoFipe) ? null : codigoFipe.Trim(),
            TipoEnergia = veiculo.TipoEnergia,
            TanqueL = capacidade.TanqueL,
            BateriaKwh = capacidade.BateriaKwh,
            CriadoEm = relogio.Agora
        });
        try
        {
            await banco.SaveChangesAsync(cancelamento);
        }
        catch (DbUpdateException)
        {
            banco.ChangeTracker.Clear();
        }
    }
}
