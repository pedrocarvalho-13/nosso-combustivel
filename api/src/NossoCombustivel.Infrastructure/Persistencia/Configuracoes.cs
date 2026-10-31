using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using NossoCombustivel.Domain.Cartoes;
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
        builder.Property(v => v.TipoVeiculo).HasConversion<string>().HasMaxLength(10).HasDefaultValue(TipoVeiculo.Carro);
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
        builder.Property(a => a.FormaPagamento).HasConversion<string>().HasMaxLength(10);
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
        builder.Property(r => r.FormaPagamento).HasConversion<string>().HasMaxLength(10);
        builder.HasOne<Veiculo>().WithMany().HasForeignKey(r => r.VeiculoId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(r => new { r.VeiculoId, r.SincronizadoEm });
    }
}

public sealed class CapacidadeVeiculoConfiguracao : IEntityTypeConfiguration<CapacidadeVeiculo>
{
    public void Configure(EntityTypeBuilder<CapacidadeVeiculo> builder)
    {
        builder.ToTable("CapacidadesVeiculo");
        builder.HasKey(c => c.Chave);
        builder.Property(c => c.Chave).HasMaxLength(300);
        builder.Property(c => c.TipoVeiculo).HasConversion<string>().HasMaxLength(10);
        builder.Property(c => c.Marca).HasMaxLength(100);
        builder.Property(c => c.Modelo).HasMaxLength(200);
        builder.Property(c => c.CodigoFipe).HasMaxLength(20);
        builder.Property(c => c.TipoEnergia).HasConversion<string>().HasMaxLength(20);
        builder.Property(c => c.TanqueL).HasPrecision(6, 1);
        builder.Property(c => c.BateriaKwh).HasPrecision(6, 1);
    }
}

public sealed class CartaoConfiguracao : IEntityTypeConfiguration<Cartao>
{
    public void Configure(EntityTypeBuilder<Cartao> builder)
    {
        builder.ToTable("Cartoes");
        builder.HasKey(c => c.Id);
        builder.Property(c => c.Id).ValueGeneratedNever();
        builder.Property(c => c.Nome).HasMaxLength(60).IsRequired();
        builder.Property(c => c.Banco).HasMaxLength(40);
        builder.HasOne<Usuario>().WithMany().HasForeignKey(c => c.DonoId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(c => new { c.DonoId, c.SincronizadoEm });
    }
}
