using Microsoft.Extensions.DependencyInjection;
using NossoCombustivel.Application.Contas;
using NossoCombustivel.Application.Ia;
using NossoCombustivel.Application.Notificacoes;
using NossoCombustivel.Application.Postos;
using NossoCombustivel.Application.Sincronizacao;

namespace NossoCombustivel.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ServicoSessoes>();
        services.AddScoped<ServicoSincronizacao>();
        services.AddScoped<ServicoIa>();
        services.AddScoped<ServicoPostos>();
        services.AddScoped<ServicoNotificacoes>();
        return services;
    }
}
