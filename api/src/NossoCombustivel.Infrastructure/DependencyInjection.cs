using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Contas;
using NossoCombustivel.Infrastructure.Identidade;
using NossoCombustivel.Infrastructure.Persistencia;

namespace NossoCombustivel.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<NossoCombustivelDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("Banco")));

        services
            .AddIdentityCore<Usuario>(opcoes =>
            {
                opcoes.User.RequireUniqueEmail = true;
                opcoes.Password.RequiredLength = 8;
                opcoes.Password.RequireDigit = true;
                opcoes.Password.RequireLowercase = true;
                opcoes.Password.RequireUppercase = false;
                opcoes.Password.RequireNonAlphanumeric = false;
            })
            .AddEntityFrameworkStores<NossoCombustivelDbContext>()
            .AddErrorDescriber<DescritorErrosIdentidade>();

        services
            .AddOptions<OpcoesJwt>()
            .Bind(configuration.GetSection(OpcoesJwt.Secao))
            .Validate(o => !string.IsNullOrWhiteSpace(o.Chave) && Convert.FromBase64String(o.Chave).Length >= 32,
                "Configure Jwt:Chave com pelo menos 32 bytes em base64 (user-secrets em desenvolvimento).")
            .ValidateOnStart();
        services.Configure<OpcoesSessao>(configuration.GetSection("Sessao"));

        services.AddSingleton<IRelogio, RelogioSistema>();
        services.AddSingleton<IEmissorTokens, EmissorTokensJwt>();
        services.AddScoped<IServicoContas, ServicoContas>();
        services.AddScoped<IRepositorioSessoes, RepositorioSessoes>();

        return services;
    }
}
