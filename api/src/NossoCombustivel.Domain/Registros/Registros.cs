using NossoCombustivel.Domain.ObjetosDeValor;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Domain.Registros;

public enum LocalRecarga
{
    Casa = 1,
    Trabalho = 2,
    Eletroposto = 3
}

public enum FormaPagamento
{
    Credito = 1,
    Debito = 2,
    Pix = 3,
    Dinheiro = 4
}

public enum TipoGasolina
{
    Comum = 1,
    Aditivada = 2,
    Premium = 3
}

public sealed record DadosAbastecimento(
    DateTimeOffset Data,
    int Odometro,
    Combustivel Combustivel,
    decimal Litros,
    decimal PrecoLitro,
    decimal ValorTotal,
    bool TanqueCheio,
    string? Posto,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm,
    FormaPagamento? FormaPagamento = null,
    Guid? CartaoId = null,
    bool ContaNaMedia = true,
    Guid? PostoId = null,
    TipoGasolina? TipoGasolina = null);

public sealed record DadosRecarga(
    DateTimeOffset Data,
    int Odometro,
    LocalRecarga Local,
    decimal Kwh,
    decimal PrecoKwh,
    decimal ValorTotal,
    bool CargaCompleta,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm,
    FormaPagamento? FormaPagamento = null,
    Guid? CartaoId = null,
    bool ContaNaMedia = true);

public abstract class RegistroEnergia
{
    public Guid Id { get; protected set; }
    public Guid VeiculoId { get; protected set; }
    public Guid UsuarioId { get; protected set; }
    public DateTimeOffset Data { get; protected set; }
    public int Odometro { get; protected set; }
    public decimal ValorTotal { get; protected set; }
    public DateTimeOffset CriadoEm { get; protected set; }
    public DateTimeOffset AtualizadoEm { get; protected set; }
    public DateTimeOffset? ExcluidoEm { get; protected set; }
    public DateTimeOffset SincronizadoEm { get; protected set; }
    public FormaPagamento? FormaPagamento { get; protected set; }
    public Guid? CartaoId { get; protected set; }
    public bool ContaNaMedia { get; protected set; } = true;

    protected void CopiarPagamento(FormaPagamento? formaPagamento, Guid? cartaoId)
    {
        FormaPagamento = formaPagamento;
        CartaoId = formaPagamento == Registros.FormaPagamento.Credito ? cartaoId : null;
    }

    protected void CopiarComum(DateTimeOffset data, int odometro, decimal valorTotal, DateTimeOffset atualizadoEm, DateTimeOffset? excluidoEm, DateTimeOffset agora)
    {
        Data = data;
        Odometro = new Odometro(odometro).Km;
        ValorTotal = new Dinheiro(valorTotal).Valor;
        AtualizadoEm = atualizadoEm;
        ExcluidoEm = excluidoEm;
        SincronizadoEm = agora;
    }

    protected static void ValidarComum(int odometro, decimal valorTotal)
    {
        _ = new Odometro(odometro);
        _ = new Dinheiro(valorTotal);
    }
}

public sealed class Abastecimento : RegistroEnergia
{
    private Abastecimento()
    {
    }

    public Combustivel Combustivel { get; private set; }
    public decimal Litros { get; private set; }
    public decimal PrecoLitro { get; private set; }
    public bool TanqueCheio { get; private set; }
    public string? Posto { get; private set; }
    public Guid? PostoId { get; private set; }
    public TipoGasolina? TipoGasolina { get; private set; }

    public static Abastecimento Criar(Guid id, Guid veiculoId, Guid usuarioId, DadosAbastecimento dados, DateTimeOffset criadoEm, DateTimeOffset agora)
    {
        Validar(dados);
        var abastecimento = new Abastecimento { Id = id, VeiculoId = veiculoId, UsuarioId = usuarioId, CriadoEm = criadoEm };
        abastecimento.Copiar(dados, agora);
        return abastecimento;
    }

    public bool Aplicar(DadosAbastecimento dados, DateTimeOffset agora)
    {
        if (dados.AtualizadoEm <= AtualizadoEm)
            return false;
        Validar(dados);
        Copiar(dados, agora);
        return true;
    }

    private void Copiar(DadosAbastecimento dados, DateTimeOffset agora)
    {
        CopiarComum(dados.Data, dados.Odometro, dados.ValorTotal, dados.AtualizadoEm, dados.ExcluidoEm, agora);
        Combustivel = dados.Combustivel;
        Litros = dados.Litros;
        PrecoLitro = dados.PrecoLitro;
        TanqueCheio = dados.TanqueCheio;
        Posto = string.IsNullOrWhiteSpace(dados.Posto) ? null : dados.Posto.Trim();
        PostoId = dados.PostoId;
        TipoGasolina = dados.Combustivel == Combustivel.Gasolina ? dados.TipoGasolina : null;
        CopiarPagamento(dados.FormaPagamento, dados.CartaoId);
        ContaNaMedia = dados.ContaNaMedia;
    }

    private static void Validar(DadosAbastecimento dados)
    {
        ValidarComum(dados.Odometro, dados.ValorTotal);
        if (dados.Litros <= 0)
            throw new ExcecaoDeDominio("Os litros abastecidos precisam ser positivos.");
        if (dados.PrecoLitro <= 0)
            throw new ExcecaoDeDominio("O preço por litro precisa ser positivo.");
        if (dados.Posto?.Length > 100)
            throw new ExcecaoDeDominio("O nome do posto tem até 100 letras.");
    }
}

public sealed class Recarga : RegistroEnergia
{
    private Recarga()
    {
    }

    public LocalRecarga Local { get; private set; }
    public decimal Kwh { get; private set; }
    public decimal PrecoKwh { get; private set; }
    public bool CargaCompleta { get; private set; }

    public static Recarga Criar(Guid id, Guid veiculoId, Guid usuarioId, DadosRecarga dados, DateTimeOffset criadoEm, DateTimeOffset agora)
    {
        Validar(dados);
        var recarga = new Recarga { Id = id, VeiculoId = veiculoId, UsuarioId = usuarioId, CriadoEm = criadoEm };
        recarga.Copiar(dados, agora);
        return recarga;
    }

    public bool Aplicar(DadosRecarga dados, DateTimeOffset agora)
    {
        if (dados.AtualizadoEm <= AtualizadoEm)
            return false;
        Validar(dados);
        Copiar(dados, agora);
        return true;
    }

    private void Copiar(DadosRecarga dados, DateTimeOffset agora)
    {
        CopiarComum(dados.Data, dados.Odometro, dados.ValorTotal, dados.AtualizadoEm, dados.ExcluidoEm, agora);
        Local = dados.Local;
        Kwh = dados.Kwh;
        PrecoKwh = dados.PrecoKwh;
        CargaCompleta = dados.CargaCompleta;
        CopiarPagamento(dados.FormaPagamento, dados.CartaoId);
        ContaNaMedia = dados.ContaNaMedia;
    }

    private static void Validar(DadosRecarga dados)
    {
        ValidarComum(dados.Odometro, dados.ValorTotal);
        if (dados.Kwh <= 0)
            throw new ExcecaoDeDominio("A energia da recarga precisa ser positiva.");
        if (dados.PrecoKwh < 0)
            throw new ExcecaoDeDominio("O preço por kWh não pode ser negativo.");
    }
}
