using Microsoft.AspNetCore.Identity;

namespace NossoCombustivel.Infrastructure.Identidade;

public sealed class Usuario : IdentityUser<Guid>
{
    public string Nome { get; set; } = string.Empty;
    public DateTimeOffset CriadoEm { get; set; }
}
