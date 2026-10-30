using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;
using NossoCombustivel.Infrastructure.Identidade;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class NossoCombustivelDbContext(DbContextOptions<NossoCombustivelDbContext> options)
    : IdentityDbContext<Usuario, IdentityRole<Guid>, Guid>(options)
{
    public DbSet<SessaoRefresh> Sessoes => Set<SessaoRefresh>();
    public DbSet<Veiculo> Veiculos => Set<Veiculo>();
    public DbSet<Abastecimento> Abastecimentos => Set<Abastecimento>();
    public DbSet<Recarga> Recargas => Set<Recarga>();
    public DbSet<CapacidadeVeiculo> Capacidades => Set<CapacidadeVeiculo>();

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        if (Database.ProviderName == "Microsoft.EntityFrameworkCore.Sqlite")
        {
            configurationBuilder.Properties<DateTimeOffset>().HaveConversion<DateTimeOffsetToBinaryConverter>();
            configurationBuilder.Properties<decimal>().HaveConversion<double>();
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.Entity<Usuario>().Property(u => u.Nome).HasMaxLength(100).IsRequired();
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(NossoCombustivelDbContext).Assembly);
    }
}
