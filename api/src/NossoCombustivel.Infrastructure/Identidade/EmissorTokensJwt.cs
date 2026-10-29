using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Application.Contas;

namespace NossoCombustivel.Infrastructure.Identidade;

public sealed class OpcoesJwt
{
    public const string Secao = "Jwt";

    public string Emissor { get; set; } = string.Empty;
    public string Audiencia { get; set; } = string.Empty;
    public string Chave { get; set; } = string.Empty;
    public int MinutosAcesso { get; set; } = 15;

    public const int TamanhoMinimoDaChave = 32;

    public bool ChaveValida => !string.IsNullOrWhiteSpace(Chave) && Chave.Length >= TamanhoMinimoDaChave;

    public SymmetricSecurityKey ChaveDeAssinatura() => new(SHA256.HashData(Encoding.UTF8.GetBytes(Chave)));
}

public sealed class EmissorTokensJwt(IOptions<OpcoesJwt> opcoes, IRelogio relogio) : IEmissorTokens
{
    private readonly JsonWebTokenHandler _manipulador = new();

    public TokenAcesso Emitir(UsuarioConta usuario)
    {
        var configuracao = opcoes.Value;
        var expiraEm = relogio.Agora.AddMinutes(configuracao.MinutosAcesso);
        var token = _manipulador.CreateToken(new SecurityTokenDescriptor
        {
            Issuer = configuracao.Emissor,
            Audience = configuracao.Audiencia,
            IssuedAt = relogio.Agora.UtcDateTime,
            NotBefore = relogio.Agora.UtcDateTime,
            Expires = expiraEm.UtcDateTime,
            Subject = new ClaimsIdentity(
            [
                new Claim(JwtRegisteredClaimNames.Sub, usuario.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, usuario.Email),
                new Claim(JwtRegisteredClaimNames.Name, usuario.Nome)
            ]),
            SigningCredentials = new SigningCredentials(configuracao.ChaveDeAssinatura(), SecurityAlgorithms.HmacSha256)
        });
        return new TokenAcesso(token, expiraEm);
    }
}
