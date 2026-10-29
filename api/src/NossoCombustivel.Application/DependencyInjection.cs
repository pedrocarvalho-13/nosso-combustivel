using Microsoft.Extensions.DependencyInjection;
using NossoCombustivel.Application.Contas;
using NossoCombustivel.Application.Sincronizacao;

namespace NossoCombustivel.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ServicoSessoes>();
        services.AddScoped<ServicoSincronizacao>();
        return services;
    }
}
