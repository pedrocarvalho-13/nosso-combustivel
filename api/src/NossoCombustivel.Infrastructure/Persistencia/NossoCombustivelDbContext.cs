using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using NossoCombustivel.Infrastructure.Identidade;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class NossoCombustivelDbContext(DbContextOptions<NossoCombustivelDbContext> options)
    : IdentityDbContext<Usuario, IdentityRole<Guid>, Guid>(options)
{
    public DbSet<SessaoRefresh> Sessoes => Set<SessaoRefresh>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.Entity<Usuario>().Property(u => u.Nome).HasMaxLength(100).IsRequired();
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(NossoCombustivelDbContext).Assembly);
    }
}
