using NossoCombustivel.Application.Comum;

namespace NossoCombustivel.Infrastructure;

public sealed class RelogioSistema : IRelogio
{
    public DateTimeOffset Agora => DateTimeOffset.UtcNow;
}
