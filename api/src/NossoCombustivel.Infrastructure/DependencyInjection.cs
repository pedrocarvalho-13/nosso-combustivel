using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Contas;
using NossoCombustivel.Application.Ia;
using NossoCombustivel.Application.Sincronizacao;
using NossoCombustivel.Infrastructure.Ia;
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
            .Validate(o => o.ChaveValida,
                $"Configure Jwt:Chave com pelo menos {OpcoesJwt.TamanhoMinimoDaChave} caracteres (user-secrets em desenvolvimento).")
            .ValidateOnStart();
        services.Configure<OpcoesSessao>(configuration.GetSection("Sessao"));

        services.AddSingleton<IRelogio, RelogioSistema>();
        services.AddSingleton<IEmissorTokens, EmissorTokensJwt>();
        services.AddScoped<IServicoContas, ServicoContas>();
        services.AddScoped<IRepositorioSessoes, RepositorioSessoes>();
        services.AddScoped<IRepositorioSincronizacao, RepositorioSincronizacao>();
        services.AddScoped<IRepositorioCapacidades, RepositorioCapacidades>();

        services.Configure<OpcoesGemini>(configuration.GetSection(OpcoesGemini.Secao));
        services.AddHttpClient<IAssistenteIa, AssistenteGemini>((provedor, http) =>
        {
            var gemini = provedor.GetRequiredService<IOptions<OpcoesGemini>>().Value;
            http.BaseAddress = new Uri(gemini.Endereco);
            http.Timeout = TimeSpan.FromSeconds(gemini.SegundosLimite);
        });

        return services;
    }
}
