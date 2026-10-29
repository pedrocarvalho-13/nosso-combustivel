using NossoCombustivel.Domain.ObjetosDeValor;

namespace NossoCombustivel.Domain.Veiculos;

public sealed record DadosVeiculo(
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
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm);

public sealed class Veiculo
{
    private Veiculo()
    {
    }

    public Guid Id { get; private set; }
    public Guid DonoId { get; private set; }
    public string Apelido { get; private set; } = string.Empty;
    public string Marca { get; private set; } = string.Empty;
    public string Modelo { get; private set; } = string.Empty;
    public int? Ano { get; private set; }
    public string? CodigoFipe { get; private set; }
    public TipoEnergia TipoEnergia { get; private set; }
    public string Combustiveis { get; private set; } = string.Empty;
    public decimal? CapacidadeTanqueL { get; private set; }
    public decimal? CapacidadeBateriaKwh { get; private set; }
    public int OdometroInicial { get; private set; }
    public DateTimeOffset CriadoEm { get; private set; }
    public DateTimeOffset AtualizadoEm { get; private set; }
    public DateTimeOffset? ExcluidoEm { get; private set; }
    public DateTimeOffset SincronizadoEm { get; private set; }

    public IReadOnlyList<Combustivel> ListaCombustiveis =>
        Combustiveis.Length == 0 ? [] : Combustiveis.Split(',').Select(Enum.Parse<Combustivel>).ToList();

    public static Veiculo Criar(Guid id, Guid donoId, DadosVeiculo dados, DateTimeOffset criadoEm, DateTimeOffset agora)
    {
        Validar(dados);
        var veiculo = new Veiculo { Id = id, DonoId = donoId, CriadoEm = criadoEm };
        veiculo.Copiar(dados, agora);
        return veiculo;
    }

    public bool Aplicar(DadosVeiculo dados, DateTimeOffset agora)
    {
        if (dados.AtualizadoEm <= AtualizadoEm)
            return false;
        Validar(dados);
        Copiar(dados, agora);
        return true;
    }

    private void Copiar(DadosVeiculo dados, DateTimeOffset agora)
    {
        Apelido = dados.Apelido.Trim();
        Marca = dados.Marca.Trim();
        Modelo = dados.Modelo.Trim();
        Ano = dados.Ano;
        CodigoFipe = dados.CodigoFipe;
        TipoEnergia = dados.TipoEnergia;
        Combustiveis = string.Join(',', dados.Combustiveis.Distinct());
        CapacidadeTanqueL = dados.CapacidadeTanqueL;
        CapacidadeBateriaKwh = dados.CapacidadeBateriaKwh;
        OdometroInicial = dados.OdometroInicial;
        AtualizadoEm = dados.AtualizadoEm;
        ExcluidoEm = dados.ExcluidoEm;
        SincronizadoEm = agora;
    }

    private static void Validar(DadosVeiculo dados)
    {
        if (string.IsNullOrWhiteSpace(dados.Apelido) || dados.Apelido.Length > 100)
            throw new ExcecaoDeDominio("O apelido do carro é obrigatório e tem até 100 letras.");
        if (string.IsNullOrWhiteSpace(dados.Marca) || string.IsNullOrWhiteSpace(dados.Modelo))
            throw new ExcecaoDeDominio("Marca e modelo do carro são obrigatórios.");
        if (dados.TipoEnergia != TipoEnergia.Eletrico && dados.Combustiveis.Count == 0)
            throw new ExcecaoDeDominio("Um carro que abastece precisa de pelo menos um combustível.");
        if (dados.CapacidadeTanqueL <= 0 || dados.CapacidadeBateriaKwh <= 0)
            throw new ExcecaoDeDominio("A capacidade do tanque e da bateria precisa ser positiva.");
        _ = new Odometro(dados.OdometroInicial);
    }
}
