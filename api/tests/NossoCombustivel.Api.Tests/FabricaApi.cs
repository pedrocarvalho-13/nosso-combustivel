using System.Security.Cryptography;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using NossoCombustivel.Infrastructure.Persistencia;

namespace NossoCombustivel.Api.Tests;

public sealed class FabricaApi : WebApplicationFactory<Program>
{
    private readonly SqliteConnection _conexao = new("DataSource=:memory:");

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testes");
        builder.UseSetting("Jwt:Chave", Convert.ToBase64String(RandomNumberGenerator.GetBytes(48)));
        builder.UseSetting("ConnectionStrings:Banco", "Host=nao-usado");

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<DbContextOptions<NossoCombustivelDbContext>>();
            services.RemoveAll(typeof(IDbContextOptionsConfiguration<NossoCombustivelDbContext>));

            _conexao.Open();
            services.AddDbContext<NossoCombustivelDbContext>(options => options.UseSqlite(_conexao));

            using var escopo = services.BuildServiceProvider().CreateScope();
            escopo.ServiceProvider.GetRequiredService<NossoCombustivelDbContext>().Database.EnsureCreated();
        });
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        _conexao.Dispose();
    }
}
