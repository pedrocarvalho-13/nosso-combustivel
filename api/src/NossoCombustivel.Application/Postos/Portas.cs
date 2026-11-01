using NossoCombustivel.Domain.Postos;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Application.Postos;

public sealed record PostoEncontrado(
    TipoPosto Tipo,
    OrigemPosto Origem, string IdExterno, string Nome, string? Bandeira, string? Endereco, double Latitude, double Longitude, string? Horario = null);

public sealed record PrecoInformado(Combustivel Combustivel, decimal PrecoLitro, DateTimeOffset Data, TipoGasolina? TipoGasolina = null);

public sealed record PrecoDoPosto(Guid PostoId, Combustivel Combustivel, TipoGasolina? TipoGasolina, decimal PrecoLitro, DateTimeOffset Data);

public sealed record PostoProximo(
    Guid Id, string Nome, string? Bandeira, string? Endereco, double Latitude, double Longitude, int DistanciaMetros,
    IReadOnlyList<PrecoInformado>? Precos = null,
    string? Horario = null);

public sealed record PostosProximos(IReadOnlyList<PostoProximo> Postos, bool BuscaCompleta);

public sealed class BuscaPostosIndisponivelException() : Exception("A busca de postos está indisponível agora.");

public interface IBuscaPostos
{
    OrigemPosto Origem { get; }
    Task<IReadOnlyList<PostoEncontrado>> BuscarProximosAsync(TipoPosto tipo, double latitude, double longitude, int raioMetros, CancellationToken cancelamento);
}

public interface IRepositorioPostos
{
    Task<List<Posto>> ObterAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento);
    Task<List<Posto>> ObterPorExternosAsync(OrigemPosto origem, IReadOnlyCollection<string> idsExternos, CancellationToken cancelamento);
    Task<List<Posto>> NaAreaAsync(TipoPosto tipo, double latitudeMin, double latitudeMax, double longitudeMin, double longitudeMax, CancellationToken cancelamento);
    Task<List<PrecoDoPosto>> PrecosDesdeAsync(IReadOnlyCollection<Guid> postoIds, DateTimeOffset desde, CancellationToken cancelamento);
    Task<bool> AreaBuscadaDesdeAsync(string chave, DateTimeOffset desde, CancellationToken cancelamento);
    Task MarcarAreaBuscadaAsync(string chave, DateTimeOffset quando, CancellationToken cancelamento);
    void Adicionar(Posto posto);
    Task SalvarAsync(CancellationToken cancelamento);
}
