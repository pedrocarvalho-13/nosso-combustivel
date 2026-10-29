using Microsoft.AspNetCore.Identity;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Contas;

namespace NossoCombustivel.Infrastructure.Identidade;

public sealed class ServicoContas(UserManager<Usuario> usuarios, IRelogio relogio) : IServicoContas
{
    private static readonly string[] CodigosDeConflito =
        [nameof(IdentityErrorDescriber.DuplicateEmail), nameof(IdentityErrorDescriber.DuplicateUserName)];

    public async Task<Resultado<UsuarioConta>> CriarAsync(string nome, string email, string senha, CancellationToken cancelamento)
    {
        var usuario = new Usuario
        {
            Id = Guid.CreateVersion7(),
            Nome = nome,
            Email = email,
            UserName = email,
            CriadoEm = relogio.Agora
        };

        var resultado = await usuarios.CreateAsync(usuario, senha);
        if (resultado.Succeeded)
            return Resultado<UsuarioConta>.Ok(ParaConta(usuario));

        var conflito = resultado.Errors.FirstOrDefault(e => CodigosDeConflito.Contains(e.Code));
        if (conflito is not null)
            return Resultado<UsuarioConta>.Falha(TipoErro.Conflito, conflito.Description);

        var mensagens = resultado.Errors.Select(e => e.Description).Distinct();
        return Resultado<UsuarioConta>.Falha(TipoErro.Validacao, string.Join(" ", mensagens));
    }

    public async Task<UsuarioConta?> ValidarCredenciaisAsync(string email, string senha, CancellationToken cancelamento)
    {
        var usuario = await usuarios.FindByEmailAsync(email);
        if (usuario is null || !await usuarios.CheckPasswordAsync(usuario, senha))
            return null;
        return ParaConta(usuario);
    }

    public async Task<UsuarioConta?> ObterAsync(Guid id, CancellationToken cancelamento)
    {
        var usuario = await usuarios.FindByIdAsync(id.ToString());
        return usuario is null ? null : ParaConta(usuario);
    }

    private static UsuarioConta ParaConta(Usuario usuario) => new(usuario.Id, usuario.Nome, usuario.Email!);
}
