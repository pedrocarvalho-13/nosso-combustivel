using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Application.Ia;

public sealed record VeiculoConsultado(TipoVeiculo TipoVeiculo, string Marca, string Modelo, int? Ano, TipoEnergia TipoEnergia);

public sealed record CapacidadeEstimada(decimal? TanqueL, decimal? BateriaKwh);

public sealed record IntervaloSugerido(int? Km, int? Meses, int? KmSevero, int? MesesSevero, string? Observacao);

public enum TipoLeitura
{
    Abastecimento,
    Recarga,
    Hodometro
}

public sealed record LeituraFoto(
    decimal? Litros,
    decimal? PrecoLitro,
    decimal? Kwh,
    decimal? PrecoKwh,
    decimal? ValorTotal,
    int? Odometro,
    Combustivel? Combustivel);

public sealed class IaIndisponivelException() : Exception("A IA está ocupada agora.");

public interface IAssistenteIa
{
    bool Disponivel { get; }
    Task<CapacidadeEstimada?> EstimarCapacidadeAsync(VeiculoConsultado veiculo, CancellationToken cancelamento);
    Task<LeituraFoto?> LerFotoAsync(byte[] imagem, string tipoMime, TipoLeitura tipo, CancellationToken cancelamento);
    Task<IntervaloSugerido?> EstimarIntervaloAsync(VeiculoConsultado veiculo, string servico, string? detalhe, CancellationToken cancelamento);
}

public interface IRepositorioCapacidades
{
    Task<CapacidadeEstimada?> ObterAsync(string chave, CancellationToken cancelamento);
    Task SalvarAsync(string chave, VeiculoConsultado veiculo, string? codigoFipe, CapacidadeEstimada capacidade, CancellationToken cancelamento);
}

public interface IRepositorioIntervalos
{
    Task<IntervaloSugerido?> ObterAsync(string chave, CancellationToken cancelamento);
    Task SalvarAsync(string chave, IntervaloSugerido intervalo, CancellationToken cancelamento);
}
