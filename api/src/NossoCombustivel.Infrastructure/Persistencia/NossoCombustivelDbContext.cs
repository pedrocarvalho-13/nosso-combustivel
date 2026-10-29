using Microsoft.EntityFrameworkCore;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class NossoCombustivelDbContext(DbContextOptions<NossoCombustivelDbContext> options) : DbContext(options)
{
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(NossoCombustivelDbContext).Assembly);
    }
}
