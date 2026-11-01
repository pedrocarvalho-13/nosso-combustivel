namespace NossoCombustivel.Domain.Postos;

public enum OrigemPosto
{
    OpenStreetMap = 1,
    Google = 2,
    Manual = 3
}

public sealed record DadosPosto(string Nome, string? Bandeira, string? Endereco, double Latitude, double Longitude);

public sealed class Posto
{
    private Posto()
    {
    }

    public Guid Id { get; private set; }
    public OrigemPosto Origem { get; private set; }
    public string? IdExterno { get; private set; }
    public string Nome { get; private set; } = string.Empty;
    public string? Bandeira { get; private set; }
    public string? Endereco { get; private set; }
    public double Latitude { get; private set; }
    public double Longitude { get; private set; }
    public Guid? CriadoPor { get; private set; }
    public DateTimeOffset CriadoEm { get; private set; }
    public DateTimeOffset AtualizadoEm { get; private set; }

    public static Posto Criar(Guid id, OrigemPosto origem, string? idExterno, DadosPosto dados, Guid? criadoPor, DateTimeOffset agora)
    {
        if (origem != OrigemPosto.Manual && string.IsNullOrWhiteSpace(idExterno))
            throw new ExcecaoDeDominio("Posto de busca precisa do identificador da origem.");
        var posto = new Posto
        {
            Id = id,
            Origem = origem,
            IdExterno = origem == OrigemPosto.Manual ? null : idExterno!.Trim(),
            CriadoPor = criadoPor,
            CriadoEm = agora
        };
        posto.Copiar(Limpar(dados), agora);
        return posto;
    }

    public bool Atualizar(DadosPosto dados, DateTimeOffset agora)
    {
        var limpos = Limpar(dados);
        if (limpos == new DadosPosto(Nome, Bandeira, Endereco, Latitude, Longitude))
            return false;
        Copiar(limpos, agora);
        return true;
    }

    private void Copiar(DadosPosto limpos, DateTimeOffset agora)
    {
        Nome = limpos.Nome;
        Bandeira = limpos.Bandeira;
        Endereco = limpos.Endereco;
        Latitude = limpos.Latitude;
        Longitude = limpos.Longitude;
        AtualizadoEm = agora;
    }

    private static DadosPosto Limpar(DadosPosto dados)
    {
        if (string.IsNullOrWhiteSpace(dados.Nome) || dados.Nome.Trim().Length > 100)
            throw new ExcecaoDeDominio("O nome do posto precisa ter de 1 a 100 letras.");
        if (dados.Bandeira?.Trim().Length > 60)
            throw new ExcecaoDeDominio("A bandeira do posto tem até 60 letras.");
        if (dados.Latitude is < -90 or > 90 || dados.Longitude is < -180 or > 180)
            throw new ExcecaoDeDominio("Localização do posto inválida.");
        var endereco = string.IsNullOrWhiteSpace(dados.Endereco) ? null : dados.Endereco.Trim();
        return new DadosPosto(
            dados.Nome.Trim(),
            string.IsNullOrWhiteSpace(dados.Bandeira) ? null : dados.Bandeira.Trim(),
            endereco?.Length > 200 ? endereco[..200] : endereco,
            Math.Round(dados.Latitude, 7),
            Math.Round(dados.Longitude, 7));
    }
}
