using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;
using NossoCombustivel.Infrastructure.Identidade;

namespace NossoCombustivel.Infrastructure.Persistencia;

public sealed class VeiculoConfiguracao : IEntityTypeConfiguration<Veiculo>
{
    public void Configure(EntityTypeBuilder<Veiculo> builder)
    {
        builder.ToTable("Veiculos");
        builder.HasKey(v => v.Id);
        builder.Property(v => v.Id).ValueGeneratedNever();
        builder.Property(v => v.Apelido).HasMaxLength(100).IsRequired();
        builder.Property(v => v.Marca).HasMaxLength(100).IsRequired();
        builder.Property(v => v.Modelo).HasMaxLength(200).IsRequired();
        builder.Property(v => v.CodigoFipe).HasMaxLength(20);
        builder.Property(v => v.TipoEnergia).HasConversion<string>().HasMaxLength(20);
        builder.Property(v => v.Combustiveis).HasMaxLength(100);
        builder.Property(v => v.CapacidadeTanqueL).HasPrecision(8, 3);
        builder.Property(v => v.CapacidadeBateriaKwh).HasPrecision(8, 3);
        builder.Ignore(v => v.ListaCombustiveis);
        builder.HasOne<Usuario>().WithMany().HasForeignKey(v => v.DonoId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(v => new { v.DonoId, v.SincronizadoEm });
    }
}

public sealed class AbastecimentoConfiguracao : IEntityTypeConfiguration<Abastecimento>
{
    public void Configure(EntityTypeBuilder<Abastecimento> builder)
    {
        builder.ToTable("Abastecimentos");
        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).ValueGeneratedNever();
        builder.Property(a => a.Combustivel).HasConversion<string>().HasMaxLength(20);
        builder.Property(a => a.Litros).HasPrecision(8, 3);
        builder.Property(a => a.PrecoLitro).HasPrecision(6, 3);
        builder.Property(a => a.ValorTotal).HasPrecision(10, 2);
        builder.Property(a => a.Posto).HasMaxLength(100);
        builder.HasOne<Veiculo>().WithMany().HasForeignKey(a => a.VeiculoId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(a => new { a.VeiculoId, a.SincronizadoEm });
    }
}

public sealed class RecargaConfiguracao : IEntityTypeConfiguration<Recarga>
{
    public void Configure(EntityTypeBuilder<Recarga> builder)
    {
        builder.ToTable("Recargas");
        builder.HasKey(r => r.Id);
        builder.Property(r => r.Id).ValueGeneratedNever();
        builder.Property(r => r.Local).HasConversion<string>().HasMaxLength(20);
        builder.Property(r => r.Kwh).HasPrecision(8, 3);
        builder.Property(r => r.PrecoKwh).HasPrecision(6, 3);
        builder.Property(r => r.ValorTotal).HasPrecision(10, 2);
        builder.HasOne<Veiculo>().WithMany().HasForeignKey(r => r.VeiculoId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(r => new { r.VeiculoId, r.SincronizadoEm });
    }
}
