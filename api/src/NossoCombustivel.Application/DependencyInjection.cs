using Microsoft.Extensions.DependencyInjection;
using NossoCombustivel.Application.Contas;

namespace NossoCombustivel.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ServicoSessoes>();
        return services;
    }
}
