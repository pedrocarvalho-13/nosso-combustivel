using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NossoCombustivel.Infrastructure.Persistencia;

namespace NossoCombustivel.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<NossoCombustivelDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("Banco")));

        return services;
    }
}
