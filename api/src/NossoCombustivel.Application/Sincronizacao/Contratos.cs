using NossoCombustivel.Domain.Cartoes;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Servicos;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Application.Sincronizacao;

public sealed record VeiculoSync(
    Guid Id,
    string Apelido,
    string Marca,
    string Modelo,
    int? Ano,
    string? CodigoFipe,
    TipoEnergia TipoEnergia,
    IReadOnlyList<Combustivel> Combustiveis,
    decimal? CapacidadeTanqueL,
    decimal? CapacidadeBateriaKwh,
    int OdometroInicial,
    DateTimeOffset CriadoEm,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm,
    TipoVeiculo? TipoVeiculo = null);

public sealed record AbastecimentoSync(
    Guid Id,
    Guid VeiculoId,
    DateTimeOffset Data,
    int Odometro,
    Combustivel Combustivel,
    decimal Litros,
    decimal PrecoLitro,
    decimal ValorTotal,
    bool TanqueCheio,
    string? Posto,
    DateTimeOffset CriadoEm,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm,
    FormaPagamento? FormaPagamento = null,
    Guid? CartaoId = null,
    bool? ContaNaMedia = null,
    Guid? PostoId = null,
    TipoGasolina? TipoGasolina = null);

public sealed record RecargaSync(
    Guid Id,
    Guid VeiculoId,
    DateTimeOffset Data,
    int Odometro,
    LocalRecarga Local,
    decimal Kwh,
    decimal PrecoKwh,
    decimal ValorTotal,
    bool CargaCompleta,
    DateTimeOffset CriadoEm,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm,
    FormaPagamento? FormaPagamento = null,
    Guid? CartaoId = null,
    bool? ContaNaMedia = null);

public sealed record CartaoSync(
    Guid Id,
    string Nome,
    int DiaFechamento,
    DateTimeOffset CriadoEm,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm,
    string? Banco = null);

public sealed record ServicoSync(
    Guid Id,
    Guid VeiculoId,
    TipoServico Tipo,
    DateTimeOffset Data,
    int? Odometro,
    IReadOnlyList<string> Categorias,
    string? Detalhes,
    decimal ValorTotal,
    decimal? ValorPecas,
    decimal? ValorMaoDeObra,
    Guid? LugarId,
    string? LugarNome,
    FormaPagamento? FormaPagamento,
    Guid? CartaoId,
    string? Observacao,
    DateTimeOffset CriadoEm,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm);

public sealed record PostoSync(Guid Id, string Nome, string? Bandeira, string? Endereco, double Latitude, double Longitude);

public sealed record LoteSync(
    IReadOnlyList<VeiculoSync> Veiculos,
    IReadOnlyList<AbastecimentoSync> Abastecimentos,
    IReadOnlyList<RecargaSync> Recargas,
    IReadOnlyList<CartaoSync>? Cartoes = null,
    IReadOnlyList<PostoSync>? Postos = null,
    IReadOnlyList<ServicoSync>? Servicos = null);

public sealed record Rejeitado(Guid Id, string Motivo);

public sealed record RespostaEnvio(IReadOnlyList<Rejeitado> Rejeitados);

public sealed record RespostaBusca(LoteSync Alteracoes, DateTimeOffset Cursor);

public interface IRepositorioSincronizacao
{
    Task<List<Veiculo>> ObterVeiculosAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento);
    Task<List<Abastecimento>> ObterAbastecimentosAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento);
    Task<List<Recarga>> ObterRecargasAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento);
    Task<HashSet<Guid>> IdsDosVeiculosDoUsuarioAsync(Guid usuarioId, CancellationToken cancelamento);
    Task<List<Veiculo>> VeiculosAlteradosAsync(Guid usuarioId, DateTimeOffset? desde, CancellationToken cancelamento);
    Task<List<Abastecimento>> AbastecimentosAlteradosAsync(IReadOnlyCollection<Guid> veiculoIds, DateTimeOffset? desde, CancellationToken cancelamento);
    Task<List<Recarga>> RecargasAlteradasAsync(IReadOnlyCollection<Guid> veiculoIds, DateTimeOffset? desde, CancellationToken cancelamento);
    Task<List<Cartao>> ObterCartoesAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento);
    Task<List<Cartao>> CartoesAlteradosAsync(Guid usuarioId, DateTimeOffset? desde, CancellationToken cancelamento);
    Task<List<Servico>> ObterServicosAsync(IReadOnlyCollection<Guid> ids, CancellationToken cancelamento);
    Task<List<Servico>> ServicosAlteradosAsync(IReadOnlyCollection<Guid> veiculoIds, DateTimeOffset? desde, CancellationToken cancelamento);
    void Adicionar(Servico servico);
    void Adicionar(Cartao cartao);
    void Adicionar(Veiculo veiculo);
    void Adicionar(RegistroEnergia registro);
    Task SalvarAsync(CancellationToken cancelamento);
}
