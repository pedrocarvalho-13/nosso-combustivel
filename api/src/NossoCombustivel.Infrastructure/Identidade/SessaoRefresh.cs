using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace NossoCombustivel.Infrastructure.Identidade;

public sealed class SessaoRefresh
{
    public Guid Id { get; set; }
    public Guid UsuarioId { get; set; }
    public string TokenHash { get; set; } = string.Empty;
    public DateTimeOffset CriadoEm { get; set; }
    public DateTimeOffset ExpiraEm { get; set; }
    public DateTimeOffset? RevogadoEm { get; set; }
}

public sealed class SessaoRefreshConfiguracao : IEntityTypeConfiguration<SessaoRefresh>
{
    public void Configure(EntityTypeBuilder<SessaoRefresh> builder)
    {
        builder.ToTable("SessoesRefresh");
        builder.HasKey(s => s.Id);
        builder.Property(s => s.TokenHash).HasMaxLength(64).IsRequired();
        builder.HasIndex(s => s.TokenHash).IsUnique();
        builder.HasOne<Usuario>().WithMany().HasForeignKey(s => s.UsuarioId).OnDelete(DeleteBehavior.Cascade);
    }
}
